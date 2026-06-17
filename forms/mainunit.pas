//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the MIT License
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//-----------------------------------------------------------------------------------

unit mainunit;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  FileUtil,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  Menus,
  ComCtrls,
  StdCtrls,
  ExtCtrls,
  Grids,
  Process,
  Buttons,
  StrUtils,
  LCLType,
  LCLIntf, ActnList,
  powrap;

type

  { TformPoBatch }

  TformPoBatch = class(TForm)
    AAllowEditingAll: TAction;
    AUndoChanges: TAction;
    ActionList: TActionList;
    Filter: TEdit;
    GridHeaders: TStringGrid;
    ListPath: TListBox;
    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    MenuFileOpen: TMenuItem;
    MenuFileSave: TMenuItem;
    MenuFileExit: TMenuItem;
    MenuFileSaveAs: TMenuItem;
    MenuFileNew: TMenuItem;
    dialogOpen: TOpenDialog;
    menuHelp: TMenuItem;
    MenuBuyMeACoffee: TMenuItem;
    MenuCheckForUpdates: TMenuItem;
    MenuAbout: TMenuItem;
    MenuFileNewWindow: TMenuItem;
    MenuAutoCheckUpdates: TMenuItem;
    MenuClosePath: TMenuItem;
    MenuHeaders: TMenuItem;
    MenuColumnReference: TMenuItem;
    MenuEdit: TMenuItem;
    MenuAllowEditAll: TMenuItem;
    MenuUndoChanges: TMenuItem;
    MenuView: TMenuItem;
    MenuPathOpen: TMenuItem;
    PanelClient: TPanel;
    PanelFilter: TPanel;
    dialogSave: TSaveDialog;
    Separator2: TMenuItem;
    btnFilterClear: TSpeedButton;
    dialogPath: TSelectDirectoryDialog;
    Separator1: TMenuItem;
    Separator3: TMenuItem;
    SplitterHeaders: TSplitter;
    SplitterPath: TSplitter;
    StatusBar: TStatusBar;
    Grid: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure GridCompareCells(Sender: TObject; ACol, ARow, BCol, BRow: integer; var Result: integer);
    procedure GridValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
    procedure MenuAboutClick(Sender: TObject);
    procedure MenuAutoCheckUpdatesClick(Sender: TObject);
    procedure MenuClosePathClick(Sender: TObject);
    procedure MenuColumnReferenceClick(Sender: TObject);
    procedure MenuFileNewWindowClick(Sender: TObject);
    procedure MenuBuyMeACoffeeClick(Sender: TObject);
    procedure MenuCheckForUpdatesClick(Sender: TObject);
    procedure MenuFileExitClick(Sender: TObject);
    procedure MenuFileNewClick(Sender: TObject);
    procedure MenuFileOpenClick(Sender: TObject);
    procedure MenuFileSaveAsClick(Sender: TObject);
    procedure MenuFileSaveClick(Sender: TObject);
    procedure AUndoChangesExecute(Sender: TObject);
    procedure AAllowEditingAllExecute(Sender: TObject);
    procedure GridHeadersKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure GridHeadersValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
    procedure GridPrepareCanvas(Sender: TObject; aCol, aRow: integer; aState: TGridDrawState);
    procedure GridHeaderClick(Sender: TObject; IsColumn: boolean; Index: integer);
    procedure GridHeaderSized(Sender: TObject; IsColumn: boolean; Index: integer);
    procedure ListPathClick(Sender: TObject);
    procedure FilterChange(Sender: TObject);
    procedure btnFilterClearClick(Sender: TObject);
    procedure MenuHeadersClick(Sender: TObject);
    procedure MenuPathOpenClick(Sender: TObject);
    procedure PanelClientResize(Sender: TObject);
  private
    PoFile: TPoFile;
    FFileName: string;
    FPath: string;
    FPoFiles: TStringList;
    FChanged: boolean;
    FInitialized: boolean;
    FCommandLineFile: string;
    FAutoCheckUpdates: boolean;
    FSortOrder: TSortOrder;
    FSortColumn: integer;

    FLastPathIndex: integer;

    function IsCanClose: boolean;
    function PromptSaveChanges: TModalResult;
    procedure HandleCommandLineParameters;
    function ValidateFileForOpen(const AFileName: string): boolean;
    function NewFile(AFileName: string = string.Empty): boolean;
    function OpenFile(const AFileName: string): boolean;
    function OpenPath(const AFileName: string): boolean;
    procedure ClosePath;
    procedure UpdatePath;
    procedure SyncPath;
    function LoadFromFile(AFileName: string): boolean;
    function SaveFile(AFileName: string): boolean;
    procedure UpdateRowHeights;
    procedure SetChanges(Value: boolean);
    procedure UpdateCaption;
    procedure FixSplitters(Data: PtrInt);
    function EntryMatchesFilter(Entry: TPOEntry; const AFilter: string): boolean;
    procedure FillGrids;
    procedure SaveGrids;
  public
    property Changed: boolean read FChanged write SetChanges;
    property Path: string read FPath write FPath;
    property AutoCheckUpdates: boolean read FAutoCheckUpdates write FAutoCheckUpdates;
    property SortOrder: TSortOrder read FSortOrder write FSortOrder;
    property SortColumn: integer read FSortColumn write FSortColumn;
  end;

