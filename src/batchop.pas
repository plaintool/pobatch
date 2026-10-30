//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit BatchOp;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  StrUtils,
  SysUtils,
  Math,
  Controls,
  Forms,
  Dialogs,
  Grids,
  FileUtil,
  MainUnit;

type
  TBatchOp = class
  private
    // Print to the console when confirmations are off, otherwise show a dialog
    class procedure ReportMessage(const AMessage: string; AConfirm: boolean);
    class procedure ReportMessageFmt(const AFormat: string; const Args: array of const; AConfirm: boolean);
    class procedure ReportSuccess(AForm: TformPoBatch; const AMessage: string; AConfirm: boolean);
    class procedure ReportSuccessFmt(AForm: TformPoBatch; const AFormat: string; const Args: array of const; AConfirm: boolean);
  public
    // Resolve the POT file that pairs with AFileName:
    // - POT returns itself
    // - PO returns <base>.pot (with the language suffix stripped)
    // - returns an empty string when no matching POT exists
    class function FindPotForFile(const AFileName: string): string;
    // Multi-file operations on the opened path
    class procedure CopySourceInFiles(AForm: TformPoBatch; AConfirm: boolean = True);
    class procedure ClearInFiles(AForm: TformPoBatch; AFuzzyOnly: boolean = True; AConfirm: boolean = True);
    class procedure MarkFilesValid(AForm: TformPoBatch; AConfirm: boolean = True);
    class procedure SyncFilesWithPot(AForm: TformPoBatch; const APotFileName: string = ''; AConfirm: boolean = True);
    class procedure RenameFiles(AForm: TformPoBatch; const ANewBaseName: string = ''; AConfirm: boolean = True);
    class procedure DeleteFiles(AForm: TformPoBatch; AConfirm: boolean = True);
    class procedure NewFilesFromPot(AForm: TformPoBatch; const APotFileName: string = ''; ALangCodes: TStrings = nil;
      AConfirm: boolean = True);
    class procedure PathTranslateEmpty(AForm: TformPoBatch; AConfirm: boolean = True);
    // Single-file operations
    class procedure SyncCurrentWithPot(AForm: TformPoBatch; const APotFileName: string = ''; AConfirm: boolean = True);
    class procedure MarkSelectedValid(AForm: TformPoBatch);
    // Grid-level operations
    class procedure CopySourceToTranslation(AForm: TformPoBatch);
    class procedure ClearIdenticalTranslations(AForm: TformPoBatch);
    class procedure Translate(AForm: TformPoBatch; ASkipTranslated: boolean = False; AOnlySelected: boolean = True);
  end;

  {%Region -fold Resource Strings}
resourcestring
  rnopofilesselected = 'No PO files selected.';
  rfilenotfound = 'File not found: %s';
  rerrorprocessingfile = 'Error processing file "%s": %s';
  rmorefiles = '... and %d more file(s)';
  rmorelines = '... and %d more line(s)';

  rcopysourceemptyconfirm = 'Copy source text to empty translations in the following %d file(s)?'#13#10'This action cannot be undone within the application.'#13#10#13#10'%s';
  rcopysourceemptytitle = 'Copy source to empty';
  rdonetranslationsfilled = 'Done. %d translation(s) filled from source.';

  rclearinvalidtitle = 'Clear invalid translations';
  rclearfuzzyconfirm = 'Clear translations of fuzzy entries in the following %d file(s)?'#13#10'This action cannot be undone within the application.'#13#10#13#10'%s';
  rclearalltitle = 'Clear all translations';
  rclearallconfirm = 'Clear ALL translations in the following %d file(s)?'#13#10'Headers are preserved, all msgstr values are removed.'#13#10'This action cannot be undone within the application.'#13#10#13#10'%s';
  rdoneinvalidcleared = 'Done. %d invalid translation(s) cleared.';
  rdonetranslationscleared = 'Done. %d translation(s) cleared.';

  rmarkvalidconfirm = 'Mark the following %d file(s) as valid?'#13#10'This will remove the "fuzzy" flag from all entries.'#13#10'This action cannot be undone within the application.'#13#10#13#10'%s';
  rremovefuzzytitle = 'Remove fuzzy flag';
  rmarkvaliddone = 'Selected files have been marked as valid. All "fuzzy" flags were removed.';

  rnosyncselected = 'No PO files selected for synchronization.';
  rsyncconfirm = 'Synchronize the following %d file(s) with'#13#10'their matching POT files?'#13#10'This action cannot be undone within the application.'#13#10#13#10'%s';
  rconfirmsynctitle = 'Confirm synchronization';
  rerrorsyncfile = 'Error synchronizing file "%s": %s';
  rsyncdoneskipped = 'Synchronization complete. %d file(s) skipped (no matching POT).';
  rsyncdone = 'Synchronization complete.';

  rselectrenamemessage = 'Select file(s) to rename!';
  rnameconsoleerror = 'Error: --name is required in console mode';
  rrenametitle = 'Rename files';
  rrenameprompt = 'Enter new base name:';
  rrenameconfirm = 'Rename the following %d file(s) using base name "%s"?'#13#10#13#10'%s';
  rconfirmrenametitle = 'Confirm rename';
  rrenamefailed = 'Failed to rename: %s';

  rselectdeletemessage = 'Select file to delete!';
  rdeletetitle = 'Delete file';
  rdeletesingleconfirm = 'Are you sure you want to delete the selected file?';
  rdeletemultipleconfirm = 'Are you sure you want to delete the following %d file(s)?'#13#10#13#10'%s';
  rdeletefilestitle = 'Delete files';

  rnopotforfile = 'No matching POT file found for: %s';
  rpotconsoleerror = 'Error: --pot is required in console mode';
  rpotnotfound = 'POT file not found: %s';
  rlangsconsoleerror = 'Error: --langs is required in console mode';
  rfilesexisttitle = 'Files exist';
  rfilesexistconfirm = 'The following files already exist:'#13#10#13#10'%s'#13#10'Overwrite them?';

  rtranslationconfignotselected = 'Translation configuration is not selected. Please choose a translation service first.';
  rtranslatemissingconfirm = 'Translate missing translations in the following %d file(s)?'#13#10'This action cannot be undone within the application.'#13#10#13#10'%s';
  rtranslatemissingtitle = 'Translate missing';
  rfilelangnotset = 'File "%s" skipped: target language is not set in the PO header or file name.';
  rtranslationlinecount = 'File "%s": translation service returned %d lines instead of %d; single-line entries were skipped.'#13#10#13#10'Response:'#13#10'%s';
  rfiletranslationnone = 'File "%s" skipped: no translations were produced for language "%s".';
  rdonetranslationsadded = 'Done. %d translation(s) added in %d file(s). %d file(s) skipped.';

  rsynccurrentconfirm = 'Synchronize current file'#13#10'  %s'#13#10'with reference POT'#13#10'  %s ?';
  rerrorsynccurrent = 'Error synchronizing file: %s';

  rmarkvalidgridtitle = 'Mark as Valid';
  rmarkvalidgridconfirm = 'Mark %d selected entries as valid?'#13#10'This will remove the "fuzzy" flag from the selected entries.';
  rnofuzzyentries = 'No fuzzy entries in the selection.';
  rmarkedvalidcount = '%d entries marked as valid.';

  rcopysourcetotranslationconfirm = 'Copy source text to translations in the selected row(s)?';
  rcopiedtranslationscount = '%d translations were copied.';
  rclearidenticalconfirm = 'Clear translations that are identical to the source text in the selected row(s)?';
  rclearedtranslationscount = '%d translations were cleared.';

  rtargetlangnotset = 'Target language is not set. Please specify the Language header in the PO file.';
  rtranslatemissingselected = 'Translate missing translations in %d selected entries?';
  rtranslateselected = 'Translate %d selected entries?';
  rtranslateallmissing = 'Translate all missing translations in the current file?';
  rtranslateall = 'Translate all entries in the current file?';
  rnothingtranslatedall = 'Nothing to translate: all entries already have translations.';
  rnothingtranslated = 'Nothing to translate.';
  rtranslationerror = 'Translation error: %s';
  rtranslationlinecountgrid = 'Translation service returned %d lines instead of %d; single-line entries were skipped.'#13#10#13#10'Response:'#13#10'%s';
  rtranslatedoneskipped = 'Translation complete. %d entries updated, %d skipped.';
  rtranslatedone = 'Translation complete. %d entries updated.';
  {%EndRegion}

implementation

uses
  LangCodes, StringHelper, Localize, PoWrap;

  { TBatchOp }

class procedure TBatchOp.ReportMessage(const AMessage: string; AConfirm: boolean);
begin
  if AConfirm then
    ShowMessage(AMessage)
  else
    WriteLn(AMessage);
