//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit PoWrap;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  Classes,
  SysUtils,
  Contnrs;

resourcestring
  // QA check messages
  rsQAPlaceholderMissing = 'Missing placeholder in translation: %s';
  rsQAPlaceholderExtra = 'Extra placeholder in translation: %s';
  rsQACaseMismatch = 'Case mismatch: source starts with "%s", translation starts with "%s"';
  rsQACaseMismatchUpper = 'Case mismatch: source is all uppercase, translation is not';
  rsQASpaceLeading = 'Leading space in translation';
  rsQASpaceTrailing = 'Trailing space in translation';
  rsQASpaceDouble = 'Double space in translation';
  rsQASpaceBeforePunctuation = 'Space before punctuation: "%s"';
  rsQASpaceMissingAfterPunctuation = 'Missing space after punctuation: "%s"';
  rsQAPunctuationEndMismatch = 'End punctuation mismatch: source ends with "%s", translation ends with "%s"';
  rsQAPunctuationBracketMismatch = 'Bracket mismatch: expected "%s", found "%s"';
  rsQAPluralFormsMismatch = 'Plural forms count mismatch: expected %d, found %d';

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

  TQACheckOptions = record
    PluralFormsCount: integer;
    PlaceholderMissing: boolean;
    PlaceholderExtra: boolean;
    PluralCount: boolean;
    CaseFirstChar: boolean;
    CaseAllUpper: boolean;
    SpaceLeading: boolean;
    SpaceTrailing: boolean;
    SpaceDouble: boolean;
    SpaceBeforePunct: boolean;
    SpaceAfterPunct: boolean;
    PunctEnd: boolean;
    PunctBracket: boolean;
  end;

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
    FQACheckResults: TStringArray;

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

    // QA checks
    procedure ClearQACheckResults;
    procedure AddQACheckResult(const AMessage: string);
    function GetQACheckResults: TStringArray;
    procedure CheckQA(const AOptions: TQACheckOptions);

    property QACheckResults: TStringArray read GetQACheckResults;

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
    FQACheckPlaceholderMissing: boolean;
    FQACheckPlaceholderExtra: boolean;
    FQACheckPluralCount: boolean;
    FQACheckCaseFirstChar: boolean;
    FQACheckCaseAllUpper: boolean;
    FQACheckSpaceLeading: boolean;
    FQACheckSpaceTrailing: boolean;
    FQACheckSpaceDouble: boolean;
    FQACheckSpaceBeforePunct: boolean;
    FQACheckSpaceAfterPunct: boolean;
    FQACheckPunctEnd: boolean;
    FQACheckPunctBracket: boolean;
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

    // Run all QA checks on every entry of the file
    procedure CheckAllQA;
    procedure CheckEntryQA(AEntry: TPOEntry);
    function GetQACheckOptions: TQACheckOptions;

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

    property QACheckPlaceholderMissing: boolean read FQACheckPlaceholderMissing write FQACheckPlaceholderMissing;
    property QACheckPlaceholderExtra: boolean read FQACheckPlaceholderExtra write FQACheckPlaceholderExtra;
    property QACheckPluralCount: boolean read FQACheckPluralCount write FQACheckPluralCount;
    property QACheckCaseFirstChar: boolean read FQACheckCaseFirstChar write FQACheckCaseFirstChar;
    property QACheckCaseAllUpper: boolean read FQACheckCaseAllUpper write FQACheckCaseAllUpper;
    property QACheckSpaceLeading: boolean read FQACheckSpaceLeading write FQACheckSpaceLeading;
    property QACheckSpaceTrailing: boolean read FQACheckSpaceTrailing write FQACheckSpaceTrailing;
    property QACheckSpaceDouble: boolean read FQACheckSpaceDouble write FQACheckSpaceDouble;
    property QACheckSpaceBeforePunct: boolean read FQACheckSpaceBeforePunct write FQACheckSpaceBeforePunct;
    property QACheckSpaceAfterPunct: boolean read FQACheckSpaceAfterPunct write FQACheckSpaceAfterPunct;
    property QACheckPunctEnd: boolean read FQACheckPunctEnd write FQACheckPunctEnd;
    property QACheckPunctBracket: boolean read FQACheckPunctBracket write FQACheckPunctBracket;

    // Po File Operations
    class function ComputeStatusFromModel(APoFile: TPOFile): TPoFileStatus;
    class function GetFileStatus(const AFileName: string): TPoFileStatus; static;
    class function GetCommentTypeName(const APrefix: string): string; static;
    class function GetHeaderNames: TStringList;
    procedure SynchronizeToFile(const AFileName: string; AUpdateHeader: boolean = False);
    procedure ApplyDefaultHeaders(const ALanguage: string = ''; const AGenerator: string = '');
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

{%Region -fold QA helper functions}

// Determine whether the text contains characters from a right-to-left
// script. The whole string is scanned, so a mix of ASCII and Hebrew or
// Arabic is still reported as RTL - which is what the QA checks need,
// because the sentence-ending dot heuristic based on uppercase letters
// cannot be applied to RTL scripts. Other RTL scripts (Syriac, Thaana,
// N'Ko, etc.) can be added here later if needed.
function IsRTLText(const S: string): boolean;
var
  I, Len: integer;
  B1, B2: byte;
begin
  Result := False;
  Len := Length(S);
  I := 1;
  while I <= Len do
  begin
    B1 := Ord(S[I]);
    // Check for two-byte UTF-8 sequences
    if (B1 >= $C2) and (B1 <= $DF) and (I < Len) then
    begin
      B2 := Ord(S[I + 1]);
      // Hebrew (U+0590 - U+05FF): 0xD7 0x90 .. 0xD7 0xBF
      if (B1 = $D7) and (B2 >= $90) and (B2 <= $BF) then
        Exit(True);
      // Arabic (U+0600 - U+06FF): 0xD8 0x80 .. 0xDB 0xBF
      if (B1 = $D8) and (B2 >= $80) then
        Exit(True);
      if (B1 = $D9) or (B1 = $DA) or (B1 = $DB) then
        Exit(True);
    end;
    Inc(I);
  end;