var
  formPoBatch: TformPoBatch;

const
  COL_HEADERS_NAME = 0;
  COL_HEADERS_VALUE = 1;

  COL_VALID = 0;
  COL_TEXT = 1;
  COL_TRANSLATION = 2;
  COL_REFERENCE = 3;
  COL_CONTEXT = 4;
  COL_PREVIOUS = 5;
  COL_FUZZY = 6;

implementation

uses formabout, formdonate, systemtool, formattool, settings;

  {$R *.lfm}

  { TformPoBatch }

procedure TformPoBatch.FormCreate(Sender: TObject);
begin
  // Enable file dropping
  AllowDropFiles := True;

  // Initialize state
  FInitialized := False;
  FAutoCheckUpdates := True;
  FFileName := string.Empty;
  FPath := string.Empty;
  FPoFiles := TStringList.Create;
  FCommandLineFile := string.Empty;
  FSortColumn := -1;
  FSortOrder := soAscending;
  FLastPathIndex := -1;

  LoadFormSettings(Self);

  // Create PoFile object
  PoFile := TPoFile.Create;
  NewFile;

  // Load the menu state
  MenuAutoCheckUpdates.Checked := FAutoCheckUpdates;

  // Handle command line parameters
  HandleCommandLineParameters;
end;

procedure TformPoBatch.FormDestroy(Sender: TObject);
begin
  SaveFormSettings(Self);

  FreeAndNil(PoFile);
  FreeAndNil(FPoFiles);
end;

procedure TformPoBatch.FormShow(Sender: TObject);
var
  Th: TCheckUpdateThread;
begin
  if not FInitialized then
  begin
    FInitialized := True;

    // Open Path
    if (Path <> string.Empty) and OpenPath(Path) then
      UpdatePath;

    // Open file from command line if specified, otherwise start with a new document
    if FCommandLineFile <> string.Empty then
    begin
      if not OpenFile(FCommandLineFile) then
        NewFile;
    end
    else
      NewFile;
  end;

  if AutoCheckUpdates then
  begin
    Th := TCheckUpdateThread.Create(False);
    Th.FreeOnTerminate := True;
  end;
end;

procedure TformPoBatch.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := IsCanClose;
end;

procedure TformPoBatch.FormDropFiles(Sender: TObject; const FileNames: array of string);
begin
  if Length(FileNames) = 0 then
    Exit;

  // Get the first dropped file
  OpenFile(FileNames[0]);
end;

procedure TformPoBatch.FormResize(Sender: TObject);
begin
  Application.QueueAsyncCall(@FixSplitters, 0);
end;

procedure TformPoBatch.MenuAboutClick(Sender: TObject);
begin
  formAboutPoBatch.ShowModal;
end;

procedure TformPoBatch.MenuFileNewWindowClick(Sender: TObject);
var
  Process: TProcess;
begin
  if Screen.ActiveForm <> Self then exit;

  SaveFormSettings(self); // Save setting for new process

  Process := TProcess.Create(nil); // Create a new process
  try
    Process.Executable := ParamStr(0); // Set the executable to the current application
    Process.Options := []; // No wait, open and forget
    Process.Execute; // Execute the new instance
  finally
    Process.Free; // Free the process object
  end;
end;

procedure TformPoBatch.MenuBuyMeACoffeeClick(Sender: TObject);
begin
  formDonatePoBatch.ShowModal;
end;

procedure TformPoBatch.MenuAutoCheckUpdatesClick(Sender: TObject);
begin
  FAutoCheckUpdates := MenuAutoCheckUpdates.Checked;
end;

procedure TformPoBatch.MenuCheckForUpdatesClick(Sender: TObject);
var
  LatestVersion: string;
begin
  CheckGithubLatestVersion(LatestVersion, REPO);
end;

