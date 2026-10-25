//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

//  Console mode operations for PoBatch.
//  Usage:
//    pobatch <command> <target> [options]
//  Commands:
//    copy-source         copy source text into empty translations
//    clear-fuzzy         clear translations of fuzzy entries
//    clear-all           clear all translations (header is preserved)
//    mark-valid          remove the fuzzy flag from all entries
//    sync-pot            synchronize with the reference POT
//    translate           translate empty entries via the configured service
//    new-from-pot        create new PO files from a POT for the given languages
//    rename              rename files by base name
//  Targets (one is required for most commands):
//    --file <path>       process a single PO or POT file
//    --dir <path>        process all PO and POT files in a directory
//    --files <p1;p2>     semicolon-separated file list
//  Options:
//    --pot <path>        reference POT file (sync-pot, new-from-pot)
//    --langs <c1,c2>     target language codes (new-from-pot)
//    --name <base>       new base name (rename)
//    --config <path>     translation config file (name or full path)
//    --source <lang>     source language code (default: en)
//    --target <lang>     target language code
//    -h, --help          show this help and exit
//-----------------------------------------------------------------------------------

unit ConsoleOp;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  MainUnit;

type
  { TConsoleOp - command line entry point for batch operations }
  TConsoleOp = class
  public
    // Returns True when the command line contains a recognised command
    class function IsConsoleMode: boolean;
    // Returns True when only --help / -h is requested without a command
    class function IsHelpOnly: boolean;
    // Executes the requested operation on AForm; returns the process exit code
    class function Run(AForm: TformPoBatch): integer;
    // Writes the help text to standard output
    class procedure PrintHelp;
  end;

implementation

uses
  Forms,
  Dialogs,
  BatchOp,
  PoWrap,
  OSUtils;

type
  { Parsed command line parameters }
  TConsoleParams = record
    Command: string;
    FilePath: string;
    DirPath: string;
    FilesList: string;
    PotPath: string;
    LangsList: string;
    NewName: string;
    ConfigPath: string;
    SourceLang: string;
    TargetLang: string;
    Help: boolean;
  end;

const
  CMD_COPY_SOURCE = 'copy-source';
  CMD_CLEAR_FUZZY = 'clear-fuzzy';
  CMD_CLEAR_ALL = 'clear-all';
  CMD_MARK_VALID = 'mark-valid';
  CMD_SYNC_POT = 'sync-pot';
  CMD_TRANSLATE = 'translate';
  CMD_NEW_FROM_POT = 'new-from-pot';
  CMD_RENAME = 'rename';

  LOG_PREFIX = '[PoBatch] ';

procedure Log(const AMessage: string);
begin
  WriteLn(LOG_PREFIX + AMessage);
  Flush(Output);
end;

function IsKnownCommand(const AValue: string): boolean;
begin
  Result := (AValue = CMD_COPY_SOURCE) or (AValue = CMD_CLEAR_FUZZY) or (AValue = CMD_CLEAR_ALL) or
    (AValue = CMD_MARK_VALID) or (AValue = CMD_SYNC_POT) or (AValue = CMD_TRANSLATE) or (AValue = CMD_NEW_FROM_POT) or
    (AValue = CMD_RENAME);
end;

function ParseCommandLine: TConsoleParams;
var
  i: integer;
  Param: string;
begin
  Result.Command := string.Empty;
  Result.FilePath := string.Empty;
  Result.DirPath := string.Empty;
  Result.FilesList := string.Empty;
  Result.PotPath := string.Empty;
  Result.LangsList := string.Empty;
  Result.NewName := string.Empty;
  Result.ConfigPath := string.Empty;
  Result.SourceLang := string.Empty;
  Result.TargetLang := string.Empty;
  Result.Help := False;

  i := 1;
  while i <= ParamCount do
  begin
    Param := ParamStr(i);

    if (Param = '-h') or (Param = '--help') then
      Result.Help := True
    else if (Param = '--file') and (i < ParamCount) then
    begin
      Inc(i);
      Result.FilePath := ParamStr(i);
    end
    else if (Param = '--dir') and (i < ParamCount) then
    begin
      Inc(i);
      Result.DirPath := ParamStr(i);
    end
    else if (Param = '--files') and (i < ParamCount) then
    begin
      Inc(i);
      Result.FilesList := ParamStr(i);
    end
    else if (Param = '--pot') and (i < ParamCount) then
    begin
      Inc(i);
      Result.PotPath := ParamStr(i);
    end
    else if (Param = '--langs') and (i < ParamCount) then
    begin
      Inc(i);
      Result.LangsList := ParamStr(i);
    end
    else if (Param = '--name') and (i < ParamCount) then
    begin
      Inc(i);
      Result.NewName := ParamStr(i);
    end
    else if (Param = '--config') and (i < ParamCount) then
    begin
      Inc(i);
      Result.ConfigPath := ParamStr(i);
    end
    else if (Param = '--source') and (i < ParamCount) then
    begin
      Inc(i);
      Result.SourceLang := ParamStr(i);
    end
    else if (Param = '--target') and (i < ParamCount) then
    begin
      Inc(i);
      Result.TargetLang := ParamStr(i);
    end
    else if (Result.Command = string.Empty) and IsKnownCommand(Param) then
      Result.Command := Param;

    Inc(i);
  end;
