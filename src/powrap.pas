//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
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

  {%Region -fold Enums}

  TPOCommentType = (
    poctTranslator,   // #  (free comment by translator)
    poctExtracted,    // #. (extracted from source code by xgettext)
    poctReference,    // #: (source file and line reference)
    poctPrevious,     // #| (previous untranslated string, after msgmerge)
    poctFlag          // #, (flags like fuzzy, c-format, etc.)
    );

  TPOLineEndingStyle = (
    pleLF,    // Unix/Linux line ending   (LF -> \n)
    pleCRLF,  // Windows line ending      (CRLF -> \r\n)
    pleCR     // Classic Mac line ending  (CR -> \r)
    );

  // Known PO flags (without parameters)
  TPOFlag = (
    pofFuzzy,
    pofCFormat,
    pofNoWrap,
    pofPythonFormat,
    pofJavaFormat,
    pofQtFormat,
    pofBoostFormat,
    pofLispFormat,
    pofSchemeFormat,
    pofObjectiveCFormat,
    pofYcpFormat,
    pofTclFormat,
    pofPerlFormat,
    pofPhpFormat,
    pofGccInternalFormat,
    pofQtPluralFormat,
    pofCppFormat
    );
  TPOFlags = set of TPOFlag;

  TPOFileStatus = (
    psEmptyTranslation,  // No fuzzy, but at least one entry has an empty translation
    psCorrect,           // All translations present, no fuzzy
    psFuzzy              // At least one entry has the 'fuzzy' flag
    );

  TPOFileStatusArray = array of TPoFileStatus;

  TPOHeader = (
    hProjectIdVersion,
    hReportMsgidBugsTo,
    hPOTCreationDate,
    hPORevisionDate,
    hLastTranslator,
    hLanguageTeam,
    hLanguage,
    hMIMEVersion,
    hContentType,
    hContentTransferEncoding,
    hPluralForms,
    hXGenerator
    );

  {%EndRegion}

  TParseState = record
    Field: string;        // 'msgid', 'msgid_plural', 'msgctxt', 'msgstr', 'msgstrN'
    PluralIndex: integer;
    MultiBuffer: TStrings;
    ExpectContinuation: boolean; // true after empty "msgid" or "msgstr"
  end;

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

    // Internal helpers for flag comments
    function HasFlag(const AFlag: string): boolean;
    procedure AddFlag(const AFlag: string);
    procedure RemoveFlag(const AFlag: string);

    function GetFlagsSet: TPOFlags;
    procedure SetFlagsSet(AValue: TPOFlags);

    function GetRange: string;
    procedure SetRange(const AValue: string);

    // Boolean properties for each known flag
    function GetIsFuzzy: boolean;
    procedure SetIsFuzzy(AValue: boolean);
    function GetIsCFormat: boolean;
    procedure SetIsCFormat(AValue: boolean);
    function GetIsNoWrap: boolean;
    procedure SetIsNoWrap(AValue: boolean);
    function GetIsPythonFormat: boolean;
    procedure SetIsPythonFormat(AValue: boolean);
    function GetIsJavaFormat: boolean;
    procedure SetIsJavaFormat(AValue: boolean);
    function GetIsQtFormat: boolean;
    procedure SetIsQtFormat(AValue: boolean);
    function GetIsBoostFormat: boolean;
    procedure SetIsBoostFormat(AValue: boolean);
    function GetIsLispFormat: boolean;
    procedure SetIsLispFormat(AValue: boolean);
    function GetIsSchemeFormat: boolean;
    procedure SetIsSchemeFormat(AValue: boolean);
    function GetIsObjectiveCFormat: boolean;
    procedure SetIsObjectiveCFormat(AValue: boolean);
    function GetIsYcpFormat: boolean;
    procedure SetIsYcpFormat(AValue: boolean);
    function GetIsTclFormat: boolean;
    procedure SetIsTclFormat(AValue: boolean);
    function GetIsPerlFormat: boolean;
    procedure SetIsPerlFormat(AValue: boolean);
    function GetIsPhpFormat: boolean;
    procedure SetIsPhpFormat(AValue: boolean);
    function GetIsGccInternalFormat: boolean;
    procedure SetIsGccInternalFormat(AValue: boolean);
    function GetIsQtPluralFormat: boolean;
    procedure SetIsQtPluralFormat(AValue: boolean);
    function GetIsCppFormat: boolean;
    procedure SetIsCppFormat(AValue: boolean);

    function GetExtractedComment: string;
    procedure SetExtractedComment(const AValue: string);
    function GetReference: string;
    procedure SetReference(const AValue: string);
    function GetPreviousComment: string;
    procedure SetPreviousComment(const AValue: string);

    function GetMsgStr(Index: integer): string;
    procedure SetMsgStr(Index: integer; const Value: string);
    function GetMsgStrCount: integer;
    function GetFlagsString: string;
    procedure SetFlagsString(const AValue: string);
    function GetMsgStrSimple: string;
    procedure SetMsgStrSimple(const AValue: string);
    function GetIsPlural: boolean;

    function GetMsgStrList: TStrings;
    procedure SetMsgStrList(AValue: TStrings);
    function GetCommentsStr: TStrings;
    procedure SetCommentsStr(AValue: TStrings);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;

    procedure Assign(Source: TPOEntry);

    function GetCommentsAsStrings: TStrings;
    procedure LoadCommentsFromStrings(const Lines: TStrings);

    procedure AddComment(AType: TPOCommentType; const AText: string);
    procedure DeleteCommentsOfType(AType: TPOCommentType);
    function GetCommentsOfType(AType: TPOCommentType): TStrings;

    // Render entry to PO string (without trailing newline)
    function ToString(ALineEndingStyle: TPOLineEndingStyle): string; overload;
    function ToString: string; overload; override;   // uses pleLF by default

    // Check valid po
    function IsValid: boolean;

    property Flags: string read GetFlagsString write SetFlagsString;
    property MsgStrSimple: string read GetMsgStrSimple write SetMsgStrSimple;
    property MsgStr[Index: integer]: string read GetMsgStr write SetMsgStr;
    property MsgStrCount: integer read GetMsgStrCount;

    // Direct TStrings access to all msgstr translations (index 0 = singular/ordinary)
    property MsgStrList: TStrings read GetMsgStrList write SetMsgStrList;

    // Key=Value list of comments: Key is 'translator','extracted','reference','previous','flag'
    property CommentsStr: TStrings read GetCommentsStr write SetCommentsStr;

    property MsgCtxt: string read FMsgCtxt write FMsgCtxt;
    property MsgId: string read FMsgId write FMsgId;
    property MsgIdPlural: string read FMsgIdPlural write FMsgIdPlural;
    property IsPlural: boolean read GetIsPlural;
    property Obsolete: boolean read FObsolete write FObsolete;

    property Comments: TPOCommentList read FComments;

    // Properties for convenient flag manipulation
    property FlagsSet: TPOFlags read GetFlagsSet write SetFlagsSet;
    property Range: string read GetRange write SetRange;

    property IsFuzzy: boolean read GetIsFuzzy write SetIsFuzzy;
    property IsCFormat: boolean read GetIsCFormat write SetIsCFormat;
    property IsNoWrap: boolean read GetIsNoWrap write SetIsNoWrap;
    property IsPythonFormat: boolean read GetIsPythonFormat write SetIsPythonFormat;
    property IsJavaFormat: boolean read GetIsJavaFormat write SetIsJavaFormat;
    property IsQtFormat: boolean read GetIsQtFormat write SetIsQtFormat;
    property IsBoostFormat: boolean read GetIsBoostFormat write SetIsBoostFormat;
    property IsLispFormat: boolean read GetIsLispFormat write SetIsLispFormat;
    property IsSchemeFormat: boolean read GetIsSchemeFormat write SetIsSchemeFormat;
    property IsObjectiveCFormat: boolean read GetIsObjectiveCFormat write SetIsObjectiveCFormat;
    property IsYcpFormat: boolean read GetIsYcpFormat write SetIsYcpFormat;
    property IsTclFormat: boolean read GetIsTclFormat write SetIsTclFormat;
    property IsPerlFormat: boolean read GetIsPerlFormat write SetIsPerlFormat;
    property IsPhpFormat: boolean read GetIsPhpFormat write SetIsPhpFormat;
    property IsGccInternalFormat: boolean read GetIsGccInternalFormat write SetIsGccInternalFormat;
    property IsQtPluralFormat: boolean read GetIsQtPluralFormat write SetIsQtPluralFormat;
    property IsCppFormat: boolean read GetIsCppFormat write SetIsCppFormat;

    // String properties for standard comment types
    property ExtractedComment: string read GetExtractedComment write SetExtractedComment;
    property Reference: string read GetReference write SetReference;
    property PreviousComment: string read GetPreviousComment write SetPreviousComment;
  end;

  TPOEntryList = class(TObjectList)
  private
    function GetItem(Index: integer): TPOEntry;
    procedure SetItem(Index: integer; const Value: TPOEntry);
  public
    property Items[Index: integer]: TPOEntry read GetItem write SetItem; default;
    function Add(Entry: TPOEntry): integer;
  end;

  TPOFile = class
  private
    FEntries: TPOEntryList;
    FEncoding: TEncoding;
    FLineEndingStyle: TPOLineEndingStyle;
    FTrailingEmptyLines: integer;   // Number of empty lines at the end of the file
    procedure ParseLine(const Line: string; var CurrentEntry: TPOEntry; var PendingState: TParseState);
    function GetHeaders: TStrings;
    procedure SetHeaders(AHeaders: TStrings);
    function GetHeaderValue(const AKey: string): string;
    procedure SetHeaderValue(const AKey, AValue: string);
    function GetTranslations: TStrings;
    procedure SetTranslations(AList: TStrings);
    function GetPluralFormsCount: integer;
    function GetPluralFormsExpression: string;
    // Internal helper: normalise line endings and split into escaped PO quoted lines
    procedure AddFieldToStrings(Lines: TStrings; const Prefix, FieldKeyword: string; const Value: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Source: TPOFile);
    constructor CreateCopy(ASource: TPOFile);

    procedure LoadFromStream(AStream: TStream);
    procedure LoadFromFile(const AFilename: string);
    procedure SaveToStream(AStream: TStream);
    procedure SaveToFile(const AFilename: string);

    procedure Clear;
    procedure Reset;
    function FindEntry(const AMsgCtxt, AMsgId: string): TPOEntry; overload;
    function FindEntry(const AMsgId: string): TPOEntry; overload;
    procedure DeleteEntriesByIndexes(const AIndexes: array of integer);
    procedure WriteEntry(Entry: TPOEntry; Lines: TStrings);

    property Entries: TPOEntryList read FEntries;
    property Encoding: TEncoding read FEncoding write FEncoding;
    property LineEndingStyle: TPOLineEndingStyle read FLineEndingStyle write FLineEndingStyle;
    property Headers: TStrings read GetHeaders write SetHeaders;
    property HeaderValue[const AKey: string]: string read GetHeaderValue write SetHeaderValue;
    property Translations: TStrings read GetTranslations write SetTranslations;
    property TrailingEmptyLines: integer read FTrailingEmptyLines write FTrailingEmptyLines;

    // Plural forms information from the 'Plural-Forms' header
    property PluralFormsCount: integer read GetPluralFormsCount;
    property PluralFormsExpression: string read GetPluralFormsExpression;

    class function GetFileStatus(const AFileName: string): TPoFileStatus; static;
    class function GetCommentTypeName(const APrefix: string): string; static;
    class function GetHeaderNames: TStringList;
  end;