end;

class procedure TBatchOp.ReportMessageFmt(const AFormat: string; const Args: array of const; AConfirm: boolean);
begin
  if AConfirm then
    ShowMessageFmt(AFormat, Args)
  else
    WriteLn(Format(AFormat, Args));
end;

class procedure TBatchOp.ReportSuccess(AForm: TformPoBatch; const AMessage: string; AConfirm: boolean);
begin
  // Console mode always prints, GUI mode respects the form's success toggle
  if AConfirm and not AForm.ShowSuccess then Exit;
  ReportMessage(AMessage, AConfirm);
end;

class procedure TBatchOp.ReportSuccessFmt(AForm: TformPoBatch; const AFormat: string; const Args: array of const; AConfirm: boolean);
begin
  // Console mode always prints, GUI mode respects the form's success toggle
  if AConfirm and not AForm.ShowSuccess then Exit;
  ReportMessageFmt(AFormat, Args, AConfirm);
end;

class function TBatchOp.FindPotForFile(const AFileName: string): string;
var
  Dir: string;
  Base: string;
  Candidate: string;
  DotPos: integer;
begin
  Result := string.Empty;
  if AFileName = string.Empty then
    Exit;

  // POT files pair with themselves
  if SameText(ExtractFileExt(AFileName), '.pot') then
    Exit(AFileName);

  // Only PO files can be paired with a POT
  if not SameText(ExtractFileExt(AFileName), '.po') then
    Exit;

  Dir := IncludeTrailingPathDelimiter(ExtractFilePath(AFileName));
  Base := ChangeFileExt(ExtractFileName(AFileName), '');

  // Try <base>.pot first - covers "module.po" and "module.<lang>.po"
  // when the POT carries the same suffix
  Candidate := Dir + Base + '.pot';
  if FileExists(Candidate) then
    Exit(Candidate);

  // Fall back to stripping the language suffix: "module.<lang>.po" -> "module.pot"
  DotPos := RPos('.', Base);
  if DotPos > 1 then
  begin
    Candidate := Dir + Copy(Base, 1, DotPos - 1) + '.pot';
    if FileExists(Candidate) then
      Exit(Candidate);
  end;
end;

class procedure TBatchOp.CopySourceInFiles(AForm: TformPoBatch; AConfirm: boolean = True);
var
  i, j, k, selCount: integer;
  PoFile: TPOFile;
  Entry: TPOEntry;
  FileName: string;
  fileList, msg: string;
  SelectedIndices: array of integer = nil;
  NewList: TStringList;
  FormsCount: integer;
  HasChanges: boolean;
  CopiedCount: integer;
  TotalCopied: integer;
begin
  // Collect selected indices before processing
  SetLength(SelectedIndices, AForm.ListPath.Items.Count);
  selCount := 0;
  for i := 0 to AForm.ListPath.Items.Count - 1 do
    if AForm.ListPath.Selected[i] then
    begin
      SelectedIndices[selCount] := i;
      Inc(selCount);
    end;
  SetLength(SelectedIndices, selCount);

  if selCount = 0 then
  begin
    ReportMessage(rnopofilesselected, AConfirm);
    Exit;
  end;

  // Build the confirmation message with the affected files
  fileList := string.Empty;
  for i := 0 to selCount - 1 do
  begin
    if i < 10 then
      fileList := fileList + AForm.PoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + Format(rmorefiles, [selCount - 10]) + sLineBreak;
  end;

  msg := Format(rcopysourceemptyconfirm, [selCount, fileList]);
  if AConfirm and (MessageDlg(rcopysourceemptytitle, msg, mtConfirmation, mbYesNo, 0) <> mrYes) then
    Exit;

  // Ask to save the current file if modified - abort if user cancels
  if not AForm.IsCanClose(True) then
    Exit;

  TotalCopied := 0;
  Screen.Cursor := crHourGlass;
  try
    for i := 0 to selCount - 1 do
    begin
      FileName := AForm.PoFiles[SelectedIndices[i]];
      if not FileExists(FileName) then
      begin
        // Show the warning without the hourglass cursor
        Screen.Cursor := crDefault;
        ReportMessageFmt(rfilenotfound, [FileName], AConfirm);
        Screen.Cursor := crHourGlass;
        Continue;
      end;

      // Skip POT files - they contain no translations
      if SameText(ExtractFileExt(FileName), '.pot') then
        Continue;

      PoFile := TPOFile.Create;
      try
        try
          PoFile.LoadFromFile(FileName);
          CopiedCount := 0;

          for j := 0 to PoFile.Entries.Count - 1 do
          begin
            Entry := PoFile.Entries[j];
            // Skip the header entry (empty msgid)
            if Entry.MsgId = string.Empty then
              Continue;

            if Entry.MsgIdPlural <> string.Empty then
            begin
              // Plural entry: fill every empty form with the matching source form
              FormsCount := Max(Entry.MsgStrCount, PoFile.PluralFormsCount);
              if FormsCount < 2 then
                FormsCount := 2;

              NewList := TStringList.Create;
              try
                for k := 0 to FormsCount - 1 do
                begin
                  if (k < Entry.MsgStrCount) and (Entry.MsgStr[k] <> string.Empty) then
                    NewList.Add(Entry.MsgStr[k])
                  else
                  begin
                    if k = 0 then
                      NewList.Add(Entry.MsgId)
                    else
                      NewList.Add(Entry.MsgIdPlural);
                    Inc(CopiedCount);
                  end;
                end;

                // Apply only if the form count or content actually changed
                HasChanges := NewList.Count <> Entry.MsgStrCount;
                if not HasChanges then
                  for k := 0 to NewList.Count - 1 do
                    if NewList[k] <> Entry.MsgStr[k] then
                    begin
                      HasChanges := True;
                      Break;
                    end;

                if HasChanges then
                  Entry.MsgStrList := NewList;
              finally
                NewList.Free;
              end;
            end
            else
            begin
              // Simple entry: copy msgid to msgstr only when msgstr is empty
              if Entry.MsgStrSimple = string.Empty then
              begin
                Entry.MsgStrSimple := Entry.MsgId;
                Inc(CopiedCount);
              end;
            end;
          end;

          if CopiedCount > 0 then
          begin
            PoFile.SaveToFile(FileName);
            Inc(TotalCopied, CopiedCount);
          end;
        except
          on E: Exception do
          begin
            // Show the error without the hourglass cursor
            Screen.Cursor := crDefault;
            ReportMessageFmt(rerrorprocessingfile, [FileName, E.Message], AConfirm);
            Screen.Cursor := crHourGlass;
            Continue;
          end;
        end;
      finally
        PoFile.Free;
      end;

      // Refresh the status of this file in the path list
      AForm.AnalizePath(SelectedIndices[i]);

      // If this was the currently opened file, reload it in the editor
      if SameFileName(FileName, AForm.FileName) then
        AForm.ReloadCurrentFile(AForm.FileName);
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  ReportSuccessFmt(AForm, rdonetranslationsfilled, [TotalCopied], AConfirm);
end;

class procedure TBatchOp.ClearInFiles(AForm: TformPoBatch; AFuzzyOnly: boolean = True; AConfirm: boolean = True);
var
  i, j, selCount: integer;
  PoFile: TPOFile;
  Entry: TPOEntry;
  FileName: string;
  fileList, msg, DialogTitle: string;
  SelectedIndices: array of integer = nil;
  ClearedCount, TotalCleared: integer;
  EmptyList: TStringList;