end;

procedure SplitCommaList(const AValue: string; AList: TStrings);
var
  Parts: TStringArray;
  i: integer;
begin
  AList.Clear;
  if Trim(AValue) = string.Empty then Exit;
  Parts := AValue.Split([',']);
  for i := 0 to High(Parts) do
  begin
    Parts[i] := Trim(Parts[i]);
    if Parts[i] <> string.Empty then
      AList.Add(Parts[i]);
  end;
end;

function LoadTargetFiles(AForm: TformPoBatch; const Params: TConsoleParams): integer;
var
  i: integer;
  TempFiles: TStringList;
  Statuses: TPOFileStatusArray;
begin
  AForm.PoFiles.Clear;
  Statuses := AForm.FileStatuses;
  SetLength(Statuses, 0);
  AForm.FileStatuses := Statuses;

  if Params.FilePath <> string.Empty then
  begin
    if FileExists(Params.FilePath) then
      AForm.PoFiles.Add(ExpandFileName(Params.FilePath))
    else
      Log('Error: file not found: ' + Params.FilePath);
  end
  else if Params.DirPath <> string.Empty then
  begin
    if DirectoryExists(Params.DirPath) then
    begin
      TempFiles := TStringList.Create;
      try
        TOS.FindFilesByMasks(Params.DirPath, ['*.po', '*.pot'], TempFiles);
        AForm.PoFiles.Assign(TempFiles);
      finally
        TempFiles.Free;
      end;
    end
    else
      Log('Error: directory not found: ' + Params.DirPath);
  end
  else if Params.FilesList <> string.Empty then
  begin
    TempFiles := TStringList.Create;
    try
      TempFiles.Delimiter := ';';
      TempFiles.StrictDelimiter := True;
      TempFiles.DelimitedText := Params.FilesList;
      for i := 0 to TempFiles.Count - 1 do
      begin
        if TempFiles[i] = string.Empty then Continue;
        if FileExists(TempFiles[i]) then
          AForm.PoFiles.Add(ExpandFileName(TempFiles[i]))
        else
          Log('Error: file not found: ' + TempFiles[i]);
      end;
    finally
      TempFiles.Free;
    end;
  end;

  // Populate the visible list before selecting, because assigning
  // ItemIndex resets the multi-selection to a single item
  AForm.ListPath.Items.BeginUpdate;
  try
    AForm.ListPath.Items.Clear;
    for i := 0 to AForm.PoFiles.Count - 1 do
      AForm.ListPath.Items.Add(ExtractFileName(AForm.PoFiles[i]));
  finally
    AForm.ListPath.Items.EndUpdate;
  end;

  // Focus the first entry first, then select every file;
  // this order preserves multi-selection across widgetsets
  if AForm.PoFiles.Count > 0 then
    AForm.ListPath.ItemIndex := 0;
  for i := 0 to AForm.ListPath.Items.Count - 1 do
    AForm.ListPath.Selected[i] := True;

  Result := AForm.PoFiles.Count;
end;

class function TConsoleOp.IsConsoleMode: boolean;
var
  i: integer;
  Param: string;
begin
  for i := 1 to ParamCount do
  begin
    Param := ParamStr(i);

    // Help requests always run in console mode
    if (Param = '-h') or (Param = '--help') then
      Exit(True);

    if IsKnownCommand(Param) then
      Exit(True);
  end;
  Result := False;
end;

class function TConsoleOp.IsHelpOnly: boolean;
var
  i: integer;
  Param: string;
  HasHelp: boolean = False;
begin
  for i := 1 to ParamCount do
  begin
    Param := ParamStr(i);

    if (Param = '-h') or (Param = '--help') then
      HasHelp := True
    else if IsKnownCommand(Param) then
      // A real command is present: --help is only informational, form is needed
      Exit(False);
  end;
  Result := HasHelp;
end;

