//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit settings;

{$mode ObjFPC}{$H+}
{$codepage utf8}

interface

uses
  Forms,
  Classes,
  SysUtils,
  fpjson,
  Graphics,
  mainunit;

procedure SaveFormSettings(Form: TformPoBatch);

function LoadFormSettings(Form: TformPoBatch): boolean;

implementation

uses systemtool;

function GetSettingsDirectory(fileName: string = ''): string;
  {$IFDEF Windows}
var
  baseDir: string;
  exeDir: string;
  {$ENDIF}
begin
  {$IFDEF Windows}
  // Get directory where exe is located
  exeDir := ExtractFilePath(ParamStr(0));

  // Portable mode: settings file exists near exe
  if FileExists(exeDir + 'form_settings.json') then
  begin
    Result := IncludeTrailingPathDelimiter(exeDir) + fileName;
    Exit;
  end;

  // Default mode: use LOCALAPPDATA or APPDATA
  baseDir := GetEnvironmentVariable('LOCALAPPDATA');
  if baseDir = '' then
    baseDir := GetEnvironmentVariable('APPDATA');

  Result := IncludeTrailingPathDelimiter(baseDir) + 'PoBatch\' + fileName;
  {$ELSE}
  // Unix-like systems: use ~/.config/pobatch
  Result := IncludeTrailingPathDelimiter(GetUserDir) + '.config/pobatch/' + fileName;
  {$ENDIF}
end;

procedure SaveFormSettings(Form: TformPoBatch);
var
  JSONObj: TJSONObject;
  FileName: string;
begin
  FileName := GetSettingsDirectory('form_settings.json'); // Get settings file name
  ForceDirectories(GetSettingsDirectory); // Ensure the directory exists
  JSONObj := TJSONObject.Create;
  try
    // Save form position and size
    if (Form.WindowState in [wsMaximized, wsMinimized]) then
    begin
      JSONObj.Add('Left', Form.RestoredLeft);
      JSONObj.Add('Top', Form.RestoredTop);
      JSONObj.Add('Width', Form.RestoredWidth);
      JSONObj.Add('Height', Form.RestoredHeight);
    end
    else
    begin
      JSONObj.Add('Left', Form.Left);
      JSONObj.Add('Top', Form.Top);
      JSONObj.Add('Width', Form.Width);
      JSONObj.Add('Height', Form.Height);
    end;
    JSONObj.Add('WindowState', Ord(Form.WindowState));

    JSONObj.Add('ListPathWidth', Form.ListPath.Width);
    JSONObj.Add('GridHeadersHeight', Form.GridHeaders.Height);
    JSONObj.Add('GridHeadersColumnNameWidth', Form.GridHeaders.Columns[COL_HEADERS_NAME].Width);
    JSONObj.Add('GridHeadersColumnValueWidth', Form.GridHeaders.Columns[COL_HEADERS_VALUE].Width);
    JSONObj.Add('GridColumnSourceTextWidth', Form.Grid.Columns[COL_TEXT].Width);
    JSONObj.Add('GridColumnTranslationWidth', Form.Grid.Columns[COL_TRANSLATION].Width);
    JSONObj.Add('GridColumnReferenceWidth', Form.Grid.Columns[COL_REFERENCE].Width);

    JSONObj.Add('MenuHeadersChecked', Form.MenuHeaders.Checked);
    JSONObj.Add('MenuColumnReferenceChecked', Form.MenuColumnReference.Checked);
    JSONObj.Add('ActionEditTranslationOnly', Form.AEditTranslationOnly.Checked);

    JSONObj.Add('AutoCheckUpdates', Form.AutoCheckUpdates);

    JSONObj.Add('Path', Form.Path);

    // Write to file
    with TStringList.Create do
    try
      Add(JSONObj.FormatJSON);
      SaveToFile(FileName);
    finally
      Free;
    end;
  finally
    JSONObj.Free;
  end;
end;

function LoadFormSettings(Form: TformPoBatch): boolean;
var
  JSONData: TJSONData;
  JSONObj: TJSONObject;
  FileName: string;
  FileStream: TFileStream;
  FileContent: string;
