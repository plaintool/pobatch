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
  public
    // Multi-file operations on the opened path
    class procedure CopySourceInFiles(AForm: TformPoBatch);
    class procedure ClearInvalidInFiles(AForm: TformPoBatch);
    class procedure MarkFilesValid(AForm: TformPoBatch);
    class procedure SyncFilesWithPot(AForm: TformPoBatch);
    class procedure RenameFiles(AForm: TformPoBatch);
    class procedure DeleteFiles(AForm: TformPoBatch);
    class procedure NewFilesFromPot(AForm: TformPoBatch);
    // Single-file operations
    class procedure SyncCurrentWithPot(AForm: TformPoBatch);
    class procedure MarkCurrentFileValid(AForm: TformPoBatch);
    // Grid-level operations
    class procedure CopySourceToTranslation(AForm: TformPoBatch);
    class procedure ClearIdenticalTranslations(AForm: TformPoBatch);
  end;

implementation

uses
  LangCodes, StringHelper, Localize, PoWrap;

  { TBatchOp }

class procedure TBatchOp.CopySourceInFiles(AForm: TformPoBatch);
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
    ShowMessage('No PO files selected.');
    Exit;
  end;

  // Build the confirmation message with the affected files
  fileList := string.Empty;
  for i := 0 to selCount - 1 do
  begin
    if i < 10 then
      fileList := fileList + AForm.PoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + '... and ' + IntToStr(selCount - 10) + ' more file(s)' + sLineBreak;
  end;

  msg := 'Copy source text to empty translations in the following ' + IntToStr(selCount) + ' file(s)?' +
    sLineBreak + 'This action cannot be undone within the application.' + sLineBreak + sLineBreak + fileList;
  if MessageDlg('Copy source to empty', msg, mtConfirmation, mbYesNo, 0) <> mrYes then
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
        ShowMessageFmt('File not found: %s', [FileName]);
        Screen.Cursor := crHourGlass;
        Continue;
      end;

      // Skip the reference POT file - it contains no translations
      if SameFileName(FileName, AForm.PotFile) then
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
            ShowMessageFmt('Error processing file "%s": %s', [FileName, E.Message]);
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

  ShowMessageFmt('Done. %d translation(s) filled from source.', [TotalCopied]);
end;

class procedure TBatchOp.ClearInvalidInFiles(AForm: TformPoBatch);
var
  i, j, selCount: integer;
  PoFile: TPOFile;
  Entry: TPOEntry;
  FileName: string;
  fileList, msg: string;
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
    ShowMessage('No PO files selected.');
    Exit;
  end;

  // Build the confirmation message with the affected files
  fileList := string.Empty;
  for i := 0 to selCount - 1 do
  begin
    if i < 10 then
      fileList := fileList + AForm.PoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + '... and ' + IntToStr(selCount - 10) + ' more file(s)' + sLineBreak;
  end;

  msg := 'Clear translations of fuzzy entries in the following ' + IntToStr(selCount) + ' file(s)?' +
    sLineBreak + 'This action cannot be undone within the application.' + sLineBreak + sLineBreak + fileList;
  if MessageDlg('Clear invalid translations', msg, mtConfirmation, mbYesNo, 0) <> mrYes then
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
        ShowMessageFmt('File not found: %s', [FileName]);
        Screen.Cursor := crHourGlass;
        Continue;
      end;

      // Skip the reference POT file - it contains no translations
      if SameFileName(FileName, AForm.PotFile) then
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
            // Only entries flagged as fuzzy (invalid) are affected
            if not Entry.IsFuzzy then
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
            ShowMessageFmt('Error processing file "%s": %s', [FileName, E.Message]);
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

  ShowMessageFmt('Done. %d invalid translation(s) cleared.', [TotalCleared]);
end;

class procedure TBatchOp.MarkFilesValid(AForm: TformPoBatch);
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
    ShowMessage('No PO files selected.');
    Exit;
  end;

  // Build file list for confirmation message
  fileList := '';
  for i := 0 to selCount - 1 do
  begin
    if i < 10 then
      fileList := fileList + AForm.PoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + '... and ' + IntToStr(selCount - 10) + ' more file(s)' + sLineBreak;
  end;

  msg := 'Mark the following ' + IntToStr(selCount) + ' file(s) as valid?' + sLineBreak +
    'This will remove the "fuzzy" flag from all entries.' + sLineBreak + 'This action cannot be undone within the application.' +
    sLineBreak + sLineBreak + fileList;
  if MessageDlg('Remove fuzzy flag', msg, mtConfirmation, mbYesNo, 0) <> mrYes then
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
        ShowMessageFmt('File not found: %s', [FileName]);
        Screen.Cursor := crHourGlass;
        Continue;
      end;

      // Skip the reference POT file - it contains no translations
      if SameFileName(FileName, AForm.PotFile) then
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
            ShowMessageFmt('Error processing file "%s": %s', [FileName, E.Message]);
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

  ShowMessage('Selected files have been marked as valid. All "fuzzy" flags were removed.');