implementation

{%Region -fold Consts}

const
  // Mapping from TPOFlag to the string used in #, comments
  POFlagNames: array[TPOFlag] of string = (
    'fuzzy',
    'c-format',
    'no-wrap',
    'python-format',
    'java-format',
    'qt-format',
    'boost-format',
    'lisp-format',
    'scheme-format',
    'objective-c-format',
    'ycp-format',
    'tcl-format',
    'perl-format',
    'php-format',
    'gcc-internal-format',
    'qt-plural-format',
    'c++-format'
    );

  POHeaderNames: array[TPOHeader] of string = (
    'Project-Id-Version',
    'Report-Msgid-Bugs-To',
    'POT-Creation-Date',
    'PO-Revision-Date',
    'Last-Translator',
    'Language-Team',
    'Language',
    'MIME-Version',
    'Content-Type',
    'Content-Transfer-Encoding',
    'Plural-Forms',
    'X-Generator'
    );

  {%EndRegion}

{%Region -fold Plain utility functions}

function EscapeString(const S: string): string;
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

function UnescapeString(const S: string): string;
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

function CompareIndexStringsDesc(List: TStringList; Index1, Index2: integer): integer;
begin
  // Sort as numbers in descending order
  Result := StrToIntDef(List[Index2], 0) - StrToIntDef(List[Index1], 0);
end;

{%EndRegion}

{%Region -fold TPOComment}

constructor TPOComment.Create(AType: TPOCommentType; const AText: string);
begin
  inherited Create;
  CommentType := AType;
  Text := AText;
end;

{%EndRegion}

{%Region -fold TPOCommentList}

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

{%EndRegion}

{%Region -fold TPOEntry}

constructor TPOEntry.Create;
begin
  inherited;
  FComments := TPOCommentList.Create(True);
  FMsgStr := TStringList.Create;
end;

destructor TPOEntry.Destroy;
begin
  FComments.Free;
  FMsgStr.Free;
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
end;

procedure TPOEntry.Assign(Source: TPOEntry);
var
  i: integer;
  c: TPOComment;
begin
  // Copy simple fields
  FMsgCtxt := Source.FMsgCtxt;
  FMsgId := Source.FMsgId;
  FMsgIdPlural := Source.FMsgIdPlural;
  FObsolete := Source.FObsolete;

  // Deep copy comment objects
  FComments.Clear;
  for i := 0 to Source.FComments.Count - 1 do
  begin
    c := TPOComment(Source.FComments[i]);
    FComments.Add(TPOComment.Create(c.CommentType, c.Text));
  end;

  // StringList can copy itself
  FMsgStr.Assign(Source.FMsgStr);
end;

function TPOEntry.GetCommentsAsStrings: TStrings;
var
  i: integer;
  c: TPOComment;
  FlagList: TStringList;
  s: string;
