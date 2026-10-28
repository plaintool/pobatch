//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit Settings;

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
  MainUnit;

procedure SaveFormSettings(Form: TformPoBatch);

function LoadFormSettings(Form: TformPoBatch): boolean;

implementation

uses PoWrap, PoCheck, ObjectDictionary, OSUtils;

function QACheckOptionsToJSON(const AOpt: TQACheckOptions): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.Add('PlaceholderMissing', AOpt.PlaceholderMissing);
  Result.Add('PlaceholderExtra', AOpt.PlaceholderExtra);
  Result.Add('PluralCount', AOpt.PluralCount);
  Result.Add('CaseFirstChar', AOpt.CaseFirstChar);
  Result.Add('CaseAllUpper', AOpt.CaseAllUpper);
  Result.Add('SpaceLeading', AOpt.SpaceLeading);
  Result.Add('SpaceTrailing', AOpt.SpaceTrailing);
  Result.Add('SpaceDouble', AOpt.SpaceDouble);
  Result.Add('SpaceBeforePunct', AOpt.SpaceBeforePunct);
  Result.Add('SpaceAfterPunct', AOpt.SpaceAfterPunct);
  Result.Add('PunctEnd', AOpt.PunctEnd);
  Result.Add('PunctBracket', AOpt.PunctBracket);
  Result.Add('Newlines', AOpt.Newlines);
end;

function QACheckOptionsFromJSON(const AObj: TJSONObject): TQACheckOptions;
var
  Node: TJSONData;
begin
  Result := DefaultQACheckOptions;

  Node := AObj.FindPath('PlaceholderMissing');
  if Node <> nil then Result.PlaceholderMissing := Node.AsBoolean;
  Node := AObj.FindPath('PlaceholderExtra');
  if Node <> nil then Result.PlaceholderExtra := Node.AsBoolean;
  Node := AObj.FindPath('PluralCount');
  if Node <> nil then Result.PluralCount := Node.AsBoolean;
  Node := AObj.FindPath('CaseFirstChar');
  if Node <> nil then Result.CaseFirstChar := Node.AsBoolean;
  Node := AObj.FindPath('CaseAllUpper');
  if Node <> nil then Result.CaseAllUpper := Node.AsBoolean;
  Node := AObj.FindPath('SpaceLeading');
  if Node <> nil then Result.SpaceLeading := Node.AsBoolean;
  Node := AObj.FindPath('SpaceTrailing');
  if Node <> nil then Result.SpaceTrailing := Node.AsBoolean;
  Node := AObj.FindPath('SpaceDouble');
  if Node <> nil then Result.SpaceDouble := Node.AsBoolean;
  Node := AObj.FindPath('SpaceBeforePunct');
  if Node <> nil then Result.SpaceBeforePunct := Node.AsBoolean;
  Node := AObj.FindPath('SpaceAfterPunct');
  if Node <> nil then Result.SpaceAfterPunct := Node.AsBoolean;
  Node := AObj.FindPath('PunctEnd');
  if Node <> nil then Result.PunctEnd := Node.AsBoolean;
  Node := AObj.FindPath('PunctBracket');
  if Node <> nil then Result.PunctBracket := Node.AsBoolean;
  Node := AObj.FindPath('Newlines');
  if Node <> nil then Result.Newlines := Node.AsBoolean;
end;

procedure SaveFormSettings(Form: TformPoBatch);
var
  JSONObj: TJSONObject;
  FileName: string;
  PoFilesArray, StatusArray, arrParams: TJSONArray;
  QAMapObj, LangObj: TJSONObject;
  LangKey: string;
  Holder: TQACheckOptionsHolder;
  i: integer;