end;

class procedure TBatchOp.SyncFilesWithPot(AForm: TformPoBatch);
var
  i, selCount: integer;
  PoFile: TPOFile;
  FileName: string;
  fileList, msg: string;
  SelectedIndices: array of integer = nil;
begin
  // Check if the reference POT file is specified
  if AForm.PotFile = '' then
  begin
    ShowMessage('No reference POT file exists in opened path.');
    Exit;
  end;

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
    ShowMessage('No PO files selected for synchronization.');
    Exit;
  end;

  // Build confirmation message
  fileList := '';
  for i := 0 to selCount - 1 do
  begin
    if i < 10 then
      fileList := fileList + AForm.PoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + '... and ' + IntToStr(selCount - 10) + ' more file(s)' + sLineBreak;
  end;

  msg := 'Synchronize the following ' + IntToStr(selCount) + ' file(s) with' + sLineBreak + 'reference POT: ' +
    AForm.PotFile + sLineBreak + 'This action cannot be undone within the application.' + sLineBreak + sLineBreak + fileList;
  if MessageDlg('Confirm synchronization', msg, mtConfirmation, mbYesNo, 0) <> mrYes then
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
        ShowMessageFmt('File not found: %s', [FileName]);
        Screen.Cursor := crHourGlass;
        Continue;
      end;

      // Skip the reference POT file itself to avoid self-synchronization
      if SameFileName(FileName, AForm.PotFile) then
        Continue;

      PoFile := TPOFile.Create;
      try
        try
          PoFile.LoadFromFile(FileName);
          PoFile.SynchronizeToFile(AForm.PotFile, True);
          PoFile.SaveToFile(FileName);
        except
          on E: Exception do
          begin
            // Show the error without the hourglass cursor
            Screen.Cursor := crDefault;
            ShowMessageFmt('Error synchronizing file "%s": %s', [FileName, E.Message]);
            Screen.Cursor := crHourGlass;
            Continue;    // skip reloading this file
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

  ShowMessage('Synchronization complete.');
end;

class procedure TBatchOp.RenameFiles(AForm: TformPoBatch);
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
    ShowMessage('Select file(s) to rename!');
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

  // Ask the user for the new base name; the language code and extension are kept
  InputQueryLite('Rename files', 'Enter new base name:', DefaultName);

  DefaultName := Trim(DefaultName);
  if (DefaultName = string.Empty) or (DefaultName = OriginalName) then
    Exit;

  // Build a confirmation message with the affected files
  fileList := string.Empty;
  for i := 0 to selCount - 1 do
  begin
    if i < 10 then
      fileList := fileList + AForm.PoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + '... and ' + IntToStr(selCount - 10) + ' more file(s)' + sLineBreak;
  end;

  msg := 'Rename the following ' + IntToStr(selCount) + ' file(s) using base name "' + DefaultName + '"?' +
    sLineBreak + sLineBreak + fileList;
  if MessageDlg('Confirm rename', msg, mtConfirmation, mbYesNo, 0) <> mrYes then
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
        ShowMessageFmt('Failed to rename: %s', [FileName]);
        Screen.Cursor := crHourGlass;
        Continue;
      end;

      // Update the in-memory path; the file content is unchanged,
      // so the status entry stays the same
      AForm.PoFiles[SelectedIndices[i]] := NewName;

      // Keep the currently opened file and the reference POT file in sync
      if SameFileName(FileName, AForm.FileName) then
        AForm.FileName := NewName;

      if SameFileName(FileName, AForm.PotFile) then
        AForm.PotFile := NewName;

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

class procedure TBatchOp.DeleteFiles(AForm: TformPoBatch);
var
  i, Count, idx: integer;
  selectedIndices: array of integer = ();
  msg, fileList: string;
  FileToDelete: string;
  CurrentFileDeleted: boolean;
  PotDeleted: boolean;
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
    ShowMessage('Select file to delete!');
    Exit;
  end;

  if Count = 1 then
  begin
    // Single file deletion (original behavior)
    if MessageDlg('Delete file', 'Are you sure you want to delete the selected file?', mtConfirmation, mbYesNo, 0) <> mrYes then
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
        fileList := fileList + '... and ' + IntToStr(Count - 10) + ' more file(s)' + sLineBreak;
    end;
    msg := 'Are you sure you want to delete the following ' + IntToStr(Count) + ' file(s)?' + sLineBreak + sLineBreak + fileList;

    if MessageDlg('Delete files', msg, mtConfirmation, mbYesNo, 0) <> mrYes then
      Exit;
  end;

  // Delete files from disk and drop them from the in-memory lists
  CurrentFileDeleted := False;
  PotDeleted := False;
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

      // Remember whether the currently opened file or the reference POT is going away
      if SameFileName(FileToDelete, AForm.FileName) then
        CurrentFileDeleted := True;
      if (AForm.PotFile <> string.Empty) and SameFileName(FileToDelete, AForm.PotFile) then
        PotDeleted := True;

      DeleteFile(FileToDelete);

      // Remove the entry from the path list and keep statuses aligned
      AForm.PoFiles.Delete(idx);
      if idx < Length(Statuses) then
        Delete(Statuses, idx, 1);
    end;

    AForm.FileStatuses := Statuses;

    if PotDeleted then
      AForm.PotFile := string.Empty;

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