class procedure TConsoleOp.PrintHelp;
begin
  WriteLn('PoBatch console mode');
  WriteLn;
  WriteLn('Usage:');
  WriteLn('  pobatch <command> <target> [options]');
  WriteLn;
  WriteLn('Commands:');
  WriteLn('  copy-source         copy source text into empty translations');
  WriteLn('  clear-fuzzy         clear translations of fuzzy entries');
  WriteLn('  clear-all           clear all translations (header is preserved)');
  WriteLn('  mark-valid          remove the fuzzy flag from all entries');
  WriteLn('  sync-pot            synchronize with the reference POT');
  WriteLn('  translate           translate empty entries via the configured service');
  WriteLn('  new-from-pot        create new PO files from a POT for the given languages');
  WriteLn('  rename              rename files by base name');
  WriteLn;
  WriteLn('Targets (one is required for most commands):');
  WriteLn('  --file <path>       process a single PO or POT file');
  WriteLn('  --dir <path>        process all PO and POT files in a directory');
  WriteLn('  --files <p1;p2>     semicolon-separated file list');
  WriteLn;
  WriteLn('Options:');
  WriteLn('  --pot <path>        reference POT file (sync-pot, new-from-pot)');
  WriteLn('  --langs <c1,c2>     target language codes (new-from-pot)');
  WriteLn('  --name <base>       new base name (rename)');
  WriteLn('  --config <path>     translation config file (name or full path)');
  WriteLn('  --source <lang>     source language code (default: en)');
  WriteLn('  --target <lang>     target language code');
  WriteLn('  -h, --help          show this help and exit');
  WriteLn;
end;

class function TConsoleOp.Run(AForm: TformPoBatch): integer;
var
  Params: TConsoleParams;
  FileCount: integer;
  LangList: TStringList;
begin
  Result := 1;
  Params := ParseCommandLine;

  if Params.Help or (Params.Command = string.Empty) then
  begin
    PrintHelp;
    if Params.Help then
      Exit(0)
    else
      Exit(1);
  end;

  Log('Command: ' + Params.Command);

  if Params.ConfigPath <> string.Empty then
  begin
    AForm.Translate.ConfigFile := Params.ConfigPath;
    Log('Translation config: ' + Params.ConfigPath);
  end;

  if Params.SourceLang <> string.Empty then
  begin
    AForm.Translate.SourceLanguage := Params.SourceLang;
    Log('Source language: ' + Params.SourceLang);
  end;

  if Params.TargetLang <> string.Empty then
  begin
    AForm.Translate.TargetLanguage := Params.TargetLang;
    Log('Target language: ' + Params.TargetLang);
  end;

  // Load target files into the form; new-from-pot does not need them
  FileCount := 0;
  if Params.Command <> CMD_NEW_FROM_POT then
  begin
    FileCount := LoadTargetFiles(AForm, Params);
    Log('Files to process: ' + IntToStr(FileCount));
    if FileCount = 0 then
    begin
      Log('Error: no target files');
      Exit(1);
    end;
  end;

  try
    case Params.Command of
      CMD_COPY_SOURCE:
      begin
        Log('Copying source to empty translations...');
        TBatchOp.CopySourceInFiles(AForm, False);
      end;

      CMD_CLEAR_FUZZY:
      begin
        Log('Clearing fuzzy translations...');
        TBatchOp.ClearInFiles(AForm, True, False);
      end;

      CMD_CLEAR_ALL:
      begin
        Log('Clearing all translations...');
        TBatchOp.ClearInFiles(AForm, False, False);
      end;

      CMD_MARK_VALID:
      begin
        Log('Removing fuzzy flags...');
        TBatchOp.MarkFilesValid(AForm, False);
      end;

      CMD_SYNC_POT:
      begin
        Log('Synchronizing with POT...');
        TBatchOp.SyncFilesWithPot(AForm, Params.PotPath, False);
      end;

      CMD_TRANSLATE:
      begin
        Log('Translating empty entries...');
        TBatchOp.PathTranslateEmpty(AForm, False);
      end;

      CMD_NEW_FROM_POT:
      begin
        Log('Creating PO files from POT...');
        LangList := TStringList.Create;
        try
          SplitCommaList(Params.LangsList, LangList);
          TBatchOp.NewFilesFromPot(AForm, Params.PotPath, LangList, False);
        finally
          LangList.Free;
        end;
      end;

      CMD_RENAME:
      begin
        Log('Renaming files to base name "' + Params.NewName + '"...');
        TBatchOp.RenameFiles(AForm, Params.NewName, False);
      end;

      else
      begin
        Log('Error: unknown command: ' + Params.Command);
        Exit(1);
      end;
    end;

    Result := 0;
    Log('Done.');
  except
    on E: Exception do
    begin
      Log('Error: ' + E.Message);
      Result := 1;
    end;
  end;
end;

end.