begin
  // Form may reach FormDestroy without completing FormCreate (e.g. after
  // an early exception during finalization), so guard against a nil instance
  if not Assigned(Form) then
    Exit;

  FileName := TOS.GetSettingsDirectory(APP_NAME, 'form_settings.json'); // Get settings file name
  ForceDirectories(TOS.GetSettingsDirectory(APP_NAME)); // Ensure the directory exists
  JSONObj := TJSONObject.Create;
  try
    // Save form position and size in design pixels (96 dpi) so the
    // values stay consistent when the screen DPI changes between runs
    if (Form.WindowState in [wsMaximized, wsMinimized]) then
    begin
      JSONObj.Add('Left', Form.ScaleFormTo96(Form.RestoredLeft));
      JSONObj.Add('Top', Form.ScaleFormTo96(Form.RestoredTop));
      JSONObj.Add('Width', Form.ScaleFormTo96(Form.RestoredWidth));
      JSONObj.Add('Height', Form.ScaleFormTo96(Form.RestoredHeight));
    end
    else
    begin
      JSONObj.Add('Left', Form.ScaleFormTo96(Form.Left));
      JSONObj.Add('Top', Form.ScaleFormTo96(Form.Top));
      JSONObj.Add('Width', Form.ScaleFormTo96(Form.Width));
      JSONObj.Add('Height', Form.ScaleFormTo96(Form.Height));
    end;
    JSONObj.Add('WindowState', Ord(Form.WindowState));

    JSONObj.Add('ListPathWidth', Form.ScaleFormTo96(Form.ListPath.Width));
    JSONObj.Add('PagesHeight', Form.ScaleFormTo96(Form.Pages.Height));
    JSONObj.Add('SplitRatio', Form.SplitRatio);

    JSONObj.Add('GridHeadersHeight', Form.ScaleFormTo96(Form.GridHeaders.Height));
    JSONObj.Add('GridHeadersColumnNameWidth', Form.ScaleFormTo96(Form.GridHeaders.Columns[COLUMN_HEADERS_NAME].Width));
    JSONObj.Add('GridHeadersColumnValueWidth', Form.ScaleFormTo96(Form.GridHeaders.Columns[COLUMN_HEADERS_VALUE].Width));
    JSONObj.Add('GridPluralColumnPluralWidth', Form.ScaleFormTo96(Form.GridPlural.Columns[COLUMN_PLURAL_PLURAL].Width));
    JSONObj.Add('GridCommentsColumnTypeWidth', Form.ScaleFormTo96(Form.GridComments.Columns[COLUMN_COMMENTS_TYPE].Width));
    JSONObj.Add('GridCommentsColumnValueWidth', Form.ScaleFormTo96(Form.GridComments.Columns[COLUMN_COMMENTS_VALUE].Width));

    JSONObj.Add('GridColumnSourceTextWidth', Form.ScaleFormTo96(Form.Grid.Columns[COLUMN_TEXT].Width));
    JSONObj.Add('GridColumnTranslationWidth', Form.ScaleFormTo96(Form.Grid.Columns[COLUMN_TRANSLATION].Width));
    JSONObj.Add('GridColumnContextWidth', Form.ScaleFormTo96(Form.Grid.Columns[COLUMN_CONTEXT].Width));
    JSONObj.Add('GridColumnReferenceWidth', Form.ScaleFormTo96(Form.Grid.Columns[COLUMN_REFERENCE].Width));
    JSONObj.Add('GridColumnPluralWidth', Form.ScaleFormTo96(Form.Grid.Columns[COLUMN_PLURAL].Width));
    JSONObj.Add('GridSortColumn', Form.SortColumn);
    JSONObj.Add('SortColumn', Form.SortColumn);
    JSONObj.Add('SortOrder', Ord(Form.SortOrder));

    JSONObj.Add('WordWrapGrid', Form.AWordWrapGrid.Checked);
    JSONObj.Add('WordWrapTranslatePanel', Form.AWordWrapTranslatePanel.Checked);
    JSONObj.Add('SpellCheckSource', Form.ASpellCheckSource.Checked);
    JSONObj.Add('SpellCheckTranslation', Form.ASpellCheckTranslation.Checked);

    JSONObj.Add('MenuHeadersChecked', Form.MenuHeaders.Checked);
    JSONObj.Add('MenuTranslatePanelChecked', Form.MenuTranslatePanel.Checked);
    JSONObj.Add('MenuColumnContextChecked', Form.MenuColumnContext.Checked);
    JSONObj.Add('MenuColumnReferenceChecked', Form.MenuColumnReference.Checked);
    JSONObj.Add('MenuColumnPluralChecked', Form.MenuColumnPlural.Checked);

    JSONObj.Add('FormConfigLeft', Form.ScaleFormTo96(Form.ConfigManager.FormPosition.Left));
    JSONObj.Add('FormConfigTop', Form.ScaleFormTo96(Form.ConfigManager.FormPosition.Top));
    JSONObj.Add('FormConfigWidth', Form.ScaleFormTo96(Form.ConfigManager.FormPosition.Width));
    JSONObj.Add('FormConfigHeight', Form.ScaleFormTo96(Form.ConfigManager.FormPosition.Height));
    JSONObj.Add('FormConfigSep1', Form.ScaleFormTo96(Form.ConfigManager.FormPosition.Sep1));
    JSONObj.Add('FormConfigSep2', Form.ScaleFormTo96(Form.ConfigManager.FormPosition.Sep2));

    JSONObj.Add('ActionEditTranslationOnly', Form.AEditTranslationOnly.Checked);
    JSONObj.Add('AutoCheckUpdates', Form.AutoCheckUpdates);
    JSONObj.Add('TranslateConfig', Form.ConfigManager.ConfigFile);
    JSONObj.Add('Path', Form.Path);

    // Save PO files list
    PoFilesArray := TJSONArray.Create;
    try
      // PoFiles is nil when the form is destroyed mid-construction
      if Assigned(Form.PoFiles) then
        for i := 0 to Form.PoFiles.Count - 1 do
          PoFilesArray.Add(Form.PoFiles[i]);
      JSONObj.Add('PoFiles', PoFilesArray);
      PoFilesArray := nil; // Ownership transferred to JSONObj
    finally
      PoFilesArray.Free;
    end;

    // Save PO file statuses
    StatusArray := TJSONArray.Create;
    try
      for i := 0 to High(Form.FileStatuses) do
        StatusArray.Add(Ord(Form.FileStatuses[i]));
      JSONObj.Add('PoFileStatuses', StatusArray);
      StatusArray := nil; // Ownership transferred to JSONObj
    finally
      StatusArray.Free;
    end;

    // Save the master QA switch. Per-language options are stored separately
    // and are not affected by this flag
    JSONObj.Add('QAChecksEnabled', Form.ACheckEnabled.Checked);

    // Save per-language QA check options. Only languages whose options
    // differ from the defaults are stored, so the map stays minimal
    QAMapObj := TJSONObject.Create;
    try
      // The dictionary stays nil if FormCreate aborted before creating it
      if Assigned(Form.QACheckOptionsByLang) then
        for i := 0 to Form.QACheckOptionsByLang.Count - 1 do
        begin
          LangKey := Form.QACheckOptionsByLang.GetKeyAt(i);
          Holder := TQACheckOptionsHolder(Form.QACheckOptionsByLang[LangKey]);
          if Assigned(Holder) and (LangKey <> '') then
          begin
            LangObj := QACheckOptionsToJSON(Holder.Options);
            QAMapObj.Add(LangKey, LangObj);
          end;
        end;
      JSONObj.Add('QACheckOptionsByLang', QAMapObj);
      QAMapObj := nil; // Ownership transferred to JSONObj
    finally
      QAMapObj.Free;
    end;

    // User Parameters
    arrParams := TJSONArray.Create;
    try
      // Translate or its UserParameters may be nil during early teardown
      if Assigned(Form.Translate) and Assigned(Form.Translate.UserParameters) then
        for i := 0 to Form.Translate.UserParameters.Count - 1 do
          arrParams.Add(Form.Translate.UserParameters[i]);
      JSONObj.Add('UserParameters', arrParams);
      arrParams := nil; // Ownership transferred to JSONObj
    finally
      arrParams.Free;
    end;

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
  PoFilesArray, StatusArray, arrParams: TJSONArray;
  TempStatusArray: TPOFileStatusArray = ();
  FileName: string;
  FileStream: TFileStream;
  FileContent: string;
  QAMapObj, LangObj: TJSONObject;
  i: integer;
