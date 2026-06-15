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
  Process,
  Buttons,
  LCLType,
  powrap;

type

  { TformPoBatch }

  TformPoBatch = class(TForm)
    filter: TEdit;
    MainMenu: TMainMenu;
    menuFile: TMenuItem;
    menuFileOpen: TMenuItem;
    menuFileSave: TMenuItem;
    menuFileExit: TMenuItem;
    menuFileSaveAs: TMenuItem;
    menuFileNew: TMenuItem;
    dialogOpen: TOpenDialog;
    menuHelp: TMenuItem;
    menuBuyMeACoffee: TMenuItem;
    menuCheckForUpdates: TMenuItem;
    menuAbout: TMenuItem;
    menuFileNewWindow: TMenuItem;
    menuAutoCheckUpdates: TMenuItem;
    PanelFilter: TPanel;
    dialogSave: TSaveDialog;
    menuFileSeparator1: TMenuItem;
    btnFilterClear: TSpeedButton;
    StatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure menuAboutClick(Sender: TObject);
    procedure menuAutoCheckUpdatesClick(Sender: TObject);
    procedure menuFileNewWindowClick(Sender: TObject);
    procedure menuBuyMeACoffeeClick(Sender: TObject);
    procedure menuCheckForUpdatesClick(Sender: TObject);
    procedure menuFileExitClick(Sender: TObject);
    procedure menuFileNewClick(Sender: TObject);
    procedure menuFileOpenClick(Sender: TObject);
    procedure menuFileSaveAsClick(Sender: TObject);
    procedure menuFileSaveClick(Sender: TObject);
    procedure filterChange(Sender: TObject);
    procedure btnFilterClearClick(Sender: TObject);
  private
    PoFile: TPoFile;
    FFileName: string;
    FChanged: boolean;
    FInitialized: boolean;
    FCommandLineFile: string;
    FAutoCheckUpdates: boolean;

    function IsCanClose: boolean;
    function PromptSaveChanges: TModalResult;
    procedure HandleCommandLineParameters;
    function ValidateFileForOpen(const AFileName: string): boolean;
    function NewFile(AFileName: string = string.Empty): boolean;
    function OpenFile(const AFileName: string): boolean;
    function LoadFromFile(AFileName: string): boolean;
    function SaveFile(AFileName: string): boolean;
    procedure UpdateCaption;
    procedure FillGrid;
    procedure SaveGrid;
  public
    property AutoCheckUpdates: boolean read FAutoCheckUpdates write FAutoCheckUpdates;
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
  FFileName := '';
  FCommandLineFile := '';

  LoadFormSettings(Self);

  // Create PoFile object
  PoFile := TPoFile.Create;
  NewFile;

  // Load the menu state
  menuAutoCheckUpdates.Checked := FAutoCheckUpdates;

  // Handle command line parameters
  HandleCommandLineParameters;
end;

procedure TformPoBatch.FormDestroy(Sender: TObject);
begin
  SaveFormSettings(Self);

  PoFile.Free;
end;

procedure TformPoBatch.FormShow(Sender: TObject);
var
  Th: TCheckUpdateThread;
begin
  if not FInitialized then
  begin
    FInitialized := True;

    // Open file from command line if specified, otherwise start with a new document
    if FCommandLineFile <> '' then
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

procedure TformPoBatch.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TformPoBatch.menuAboutClick(Sender: TObject);
begin
  formAboutPoBatch.ShowModal;
end;

procedure TformPoBatch.menuFileNewWindowClick(Sender: TObject);
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

procedure TformPoBatch.menuBuyMeACoffeeClick(Sender: TObject);
begin
  formDonatePoBatch.ShowModal;
end;

procedure TformPoBatch.menuAutoCheckUpdatesClick(Sender: TObject);
begin
  FAutoCheckUpdates := menuAutoCheckUpdates.Checked;
end;

procedure TformPoBatch.menuCheckForUpdatesClick(Sender: TObject);
var
  LatestVersion: string;
begin
  CheckGithubLatestVersion(LatestVersion, REPO);
