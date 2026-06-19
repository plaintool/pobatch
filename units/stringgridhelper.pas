//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit StringGridHelper;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Graphics,
  Grids,
  Clipbrd,
  LazUTF8,
  LCLIntf,
  LCLType;

type
  TStringGridHelper = class helper for TStringGrid
  public
    // Paste TSV text from clipboard into the grid.
    // Respects selection, ReadOnly columns, and multiline quoted cells.
    procedure PasteFromClipboard;

    // Draw text in the grid with highlighting of the found substrings
    procedure DrawHighlightedText(ACanvas: TCanvas; ARect: TRect; aColorHighlight, aColorLineBreak: TColor;
      const AText, AFilterText: string; AWordWrap: boolean = False; AShowLineBreaks: boolean = False; ABiDiRightToLeft: boolean = False);
  end;

implementation

uses colorhelper;

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

procedure TStringGridHelper.DrawHighlightedText(ACanvas: TCanvas; ARect: TRect; aColorHighlight, aColorLineBreak: TColor;
  const AText, AFilterText: string; AWordWrap: boolean = False; AShowLineBreaks: boolean = False; ABiDiRightToLeft: boolean = False);
type
  TTextRange = record
    StartPos: integer;
    EndPos: integer;
    IsMatch: boolean;
  end;
  PTextRange = ^TTextRange;

  TLineWord = record
    word: string;
    Width: integer;
    IsMatch: boolean;
  end;
var
  TextRanges: TList;
  LineWords: array of TLineWord = ();
  LineStartIndex: integer; // Index of first word in current line
  LineWidth: integer;      // Current line width
  Flags: cardinal;
  CurrentY: integer;
  LineHeight: integer;
  SavedBrushStyle: TBrushStyle;
  SavedBrushColor: TColor;
  SavedTextColor: TColor;
  Range: PTextRange;
  Fragment: string;
  CurrentWord: string;
  WordStart, WordEnd: integer;
  WordWidth: integer;
  TotalGroupWidth: integer;
  I, J: integer;
  IsLineBreak: boolean;    // True if the current word is an explicit line break