begin
  // Collect selected indices before processing
  SetLength(SelectedIndices, AForm.ListPath.Items.Count);
  selCount := 0;
  for i := 0 to AForm.ListPath.Items.Count - 1 do
    if AForm.ListPath.Selected[i] then
    begin
      SelectedIndices[selCount] := i;
      Inc(selCount);
    end;
  SetLength(SelectedIndices, selCount);

  if selCount = 0 then
  begin
    ReportMessage(rnopofilesselected, AConfirm);
    Exit;
  end;

  // Build the confirmation message with the affected files
  fileList := string.Empty;
  for i := 0 to selCount - 1 do
  begin
    if i < 10 then
      fileList := fileList + AForm.PoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + Format(rmorefiles, [selCount - 10]) + sLineBreak;
  end;

  if AFuzzyOnly then
  begin
    DialogTitle := rclearinvalidtitle;
    msg := Format(rclearfuzzyconfirm, [selCount, fileList]);
  end
  else
  begin
    DialogTitle := rclearalltitle;
    msg := Format(rclearallconfirm, [selCount, fileList]);
  end;

  if AConfirm and (MessageDlg(DialogTitle, msg, mtConfirmation, mbYesNo, 0) <> mrYes) then
    Exit;

  // Ask to save the current file if modified - abort if user cancels
  if not AForm.IsCanClose(True) then
    Exit;

  TotalCleared := 0;
  Screen.Cursor := crHourGlass;
  try
    for i := 0 to selCount - 1 do
    begin
      FileName := AForm.PoFiles[SelectedIndices[i]];
      if not FileExists(FileName) then
      begin
        // Show the warning without the hourglass cursor
        Screen.Cursor := crDefault;
        ReportMessageFmt(rfilenotfound, [FileName], AConfirm);
        Screen.Cursor := crHourGlass;
        Continue;
      end;

      // Skip POT files - they contain no translations
      if SameText(ExtractFileExt(FileName), '.pot') then
        Continue;

      PoFile := TPOFile.Create;
      try
        try
          PoFile.LoadFromFile(FileName);
          ClearedCount := 0;

          for j := 0 to PoFile.Entries.Count - 1 do
          begin
            Entry := PoFile.Entries[j];
            // Skip the header entry (empty msgid)
            if Entry.MsgId = string.Empty then
              Continue;
            // When only fuzzy entries are requested, skip the rest
            if AFuzzyOnly and not Entry.IsFuzzy then
              Continue;

            if Entry.MsgIdPlural <> string.Empty then
            begin
              // Plural entry: drop all translation forms at once
              EmptyList := TStringList.Create;
              try
                Entry.MsgStrList := EmptyList;
              finally
                EmptyList.Free;
              end;
            end
            else
              Entry.MsgStrSimple := string.Empty;

            Inc(ClearedCount);
          end;

          if ClearedCount > 0 then
          begin
            PoFile.SaveToFile(FileName);
            Inc(TotalCleared, ClearedCount);
          end;
        except
          on E: Exception do
          begin
            // Show the error without the hourglass cursor
            Screen.Cursor := crDefault;
            ReportMessageFmt(rerrorprocessingfile, [FileName, E.Message], AConfirm);
            Screen.Cursor := crHourGlass;
            Continue;
          end;
        end;
      finally
        PoFile.Free;
      end;

      // Refresh the status of this file in the path list
      AForm.AnalizePath(SelectedIndices[i]);

      // If this was the currently opened file, reload it in the editor
      if SameFileName(FileName, AForm.FileName) then
        AForm.ReloadCurrentFile(AForm.FileName);
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  if AFuzzyOnly then
    ReportSuccessFmt(AForm, rdoneinvalidcleared, [TotalCleared], AConfirm)
  else
    ReportSuccessFmt(AForm, rdonetranslationscleared, [TotalCleared], AConfirm);
end;

class procedure TBatchOp.MarkFilesValid(AForm: TformPoBatch; AConfirm: boolean = True);
var
  i, j, selCount: integer;
  PoFile: TPOFile;
  FileName: string;
  fileList, msg: string;
  SelectedIndices: array of integer = nil;
begin
  // Collect selected indices before showing the dialog
  SetLength(SelectedIndices, AForm.ListPath.Items.Count);
  selCount := 0;
  for i := 0 to AForm.ListPath.Items.Count - 1 do
    if AForm.ListPath.Selected[i] then
    begin
      SelectedIndices[selCount] := i;
      Inc(selCount);
    end;
  SetLength(SelectedIndices, selCount);

  if selCount = 0 then
  begin
    ReportMessage(rnopofilesselected, AConfirm);
    Exit;
  end;

  // Build file list for confirmation message
  fileList := '';
  for i := 0 to selCount - 1 do
  begin
    if i < 10 then
      fileList := fileList + AForm.PoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + Format(rmorefiles, [selCount - 10]) + sLineBreak;
  end;

  msg := Format(rmarkvalidconfirm, [selCount, fileList]);
  if AConfirm and (MessageDlg(rremovefuzzytitle, msg, mtConfirmation, mbYesNo, 0) <> mrYes) then
    Exit;

  // Save current file if modified - abort if user cancels
  if not AForm.IsCanClose(True) then
    Exit;

  // Process each selected file using the saved indices
  Screen.Cursor := crHourGlass;
  try
    for i := 0 to selCount - 1 do
    begin
      FileName := AForm.PoFiles[SelectedIndices[i]];
      if not FileExists(FileName) then
      begin
        // Show the warning without the hourglass cursor
        Screen.Cursor := crDefault;
        ReportMessageFmt(rfilenotfound, [FileName], AConfirm);
        Screen.Cursor := crHourGlass;
        Continue;
      end;

      // Skip POT files - they contain no translations
      if SameText(ExtractFileExt(FileName), '.pot') then
        Continue;

      PoFile := TPOFile.Create;
      try
        try
          PoFile.LoadFromFile(FileName);

          // Remove fuzzy flag from every translatable entry
          for j := 0 to PoFile.Entries.Count - 1 do
          begin
            if PoFile.Entries[j].MsgId <> '' then
              PoFile.Entries[j].IsFuzzy := False;
          end;

          PoFile.SaveToFile(FileName);
        except
          on E: Exception do
          begin
            // Show the error without the hourglass cursor
            Screen.Cursor := crDefault;
            ReportMessageFmt(rerrorprocessingfile, [FileName, E.Message], AConfirm);
            Screen.Cursor := crHourGlass;
            Continue;    // skip status update for this file
          end;
        end;
      finally
        PoFile.Free;
      end;

      // Update the status of this file in the path list
      AForm.AnalizePath(SelectedIndices[i]);

      // If this was the currently opened file, reload it in the editor
      if FileName = AForm.FileName then
        AForm.ReloadCurrentFile(AForm.FileName);
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  ReportSuccess(AForm, rmarkvaliddone, AConfirm);
end;

class procedure TBatchOp.SyncFilesWithPot(AForm: TformPoBatch; const APotFileName: string = ''; AConfirm: boolean = True);
var
  i, selCount: integer;
  PoFile: TPOFile;
  FileName: string;
  PotForFile: string;
  fileList, msg: string;
  SelectedIndices: array of integer = nil;
  SkippedCount: integer = 0;
begin
  // Ask to save current file if modified - if user cancels, abort sync
  if not AForm.IsCanClose(True) then
    Exit;

  // Collect selected indices before processing
  SetLength(SelectedIndices, AForm.ListPath.Items.Count);
  selCount := 0;
  for i := 0 to AForm.ListPath.Items.Count - 1 do
    if AForm.ListPath.Selected[i] then
    begin
      SelectedIndices[selCount] := i;
      Inc(selCount);
    end;
  SetLength(SelectedIndices, selCount);

  if selCount = 0 then
  begin
    ReportMessage(rnosyncselected, AConfirm);
    Exit;
  end;

  // Build confirmation message
  fileList := '';
  for i := 0 to selCount - 1 do
  begin
    if i < 10 then
      fileList := fileList + AForm.PoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + Format(rmorefiles, [selCount - 10]) + sLineBreak;
  end;

  msg := Format(rsyncconfirm, [selCount, fileList]);
  if AConfirm and (MessageDlg(rconfirmsynctitle, msg, mtConfirmation, mbYesNo, 0) <> mrYes) then
    Exit;

  // Process each selected file using the saved indices
  Screen.Cursor := crHourGlass;
  try
    for i := 0 to selCount - 1 do
    begin
      FileName := AForm.PoFiles[SelectedIndices[i]];
      if not FileExists(FileName) then
      begin
        // Show the warning without the hourglass cursor
        Screen.Cursor := crDefault;
        ReportMessageFmt(rfilenotfound, [FileName], AConfirm);
        Screen.Cursor := crHourGlass;
        Continue;
      end;

      // Use the explicit POT when supplied, otherwise auto-detect per file
      if APotFileName <> string.Empty then
        PotForFile := APotFileName
      else
        PotForFile := FindPotForFile(FileName);

      // Skip POT files and PO files with no matching POT
      if (PotForFile = string.Empty) or SameFileName(FileName, PotForFile) then
      begin
        Inc(SkippedCount);
        Continue;
      end;

      PoFile := TPOFile.Create;
      try
        try
          PoFile.LoadFromFile(FileName);
          PoFile.SynchronizeToFile(PotForFile, True);
          PoFile.SaveToFile(FileName);
        except
          on E: Exception do
          begin
            // Show the error without the hourglass cursor
            Screen.Cursor := crDefault;
            ReportMessageFmt(rerrorsyncfile, [FileName, E.Message], AConfirm);
            Screen.Cursor := crHourGlass;
            Continue;
          end;
        end;
      finally
        PoFile.Free;
      end;

      // Refresh list item status
      AForm.AnalizePath(SelectedIndices[i]);

      // If this was the currently opened file, reload it in the editor
      if FileName = AForm.FileName then
        AForm.ReloadCurrentFile(AForm.FileName);
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  if SkippedCount > 0 then
    ReportSuccessFmt(AForm, rsyncdoneskipped, [SkippedCount], AConfirm)
  else
    ReportSuccess(AForm, rsyncdone, AConfirm);