begin
  Result := TStringList.Create;
  FlagList := TStringList.Create;
  try
    for i := 0 to FComments.Count - 1 do
    begin
      c := TPOComment(FComments[i]);
      case c.CommentType of
        poctTranslator: Result.Add('# ' + c.Text);
        poctExtracted: Result.Add('#. ' + c.Text);
        poctReference: Result.Add('#: ' + c.Text);
        poctPrevious: Result.Add('#| ' + c.Text);
        poctFlag: FlagList.Add(c.Text);
      end;
    end;
    if FlagList.Count > 0 then
    begin
      s := '';
      for i := 0 to FlagList.Count - 1 do
      begin
        if i > 0 then
          s := s + ', ';
        s := s + FlagList[i];
      end;
      Result.Add('#, ' + s);
    end;
  finally
    FlagList.Free;
  end;
end;

procedure TPOEntry.LoadCommentsFromStrings(const Lines: TStrings);
var
  s: string;
  tmp: string;
  sl: TStringList;
  i: integer;
begin
  FComments.Clear;
  sl := TStringList.Create;
  try
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
      begin
        // Split flag list by comma
        tmp := Trim(Copy(s, 3, MaxInt));
        sl.Clear;
        sl.CommaText := tmp;
        for i := 0 to sl.Count - 1 do
          if Trim(sl[i]) <> '' then
            AddComment(poctFlag, Trim(sl[i]));
      end
      else if (Length(s) >= 2) and (s[2] = '~') then
        Continue
      else if s[1] = '#' then
        AddComment(poctTranslator, Trim(Copy(s, 2, MaxInt)));
    end;
  finally
    sl.Free;
  end;
end;

procedure TPOEntry.AddComment(AType: TPOCommentType; const AText: string);
begin
  FComments.Add(TPOComment.Create(AType, AText));
end;

procedure TPOEntry.DeleteCommentsOfType(AType: TPOCommentType);
var
  i: integer;
begin
  for i := FComments.Count - 1 downto 0 do
    if TPOComment(FComments[i]).CommentType = AType then
      FComments.Delete(i);
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

{Flag helper methods}

function TPOEntry.HasFlag(const AFlag: string): boolean;
var
  i: integer;
begin
  if Assigned(FComments) then
    for i := 0 to FComments.Count - 1 do
      if (TPOComment(FComments[i]).CommentType = poctFlag) and (SameText(Trim(TPOComment(FComments[i]).Text), AFlag)) then
        Exit(True);
  Result := False;
end;

procedure TPOEntry.AddFlag(const AFlag: string);
begin
  if not HasFlag(AFlag) then
    AddComment(poctFlag, AFlag);
end;

procedure TPOEntry.RemoveFlag(const AFlag: string);
var
  i: integer;
begin
  for i := FComments.Count - 1 downto 0 do
    if (TPOComment(FComments[i]).CommentType = poctFlag) and (SameText(Trim(TPOComment(FComments[i]).Text), AFlag)) then
      FComments.Delete(i);
end;

{Flags set TPOFlags}

function TPOEntry.GetFlagsSet: TPOFlags;
var
  f: TPOFlag;
begin
  Result := [];
  for f := Low(TPOFlag) to High(TPOFlag) do
    if HasFlag(POFlagNames[f]) then
      Include(Result, f);
end;

procedure TPOEntry.SetFlagsSet(AValue: TPOFlags);
var
  f: TPOFlag;
begin
  // Remove all known flags first
  for f := Low(TPOFlag) to High(TPOFlag) do
    RemoveFlag(POFlagNames[f]);
  // Then add those that are in the new set
  for f := Low(TPOFlag) to High(TPOFlag) do
    if f in AValue then
      AddFlag(POFlagNames[f]);
end;

{ Range flag}

function TPOEntry.GetRange: string;
var
  i: integer;
  s: string;
begin
  for i := 0 to FComments.Count - 1 do
    if TPOComment(FComments[i]).CommentType = poctFlag then
    begin
      s := Trim(TPOComment(FComments[i]).Text);
      if Pos('range:', s) = 1 then
        Exit(Copy(s, 7, MaxInt));
    end;
  Result := '';
end;

procedure TPOEntry.SetRange(const AValue: string);
var
  i: integer;
begin
  // Remove any existing range comments
  for i := FComments.Count - 1 downto 0 do
    if (TPOComment(FComments[i]).CommentType = poctFlag) and (Pos('range:', Trim(TPOComment(FComments[i]).Text)) = 1) then
      FComments.Delete(i);
  // Add if not empty
  if AValue <> '' then
    AddComment(poctFlag, 'range:' + AValue);
end;

{ Boolean flag properties }

function TPOEntry.GetIsFuzzy: boolean;
begin
  Result := HasFlag('fuzzy');
end;

procedure TPOEntry.SetIsFuzzy(AValue: boolean);
begin
  if AValue then AddFlag('fuzzy')
  else
    RemoveFlag('fuzzy');
end;

function TPOEntry.GetIsCFormat: boolean;
begin
  Result := HasFlag('c-format');
end;

procedure TPOEntry.SetIsCFormat(AValue: boolean);
begin
  if AValue then AddFlag('c-format')
  else
    RemoveFlag('c-format');
end;

function TPOEntry.GetIsNoWrap: boolean;
begin
  Result := HasFlag('no-wrap');
end;

procedure TPOEntry.SetIsNoWrap(AValue: boolean);
begin
  if AValue then AddFlag('no-wrap')
  else
    RemoveFlag('no-wrap');
end;

function TPOEntry.GetIsPythonFormat: boolean;
begin
  Result := HasFlag('python-format');
end;

procedure TPOEntry.SetIsPythonFormat(AValue: boolean);
begin
  if AValue then AddFlag('python-format')
  else
    RemoveFlag('python-format');
end;

function TPOEntry.GetIsJavaFormat: boolean;
begin
  Result := HasFlag('java-format');
end;

procedure TPOEntry.SetIsJavaFormat(AValue: boolean);
begin
  if AValue then AddFlag('java-format')
  else
    RemoveFlag('java-format');
end;

function TPOEntry.GetIsQtFormat: boolean;
begin
  Result := HasFlag('qt-format');
end;

procedure TPOEntry.SetIsQtFormat(AValue: boolean);
begin
  if AValue then AddFlag('qt-format')
  else
    RemoveFlag('qt-format');
end;

function TPOEntry.GetIsBoostFormat: boolean;
begin
  Result := HasFlag('boost-format');
end;

procedure TPOEntry.SetIsBoostFormat(AValue: boolean);
begin
  if AValue then AddFlag('boost-format')
  else
    RemoveFlag('boost-format');
end;

function TPOEntry.GetIsLispFormat: boolean;
begin
  Result := HasFlag('lisp-format');
end;

procedure TPOEntry.SetIsLispFormat(AValue: boolean);
begin
  if AValue then AddFlag('lisp-format')
  else
    RemoveFlag('lisp-format');
end;

function TPOEntry.GetIsSchemeFormat: boolean;
begin
  Result := HasFlag('scheme-format');
end;

procedure TPOEntry.SetIsSchemeFormat(AValue: boolean);
begin
  if AValue then AddFlag('scheme-format')
  else
    RemoveFlag('scheme-format');
end;

