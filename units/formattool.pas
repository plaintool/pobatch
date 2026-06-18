//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit formattool;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  SysUtils,
  Graphics,
  Math,
  LCLIntf,
  LCLType,
  LazUTF8;

function EndsWithLineBreak(const Buffer: TBytes): boolean;

function EndsWithLineBreak(const FileName: string): boolean;

function LoadFileAsBytes(const FileName: string): TBytes;

function GetContrastTextColor(BackColor, FontColor: TColor; MidLevel: integer = 128): TColor;

function BlendColors(Color1, Color2: TColor; Intensity: integer): TColor;

procedure DrawHighlightedText(ACanvas: TCanvas; ARect: TRect; aColorHighlight, aColorLineBreak: TColor;
  const AText, AFilterText: string; AWordWrap: boolean = False; AShowLineBreaks: boolean = False; ABiDiRightToLeft: boolean = False);

implementation

function EndsWithLineBreak(const Buffer: TBytes): boolean;
begin
  Result := False;
  if Length(Buffer) = 0 then Exit;

  if (Buffer[High(Buffer)] = byte(#10)) or (Buffer[High(Buffer)] = byte(#13)) then
    Result := True;
end;

function EndsWithLineBreak(const FileName: string): boolean;
var
  Bytes: TBytes;
begin
  Bytes := LoadFileAsBytes(FileName);
  Result := EndsWithLineBreak(Bytes);
end;

function LoadFileAsBytes(const FileName: string): TBytes;
var
  FS: TFileStream;
begin
  Result := nil;
  SetLength(Result, 0);
  if not FileExists(FileName) then Exit;

  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, FS.Size);
    if FS.Size > 0 then
      FS.ReadBuffer(Result[0], FS.Size);
  finally
    FS.Free;
  end;
end;

function BlendColors(Color1, Color2: TColor; Intensity: integer): TColor;
var
  R1, G1, B1: byte;
  R2, G2, B2: byte;
  Alpha: double;
begin
  // Return original color if no blending needed
  if Intensity <= 0 then
    Exit(Color1);

  // Return full blend color if maximum intensity
  if Intensity >= 100 then
    Exit(Color2);

  // Calculate blend factor (0.0 to 1.0)
  Alpha := Intensity / 100.0;

  // Extract RGB components from first color
  Color1 := ColorToRGB(Color1);
  R1 := GetRValue(Color1);
  G1 := GetGValue(Color1);
  B1 := GetBValue(Color1);

  // Extract RGB components from second color
  Color2 := ColorToRGB(Color2);
  R2 := GetRValue(Color2);
  G2 := GetGValue(Color2);
  B2 := GetBValue(Color2);

  // Linear interpolation: result = color1 * (1-alpha) + color2 * alpha
  Result := RGBToColor(Round(R1 * (1 - Alpha) + R2 * Alpha), Round(G1 * (1 - Alpha) + G2 * Alpha),
    Round(B1 * (1 - Alpha) + B2 * Alpha));
end;

function GetContrastTextColor(BackColor, FontColor: TColor; MidLevel: integer = 128): TColor;
var
  Rb, Gb, Bb: byte;
  Rf, Gf, Bf: byte;
  BrightnessBack, BrightnessFont: Double;
begin
  // Clamp MidLevel to valid byte range
  if MidLevel < 0 then MidLevel := 0;
  if MidLevel > 255 then MidLevel := 255;

  // Resolve system colors to actual RGB
  BackColor := ColorToRGB(BackColor);
  FontColor := ColorToRGB(FontColor);

  Rb := GetRValue(BackColor);
  Gb := GetGValue(BackColor);
  Bb := GetBValue(BackColor);

  Rf := GetRValue(FontColor);
  Gf := GetGValue(FontColor);
  Bf := GetBValue(FontColor);

  // Perceived luminance using ITU-R BT.709 coefficients
  BrightnessBack := 0.299 * Rb + 0.587 * Gb + 0.114 * Bb;
  BrightnessFont := 0.299 * Rf + 0.587 * Gf + 0.114 * Bf;

  // If both colors are on the same side of the brightness threshold,
  // invert the font color to ensure contrast; otherwise keep it.
  if (BrightnessBack < MidLevel) = (BrightnessFont < MidLevel) then
    Result := RGBToColor(255 - Rf, 255 - Gf, 255 - Bf)
  else
    Result := FontColor;
end;

procedure DrawHighlightedText(ACanvas: TCanvas; ARect: TRect; aColorHighlight, aColorLineBreak: TColor;
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
        ACanvas.Font.Color := GetContrastTextColor(aColorHighlight, FontColor);
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
      ACanvas.Font.Color := GetContrastTextColor(ACanvas.Brush.Color,  AColorLineBreak);
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