end;

// Normalize the last character of S for end punctuation comparison.
// Full-width CJK punctuation is mapped to its ASCII equivalent:
//   U+3002 -> '.'   U+FF01 -> '!'   U+FF0C -> ','
//   U+FF1A -> ':'   U+FF1B -> ';'   U+FF1F -> '?'
// Single-byte ASCII characters are returned as-is, everything else
// (including unrecognized multi-byte characters) returns #0.
function GetEndPunctuation(const S: string): char;
var
  Len, StartPos: integer;
  B1, B2, B3: byte;
begin
  Result := #0;
  Len := Length(S);
  if Len = 0 then
    Exit;

  // Walk back over UTF-8 continuation bytes to find the last character start
  StartPos := Len;
  while (StartPos > 1) and ((Ord(S[StartPos]) and $C0) = $80) do
    Dec(StartPos);

  B1 := Ord(S[StartPos]);

  // Single-byte ASCII: return as-is
  if StartPos = Len then
  begin
    Result := Chr(B1);
    Exit;
  end;

  // Two-byte UTF-8 sequences used by Greek and Arabic punctuation
  if Len - StartPos = 1 then
  begin
    B2 := Ord(S[StartPos + 1]);
    // U+037E Greek question mark, visually identical to a semicolon but
    // functionally the question mark of the Greek script
    if (B1 = $CE) and (B2 = $BE) then
      Result := '?'
    // U+061F Arabic question mark, the question mark of the Arabic script
    else if (B1 = $D8) and (B2 = $9F) then
      Result := '?';
    Exit;
  end;

  // Three-byte UTF-8 sequences used by CJK full-width punctuation
  if Len - StartPos = 2 then
  begin
    B2 := Ord(S[StartPos + 1]);
    B3 := Ord(S[StartPos + 2]);
    // U+2026 horizontal ellipsis, treated as equivalent to the trailing dot
    // of an ASCII "..." sequence
    if (B1 = $E2) and (B2 = $80) and (B3 = $A6) then
      Result := '.'
    // U+0964 danda and U+0965 double danda, the sentence terminators used
    // by Devanagari and other Indic scripts, treated as full stops
    else if (B1 = $E0) and (B2 = $A5) and ((B3 = $A4) or (B3 = $A5)) then
      Result := '.'
    // U+3002 ideographic full stop
    else if (B1 = $E3) and (B2 = $80) and (B3 = $82) then
      Result := '.'
    // U+FF01, U+FF0C, U+FF1A, U+FF1B, U+FF1F share the EF BC prefix
    else if (B1 = $EF) and (B2 = $BC) then
    begin
      if B3 = $81 then Result := '!'
      else if B3 = $8C then Result := ','
      else if B3 = $9A then Result := ':'
      else if B3 = $9B then Result := ';'
      else if B3 = $9F then Result := '?';
    end;
  end;
end;

// Determine whether S starts with a strong character from a script that
// does not distinguish upper and lower case - CJK, Japanese kana, Korean
// Hangul, Thai and similar. The sentence-ending dot heuristic based on
// uppercase letters cannot be applied to such scripts.
function IsCaseLessText(const S: string): boolean;
var
  I, Len: integer;
  B1, B2: byte;
begin
  Result := False;
  Len := Length(S);
  I := 1;
  while I <= Len do
  begin
    B1 := Ord(S[I]);
    // Three-byte UTF-8 sequences cover Thai, kana, CJK ideographs and Hangul
    if (B1 >= $E0) and (I + 2 <= Len) then
    begin
      B2 := Ord(S[I + 1]);
      // Thai U+0E00-U+0E7F
      if (B1 = $E0) and (B2 >= $B8) and (B2 <= $B9) then
        Exit(True);
      // Hiragana U+3040-U+309F and Katakana U+30A0-U+30FF
      if (B1 = $E3) and (B2 >= $81) and (B2 <= $83) then
        Exit(True);
      // CJK Unified Ideographs U+4E00-U+9FFF
      if (B1 >= $E4) and (B1 <= $E9) then
        Exit(True);
      // Hangul Syllables U+AC00-U+D7AF
      if (B1 >= $EA) and (B1 <= $ED) then
        Exit(True);
      Inc(I, 3);
      Continue;
    end;
    Inc(I);
  end;
end;

// Extract bracket characters from S in ASCII form, mapping full-width
// CJK brackets to their ASCII equivalents so that "(...)" and "(...)"
// with CJK parentheses compare equal. Recognized pairs:
//   U+FF08 ( -> (    U+FF09 ) -> )    U+FF3B [ -> [
//   U+FF3D ] -> ]    U+FF5B { -> {    U+FF5D } -> }
function ExtractBrackets(const S: string): string;
var
  I, Len: integer;
  B1, B2, B3: byte;
  C: char;
begin
  Result := '';
  Len := Length(S);
  I := 1;
  while I <= Len do
  begin
    B1 := Ord(S[I]);
    // ASCII brackets are taken as-is
    if Chr(B1) in ['(', ')', '[', ']', '{', '}'] then
    begin
      Result := Result + Chr(B1);
      Inc(I);
      Continue;
    end;
    // Check three-byte UTF-8 sequences for full-width brackets
    if (B1 >= $E0) and (I + 2 <= Len) then
    begin
      B2 := Ord(S[I + 1]);
      B3 := Ord(S[I + 2]);
      C := #0;
      if (B1 = $EF) and (B2 = $BC) then
      begin
        case B3 of
          $88: C := '(';
          $89: C := ')';
          $BB: C := '[';
          $BD: C := ']';
        end;
      end
      else if (B1 = $EF) and (B2 = $BD) then
      begin
        case B3 of
          $9B: C := '{';
          $9D: C := '}';
        end;
      end;
      if C <> #0 then
      begin
        Result := Result + C;
        Inc(I, 3);
        Continue;
      end;
    end;
    Inc(I);
  end;
end;