// Build text ranges for highlighting matches
  procedure BuildTextRanges;
  var
    LowerText, LowerFilter: string;
    CurrentPos, MatchPos: integer;
    Range: PTextRange;
  begin
    if (AFilterText = '') or (AText = '') then
    begin
      // No filter text - create single normal range
      New(Range);
      Range^.StartPos := 1;
      Range^.EndPos := Length(AText);
      Range^.IsMatch := False;
      TextRanges.Add(Range);
      Exit;
    end;

    LowerText := UTF8LowerCase(AText);
    LowerFilter := UTF8LowerCase(AFilterText);
    CurrentPos := 1;

    while CurrentPos <= Length(AText) do
    begin
      MatchPos := Pos(LowerFilter, LowerText, CurrentPos);

      if MatchPos = 0 then
      begin
        // No more matches - add remaining text as normal range
        if CurrentPos <= Length(AText) then
        begin
          New(Range);
          Range^.StartPos := CurrentPos;
          Range^.EndPos := Length(AText);
          Range^.IsMatch := False;
          TextRanges.Add(Range);
        end;
        Break;
      end
      else
      begin
        // Add text before match as normal range
        if MatchPos > CurrentPos then
        begin
          New(Range);
          Range^.StartPos := CurrentPos;
          Range^.EndPos := MatchPos - 1;
          Range^.IsMatch := False;
          TextRanges.Add(Range);
        end;

        // Add matching text as highlight range
        New(Range);
        Range^.StartPos := MatchPos;
        Range^.EndPos := MatchPos + Length(AFilterText) - 1;
        Range^.IsMatch := True;
        TextRanges.Add(Range);

        CurrentPos := MatchPos + Length(AFilterText);
      end;
    end;
  end;

  // Draw a complete line
  procedure DrawLine(LineStart, LineEnd: integer; Y: integer; AIsLineBreakEnd: boolean = False);
  var
    J, X: integer;
    DrawRect: TRect;
    TotalLineWidth: integer;
    FontColor: TColor;
  begin
    // Remove last space
    LineWords[LineEnd].word := TrimRight(LineWords[LineEnd].word);
    LineWords[LineEnd].Width := ACanvas.TextWidth(LineWords[LineEnd].word);
    LineWords[LineStart].word := TrimLeft(LineWords[LineStart].word);
    LineWords[LineStart].Width := ACanvas.TextWidth(LineWords[LineStart].word);

    // Calculate total width of this line
    TotalLineWidth := 0;
    for J := LineStart to LineEnd do
      TotalLineWidth := TotalLineWidth + LineWords[J].Width;

    // Set starting X based on text direction
    if ABiDiRightToLeft then
      X := ARect.Right - TotalLineWidth // Align line to right
    else
      X := ARect.Left; // Align line to left

    // Ensure we don't draw outside the bounds
    if X < ARect.Left then X := ARect.Left;
    if X + TotalLineWidth > ARect.Right then
    begin
      // Adjust if line is too long (shouldn't happen with proper word wrapping)
      TotalLineWidth := ARect.Right - X;
      if ABiDiRightToLeft then
        X := ARect.Right - TotalLineWidth;
    end;

    // Draw all words in the line
    for J := LineStart to LineEnd do
    begin
      // Check if we're still within bounds
      if (X + LineWords[J].Width > ARect.Right) then
        Break;

      FontColor := ACanvas.Font.Color;
      DrawRect := Rect(X, Y, X + LineWords[J].Width, Y + LineHeight);
      if LineWords[J].IsMatch then
      begin
        ACanvas.Font.Color := aColorHighlight.GetContrastFontColor(aColorHighlight, FontColor);
        ACanvas.Brush.Style := bsSolid;
        ACanvas.Brush.Color := aColorHighlight;
        ACanvas.FillRect(DrawRect);
      end
      else
        ACanvas.Brush.Style := bsClear;

      Flags := DT_NOPREFIX;
      if ABiDiRightToLeft then
        Flags := Flags or longword(DT_RIGHT)
      else
        Flags := Flags or longword(DT_LEFT);
      if AWordWrap then
        Flags := Flags or DT_WORDBREAK;

      DrawText(ACanvas.handle, PChar(LineWords[J].word), Length(LineWords[J].word), DrawRect, Flags);
      X := X + LineWords[J].Width;
      ACanvas.Font.Color := FontColor;
    end;

    // Draw red \n at the end if line ended with explicit line break and feature enabled
    if AIsLineBreakEnd and AShowLineBreaks then
    begin
      ACanvas.Font.Color := ACanvas.Brush.Color.GetContrastFontColor(AColorLineBreak);
      ACanvas.TextOut(X, Y, '\n');
      ACanvas.Font.Color := SavedTextColor;
    end;
  end;