procedure TformPoBatch.MenuFileExitClick(Sender: TObject);
begin
  Close;
end;

procedure TformPoBatch.MenuFileNewClick(Sender: TObject);
begin
  if not IsCanClose then Exit;

  NewFile;
end;

procedure TformPoBatch.MenuFileOpenClick(Sender: TObject);
begin
  if not IsCanClose then Exit;

  if dialogOpen.Execute then
    OpenFile(dialogOpen.FileName);
end;

procedure TformPoBatch.MenuPathOpenClick(Sender: TObject);
begin
  if dialogPath.Execute then
  begin
    if not OpenPath(dialogPath.FileName) then
    begin
      ShowMessage('No .po files found in the selected directory!');
      Exit;
    end;
    FPath := dialogPath.FileName;
    UpdatePath;
  end;
end;

procedure TformPoBatch.PanelClientResize(Sender: TObject);
begin

end;

procedure TformPoBatch.MenuClosePathClick(Sender: TObject);
begin
  ClosePath;
end;

procedure TformPoBatch.MenuColumnReferenceClick(Sender: TObject);
begin
  Grid.Columns[COL_REFERENCE].Visible := MenuColumnReference.Checked;
  if Grid.Columns[COL_REFERENCE].Visible and (Grid.Columns[COL_REFERENCE].Width = 0) then
    Grid.Columns[COL_REFERENCE].Width := 240;
end;

procedure TformPoBatch.MenuFileSaveAsClick(Sender: TObject);
var
  TempFileName: string;
begin
  // Set initial filename in dialog
  if FFileName <> string.Empty then
    dialogSave.FileName := ExtractFileName(FFileName)
  else
    dialogSave.FileName := 'untitled.po';

  if dialogSave.Execute then
  begin
    TempFileName := dialogSave.FileName;

    // Ensure file has extension
    if ExtractFileExt(TempFileName) = string.Empty then
      TempFileName := TempFileName + '.po';

    if SaveFile(TempFileName) then
    begin
      FFileName := TempFileName;
      Changed := False;
    end;
  end;
end;

procedure TformPoBatch.MenuFileSaveClick(Sender: TObject);
begin
  if FFileName = string.Empty then
  begin
    // No filename yet, use Save As dialog
    menuFileSaveAsClick(Sender);
  end
  else
  begin
    // Save to current file
    if SaveFile(FFileName) then
      Changed := False;
  end;
end;

procedure TformPoBatch.MenuHeadersClick(Sender: TObject);
begin
  GridHeaders.Visible := MenuHeaders.Checked;
  SplitterHeaders.Visible := MenuHeaders.Checked;
end;

procedure TformPoBatch.AUndoChangesExecute(Sender: TObject);
begin
  FillGrids;
  Changed := False;
end;

procedure TformPoBatch.AAllowEditingAllExecute(Sender: TObject);
begin
  GridHeaders.Columns[COL_HEADERS_NAME].ReadOnly := not AAllowEditingAll.Checked;

  Grid.Columns[COL_TEXT].ReadOnly := not AAllowEditingAll.Checked;
  Grid.Columns[COL_REFERENCE].ReadOnly := not AAllowEditingAll.Checked;
  Grid.Columns[COL_CONTEXT].ReadOnly := not AAllowEditingAll.Checked;
  Grid.Columns[COL_PREVIOUS].ReadOnly := not AAllowEditingAll.Checked;
  Grid.Columns[COL_FUZZY].ReadOnly := not AAllowEditingAll.Checked;
end;

procedure TformPoBatch.GridHeadersKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  SelRow: integer;
begin
  if (Key = VK_DELETE) and (ssCtrl in Shift) then
  begin
    Key := 0; // swallow the key to prevent default handling

    SelRow := GridHeaders.Row;
    // Do not delete fixed header rows
    if SelRow < GridHeaders.FixedRows then Exit;

    // Ask for confirmation before deleting
    if MessageDlg('Delete header?', 'Are you sure you want to delete the selected header?', mtConfirmation, mbYesNo, 0) <> mrYes then
      Exit;

    // Remove the selected row from the grid
    GridHeaders.DeleteRow(SelRow);
  end;
end;

procedure TformPoBatch.GridHeadersValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
begin
  if OldValue <> NewValue then
    Changed := True;
end;

procedure TformPoBatch.GridPrepareCanvas(Sender: TObject; aCol, aRow: integer; aState: TGridDrawState);
var
  TS: TTextStyle;
begin
  TS := Grid.Canvas.TextStyle;
  TS.Wordbreak := True;
  TS.SingleLine := False;
  Grid.Canvas.TextStyle := TS;
