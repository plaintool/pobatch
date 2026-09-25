//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit PoCheck;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  Classes,
  SysUtils;

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
  rsQANewlineLeadingMismatch = 'Leading newline mismatch';
  rsQANewlineTrailingMismatch = 'Trailing newline mismatch';

type

  // Options that control which QA checks are enabled
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
    Newlines: boolean;
    FrenchSpacing: boolean;
  end;

  // Stateless class that performs all QA checks on source/translation pairs.
  // No instance is required - callers use the class methods directly.
  TPOChecker = class
  private
    // Text utility helpers
    class function IsRTLText(const S: string): boolean;
    class function IsCaseLessText(const S: string): boolean;
    class function GetEndPunctuation(const S: string): char;
    class function ExtractBrackets(const S: string): string;
    class function ExtractPlaceholders(const S: string): TStringList;
    class function IsAttachedParticleStart(const S: string; APos: integer): boolean;
    class function CountPunctWithSepAfter(const AText: string; APunct: char): integer;
    class function CountPunctWithSpaceBefore(const AText: string; APunct: char): integer;
    class function CountPunctWithSpaceAfter(const AText: string; APunct: char): integer;
    class function IsQuotedChar(const AText: string; APos: integer): boolean;
    class function CountPunct(const AText: string; APunct: char): integer;
    class function IsUpperLetter(const S: string; APos: integer): boolean;
    class function IsInvertedPunct(const S: string; APos: integer): boolean;
    class function CountSentenceEndingDots(const S: string): integer;

    // Individual check groups, each one appends its messages to AMsgs
    class procedure CheckPlaceholders(const ASrc, ATrans: string; const AOptions: TQACheckOptions; AMsgs: TStrings);
    class procedure CheckCase(const ASrc, ATrans: string; const AOptions: TQACheckOptions; AMsgs: TStrings);
    class procedure CheckSpaces(const ASrc, ATrans: string; const AOptions: TQACheckOptions; AMsgs: TStrings);
    class procedure CheckEndPunctuation(const ASrc, ATrans: string; const AOptions: TQACheckOptions;
      AMsgs: TStrings; out ASkipRest: boolean);
    class procedure CheckBrackets(const ASrc, ATrans: string; const AOptions: TQACheckOptions; AMsgs: TStrings);
    class procedure CheckNewlines(const ASrc, ATrans: string; const AOptions: TQACheckOptions; AMsgs: TStrings);
  public
    // Run all enabled checks on a single source/translation pair.
    // Returns the list of messages, empty when no issues are found.
    class function RunOnText(const ASrc, ATrans: string; const AOptions: TQACheckOptions): TStringArray;
  end;

implementation

{%Region -fold TPOChecker text helpers}

// Determine whether the text contains characters from a right-to-left
// script. The whole string is scanned, so a mix of ASCII and Hebrew or
// Arabic is still reported as RTL - which is what the QA checks need,
// because the sentence-ending dot heuristic based on uppercase letters
// cannot be applied to RTL scripts. Other RTL scripts (Syriac, Thaana,
// N'Ko, etc.) can be added here later if needed.
class function TPOChecker.IsRTLText(const S: string): boolean;
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
class function TPOChecker.GetEndPunctuation(const S: string): char;
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
class function TPOChecker.IsCaseLessText(const S: string): boolean;
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
class function TPOChecker.ExtractBrackets(const S: string): string;
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
class function TPOChecker.ExtractPlaceholders(const S: string): TStringList;
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
class function TPOChecker.IsAttachedParticleStart(const S: string; APos: integer): boolean;
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
class function TPOChecker.CountPunctWithSepAfter(const AText: string; APunct: char): integer;
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

// Count occurrences of APunct directly preceded by a whitespace character
class function TPOChecker.CountPunctWithSpaceBefore(const AText: string; APunct: char): integer;
var
  K: integer;