// Extract all placeholders from a string (C, Python, .NET styles)
function ExtractPlaceholders(const S: string): TStringList;
var
  K, K2, K3, NestDepth: integer;
  Placeholder, Content: string;
  C: char;
  IsPlaceholderLike: boolean;
begin
  Result := TStringList.Create;
  K := 1;
  while K <= Length(S) do
  begin
    if S[K] = '%' then
    begin
      // Skip escaped percent sign %%
      if (K < Length(S)) and (S[K + 1] = '%') then
      begin
        Inc(K, 2);
        Continue;
      end;
      Placeholder := '%';
      Inc(K);
      // Positional argument (digits followed by $)
      while (K <= Length(S)) and (S[K] in ['0'..'9']) do
      begin
        Placeholder := Placeholder + S[K];
        Inc(K);
      end;
      if (K <= Length(S)) and (S[K] = '$') then
      begin
        Placeholder := Placeholder + S[K];
        Inc(K);
      end;
      // Python-style named placeholder %(name)s
      if (K <= Length(S)) and (S[K] = '(') then
      begin
        while (K <= Length(S)) and (S[K] <> ')') do
        begin
          Placeholder := Placeholder + S[K];
          Inc(K);
        end;
        if K <= Length(S) then
        begin
          Placeholder := Placeholder + ')';
          Inc(K);
        end;
        if K <= Length(S) then
        begin
          Placeholder := Placeholder + S[K];
          Inc(K);
        end;
        Result.Add(Placeholder);
        Continue;
      end;
      // Length modifiers (l, h, L, ll, q, j, z, t)
      while (K <= Length(S)) and (S[K] in ['l', 'h', 'L', 'q', 'j', 'z', 't']) do
      begin
        Placeholder := Placeholder + S[K];
        Inc(K);
      end;
      // Format specifier. Only a recognized printf conversion letter makes
      // this a placeholder; a percent sign followed by anything else
      // (whitespace, punctuation, end of string, another word character)
      // is treated as literal text and not reported as a placeholder.
      if (K <= Length(S)) and (S[K] in ['d', 'i', 'o', 'u', 'x', 'X', 'e', 'E', 'f', 'F', 'g', 'G', 'a',
        'A', 'c', 's', 'p', 'n']) then
      begin
        Placeholder := Placeholder + S[K];
        Inc(K);
        Result.Add(Placeholder);
      end;
    end
    else if S[K] = '{' then
    begin
      // Find the matching close brace, taking nesting into account
      K2 := K + 1;
      NestDepth := 1;
      while (K2 <= Length(S)) and (NestDepth > 0) do
      begin
        if S[K2] = '{' then
          Inc(NestDepth)
        else if S[K2] = '}' then
        begin
          Dec(NestDepth);
          if NestDepth = 0 then
            Break;
        end;
        Inc(K2);
      end;

      if (K2 > Length(S)) or (NestDepth > 0) then
      begin
        // Unbalanced braces - treat as literal text
        Inc(K);
        Continue;
      end;

      Content := Copy(S, K + 1, K2 - K - 1);

      // Treat as a placeholder only when the content looks like an identifier:
      // starts with a letter or digit and contains only identifier characters
      // (letters, digits, underscore, dot, colon, comma, dash). Anything that
      // starts with punctuation (e.g. "{...}", "{..}", "{::}") or contains
      // spaces, nested braces or other symbols is treated as literal text.
      IsPlaceholderLike := False;
      if Length(Content) > 0 then
      begin
        C := Content[1];
        if C in ['A'..'Z', 'a'..'z', '0'..'9', '_'] then
        begin
          IsPlaceholderLike := True;
          for K3 := 2 to Length(Content) do
          begin
            C := Content[K3];
            if not (C in ['A'..'Z', 'a'..'z', '0'..'9', '_', '.', ':', ',', '-']) then
            begin
              IsPlaceholderLike := False;
              Break;
            end;
          end;
        end;
      end;

      if IsPlaceholderLike then
      begin
        Placeholder := Copy(S, K, K2 - K + 1);
        Result.Add(Placeholder);
      end;

      K := K2 + 1;
    end
    else
      Inc(K);
  end;
end;

// Determine whether the character starting at APos in S is a Hangul
// syllable, CJK ideograph, Hiragana or Katakana character. In these
// scripts particles and suffixes attach directly to the preceding
// token, so punctuation followed immediately by such a character
// without a space is a valid form.
function IsAttachedParticleStart(const S: string; APos: integer): boolean;
var
  B1, B2: byte;
begin
  Result := False;
  if (APos < 1) or (APos + 2 > Length(S)) then
    Exit;
  B1 := Ord(S[APos]);
  B2 := Ord(S[APos + 1]);
  // Hiragana U+3040-U+309F and Katakana U+30A0-U+30FF
  if (B1 = $E3) and (B2 >= $81) and (B2 <= $83) then
    Exit(True);
  // CJK Unified Ideographs U+4E00-U+9FFF
  if (B1 >= $E4) and (B1 <= $E9) then
    Exit(True);
  // Hangul Syllables U+AC00-U+D7AF
  if (B1 >= $EA) and (B1 <= $ED) then
    Exit(True);
end;

// Count occurrences of APunct directly followed by either a whitespace
// character or a CJK/Hangul/kana letter. The latter are counted as
// "spaced" because in these scripts particles and suffixes attach to
// the preceding token without an intervening space.
function CountPunctWithSepAfter(const AText: string; APunct: char): integer;
var
  K, Len: integer;
