//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit GridHelper;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Grids,
  Clipbrd;

type
  TStringGridHelper = class helper for TStringGrid
  public
    // Paste TSV text from clipboard into the grid.
    // Respects selection, ReadOnly columns, and multiline quoted cells.
    procedure PasteFromClipboard;
  end;

implementation

{ TStringGridHelper }

procedure TStringGridHelper.PasteFromClipboard;
var
  TextData: string;
  Stream: TStringStream;
  StartCol, StartRow, MaxRow, MaxCol: integer;

// ------------------------------------------------------------------
// Embedded TSV parser – mimics the LCL's LoadFromCSVStream behaviour.
// Handles quoted fields, embedded newlines, and doubled quotes.
// Inserts directly into the grid cells.
// ------------------------------------------------------------------
  procedure ParseTSV(AStream: TStream);
  var
    Buffer: ansistring;
    BytesRead, BufLen, BufDelta: longint;
    leadPtr, tailPtr, wordPtr: pchar;
    curWord: string;
    Line: TStringList;
    I: integer;
    ColIdx: integer;

    procedure NotifyLine;
    var
      J: integer;
      CustomColIdx: integer;
    begin
      if Assigned(Line) and (Line.Count > 0) then
      begin
        if StartRow <= MaxRow then
        begin
          for J := 0 to Line.Count - 1 do
          begin
            ColIdx := StartCol + J;
            if (ColIdx >= Self.FixedCols) and (ColIdx < Self.ColCount) and (StartRow >= Self.FixedRows) and
              (StartRow < Self.RowCount) then
            begin
              // Calculate the correct index for the Columns collection
              CustomColIdx := ColIdx - Self.FixedCols;

              if (CustomColIdx >= 0) and (CustomColIdx < Self.Columns.Count) then
                if Self.Columns[CustomColIdx].ReadOnly then
                  Continue;

              Self.Cells[ColIdx, StartRow] := Line[J];
            end;
          end;
          Inc(StartRow);
        end;
        Line.Clear;
      end;
    end;

    procedure StoreWord; inline;
    begin
      if not Assigned(Line) then
        Line := TStringList.Create;
      Line.Add(curWord);
      curWord := '';
    end;

    function SkipSet(const aSet: TSysCharSet): boolean; inline;
    begin
      while (leadPtr < tailPtr) and (leadPtr^ in aSet) do Inc(leadPtr);
      Result := leadPtr < tailPtr;
    end;

    function FindSet(const aSet: TSysCharSet): boolean; inline;
    begin
      while (leadPtr < tailPtr) and (not (leadPtr^ in aSet)) do Inc(leadPtr);
      Result := leadPtr < tailPtr;
    end;

    procedure ProcessEndline; inline;
    begin
      if curWord <> '' then
        StoreWord;
      NotifyLine;
      if leadPtr < tailPtr then
      begin
        if (leadPtr^ = #13) and ((leadPtr + 1)^ = #10) then
          Inc(leadPtr);
        Inc(leadPtr);
        wordPtr := leadPtr;
      end;
    end;

    procedure ProcessQuote;
    var
      endQuote, endField: pchar;
      isDelimiter: boolean;
    begin
      Inc(leadPtr); // skip opening quote
      wordPtr := leadPtr;
      while leadPtr < tailPtr do
      begin
        if not FindSet(['"']) then
          break;
        if (leadPtr + 1)^ = '"' then
        begin
          Inc(leadPtr);
          SetLength(curWord, Length(curWord) + (leadPtr - wordPtr));
          Move(wordPtr^, curWord[Length(curWord) - (leadPtr - wordPtr) + 1], leadPtr - wordPtr);
          Inc(leadPtr);
          wordPtr := leadPtr;
        end
        else
        begin
          // closing quote
          endQuote := leadPtr;
          Inc(leadPtr);
          SkipSet([' ']);
          endField := leadPtr;
          if (leadPtr >= tailPtr) or (leadPtr^ in [#9, #10, #13]) then
          begin
            isDelimiter := (leadPtr < tailPtr) and (leadPtr^ = #9);
            SetLength(curWord, Length(curWord) + (endQuote - wordPtr));
            Move(wordPtr^, curWord[Length(curWord) - (endQuote - wordPtr) + 1], endQuote - wordPtr);
            if isDelimiter then
              StoreWord
            else
            begin
              StoreWord;
              NotifyLine;
            end;
            leadPtr := endField;
            wordPtr := leadPtr;
            break;
          end;
        end;
      end;
      if leadPtr <> wordPtr then
      begin
        // unclosed quote – take the rest
        SetLength(curWord, Length(curWord) + (tailPtr - wordPtr));
        Move(wordPtr^, curWord[Length(curWord) - (tailPtr - wordPtr) + 1], tailPtr - wordPtr);
        leadPtr := tailPtr;
        wordPtr := leadPtr;   // <-- prevent double paste
        StoreWord;
        NotifyLine;
      end;
    end;

  begin
    Buffer := '';
    BufLen := 0;
    I := 1;
    repeat
      BufDelta := 1024 * I;
      SetLength(Buffer, BufLen + BufDelta);
      BytesRead := AStream.Read(Buffer[BufLen + 1], BufDelta);
      Inc(BufLen, BufDelta);
      if I < 10 then I := I shl 1;
    until BytesRead <> BufDelta;
    BufLen := BufLen - BufDelta + BytesRead;
    SetLength(Buffer, BufLen);
    if BufLen = 0 then Exit;

    curWord := '';
    leadPtr := @Buffer[1];
    tailPtr := leadPtr + BufLen;
    wordPtr := leadPtr;
    Line := nil;
    try
      while leadPtr < tailPtr do
      begin
        SkipSet([' ']);
        if leadPtr >= tailPtr then break;
        if leadPtr^ = '"' then
          ProcessQuote
        else if leadPtr^ in [#10, #13] then
          ProcessEndline
        else if leadPtr^ = #9 then
        begin
          StoreWord;
          Inc(leadPtr);
          wordPtr := leadPtr;
        end
        else
        begin
          if FindSet([#9, #10, #13, '"']) then
          begin
            SetLength(curWord, Length(curWord) + (leadPtr - wordPtr));
            Move(wordPtr^, curWord[Length(curWord) - (leadPtr - wordPtr) + 1], leadPtr - wordPtr);
          end
          else
          begin
            // end of buffer without delimiter
            SetLength(curWord, Length(curWord) + (tailPtr - wordPtr));
            Move(wordPtr^, curWord[Length(curWord) - (tailPtr - wordPtr) + 1], tailPtr - wordPtr);
            leadPtr := tailPtr;
            wordPtr := leadPtr;   // <-- prevent double paste
            StoreWord;
            NotifyLine;
            break;
          end;
        end;
      end;
      if wordPtr < tailPtr then
      begin
        // final piece (should not be reached with above fix, but kept for safety)
        SetLength(curWord, Length(curWord) + (tailPtr - wordPtr));
        Move(wordPtr^, curWord[Length(curWord) - (tailPtr - wordPtr) + 1], tailPtr - wordPtr);
        wordPtr := tailPtr;       // <-- prevent double paste
        StoreWord;
        NotifyLine;
      end;
    finally
      Line.Free;
    end;
  end;

begin
  if not Clipboard.HasFormat(CF_TEXT) then Exit;
  TextData := Clipboard.AsText;
  if TextData = '' then Exit;

  Stream := TStringStream.Create(TextData);
  try
    // Determine the paste area
    if (Self.Selection.Left <> Self.Selection.Right) or (Self.Selection.Top <> Self.Selection.Bottom) then
    begin
      StartCol := Self.Selection.Left;
      StartRow := Self.Selection.Top;
      MaxRow := Self.Selection.Bottom;
      MaxCol := Self.Selection.Right;
    end
    else
    begin
      StartCol := Self.Col;
      StartRow := Self.Row;
      MaxRow := Self.RowCount - 1;
      MaxCol := Self.ColCount - 1;
    end;

    if StartCol < Self.FixedCols then StartCol := Self.FixedCols;
    if StartRow < Self.FixedRows then StartRow := Self.FixedRows;
    if (StartRow > MaxRow) or (StartCol > MaxCol) then Exit;

    ParseTSV(Stream);
  finally
    Stream.Free;
  end;
end;

end.
