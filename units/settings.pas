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
  Grids,
  fpjson,
  Graphics,
  mainunit;

procedure SaveFormSettings(Form: TformPoBatch);

function LoadFormSettings(Form: TformPoBatch): boolean;

implementation

uses systemtool, powrap;

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
  PoFilesArray, StatusArray: TJSONArray;
  i: integer;
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
    JSONObj.Add('PagesHeight', Form.Pages.Height);
    JSONObj.Add('SplitRatio', Form.SplitRatio);

    JSONObj.Add('GridHeadersHeight', Form.GridHeaders.Height);
    JSONObj.Add('GridHeadersColumnNameWidth', Form.GridHeaders.Columns[COLUMN_HEADERS_NAME].Width);
    JSONObj.Add('GridHeadersColumnValueWidth', Form.GridHeaders.Columns[COLUMN_HEADERS_VALUE].Width);
    JSONObj.Add('GridPluralColumnPluralWidth', Form.GridPlural.Columns[COLUMN_PLURAL_PLURAL].Width);
    JSONObj.Add('GridCommentsColumnTypeWidth', Form.GridComments.Columns[COLUMN_COMMENTS_TYPE].Width);
    JSONObj.Add('GridCommentsColumnValueWidth', Form.GridComments.Columns[COLUMN_COMMENTS_VALUE].Width);

    JSONObj.Add('GridColumnSourceTextWidth', Form.Grid.Columns[COLUMN_TEXT].Width);
    JSONObj.Add('GridColumnTranslationWidth', Form.Grid.Columns[COLUMN_TRANSLATION].Width);
    JSONObj.Add('GridColumnReferenceWidth', Form.Grid.Columns[COLUMN_REFERENCE].Width);
    JSONObj.Add('GridSortColumn', Form.SortColumn);
    JSONObj.Add('SortColumn', Form.SortColumn);
    JSONObj.Add('SortOrder', Ord(Form.SortOrder));

    JSONObj.Add('MenuHeadersChecked', Form.MenuHeaders.Checked);
    JSONObj.Add('MenuTranslatePanelChecked', Form.MenuTranslatePanel.Checked);
    JSONObj.Add('MenuColumnReferenceChecked', Form.MenuColumnReference.Checked);
    JSONObj.Add('ActionEditTranslationOnly', Form.AEditTranslationOnly.Checked);

    JSONObj.Add('AutoCheckUpdates', Form.AutoCheckUpdates);

    JSONObj.Add('Path', Form.Path);

    // Save PO files list
    PoFilesArray := TJSONArray.Create;
    for i := 0 to Form.PoFiles.Count - 1 do
      PoFilesArray.Add(Form.PoFiles[i]);
    JSONObj.Add('PoFiles', PoFilesArray);

    // Save PO file statuses
    StatusArray := TJSONArray.Create;
    for i := 0 to High(Form.FileStatuses) do
      StatusArray.Add(Ord(Form.FileStatuses[i]));
    JSONObj.Add('PoFileStatuses', StatusArray);

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
  PoFilesArray, StatusArray: TJSONArray;
  TempStatusArray: TPoFileStatusArray = ();
  FileName: string;
  FileStream: TFileStream;
  FileContent: string;
  i: integer;
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

      if JSONObj.FindPath('PagesHeight') <> nil then
        Form.Pages.Height := JSONObj.FindPath('PagesHeight').AsInteger;

      if JSONObj.FindPath('SplitRatio') <> nil then
        Form.SplitRatio := JSONObj.FindPath('SplitRatio').AsFloat
      else
        Form.SplitRatio := 0.5;

      if JSONObj.FindPath('GridHeadersHeight') <> nil then
        Form.GridHeaders.Height := JSONObj.FindPath('GridHeadersHeight').AsInteger;

      if JSONObj.FindPath('GridHeadersColumnNameWidth') <> nil then
        Form.GridHeaders.Columns[COLUMN_HEADERS_NAME].Width := JSONObj.FindPath('GridHeadersColumnNameWidth').AsInteger;

      if JSONObj.FindPath('GridHeadersColumnValueWidth') <> nil then
        Form.GridHeaders.Columns[COLUMN_HEADERS_VALUE].Width := JSONObj.FindPath('GridHeadersColumnValueWidth').AsInteger;

      if JSONObj.FindPath('GridPluralColumnPluralWidth') <> nil then
        Form.GridPlural.Columns[COLUMN_PLURAL_PLURAL].Width := JSONObj.FindPath('GridPluralColumnPluralWidth').AsInteger;

      if JSONObj.FindPath('GridCommentsColumnTypeWidth') <> nil then
        Form.GridComments.Columns[COLUMN_COMMENTS_TYPE].Width := JSONObj.FindPath('GridCommentsColumnTypeWidth').AsInteger;

      if JSONObj.FindPath('GridCommentsColumnValueWidth') <> nil then
        Form.GridComments.Columns[COLUMN_COMMENTS_VALUE].Width := JSONObj.FindPath('GridCommentsColumnValueWidth').AsInteger;

      if JSONObj.FindPath('GridColumnSourceTextWidth') <> nil then
        Form.Grid.Columns[COLUMN_TEXT].Width := JSONObj.FindPath('GridColumnSourceTextWidth').AsInteger;

      if JSONObj.FindPath('GridColumnTranslationWidth') <> nil then
        Form.Grid.Columns[COLUMN_TRANSLATION].Width := JSONObj.FindPath('GridColumnTranslationWidth').AsInteger;

      if JSONObj.FindPath('GridColumnReferenceWidth') <> nil then
        Form.Grid.Columns[COLUMN_REFERENCE].Width := JSONObj.FindPath('GridColumnReferenceWidth').AsInteger;

      if JSONObj.FindPath('SortColumn') <> nil then
        Form.SortColumn := JSONObj.FindPath('SortColumn').AsInteger;

      if JSONObj.FindPath('SortOrder') <> nil then
      begin
        Form.SortOrder := TSortOrder(JSONObj.FindPath('SortOrder').AsInteger);
      end;

      if JSONObj.FindPath('MenuHeadersChecked') <> nil then
      begin
        Form.MenuHeaders.Checked := JSONObj.FindPath('MenuHeadersChecked').AsBoolean;
        if Form.MenuHeaders.Checked and Assigned(Form.MenuHeaders.OnClick) then
          Form.MenuHeaders.OnClick(Form.MenuHeaders);
      end;
      if JSONObj.FindPath('MenuTranslatePanelChecked') <> nil then
      begin
        Form.MenuTranslatePanel.Checked := JSONObj.FindPath('MenuTranslatePanelChecked').AsBoolean;
        if Form.MenuTranslatePanel.Checked and Assigned(Form.MenuTranslatePanel.OnClick) then
          Form.MenuTranslatePanel.OnClick(Form.MenuTranslatePanel);
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
        if Assigned(Form.AEditTranslationOnly.OnExecute) then
          Form.AEditTranslationOnly.OnExecute(Form.AEditTranslationOnly);
      end;

      if JSONObj.FindPath('Path') <> nil then
        Form.Path := JSONObj.FindPath('Path').AsString;

      // Load PO files list
      if JSONObj.FindPath('PoFiles') <> nil then
      begin
        PoFilesArray := JSONObj.FindPath('PoFiles') as TJSONArray;
        Form.PoFiles.Clear;                         // use property
        for i := 0 to PoFilesArray.Count - 1 do
          Form.PoFiles.Add(PoFilesArray.Items[i].AsString);
      end;

      // Load PO file statuses
      if JSONObj.FindPath('PoFileStatuses') <> nil then
      begin
        StatusArray := JSONObj.FindPath('PoFileStatuses') as TJSONArray;
        SetLength(TempStatusArray, StatusArray.Count);
        for i := 0 to StatusArray.Count - 1 do
          TempStatusArray[i] := TPOFileStatus(StatusArray.Items[i].AsInteger);
        // Ensure statuses count matches files count
        if Length(TempStatusArray) <> Form.PoFiles.Count then
          SetLength(TempStatusArray, Form.PoFiles.Count);
        Form.FileStatuses := TempStatusArray;       // assign via property
      end;

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