begin
  Result := 0;
  Len := Length(AText);
  for K := 1 to Len - 1 do
    if AText[K] = APunct then
    begin
      if AText[K + 1] in [' ', #9, #10, #13] then
        Inc(Result)
      else if IsAttachedParticleStart(AText, K + 1) then
        Inc(Result);
    end;
end;

// Run all textual QA checks on a source/translation pair, return messages
function RunQAChecksOnText(const ASrc, ATrans: string; const AOptions: TQACheckOptions): TStringArray;
var
  Msgs: TStringList;
  SrcPH, TransPH: TStringList;
  I, K: integer;
  SrcChar, TransChar: char;
  SrcBrackets, TransBrackets: string;
  SrcHasLetters, SrcAllUpper, HasLower: boolean;
  PunctChar: char;
  RTLSource: boolean;

// Count occurrences of APunct directly preceded by a whitespace character
  function CountPunctWithSpaceBefore(const AText: string; APunct: char): integer;
  var
    K: integer;
  begin
    Result := 0;
    for K := 2 to Length(AText) do
      if (AText[K] = APunct) and (AText[K - 1] in [' ', #9, #10, #13]) then
        Inc(Result);
  end;

  // Count occurrences of APunct directly followed by a whitespace character
  function CountPunctWithSpaceAfter(const AText: string; APunct: char): integer;
  var
    K: integer;
  begin
    Result := 0;
    for K := 1 to Length(AText) - 1 do
      if (AText[K] = APunct) and (AText[K + 1] in [' ', #9, #10, #13]) then
        Inc(Result);
  end;

  // Check whether the character at APos is enclosed in quotes like '!'
  // or "!" - a common way to reference a punctuation character itself
  // instead of using it as punctuation. Only ASCII single and double
  // quotes are recognized.
  function IsQuotedChar(const AText: string; APos: integer): boolean;
  begin
    Result := False;
    if (APos < 2) or (APos >= Length(AText)) then
      Exit;
    if (AText[APos - 1] in ['''', '"']) and (AText[APos + 1] in ['''', '"']) then
      Result := True;
  end;

  // Count all occurrences of APunct in AText, skipping quoted characters
  // like '!' or "!" that reference the character itself
  function CountPunct(const AText: string; APunct: char): integer;
  var
    K: integer;
  begin
    Result := 0;
    for K := 1 to Length(AText) do
      if (AText[K] = APunct) and not IsQuotedChar(AText, K) then
        Inc(Result);
  end;

  // Check whether the character starting at APos is an uppercase letter.
  // Handles three UTF-8 families used by the languages PoBatch supports:
  //   - ASCII uppercase A..Z
  //   - Cyrillic uppercase (0xD0 0x80..0xAF, covers Russian, Ukrainian, etc.)
  //   - Latin-1 supplement uppercase (0xC3 0x80..0x9E, minus 0xC3 0x97 which
  //     is the multiplication sign), covers German, French, Spanish, etc.
  //   - Latin Extended-A uppercase (0xC4 0x80..0xB7), covers Polish, Czech,
  //     Hungarian, etc.
  function IsUpperLetter(const S: string; APos: integer): boolean;
  var
    B1, B2, B3: byte;
  begin
    Result := False;
    if (APos < 1) or (APos > Length(S)) then
      Exit;
    B1 := Ord(S[APos]);
    // ASCII uppercase
    if (B1 >= Ord('A')) and (B1 <= Ord('Z')) then
    begin
      Result := True;
      Exit;
    end;
    if APos >= Length(S) then
      Exit;
    B2 := Ord(S[APos + 1]);
    // Cyrillic uppercase
    if (B1 = $D0) and (B2 >= $80) and (B2 <= $AF) then
      Result := True
    // Latin-1 supplement uppercase, excluding the multiplication sign 0xC3 0x97
    else if (B1 = $C3) and (B2 >= $80) and (B2 <= $9E) and (B2 <> $97) then
      Result := True
    // Latin Extended-A block (U+0100-U+017F). Covers Polish, Czech,
    // Hungarian and other Latin-script letters with diacritics,
    // including uppercase letters such as U+015A.
    else if ((B1 = $C4) and (B2 >= $80)) or ((B1 = $C5) and (B2 <= $BF)) then
      Result := True
    // Greek uppercase block (U+0386-U+03AB). Covers the monotonic letters
    // with tonos (U+0386, U+0388-U+038A, U+038C, U+038E-U+038F) and the
    // plain uppercase alphabet (U+0391-U+03A1, U+03A3-U+03AB).
    else if (B1 = $CE) and ((B2 = $86) or ((B2 >= $88) and (B2 <= $8A)) or (B2 = $8C) or ((B2 >= $8E) and (B2 <= $8F)) or
      ((B2 >= $91) and (B2 <= $A1)) or ((B2 >= $A3) and (B2 <= $AB))) then
      Result := True
    // Latin Extended Additional (U+1E00-U+1EFF), covers Vietnamese uppercase
    // with diacritics such as U+1EE8. In this block uppercase letters occupy
    // even codepoints and lowercase ones occupy odd codepoints.
    else if (B1 = $E1) and (B2 >= $B8) and (B2 <= $BB) and (APos + 2 <= Length(S)) then
    begin
      B3 := Ord(S[APos + 2]);
      if (B3 and $01) = 0 then
        Result := True;
    end;
  end;

  // Check whether the character starting at APos is a Spanish inverted
  // punctuation mark: inverted question mark U+00BF (UTF-8: 0xC2 0xBF) or
  // inverted exclamation mark U+00A1 (UTF-8: 0xC2 0xA1).
  function IsInvertedPunct(const S: string; APos: integer): boolean;
  var
    B1, B2: byte;
  begin
    Result := False;
    if (APos < 1) or (APos + 1 > Length(S)) then
      Exit;
    B1 := Ord(S[APos]);
    B2 := Ord(S[APos + 1]);
    Result := (B1 = $C2) and ((B2 = $BF) or (B2 = $A1));
  end;

  // Count sentence-ending dots: a dot followed by whitespace and then an
  // uppercase letter, or a dot at the end of the string. This filters out
  // abbreviation dots like "e.g.", "etc.", "Mr." and decimal dots like "1.5".
  function CountSentenceEndingDots(const S: string): integer;
  var
    K, P: integer;
  begin
    Result := 0;
    for K := 1 to Length(S) do
      if S[K] = '.' then
      begin
        if K = Length(S) then
        begin
          Inc(Result);
          Continue;
        end;
        if S[K + 1] in [' ', #9, #10, #13] then
        begin
          P := K + 1;
          while (P <= Length(S)) and (S[P] in [' ', #9, #10, #13]) do
            Inc(P);
          // Skip leading Spanish inverted punctuation (¿ or ¡) so that the
          // actual sentence-initial letter can be inspected. If the inverted
          // mark is the last thing on the line, treat it as a sentence start
          // by itself.
          if IsInvertedPunct(S, P) then
          begin
            Inc(P, 2);  // both ¿ and ¡ are 2 bytes in UTF-8
            if P > Length(S) then
            begin
              Inc(Result);
              Continue;
            end;
          end;
          // Skip an opening ASCII quote so that the sentence-initial
          // letter behind it can be inspected
          if (P <= Length(S)) and (S[P] in ['''', '"']) then
          begin
            Inc(P);
            if P > Length(S) then
            begin
              Inc(Result);
              Continue;
            end;
          end;
          // A dot followed by whitespace and an opening brace is also
          // treated as a sentence end: the brace starts a placeholder
          // whose actual value is unknown at QA time.
          if (P > Length(S)) or IsUpperLetter(S, P) or (S[P] = '{') then
            Inc(Result);
        end;
      end;
  end;

const
  PunctArray: array[0..5] of char = (',', '.', ';', ':', '!', '?');
begin
  Result := nil;
  SetLength(Result, 0);
  Msgs := TStringList.Create;
  SrcPH := nil;
  TransPH := nil;
  try
    // 1. Placeholder checks
    if AOptions.PlaceholderMissing or AOptions.PlaceholderExtra then
    begin
      SrcPH := ExtractPlaceholders(ASrc);
      TransPH := ExtractPlaceholders(ATrans);
      if AOptions.PlaceholderMissing then
        for I := 0 to SrcPH.Count - 1 do
          if TransPH.IndexOf(SrcPH[I]) < 0 then
            Msgs.Add(Format(rsQAPlaceholderMissing, [SrcPH[I]]));
      if AOptions.PlaceholderExtra then
        for I := 0 to TransPH.Count - 1 do
          if SrcPH.IndexOf(TransPH[I]) < 0 then
            Msgs.Add(Format(rsQAPlaceholderExtra, [TransPH[I]]));
    end;

    // 2. Case mismatch checks
    if (AOptions.CaseFirstChar or AOptions.CaseAllUpper) and (Length(ASrc) > 0) and (Length(ATrans) > 0) then
    begin
      if AOptions.CaseFirstChar then
      begin
        SrcChar := ASrc[1];
        TransChar := ATrans[1];
        if SrcChar in ['A'..'Z'] then
        begin
          if TransChar in ['a'..'z'] then
            Msgs.Add(Format(rsQACaseMismatch, [SrcChar, TransChar]));
        end
        else if SrcChar in ['a'..'z'] then
        begin
          if TransChar in ['A'..'Z'] then
            Msgs.Add(Format(rsQACaseMismatch, [SrcChar, TransChar]));
        end;
      end;

      if AOptions.CaseAllUpper then
      begin
        SrcHasLetters := False;
        SrcAllUpper := True;
        for I := 1 to Length(ASrc) do
        begin
          if ASrc[I] in ['a'..'z'] then
          begin
            SrcHasLetters := True;
            SrcAllUpper := False;
            Break;
          end
          else if ASrc[I] in ['A'..'Z'] then
            SrcHasLetters := True;
        end;
        if SrcHasLetters and SrcAllUpper then
        begin
          HasLower := False;
          for I := 1 to Length(ATrans) do
            if ATrans[I] in ['a'..'z'] then
            begin
              HasLower := True;
              Break;
            end;
          if HasLower then
            Msgs.Add(rsQACaseMismatchUpper);
        end;
      end;
    end;

    // 3. Space checks - all are comparative with the source string
    if AOptions.SpaceLeading then
      if (Length(ATrans) > 0) and (ATrans[1] = ' ') and not ((Length(ASrc) > 0) and (ASrc[1] = ' ')) then
        Msgs.Add(rsQASpaceLeading);
    if AOptions.SpaceTrailing then
      if (Length(ATrans) > 0) and (ATrans[Length(ATrans)] = ' ') and not ((Length(ASrc) > 0) and (ASrc[Length(ASrc)] = ' ')) then
        Msgs.Add(rsQASpaceTrailing);
    if AOptions.SpaceDouble then
      if (Pos('  ', ATrans) > 0) and (Pos('  ', ASrc) = 0) then
        Msgs.Add(rsQASpaceDouble);

    // Space before punctuation: report only when the translation keeps at
    // least as many punctuation marks as the source, but puts more whitespace
    // before them. If the translation dropped the punctuation entirely, that
    // is a stylistic choice, not a space issue.
    if AOptions.SpaceBeforePunct then
      for K := 0 to High(PunctArray) do
      begin
        PunctChar := PunctArray[K];
        if (CountPunct(ATrans, PunctChar) <= CountPunct(ASrc, PunctChar)) and
          (CountPunctWithSpaceBefore(ATrans, PunctChar) > CountPunctWithSpaceBefore(ASrc, PunctChar)) then
          Msgs.Add(Format(rsQASpaceBeforePunctuation, [PunctChar]));
      end;

    // Missing space after punctuation: report only when the translation keeps
    // at least as many punctuation marks as the source, but fewer of them have
    // a space after. If the translation dropped the punctuation, this check
    // stays silent - it is a different kind of issue.

    // For dots the sentence-ending heuristic is used to ignore abbreviation
    // dots like "e.g." and decimal dots like "1.5". RTL scripts (Hebrew,
    // Arabic, etc.) have no uppercase letters, so the sentence-ending
    // heuristic cannot work there - the dot check is skipped entirely for
    // such languages.
    if AOptions.SpaceAfterPunct then
    begin
      RTLSource := IsRTLText(ASrc);
      for K := 0 to High(PunctArray) do
      begin
        PunctChar := PunctArray[K];
        if PunctChar = '.' then
        begin
          // Skip the dot check when either side uses a script without
          // uppercase letters (RTL or case-less like CJK, Korean, Thai)
          if RTLSource or IsRTLText(ATrans) or IsCaseLessText(ASrc) or IsCaseLessText(ATrans) then
            Continue;
          if (CountPunct(ATrans, '.') >= CountPunct(ASrc, '.')) and (CountSentenceEndingDots(ATrans) <
            CountSentenceEndingDots(ASrc)) then
            Msgs.Add(Format(rsQASpaceMissingAfterPunctuation, [PunctChar]));
        end
        else
        begin
          if (CountPunct(ATrans, PunctChar) >= CountPunct(ASrc, PunctChar)) and
            (CountPunctWithSepAfter(ATrans, PunctChar) < CountPunctWithSpaceAfter(ASrc, PunctChar)) then
            Msgs.Add(Format(rsQASpaceMissingAfterPunctuation, [PunctChar]));
        end;
      end;
    end;

    // 4. End punctuation check
    if AOptions.PunctEnd and (Length(ASrc) > 0) and (Length(ATrans) > 0) then
    begin
      SrcChar := GetEndPunctuation(ASrc);
      TransChar := GetEndPunctuation(ATrans);
      // An ASCII semicolon at the end of the translation is the standard
      // way Greek typography represents the question mark, so a question
      // mark on one side and a semicolon on the other are treated as
      // equivalent for this check only. The U+037E Greek question mark is
      // handled separately in GetEndPunctuation and normalizes to '?'.
      if ((SrcChar = '?') and (TransChar = ';')) or ((SrcChar = ';') and (TransChar = '?')) then
        Exit;
      if ((SrcChar in ['.', '!', '?', ':']) or (TransChar in ['.', '!', '?', ':'])) and (SrcChar <> TransChar) then
        Msgs.Add(Format(rsQAPunctuationEndMismatch, [SrcChar, TransChar]));
    end;

    // 5. Bracket matching
    if AOptions.PunctBracket then
    begin
      SrcBrackets := ExtractBrackets(ASrc);
      TransBrackets := ExtractBrackets(ATrans);
      if SrcBrackets <> TransBrackets then
        Msgs.Add(Format(rsQAPunctuationBracketMismatch, [SrcBrackets, TransBrackets]));
    end;

    // Copy results into the dynamic array
    SetLength(Result, Msgs.Count);
    for I := 0 to Msgs.Count - 1 do
      Result[I] := Msgs[I];
  finally
    if SrcPH <> nil then
      SrcPH.Free;
    if TransPH <> nil then
      TransPH.Free;
    Msgs.Free;
  end;
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
  FQACheckResults := nil;
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
  FQACheckResults := nil;
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
  Result := not IsFuzzy and ((MsgStrSimple <> '') or (MsgStrSimple = MsgId)) and (Length(FQACheckResults) = 0);
end;

{QA check implementation}

procedure TPOEntry.ClearQACheckResults;
begin
  FQACheckResults := nil;
end;

procedure TPOEntry.AddQACheckResult(const AMessage: string);
var
  Len: integer;
begin
  Len := Length(FQACheckResults);
  SetLength(FQACheckResults, Len + 1);
  FQACheckResults[Len] := AMessage;
end;

function TPOEntry.GetQACheckResults: TStringArray;
begin
  Result := FQACheckResults;
end;

procedure TPOEntry.CheckQA(const AOptions: TQACheckOptions);
var
  I, J, FormCount: integer;
  FormText: string;
  FormMsgs: TStringArray;
  Prefix: string;
begin
  ClearQACheckResults;

  // Skip obsolete entries and the header
  if FObsolete or (FMsgId = '') then
    Exit;

  // 1. Plural forms count check
  if AOptions.PluralCount and IsPlural and (AOptions.PluralFormsCount > 0) and (MsgStrCount > 0) then
    if MsgStrCount <> AOptions.PluralFormsCount then
      AddQACheckResult(Format(rsQAPluralFormsMismatch, [AOptions.PluralFormsCount, MsgStrCount]));

  // 2. Determine how many translations to check
  if IsPlural then
  begin
    FormCount := MsgStrCount;
    if FormCount = 0 then
      Exit;
  end
  else
    FormCount := 1;

  for I := 0 to FormCount - 1 do
  begin
    if IsPlural then
      FormText := MsgStr[I]
    else
      FormText := MsgStrSimple;

    if FormText = '' then
      Continue;

    FormMsgs := RunQAChecksOnText(FMsgId, FormText, AOptions);
    if IsPlural and (FormCount > 1) then
      Prefix := Format('[form %d] ', [I])
    else
      Prefix := '';
    for J := 0 to Length(FormMsgs) - 1 do
      AddQACheckResult(Prefix + FormMsgs[J]);
  end;
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

  // QA checks are enabled by default
  FQACheckPlaceholderMissing := True;
  FQACheckPlaceholderExtra := True;
  FQACheckPluralCount := True;
  FQACheckCaseFirstChar := True;
  FQACheckCaseAllUpper := True;
  FQACheckSpaceLeading := True;
  FQACheckSpaceTrailing := True;
  FQACheckSpaceDouble := True;
  FQACheckSpaceBeforePunct := True;
  FQACheckSpaceAfterPunct := True;
  FQACheckPunctEnd := True;
  FQACheckPunctBracket := True;

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

  // 5. Previous (after flags) - only output when entry is fuzzy
  if Entry.IsFuzzy then
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

{QA check over the whole file}

function TPOFile.GetQACheckOptions: TQACheckOptions;
begin
  Result.PluralFormsCount := PluralFormsCount;
  if Result.PluralFormsCount = 0 then
    Result.PluralFormsCount := 2; // safe default for languages with no header

  Result.PlaceholderMissing := FQACheckPlaceholderMissing;
  Result.PlaceholderExtra := FQACheckPlaceholderExtra;
  Result.PluralCount := FQACheckPluralCount;
  Result.CaseFirstChar := FQACheckCaseFirstChar;
  Result.CaseAllUpper := FQACheckCaseAllUpper;
  Result.SpaceLeading := FQACheckSpaceLeading;
  Result.SpaceTrailing := FQACheckSpaceTrailing;
  Result.SpaceDouble := FQACheckSpaceDouble;
  Result.SpaceBeforePunct := FQACheckSpaceBeforePunct;
  Result.SpaceAfterPunct := FQACheckSpaceAfterPunct;
  Result.PunctEnd := FQACheckPunctEnd;
  Result.PunctBracket := FQACheckPunctBracket;
end;

procedure TPOFile.CheckEntryQA(AEntry: TPOEntry);
begin
  if Assigned(AEntry) then
    AEntry.CheckQA(GetQACheckOptions);
end;

procedure TPOFile.CheckAllQA;
var
  I: integer;
  Options: TQACheckOptions;
begin
  Options := GetQACheckOptions;
  for I := 0 to FEntries.Count - 1 do
    TPOEntry(FEntries[I]).CheckQA(Options);
end;

class function TPOFile.ComputeStatusFromModel(APoFile: TPOFile): TPoFileStatus;
var
  i, j: integer;
  Entry: TPOEntry;
  HasEmpty: boolean;
begin
  HasEmpty := False;
  for i := 1 to APoFile.Entries.Count - 1 do
  begin
    Entry := APoFile.Entries[i];
    if Entry.Obsolete then
      Continue;
    if Entry.IsFuzzy then
      Exit(psFuzzy);
    if not HasEmpty then
    begin
      if Entry.IsPlural then
      begin
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
end;

class function TPOFile.GetFileStatus(const AFileName: string): TPoFileStatus;
var
  Po: TPOFile;
begin
  Po := TPOFile.Create;
  try
    Po.LoadFromFile(AFileName);
    Result := ComputeStatusFromModel(Po);
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

procedure TPOFile.SynchronizeToFile(const AFileName: string; AUpdateHeader: boolean);
var
  Target: TPOFile;
  NewList: TPOEntryList;
  TargetEntry, SrcEntry, NewEntry: TPOEntry;
  i, k: integer;
  Found, KeysChanged: boolean;
  SrcHeaderLines, TgtHeaderLines: TStringList;
  Key, Value: string;
  EqPos: integer;

  function GetReferenceLines(E: TPOEntry): TStringList;
  var
    m: integer;
  begin
    Result := TStringList.Create;
    Result.Duplicates := dupIgnore;
    Result.Sorted := True;
    for m := 0 to E.Comments.Count - 1 do
      if TPOComment(E.Comments[m]).CommentType = poctReference then
        Result.Add(TPOComment(E.Comments[m]).Text);
  end;

  function HaveCommonReference(E1, E2: TPOEntry): boolean;
  var
    R1, R2: TStringList;
    s: string;
  begin
    Result := False;
    R1 := GetReferenceLines(E1);
    R2 := GetReferenceLines(E2);
    try
      for s in R1 do
        if R2.IndexOf(s) >= 0 then
          Exit(True);
    finally
      R1.Free;
      R2.Free;
    end;
  end;

  procedure AddCopyWithTranslations(Source: TPOEntry; const ReplaceMsgStrFrom: TPOEntry; AKeysChanged: boolean);
  var
    NewEntry: TPOEntry;
    n, nn: integer;
    NewMsgStr: TStringList;
  begin
    NewEntry := TPOEntry.Create;
    NewEntry.Assign(Source);
    if ReplaceMsgStrFrom <> nil then
    begin
      nn := Source.MsgStrCount;
      if nn = 0 then nn := 1;
      NewMsgStr := TStringList.Create;
      try
        for n := 0 to nn - 1 do
          if n < ReplaceMsgStrFrom.MsgStrCount then
            NewMsgStr.Add(ReplaceMsgStrFrom.MsgStr[n])
          else
            NewMsgStr.Add('');
        NewEntry.MsgStrList := NewMsgStr;
        if (Source.MsgId = '') and (ReplaceMsgStrFrom.MsgId = '') then
          NewEntry.MsgStrSimple := ReplaceMsgStrFrom.MsgStrSimple;
      finally
        NewMsgStr.Free;
      end;

      if AKeysChanged then
      begin
        NewEntry.IsFuzzy := True;
        NewEntry.DeleteCommentsOfType(poctPrevious);
        if Source.MsgCtxt <> ReplaceMsgStrFrom.MsgCtxt then
          NewEntry.AddComment(poctPrevious, 'msgctxt "' + EscapeString(ReplaceMsgStrFrom.MsgCtxt) + '"');
        if Source.MsgId <> ReplaceMsgStrFrom.MsgId then
          NewEntry.AddComment(poctPrevious, 'msgid "' + EscapeString(ReplaceMsgStrFrom.MsgId) + '"');
        if (Source.MsgIdPlural <> '') or (ReplaceMsgStrFrom.MsgIdPlural <> '') then
          if Source.MsgIdPlural <> ReplaceMsgStrFrom.MsgIdPlural then
            NewEntry.AddComment(poctPrevious, 'msgid_plural "' + EscapeString(ReplaceMsgStrFrom.MsgIdPlural) + '"');
      end;
    end;
    NewList.Add(NewEntry);
  end;

  // Parse header text (MsgStrSimple) into TStringList of "Key=Value"
  function ParseHeaderText(const HeaderText: string): TStringList;
  var
    Lines: TStringList;
    s, k, v: string;
    p: integer;
  begin
    Result := TStringList.Create;
    Lines := TStringList.Create;
    try
      Lines.Text := HeaderText;
      for s in Lines do
      begin
        if s = '' then Continue;
        p := Pos(': ', s);
        if p > 0 then
        begin
          k := Trim(Copy(s, 1, p - 1));
          v := Trim(Copy(s, p + 2, MaxInt));
          Result.Values[k] := v;
        end
        else
          Result.Add(s);   // malformed line, keep as is
      end;
    finally
      Lines.Free;
    end;
  end;

  // Convert "Key=Value" list back to header text "Key: Value\n"
  function FormatHeaderText(const HeaderValues: TStrings): string;
  var
    i: integer;
    s, k, v: string;
    EqPos: integer;
  begin
    Result := '';
    for i := 0 to HeaderValues.Count - 1 do
    begin
      s := HeaderValues[i];
      EqPos := Pos('=', s);
      if EqPos > 0 then
      begin
        k := Copy(s, 1, EqPos - 1);
        v := Copy(s, EqPos + 1, MaxInt);
        Result := Result + k + ': ' + v + sLineBreak;
      end
      else
        Result := Result + s + sLineBreak;
    end;
    if Result <> '' then
      SetLength(Result, Length(Result) - Length(sLineBreak));
  end;

begin
  if not FileExists(AFileName) then
    raise Exception.CreateFmt('Target file not found: %s', [AFileName]);

  Target := TPOFile.Create;
  try
    Target.LoadFromFile(AFileName);

    if Target.Entries.Count = 0 then
      raise Exception.CreateFmt('Target file "%s" contains no entries.', [AFileName]);
    if Self.Entries.Count = 0 then
      raise Exception.Create('Current PO file has no entries.');

    NewList := TPOEntryList.Create(True);
    try
      // Handle header entry (msgid='')
      TargetEntry := Target.Entries[0];
      if TargetEntry.MsgId = '' then
      begin
        SrcEntry := FindEntry('');
        if AUpdateHeader then
        begin
          if SrcEntry <> nil then
          begin
            SrcHeaderLines := ParseHeaderText(SrcEntry.MsgStrSimple);
            TgtHeaderLines := ParseHeaderText(TargetEntry.MsgStrSimple);
            try
              for k := 0 to TgtHeaderLines.Count - 1 do
              begin
                EqPos := Pos('=', TgtHeaderLines[k]);
                if EqPos > 0 then
                begin
                  Key := Copy(TgtHeaderLines[k], 1, EqPos - 1);
                  Value := Copy(TgtHeaderLines[k], EqPos + 1, MaxInt);
                  SrcHeaderLines.Values[Key] := Value;
                end;
              end;
              NewEntry := TPOEntry.Create;
              NewEntry.Assign(SrcEntry);
              NewEntry.MsgStrSimple := FormatHeaderText(SrcHeaderLines);
              NewList.Add(NewEntry);
            finally
              SrcHeaderLines.Free;
              TgtHeaderLines.Free;
            end;
          end
          else
            AddCopyWithTranslations(TargetEntry, nil, False);
        end
        else
        begin
          if SrcEntry <> nil then
            AddCopyWithTranslations(SrcEntry, nil, False)
          else
            AddCopyWithTranslations(TargetEntry, nil, False);
        end;
        k := 1;   // start of translatable entries
      end
      else
        k := 0;

      // Process translatable entries
      for i := k to Target.Entries.Count - 1 do
      begin
        TargetEntry := Target.Entries[i];
        SrcEntry := nil;
        KeysChanged := False;

        // 1. Common reference
        Found := False;
        for k := 1 to Self.Entries.Count - 1 do
          if (Self.Entries[k].MsgId <> '') and HaveCommonReference(TargetEntry, Self.Entries[k]) then
          begin
            SrcEntry := Self.Entries[k];
            Found := True;
            Break;
          end;

        // 2. Exact (msgctxt+msgid)
        if not Found then
          for k := 1 to Self.Entries.Count - 1 do
            if (Self.Entries[k].MsgId <> '') and (Self.Entries[k].MsgId = TargetEntry.MsgId) and
              (Self.Entries[k].MsgCtxt = TargetEntry.MsgCtxt) then
            begin
              SrcEntry := Self.Entries[k];
              Found := True;
              Break;
            end;

        // 3. Msgid only (changed context)
        if not Found then
          for k := 1 to Self.Entries.Count - 1 do
            if (Self.Entries[k].MsgId <> '') and (Self.Entries[k].MsgId = TargetEntry.MsgId) then
            begin
              SrcEntry := Self.Entries[k];
              Found := True;
              KeysChanged := True;
              Break;
            end;

        if Found and not KeysChanged then
          if (SrcEntry.MsgCtxt <> TargetEntry.MsgCtxt) or (SrcEntry.MsgId <> TargetEntry.MsgId) or
            (SrcEntry.MsgIdPlural <> TargetEntry.MsgIdPlural) then
            KeysChanged := True;

        if Found then
          AddCopyWithTranslations(TargetEntry, SrcEntry, KeysChanged)
        else
          AddCopyWithTranslations(TargetEntry, nil, False);
      end;

      FEntries.Clear;
      for i := 0 to NewList.Count - 1 do
        FEntries.Add(NewList[i]);
      NewList.OwnsObjects := False;
    finally
      NewList.Free;
    end;
  finally
    Target.Free;
  end;
end;

procedure TPOFile.ApplyDefaultHeaders(const ALanguage: string; const AGenerator: string);
var
  ExistingHeaders: TStrings;
  NewHeaders: TStringList;
  DefaultValues: array[TPOHeader] of string;
  h: TPOHeader;
  OldValue: string;
begin
  for h := Low(TPOHeader) to High(TPOHeader) do
    DefaultValues[h] := '';

  DefaultValues[hMIMEVersion] := '1.0';
  DefaultValues[hContentType] := 'text/plain; charset=UTF-8';
  DefaultValues[hContentTransferEncoding] := '8bit';
  DefaultValues[hXGenerator] := AGenerator;

  ExistingHeaders := GetHeaders;
  NewHeaders := TStringList.Create;
  try
    // Rebuild the header block in the canonical order from POHeaderNames,
    // keeping the values that were already present in the loaded POT
    for h := Low(TPOHeader) to High(TPOHeader) do
    begin
      OldValue := Trim(ExistingHeaders.Values[POHeaderNames[h]]);
      if (OldValue <> '') and (h <> hXGenerator) then
        NewHeaders.Values[POHeaderNames[h]] := OldValue
      else
        NewHeaders.Values[POHeaderNames[h]] := DefaultValues[h];
    end;

    // Force the language when explicitly requested
    if ALanguage <> '' then
      NewHeaders.Values['Language'] := ALanguage;

    SetHeaders(NewHeaders);
  finally
    NewHeaders.Free;
    ExistingHeaders.Free;
  end;
end;

{%EndRegion}

end.