end;

class procedure TBatchOp.RenameFiles(AForm: TformPoBatch; const ANewBaseName: string = ''; AConfirm: boolean = True);
var
  i, selCount, p, NewIdx: integer;
  FileName, Dir, BaseName, LangPart, NewName: string;
  DefaultName, OriginalName: string;
  SelectedIndices: array of integer = nil;
  fileList, msg: string;
  RenamedCount: integer;
  SortList: TStringList;
  Statuses: TPOFileStatusArray;
begin
  // Collect indices of selected items
  SetLength(SelectedIndices, AForm.ListPath.Items.Count);
  selCount := 0;
  for i := 0 to AForm.ListPath.Items.Count - 1 do
    if AForm.ListPath.Selected[i] then
    begin
      SelectedIndices[selCount] := i;
      Inc(selCount);
    end;
  SetLength(SelectedIndices, selCount);

  if selCount = 0 then
  begin
    ReportMessage(rselectrenamemessage, AConfirm);
    Exit;
  end;

  // Take the default name part from the currently opened file if it belongs
  // to the opened folder, otherwise from the first selected file
  if (AForm.FileName <> string.Empty) and (AForm.PoFiles.IndexOf(AForm.FileName) >= 0) then
    BaseName := ChangeFileExt(ExtractFileName(AForm.FileName), '')
  else
    BaseName := ChangeFileExt(ExtractFileName(AForm.PoFiles[SelectedIndices[0]]), '');

  p := RPos('.', BaseName);
  if p > 1 then
    DefaultName := Copy(BaseName, 1, p - 1)
  else
    DefaultName := BaseName;

  OriginalName := DefaultName;

  // Use the name from the console when supplied, otherwise ask interactively
  if ANewBaseName <> string.Empty then
    DefaultName := Trim(ANewBaseName)
  else
  begin
    if not AConfirm then
    begin
      ReportMessage(rnameconsoleerror, AConfirm);
      Exit;
    end;
    InputQueryLite(rrenametitle, rrenameprompt, DefaultName);
    DefaultName := Trim(DefaultName);
  end;

  if (DefaultName = string.Empty) or (DefaultName = OriginalName) then
    Exit;

  // Build a confirmation message with the affected files
  fileList := string.Empty;
  for i := 0 to selCount - 1 do
  begin
    if i < 10 then
      fileList := fileList + AForm.PoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + Format(rmorefiles, [selCount - 10]) + sLineBreak;
  end;

  msg := Format(rrenameconfirm, [selCount, DefaultName, fileList]);
  if AConfirm and (MessageDlg(rconfirmrenametitle, msg, mtConfirmation, mbYesNo, 0) <> mrYes) then
    Exit;

  // Rename each selected file on disk keeping its language code and extension
  RenamedCount := 0;
  Screen.Cursor := crHourGlass;
  try
    for i := 0 to selCount - 1 do
    begin
      FileName := AForm.PoFiles[SelectedIndices[i]];
      Dir := ExtractFilePath(FileName);
      BaseName := ChangeFileExt(ExtractFileName(FileName), '');

      p := RPos('.', BaseName);
      if p > 1 then
        LangPart := Copy(BaseName, p, MaxInt)   // includes the leading dot
      else
        LangPart := string.Empty;

      NewName := Dir + DefaultName + LangPart + ExtractFileExt(FileName);

      if SameFileName(FileName, NewName) then
        Continue;

      if not RenameFile(FileName, NewName) then
      begin
        // Show the warning without the hourglass cursor
        Screen.Cursor := crDefault;
        ReportMessageFmt(rrenamefailed, [FileName], AConfirm);
        Screen.Cursor := crHourGlass;
        Continue;
      end;

      // Update the in-memory path; the file content is unchanged,
      // so the status entry stays the same
      AForm.PoFiles[SelectedIndices[i]] := NewName;

      // Keep the currently opened file and the reference POT file in sync
      if SameFileName(FileName, AForm.FileName) then
        AForm.FileName := NewName;

      Inc(RenamedCount);
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  if RenamedCount = 0 then
    Exit;

  // Re-sort the file list; a renamed file can move to a new position
  SortList := TStringList.Create;
  try
    SortList.Sorted := False;
    for i := 0 to AForm.PoFiles.Count - 1 do
      if i < Length(AForm.FileStatuses) then
        SortList.AddObject(AForm.PoFiles[i], TObject(PtrInt(Ord(AForm.FileStatuses[i]))))
      else
        SortList.AddObject(AForm.PoFiles[i], TObject(PtrInt(Ord(psEmptyTranslation))));

    SortList.Sort;

    for i := 0 to SortList.Count - 1 do
      AForm.PoFiles[i] := SortList[i];

    // Properties cannot be passed by var to SetLength, use a local copy
    Statuses := AForm.FileStatuses;
    SetLength(Statuses, SortList.Count);
    for i := 0 to SortList.Count - 1 do
      Statuses[i] := TPoFileStatus(PtrInt(SortList.Objects[i]));
    AForm.FileStatuses := Statuses;
  finally
    SortList.Free;
  end;

  // Rebuild the visible list and keep the same file selected after reordering
  AForm.ListPath.Items.BeginUpdate;
  try
    AForm.ListPath.Items.Clear;
    for i := 0 to AForm.PoFiles.Count - 1 do
      AForm.ListPath.Items.Add(ExtractFileName(AForm.PoFiles[i]));

    NewIdx := AForm.PoFiles.IndexOf(AForm.FileName);
    if NewIdx >= 0 then
    begin
      AForm.ListPath.Selected[NewIdx] := True;
      AForm.ListPath.ItemIndex := NewIdx;
      AForm.PathIndex := NewIdx;
      AForm.LastPathIndex := NewIdx;
    end
    else
    begin
      AForm.PathIndex := -1;
      AForm.LastPathIndex := -1;
    end;
  finally
    AForm.ListPath.Items.EndUpdate;
  end;

  AForm.ListPath.Invalidate;
  AForm.UpdateCaption;
end;

class procedure TBatchOp.DeleteFiles(AForm: TformPoBatch; AConfirm: boolean = True);
var
  i, Count, idx: integer;
  selectedIndices: array of integer = ();
  msg, fileList: string;
  FileToDelete: string;
  CurrentFileDeleted: boolean;
  NewIdx: integer;
  Statuses: TPOFileStatusArray;
begin
  // Collect indices of selected items
  SetLength(selectedIndices, AForm.ListPath.Items.Count);
  Count := 0;
  for i := 0 to AForm.ListPath.Items.Count - 1 do
    if AForm.ListPath.Selected[i] then
    begin
      selectedIndices[Count] := i;
      Inc(Count);
    end;
  SetLength(selectedIndices, Count);

  if Count = 0 then
  begin
    ReportMessage(rselectdeletemessage, AConfirm);
    Exit;
  end;

  if Count = 1 then
  begin
    // Single file deletion (original behavior)
    if AConfirm and (MessageDlg(rdeletetitle, rdeletesingleconfirm, mtConfirmation, mbYesNo, 0) <> mrYes) then
      Exit;
  end
  else
  begin
    // Multiple files deletion: show names (up to 10) and total count
    fileList := string.Empty;
    for i := 0 to Count - 1 do
    begin
      if i < 10 then
        fileList := fileList + AForm.PoFiles[selectedIndices[i]] + sLineBreak
      else if i = 10 then
        fileList := fileList + Format(rmorefiles, [Count - 10]) + sLineBreak;
    end;
    msg := Format(rdeletemultipleconfirm, [Count, fileList]);

    if AConfirm and (MessageDlg(rdeletefilestitle, msg, mtConfirmation, mbYesNo, 0) <> mrYes) then
      Exit;
  end;

  // Delete files from disk and drop them from the in-memory lists
  CurrentFileDeleted := False;
  Screen.Cursor := crHourGlass;
  try
    // Properties cannot be passed by var to Delete, use a local copy
    Statuses := AForm.FileStatuses;

    // Walk the saved indices from the end so earlier ones stay valid while removing
    for i := Count - 1 downto 0 do
    begin
      idx := selectedIndices[i];
      if (idx < 0) or (idx >= AForm.PoFiles.Count) then
        Continue;

      FileToDelete := AForm.PoFiles[idx];

      // Remember whether the currently opened file is going away
      if SameFileName(FileToDelete, AForm.FileName) then
        CurrentFileDeleted := True;

      DeleteFile(FileToDelete);

      // Remove the entry from the path list and keep statuses aligned
      AForm.PoFiles.Delete(idx);
      if idx < Length(Statuses) then
        Delete(Statuses, idx, 1);
    end;

    AForm.FileStatuses := Statuses;

    // If the currently opened file was removed, reset to an empty document
    if CurrentFileDeleted then
      AForm.NewFile;
  finally
    Screen.Cursor := crDefault;
  end;

  // Rebuild the visible list and restore the selection when possible
  AForm.ListPath.Items.BeginUpdate;
  try
    AForm.ListPath.Items.Clear;
    for i := 0 to AForm.PoFiles.Count - 1 do
      AForm.ListPath.Items.Add(ExtractFileName(AForm.PoFiles[i]));

    NewIdx := AForm.PoFiles.IndexOf(AForm.FileName);
    if NewIdx >= 0 then
    begin
      AForm.ListPath.Selected[NewIdx] := True;
      AForm.ListPath.ItemIndex := NewIdx;
      AForm.PathIndex := NewIdx;
      AForm.LastPathIndex := NewIdx;
    end
    else
    begin
      AForm.PathIndex := -1;
      AForm.LastPathIndex := -1;
    end;
  finally
    AForm.ListPath.Items.EndUpdate;
  end;

  AForm.ListPath.Invalidate;
  AForm.UpdateCaption;