end;

procedure TformPoBatch.GridHeaderClick(Sender: TObject; IsColumn: boolean; Index: integer);
begin
  if not IsColumn then Exit;

  // Ctrl+click on any column resets sorting to original order
  if GetKeyState(VK_CONTROL) and $8000 <> 0 then
  begin
    FSortColumn := -1;
    FillGrids;
    Exit;
  end;

  // Toggle direction if same column, otherwise start ascending
  if Index = FSortColumn then
  begin
    if FSortOrder = soAscending then
      FSortOrder := soDescending
    else
      FSortOrder := soAscending;
  end
  else
  begin
    FSortColumn := Index;
    FSortOrder := soAscending;
  end;

  if (Grid.RowCount > Grid.FixedRows) and (FSortColumn >= 0) then
    Grid.SortColRow(True, FSortColumn, Grid.FixedRows, Grid.RowCount - 1);
end;

procedure TformPoBatch.GridHeaderSized(Sender: TObject; IsColumn: boolean; Index: integer);
begin
  UpdateRowHeights;
end;

procedure TformPoBatch.GridValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
begin
  if OldValue <> NewValue then
    Changed := True;
end;

procedure TformPoBatch.GridCompareCells(Sender: TObject; ACol, ARow, BCol, BRow: integer; var Result: integer);
var
  ValA, ValB: string;
  NumA, NumB: integer;
begin
  // Special rule: when sorting by COL_VALID or COL_TRANSLATION,
  // put fuzzy entries first (fuzzy flag = '1' before '0').
  if (FSortColumn = COL_VALID + 1) then
  begin
    ValA := Grid.Cells[COL_FUZZY + 1, ARow];   // +1 because Cells[0] is row number
    ValB := Grid.Cells[COL_FUZZY + 1, BRow];
    Result := CompareStr(ValA, ValB);          // '1' < '0'
    if FSortOrder = soAscending then
      Result := -Result;
    if Result <> 0 then
      Exit;
  end;

  // 1. Primary column (the one we clicked)
  ValA := Grid.Cells[ACol, ARow];
  ValB := Grid.Cells[ACol, BRow];
  Result := CompareStr(ValA, ValB);

  // Apply user-chosen sort direction
  if (FSortOrder = soDescending) and (Result <> 0) then
    Result := -Result;

  // 3. Final tie-breaker: row number stored in Cells[0, row] (always numeric, ascending)
  if Result = 0 then
  begin
    ValA := Grid.Cells[0, ARow];
    ValB := Grid.Cells[0, BRow];
    NumA := StrToIntDef(ValA, 0);
    NumB := StrToIntDef(ValB, 0);
    Result := NumA - NumB;
  end;
end;

procedure TformPoBatch.ListPathClick(Sender: TObject);
var
  Idx: integer;
  FullPath: string;
  SavedIndex: integer;
begin
  Idx := ListPath.ItemIndex;
  if Idx < 0 then Exit;   // no file selected

  // Remember the previous valid selection
  SavedIndex := FLastPathIndex;

  // Tentatively accept the new index (will be confirmed or reverted)
  FLastPathIndex := Idx;

  if Idx >= FPoFiles.Count then Exit;   // safety check
  FullPath := FPoFiles[Idx];

  // Ask to save current changes – if user cancels, revert the selection
  if not IsCanClose then
  begin
    ListPath.ItemIndex := SavedIndex;
    FLastPathIndex := SavedIndex;
    Exit;
  end;

  // Attempt to load the file
  if LoadFromFile(FullPath) then
  begin
    FFileName := FullPath;
    Changed := False;
    FillGrids;
    // FLastPathIndex already points to Idx – no change needed
  end
  else
  begin
    // Loading failed – revert to the previous selection
    ListPath.ItemIndex := SavedIndex;
    FLastPathIndex := SavedIndex;
  end;
end;

procedure TformPoBatch.FilterChange(Sender: TObject);
begin
  SaveGrids;
  FillGrids;
end;

procedure TformPoBatch.btnFilterClearClick(Sender: TObject);
begin
  Filter.Text := string.Empty;
  filterChange(Self);
end;

function TformPoBatch.IsCanClose: boolean;
var
  mr: TModalResult;
