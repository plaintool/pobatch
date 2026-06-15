unit formattool;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

function EndsWithLineBreak(const Buffer: TBytes): boolean;

function EndsWithLineBreak(const FileName: string): boolean;

function LoadFileAsBytes(const FileName: string): TBytes;

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

end.