end;

procedure TformPoBatch.menuFileExitClick(Sender: TObject);
begin
  Close;
end;

procedure TformPoBatch.menuFileNewClick(Sender: TObject);
begin
  if not IsCanClose then Exit;

  NewFile;
end;

procedure TformPoBatch.menuFileOpenClick(Sender: TObject);
begin
  if not IsCanClose then Exit;

  if dialogOpen.Execute then
  begin
    OpenFile(dialogOpen.FileName);
  end;
end;

procedure TformPoBatch.menuFileSaveAsClick(Sender: TObject);
var
  TempFileName: string;
begin
  // Set initial filename in dialog
  if FFileName <> '' then
    dialogSave.FileName := ExtractFileName(FFileName)
  else
    dialogSave.FileName := 'untitled.po';

  if dialogSave.Execute then
  begin
    TempFileName := dialogSave.FileName;

    // Ensure file has extension
    if ExtractFileExt(TempFileName) = '' then
      TempFileName := TempFileName + '.po';

    if SaveFile(TempFileName) then
    begin
      FFileName := TempFileName;
      FChanged := False;
      UpdateCaption;
    end;
  end;
end;

procedure TformPoBatch.menuFileSaveClick(Sender: TObject);
begin
  if FFileName = '' then
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

procedure TformPoBatch.filterChange(Sender: TObject);
begin
  //propertyPad.TIObject := nil;
  //propertyPad.TIObject := PadFormat;
end;

procedure TformPoBatch.btnFilterClearClick(Sender: TObject);
begin
  filter.Text := string.Empty;
  filterChange(Self);
end;

function TformPoBatch.IsCanClose: boolean;
var
  mr: TModalResult;
begin
  Result := True;
  SaveGrid;

  if FChanged then
  begin
    mr := PromptSaveChanges;

    case mr of
      mrYes:
      begin
        // Try to save
        if FFileName = '' then
        begin
          // No filename, show Save As dialog
          dialogSave.FileName := '';
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
  if FFileName = '' then
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
    if (Param = '') or (Param[1] in ['-', '/']) then
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

      if FCommandLineFile <> '' then
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
    FillGrid;
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
    FillGrid;
    UpdateCaption;
    Result := True;
  end;
end;

function TformPoBatch.SaveFile(AFileName: string): boolean;
var
  Output: TStringList;
  Stream: TStringStream;
begin
  Result := False;
  SaveGrid;

  // Validate filename
  if Trim(AFileName) = '' then
  begin
    MessageDlg('Error', 'Invalid file name', mtError, [mbOK], 0);
    Exit;
  end;

  Output := TStringList.Create;
  try
    try
      // Save PoFile content into a string first
      begin
        Stream := TStringStream.Create('', TEncoding.UTF8);
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

procedure TformPoBatch.UpdateCaption;
var
  BaseTitle: string;
  AppName: string;
begin
  // Get application name from project settings or use default
  AppName := 'PoBatch';

  if FFileName = '' then
    BaseTitle := 'Untitled'
  else
    BaseTitle := ExtractFileName(FFileName);

  if FChanged then
    Caption := BaseTitle + '* - ' + AppName
  else
    Caption := BaseTitle + ' - ' + AppName;

  // You can also set the application title for taskbar
  Application.Title := BaseTitle;
  if FChanged then
    Application.Title := Application.Title + '*';
end;

procedure TformPoBatch.FillGrid;
var test:TPoEntry;
begin
if FFileName = '' then exit;
test:=PoFile.FindEntry('Parameters in the form key=value used by {key} in requests. If the value is omitted (key=), it will be requested from the user.');

Test.IsFuzzy:=True;
Test.IsPhpFormat:=False;
Test.IsBoostFormat:=False;
end;

procedure TformPoBatch.SaveGrid;
begin
end;

//procedure TformPoBatch.propertyPadModified(Sender: TObject);
//begin
//  if not FChanged then
//  begin
//    FChanged := True;
//    UpdateCaption;
//  end;
//end;

end.