begin
  Result := False;
  FileContent := string.Empty;
  FileName := GetSettingsDirectory('form_settings.json'); // Get the settings file name
  if not FileExists(FileName) then Exit; // Exit if the file does not exist

  // Read from file
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(FileContent, FileStream.Size);
    FileStream.Read(Pointer(FileContent)^, FileStream.Size);
    JSONData := GetJSON(FileContent);
    try
      JSONObj := JSONData as TJSONObject;

      // Check and load form's position and size
      if JSONObj.FindPath('Left') <> nil then
        Form.Left := JSONObj.FindPath('Left').AsInteger;

      if JSONObj.FindPath('Top') <> nil then
        Form.Top := JSONObj.FindPath('Top').AsInteger;

      if JSONObj.FindPath('Width') <> nil then
        Form.Width := JSONObj.FindPath('Width').AsInteger;

      if JSONObj.FindPath('Height') <> nil then
        Form.Height := JSONObj.FindPath('Height').AsInteger;

      if JSONObj.FindPath('WindowState') <> nil then
        Form.WindowState := TWindowState(JSONObj.FindPath('WindowState').AsInteger);

      if JSONObj.FindPath('ListPathWidth') <> nil then
        Form.ListPath.Width := JSONObj.FindPath('ListPathWidth').AsInteger;

      if JSONObj.FindPath('GridHeadersHeight') <> nil then
        Form.GridHeaders.Height := JSONObj.FindPath('GridHeadersHeight').AsInteger;

      if JSONObj.FindPath('GridHeadersColumnNameWidth') <> nil then
        Form.GridHeaders.Columns[COL_HEADERS_NAME].Width := JSONObj.FindPath('GridHeadersColumnNameWidth').AsInteger;

      if JSONObj.FindPath('GridHeadersColumnValueWidth') <> nil then
        Form.GridHeaders.Columns[COL_HEADERS_VALUE].Width := JSONObj.FindPath('GridHeadersColumnValueWidth').AsInteger;

      if JSONObj.FindPath('GridColumnSourceTextWidth') <> nil then
        Form.Grid.Columns[COL_TEXT].Width := JSONObj.FindPath('GridColumnSourceTextWidth').AsInteger;

      if JSONObj.FindPath('GridColumnTranslationWidth') <> nil then
        Form.Grid.Columns[COL_TRANSLATION].Width := JSONObj.FindPath('GridColumnTranslationWidth').AsInteger;

      if JSONObj.FindPath('GridColumnReferenceWidth') <> nil then
        Form.Grid.Columns[COL_REFERENCE].Width := JSONObj.FindPath('GridColumnReferenceWidth').AsInteger;

      if JSONObj.FindPath('MenuHeadersChecked') <> nil then
      begin
        Form.MenuHeaders.Checked := JSONObj.FindPath('MenuHeadersChecked').AsBoolean;
        if Form.MenuHeaders.Checked and Assigned(Form.MenuHeaders.OnClick) then
          Form.MenuHeaders.OnClick(Form.MenuHeaders);
      end;

      if JSONObj.FindPath('MenuColumnReferenceChecked') <> nil then
      begin
        Form.MenuColumnReference.Checked := JSONObj.FindPath('MenuColumnReferenceChecked').AsBoolean;
        if Form.MenuColumnReference.Checked and Assigned(Form.MenuColumnReference.OnClick) then
          Form.MenuColumnReference.OnClick(Form.MenuColumnReference);
      end;

      if JSONObj.FindPath('ActionEditTranslationOnly') <> nil then
      begin
        Form.AEditTranslationOnly.Checked := JSONObj.FindPath('ActionEditTranslationOnly').AsBoolean;
        if Form.AEditTranslationOnly.Checked and Assigned(Form.AEditTranslationOnly.OnExecute) then
          Form.AEditTranslationOnly.OnExecute(Form.AEditTranslationOnly);
      end;

      if JSONObj.FindPath('Path') <> nil then
        Form.Path := JSONObj.FindPath('Path').AsString;

      if JSONObj.FindPath('AutoCheckUpdates') <> nil then
        Form.AutoCheckUpdates := JSONObj.FindPath('AutoCheckUpdates').AsBoolean;

      Result := True;
    finally
      JSONData.Free;
    end;
  finally
    FileStream.Free;
  end;
end;

end.