function TPOEntry.GetIsObjectiveCFormat: boolean;
begin
  Result := HasFlag('objective-c-format');
end;

procedure TPOEntry.SetIsObjectiveCFormat(AValue: boolean);
begin
  if AValue then AddFlag('objective-c-format')
  else
    RemoveFlag('objective-c-format');
end;

function TPOEntry.GetIsYcpFormat: boolean;
begin
  Result := HasFlag('ycp-format');
end;

procedure TPOEntry.SetIsYcpFormat(AValue: boolean);
begin
  if AValue then AddFlag('ycp-format')
  else
    RemoveFlag('ycp-format');
end;

function TPOEntry.GetIsTclFormat: boolean;
begin
  Result := HasFlag('tcl-format');
end;

procedure TPOEntry.SetIsTclFormat(AValue: boolean);
begin
  if AValue then AddFlag('tcl-format')
  else
    RemoveFlag('tcl-format');
end;

function TPOEntry.GetIsPerlFormat: boolean;
begin
  Result := HasFlag('perl-format');
end;

procedure TPOEntry.SetIsPerlFormat(AValue: boolean);
begin
  if AValue then AddFlag('perl-format')
  else
    RemoveFlag('perl-format');
end;

function TPOEntry.GetIsPhpFormat: boolean;
begin
  Result := HasFlag('php-format');
end;

procedure TPOEntry.SetIsPhpFormat(AValue: boolean);
begin
  if AValue then AddFlag('php-format')
  else
    RemoveFlag('php-format');
end;

function TPOEntry.GetIsGccInternalFormat: boolean;
begin
  Result := HasFlag('gcc-internal-format');
end;

procedure TPOEntry.SetIsGccInternalFormat(AValue: boolean);
begin
  if AValue then AddFlag('gcc-internal-format')
  else
    RemoveFlag('gcc-internal-format');
end;

function TPOEntry.GetIsQtPluralFormat: boolean;
begin
  Result := HasFlag('qt-plural-format');
end;

procedure TPOEntry.SetIsQtPluralFormat(AValue: boolean);
begin
  if AValue then AddFlag('qt-plural-format')
  else
    RemoveFlag('qt-plural-format');
end;

function TPOEntry.GetIsCppFormat: boolean;
begin
  Result := HasFlag('c++-format');
end;

procedure TPOEntry.SetIsCppFormat(AValue: boolean);
begin
  if AValue then AddFlag('c++-format')
  else
    RemoveFlag('c++-format');
end;

function TPOEntry.GetExtractedComment: string;
var
  sl: TStrings;
  i: integer;
begin
  sl := GetCommentsOfType(poctExtracted);
  try
    Result := '';
    for i := 0 to sl.Count - 1 do
    begin
      if i > 0 then
        Result := Result + #10;
      Result := Result + sl[i];
    end;
  finally
    sl.Free;
  end;
end;

procedure TPOEntry.SetExtractedComment(const AValue: string);
var
  sl: TStringList;
  i: integer;
begin
  DeleteCommentsOfType(poctExtracted);
  sl := TStringList.Create;
  try
    sl.Text := AValue;   // splits into lines using any standard line breaks
    for i := 0 to sl.Count - 1 do
      if sl[i] <> '' then
        AddComment(poctExtracted, sl[i]);
  finally
    sl.Free;
  end;
end;

function TPOEntry.GetReference: string;
var
  sl: TStrings;
  i: integer;
begin
  sl := GetCommentsOfType(poctReference);
  try
    Result := '';
    for i := 0 to sl.Count - 1 do
    begin
      if i > 0 then
        Result := Result + #10;
      Result := Result + sl[i];
    end;
  finally
    sl.Free;
  end;
end;

procedure TPOEntry.SetReference(const AValue: string);
var
  sl: TStringList;
  i: integer;
begin
  DeleteCommentsOfType(poctReference);
  sl := TStringList.Create;
  try
    sl.Text := AValue;
    for i := 0 to sl.Count - 1 do
      if sl[i] <> '' then
        AddComment(poctReference, sl[i]);
  finally
    sl.Free;
  end;
end;

function TPOEntry.GetPreviousComment: string;
var
  sl: TStrings;
  i: integer;
begin
  sl := GetCommentsOfType(poctPrevious);
  try
    Result := '';
    for i := 0 to sl.Count - 1 do
    begin
      if i > 0 then
        Result := Result + #10;
      Result := Result + sl[i];
    end;
  finally
    sl.Free;
  end;
end;

procedure TPOEntry.SetPreviousComment(const AValue: string);
var
  sl: TStringList;
  i: integer;
begin
  DeleteCommentsOfType(poctPrevious);
  sl := TStringList.Create;
  try
    sl.Text := AValue;
    for i := 0 to sl.Count - 1 do
      if sl[i] <> '' then
        AddComment(poctPrevious, sl[i]);
  finally
    sl.Free;
  end;
end;

{Original string-based Flags property}

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
        Result := Result + ', ' + s;
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
end;

function TPOEntry.GetIsPlural: boolean;
begin
  Result := FMsgIdPlural <> '';
end;

function TPOEntry.GetMsgStrList: TStrings;
begin
  // Return a copy of the internal msgstr list
  Result := TStringList.Create;
  Result.Assign(FMsgStr);
end;

procedure TPOEntry.SetMsgStrList(AValue: TStrings);
begin
  // Replace all msgstr entries with the provided strings
  FMsgStr.Assign(AValue);
end;

function TPOEntry.GetCommentsStr: TStrings;
var
  i: integer;
  c: TPOComment;
  sl, flagList: TStringList;
begin
  sl := TStringList.Create;
  flagList := TStringList.Create;
  try
    for i := 0 to FComments.Count - 1 do
    begin
      c := TPOComment(FComments[i]);
      case c.CommentType of
        poctTranslator: sl.Add('#=' + c.Text);
        poctExtracted: sl.Add('#.=' + c.Text);
        poctReference: sl.Add('#:=' + c.Text);
        poctPrevious: sl.Add('#|=' + c.Text);
        poctFlag: flagList.Add(c.Text);
      end;
    end;
    // All flags merged into one "#,=" line with comma-separated values
    if flagList.Count > 0 then
      sl.Add('#,=' + flagList.CommaText);
    Result := sl;
  finally
    flagList.Free;
  end;
end;

procedure TPOEntry.SetCommentsStr(AValue: TStrings);
var
  i, p: integer;
  s, typ, txt: string;
  flagParts: TStringList;
begin
  // Replace all existing comments with the supplied list
  FComments.Clear;

  for i := 0 to AValue.Count - 1 do
  begin
    s := AValue[i];
    if s = '' then
      Continue;
    p := Pos('=', s);
    if p = 0 then
      Continue;
    typ := Copy(s, 1, p - 1);
    txt := Copy(s, p + 1, MaxInt);

    if typ = '#' then
      AddComment(poctTranslator, txt)
    else if typ = '#.' then
      AddComment(poctExtracted, txt)
    else if typ = '#:' then
      AddComment(poctReference, txt)
    else if typ = '#|' then
      AddComment(poctPrevious, txt)
    else if typ = '#,' then
    begin
      // Split the comma-separated flags and add each as a separate poctFlag
      flagParts := TStringList.Create;
      try
        flagParts.CommaText := txt;
        for p := 0 to flagParts.Count - 1 do
          if Trim(flagParts[p]) <> '' then
            AddComment(poctFlag, Trim(flagParts[p]));
      finally
        flagParts.Free;
      end;
    end;
    // unknown prefixes are silently ignored
  end;