begin
  Result := False;
  FileContent := string.Empty;
  FileName := TOS.GetSettingsDirectory(APP_NAME, 'form_settings.json'); // Get the settings file name
  if not FileExists(FileName) then Exit; // Exit if the file does not exist

  // Read from file
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(FileContent, FileStream.Size);
    FileStream.Read(Pointer(FileContent)^, FileStream.Size);
    JSONData := GetJSON(FileContent);
    try
      JSONObj := JSONData as TJSONObject;

      // Restore form position and size from design pixels (96 dpi),
      // scaled to the current DPI of the form
      if JSONObj.FindPath('Left') <> nil then
        Form.Left := Form.Scale96ToForm(JSONObj.FindPath('Left').AsInteger);

      if JSONObj.FindPath('Top') <> nil then
        Form.Top := Form.Scale96ToForm(JSONObj.FindPath('Top').AsInteger);

      if JSONObj.FindPath('Width') <> nil then
        Form.Width := Form.Scale96ToForm(JSONObj.FindPath('Width').AsInteger);

      if JSONObj.FindPath('Height') <> nil then
        Form.Height := Form.Scale96ToForm(JSONObj.FindPath('Height').AsInteger);

      if JSONObj.FindPath('WindowState') <> nil then
        Form.WindowState := TWindowState(JSONObj.FindPath('WindowState').AsInteger);

      if JSONObj.FindPath('ListPathWidth') <> nil then
        Form.ListPath.Width := Form.Scale96ToForm(JSONObj.FindPath('ListPathWidth').AsInteger);

      if JSONObj.FindPath('PagesHeight') <> nil then
        Form.Pages.Height := Form.Scale96ToForm(JSONObj.FindPath('PagesHeight').AsInteger);

      if JSONObj.FindPath('SplitRatio') <> nil then
        Form.SplitRatio := JSONObj.FindPath('SplitRatio').AsFloat
      else
        Form.SplitRatio := 0.5;

      if JSONObj.FindPath('GridHeadersHeight') <> nil then
        Form.GridHeaders.Height := Form.Scale96ToForm(JSONObj.FindPath('GridHeadersHeight').AsInteger);

      if JSONObj.FindPath('GridHeadersColumnNameWidth') <> nil then
        Form.GridHeaders.Columns[COLUMN_HEADERS_NAME].Width := Form.Scale96ToForm(JSONObj.FindPath('GridHeadersColumnNameWidth').AsInteger);

      if JSONObj.FindPath('GridHeadersColumnValueWidth') <> nil then
        Form.GridHeaders.Columns[COLUMN_HEADERS_VALUE].Width := Form.Scale96ToForm(JSONObj.FindPath('GridHeadersColumnValueWidth').AsInteger);

      if JSONObj.FindPath('GridPluralColumnPluralWidth') <> nil then
        Form.GridPlural.Columns[COLUMN_PLURAL_PLURAL].Width := Form.Scale96ToForm(JSONObj.FindPath('GridPluralColumnPluralWidth').AsInteger);

      if JSONObj.FindPath('GridCommentsColumnTypeWidth') <> nil then
        Form.GridComments.Columns[COLUMN_COMMENTS_TYPE].Width := Form.Scale96ToForm(JSONObj.FindPath('GridCommentsColumnTypeWidth').AsInteger);

      if JSONObj.FindPath('GridCommentsColumnValueWidth') <> nil then
        Form.GridComments.Columns[COLUMN_COMMENTS_VALUE].Width := Form.Scale96ToForm(JSONObj.FindPath('GridCommentsColumnValueWidth').AsInteger);

      if JSONObj.FindPath('GridColumnSourceTextWidth') <> nil then
        Form.Grid.Columns[COLUMN_TEXT].Width := Form.Scale96ToForm(JSONObj.FindPath('GridColumnSourceTextWidth').AsInteger);

      if JSONObj.FindPath('GridColumnTranslationWidth') <> nil then
        Form.Grid.Columns[COLUMN_TRANSLATION].Width := Form.Scale96ToForm(JSONObj.FindPath('GridColumnTranslationWidth').AsInteger);

      if JSONObj.FindPath('GridColumnContextWidth') <> nil then
        Form.Grid.Columns[COLUMN_CONTEXT].Width := Form.Scale96ToForm(JSONObj.FindPath('GridColumnContextWidth').AsInteger);

      if JSONObj.FindPath('GridColumnReferenceWidth') <> nil then
        Form.Grid.Columns[COLUMN_REFERENCE].Width := Form.Scale96ToForm(JSONObj.FindPath('GridColumnReferenceWidth').AsInteger);

      if JSONObj.FindPath('GridColumnPluralWidth') <> nil then
        Form.Grid.Columns[COLUMN_PLURAL].Width := Form.Scale96ToForm(JSONObj.FindPath('GridColumnPluralWidth').AsInteger);

      if JSONObj.FindPath('SortColumn') <> nil then
        Form.SortColumn := JSONObj.FindPath('SortColumn').AsInteger;

      if JSONObj.FindPath('SortOrder') <> nil then
      begin
        Form.SortOrder := TSortOrder(JSONObj.FindPath('SortOrder').AsInteger);
      end;

      if JSONObj.FindPath('WordWrapGrid') <> nil then
      begin
        Form.AWordWrapGrid.Checked := JSONObj.FindPath('WordWrapGrid').AsBoolean;
        if not Form.AWordWrapGrid.Checked and Assigned(Form.AWordWrapGrid.OnExecute) then
          Form.AWordWrapGrid.OnExecute(Form.AWordWrapGrid);
      end;
      if JSONObj.FindPath('WordWrapTranslatePanel') <> nil then
      begin
        Form.AWordWrapTranslatePanel.Checked := JSONObj.FindPath('WordWrapTranslatePanel').AsBoolean;
        if Form.AWordWrapTranslatePanel.Checked and Assigned(Form.AWordWrapTranslatePanel.OnExecute) then
          Form.AWordWrapTranslatePanel.OnExecute(Form.AWordWrapTranslatePanel);
      end;
      if JSONObj.FindPath('SpellCheckSource') <> nil then
      begin
        Form.ASpellCheckSource.Checked := JSONObj.FindPath('SpellCheckSource').AsBoolean;
        if not Form.ASpellCheckSource.Checked and Assigned(Form.ASpellCheckSource.OnExecute) then
          Form.ASpellCheckSource.OnExecute(Form.ASpellCheckSource);
      end;
      if JSONObj.FindPath('SpellCheckTranslation') <> nil then
      begin
        Form.ASpellCheckTranslation.Checked := JSONObj.FindPath('SpellCheckTranslation').AsBoolean;
        if not Form.ASpellCheckTranslation.Checked and Assigned(Form.ASpellCheckTranslation.OnExecute) then
          Form.ASpellCheckTranslation.OnExecute(Form.ASpellCheckTranslation);
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
      if JSONObj.FindPath('MenuColumnContextChecked') <> nil then
      begin
        Form.MenuColumnContext.Checked := JSONObj.FindPath('MenuColumnContextChecked').AsBoolean;
        if Form.MenuColumnContext.Checked and Assigned(Form.MenuColumnContext.OnClick) then
          Form.MenuColumnContext.OnClick(Form.MenuColumnContext);
      end;
      if JSONObj.FindPath('MenuColumnReferenceChecked') <> nil then
      begin
        Form.MenuColumnReference.Checked := JSONObj.FindPath('MenuColumnReferenceChecked').AsBoolean;
        if Form.MenuColumnReference.Checked and Assigned(Form.MenuColumnReference.OnClick) then
          Form.MenuColumnReference.OnClick(Form.MenuColumnReference);
      end;
      if JSONObj.FindPath('MenuColumnPluralChecked') <> nil then
      begin
        Form.MenuColumnPlural.Checked := JSONObj.FindPath('MenuColumnPluralChecked').AsBoolean;
        if Form.MenuColumnPlural.Checked and Assigned(Form.MenuColumnPlural.OnClick) then
          Form.MenuColumnPlural.OnClick(Form.MenuColumnPlural);
      end;

      if JSONObj.FindPath('FormConfigLeft') <> nil then
        Form.ConfigManager.FormPosition.Left := Form.Scale96ToForm(JSONObj.FindPath('FormConfigLeft').AsInteger);

      if JSONObj.FindPath('FormConfigTop') <> nil then
        Form.ConfigManager.FormPosition.Top := Form.Scale96ToForm(JSONObj.FindPath('FormConfigTop').AsInteger);

      if JSONObj.FindPath('FormConfigWidth') <> nil then
        Form.ConfigManager.FormPosition.Width := Form.Scale96ToForm(JSONObj.FindPath('FormConfigWidth').AsInteger);

      if JSONObj.FindPath('FormConfigHeight') <> nil then
        Form.ConfigManager.FormPosition.Height := Form.Scale96ToForm(JSONObj.FindPath('FormConfigHeight').AsInteger);

      if JSONObj.FindPath('FormConfigSep1') <> nil then
        Form.ConfigManager.FormPosition.Sep1 := Form.Scale96ToForm(JSONObj.FindPath('FormConfigSep1').AsInteger);

      if JSONObj.FindPath('FormConfigSep2') <> nil then
        Form.ConfigManager.FormPosition.Sep2 := Form.Scale96ToForm(JSONObj.FindPath('FormConfigSep2').AsInteger);

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

      if JSONObj.FindPath('TranslateConfig') <> nil then
        Form.ConfigManager.ConfigFile := JSONObj.FindPath('TranslateConfig').AsString;

      // Restore the master QA switch
      if JSONObj.FindPath('QAChecksEnabled') <> nil then
        Form.ACheckEnabled.Checked := JSONObj.FindPath('QAChecksEnabled').AsBoolean;

      // Load per-language QA check options
      if JSONObj.FindPath('QACheckOptionsByLang') <> nil then
      begin
        QAMapObj := JSONObj.FindPath('QACheckOptionsByLang') as TJSONObject;
        // The dictionary may be nil when the form is only partially created
        if Assigned(Form.QACheckOptionsByLang) then
        begin
          Form.QACheckOptionsByLang.Clear;
          for i := 0 to QAMapObj.Count - 1 do
          begin
            LangObj := QAMapObj.Items[i] as TJSONObject;
            Form.QACheckOptionsByLang[QAMapObj.Names[i]] :=
              TQACheckOptionsHolder.Create(QACheckOptionsFromJSON(LangObj));
          end;
        end;
      end;

      // Load user parameters
      // TTranslate.UserParameters may be nil early in the form lifecycle
      if Assigned(Form.Translate) and Assigned(Form.Translate.UserParameters) then
      begin
        Form.Translate.UserParameters.Clear;
        if JSONObj.FindPath('UserParameters') <> nil then
        begin
          arrParams := JSONObj.FindPath('UserParameters') as TJSONArray;
          for i := 0 to arrParams.Count - 1 do
            Form.Translate.UserParameters.Add(arrParams.Items[i].AsString);
        end;
      end;

      Result := True;
    finally
      JSONData.Free;
    end;
  finally
    FileStream.Free;
  end;
end;

end.
