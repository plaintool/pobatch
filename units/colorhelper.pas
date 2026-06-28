//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit colorhelper;

{$mode objfpc}{$H+}
{$modeswitch typehelpers}

interface

uses
  Graphics,
  LCLIntf;

type
  TColorHelper = type helper for TColor
  public
    function BlendColor(AColor: TColor; Intensity: integer): TColor;
    function InvertColor(ABackColor: TColor; MidLevel: integer = 128; AOnlyDarkBackground: boolean = False): TColor;
  end;

implementation

{ TColorHelper }

function TColorHelper.BlendColor(AColor: TColor; Intensity: integer): TColor;
var
  R1, G1, B1: byte;
  R2, G2, B2: byte;
  Alpha: double;
begin
  // Return original color if no blending needed
  if Intensity <= 0 then
    Exit(Self);

  // Return full blend color if maximum intensity
  if Intensity >= 100 then
    Exit(AColor);

  // Calculate blend factor (0.0 to 1.0)
  Alpha := Intensity / 100.0;

  // Extract RGB components from first color
  Self := ColorToRGB(Self);
  R1 := GetRValue(Self);
  G1 := GetGValue(Self);
  B1 := GetBValue(Self);

  // Extract RGB components from second color
  AColor := ColorToRGB(AColor);
  R2 := GetRValue(AColor);
  G2 := GetGValue(AColor);
  B2 := GetBValue(AColor);

  // Linear interpolation: result = Self * (1-alpha) + AColor * alpha
  Result := RGBToColor(Round(R1 * (1 - Alpha) + R2 * Alpha), Round(G1 * (1 - Alpha) + G2 * Alpha),
    Round(B1 * (1 - Alpha) + B2 * Alpha));
end;

function TColorHelper.InvertColor(ABackColor: TColor; MidLevel: integer = 128; AOnlyDarkBackground: boolean = False): TColor;
var
  Rb, Gb, Bb: byte;
  Rf, Gf, Bf: byte;
  BrightnessBack, BrightnessFont: double;
begin
  // Clamp MidLevel to valid byte range
  if MidLevel < 0 then MidLevel := 0;
  if MidLevel > 255 then MidLevel := 255;

  // Resolve system colors to actual RGB
  ABackColor := ColorToRGB(ABackColor);
  Self := ColorToRGB(Self);

  Rb := GetRValue(ABackColor);
  Gb := GetGValue(ABackColor);
  Bb := GetBValue(ABackColor);

  Rf := GetRValue(Self);
  Gf := GetGValue(Self);
  Bf := GetBValue(Self);

  // Perceived luminance using ITU-R BT.709 coefficients
  BrightnessBack := 0.299 * Rb + 0.587 * Gb + 0.114 * Bb;
  BrightnessFont := 0.299 * Rf + 0.587 * Gf + 0.114 * Bf;

  // Check if both colors are on the same side of the brightness threshold
  if (BrightnessBack < MidLevel) = (BrightnessFont < MidLevel) then
  begin
    if AOnlyDarkBackground then
    begin
      // Invert only if the background is dark (and thus the font is dark too)
      if BrightnessBack < MidLevel then
        Result := RGBToColor(255 - Rf, 255 - Gf, 255 - Bf)
      else
        Result := Self; // On a light background, leave the font unchanged
    end
    else
      // Default behavior: always invert when both are on the same side
      Result := RGBToColor(255 - Rf, 255 - Gf, 255 - Bf);
  end
  else
    Result := Self; // Already contrasting, keep the original font color
end;

end.
