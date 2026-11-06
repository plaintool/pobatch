//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit PoTM;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  SysUtils,
  LazUTF8,
  OsUtils,
  PoWrap,
  StringHashList;

type
  // Summary of a single PO import operation
  TTMImportResult = record
    Imported: integer;          // new entries added to the memory
    Skipped: integer;           // entries filtered out or already present
    EmptyTranslation: integer;  // entries without a translation
  end;

  // In-memory translation memory entry
  TTMEntry = record
    MsgCtxt: string;
    MsgId: string;
    MsgStr: string;
    ContextWords: TStringArray;  // lowercase words parsed from MsgCtxt
  end;
  PTMEntry = ^TTMEntry;

  TPoTranslationMemory = class
  private
    FDirectory: string;
    FSourceLang: string;
    FTargetLang: string;
    FMaxSourceLength: integer;
    FSkipMultiline: boolean;
    FContextSensitive: boolean;
    FEntries: TStringHashList;   // ctx #1 msgid -> PTMEntry
    FByMsgId: TStringHashList;   // msgid -> TList of PTMEntry
    FByContext: TStringHashList; // exact context -> TList of PTMEntry
    FEnabled: boolean;           // master switch; when False, no reads or writes
    FDirty: boolean;

    function GetCount: integer;
    function GetFileName: string;
    function GetArchiveEntryName: string;
    function MakeKey(const AMsgCtxt, AMsgId: string): string;
    function ExtractFirstLine(const S: string): string;
    function IsRelevant(const AMsgCtxt, AMsgId: string; AIsPlural: boolean): boolean;
    function EscapeField(const S: string): string;
    function UnescapeField(const S: string): string;
    function EnsureDirectory: boolean;
    function SplitWords(const S: string): TStringArray;
    function CountMatchingWords(const AQuery, AEntry: TStringArray): integer;
    procedure IndexByMsgId(const AMsgId: string; AEntry: PTMEntry);
    procedure IndexByContext(const ACtx: string; AEntry: PTMEntry);
    function GetMsgIdList(const AMsgId: string): TList;
    procedure LoadFromStrings(ALines: TStrings);
    procedure SaveToStrings(ALines: TStringList);
    procedure ClearEntries;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load;
    procedure Save;
    procedure Clear;

    function Lookup(const AMsgCtxt, AMsgId, AReference: string; out AMsgStr: string): boolean;
    function Store(const AMsgCtxt, AMsgId, AMsgStr: string; AReference: string = ''): boolean;
    function ImportFromPoFile(const AFileName: string; out AResult: TTMImportResult; out AError: string): boolean;
    procedure ImportFromPoObject(APoFile: TPoFile; out AResult: TTMImportResult);
    procedure ImportFromStrings(ALines: TStrings);
    procedure Compact;

    property Directory: string read FDirectory write FDirectory;
    property SourceLang: string read FSourceLang write FSourceLang;
    property TargetLang: string read FTargetLang write FTargetLang;
    property MaxSourceLength: integer read FMaxSourceLength write FMaxSourceLength;
    property SkipMultiline: boolean read FSkipMultiline write FSkipMultiline;
    property ContextSensitive: boolean read FContextSensitive write FContextSensitive;
    property Enabled: boolean read FEnabled write FEnabled;
    property Count: integer read GetCount;
    property Dirty: boolean read FDirty;
  end;

implementation