begin
  Result := 0;
  for K := 2 to Length(AText) do
    if (AText[K] = APunct) and (AText[K - 1] in [' ', #9, #10, #13]) then
      Inc(Result);
end;

// Count occurrences of APunct directly followed by a whitespace character
class function TPOChecker.CountPunctWithSpaceAfter(const AText: string; APunct: char): integer;
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
class function TPOChecker.IsQuotedChar(const AText: string; APos: integer): boolean;
begin
  Result := False;
  if (APos < 2) or (APos >= Length(AText)) then
    Exit;
  if (AText[APos - 1] in ['''', '"']) and (AText[APos + 1] in ['''', '"']) then
    Result := True;
end;

// Count all occurrences of APunct in AText, skipping quoted characters
// like '!' or "!" that reference the character itself
class function TPOChecker.CountPunct(const AText: string; APunct: char): integer;
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
class function TPOChecker.IsUpperLetter(const S: string; APos: integer): boolean;
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
class function TPOChecker.IsInvertedPunct(const S: string; APos: integer): boolean;
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
class function TPOChecker.CountSentenceEndingDots(const S: string): integer;
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

{%EndRegion}

{%Region -fold TPOChecker check groups}

// Check placeholder presence and absence of extras
class procedure TPOChecker.CheckPlaceholders(const ASrc, ATrans: string; const AOptions: TQACheckOptions; AMsgs: TStrings);
var
  SrcPH, TransPH: TStringList;
  I: integer;
begin
  if not (AOptions.PlaceholderMissing or AOptions.PlaceholderExtra) then
    Exit;
  SrcPH := ExtractPlaceholders(ASrc);
  TransPH := ExtractPlaceholders(ATrans);
  try
    if AOptions.PlaceholderMissing then
      for I := 0 to SrcPH.Count - 1 do
        if TransPH.IndexOf(SrcPH[I]) < 0 then
          AMsgs.Add(Format(rsQAPlaceholderMissing, [SrcPH[I]]));
    if AOptions.PlaceholderExtra then
      for I := 0 to TransPH.Count - 1 do
        if SrcPH.IndexOf(TransPH[I]) < 0 then
          AMsgs.Add(Format(rsQAPlaceholderExtra, [TransPH[I]]));
  finally
    SrcPH.Free;
    TransPH.Free;
  end;
end;

// Check first character and full uppercase case mismatches
class procedure TPOChecker.CheckCase(const ASrc, ATrans: string; const AOptions: TQACheckOptions; AMsgs: TStrings);
var
  I: integer;
  SrcChar, TransChar: char;
  SrcHasLetters, SrcAllUpper, HasLower: boolean;
begin
  if not (AOptions.CaseFirstChar or AOptions.CaseAllUpper) then
    Exit;
  if (Length(ASrc) = 0) or (Length(ATrans) = 0) then
    Exit;

  if AOptions.CaseFirstChar then
  begin
    SrcChar := ASrc[1];
    TransChar := ATrans[1];
    if SrcChar in ['A'..'Z'] then
    begin
      if TransChar in ['a'..'z'] then
        AMsgs.Add(Format(rsQACaseMismatch, [SrcChar, TransChar]));
    end
    else if SrcChar in ['a'..'z'] then
    begin
      if TransChar in ['A'..'Z'] then
        AMsgs.Add(Format(rsQACaseMismatch, [SrcChar, TransChar]));
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
        AMsgs.Add(rsQACaseMismatchUpper);
    end;
  end;
end;

// Check leading, trailing and double spaces, plus spaces around punctuation
class procedure TPOChecker.CheckSpaces(const ASrc, ATrans: string; const AOptions: TQACheckOptions; AMsgs: TStrings);
const
  PunctArray: array[0..5] of char = (',', '.', ';', ':', '!', '?');
var
  K: integer;
  PunctChar: char;
  RTLSource: boolean;
begin
  if AOptions.SpaceLeading then
    if (Length(ATrans) > 0) and (ATrans[1] = ' ') and not ((Length(ASrc) > 0) and (ASrc[1] = ' ')) then
      AMsgs.Add(rsQASpaceLeading);
  if AOptions.SpaceTrailing then
    if (Length(ATrans) > 0) and (ATrans[Length(ATrans)] = ' ') and not ((Length(ASrc) > 0) and (ASrc[Length(ASrc)] = ' ')) then
      AMsgs.Add(rsQASpaceTrailing);
  if AOptions.SpaceDouble then
    if (Pos('  ', ATrans) > 0) and (Pos('  ', ASrc) = 0) then
      AMsgs.Add(rsQASpaceDouble);

  // Space before punctuation: report only when the translation keeps at
  // least as many punctuation marks as the source, but puts more whitespace
  // before them. If the translation dropped the punctuation entirely, that
  // is a stylistic choice, not a space issue.
  // For French (except Canadian French), a space before double punctuation
  // (?, !, ;, :) is correct and must not be reported.
  if AOptions.SpaceBeforePunct then
    for K := 0 to High(PunctArray) do
    begin
      PunctChar := PunctArray[K];
      if AOptions.FrenchSpacing and (PunctChar in [';', ':', '!', '?']) then
        Continue;
      if (CountPunct(ATrans, PunctChar) <= CountPunct(ASrc, PunctChar)) and
        (CountPunctWithSpaceBefore(ATrans, PunctChar) > CountPunctWithSpaceBefore(ASrc, PunctChar)) then
        AMsgs.Add(Format(rsQASpaceBeforePunctuation, [PunctChar]));
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
          AMsgs.Add(Format(rsQASpaceMissingAfterPunctuation, [PunctChar]));
      end
      else
      begin
        if (CountPunct(ATrans, PunctChar) >= CountPunct(ASrc, PunctChar)) and
          (CountPunctWithSepAfter(ATrans, PunctChar) < CountPunctWithSpaceAfter(ASrc, PunctChar)) then
          AMsgs.Add(Format(rsQASpaceMissingAfterPunctuation, [PunctChar]));
      end;
    end;
  end;
end;

// Check matching end punctuation. When the source ends with a question mark
// and the translation with an ASCII semicolon (standard Greek typography)
// or vice versa, no message is produced and the remaining checks are skipped
// to preserve the original behaviour.
class procedure TPOChecker.CheckEndPunctuation(const ASrc, ATrans: string; const AOptions: TQACheckOptions;
  AMsgs: TStrings; out ASkipRest: boolean);
var
  SrcChar, TransChar: char;
begin
  ASkipRest := False;
  if not AOptions.PunctEnd then
    Exit;
  if (Length(ASrc) = 0) or (Length(ATrans) = 0) then
    Exit;

  SrcChar := GetEndPunctuation(ASrc);
  TransChar := GetEndPunctuation(ATrans);
  // An ASCII semicolon at the end of the translation is the standard
  // way Greek typography represents the question mark, so a question
  // mark on one side and a semicolon on the other are treated as
  // equivalent for this check only. The U+037E Greek question mark is
  // handled separately in GetEndPunctuation and normalizes to '?'.
  if ((SrcChar = '?') and (TransChar = ';')) or ((SrcChar = ';') and (TransChar = '?')) then
  begin
    ASkipRest := True;
    Exit;
  end;
  if ((SrcChar in ['.', '!', '?', ':']) or (TransChar in ['.', '!', '?', ':'])) and (SrcChar <> TransChar) then
    AMsgs.Add(Format(rsQAPunctuationEndMismatch, [SrcChar, TransChar]));
end;

// Check that the translation preserves the bracket set of the source
class procedure TPOChecker.CheckBrackets(const ASrc, ATrans: string; const AOptions: TQACheckOptions; AMsgs: TStrings);
var
  SrcBrackets, TransBrackets: string;
begin
  if not AOptions.PunctBracket then
    Exit;
  SrcBrackets := ExtractBrackets(ASrc);
  TransBrackets := ExtractBrackets(ATrans);
  if SrcBrackets <> TransBrackets then
    AMsgs.Add(Format(rsQAPunctuationBracketMismatch, [SrcBrackets, TransBrackets]));
end;

// Check that the translation preserves leading and trailing newlines of the
// source. A newline at the start or at the end of the source string must be
// present in the translation as well, and vice versa. Both LF and CR are
// treated as newline characters.
class procedure TPOChecker.CheckNewlines(const ASrc, ATrans: string; const AOptions: TQACheckOptions; AMsgs: TStrings);
var
  SrcLead, SrcTrail, TransLead, TransTrail: boolean;
begin
  if not AOptions.Newlines then
    Exit;
  if (Length(ASrc) = 0) or (Length(ATrans) = 0) then
    Exit;

  SrcLead := (ASrc[1] = #10) or (ASrc[1] = #13);
  SrcTrail := (ASrc[Length(ASrc)] = #10) or (ASrc[Length(ASrc)] = #13);
  TransLead := (ATrans[1] = #10) or (ATrans[1] = #13);
  TransTrail := (ATrans[Length(ATrans)] = #10) or (ATrans[Length(ATrans)] = #13);

  if SrcLead <> TransLead then
    AMsgs.Add(rsQANewlineLeadingMismatch);
  if SrcTrail <> TransTrail then
    AMsgs.Add(rsQANewlineTrailingMismatch);
end;

{%EndRegion}

{%Region -fold TPOChecker public API}

class function TPOChecker.RunOnText(const ASrc, ATrans: string; const AOptions: TQACheckOptions): TStringArray;
var
  Msgs: TStringList;
  I: integer;
  SkipRest: boolean;
begin
  Result := nil;
  SetLength(Result, 0);
  Msgs := TStringList.Create;
  try
    CheckPlaceholders(ASrc, ATrans, AOptions, Msgs);
    CheckCase(ASrc, ATrans, AOptions, Msgs);
    CheckSpaces(ASrc, ATrans, AOptions, Msgs);
    CheckNewlines(ASrc, ATrans, AOptions, Msgs);
    CheckEndPunctuation(ASrc, ATrans, AOptions, Msgs, SkipRest);
    if not SkipRest then
      CheckBrackets(ASrc, ATrans, AOptions, Msgs);

    SetLength(Result, Msgs.Count);
    for I := 0 to Msgs.Count - 1 do
      Result[I] := Msgs[I];
  finally
    Msgs.Free;
  end;
end;

{%EndRegion}

end.
