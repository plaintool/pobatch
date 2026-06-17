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
  LCLIntf;

function EndsWithLineBreak(const Buffer: TBytes): boolean;

function EndsWithLineBreak(const FileName: string): boolean;

function LoadFileAsBytes(const FileName: string): TBytes;

function BlendColors(Color1, Color2: TColor; Intensity: integer): TColor;

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

end.

