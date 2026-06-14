//-----------------------------------------------------------------------------------
//  PoFormat © 2026 by Alexander Tverskoy
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit powrap;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  Classes, SysUtils, Contnrs;

type
  TPOCommentType = (
    poctTranslator,   // #  (free comment by translator)
    poctExtracted,    // #. (extracted from source code by xgettext)
    poctReference,    // #: (source file and line reference)
    poctPrevious,     // #| (previous untranslated string, after msgmerge)
    poctFlag          // #, (flags like fuzzy, c-format, etc.)
    );

  TPOComment = class
  public
    CommentType: TPOCommentType;
    Text: string;
    constructor Create(AType: TPOCommentType; const AText: string);
  end;

  TPOCommentList = class(TObjectList)
  private
    function GetItem(Index: integer): TPOComment;
    procedure SetItem(Index: integer; const Value: TPOComment);
  public
    property Items[Index: integer]: TPOComment read GetItem write SetItem; default;
    function Add(Comment: TPOComment): integer;
  end;

  TPOEntry = class
  private
    FComments: TPOCommentList;
    FMsgCtxt: string;
    FMsgId: string;
    FMsgIdPlural: string;
    FMsgStr: TStringList;
    FObsolete: boolean;
    // Raw storage for exact reproduction
    FRawComments: TStringList;
    FRawMsgCtxt: TStringList;
    FRawMsgId: TStringList;
    FRawMsgIdPlural: TStringList;
    FRawMsgStr: array of TStringList; // per plural form
    function GetMsgStr(Index: integer): string;
    procedure SetMsgStr(Index: integer; const Value: string);
    function GetMsgStrCount: integer;
    function GetFlagsString: string;
    procedure SetFlagsString(const AValue: string);
    function GetMsgStrSimple: string;
    procedure SetMsgStrSimple(const AValue: string);
    function GetIsPlural: boolean;
    procedure ClearRawMsgStrArray;
    procedure ClearRawComments;
    procedure ClearRawCtxt;
    procedure ClearRawId;
    procedure ClearRawIdPlural;
    procedure ClearRawMsgStr(Index: integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;

    function GetCommentsAsStrings: TStrings;
    procedure LoadCommentsFromStrings(const Lines: TStrings);

    procedure AddComment(AType: TPOCommentType; const AText: string);
    procedure DeleteCommentsOfType(AType: TPOCommentType);
    function GetCommentsOfType(AType: TPOCommentType): TStrings;

    property Flags: string read GetFlagsString write SetFlagsString;
    property MsgStrSimple: string read GetMsgStrSimple write SetMsgStrSimple;
    property MsgStr[Index: integer]: string read GetMsgStr write SetMsgStr;
    property MsgStrCount: integer read GetMsgStrCount;

    property MsgCtxt: string read FMsgCtxt write FMsgCtxt;
    property MsgId: string read FMsgId write FMsgId;
    property MsgIdPlural: string read FMsgIdPlural write FMsgIdPlural;
    property IsPlural: boolean read GetIsPlural;
    property Obsolete: boolean read FObsolete write FObsolete;

    property Comments: TPOCommentList read FComments;
    property RawComments: TStringList read FRawComments;
    property RawMsgCtxt: TStringList read FRawMsgCtxt;
    property RawMsgId: TStringList read FRawMsgId;
    property RawMsgIdPlural: TStringList read FRawMsgIdPlural;
    function GetRawMsgStr(Index: integer): TStringList;
    procedure SetRawMsgStr(Index: integer; AList: TStrings);
  end;

  TPOEntryList = class(TObjectList)
  private
    function GetItem(Index: integer): TPOEntry;
    procedure SetItem(Index: integer; const Value: TPOEntry);
  public
    property Items[Index: integer]: TPOEntry read GetItem write SetItem; default;
    function Add(Entry: TPOEntry): integer;
  end;

  TParseState = record
    Field: string;        // 'msgid', 'msgid_plural', 'msgctxt', 'msgstr', 'msgstrN'
    PluralIndex: integer;
    MultiBuffer: TStrings;
    ExpectContinuation: boolean; // true after empty "msgid" or "msgstr"
  end;

  TPOFile = class
  private
    FEntries: TPOEntryList;
    FEncoding: TEncoding;
    procedure ParseLine(const Line: string; var CurrentEntry: TPOEntry; var PendingState: TParseState);
    function UnescapeString(const S: string): string;
    function EscapeString(const S: string): string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromStream(AStream: TStream);
    procedure LoadFromFile(const AFilename: string);
    procedure SaveToStream(AStream: TStream);
    procedure SaveToFile(const AFilename: string);

    procedure Clear;
    function FindEntry(const AMsgCtxt, AMsgId: string): TPOEntry;
    procedure WriteEntry(Entry: TPOEntry; Lines: TStrings);

    property Entries: TPOEntryList read FEntries;
    property Encoding: TEncoding read FEncoding write FEncoding;
  end;

implementation

{ TPOComment }

constructor TPOComment.Create(AType: TPOCommentType; const AText: string);
begin
  inherited Create;
  CommentType := AType;
  Text := AText;
end;

{ TPOCommentList }

function TPOCommentList.GetItem(Index: integer): TPOComment;
begin
  Result := TPOComment(inherited Items[Index]);
end;

procedure TPOCommentList.SetItem(Index: integer; const Value: TPOComment);
begin
  inherited Items[Index] := Value;
end;

function TPOCommentList.Add(Comment: TPOComment): integer;
begin
  Result := inherited Add(Comment);
end;

{ TPOEntry }

constructor TPOEntry.Create;
begin
  inherited;
  FComments := TPOCommentList.Create(True);
  FMsgStr := TStringList.Create;
  FRawComments := TStringList.Create;
  FRawMsgCtxt := TStringList.Create;
  FRawMsgId := TStringList.Create;
  FRawMsgIdPlural := TStringList.Create;
end;

destructor TPOEntry.Destroy;
begin
  FComments.Free;
  FMsgStr.Free;
  FRawComments.Free;
  FRawMsgCtxt.Free;
  FRawMsgId.Free;
  FRawMsgIdPlural.Free;
  ClearRawMsgStrArray;
  inherited;
end;

procedure TPOEntry.Clear;
begin
  FComments.Clear;
  FMsgCtxt := '';
  FMsgId := '';
  FMsgIdPlural := '';
  FMsgStr.Clear;
  FObsolete := False;
  FRawComments.Clear;
  FRawMsgCtxt.Clear;
  FRawMsgId.Clear;
  FRawMsgIdPlural.Clear;
  ClearRawMsgStrArray;
end;

procedure TPOEntry.ClearRawComments;
begin
  FRawComments.Clear;
end;

procedure TPOEntry.ClearRawCtxt;
begin
  FRawMsgCtxt.Clear;
end;

procedure TPOEntry.ClearRawId;
begin
  FRawMsgId.Clear;
end;

procedure TPOEntry.ClearRawIdPlural;
begin
  FRawMsgIdPlural.Clear;
end;

procedure TPOEntry.ClearRawMsgStrArray;
var
  i: integer;
begin
  for i := 0 to High(FRawMsgStr) do
    FRawMsgStr[i].Free;
  SetLength(FRawMsgStr, 0);
end;

function TPOEntry.GetRawMsgStr(Index: integer): TStringList;
begin
  if (Index >= 0) and (Index < Length(FRawMsgStr)) then
    Result := FRawMsgStr[Index]
  else
    Result := nil;
end;

procedure TPOEntry.SetRawMsgStr(Index: integer; AList: TStrings);
var
  i: integer;
begin
  if Index < 0 then Exit;
  // Ensure array size
  if Index >= Length(FRawMsgStr) then
  begin
    SetLength(FRawMsgStr, Index + 1);
    for i := 0 to High(FRawMsgStr) do
      if FRawMsgStr[i] = nil then
        FRawMsgStr[i] := TStringList.Create;
  end;
  if FRawMsgStr[Index] = nil then
    FRawMsgStr[Index] := TStringList.Create;
  if AList <> nil then
    FRawMsgStr[Index].Assign(AList)
  else
    FRawMsgStr[Index].Clear;
end;

procedure TPOEntry.ClearRawMsgStr(Index: integer);
begin
  if (Index >= 0) and (Index < Length(FRawMsgStr)) and (FRawMsgStr[Index] <> nil) then
    FRawMsgStr[Index].Clear;
end;

function TPOEntry.GetCommentsAsStrings: TStrings;
var
  i: integer;
  c: TPOComment;
begin
  Result := TStringList.Create;
  for i := 0 to FComments.Count - 1 do
  begin
    c := TPOComment(FComments[i]);
    case c.CommentType of
      poctTranslator: Result.Add('# ' + c.Text);
      poctExtracted: Result.Add('#. ' + c.Text);
      poctReference: Result.Add('#: ' + c.Text);
      poctPrevious: Result.Add('#| ' + c.Text);
      poctFlag: Result.Add('#, ' + c.Text);
    end;
  end;
end;

procedure TPOEntry.LoadCommentsFromStrings(const Lines: TStrings);
var
  s: string;
begin
  FComments.Clear;
  ClearRawComments;
  for s in Lines do
  begin
    if s = '' then Continue;
    if Copy(s, 1, 2) = '#.' then
      AddComment(poctExtracted, Trim(Copy(s, 3, MaxInt)))
    else if Copy(s, 1, 2) = '#:' then
      AddComment(poctReference, Trim(Copy(s, 3, MaxInt)))
    else if Copy(s, 1, 2) = '#|' then
      AddComment(poctPrevious, Trim(Copy(s, 3, MaxInt)))
    else if (Length(s) >= 2) and (s[2] = ',') then
      AddComment(poctFlag, Trim(Copy(s, 3, MaxInt)))
    else if (Length(s) >= 2) and (s[2] = '~') then
      Continue
    else if s[1] = '#' then
      AddComment(poctTranslator, Trim(Copy(s, 2, MaxInt)));
  end;
end;

procedure TPOEntry.AddComment(AType: TPOCommentType; const AText: string);
begin
  FComments.Add(TPOComment.Create(AType, AText));
  ClearRawComments;
end;

procedure TPOEntry.DeleteCommentsOfType(AType: TPOCommentType);
var
  i: integer;
begin
  for i := FComments.Count - 1 downto 0 do
    if TPOComment(FComments[i]).CommentType = AType then
      FComments.Delete(i);
  ClearRawComments;
end;

function TPOEntry.GetCommentsOfType(AType: TPOCommentType): TStrings;
var
  i: integer;
  sl: TStringList;
begin
  sl := TStringList.Create;
  for i := 0 to FComments.Count - 1 do
    if TPOComment(FComments[i]).CommentType = AType then
      sl.Add(TPOComment(FComments[i]).Text);
  Result := sl;
end;

function TPOEntry.GetFlagsString: string;
var
  i: integer;
  s: string;
begin
  Result := '';
  for i := 0 to FComments.Count - 1 do
    if TPOComment(FComments[i]).CommentType = poctFlag then
    begin
      s := Trim(TPOComment(FComments[i]).Text);
      if Result = '' then
        Result := s
      else
        Result := Result + ',' + s;
    end;
end;

procedure TPOEntry.SetFlagsString(const AValue: string);
var
  sl: TStringList;
  i: integer;
  FlagText: string;
begin
  DeleteCommentsOfType(poctFlag);
  sl := TStringList.Create;
  try
    sl.CommaText := AValue;
    for i := 0 to sl.Count - 1 do
    begin
      FlagText := Trim(sl[i]);
      if FlagText <> '' then
        AddComment(poctFlag, FlagText);
    end;
  finally
    sl.Free;
  end;
  ClearRawComments;
end;

function TPOEntry.GetMsgStr(Index: integer): string;
begin
  if (Index >= 0) and (Index < FMsgStr.Count) then
    Result := FMsgStr[Index]
  else
    Result := '';
end;

procedure TPOEntry.SetMsgStr(Index: integer; const Value: string);
begin
  while FMsgStr.Count <= Index do
    FMsgStr.Add('');
  FMsgStr[Index] := Value;
  ClearRawMsgStr(Index);
end;

function TPOEntry.GetMsgStrCount: integer;
begin
  Result := FMsgStr.Count;
end;

function TPOEntry.GetMsgStrSimple: string;
begin
  if FMsgStr.Count > 0 then
    Result := FMsgStr[0]
  else
    Result := '';
end;

procedure TPOEntry.SetMsgStrSimple(const AValue: string);
begin
  while FMsgStr.Count <= 0 do
    FMsgStr.Add('');
  FMsgStr[0] := AValue;
  ClearRawMsgStr(0);
end;

function TPOEntry.GetIsPlural: boolean;
begin
  Result := FMsgIdPlural <> '';
end;

{ TPOEntryList }

function TPOEntryList.GetItem(Index: integer): TPOEntry;
begin
  Result := TPOEntry(inherited Items[Index]);
end;

procedure TPOEntryList.SetItem(Index: integer; const Value: TPOEntry);
begin
  inherited Items[Index] := Value;
end;

function TPOEntryList.Add(Entry: TPOEntry): integer;
begin
  Result := inherited Add(Entry);
end;

{ TPOFile }

constructor TPOFile.Create;
begin
  inherited;
  FEntries := TPOEntryList.Create(True);
  FEncoding := TEncoding.UTF8;
end;

destructor TPOFile.Destroy;
begin
  FEntries.Free;
  inherited;
end;

procedure TPOFile.Clear;
begin
  FEntries.Clear;
end;

function TPOFile.UnescapeString(const S: string): string;
var
  i: integer;
begin
  Result := '';
  i := 1;
  while i <= Length(S) do
  begin
    if (S[i] = '\') and (i < Length(S)) then
    begin
      Inc(i);
      case S[i] of
        'n': Result := Result + #10;
        't': Result := Result + #9;
        'r': Result := Result + #13;
        '\': Result := Result + '\';
        '"': Result := Result + '"';
        else
          Result := Result + '\' + S[i];
      end;
    end
    else
      Result := Result + S[i];
    Inc(i);
  end;
end;

function TPOFile.EscapeString(const S: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    case S[i] of
      '\': Result := Result + '\\';
      '"': Result := Result + '\"';
      #10: Result := Result + '\n';
      #13: Result := Result + '\r';
      #9: Result := Result + '\t';
      else
        Result := Result + S[i];
    end;
  end;
end;

procedure TPOFile.ParseLine(const Line: string; var CurrentEntry: TPOEntry;
  var PendingState: TParseState);

  procedure FinalizeCurrentEntry;
  begin
    if CurrentEntry <> nil then
    begin
      FEntries.Add(CurrentEntry);
      CurrentEntry := nil;
    end;
  end;

  procedure FinalizePendingField;
  var
    TempStr: string;
    i: integer;
    TempSL: TStringList;
  begin
    if PendingState.MultiBuffer.Count > 0 then
    begin
      // Concatenate parts directly (no extra CR/LF)
      TempStr := '';
      for i := 0 to PendingState.MultiBuffer.Count - 1 do
        TempStr := TempStr + PendingState.MultiBuffer[i];
      TempStr := UnescapeString(TempStr);

      if PendingState.Field = 'msgid' then
      begin
        CurrentEntry.MsgId := TempStr;
        CurrentEntry.RawMsgId.Clear;
        CurrentEntry.RawMsgId.Assign(PendingState.MultiBuffer);
      end
      else if PendingState.Field = 'msgid_plural' then
      begin
        CurrentEntry.MsgIdPlural := TempStr;
        CurrentEntry.RawMsgIdPlural.Clear;
        CurrentEntry.RawMsgIdPlural.Assign(PendingState.MultiBuffer);
      end
      else if PendingState.Field = 'msgctxt' then
      begin
        CurrentEntry.MsgCtxt := TempStr;
        CurrentEntry.RawMsgCtxt.Clear;
        CurrentEntry.RawMsgCtxt.Assign(PendingState.MultiBuffer);
      end
      else if PendingState.Field = 'msgstr' then
      begin
        CurrentEntry.MsgStrSimple := TempStr;
        CurrentEntry.SetRawMsgStr(0, PendingState.MultiBuffer);
      end
      else if PendingState.Field = 'msgstrN' then
      begin
        CurrentEntry.MsgStr[PendingState.PluralIndex] := TempStr;
        CurrentEntry.SetRawMsgStr(PendingState.PluralIndex, PendingState.MultiBuffer);
      end;

      PendingState.MultiBuffer.Clear;
      PendingState.Field := '';
    end
    else if PendingState.Field <> '' then
    begin
      // Empty field without any continuation lines
      if PendingState.Field = 'msgid' then
      begin
        CurrentEntry.MsgId := '';
        CurrentEntry.RawMsgId.Clear;
        CurrentEntry.RawMsgId.Add('');
      end
      else if PendingState.Field = 'msgid_plural' then
      begin
        CurrentEntry.MsgIdPlural := '';
        CurrentEntry.RawMsgIdPlural.Clear;
        CurrentEntry.RawMsgIdPlural.Add('');
      end
      else if PendingState.Field = 'msgctxt' then
      begin
        CurrentEntry.MsgCtxt := '';
        CurrentEntry.RawMsgCtxt.Clear;
        CurrentEntry.RawMsgCtxt.Add('');
      end
      else if PendingState.Field = 'msgstr' then
      begin
        CurrentEntry.MsgStrSimple := '';
        TempSL := TStringList.Create;
        try
          TempSL.Add('');
          CurrentEntry.SetRawMsgStr(0, TempSL);
        finally
          TempSL.Free;
        end;
      end
      else if PendingState.Field = 'msgstrN' then
      begin
        CurrentEntry.MsgStr[PendingState.PluralIndex] := '';
        TempSL := TStringList.Create;
        try
          TempSL.Add('');
          CurrentEntry.SetRawMsgStr(PendingState.PluralIndex, TempSL);
        finally
          TempSL.Free;
        end;
      end;
      PendingState.Field := '';
    end;
  end;

var
  TrimmedLine: string;
  Key, Value: string;
  EqPos: Integer;
  TempStr: string;
  Content: string;
begin
  TrimmedLine := TrimRight(Line);

  // Empty line separates entries
  if TrimmedLine = '' then
  begin
    FinalizePendingField;
    FinalizeCurrentEntry;
    Exit;
  end;

  // Comment line
  if (TrimmedLine[1] = '#') then
  begin
    if PendingState.Field <> '' then
      Exit; // comment cannot break a multi-line string

    if CurrentEntry = nil then
      CurrentEntry := TPOEntry.Create;

    // Store raw comment line
    CurrentEntry.FRawComments.Add(TrimmedLine);

    // Build typed comment without calling AddComment (which would clear RawComments)
    if Copy(TrimmedLine, 1, 2) = '#.' then
      CurrentEntry.FComments.Add(TPOComment.Create(poctExtracted, Trim(Copy(TrimmedLine, 3, MaxInt))))
    else if Copy(TrimmedLine, 1, 2) = '#:' then
      CurrentEntry.FComments.Add(TPOComment.Create(poctReference, Trim(Copy(TrimmedLine, 3, MaxInt))))
    else if Copy(TrimmedLine, 1, 2) = '#|' then
      CurrentEntry.FComments.Add(TPOComment.Create(poctPrevious, Trim(Copy(TrimmedLine, 3, MaxInt))))
    else if (Length(TrimmedLine) >= 2) and (TrimmedLine[2] = ',') then
      CurrentEntry.FComments.Add(TPOComment.Create(poctFlag, Trim(Copy(TrimmedLine, 3, MaxInt))))
    else if Copy(TrimmedLine, 1, 2) = '#~' then
    begin
      CurrentEntry.Obsolete := True;
      // In obsolete entries we might have content after #~, ignored for now
    end
    else
      CurrentEntry.FComments.Add(TPOComment.Create(poctTranslator, Trim(Copy(TrimmedLine, 2, MaxInt))));
    Exit;
  end;

  // Continuation of a multi-line string (starts with a quote)
  if (TrimmedLine[1] = '"') and (PendingState.Field <> '') then
  begin
    TempStr := Copy(TrimmedLine, 2, Length(TrimmedLine)-2);
    PendingState.MultiBuffer.Add(TempStr);
    Exit;
  end;

  // If we are in the middle of a multi-line field, finalize it before new directive
  FinalizePendingField;

  // Parse key/value
  Key := TrimmedLine;
  EqPos := Pos(' ', Key);
  if EqPos > 0 then
    Key := Copy(Key, 1, EqPos-1);
  Value := Trim(Copy(TrimmedLine, Length(Key)+1, MaxInt));

  // Start a new entry on msgid or msgctxt, but only if we already have a completed entry
  if (Key = 'msgid') or (Key = 'msgctxt') then
  begin
    if (CurrentEntry <> nil) and (CurrentEntry.MsgId <> '') then
      FinalizeCurrentEntry;
  end;

  if CurrentEntry = nil then
    CurrentEntry := TPOEntry.Create;

  // Set new field state
  if Key = 'msgctxt' then
  begin
    PendingState.Field := 'msgctxt';
    PendingState.PluralIndex := -1;
  end
  else if Key = 'msgid' then
  begin
    PendingState.Field := 'msgid';
    PendingState.PluralIndex := -1;
  end
  else if Key = 'msgid_plural' then
  begin
    PendingState.Field := 'msgid_plural';
    PendingState.PluralIndex := -1;
  end
  else if Key = 'msgstr' then
  begin
    PendingState.Field := 'msgstr';
    PendingState.PluralIndex := -1;
  end
  else if (Copy(Key, 1, 6) = 'msgstr') and (Length(Key) > 6) and (Key[7] = '[') then
  begin
    PendingState.Field := 'msgstrN';
    TempStr := Copy(Key, 8, Length(Key)-8);
    PendingState.PluralIndex := StrToIntDef(TempStr, -1);
  end
  else
    Exit;

  // Process the value part
  if (Value <> '') and (Value[1] = '"') then
  begin
    PendingState.MultiBuffer.Clear;
    Content := Copy(Value, 2, Length(Value)-2);
    // Only add non-empty content; empty content means multi-line start
    if Content <> '' then
      PendingState.MultiBuffer.Add(Content);
    // else leave MultiBuffer empty => ready for continuation lines
  end
  else
  begin
    // Empty value, e.g. msgstr "" – keep state ready for continuation
    PendingState.MultiBuffer.Clear;
    // No immediate assignment, will be handled by continuation or FinalizePendingField
  end;
end;

procedure TPOFile.LoadFromStream(AStream: TStream);
var
  sl: TStringList;
  i: integer;
  Line: string;
  CurrentEntry: TPOEntry;
  PendingState: TParseState;
begin
  FEntries.Clear;
  CurrentEntry := nil;
  PendingState.Field := '';
  PendingState.PluralIndex := -1;
  PendingState.MultiBuffer := TStringList.Create;
  try
    sl := TStringList.Create;
    try
      sl.LoadFromStream(AStream, FEncoding);
      for i := 0 to sl.Count - 1 do
      begin
        Line := sl[i];
        ParseLine(Line, CurrentEntry, PendingState);
      end;
    finally
      sl.Free;
    end;

    // Finalize any pending field and entry
    if PendingState.Field <> '' then
    begin
      // Force finalization of remaining multi buffer
      if PendingState.MultiBuffer.Count > 0 then
        ParseLine('', CurrentEntry, PendingState)  // empty line triggers finalization
      else
      begin
        // Empty field finalize
        if CurrentEntry = nil then CurrentEntry := TPOEntry.Create;
        if PendingState.Field = 'msgid' then CurrentEntry.MsgId := ''
        else if PendingState.Field = 'msgid_plural' then CurrentEntry.MsgIdPlural := ''
        else if PendingState.Field = 'msgctxt' then CurrentEntry.MsgCtxt := ''
        else if PendingState.Field = 'msgstr' then CurrentEntry.MsgStrSimple := ''
        else if PendingState.Field = 'msgstrN' then CurrentEntry.MsgStr[PendingState.PluralIndex] := '';
      end;
    end;
    if CurrentEntry <> nil then
      FEntries.Add(CurrentEntry);
  finally
    PendingState.MultiBuffer.Free;
  end;
end;

procedure TPOFile.LoadFromFile(const AFilename: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(FS);
  finally
    FS.Free;
  end;
end;

procedure TPOFile.WriteEntry(Entry: TPOEntry; Lines: TStrings);

  procedure WriteFieldLines(Raw: TStrings; const Value: string; const Prefix: string);
  var
    i: integer;
    escapedLine: string;
    subLines: TStringList;
  begin
    if Raw.Count > 0 then
    begin
      // Output exactly as parsed
      if Raw.Count = 1 then
        Lines.Add(Prefix + '"' + Raw[0] + '"')
      else
      begin
        Lines.Add(Prefix + '""');
        for i := 0 to Raw.Count - 1 do
          Lines.Add('"' + Raw[i] + '"');
      end;
    end
    else
    begin
      // Generate new multi-line output based on value
      if Value = '' then
      begin
        Lines.Add(Prefix + '""');
        Exit;
      end;
      subLines := TStringList.Create;
      try
        subLines.Text := Value; // breaks by line endings
        if subLines.Count <= 1 then
        begin
          Lines.Add(Prefix + '"' + EscapeString(Value) + '"');
        end
        else
        begin
          Lines.Add(Prefix + '""');
          for i := 0 to subLines.Count - 1 do
          begin
            escapedLine := EscapeString(subLines[i]);
            Lines.Add('"' + escapedLine + '"');
          end;
        end;
      finally
        subLines.Free;
      end;
    end;
  end;

var
  i: integer;
  Prefix: string;
  rawMsg: TStringList;
begin
  if Entry.Obsolete then
    Prefix := '#~ '
  else
    Prefix := '';

  // Comments: raw lines have priority, preserving exact order
  if Entry.RawComments.Count > 0 then
  begin
    for i := 0 to Entry.RawComments.Count - 1 do
      Lines.Add(Prefix + Entry.RawComments[i]);
  end
  else
  begin
    // Build from typed comments (when raw was cleared by editing)
    for i := 0 to Entry.FComments.Count - 1 do
    begin
      case TPOComment(Entry.FComments[i]).CommentType of
        poctTranslator: Lines.Add(Prefix + '# ' + TPOComment(Entry.FComments[i]).Text);
        poctExtracted: Lines.Add(Prefix + '#. ' + TPOComment(Entry.FComments[i]).Text);
        poctReference: Lines.Add(Prefix + '#: ' + TPOComment(Entry.FComments[i]).Text);
        poctPrevious: Lines.Add(Prefix + '#| ' + TPOComment(Entry.FComments[i]).Text);
        poctFlag: Lines.Add(Prefix + '#, ' + TPOComment(Entry.FComments[i]).Text);
      end;
    end;
  end;

  // msgctxt
  if Entry.MsgCtxt <> '' then
    WriteFieldLines(Entry.RawMsgCtxt, Entry.MsgCtxt, Prefix + 'msgctxt ');

  // msgid
  WriteFieldLines(Entry.RawMsgId, Entry.MsgId, Prefix + 'msgid ');

  // msgid_plural
  if Entry.IsPlural then
    WriteFieldLines(Entry.RawMsgIdPlural, Entry.MsgIdPlural, Prefix + 'msgid_plural ');

  // msgstr
  if Entry.IsPlural then
  begin
    for i := 0 to Entry.MsgStrCount - 1 do
    begin
      rawMsg := Entry.GetRawMsgStr(i);
      if (rawMsg <> nil) and (rawMsg.Count > 0) then
        WriteFieldLines(rawMsg, Entry.MsgStr[i], Prefix + 'msgstr[' + IntToStr(i) + '] ')
      else
        WriteFieldLines(nil, Entry.MsgStr[i], Prefix + 'msgstr[' + IntToStr(i) + '] ');
    end;
    if Entry.MsgStrCount = 0 then
      Lines.Add(Prefix + 'msgstr[0] ""');
  end
  else
  begin
    rawMsg := Entry.GetRawMsgStr(0);
    if (rawMsg <> nil) and (rawMsg.Count > 0) then
      WriteFieldLines(rawMsg, Entry.MsgStrSimple, Prefix + 'msgstr ')
    else
      WriteFieldLines(nil, Entry.MsgStrSimple, Prefix + 'msgstr ');
  end;
end;

procedure TPOFile.SaveToStream(AStream: TStream);
var
  sl: TStringList;
  i: integer;
begin
  sl := TStringList.Create;
  try
    for i := 0 to FEntries.Count - 1 do
    begin
      WriteEntry(TPOEntry(FEntries[i]), sl);
      if i < FEntries.Count - 1 then
        sl.Add('');
    end;
    sl.SaveToStream(AStream, FEncoding);
  finally
    sl.Free;
  end;
end;

procedure TPOFile.SaveToFile(const AFilename: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToStream(FS);
  finally
    FS.Free;
  end;
end;

function TPOFile.FindEntry(const AMsgCtxt, AMsgId: string): TPOEntry;
var
  i: integer;
begin
  for i := 0 to FEntries.Count - 1 do
    if (TPOEntry(FEntries[i]).MsgId = AMsgId) and (TPOEntry(FEntries[i]).MsgCtxt = AMsgCtxt) then
      Exit(TPOEntry(FEntries[i]));
  Result := nil;
end;

end.