begin
  Result := True;

  if Changed then
  begin
    mr := PromptSaveChanges;

    case mr of
      mrYes:
      begin
        // Save to Po
        SaveGrids;

        // Try to save
        if FFileName = string.Empty then
        begin
          // No filename, show Save As dialog
          dialogSave.FileName := string.Empty;
          if dialogSave.Execute then
          begin
            if not SaveFile(dialogSave.FileName) then
              Result := False  // Save was cancelled or failed
            else
            begin
              FFileName := dialogSave.FileName;
              Changed := False;
            end;
          end
          else
            Result := False;  // User cancelled Save As dialog
        end
        else
        begin
          // Save to current file
          if not SaveFile(FFileName) then
            Result := False  // Save failed
          else
            Changed := False;
        end;
      end;
      mrNo:
      begin
        // Don't save, just close
        Result := True;
      end;
      mrCancel:
      begin
        // Cancel closing
        Result := False;
      end;
    end;
  end;
end;

function TformPoBatch.PromptSaveChanges: TModalResult;
var
  FileNameDisplay: string;
begin
  if FFileName = string.Empty then
    FileNameDisplay := 'Untitled'
  else
    FileNameDisplay := ExtractFileName(FFileName);

  Result := MessageDlg('Save Changes', 'The document "' + FileNameDisplay + '" has been modified.' +
    sLineBreak + 'Do you want to save your changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
end;

procedure TformPoBatch.HandleCommandLineParameters;
var
  i: integer;
  Param: string;
  ValidExtensions: array of string;
  FileExt: string;
  j: integer;
begin
  ValidExtensions := ['.po'];

  // Skip the first parameter (executable path)
  for i := 1 to ParamCount do
  begin
    Param := ParamStr(i);

    // Skip empty parameters and command-line switches
    if (Param = string.Empty) or (Param[1] in ['-', '/']) then
      Continue;

    // Check if parameter is a file
    if FileExists(Param) then
    begin
      // Check file extension
      FileExt := LowerCase(ExtractFileExt(Param));
      for j := 0 to High(ValidExtensions) do
      begin
        if FileExt = ValidExtensions[j] then
        begin
          FCommandLineFile := Param;
          Break;
        end;
      end;

      if FCommandLineFile <> string.Empty then
        Break;
    end
    else
    begin
      // Parameter might be a file path with spaces (passed without quotes)
      // Try to see if it's a partial path
      if Pos(' ', Param) > 0 then
      begin
        // This might be part of a path with spaces, we could try to reconstruct
        // For simplicity, we'll just store the first parameter that looks like a file
        FCommandLineFile := Param;
        // Note: In real application, you might want to handle quoted paths properly
      end;
    end;
  end;
end;

function TformPoBatch.ValidateFileForOpen(const AFileName: string): boolean;
var
  ValidExtensions: array of string;
  FileExt: string;
  i: integer;
begin
  Result := False;

  // Check if file exists
  if not FileExists(AFileName) then
  begin
    MessageDlg('Error', 'File does not exist:' + sLineBreak + AFileName,
      mtError, [mbOK], 0);
    Exit;
  end;

  // Check if file is valid (optional - you can remove this if you want to accept any file)
  ValidExtensions := ['.po'];
  FileExt := LowerCase(ExtractFileExt(AFileName));

  for i := 0 to High(ValidExtensions) do
  begin
    if FileExt = ValidExtensions[i] then
    begin
      Result := True;
      Exit;
    end;
  end;

  // If file extension is not in our list, ask for confirmation
  if MessageDlg('Open File', 'The file "' + ExtractFileName(AFileName) + '" has an unrecognized extension.' +
    sLineBreak + 'Do you want to try opening it anyway?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    Result := True;
  end;
end;

function TformPoBatch.NewFile(AFileName: string = string.Empty): boolean;
begin
  Result := True;
  try
    PoFile.Reset;
    PoFile.HeaderValue['X-Generator'] := 'PoBatch ' + GetAppVersion;
    FillGrids;
    FFileName := AFileName;
    Changed := False;
  except
    Result := False;
    raise;
  end;
end;

function TformPoBatch.OpenFile(const AFileName: string): boolean;
begin
  Result := False;

  // Validate file before opening
  if not ValidateFileForOpen(AFileName) then
    Exit;

  // Check if we need to save current changes
  if not IsCanClose then
    Exit;

  // Try to load the file
  if LoadFromFile(AFileName) then
  begin
    FFileName := AFileName;
    Changed := False;
    FillGrids;
    SyncPath;
    Result := True;
  end;
end;

function TformPoBatch.OpenPath(const AFileName: string): boolean;
var
  SR: TSearchRec;
  TempFiles: TStringList;
  TempNames: TStringList;
  FullPath: string;
begin
  Result := False;
  if not DirectoryExists(AFileName) then Exit;

  TempFiles := TStringList.Create;
  TempNames := TStringList.Create;
  try
    // Scan the directory into temporary lists
    if FindFirst(AFileName + '\*.po', faAnyFile, SR) = 0 then
    begin
      repeat
        FullPath := AFileName + '\' + SR.Name;
        TempFiles.Add(FullPath);
        TempNames.Add(SR.Name);
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;

    // If no files found, leave the current state unchanged
    if TempFiles.Count = 0 then
      Exit;

    // Success: replace the old list with the new one
    FPoFiles.Assign(TempFiles);
    ListPath.Items.Assign(TempNames);
    ListPath.Hint := AFileName;
    FLastPathIndex := -1;   // no file is selected in the new folder

    UpdateCaption;

    Result := True;
  finally
    TempFiles.Free;
    TempNames.Free;
  end;
end;

procedure TformPoBatch.ClosePath;
begin
  FPath := string.Empty;
  UpdatePath;
  UpdateCaption;
end;

procedure TformPoBatch.UpdatePath;
var
  Enable: boolean;
begin
  Enable := FPath <> string.Empty;
  ListPath.Visible := Enable;
  SplitterPath.Visible := Enable;
  MenuClosePath.Enabled := Enable;
  if not Enabled then
    FLastPathIndex := -1;
end;

procedure TformPoBatch.SyncPath;
var
  Idx: integer;
begin
  ListPath.ItemIndex := -1;
  if (Path = '') or (FFileName = '') then Exit;
  if ExtractFilePath(FFileName) <> IncludeTrailingPathDelimiter(Path) then Exit;

  Idx := FPoFiles.IndexOf(FFileName);
  if Idx < 0 then Exit;

  ListPath.ItemIndex := Idx;
  FLastPathIndex := Idx;
end;

function TformPoBatch.LoadFromFile(AFileName: string): boolean;
var
  Input: TStringList;
  Stream: TStringStream;
begin
  Result := False;

  if not FileExists(AFileName) then
  begin
    MessageDlg('Error', 'File does not exist: ' + AFileName, mtError, [mbOK], 0);
    Exit;
  end;

  // Check if file is readable
  try
    if FileSize(AFileName) > 50 * 1024 * 1024 then // 50 MB limit
    begin
      if MessageDlg('Large File', 'The file is very large (' + IntToStr(FileSize(AFileName) div 1024 div 1024) +
        ' MB).' + sLineBreak + 'Opening it may take a while. Continue?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        Exit;
    end;
  except
    // Ignore file size check errors
  end;

  Input := TStringList.Create;
  try
    Input.TrailingLineBreak := EndsWithLineBreak(AFileName);
    try
      // Load file with UTF-8 encoding (try UTF-8 first, fallback to ANSI)
      try
        Input.LoadFromFile(AFileName, TEncoding.UTF8);
      except
        // If UTF-8 fails, try ANSI
        Input.LoadFromFile(AFileName);
      end;

      // Load into PoFile
      Stream := TStringStream.Create(Input.Text, TEncoding.UTF8);
      try
        PoFile.LoadFromStream(Stream);
      finally
        Stream.Free;
      end;

      UpdateCaption;

      Result := True;
    except
      on E: Exception do
      begin
        MessageDlg('Load Error', 'Error loading file:' + sLineBreak + E.Message + sLineBreak + 'File may be corrupted or in wrong format.',
          mtError, [mbOK], 0);
        Result := False;
      end;
    end;
  finally
    Input.Free;
  end;
end;

function TformPoBatch.SaveFile(AFileName: string): boolean;
var
  Output: TStringList;
  Stream: TStringStream;
begin
  Result := False;

  // Validate filename
  if Trim(AFileName) = string.Empty then
  begin
    MessageDlg('Error', 'Invalid file name', mtError, [mbOK], 0);
    Exit;
  end;

  SaveGrids;
  PoFile.HeaderValue['X-Generator'] := 'PoBatch ' + GetAppVersion;
  FillGrids;

  Output := TStringList.Create;
  try
    try
      // Save PoFile content into a string first
      begin
        Stream := TStringStream.Create(string.Empty, TEncoding.UTF8);
        try
          PoFile.SaveToStream(Stream);          // serialize all entries to UTF-8 stream
          Output.Text := Stream.DataString;     // get resulting string
        finally
          Stream.Free;
        end;
      end;

      // Ensure the file ends with a line break (PO/POT standard)
      Output.TrailingLineBreak := True;

      // Ensure directory exists
      ForceDirectories(ExtractFilePath(AFileName));

      // Save file with UTF-8 encoding (without BOM)
      Output.SaveToFile(AFileName, TEncoding.UTF8);

      UpdateCaption;

      Result := True;
    except
      on E: Exception do
      begin
        MessageDlg('Save Error', 'Error saving file:' + sLineBreak + E.Message,
          mtError, [mbOK], 0);
        Result := False;
      end;
    end;
  finally
    Output.Free;
  end;
end;

procedure TformPoBatch.UpdateRowHeights;
var
  Row, Col: integer;
  R: TRect;
  H, MaxH: integer;
begin
  for Row := Grid.FixedRows to Grid.RowCount - 1 do
  begin
    MaxH := Grid.DefaultRowHeight;

    for Col := 0 to Grid.ColCount - 1 do
    begin
      R := Rect(0, 0, Grid.ColWidths[Col] - 4, 0);

      DrawText(Grid.Canvas.Handle,
        PChar(Grid.Cells[Col, Row]),
        Length(Grid.Cells[Col, Row]),
        R,
        DT_WORDBREAK or DT_CALCRECT);

      H := R.Bottom - R.Top + 4;

      if H > MaxH then
        MaxH := H;
    end;

    Grid.RowHeights[Row] := MaxH;
  end;
end;

procedure TformPoBatch.SetChanges(Value: boolean);
begin
  FChanged := Value;
  AUndoChanges.Enabled := FChanged;
  UpdateCaption;
end;

procedure TformPoBatch.UpdateCaption;
var
  BaseTitle: string;
  AppName: string;
  FileInPath: boolean;
begin
  AppName := 'PoBatch';

  if FFileName = '' then
  begin
    // No file loaded – show path (if any) with "Untitled"
    if FPath <> '' then
      BaseTitle := FPath + ' - Untitled'
    else
      BaseTitle := 'Untitled';
  end
  else
  begin
    // Check whether the opened file resides inside the currently open folder
    FileInPath := (FPath <> '') and (ExtractFilePath(FFileName) = IncludeTrailingPathDelimiter(FPath));

    if not FileInPath then
      // File belongs to the open folder: display folder and file name only
      BaseTitle := FPath + ', ' + FFileName
    else
      // File is outside the open folder (or no folder open): show full file path
      BaseTitle := FFileName;
  end;

  // Append modification marker and application name
  if Changed then
    Caption := BaseTitle + '* - ' + AppName
  else
    Caption := BaseTitle + ' - ' + AppName;

  // Taskbar title (same logic, without the app name suffix)
  Application.Title := BaseTitle;
  if Changed then
    Application.Title := Application.Title + '*';

  Application.QueueAsyncCall(@FixSplitters, 0);
end;

procedure TformPoBatch.FixSplitters(Data: PtrInt);
begin
  ListPath.Left := 0;
  SplitterPath.Left := ListPath.Left + ListPath.Width;

  GridHeaders.Top := 0;
  SplitterHeaders.Top := GridHeaders.Top + GridHeaders.Height;
end;

function TformPoBatch.EntryMatchesFilter(Entry: TPOEntry; const AFilter: string): boolean;
var
  PrevStrings: TStrings;
  LowerFilter: string;
begin
  if AFilter = '' then Exit(True);
  LowerFilter := LowerCase(AFilter);
  // Check original
  if Pos(LowerFilter, LowerCase(Entry.MsgId)) > 0 then Exit(True);
  // Check translation
  if Pos(LowerFilter, LowerCase(Entry.MsgStrSimple)) > 0 then Exit(True);
  // Check previous text
  PrevStrings := Entry.GetCommentsOfType(poctPrevious);
  try
    Result := Pos(LowerFilter, LowerCase(PrevStrings.Text)) > 0;
  finally
    PrevStrings.Free;
  end;
end;

procedure TformPoBatch.FillGrids;
var
  i, RowIndex: integer;
  Entry: TPOEntry;
  PrevStrings: TStrings;
  PreviousText: string;
  j: integer;
  Headers: TStrings;
  p: integer;
  Key, Value: string;
begin
  if not Assigned(PoFile) then
  begin
    Grid.RowCount := Grid.FixedRows;
    GridHeaders.RowCount := GridHeaders.FixedRows;
    Exit;
  end;

  // Fill the headers grid
  GridHeaders.BeginUpdate;
  try
    Headers := PoFile.Headers;
    try
      GridHeaders.RowCount := GridHeaders.FixedRows + Headers.Count;
      for i := 0 to Headers.Count - 1 do
      begin
        // Parse "Key=Value" line
        p := Pos('=', Headers[i]);
        if p > 0 then
        begin
          Key := Copy(Headers[i], 1, p - 1);
          Value := Copy(Headers[i], p + 1, MaxInt);
        end
        else
        begin
          Key := Headers[i];
          Value := '';
        end;
        // Column 0 is fixed, store key and value in columns 1 and 2
        GridHeaders.Cells[1, GridHeaders.FixedRows + i] := Key;
        GridHeaders.Cells[2, GridHeaders.FixedRows + i] := Value;
      end;
    finally
      Headers.Free;
    end;
  finally
    GridHeaders.EndUpdate;
  end;

  // Fill main translation grid
  Grid.BeginUpdate;
  try
    // Reset rows, keep only fixed header row
    RowIndex := Grid.FixedRows;
    Grid.RowCount := RowIndex;

    for i := 0 to PoFile.Entries.Count - 1 do
    begin
      Entry := PoFile.Entries[i];
      if Entry.MsgId = '' then Continue;  // skip header entry

      // Apply filter if one is set
      if (Filter.Text <> '') and not EntryMatchesFilter(Entry, Filter.Text) then
        Continue;

      Grid.RowCount := Grid.RowCount + 1;

      // Column 0: permanent index of the entry in the PO list
      Grid.Cells[0, RowIndex] := IntToStr(i);

      // Column 1: valid calculate
      Grid.Cells[COL_VALID + 1, RowIndex] := IfThen(Entry.IsValid, '1', '0');

      // Column 2: original text (msgid)
      Grid.Cells[COL_TEXT + 1, RowIndex] := Entry.MsgId;

      // Column 3: translation (msgstr)
      Grid.Cells[COL_TRANSLATION + 1, RowIndex] := Entry.MsgStrSimple;

      // Column 4: referenct (#:)
      Grid.Cells[COL_REFERENCE + 1, RowIndex] := Entry.Reference;

      // Column 5: context (msgctxt)
      Grid.Cells[COL_CONTEXT + 1, RowIndex] := Entry.MsgCtxt;

      // Column 6: previous untranslated text from #| comments
      PrevStrings := Entry.GetCommentsOfType(poctPrevious);
      try
        if PrevStrings.Count > 0 then
        begin
          PreviousText := PrevStrings[0];
          for j := 1 to PrevStrings.Count - 1 do
            PreviousText := PreviousText + sLineBreak + PrevStrings[j];
        end
        else
          PreviousText := '';
      finally
        PrevStrings.Free;
      end;
      Grid.Cells[5, RowIndex] := PreviousText;

      // Column 7: fuzzy flag (1 if fuzzy, 0 otherwise)
      Grid.Cells[COL_FUZZY + 1, RowIndex] := IfThen(Entry.IsFuzzy, '1', '0');

      Inc(RowIndex);
    end;

    // Re-apply active column sort if any
    if (FSortColumn >= 0) and (Grid.RowCount > Grid.FixedRows) then
      Grid.SortColRow(True, FSortColumn, Grid.FixedRows, Grid.RowCount - 1);

    UpdateRowHeights;
  finally
    Grid.EndUpdate;
  end;
end;

procedure TformPoBatch.SaveGrids;
var
  Row: integer;
  EntryIndex: integer;
  Entry: TPOEntry;
  Headers: TStringList;
  i: integer;
begin
  if not Assigned(PoFile) then Exit;

  // Save headers from GridHeaders
  Headers := TStringList.Create;
  try
    for i := GridHeaders.FixedRows to GridHeaders.RowCount - 1 do
    begin
      // Skip completely empty rows
      if (Trim(GridHeaders.Cells[1, i]) = '') and (Trim(GridHeaders.Cells[2, i]) = '') then
        Continue;
      Headers.Add(GridHeaders.Cells[1, i] + '=' + GridHeaders.Cells[2, i]);
    end;
    PoFile.Headers := Headers;
  finally
    Headers.Free;
  end;

  // Save entries from main translation grid
  for Row := Grid.FixedRows to Grid.RowCount - 1 do
  begin
    // Column 0 holds the permanent entry index
    EntryIndex := StrToIntDef(Grid.Cells[0, Row], -1);
    if (EntryIndex < 1) or (EntryIndex >= PoFile.Entries.Count) then
      Continue;

    Entry := PoFile.Entries[EntryIndex];

    // Update translation from column COL_TRANSLATION
    Entry.MsgStrSimple := Grid.Cells[COL_TRANSLATION + 1, Row];

    // Update fuzzy flag from column COL_FUZZY
    Entry.IsFuzzy := (Grid.Cells[COL_FUZZY + 1, Row] = '1');
  end;

  AUndoChanges.Enabled := False;
end;

end.