begin
  TextRanges := TList.Create;
  try
    // Save canvas state
    SavedBrushStyle := ACanvas.Brush.Style;
    SavedBrushColor := ACanvas.Brush.Color;
    SavedTextColor := ACanvas.Font.Color;

    try
      BuildTextRanges;
      if TextRanges.Count = 0 then Exit;
      LineHeight := ACanvas.TextHeight('Wg');

      // First, extract all words from all text ranges
      SetLength(LineWords, 0);

      for I := 0 to TextRanges.Count - 1 do
      begin
        Range := PTextRange(TextRanges[I]);
        Fragment := Copy(AText, Range^.StartPos, Range^.EndPos - Range^.StartPos + 1);

        WordStart := 1;
        while WordStart <= Length(Fragment) do
        begin
          // Find word boundaries (include spaces and line breaks as separate "words")
          WordEnd := WordStart;

          if Fragment[WordStart] = ' ' then
          begin
            // This is a space - treat it as a separate word
            while (WordEnd < Length(Fragment)) and (Fragment[WordEnd + 1] = ' ') do
              Inc(WordEnd);
          end
          else if (Fragment[WordStart] = #10) or (Fragment[WordStart] = #13) then
          begin
            // This is a line break - handle different line break types
            if (Fragment[WordStart] = #13) and (WordEnd < Length(Fragment)) and (Fragment[WordEnd + 1] = #10) then
            begin
              // Windows line break (CR+LF) - treat as single word
              Inc(WordEnd);
            end;
            // For Unix line breaks (LF only) or Mac classic (CR only), we don't need to do anything else
            // as WordEnd is already at the current position
          end
          else
          begin
            // This is a non-space word - continue until space or line break
            while (WordEnd < Length(Fragment)) and (Fragment[WordEnd + 1] <> ' ') and (Fragment[WordEnd + 1] <> #10) and
              (Fragment[WordEnd + 1] <> #13) do
              Inc(WordEnd);
          end;

          CurrentWord := Copy(Fragment, WordStart, WordEnd - WordStart + 1);

          // For line breaks, use a special representation or calculate width differently
          if (Fragment[WordStart] = #10) or (Fragment[WordStart] = #13) then
          begin
            // Line breaks have zero width for calculation purposes
            // but we need to handle them specially during drawing
            WordWidth := 0;

            // Optionally, you could replace line break with a visible character for debugging
            // CurrentWord := '¶'; // Uncomment for debugging
            // WordWidth := ACanvas.TextWidth('¶'); // Uncomment for debugging
          end
          else
          begin
            WordWidth := ACanvas.TextWidth(CurrentWord);
          end;

          // Add word to array
          SetLength(LineWords, Length(LineWords) + 1);
          LineWords[High(LineWords)].word := CurrentWord;
          LineWords[High(LineWords)].Width := WordWidth;
          LineWords[High(LineWords)].IsMatch := Range^.IsMatch;

          WordStart := WordEnd + 1;
        end;
      end;

      if Length(LineWords) = 0 then Exit;

      // Now break into lines and draw
      LineStartIndex := 0;
      LineWidth := 0;
      CurrentY := ARect.Top;

      for I := 0 to High(LineWords) do
      begin
        WordWidth := LineWords[I].Width;

        // Calculate total width from current position to next break (space or line break)
        TotalGroupWidth := WordWidth;

        // Look ahead to find the next break and calculate total width
        for J := I + 1 to High(LineWords) do
        begin
          // Stop at next break (space or line break)
          if (LineWords[J].word = ' ') or (LineWords[J].word = #10) or (LineWords[J].word = #13) or
            (LineWords[J].word = #13#10) then
            Break;

          TotalGroupWidth := TotalGroupWidth + LineWords[J].Width;
        end;

        // Determine if current word is a line break
        IsLineBreak := (LineWords[I].word = #10) or (LineWords[I].word = #13) or (LineWords[I].word = #13#10);

        // Check if the entire group fits or if it's a line break
        if ((LineWidth > 0) and (LineWidth + TotalGroupWidth > ARect.Width)) or IsLineBreak then
        begin
          DrawLine(LineStartIndex, I - 1, CurrentY, IsLineBreak);
          CurrentY := CurrentY + LineHeight;
          if CurrentY + LineHeight > ARect.Bottom then
            Exit;
          LineStartIndex := I;
          LineWidth := WordWidth;
        end
        else
        begin
          LineWidth := LineWidth + WordWidth;
        end;
      end;

      // Draw the last line
      if LineStartIndex <= High(LineWords) then
        DrawLine(LineStartIndex, High(LineWords), CurrentY);

    finally
      // Restore canvas state
      ACanvas.Brush.Style := SavedBrushStyle;
      ACanvas.Brush.Color := SavedBrushColor;
      ACanvas.Font.Color := SavedTextColor;
    end;

  finally
    // Clean up text ranges
    for I := 0 to TextRanges.Count - 1 do
      Dispose(PTextRange(TextRanges[I]));
    TextRanges.Free;
  end;
end;

end.