end;

class procedure TBatchOp.NewFilesFromPot(AForm: TformPoBatch; const APotFileName: string = '';
  ALangCodes: TStrings = nil; AConfirm: boolean = True);
var
  PotFileName: string;
  SelIdx: integer;
  SelFile: string;
  Codes: TStringArray = nil;
  BaseName: string;
  NewFileNames: TStringArray = nil;
  NewFileName: string;
  LastCreatedFile: string;
  i, NewIdx, CreatedCount: integer;
  SortList: TStringList;
  ExistingList: string;
  HasExisting: boolean;
  Statuses: TPOFileStatusArray;
begin
  PotFileName := string.Empty;

  // Use the POT from the console when supplied, otherwise resolve it
  if APotFileName <> string.Empty then
    PotFileName := APotFileName
  else
  begin
    SelIdx := AForm.ListPath.ItemIndex;

    if (SelIdx >= 0) and (SelIdx < AForm.PoFiles.Count) then
    begin
      SelFile := AForm.PoFiles[SelIdx];
      PotFileName := FindPotForFile(SelFile);
      if PotFileName = string.Empty then
      begin
        ReportMessageFmt(rnopotforfile, [SelFile], AConfirm);
        Exit;
      end;
    end
    else
    begin
      // No selection - ask the user to pick the source POT file
      if not AConfirm then
      begin
        ReportMessage(rpotconsoleerror, AConfirm);
        Exit;
      end;
      AForm.dialogOpen.FilterIndex := 2;
      if not AForm.dialogOpen.Execute then
        Exit;
      PotFileName := AForm.dialogOpen.FileName;
    end;
  end;

  if not FileExists(PotFileName) then
  begin
    ReportMessageFmt(rpotnotfound, [PotFileName], AConfirm);
    Exit;
  end;

  // Ask to save the current file if modified - abort if user cancels
  if not AForm.IsCanClose(True) then
    Exit;

  // Use the language codes from the console when supplied, otherwise ask
  if Assigned(ALangCodes) and (ALangCodes.Count > 0) then
  begin
    SetLength(Codes, ALangCodes.Count);
    for i := 0 to ALangCodes.Count - 1 do
      Codes[i] := Trim(ALangCodes[i]);
  end
  else
  begin
    if not AConfirm then
    begin
      ReportMessage(rlangsconsoleerror, AConfirm);
      Exit;
    end;
    if not SelectLanguages(Codes, [cqoEditable]) then
      Exit;
  end;
  if Length(Codes) = 0 then
    Exit;

  // Build all target file names and collect the ones that already exist
  BaseName := ChangeFileExt(ExtractFileName(PotFileName), '');
  SetLength(NewFileNames, Length(Codes));
  HasExisting := False;
  ExistingList := string.Empty;
  for i := 0 to High(Codes) do
  begin
    NewFileNames[i] := IncludeTrailingPathDelimiter(ExtractFilePath(PotFileName)) + BaseName + '.' + Codes[i] + '.po';
    if FileExists(NewFileNames[i]) then
    begin
      HasExisting := True;
      ExistingList := ExistingList + NewFileNames[i] + sLineBreak;
    end;
  end;

  // Confirm overwriting existing files once, for all languages together
  if HasExisting then
  begin
    if AConfirm and (MessageDlg(rfilesexisttitle, Format(rfilesexistconfirm, [ExistingList]), mtConfirmation, mbYesNo, 0) <>
      mrYes) then
      Exit;
  end;

  Screen.Cursor := crHourGlass;
  try
    // Create a PO file for every selected language
    CreatedCount := 0;
    LastCreatedFile := string.Empty;
    for i := 0 to High(Codes) do
    begin
      if AForm.CreatePoFileFromPot(PotFileName, Codes[i], NewFileName) then
      begin
        AForm.PoFiles.Add(NewFileName);
        LastCreatedFile := NewFileName;
        Inc(CreatedCount);
      end;
    end;

    if CreatedCount = 0 then
      Exit;

    // The last created file is already loaded and saved, so drop the modified flag
    AForm.Changed := False;
    AForm.UpdateTranslatePanel;

    // Re-sort the file list keeping statuses aligned; new files get their status computed
    SortList := TStringList.Create;
    try
      for i := 0 to AForm.PoFiles.Count - 1 do
        if i < Length(AForm.FileStatuses) then
          SortList.AddObject(AForm.PoFiles[i], TObject(PtrInt(Ord(AForm.FileStatuses[i]))))
        else
          SortList.AddObject(AForm.PoFiles[i], TObject(PtrInt(Ord(TPOFile.GetFileStatus(AForm.PoFiles[i])))));

      SortList.Sort;

      AForm.PoFiles.Assign(SortList);

      // Properties cannot be passed by var to SetLength, use a local copy
      Statuses := AForm.FileStatuses;
      SetLength(Statuses, SortList.Count);
      for i := 0 to SortList.Count - 1 do
        Statuses[i] := TPoFileStatus(PtrInt(SortList.Objects[i]));
      AForm.FileStatuses := Statuses;
    finally
      SortList.Free;
    end;

    // Rebuild the visible list and select the last created file
    AForm.ListPath.Items.BeginUpdate;
    try
      AForm.ListPath.Items.Clear;
      for i := 0 to AForm.PoFiles.Count - 1 do
        AForm.ListPath.Items.Add(ExtractFileName(AForm.PoFiles[i]));

      NewIdx := AForm.PoFiles.IndexOf(LastCreatedFile);
      if NewIdx >= 0 then
      begin
        AForm.ListPath.Selected[NewIdx] := True;
        AForm.ListPath.ItemIndex := NewIdx;
        AForm.PathIndex := NewIdx;
        AForm.LastPathIndex := NewIdx;
      end;
    finally
      AForm.ListPath.Items.EndUpdate;
    end;

    AForm.ListPath.Invalidate;
    AForm.UpdateCaption;
  finally
    Screen.Cursor := crDefault;
  end;
end;

class procedure TBatchOp.PathTranslateEmpty(AForm: TformPoBatch; AConfirm: boolean = True);
var
  i, k, selCount: integer;
  PoFile: TPOFile;
  Entry: TPOEntry;
  FileName: string;
  fileList, msg, BatchText, TranslatedBatch: string;
  SelectedIndices: array of integer = nil;
  BatchEntries: array of TPOEntry = nil;
  MultiEntries: array of TPOEntry = nil;
  ResponseLines: TStringList;
  TotalTranslated, FilesTranslated, SkippedFiles: integer;
  TranslatedInFile: integer;
  FileLang, SrcLang: string;
  OrigSource, OrigTarget: string;
  MaxBatchBytes: integer;
  ChunkStart, ChunkEnd, ChunkSize: integer;
  ChunkBytes, LineBytes: integer;
  ResponseSnippet: string;
  SnippetIdx: integer;

// Detect the target language from a PO header, falling back to the file name suffix
  function DetectFileLanguage(AFile: TPOFile; const AFileName: string): string;
  var
    HeaderLang, BaseName, LangCode: string;
    Parts: TStringArray;
  begin
    Result := string.Empty;

    HeaderLang := Trim(AFile.HeaderValue['Language']);
    if HeaderLang <> string.Empty then
      Exit(HeaderLang);

    if not SameText(ExtractFileExt(AFileName), '.po') then
      Exit;

    BaseName := ChangeFileExt(ExtractFileName(AFileName), '');
    Parts := BaseName.Split('.');
    if Length(Parts) > 1 then
    begin
      LangCode := Trim(Parts[High(Parts)]);
      if LangCode <> BaseName then
        Result := LangCode;
    end;
  end;

