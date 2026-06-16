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
  LCLIntf,
  powrap;

type

  { TformPoBatch }

  TformPoBatch = class(TForm)
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
    MenuView: TMenuItem;
    MenuPathOpen: TMenuItem;
    PanelClient: TPanel;
    PanelFilter: TPanel;
    dialogSave: TSaveDialog;
    Separator2: TMenuItem;
    btnFilterClear: TSpeedButton;
    dialogPath: TSelectDirectoryDialog;
    Separator1: TMenuItem;
    SplitterTop: TSplitter;
    SplitterPath: TSplitter;
    StatusBar: TStatusBar;
    Grid: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure MenuAboutClick(Sender: TObject);
    procedure MenuAutoCheckUpdatesClick(Sender: TObject);
    procedure MenuClosePathClick(Sender: TObject);
    procedure MenuFileNewWindowClick(Sender: TObject);
    procedure MenuBuyMeACoffeeClick(Sender: TObject);
    procedure MenuCheckForUpdatesClick(Sender: TObject);
    procedure MenuFileExitClick(Sender: TObject);
    procedure MenuFileNewClick(Sender: TObject);
    procedure MenuFileOpenClick(Sender: TObject);
    procedure MenuFileSaveAsClick(Sender: TObject);
    procedure MenuFileSaveClick(Sender: TObject);
    procedure GridHeaderClick(Sender: TObject; IsColumn: boolean; Index: integer);
    procedure GridHeaderSized(Sender: TObject; IsColumn: boolean; Index: integer);
    procedure GridPrepareCanvas(Sender: TObject; aCol, aRow: integer; aState: TGridDrawState);
    procedure GridEditingDone(Sender: TObject);
    procedure GridHeadersKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure ListPathClick(Sender: TObject);
    procedure FilterChange(Sender: TObject);
    procedure btnFilterClearClick(Sender: TObject);
    procedure MenuHeadersClick(Sender: TObject);
    procedure MenuPathOpenClick(Sender: TObject);
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
    function LoadFromFile(AFileName: string): boolean;
    function SaveFile(AFileName: string): boolean;
    procedure UpdateRowHeights;
    procedure UpdateCaption;
    function EntryMatchesFilter(Entry: TPOEntry; const AFilter: string): boolean;
    procedure FillGrids;
    procedure SaveGrids;
  public
    property Path: string read FPath write FPath;
    property AutoCheckUpdates: boolean read FAutoCheckUpdates write FAutoCheckUpdates;
    property SortOrder: TSortOrder read FSortOrder write FSortOrder;
    property SortColumn: integer read FSortColumn write FSortColumn;
  end;

var
  formPoBatch: TformPoBatch;

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
  FChanged := False;
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

    // Open file from command line if specified, otherwise start with a new document
    if FCommandLineFile <> string.Empty then
    begin
      if not OpenFile(FCommandLineFile) then
        NewFile;
    end
    else
      NewFile;

    if (Path <> string.Empty) and OpenPath(Path) then
      UpdatePath;
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
  begin
    FPath := string.Empty;
    UpdatePath;

    OpenFile(dialogOpen.FileName);
  end;
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

procedure TformPoBatch.MenuClosePathClick(Sender: TObject);
begin
  ClosePath;
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
      FChanged := False;
      UpdateCaption;
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
    begin
      FChanged := False;
      UpdateCaption;
    end;
  end;
end;

procedure TformPoBatch.MenuHeadersClick(Sender: TObject);
begin
  GridHeaders.Visible := MenuHeaders.Checked;
  SplitterTop.Visible := MenuHeaders.Checked;
end;

procedure TformPoBatch.GridHeaderClick(Sender: TObject; IsColumn: boolean; Index: integer);
begin
  if not IsColumn then Exit;   // handle column clicks only

  if Index = 0 then
  begin
    // Column 0 contains original loading order numbers – reset sorting
    FSortColumn := -1;
    FillGrids;  // rows return to the loading order
    Exit;
  end;

  // For other columns: toggle direction if same column, else start new ascending sort
  if Index = FSortColumn then
  begin
    // Switch between ascending and descending
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

  // Apply sorting to the data rows only (skip fixed rows)
  if (Grid.RowCount > Grid.FixedRows) and (FSortColumn >= 0) then
    Grid.SortColRow(True, FSortColumn, Grid.FixedRows, Grid.RowCount - 1);
end;

procedure TformPoBatch.GridHeaderSized(Sender: TObject; IsColumn: boolean; Index: integer);
begin
  UpdateRowHeights;
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

procedure TformPoBatch.GridEditingDone(Sender: TObject);
begin
  FChanged := True;
  UpdateCaption;
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
    FChanged := False;
    FillGrids;
    UpdateCaption;
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
  SaveGrids;

  if FChanged then
  begin
    mr := PromptSaveChanges;

    case mr of
      mrYes:
      begin
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
              FChanged := False;
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
            FChanged := False;
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
    FChanged := False;
    UpdateCaption;
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
    FChanged := False;
    FillGrids;
    UpdateCaption;
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

procedure TformPoBatch.UpdateCaption;
var
  BaseTitle: string;
  AppName: string;
begin
  // Get application name from project settings or use default
  AppName := 'PoBatch';

  if FFileName = string.Empty then
    BaseTitle := 'Untitled'
  else
    BaseTitle := FPath + ifthen(FPath = string.Empty, '', ' - ') + ExtractFileName(FFileName);

  if FChanged then
    Caption := BaseTitle + '* - ' + AppName
  else
    Caption := BaseTitle + ' - ' + AppName;

  // You can also set the application title for taskbar
  Application.Title := BaseTitle;
  if FChanged then
    Application.Title := Application.Title + '*';
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
      // Column 1: original text (msgid)
      Grid.Cells[1, RowIndex] := Entry.MsgId;
      // Column 2: translation (msgstr)
      Grid.Cells[2, RowIndex] := Entry.MsgStrSimple;

      // Column 3: previous untranslated text from #| comments
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
      Grid.Cells[3, RowIndex] := PreviousText;

      // Column 4: fuzzy flag (1 if fuzzy, 0 otherwise)
      if Entry.IsFuzzy then
        Grid.Cells[4, RowIndex] := '1'
      else
        Grid.Cells[4, RowIndex] := '0';

      Inc(RowIndex);
    end;

    // Re-apply active column sort if any
    if (FSortColumn >= 0) and (Grid.RowCount > Grid.FixedRows) then
      Grid.SortColRow(True, FSortColumn, Grid.FixedRows, Grid.RowCount - 1);
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

    // Update translation from column 2
    Entry.MsgStrSimple := Grid.Cells[2, Row];

    // Update fuzzy flag from column 4
    Entry.IsFuzzy := (Grid.Cells[4, Row] = '1');

    // Column 3 (previous text) is intentionally left untouched
  end;
end;

end.