end;

{ToString implementation}

function TPOEntry.ToString(ALineEndingStyle: TPOLineEndingStyle): string;
var
  Lines: TStringList;
  Prefix: string;
  FlagStr: string;
  i: integer;

  procedure AddField(const FieldKeyword: string; const Value: string);
  var
    Normalized, SepStr, SepEscape: string;
    Parts: TStringArray;
    i: integer;
  begin
    if Value = '' then
    begin
      Lines.Add(Prefix + FieldKeyword + ' ""');
      Exit;
    end;

    case ALineEndingStyle of
      pleCRLF: begin
        SepStr := #13#10;
        SepEscape := '\r\n';
      end;
      pleCR: begin
        SepStr := #13;
        SepEscape := '\r';
      end;
      else
      begin
        SepStr := #10;
        SepEscape := '\n';
      end;
    end;

    Normalized := StringReplace(Value, #13#10, SepStr, [rfReplaceAll]);
    if SepStr <> #13 then
      Normalized := StringReplace(Normalized, #13, SepStr, [rfReplaceAll]);
    if SepStr <> #10 then
      Normalized := StringReplace(Normalized, #10, SepStr, [rfReplaceAll]);

    if (Length(Normalized) >= Length(SepStr)) and (Copy(Normalized, Length(Normalized) - Length(SepStr) + 1, Length(SepStr)) =
      SepStr) then
    begin
      SetLength(Normalized, Length(Normalized) - Length(SepStr));
      if Pos(SepStr, Normalized) = 0 then
      begin
        Lines.Add(Prefix + FieldKeyword + ' "' + EscapeString(Normalized) + SepEscape + '"');
        Exit;
      end;
      Parts := Normalized.Split(SepStr);
      Lines.Add(Prefix + FieldKeyword + ' ""');
      for i := 0 to High(Parts) do
        Lines.Add('"' + EscapeString(Parts[i]) + SepEscape + '"');
      Exit;
    end
    else
    begin
      if Pos(SepStr, Normalized) = 0 then
      begin
        Lines.Add(Prefix + FieldKeyword + ' "' + EscapeString(Normalized) + '"');
        Exit;
      end;
      Parts := Normalized.Split(SepStr);
      Lines.Add(Prefix + FieldKeyword + ' ""');
      for i := 0 to High(Parts) - 1 do
        Lines.Add('"' + EscapeString(Parts[i]) + SepEscape + '"');
      Lines.Add('"' + EscapeString(Parts[High(Parts)]) + '"');
    end;
  end;

begin
  Lines := TStringList.Create;
  try
    if FObsolete then Prefix := '#~ '
    else
      Prefix := '';

    // 1. Translator comments
    for i := 0 to FComments.Count - 1 do
      if TPOComment(FComments[i]).CommentType = poctTranslator then
        Lines.Add(Prefix + '# ' + TPOComment(FComments[i]).Text);

    // 2. Extracted comments
    for i := 0 to FComments.Count - 1 do
      if TPOComment(FComments[i]).CommentType = poctExtracted then
        Lines.Add(Prefix + '#. ' + TPOComment(FComments[i]).Text);

    // 3. Reference comments
    for i := 0 to FComments.Count - 1 do
      if TPOComment(FComments[i]).CommentType = poctReference then
        Lines.Add(Prefix + '#: ' + TPOComment(FComments[i]).Text);

    // 4. Flag comments (combine into one line)
    FlagStr := '';
    for i := 0 to FComments.Count - 1 do
      if TPOComment(FComments[i]).CommentType = poctFlag then
      begin
        if FlagStr <> '' then
          FlagStr := FlagStr + ', ';
        FlagStr := FlagStr + TPOComment(FComments[i]).Text;
      end;
    if FlagStr <> '' then
      Lines.Add(Prefix + '#, ' + FlagStr);

    // 5. Previous comments (must go after flags)
    for i := 0 to FComments.Count - 1 do
      if TPOComment(FComments[i]).CommentType = poctPrevious then
        Lines.Add(Prefix + '#| ' + TPOComment(FComments[i]).Text);

    // msgctxt
    if FMsgCtxt <> '' then
      AddField('msgctxt', FMsgCtxt);

    // msgid
    AddField('msgid', FMsgId);

    // msgid_plural
    if IsPlural then
      AddField('msgid_plural', FMsgIdPlural);

    // msgstr / msgstr[N]
    if IsPlural then
    begin
      for i := 0 to MsgStrCount - 1 do
        AddField('msgstr[' + IntToStr(i) + ']', MsgStr[i]);
      if MsgStrCount = 0 then
        Lines.Add(Prefix + 'msgstr[0] ""');
    end
    else
      AddField('msgstr', MsgStrSimple);

    // Set line break style for final string
    case ALineEndingStyle of
      pleCRLF: Lines.LineBreak := #13#10;
      pleCR: Lines.LineBreak := #13;
      else
        Lines.LineBreak := #10;
    end;
    Result := Lines.Text;

    // Remove trailing LineBreak added by TStrings.Text
    if (Length(Result) >= Length(Lines.LineBreak)) and (Copy(Result, Length(Result) - Length(Lines.LineBreak) +
      1, Length(Lines.LineBreak)) = Lines.LineBreak) then
      SetLength(Result, Length(Result) - Length(Lines.LineBreak));
  finally
    Lines.Free;
  end;
end;

function TPOEntry.ToString: string;
begin
  Result := ToString(pleLF);
end;

{Check valid Po}

function TPOEntry.IsValid: boolean;
begin
  Result := not IsFuzzy and ((MsgStrSimple <> '') or (MsgStrSimple = MsgId));
end;

{%EndRegion}

{%Region -fold TPOEntryList}

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

{%EndRegion}

{%Region -fold TPOFile}

constructor TPOFile.Create;
begin
  inherited;
  FEntries := TPOEntryList.Create(True);
  FEncoding := TEncoding.UTF8;
  FLineEndingStyle := pleLF;   // default to Unix style
  FTrailingEmptyLines := 0;
  Reset;
end;

destructor TPOFile.Destroy;
begin
  FEntries.Free;
  inherited;
end;

procedure TPOFile.Assign(Source: TPOFile);
var
  i: integer;
  NewEntry: TPOEntry;
begin
  // Clear current content
  Clear;

  // Copy simple properties
  FEncoding := Source.Encoding;               // TEncoding references are safe (singletons)
  FLineEndingStyle := Source.LineEndingStyle;
  FTrailingEmptyLines := Source.TrailingEmptyLines;

  // Deep copy all entries
  for i := 0 to Source.Entries.Count - 1 do
  begin
    NewEntry := TPOEntry.Create;
    NewEntry.Assign(Source.Entries[i]);       // use the entry's own deep copy
    FEntries.Add(NewEntry);
  end;
end;

constructor TPOFile.CreateCopy(ASource: TPOFile);
begin
  Create;
  Assign(ASource);
end;

procedure TPOFile.Clear;
begin
  FEntries.Clear;
end;

procedure TPOFile.Reset;
var
  HeaderEntry: TPOEntry;
  DefaultHeaders: TStringList;
  h: TPOHeader;
  DefaultValues: array[TPOHeader] of string;
begin
  FEntries.Clear;

  HeaderEntry := TPOEntry.Create;
  HeaderEntry.MsgId := '';

  for h := Low(TPOHeader) to High(TPOHeader) do
    DefaultValues[h] := '';

  DefaultValues[hMIMEVersion] := '1.0';
  DefaultValues[hContentType] := 'text/plain; charset=UTF-8';
  DefaultValues[hContentTransferEncoding] := '8bit';

  DefaultHeaders := TStringList.Create;
  try
    for h := Low(TPOHeader) to High(TPOHeader) do
      DefaultHeaders.Add(POHeaderNames[h] + ': ' + DefaultValues[h]);

    HeaderEntry.MsgStrSimple := DefaultHeaders.Text;
  finally
    DefaultHeaders.Free;
  end;

  FEntries.Add(HeaderEntry);
end;

procedure TPOFile.ParseLine(const Line: string; var CurrentEntry: TPOEntry; var PendingState: TParseState);

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
  begin
    if PendingState.MultiBuffer.Count > 0 then
    begin
      TempStr := '';
      for i := 0 to PendingState.MultiBuffer.Count - 1 do
        TempStr := TempStr + PendingState.MultiBuffer[i];
      TempStr := UnescapeString(TempStr);

      if PendingState.Field = 'msgid' then
        CurrentEntry.MsgId := TempStr
      else if PendingState.Field = 'msgid_plural' then
        CurrentEntry.MsgIdPlural := TempStr
      else if PendingState.Field = 'msgctxt' then
        CurrentEntry.MsgCtxt := TempStr
      else if PendingState.Field = 'msgstr' then
        CurrentEntry.MsgStrSimple := TempStr
      else if PendingState.Field = 'msgstrN' then
        CurrentEntry.MsgStr[PendingState.PluralIndex] := TempStr;

      PendingState.MultiBuffer.Clear;
      PendingState.Field := '';
    end
    else if PendingState.Field <> '' then
    begin
      // Empty field (e.g. msgid "")
      if PendingState.Field = 'msgid' then
        CurrentEntry.MsgId := ''
      else if PendingState.Field = 'msgid_plural' then
        CurrentEntry.MsgIdPlural := ''
      else if PendingState.Field = 'msgctxt' then
        CurrentEntry.MsgCtxt := ''
      else if PendingState.Field = 'msgstr' then
        CurrentEntry.MsgStrSimple := ''
      else if PendingState.Field = 'msgstrN' then
        CurrentEntry.MsgStr[PendingState.PluralIndex] := '';
      PendingState.Field := '';
    end;
  end;

var
  TrimmedLine: string;
  Key, Value: string;
  EqPos: integer;
  TempStr: string;
  Content: string;
  sl: TStringList;
  i: integer;
begin
  TrimmedLine := TrimRight(Line);

  if TrimmedLine = '' then
  begin
    FinalizePendingField;
    FinalizeCurrentEntry;
    Exit;
  end;

  if (TrimmedLine[1] = '#') then
  begin
    // Comment lines cannot appear in the middle of a field
    if PendingState.Field <> '' then
      Exit;

    if CurrentEntry = nil then
      CurrentEntry := TPOEntry.Create;

    if Copy(TrimmedLine, 1, 2) = '#.' then
      CurrentEntry.FComments.Add(TPOComment.Create(poctExtracted, Trim(Copy(TrimmedLine, 3, MaxInt))))
    else if Copy(TrimmedLine, 1, 2) = '#:' then
      CurrentEntry.FComments.Add(TPOComment.Create(poctReference, Trim(Copy(TrimmedLine, 3, MaxInt))))
    else if Copy(TrimmedLine, 1, 2) = '#|' then
      CurrentEntry.FComments.Add(TPOComment.Create(poctPrevious, Trim(Copy(TrimmedLine, 3, MaxInt))))
    else if (Length(TrimmedLine) >= 2) and (TrimmedLine[2] = ',') then
    begin
      // Split flag list: store each flag as a separate poctFlag comment
      Content := Trim(Copy(TrimmedLine, 3, MaxInt));
      sl := TStringList.Create;
      try
        sl.CommaText := Content;
        for i := 0 to sl.Count - 1 do
        begin
          TempStr := Trim(sl[i]);
          if TempStr <> '' then
            CurrentEntry.FComments.Add(TPOComment.Create(poctFlag, TempStr));
        end;
      finally
        sl.Free;
      end;
    end
    else if Copy(TrimmedLine, 1, 2) = '#~' then
      CurrentEntry.Obsolete := True
    else
      CurrentEntry.FComments.Add(TPOComment.Create(poctTranslator, Trim(Copy(TrimmedLine, 2, MaxInt))));
    Exit;
  end;

  // Continuation line (starts with ")
  if (TrimmedLine[1] = '"') and (PendingState.Field <> '') then
  begin
    TempStr := Copy(TrimmedLine, 2, Length(TrimmedLine) - 2);
    PendingState.MultiBuffer.Add(TempStr);
    Exit;
  end;

  // New field keyword
  FinalizePendingField;

  Key := TrimmedLine;
  EqPos := Pos(' ', Key);
  if EqPos > 0 then
    Key := Copy(Key, 1, EqPos - 1);
  Value := Trim(Copy(TrimmedLine, Length(Key) + 1, MaxInt));

  // Start a new entry when we encounter msgid (unless it's the first entry still without msgid)
  if (Key = 'msgid') or (Key = 'msgctxt') then
  begin
    if (CurrentEntry <> nil) and (CurrentEntry.MsgId <> '') then
      FinalizeCurrentEntry;
  end;

  if CurrentEntry = nil then
    CurrentEntry := TPOEntry.Create;

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
    TempStr := Copy(Key, 8, Length(Key) - 8);
    PendingState.PluralIndex := StrToIntDef(TempStr, -1);
  end
  else
    Exit;

  if (Value <> '') and (Value[1] = '"') then
  begin
    PendingState.MultiBuffer.Clear;
    Content := Copy(Value, 2, Length(Value) - 2);
    if Content <> '' then
      PendingState.MultiBuffer.Add(Content);
  end
  else
  begin
    PendingState.MultiBuffer.Clear;
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

      // Count trailing empty lines
      FTrailingEmptyLines := 0;
      i := sl.Count - 1;
      while (i >= 0) and (sl[i] = '') do
      begin
        Inc(FTrailingEmptyLines);
        Dec(i);
      end;

      for i := 0 to sl.Count - 1 do
      begin
        Line := sl[i];
        ParseLine(Line, CurrentEntry, PendingState);
      end;
    finally
      sl.Free;
    end;

    // Finalize any pending field and the last entry
    if PendingState.Field <> '' then
    begin
      if PendingState.MultiBuffer.Count > 0 then
        ParseLine('', CurrentEntry, PendingState)
      else
      begin
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

procedure TPOFile.AddFieldToStrings(Lines: TStrings; const Prefix, FieldKeyword: string; const Value: string);
var
  Normalized: string;
  SepStr: string;   // the line break string according to style
  SepEscape: string;
  Parts: TStringArray;
  i: integer;
begin
  if Value = '' then
  begin
    Lines.Add(Prefix + FieldKeyword + ' ""');
    Exit;
  end;

  // Determine separator and its escape sequence
  case FLineEndingStyle of
    pleCRLF: begin
      SepStr := #13#10;
      SepEscape := '\r\n';
    end;
    pleCR: begin
      SepStr := #13;
      SepEscape := '\r';
    end;
    else       // pleLF
      SepStr := #10;
      SepEscape := '\n';
  end;

  // Normalise all line breaks to the chosen style
  Normalized := StringReplace(Value, #13#10, SepStr, [rfReplaceAll]);
  if SepStr <> #13 then
    Normalized := StringReplace(Normalized, #13, SepStr, [rfReplaceAll]);
  if SepStr <> #10 then
    Normalized := StringReplace(Normalized, #10, SepStr, [rfReplaceAll]);

  // Check if the string ends with the separator
  if (Length(Normalized) >= Length(SepStr)) and (Copy(Normalized, Length(Normalized) - Length(SepStr) + 1, Length(SepStr)) =
    SepStr) then
  begin
    SetLength(Normalized, Length(Normalized) - Length(SepStr));
    // If the string is a single line (no more separators) and trailing separator was present
    if Pos(SepStr, Normalized) = 0 then
    begin
      Lines.Add(Prefix + FieldKeyword + ' "' + EscapeString(Normalized) + SepEscape + '"');
      Exit;
    end;
    // Multi-line with trailing separator: split, each part + escape
    Parts := Normalized.Split(SepStr);
    Lines.Add(Prefix + FieldKeyword + ' ""');
    for i := 0 to High(Parts) do
      Lines.Add('"' + EscapeString(Parts[i]) + SepEscape + '"');
    Exit;
  end
  else
  begin
    // No trailing separator
    if Pos(SepStr, Normalized) = 0 then
    begin
      // Single line
      Lines.Add(Prefix + FieldKeyword + ' "' + EscapeString(Normalized) + '"');
      Exit;
    end;
    // Multi-line, no trailing separator
    Parts := Normalized.Split(SepStr);
    Lines.Add(Prefix + FieldKeyword + ' ""');
    for i := 0 to High(Parts) - 1 do
      Lines.Add('"' + EscapeString(Parts[i]) + SepEscape + '"');
    Lines.Add('"' + EscapeString(Parts[High(Parts)]) + '"');
  end;
end;

procedure TPOFile.WriteEntry(Entry: TPOEntry; Lines: TStrings);
var
  i: integer;
  Prefix: string;
  FlagStr: string;
begin
  if Entry.Obsolete then Prefix := '#~ '
  else
    Prefix := '';

  // 1. Translator
  for i := 0 to Entry.FComments.Count - 1 do
    if TPOComment(Entry.FComments[i]).CommentType = poctTranslator then
      Lines.Add(Prefix + '# ' + TPOComment(Entry.FComments[i]).Text);

  // 2. Extracted
  for i := 0 to Entry.FComments.Count - 1 do
    if TPOComment(Entry.FComments[i]).CommentType = poctExtracted then
      Lines.Add(Prefix + '#. ' + TPOComment(Entry.FComments[i]).Text);

  // 3. Reference
  for i := 0 to Entry.FComments.Count - 1 do
    if TPOComment(Entry.FComments[i]).CommentType = poctReference then
      Lines.Add(Prefix + '#: ' + TPOComment(Entry.FComments[i]).Text);

  // 4. Flags (strictly before #|)
  FlagStr := '';
  for i := 0 to Entry.FComments.Count - 1 do
    if TPOComment(Entry.FComments[i]).CommentType = poctFlag then
    begin
      if FlagStr <> '' then
        FlagStr := FlagStr + ', ';
      FlagStr := FlagStr + TPOComment(Entry.FComments[i]).Text;
    end;
  if FlagStr <> '' then
    Lines.Add(Prefix + '#, ' + FlagStr);

  // 5. Previous (after flags)
  for i := 0 to Entry.FComments.Count - 1 do
    if TPOComment(Entry.FComments[i]).CommentType = poctPrevious then
      Lines.Add(Prefix + '#| ' + TPOComment(Entry.FComments[i]).Text);

  // msgctxt
  if Entry.MsgCtxt <> '' then
    AddFieldToStrings(Lines, Prefix, 'msgctxt', Entry.MsgCtxt);

  // msgid
  AddFieldToStrings(Lines, Prefix, 'msgid', Entry.MsgId);

  // msgid_plural
  if Entry.IsPlural then
    AddFieldToStrings(Lines, Prefix, 'msgid_plural', Entry.MsgIdPlural);

  // msgstr / msgstr[N]
  if Entry.IsPlural then
  begin
    for i := 0 to Entry.MsgStrCount - 1 do
      AddFieldToStrings(Lines, Prefix, 'msgstr[' + IntToStr(i) + ']', Entry.MsgStr[i]);
    if Entry.MsgStrCount = 0 then
      Lines.Add(Prefix + 'msgstr[0] ""');
  end
  else
    AddFieldToStrings(Lines, Prefix, 'msgstr', Entry.MsgStrSimple);
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

    // Preserve trailing empty lines as in the original file
    for i := 1 to FTrailingEmptyLines do
      sl.Add('');

    // Set the file-level line break according to style
    case FLineEndingStyle of
      pleCRLF: sl.LineBreak := #13#10;
      pleCR: sl.LineBreak := #13;
      else
        sl.LineBreak := #10;
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

function TPOFile.FindEntry(const AMsgId: string): TPOEntry; overload;
var
  i: integer;
begin
  for i := 0 to FEntries.Count - 1 do
    if (TPOEntry(FEntries[i]).MsgId = AMsgId) then
      Exit(TPOEntry(FEntries[i]));
  Result := nil;
end;

procedure TPOFile.DeleteEntriesByIndexes(const AIndexes: array of integer);
var
  i, Idx: integer;
  sl: TStringList;
begin
  if Length(AIndexes) = 0 then Exit;
  sl := TStringList.Create;
  try
    for i := 0 to High(AIndexes) do
      sl.Add(IntToStr(AIndexes[i]));
    // Sort descending so we delete from highest to lowest index
    sl.CustomSort(@CompareIndexStringsDesc);
    for i := 0 to sl.Count - 1 do
    begin
      Idx := StrToInt(sl[i]);
      if (Idx >= 0) and (Idx < FEntries.Count) then
        FEntries.Delete(Idx);
    end;
  finally
    sl.Free;
  end;
end;

function TPOFile.GetHeaders: TStrings;
var
  Entry: TPOEntry;
  sl: TStringList;
  i: integer;
  s: string;
  p: integer;
begin
  Entry := FindEntry('', '');
  if Entry = nil then
  begin
    Entry := TPOEntry.Create;
    Entry.MsgId := '';
    FEntries.Insert(0, Entry);
  end;
  sl := TStringList.Create;
  try
    sl.Text := Entry.MsgStrSimple;
    Result := TStringList.Create;
    for i := 0 to sl.Count - 1 do
    begin
      s := sl[i];
      if s = '' then Continue;
      p := Pos(': ', s);
      if p > 0 then
        Result.Add(Copy(s, 1, p - 1) + '=' + Copy(s, p + 2, MaxInt))
      else
        Result.Add(s);
    end;
  finally
    sl.Free;
  end;
end;

procedure TPOFile.SetHeaders(AHeaders: TStrings);
var
  Entry: TPOEntry;
  sl: TStringList;
  i: integer;
  s: string;
  p: integer;
begin
  Entry := FindEntry('', '');
  if Entry = nil then
  begin
    Entry := TPOEntry.Create;
    Entry.MsgId := '';
    FEntries.Insert(0, Entry);
  end;
  sl := TStringList.Create;
  try
    for i := 0 to AHeaders.Count - 1 do
    begin
      s := AHeaders[i];
      if s = '' then Continue;
      p := Pos('=', s);
      if p > 0 then
        sl.Add(Copy(s, 1, p - 1) + ': ' + Copy(s, p + 1, MaxInt))
      else
        sl.Add(s);
    end;
    Entry.MsgStrSimple := sl.Text;
  finally
    sl.Free;
  end;
end;

function TPOFile.GetHeaderValue(const AKey: string): string;
var
  H: TStrings;
begin
  H := GetHeaders;
  try
    Result := H.Values[AKey];
  finally
    H.Free;
  end;
end;

procedure TPOFile.SetHeaderValue(const AKey, AValue: string);
var
  H: TStrings;
begin
  H := GetHeaders;
  try
    H.Values[AKey] := AValue;
    SetHeaders(H);
  finally
    H.Free;
  end;
end;

function TPOFile.GetTranslations: TStrings;
var
  i: integer;
  Entry: TPOEntry;
  KeyEscaped: string;
begin
  Result := TStringList.Create;
  for i := 0 to FEntries.Count - 1 do
  begin
    Entry := TPOEntry(FEntries[i]);
    if Entry.MsgId = '' then Continue;   // skip header(s)

    // Escape '\' and '=' to safely embed Key in 'Key=Value' line
    KeyEscaped := StringReplace(Entry.MsgId, '\', '\\', [rfReplaceAll]);
    KeyEscaped := StringReplace(KeyEscaped, '=', '\=', [rfReplaceAll]);

    Result.Add(KeyEscaped + '=' + Entry.MsgStrSimple);
  end;
end;

procedure TPOFile.SetTranslations(AList: TStrings);
var
  i, j: integer;
  Entry: TPOEntry;
  S, KeyPart, ValuePart: string;
  p: integer;
  Escaped: boolean;
begin
  j := 0;
  for i := 0 to FEntries.Count - 1 do
  begin
    Entry := TPOEntry(FEntries[i]);
    if Entry.MsgId = '' then
      Continue;

    if j >= AList.Count then
      raise Exception.CreateFmt('More translatable entries than provided strings (at entry "%s")', [Entry.MsgId]);

    S := AList[j];

    // Find first unescaped '='
    p := 1;
    Escaped := False;
    while p <= Length(S) do
    begin
      if Escaped then
        Escaped := False
      else if S[p] = '\' then
        Escaped := True
      else if S[p] = '=' then
        Break;
      Inc(p);
    end;

    if p > Length(S) then
      raise Exception.CreateFmt('Invalid translation line (missing =): %s', [S]);

    KeyPart := Copy(S, 1, p - 1);
    ValuePart := Copy(S, p + 1, MaxInt);

    // Unescape the key
    KeyPart := StringReplace(KeyPart, '\=', '=', [rfReplaceAll]);
    KeyPart := StringReplace(KeyPart, '\\', '\', [rfReplaceAll]);

    if KeyPart <> Entry.MsgId then
      raise Exception.CreateFmt('Key mismatch at position %d: expected "%s" but got "%s"', [j, Entry.MsgId, KeyPart]);

    Entry.MsgStrSimple := ValuePart;
    Inc(j);
  end;

  if j <> AList.Count then
    raise Exception.CreateFmt('Provided %d translations but there are %d translatable entries', [AList.Count, j]);
end;

function TPOFile.GetPluralFormsCount: integer;
var
  Value: string;
  p: integer;
  NumStr: string;
begin
  Result := 0;   // default: no plural forms
  Value := Self.HeaderValue['Plural-Forms'];
  if Value = '' then
    Exit;
  // Locate 'nplurals=' substring
  p := Pos('nplurals=', Value);
  if p = 0 then
    Exit;
  Inc(p, Length('nplurals='));
  // Read consecutive digits
  NumStr := '';
  while (p <= Length(Value)) and (Value[p] in ['0'..'9']) do
  begin
    NumStr := NumStr + Value[p];
    Inc(p);
  end;
  Result := StrToIntDef(NumStr, 0);
end;

function TPOFile.GetPluralFormsExpression: string;
var
  Value: string;
  p: integer;
begin
  Result := '';
  Value := Self.HeaderValue['Plural-Forms'];
  if Value = '' then
    Exit;
  p := Pos('plural=', Value);
  if p = 0 then
    Exit;
  Inc(p, Length('plural='));
  Result := Copy(Value, p, MaxInt);
end;

class function TPOFile.GetFileStatus(const AFileName: string): TPoFileStatus;
var
  Po: TPOFile;
  i, j: integer;
  Entry: TPOEntry;
  HasEmpty: boolean;
begin
  Po := TPOFile.Create;
  try
    Po.LoadFromFile(AFileName);
    HasEmpty := False;
    // Skip entry 0 (header with empty msgid)
    for i := 1 to Po.Entries.Count - 1 do
    begin
      Entry := Po.Entries[i];
      // Ignore obsolete entries
      if Entry.Obsolete then
        Continue;
      // Fuzzy is the highest priority problem
      if Entry.IsFuzzy then
        Exit(psFuzzy);
      // Check for empty translation if not already found
      if not HasEmpty then
      begin
        if Entry.IsPlural then
        begin
          // Plural: all forms must be non-empty, otherwise it's empty
          HasEmpty := True;
          for j := 0 to Entry.MsgStrCount - 1 do
            if Entry.MsgStr[j] <> '' then
            begin
              HasEmpty := False;
              Break;
            end;
        end
        else
          HasEmpty := (Entry.MsgStrSimple = '');
      end;
    end;
    if HasEmpty then
      Result := psEmptyTranslation
    else
      Result := psCorrect;
  finally
    Po.Free;
  end;
end;

class function TPOFile.GetCommentTypeName(const APrefix: string): string;
const
  Prefixes: array[0..5] of string = ('# ', '#.', '#:', '#,', '#|', '#~');
  Names: array[0..5] of string = (
    'Translator comment',
    'Extracted comment',
    'Source code reference',
    'Flag comment',
    'Previous msgid',
    'Obsolete message'
    );
var
  i: integer;
begin
  Result := 'None';
  for i := 0 to High(Prefixes) do
    if Prefixes[i] = APrefix then
      Exit(Names[i]);
end;

class function TPOFile.GetHeaderNames: TStringList;
var
  h: TPOHeader;
begin
  Result := TStringList.Create;
  try
    for h := Low(TPOHeader) to High(TPOHeader) do
      Result.Add(POHeaderNames[h]);
  except
    Result.Free;
    raise;
  end;
end;

{%EndRegion}

end.