begin
  // Collect selected indices before processing
  SetLength(SelectedIndices, AForm.ListPath.Items.Count);
  selCount := 0;
  for i := 0 to AForm.ListPath.Items.Count - 1 do
    if AForm.ListPath.Selected[i] then
    begin
      SelectedIndices[selCount] := i;
      Inc(selCount);
    end;
  SetLength(SelectedIndices, selCount);

  if selCount = 0 then
  begin
    ReportMessage(rnopofilesselected, AConfirm);
    Exit;
  end;

  // Reject early when no translation configuration is selected
  if Trim(AForm.Translate.ConfigFile) = string.Empty then
  begin
    ReportMessage(rtranslationconfignotselected, AConfirm);
    Exit;
  end;

  // Build the confirmation message with the affected files

  // Build the confirmation message with the affected files
  fileList := string.Empty;
  for i := 0 to selCount - 1 do
  begin
    if i < 10 then
      fileList := fileList + AForm.PoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + Format(rmorefiles, [selCount - 10]) + sLineBreak;
  end;

  msg := Format(rtranslatemissingconfirm, [selCount, fileList]);
  if AConfirm and (MessageDlg(rtranslatemissingtitle, msg, mtConfirmation, mbYesNo, 0) <> mrYes) then
    Exit;

  // Ask to save current file if modified - abort if user cancels
  if not AForm.IsCanClose(True) then
    Exit;

  // Remember the current language pair so it can be restored afterwards
  OrigSource := AForm.Translate.SourceLanguage;
  OrigTarget := AForm.Translate.TargetLanguage;

  TotalTranslated := 0;
  FilesTranslated := 0;
  SkippedFiles := 0;
  ResponseLines := TStringList.Create;
  Screen.Cursor := crHourGlass;
  try
    for i := 0 to selCount - 1 do
    begin
      FileName := AForm.PoFiles[SelectedIndices[i]];
      if not FileExists(FileName) then
      begin
        Screen.Cursor := crDefault;
        ReportMessageFmt(rfilenotfound, [FileName], AConfirm);
        Screen.Cursor := crHourGlass;
        Continue;
      end;

      // Skip POT files - they contain no translations
      if SameText(ExtractFileExt(FileName), '.pot') then
        Continue;

      PoFile := TPOFile.Create;
      try
        try
          PoFile.LoadFromFile(FileName);

          // Detect the target language from this file's own header or
          // file name; do not borrow the language of the open document
          FileLang := DetectFileLanguage(PoFile, FileName);

          if FileLang = string.Empty then
          begin
            Inc(SkippedFiles);
            Screen.Cursor := crDefault;
            ReportMessageFmt(rfilelangnotset, [ExtractFileName(FileName)], AConfirm);
            Screen.Cursor := crHourGlass;
            Continue;
          end;

          SrcLang := Trim(PoFile.HeaderValue['X-Source-Language']);
          if SrcLang = string.Empty then
            SrcLang := 'en';
          AForm.Translate.SourceLanguage := SrcLang;
          AForm.Translate.TargetLanguage := FileLang;

          // Collect untranslated entries into two groups
          SetLength(BatchEntries, 0);
          SetLength(MultiEntries, 0);

          for k := 0 to PoFile.Entries.Count - 1 do
          begin
            Entry := PoFile.Entries[k];
            if Entry.MsgId = string.Empty then
              Continue;
            if Trim(Entry.MsgStrSimple) <> string.Empty then
              Continue;

            if (Pos(#10, Entry.MsgId) > 0) or (Pos(#13, Entry.MsgId) > 0) then
            begin
              SetLength(MultiEntries, Length(MultiEntries) + 1);
              MultiEntries[High(MultiEntries)] := Entry;
            end
            else
            begin
              SetLength(BatchEntries, Length(BatchEntries) + 1);
              BatchEntries[High(BatchEntries)] := Entry;
            end;
          end;

          if (Length(BatchEntries) = 0) and (Length(MultiEntries) = 0) then
          begin
            Inc(SkippedFiles);
            Continue;
          end;

          TranslatedInFile := 0;

          // Single-line entries go out in chunks bounded by the translator's
          // MaxLength; the response must keep the same line count per chunk,
          // otherwise the mapping is unreliable
          if Length(BatchEntries) > 0 then
          begin
            MaxBatchBytes := AForm.Translate.MaxLength;
            if MaxBatchBytes > 0 then
              MaxBatchBytes := MaxBatchBytes * 9 div 10;  // safety margin

            ChunkStart := 0;
            while ChunkStart < Length(BatchEntries) do
            begin
              // Collect lines for the next chunk without exceeding the limit
              BatchText := string.Empty;
              ChunkEnd := ChunkStart;
              ChunkBytes := 0;
              while ChunkEnd < Length(BatchEntries) do
              begin
                LineBytes := Length(BatchEntries[ChunkEnd].MsgId);
                if ChunkEnd > ChunkStart then
                  Inc(LineBytes, Length(sLineBreak));
                if (MaxBatchBytes > 0) and (ChunkEnd > ChunkStart) and (ChunkBytes + LineBytes > MaxBatchBytes) then
                  Break;
                if ChunkEnd > ChunkStart then
                  BatchText := BatchText + sLineBreak;
                BatchText := BatchText + BatchEntries[ChunkEnd].MsgId;
                Inc(ChunkBytes, LineBytes);
                Inc(ChunkEnd);
              end;

              ChunkSize := ChunkEnd - ChunkStart;
              if ChunkSize = 0 then
                Break;  // safety guard

              TranslatedBatch := AForm.Translate.TranslateSync(BatchText);
              ResponseLines.Text := TranslatedBatch;

              if ResponseLines.Count = ChunkSize then
              begin
                for k := 0 to ChunkSize - 1 do
                begin
                  BatchEntries[ChunkStart + k].MsgStrSimple := ResponseLines[k];
                  BatchEntries[ChunkStart + k].IsFuzzy := True;
                  Inc(TranslatedInFile);
                end;
              end
              else
              begin
                Screen.Cursor := crDefault;
                // Include the raw response, truncated to the first 20 lines
                ResponseSnippet := string.Empty;
                for SnippetIdx := 0 to Min(ResponseLines.Count, 20) - 1 do
                begin
                  if SnippetIdx > 0 then
                    ResponseSnippet := ResponseSnippet + sLineBreak;
                  ResponseSnippet := ResponseSnippet + ResponseLines[SnippetIdx];
                end;
                if ResponseLines.Count > 20 then
                  ResponseSnippet := ResponseSnippet + sLineBreak + Format(rmorelines, [ResponseLines.Count - 20]);
                ReportMessageFmt(rtranslationlinecount,
                  [ExtractFileName(FileName), ResponseLines.Count, ChunkSize, ResponseSnippet], AConfirm);
                Screen.Cursor := crHourGlass;
              end;

              ChunkStart := ChunkEnd;
              Application.ProcessMessages;
            end;
          end;

          // Multi-line entries are translated one by one to keep their
          // internal line structure intact
          for k := 0 to High(MultiEntries) do
          begin
            TranslatedBatch := AForm.Translate.TranslateSync(MultiEntries[k].MsgId);
            if TranslatedBatch <> string.Empty then
            begin
              MultiEntries[k].MsgStrSimple := TranslatedBatch;
              MultiEntries[k].IsFuzzy := True;
              Inc(TranslatedInFile);
            end;
            Application.ProcessMessages;
          end;

          if TranslatedInFile > 0 then
          begin
            PoFile.SaveToFile(FileName);
            Inc(TotalTranslated, TranslatedInFile);
            Inc(FilesTranslated);

            // Refresh the status in the path list
            AForm.AnalizePath(SelectedIndices[i]);

            // Reload the current file if it was the one processed
            if SameFileName(FileName, AForm.FileName) then
              AForm.ReloadCurrentFile(AForm.FileName);
          end
          else
          begin
            Inc(SkippedFiles);
            Screen.Cursor := crDefault;
            ReportMessageFmt(rfiletranslationnone, [ExtractFileName(FileName), FileLang], AConfirm);
            Screen.Cursor := crHourGlass;
          end;
        except
          on E: Exception do
          begin
            Screen.Cursor := crDefault;
            ReportMessageFmt(rerrorprocessingfile, [FileName, E.Message], AConfirm);
            Screen.Cursor := crHourGlass;
          end;
        end;
      finally
        PoFile.Free;
      end;
    end;
  finally
    // Restore the language pair of the currently opened document
    AForm.Translate.SourceLanguage := OrigSource;
    AForm.Translate.TargetLanguage := OrigTarget;
    ResponseLines.Free;
    Screen.Cursor := crDefault;
  end;

  ReportSuccessFmt(AForm, rdonetranslationsadded,
    [TotalTranslated, FilesTranslated, SkippedFiles], AConfirm);
end;

class procedure TBatchOp.SyncCurrentWithPot(AForm: TformPoBatch; const APotFileName: string = ''; AConfirm: boolean = True);
var
  PotFileName: string;
  Msg: string;
begin
  // Ask to save current changes if modified - abort if user cancels
  if not AForm.IsCanClose(True) then
    Exit;

  // Use the POT from the console when supplied, otherwise let the user pick one
  if APotFileName <> string.Empty then
    PotFileName := APotFileName
  else
  begin
    AForm.dialogOpen.FilterIndex := 2;
    if not AForm.dialogOpen.Execute then
      Exit;
    PotFileName := AForm.dialogOpen.FileName;
  end;

  if not FileExists(PotFileName) then
  begin
    ReportMessageFmt(rpotnotfound, [PotFileName], AConfirm);
    Exit;
  end;

  // Confirm synchronization
  Msg := Format(rsynccurrentconfirm, [AForm.FileName, PotFileName]);
  if AConfirm and (MessageDlg(rconfirmsynctitle, Msg, mtConfirmation, mbYesNo, 0) <> mrYes) then
    Exit;

  // Perform synchronization directly on the already loaded FPoFile object
  Screen.Cursor := crHourGlass;
  try
    try
      AForm.PoFile.SynchronizeToFile(PotFileName, True);   // keep existing header
    except
      on E: Exception do
      begin
        // Show the error dialog without the hourglass cursor
        Screen.Cursor := crDefault;
        ReportMessageFmt(rerrorsynccurrent, [E.Message], AConfirm);
        Exit;
      end;
    end;

    // Run QA checks once for the whole file
    AForm.PoFile.CheckAllQA;

    AForm.Changed := True;
    AForm.FillGrid;
    AForm.FillGridHeaders;
    AForm.UpdateTranslatePanel;
    if AForm.PathIndex >= 0 then
      AForm.AnalizePath(AForm.PathIndex);
  finally
    Screen.Cursor := crDefault;
  end;
end;

class procedure TBatchOp.MarkSelectedValid(AForm: TformPoBatch);
var
  StartRow, EndRow, Row: integer;
  EntryIndex: integer;
  Entry: TPOEntry;
  MarkedCount: integer;
begin
  // Check if there is anything to process
  if AForm.PoFile.Entries.Count = 0 then Exit;

  // Determine the row range from the current selection
  if AForm.Grid.Selection.Top = AForm.Grid.Selection.Bottom then
  begin
    StartRow := AForm.Grid.Row;
    EndRow := AForm.Grid.Row;
  end
  else
  begin
    StartRow := AForm.Grid.Selection.Top;
    EndRow := AForm.Grid.Selection.Bottom;
  end;

  // Only data rows are valid
  if StartRow < AForm.Grid.FixedRows then
    StartRow := AForm.Grid.FixedRows;
  if EndRow >= AForm.Grid.RowCount then
    EndRow := AForm.Grid.RowCount - 1;
  if StartRow > EndRow then
    Exit;

  // Ask for confirmation
  if MessageDlg(rmarkvalidgridtitle, Format(rmarkvalidgridconfirm, [EndRow - StartRow + 1]), mtConfirmation, mbYesNo, 0) <> mrYes then
    Exit;

  Screen.Cursor := crHourGlass;
  try
    // Save any pending grid changes back to the model
    AForm.Grid.EditorMode := False;
    AForm.SaveGrid;

    // Remove the fuzzy flag from the selected translatable entries
    MarkedCount := 0;
    for Row := StartRow to EndRow do
    begin
      EntryIndex := StrToIntDef(AForm.Grid.Cells[0, Row], -1);
      if (EntryIndex < 0) or (EntryIndex >= AForm.PoFile.Entries.Count) then
        Continue;

      Entry := AForm.PoFile.Entries[EntryIndex];
      if Entry.MsgId = '' then
        Continue;

      if Entry.IsFuzzy then
      begin
        Entry.IsFuzzy := False;
        Inc(MarkedCount);
      end;
    end;

    if MarkedCount = 0 then
    begin
      Screen.Cursor := crDefault;
      ShowMessage(rnofuzzyentries);
      Exit;
    end;

    AForm.Changed := True;

    // Rebuild the grid and update the UI
    AForm.FillGrid;
    AForm.FillGridHeaders;
    AForm.UpdateTranslatePanel;

    // Update the file status in the path list if applicable
    if AForm.PathIndex >= 0 then
      AForm.AnalizePath(AForm.PathIndex);

    Screen.Cursor := crDefault;
    if AForm.ShowSuccess then
      ShowMessageFmt(rmarkedvalidcount, [MarkedCount]);
  finally
    Screen.Cursor := crDefault;
  end;
end;

class procedure TBatchOp.CopySourceToTranslation(AForm: TformPoBatch);
var
  Row: integer;
  CopiedCount: integer;
  StartRow, EndRow: integer;
begin
  if MessageDlg(rcopysourcetotranslationconfirm, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  CopiedCount := 0;
  AForm.Grid.EditorMode := False;

  if AForm.Grid.Selection.Top = AForm.Grid.Selection.Bottom then
  begin
    StartRow := AForm.Grid.Row;
    EndRow := AForm.Grid.Row;
  end
  else
  begin
    StartRow := AForm.Grid.Selection.Top;
    EndRow := AForm.Grid.Selection.Bottom;
  end;

  for Row := StartRow to EndRow do
  begin
    AForm.Grid.Cells[CELL_TRANSLATION, Row] := AForm.Grid.Cells[CELL_TEXT, Row];
    AForm.UpdateValid(Row);
    Inc(CopiedCount);
  end;

  if CopiedCount > 0 then
  begin
    AForm.Changed := True;

    // Re-apply active column sort if any
    //if (FSortColumn >= 0) and (Grid.RowCount > Grid.FixedRows) then
    //  Grid.SortColRow(True, FSortColumn, Grid.FixedRows, Grid.RowCount - 1);
    //Grid.Invalidate;
  end;

  if AForm.ShowSuccess then
    MessageDlg(
      Format(rcopiedtranslationscount, [CopiedCount]),
      mtInformation,
      [mbOK],
      0
      );

  AForm.UpdateStatusBar;
  AForm.Grid.Invalidate;
end;

class procedure TBatchOp.ClearIdenticalTranslations(AForm: TformPoBatch);
var
  Row: integer;
  ReplacedCount: integer;
  StartRow, EndRow: integer;
begin
  if MessageDlg(rclearidenticalconfirm, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  ReplacedCount := 0;
  AForm.Grid.EditorMode := False;

  if AForm.Grid.Selection.Top = AForm.Grid.Selection.Bottom then
  begin
    StartRow := AForm.Grid.Row;
    EndRow := AForm.Grid.Row;
  end
  else
  begin
    StartRow := AForm.Grid.Selection.Top;
    EndRow := AForm.Grid.Selection.Bottom;
  end;

  for Row := StartRow to EndRow do
  begin
    if AForm.Grid.Cells[CELL_TEXT, Row] = AForm.Grid.Cells[CELL_TRANSLATION, Row] then
    begin
      AForm.Grid.Cells[CELL_TRANSLATION, Row] := string.Empty;
      AForm.Grid.Cells[CELL_VALID, Row] := '0';
      Inc(ReplacedCount);
    end;
  end;

  if ReplacedCount > 0 then
  begin
    AForm.Changed := True;

    // Re-apply active column sort if any
    //if (FSortColumn >= 0) and (Grid.RowCount > Grid.FixedRows) then
    //  Grid.SortColRow(True, FSortColumn, Grid.FixedRows, Grid.RowCount - 1);
    //Grid.Invalidate;
  end;

  if AForm.ShowSuccess then
    MessageDlg(
      Format(rclearedtranslationscount, [ReplacedCount]),
      mtInformation,
      [mbOK],
      0
      );

  AForm.UpdateStatusBar;
  AForm.Grid.Invalidate;
end;

class procedure TBatchOp.Translate(AForm: TformPoBatch; ASkipTranslated: boolean = False; AOnlySelected: boolean = True);
var
  StartRow, EndRow, Row: integer;
  EntryIndex, i: integer;
  Entry: TPOEntry;
  BatchEntries: array of TPOEntry = nil;
  BatchRows: array of integer = nil;
  MultiEntries: array of TPOEntry = nil;
  MultiRows: array of integer = nil;
  BatchText: string;
  TranslatedBatch: string;
  SourceText: string;
  ResponseLines: TStringList;
  BatchCount, MultiCount: integer;
  TotalTranslated: integer;
  SkippedCount: integer;
  ConfirmMsg: string;
  MaxBatchBytes: integer;
  ChunkStart, ChunkEnd, ChunkSize: integer;
  ChunkBytes, LineBytes: integer;
  ResponseSnippet: string;
  SnippetIdx: integer;
begin
  // Reject early when the target language is not known
  if Trim(AForm.Translate.TargetLanguage) = string.Empty then
  begin
    ShowMessage(rtargetlangnotset);
    Exit;
  end;

  // Reject early when no translation configuration is selected
  if Trim(AForm.Translate.ConfigFile) = string.Empty then
  begin
    ShowMessage(rtranslationconfignotselected);
    Exit;
  end;

  // Determine the row range: either the selected rows or the whole file
  if AOnlySelected then
  begin
    if AForm.Grid.Selection.Top = AForm.Grid.Selection.Bottom then
    begin
      StartRow := AForm.Grid.Row;
      EndRow := AForm.Grid.Row;
    end
    else
    begin
      StartRow := AForm.Grid.Selection.Top;
      EndRow := AForm.Grid.Selection.Bottom;
    end;
  end
  else
  begin
    StartRow := AForm.Grid.FixedRows;
    EndRow := AForm.Grid.RowCount - 1;
  end;

  // Only data rows are valid
  if StartRow < AForm.Grid.FixedRows then
    StartRow := AForm.Grid.FixedRows;
  if EndRow >= AForm.Grid.RowCount then
    EndRow := AForm.Grid.RowCount - 1;
  if StartRow > EndRow then
    Exit;

  if AOnlySelected then
  begin
    if ASkipTranslated then
      ConfirmMsg := Format(rtranslatemissingselected, [EndRow - StartRow + 1])
    else
      ConfirmMsg := Format(rtranslateselected, [EndRow - StartRow + 1]);
  end
  else
  begin
    if ASkipTranslated then
      ConfirmMsg := rtranslateallmissing
    else
      ConfirmMsg := rtranslateall;
  end;

  if MessageDlg(ConfirmMsg, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  // Ensure the grid data is pushed to the model before we look at entries
  AForm.Grid.EditorMode := False;
  AForm.SaveGrid;

  ResponseLines := TStringList.Create;
  try
    SkippedCount := 0;

    // Split the range into single-line and multi-line entries
    for Row := StartRow to EndRow do
    begin
      EntryIndex := StrToIntDef(AForm.Grid.Cells[0, Row], -1);
      if (EntryIndex < 0) or (EntryIndex >= AForm.PoFile.Entries.Count) then
        Continue;

      Entry := AForm.PoFile.Entries[EntryIndex];
      if Entry.MsgId = string.Empty then
        Continue;

      // Skip entries that already have a translation when requested
      if ASkipTranslated and (Trim(Entry.MsgStrSimple) <> string.Empty) then
      begin
        Inc(SkippedCount);
        Continue;
      end;

      if (Pos(#10, Entry.MsgId) > 0) or (Pos(#13, Entry.MsgId) > 0) then
      begin
        SetLength(MultiEntries, Length(MultiEntries) + 1);
        MultiEntries[High(MultiEntries)] := Entry;
        SetLength(MultiRows, Length(MultiRows) + 1);
        MultiRows[High(MultiRows)] := Row;
      end
      else
      begin
        SetLength(BatchEntries, Length(BatchEntries) + 1);
        BatchEntries[High(BatchEntries)] := Entry;
        SetLength(BatchRows, Length(BatchRows) + 1);
        BatchRows[High(BatchRows)] := Row;
      end;
    end;

    BatchCount := Length(BatchEntries);
    MultiCount := Length(MultiEntries);

    if (BatchCount = 0) and (MultiCount = 0) then
    begin
      if ASkipTranslated and (SkippedCount > 0) then
        ShowMessage(rnothingtranslatedall)
      else
        ShowMessage(rnothingtranslated);
      Exit;
    end;

    TotalTranslated := 0;
    Screen.Cursor := crHourGlass;
    try
      // Single-line entries go out in chunks bounded by the translator's
      // MaxLength; the response must keep the same line count per chunk,
      // otherwise the mapping is unreliable
      if BatchCount > 0 then
      begin
        MaxBatchBytes := AForm.Translate.MaxLength;
        if MaxBatchBytes > 0 then
          MaxBatchBytes := MaxBatchBytes * 9 div 10;  // safety margin

        ChunkStart := 0;
        while ChunkStart < BatchCount do
        begin
          // Collect lines for the next chunk without exceeding the limit
          BatchText := string.Empty;
          ChunkEnd := ChunkStart;
          ChunkBytes := 0;
          while ChunkEnd < BatchCount do
          begin
            LineBytes := Length(BatchEntries[ChunkEnd].MsgId);
            if ChunkEnd > ChunkStart then
              Inc(LineBytes, Length(sLineBreak));
            if (MaxBatchBytes > 0) and (ChunkEnd > ChunkStart) and (ChunkBytes + LineBytes > MaxBatchBytes) then
              Break;
            if ChunkEnd > ChunkStart then
              BatchText := BatchText + sLineBreak;
            BatchText := BatchText + BatchEntries[ChunkEnd].MsgId;
            Inc(ChunkBytes, LineBytes);
            Inc(ChunkEnd);
          end;

          ChunkSize := ChunkEnd - ChunkStart;
          if ChunkSize = 0 then
            Break;  // safety guard

          try
            TranslatedBatch := AForm.Translate.TranslateSync(BatchText);
          except
            on E: Exception do
            begin
              Screen.Cursor := crDefault;
              ShowMessageFmt(rtranslationerror, [E.Message]);
              Exit;
            end;
          end;

          ResponseLines.Text := TranslatedBatch;

          if ResponseLines.Count = ChunkSize then
          begin
            for i := 0 to ChunkSize - 1 do
            begin
              Entry := BatchEntries[ChunkStart + i];
              Entry.MsgStrSimple := ResponseLines[i];
              Entry.IsFuzzy := True;
              AForm.Grid.Cells[CELL_TRANSLATION, BatchRows[ChunkStart + i]] := ResponseLines[i];
              AForm.Grid.Cells[CELL_FUZZY, BatchRows[ChunkStart + i]] := '1';
              AForm.UpdateValid(BatchRows[ChunkStart + i]);
              Inc(TotalTranslated);
            end;
          end
          else
          begin
            Screen.Cursor := crDefault;
            // Include the raw response, truncated to the first 20 lines
            ResponseSnippet := string.Empty;
            for SnippetIdx := 0 to Min(ResponseLines.Count, 20) - 1 do
            begin
              if SnippetIdx > 0 then
                ResponseSnippet := ResponseSnippet + sLineBreak;
              ResponseSnippet := ResponseSnippet + ResponseLines[SnippetIdx];
            end;
            if ResponseLines.Count > 20 then
              ResponseSnippet := ResponseSnippet + sLineBreak + Format(rmorelines, [ResponseLines.Count - 20]);
            ShowMessageFmt(rtranslationlinecountgrid, [ResponseLines.Count, ChunkSize, ResponseSnippet]);
            Screen.Cursor := crHourGlass;
          end;

          ChunkStart := ChunkEnd;
          Application.ProcessMessages;
        end;
      end;

      // Multi-line entries are translated one by one to keep their
      // internal line structure intact
      for i := 0 to MultiCount - 1 do
      begin
        Entry := MultiEntries[i];
        SourceText := Entry.MsgId;
        if SourceText = string.Empty then
          Continue;

        try
          TranslatedBatch := AForm.Translate.TranslateSync(SourceText);
        except
          on E: Exception do
            Continue;
        end;

        if TranslatedBatch <> string.Empty then
        begin
          Entry.MsgStrSimple := TranslatedBatch;
          Entry.IsFuzzy := True;
          AForm.Grid.Cells[CELL_TRANSLATION, MultiRows[i]] := TranslatedBatch;
          AForm.Grid.Cells[CELL_FUZZY, MultiRows[i]] := '1';
          AForm.UpdateValid(MultiRows[i]);
          Inc(TotalTranslated);
        end;

        // Keep the UI responsive between individual requests
        Application.ProcessMessages;
      end;

      if TotalTranslated > 0 then
      begin
        AForm.Changed := True;
        AForm.UpdateTranslatePanel;
        // Force a full repaint so the new fuzzy state and selection
        // colors are drawn correctly before the modal message appears
        AForm.Grid.Invalidate;
      end;
    finally
      Screen.Cursor := crDefault;
    end;

    if AForm.ShowSuccess then
    begin
      if ASkipTranslated and (SkippedCount > 0) then
        ShowMessageFmt(rtranslatedoneskipped,
          [TotalTranslated, SkippedCount])
      else
        ShowMessageFmt(rtranslatedone, [TotalTranslated]);
    end;
  finally
    ResponseLines.Free;
  end;
end;

end.