const
  FIELD_SEP = #9;  // Tab between fields in the on-disk file
  KEY_SEP = #1;    // SOH between msgctxt and msgid in the lookup key
  // Separators used to split a context string into words for fuzzy matching
  WORD_SEPARATORS = ['.', '_', '/', '\', ':', '#', '-', ' '];

constructor TPoTranslationMemory.Create;
begin
  inherited Create;
  FEntries := TStringHashList.Create(True);
  FByMsgId := TStringHashList.Create(True);
  FByContext := TStringHashList.Create(True);
  FMaxSourceLength := 100;
  FSkipMultiline := True;
  FContextSensitive := True;
  FEnabled := True;
  FDirty := False;
end;

destructor TPoTranslationMemory.Destroy;
begin
  if FDirty then
  try
    Save;
  except
    // Ignore disk errors on shutdown
  end;
  ClearEntries;
  FEntries.Free;
  FByMsgId.Free;
  FByContext.Free;
  inherited Destroy;
end;

procedure TPoTranslationMemory.ClearEntries;
var
  I: integer;
begin
  // Free the auxiliary index lists before dropping the entries themselves
  for I := 0 to FByMsgId.Count - 1 do
    TList(FByMsgId.List[I]^.Data).Free;
  FByMsgId.Clear;

  for I := 0 to FByContext.Count - 1 do
    TList(FByContext.List[I]^.Data).Free;
  FByContext.Clear;

  for I := 0 to FEntries.Count - 1 do
    Dispose(PTMEntry(FEntries.List[I]^.Data));
  FEntries.Clear;
end;

function TPoTranslationMemory.GetCount: integer;
begin
  Result := FEntries.Count;
end;

function TPoTranslationMemory.GetFileName: string;
var
  Src, Tgt: string;
  I: integer;
  C: char;
begin
  Src := '';
  for I := 1 to Length(FSourceLang) do
  begin
    C := FSourceLang[I];
    if C in ['a'..'z', 'A'..'Z', '0'..'9', '_', '-'] then
      Src := Src + C;
  end;
  Tgt := '';
  for I := 1 to Length(FTargetLang) do
  begin
    C := FTargetLang[I];
    if C in ['a'..'z', 'A'..'Z', '0'..'9', '_', '-'] then
      Tgt := Tgt + C;
  end;
  if (Src = '') or (Tgt = '') then
    raise Exception.Create('TM: source and target languages must be set');
  Result := IncludeTrailingPathDelimiter(FDirectory) + Src + '-' + Tgt + '.zip';
end;

function TPoTranslationMemory.GetArchiveEntryName: string;
begin
  // The .txt file stored inside the zip keeps the language pair in its name
  // so the archive stays meaningful when opened in Explorer or an archiver
  Result := ChangeFileExt(ExtractFileName(GetFileName), '.txt');
end;

function TPoTranslationMemory.MakeKey(const AMsgCtxt, AMsgId: string): string;
begin
  // Empty context collapses to the plain msgid so that Store and Lookup
  // agree on a single key regardless of the ContextSensitive flag
  if (AMsgCtxt = '') or not FContextSensitive then
    Result := AMsgId
  else
    Result := AMsgCtxt + KEY_SEP + AMsgId;
end;

function TPoTranslationMemory.ExtractFirstLine(const S: string): string;
var
  P: integer;
begin
  P := Pos(#10, S);
  if P > 0 then
    Result := Copy(S, 1, P - 1)
  else
    Result := S;
  Result := Trim(Result);
end;

function TPoTranslationMemory.IsRelevant(const AMsgCtxt, AMsgId: string; AIsPlural: boolean): boolean;
begin
  if AMsgId = '' then
    Exit(False);
  if AIsPlural then
    Exit(False);
  if FSkipMultiline and (Pos(#10, AMsgId) > 0) then
    Exit(False);
  if (FMaxSourceLength > 0) and (UTF8Length(AMsgId) > FMaxSourceLength) then
    Exit(False);
  Result := True;
end;

function TPoTranslationMemory.EscapeField(const S: string): string;
var
  I: integer;
  C: char;
begin
  Result := '';
  for I := 1 to Length(S) do
  begin
    C := S[I];
    case C of
      '\': Result := Result + '\\';
      FIELD_SEP: Result := Result + '\t';
      #10: Result := Result + '\n';
      #13: Result := Result + '\r';
      else
        Result := Result + C;
    end;
  end;
end;

function TPoTranslationMemory.UnescapeField(const S: string): string;
var
  I, Len: integer;
  C: char;
begin
  Result := '';
  I := 1;
  Len := Length(S);
  while I <= Len do
  begin
    C := S[I];
    if (C = '\') and (I < Len) then
    begin
      Inc(I);
      case S[I] of
        '\': Result := Result + '\';
        't': Result := Result + FIELD_SEP;
        'n': Result := Result + #10;
        'r': Result := Result + #13;
        else
          Result := Result + '\' + S[I];
      end;
    end
    else
      Result := Result + C;
    Inc(I);
  end;
end;

function TPoTranslationMemory.EnsureDirectory: boolean;
begin
  Result := False;
  if FDirectory = '' then
    Exit;
  try
    Result := ForceDirectories(FDirectory);
  except
    Result := False;
  end;
end;

function TPoTranslationMemory.SplitWords(const S: string): TStringArray;
var
  I, Start, ACount, J: integer;
  word: string;
  IsDup: boolean;
begin
  Result := nil;
  if S = '' then
    Exit;
  ACount := 0;
  Start := 1;
  for I := 1 to Length(S) + 1 do
  begin
    if (I > Length(S)) or (S[I] in WORD_SEPARATORS) then
    begin
      if I > Start then
      begin
        word := LowerCase(Trim(Copy(S, Start, I - Start)));
        if word <> '' then
        begin
          // Skip duplicate words so each unique token counts once
          IsDup := False;
          for J := 0 to ACount - 1 do
            if Result[J] = word then
            begin
              IsDup := True;
              Break;
            end;
          if not IsDup then
          begin
            SetLength(Result, ACount + 1);
            Result[ACount] := word;
            Inc(ACount);
          end;
        end;
      end;
      Start := I + 1;
    end;
  end;
end;

function TPoTranslationMemory.CountMatchingWords(const AQuery, AEntry: TStringArray): integer;
var
  I, J: integer;
begin
  Result := 0;
  for I := 0 to High(AQuery) do
    for J := 0 to High(AEntry) do
      if AQuery[I] = AEntry[J] then
      begin
        Inc(Result);
        Break;
      end;
end;

procedure TPoTranslationMemory.IndexByMsgId(const AMsgId: string; AEntry: PTMEntry);
var
  Idx: integer;
  List: TList;
begin
  Idx := FByMsgId.Find(AMsgId);
  if Idx >= 0 then
    List := TList(FByMsgId.List[Idx]^.Data)
  else
  begin
    List := TList.Create;
    FByMsgId.Add(AMsgId, List);
  end;
  List.Add(AEntry);
end;

procedure TPoTranslationMemory.IndexByContext(const ACtx: string; AEntry: PTMEntry);
var
  Idx: integer;
  List: TList;
begin
  if ACtx = '' then
    Exit;
  Idx := FByContext.Find(ACtx);
  if Idx >= 0 then
    List := TList(FByContext.List[Idx]^.Data)
  else
  begin
    List := TList.Create;
    FByContext.Add(ACtx, List);
  end;
  List.Add(AEntry);
end;

function TPoTranslationMemory.GetMsgIdList(const AMsgId: string): TList;
var
  Idx: integer;
begin
  Result := nil;
  Idx := FByMsgId.Find(AMsgId);
  if Idx >= 0 then
    Result := TList(FByMsgId.List[Idx]^.Data);
end;

procedure TPoTranslationMemory.LoadFromStrings(ALines: TStrings);
var
  I, P1, P2: integer;
  Line, RawCtxt, RawId, RawStr, Key: string;
  Entry: PTMEntry;
begin
  ClearEntries;
  for I := 0 to ALines.Count - 1 do
  begin
    Line := ALines[I];
    if Line = '' then
      Continue;

    P1 := Pos(FIELD_SEP, Line);
    if P1 = 0 then
      Continue;
    P2 := Pos(FIELD_SEP, Line, P1 + 1);
    if P2 = 0 then
      Continue;

    RawCtxt := UnescapeField(Copy(Line, 1, P1 - 1));
    RawId := UnescapeField(Copy(Line, P1 + 1, P2 - P1 - 1));
    RawStr := UnescapeField(Copy(Line, P2 + 1, MaxInt));

    if RawId = '' then
      Continue;

    Key := MakeKey(RawCtxt, RawId);
    if FEntries.Find(Key) >= 0 then
      Continue;  // skip duplicates

    New(Entry);
    Entry^.MsgCtxt := RawCtxt;
    Entry^.MsgId := RawId;
    Entry^.MsgStr := RawStr;
    Entry^.ContextWords := SplitWords(RawCtxt);
    FEntries.Add(Key, Entry);
    IndexByMsgId(RawId, Entry);
    IndexByContext(RawCtxt, Entry);
  end;
end;

procedure TPoTranslationMemory.SaveToStrings(ALines: TStringList);
var
  I: integer;
  Entry: PTMEntry;
begin
  ALines.Clear;
  for I := 0 to FEntries.Count - 1 do
  begin
    Entry := PTMEntry(FEntries.List[I]^.Data);
    ALines.Add(EscapeField(Entry^.MsgCtxt) + FIELD_SEP + EscapeField(Entry^.MsgId) + FIELD_SEP + EscapeField(Entry^.MsgStr));
  end;
  ALines.CaseSensitive := True;
  ALines.Sort;
end;

procedure TPoTranslationMemory.Load;
var
  FileName, LegacyTxt, ArcName: string;
  Stream: TMemoryStream;
  Lines: TStringList;
begin
  ClearEntries;
  FDirty := False;
  if (FDirectory = '') or (FSourceLang = '') or (FTargetLang = '') then
    Exit;
  FileName := GetFileName;

  // Primary format: zip archive
  if FileExists(FileName) then
  begin
    ArcName := GetArchiveEntryName;
    Stream := nil;
    try
      if TOS.UnZipFileToStream(FileName, ArcName, Stream) then
      begin
        Lines := TStringList.Create;
        try
          Lines.LoadFromStream(Stream, TEncoding.UTF8);
          LoadFromStrings(Lines);
        finally
          Lines.Free;
        end;
      end;
    finally
      Stream.Free;
    end;
    Exit;
  end;

  // Legacy fallback: read the old plain-text file when the zip is absent
  LegacyTxt := ChangeFileExt(FileName, '.txt');
  if FileExists(LegacyTxt) then
  begin
    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(LegacyTxt, TEncoding.UTF8);
      LoadFromStrings(Lines);
    finally
      Lines.Free;
    end;
  end;
end;

procedure TPoTranslationMemory.Save;
var
  FileName, ArcName, TmpZip: string;
  Lines: TStringList;
  Stream: TMemoryStream;
begin
  if (FDirectory = '') or (FSourceLang = '') or (FTargetLang = '') then
    Exit;
  if not EnsureDirectory then
    raise Exception.CreateFmt('TM: cannot create directory %s', [FDirectory]);
  FileName := GetFileName;
  ArcName := GetArchiveEntryName;

  // Serialize the memory into an in-memory text stream first
  Lines := TStringList.Create;
  try
    SaveToStrings(Lines);
    Stream := TMemoryStream.Create;
    try
      Lines.SaveToStream(Stream, TEncoding.UTF8);
      Stream.Position := 0;

      // Pack the text stream into a temporary zip, then replace the target
      TmpZip := FileName + '.tmp';
      try
        if not TOS.ZipStreamToFile(Stream, TmpZip, ArcName) then
          raise Exception.CreateFmt('TM: cannot create archive %s', [TmpZip]);

        // Atomic replace: POSIX overwrites, Windows needs the target removed first
        if not RenameFile(TmpZip, FileName) then
        begin
          DeleteFile(FileName);
          if not RenameFile(TmpZip, FileName) then
            raise Exception.CreateFmt('TM: cannot write %s', [FileName]);
        end;
      finally
        DeleteFile(TmpZip);
      end;
    finally
      Stream.Free;
    end;
  finally
    Lines.Free;
  end;
  FDirty := False;
end;

procedure TPoTranslationMemory.Clear;
begin
  if FEntries.Count = 0 then
    Exit;
  ClearEntries;
  FDirty := True;
end;

function TPoTranslationMemory.Lookup(const AMsgCtxt, AMsgId, AReference: string; out AMsgStr: string): boolean;
var
  Ctx, RefCtx, Key: string;
  Idx, I, Score, BestScore: integer;
  List: TList;
  Entry, BestEntry: PTMEntry;
  QueryWords: TStringArray;
begin
  Result := False;
  AMsgStr := '';
  if not FEnabled then
    Exit;
  if not IsRelevant(AMsgCtxt, AMsgId, False) then
    Exit;

  // Context-insensitive mode keeps a single entry per msgid
  if not FContextSensitive then
  begin
    Idx := FEntries.Find(AMsgId);
    if Idx >= 0 then
    begin
      Entry := PTMEntry(FEntries.List[Idx]^.Data);
      AMsgStr := Entry^.MsgStr;
      Result := True;
    end;
    Exit;
  end;

  // 1. Exact context match on msgctxt
  if AMsgCtxt <> '' then
  begin
    Key := AMsgCtxt + KEY_SEP + AMsgId;
    Idx := FEntries.Find(Key);
    if Idx >= 0 then
    begin
      Entry := PTMEntry(FEntries.List[Idx]^.Data);
      AMsgStr := Entry^.MsgStr;
      Exit(True);
    end;
  end;

  // 2. Exact context match on the first reference line
  RefCtx := ExtractFirstLine(AReference);
  if (RefCtx <> '') and (RefCtx <> AMsgCtxt) then
  begin
    Key := RefCtx + KEY_SEP + AMsgId;
    Idx := FEntries.Find(Key);
    if Idx >= 0 then
    begin
      Entry := PTMEntry(FEntries.List[Idx]^.Data);
      AMsgStr := Entry^.MsgStr;
      Exit(True);
    end;
  end;

  // 3. Word-based context match: pick the entry sharing the most words
  Ctx := AMsgCtxt;
  if Ctx = '' then
    Ctx := RefCtx;
  if Ctx <> '' then
  begin
    List := GetMsgIdList(AMsgId);
    if Assigned(List) then
    begin
      QueryWords := SplitWords(Ctx);
      if Length(QueryWords) > 0 then
      begin
        BestScore := 0;
        BestEntry := nil;
        for I := 0 to List.Count - 1 do
        begin
          Entry := PTMEntry(List[I]);
          Score := CountMatchingWords(QueryWords, Entry^.ContextWords);
          if Score > BestScore then
          begin
            BestScore := Score;
            BestEntry := Entry;
          end;
        end;
        if BestScore > 0 then
        begin
          AMsgStr := BestEntry^.MsgStr;
          Exit(True);
        end;
      end;
    end;
  end;

  // 4. Exact context match with a different msgid. The msgid text may have
  // been reworded between releases while the UI element stayed the same,
  // so the previously stored translation is still a useful starting point
  if Ctx <> '' then
  begin
    Idx := FByContext.Find(Ctx);
    if Idx >= 0 then
    begin
      List := TList(FByContext.List[Idx]^.Data);
      if List.Count > 0 then
      begin
        Entry := PTMEntry(List[0]);
        AMsgStr := Entry^.MsgStr;
        Exit(True);
      end;
    end;
  end;

  // 5. Fallback: any entry with the same msgid
  List := GetMsgIdList(AMsgId);
  if Assigned(List) and (List.Count > 0) then
  begin
    // A query without context should prefer a stored entry without context
    BestEntry := nil;
    if (AMsgCtxt = '') and (RefCtx = '') then
    begin
      for I := 0 to List.Count - 1 do
      begin
        Entry := PTMEntry(List[I]);
        if Length(Entry^.ContextWords) = 0 then
        begin
          BestEntry := Entry;
          Break;
        end;
      end;
    end;
    if BestEntry = nil then
      BestEntry := PTMEntry(List[0]);
    AMsgStr := BestEntry^.MsgStr;
    Exit(True);
  end;
end;

function TPoTranslationMemory.Store(const AMsgCtxt, AMsgId, AMsgStr: string; AReference: string = ''): boolean;
var
  Key, Ctx: string;
  Entry: PTMEntry;
begin
  Result := False;
  if not FEnabled then
    Exit;
  if not IsRelevant(AMsgCtxt, AMsgId, False) then
    Exit;
  if AMsgStr = '' then
    Exit;

  // Determine the effective context: msgctxt wins, then reference, then empty
  Ctx := '';
  if FContextSensitive then
  begin
    if AMsgCtxt <> '' then
      Ctx := AMsgCtxt
    else
      Ctx := ExtractFirstLine(AReference);
  end;

  Key := MakeKey(Ctx, AMsgId);
  if FEntries.Find(Key) >= 0 then
    Exit; // Keep the existing translation on duplicate

  New(Entry);
  Entry^.MsgCtxt := Ctx;
  Entry^.MsgId := AMsgId;
  Entry^.MsgStr := AMsgStr;
  Entry^.ContextWords := SplitWords(Ctx);
  FEntries.Add(Key, Entry);
  IndexByMsgId(AMsgId, Entry);
  IndexByContext(Ctx, Entry);
  FDirty := True;
  Result := True;
end;

procedure TPoTranslationMemory.ImportFromPoObject(APoFile: TPoFile; out AResult: TTMImportResult);
var
  I: integer;
  Entry: TPOEntry;
  FileSrcLang, FileTgtLang, MsgStr: string;
begin
  AResult.Imported := 0;
  AResult.Skipped := 0;
  AResult.EmptyTranslation := 0;
  if not FEnabled then
    Exit;
  if not Assigned(APoFile) then
    Exit;

  FileTgtLang := Trim(APoFile.HeaderValue['Language']);
  FileSrcLang := Trim(APoFile.HeaderValue['X-Source-Language']);
  if FileSrcLang = '' then
    FileSrcLang := 'en';
  if not SameText(FileTgtLang, FTargetLang) then
    Exit;
  if not SameText(FileSrcLang, FSourceLang) then
    Exit;

  for I := 0 to APoFile.Entries.Count - 1 do
  begin
    Entry := APoFile.Entries[I];
    if Entry.MsgId = '' then
      Continue;
    if Entry.Obsolete then
    begin
      Inc(AResult.Skipped);
      Continue;
    end;
    if not IsRelevant(Entry.MsgCtxt, Entry.MsgId, Entry.IsPlural) then
    begin
      Inc(AResult.Skipped);
      Continue;
    end;
    // Fuzzy entries are unvalidated drafts, so they never enter the memory
    if Entry.IsFuzzy then
    begin
      Inc(AResult.Skipped);
      Continue;
    end;
    MsgStr := Entry.MsgStrSimple;
    if MsgStr = '' then
    begin
      Inc(AResult.EmptyTranslation);
      Continue;
    end;
    if Store(Entry.MsgCtxt, Entry.MsgId, MsgStr, Entry.Reference) then
      Inc(AResult.Imported)
    else
      Inc(AResult.Skipped);
  end;
end;

function TPoTranslationMemory.ImportFromPoFile(const AFileName: string; out AResult: TTMImportResult; out AError: string): boolean;
var
  PoFile: TPoFile;
  FileSrcLang, FileTgtLang: string;
begin
  Result := False;
  AError := '';
  AResult.Imported := 0;
  AResult.Skipped := 0;
  AResult.EmptyTranslation := 0;

  if not FileExists(AFileName) then
  begin
    AError := Format('File not found: %s', [AFileName]);
    Exit;
  end;

  PoFile := TPoFile.Create;
  try
    try
      PoFile.LoadFromFile(AFileName);
    except
      on E: Exception do
      begin
        AError := Format('Cannot load PO file: %s', [E.Message]);
        Exit;
      end;
    end;

    FileTgtLang := Trim(PoFile.HeaderValue['Language']);
    FileSrcLang := Trim(PoFile.HeaderValue['X-Source-Language']);
    if FileSrcLang = '' then
      FileSrcLang := 'en';
    if not SameText(FileTgtLang, FTargetLang) then
    begin
      AError := Format('Target language mismatch: file is "%s", expected "%s"', [FileTgtLang, FTargetLang]);
      Exit;
    end;
    if not SameText(FileSrcLang, FSourceLang) then
    begin
      AError := Format('Source language mismatch: file is "%s", expected "%s"', [FileSrcLang, FSourceLang]);
      Exit;
    end;

    ImportFromPoObject(PoFile, AResult);
    Result := True;
  finally
    PoFile.Free;
  end;
end;

procedure TPoTranslationMemory.ImportFromStrings(ALines: TStrings);
var
  I, P1, P2: integer;
  Line, RawCtxt, RawId, RawStr, Key, Ctx: string;
  Entry: PTMEntry;
begin
  // Merge lines from a plain-text TM file into the current memory.
  // Duplicates are skipped; the Enabled and filter settings are bypassed
  // because the caller explicitly requested the import
  for I := 0 to ALines.Count - 1 do
  begin
    Line := ALines[I];
    if Line = '' then
      Continue;
    P1 := Pos(FIELD_SEP, Line);
    if P1 = 0 then
      Continue;
    P2 := Pos(FIELD_SEP, Line, P1 + 1);
    if P2 = 0 then
      Continue;
    RawCtxt := UnescapeField(Copy(Line, 1, P1 - 1));
    RawId := UnescapeField(Copy(Line, P1 + 1, P2 - P1 - 1));
    RawStr := UnescapeField(Copy(Line, P2 + 1, MaxInt));
    if (RawId = '') or (RawStr = '') then
      Continue;

    if FContextSensitive then
      Ctx := RawCtxt
    else
      Ctx := '';

    if Ctx = '' then
      Key := RawId
    else
      Key := Ctx + KEY_SEP + RawId;

    if FEntries.Find(Key) >= 0 then
      Continue;

    New(Entry);
    Entry^.MsgCtxt := Ctx;
    Entry^.MsgId := RawId;
    Entry^.MsgStr := RawStr;
    Entry^.ContextWords := SplitWords(Ctx);
    FEntries.Add(Key, Entry);
    IndexByMsgId(RawId, Entry);
    IndexByContext(Ctx, Entry);
  end;
  FDirty := True;
end;

procedure TPoTranslationMemory.Compact;
var
  NewEntries, NewByMsgId, NewByContext: TStringHashList;
  ToDelete: TList;
  I, Idx: integer;
  Entry: PTMEntry;
  Key: string;
  Kept: boolean;
  List: TList;
begin
  if FEntries.Count = 0 then
    Exit;

  NewEntries := TStringHashList.Create(True);
  NewByMsgId := TStringHashList.Create(True);
  NewByContext := TStringHashList.Create(True);
  ToDelete := TList.Create;
  try
    for I := 0 to FEntries.Count - 1 do
    begin
      Entry := PTMEntry(FEntries.List[I]^.Data);
      Kept := (Entry^.MsgId <> '') and (not FSkipMultiline or (Pos(#10, Entry^.MsgId) = 0)) and
        ((FMaxSourceLength = 0) or (UTF8Length(Entry^.MsgId) <= FMaxSourceLength));

      if Kept then
      begin
        if FContextSensitive and (Entry^.MsgCtxt <> '') then
          Key := Entry^.MsgCtxt + KEY_SEP + Entry^.MsgId
        else
          Key := Entry^.MsgId;

        if NewEntries.Find(Key) < 0 then
        begin
          NewEntries.Add(Key, Entry);
          Idx := NewByMsgId.Find(Entry^.MsgId);
          if Idx >= 0 then
            TList(NewByMsgId.List[Idx]^.Data).Add(Entry)
          else
          begin
            List := TList.Create;
            List.Add(Entry);
            NewByMsgId.Add(Entry^.MsgId, List);
          end;
          if Entry^.MsgCtxt <> '' then
          begin
            Idx := NewByContext.Find(Entry^.MsgCtxt);
            if Idx >= 0 then
              TList(NewByContext.List[Idx]^.Data).Add(Entry)
            else
            begin
              List := TList.Create;
              List.Add(Entry);
              NewByContext.Add(Entry^.MsgCtxt, List);
            end;
          end;
        end
        else
          ToDelete.Add(Entry);
      end
      else
        ToDelete.Add(Entry);
    end;

    // Dispose the entries that were filtered out or deduplicated
    for I := 0 to ToDelete.Count - 1 do
      Dispose(PTMEntry(ToDelete[I]));

    // Free the old containers and swap in the new ones
    for I := 0 to FByMsgId.Count - 1 do
      TList(FByMsgId.List[I]^.Data).Free;
    for I := 0 to FByContext.Count - 1 do
      TList(FByContext.List[I]^.Data).Free;
    FEntries.Free;
    FByMsgId.Free;
    FByContext.Free;

    FEntries := NewEntries;
    FByMsgId := NewByMsgId;
    FByContext := NewByContext;
    NewEntries := nil;
    NewByMsgId := nil;
    NewByContext := nil;

    FDirty := True;
  finally
    NewEntries.Free;
    NewByMsgId.Free;
    NewByContext.Free;
    ToDelete.Free;
  end;
end;

end.