class procedure TBatchOp.NewFilesFromPot(AForm: TformPoBatch);
var
  PotFileName: string;
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
  // Use the known reference POT, otherwise ask the user to pick one
  PotFileName := AForm.PotFile;
  if PotFileName = '' then
  begin
    AForm.dialogOpen.FilterIndex := 2;
    if not AForm.dialogOpen.Execute then
      Exit;
    PotFileName := AForm.dialogOpen.FileName;
  end;

  if not FileExists(PotFileName) then
  begin
    ShowMessageFmt('POT file not found: %s', [PotFileName]);
    Exit;
  end;

  // Ask to save the current file if modified - abort if user cancels
  if not AForm.IsCanClose(True) then
    Exit;

  // Ask the user to choose the target languages for the new PO files
  if not SelectLanguages(Codes, [cqoEditable]) then
    Exit;
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
    if MessageDlg('Files exist', 'The following files already exist:' + sLineBreak + sLineBreak +
      ExistingList + sLineBreak + 'Overwrite them?', mtConfirmation, mbYesNo, 0) <> mrYes then
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

class procedure TBatchOp.SyncCurrentWithPot(AForm: TformPoBatch);
var
  PotFileName: string;
  Msg: string;
begin
  // Ask to save current changes if modified - abort if user cancels
  if not AForm.IsCanClose(True) then
    Exit;

  // Let the user choose a POT file
  AForm.dialogOpen.FilterIndex := 2;
  if not AForm.dialogOpen.Execute then
    Exit;

  PotFileName := AForm.dialogOpen.FileName;
  if not FileExists(PotFileName) then
  begin
    ShowMessageFmt('POT file not found: %s', [PotFileName]);
    Exit;
  end;

  // Confirm synchronization
  Msg := 'Synchronize current file' + sLineBreak + '  ' + AForm.FileName + sLineBreak + 'with reference POT' +
    sLineBreak + '  ' + PotFileName + ' ?';
  if MessageDlg('Confirm synchronization', Msg, mtConfirmation, mbYesNo, 0) <> mrYes then
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
        ShowMessageFmt('Error synchronizing file: %s', [E.Message]);
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

class procedure TBatchOp.MarkCurrentFileValid(AForm: TformPoBatch);
var
  i: integer;
begin
  // Check if there is anything to process
  if AForm.PoFile.Entries.Count = 0 then Exit;

  // Ask for confirmation
  if MessageDlg('Mark as Valid', 'Mark the current file as valid?' + sLineBreak + 'This will remove the "fuzzy" flag from all entries.',
    mtConfirmation, mbYesNo, 0) <> mrYes then Exit;

  Screen.Cursor := crHourGlass;
  try
    // Save any pending grid changes back to the model
    AForm.SaveGrid;

    // Remove the fuzzy flag from every translatable entry
    for i := 0 to AForm.PoFile.Entries.Count - 1 do
    begin
      // Keep the header entry (empty msgid) untouched
      if AForm.PoFile.Entries[i].MsgId <> '' then
        AForm.PoFile.Entries[i].IsFuzzy := False;
    end;

    AForm.Changed := True;

    // Rebuild the grid and update the UI
    AForm.FillGrid;
    AForm.FillGridHeaders;
    AForm.UpdateTranslatePanel;

    // Update the file status in the path list if applicable
    if AForm.PathIndex >= 0 then
      AForm.AnalizePath(AForm.PathIndex);
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
  if MessageDlg('Copy source text to translations in the selected row(s)?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
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
  MessageDlg(
    Format('%d translations were copied.', [CopiedCount]),
    mtInformation,
    [mbOK],
    0
    );

  AForm.Grid.Invalidate;
end;

class procedure TBatchOp.ClearIdenticalTranslations(AForm: TformPoBatch);
var
  Row: integer;
  ReplacedCount: integer;
  StartRow, EndRow: integer;
begin
  if MessageDlg('Clear translations that are identical to the source text in the selected row(s)?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
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

  MessageDlg(
    Format('%d translations were cleared.', [ReplacedCount]),
    mtInformation,
    [mbOK],
    0
    );

  AForm.Grid.Invalidate;
end;

end.
