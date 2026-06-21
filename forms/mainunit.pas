//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit mainunit;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  FileUtil,
  Forms,
  ActnList,
  Controls,
  Graphics,
  Math,
  Dialogs,
  Menus,
  ComCtrls,
  StdCtrls,
  ExtCtrls,
  Grids,
  Process,
  Buttons,
  StrUtils,
  Clipbrd,
  LCLType,
  LCLIntf,
  powrap, Types;

type

  { TformPoBatch }

  TformPoBatch = class(TForm)
    ACopySourceText: TAction;
    AClearIdentical: TAction;
    ApplicationProp: TApplicationProperties;
    ASelectAll: TAction;
    ACut: TAction;
    ACopy: TAction;
    APaste: TAction;
    ADelete: TAction;
    AEditTranslationOnly: TAction;
    AUndoChanges: TAction;
    ActionList: TActionList;
    Filter: TEdit;
    GridHeaders: TStringGrid;
    ImagesSwitch: TImageList;
    ImageSwitch: TImage;
    LabelSwitch: TLabel;
    ListPath: TListBox;
    MainMenu: TMainMenu;
    MemoCheck: TMemo;
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
    MenuCut: TMenuItem;
    MenuCopy: TMenuItem;
    MenuCopySourceText: TMenuItem;
    MenuClearIdentical: TMenuItem;
    MeniTranslatePanel: TMenuItem;
    MenuPopupCut: TMenuItem;
    MenuPopupCopy: TMenuItem;
    MenuPopupPaste: TMenuItem;
    MenuPopupDelete: TMenuItem;
    MenuPopupSelectAll: TMenuItem;
    MenuPopupCopySourceText: TMenuItem;
    MenuPopupClearIdentical: TMenuItem;
    MenuSelectAll: TMenuItem;
    MenuPaste: TMenuItem;
    MenuDelete: TMenuItem;
    MenuPathClose: TMenuItem;
    MenuHeaders: TMenuItem;
    MenuColumnReference: TMenuItem;
    MenuEdit: TMenuItem;
    MenuEditTranslationOnly: TMenuItem;
    MenuUndoChanges: TMenuItem;
    MenuView: TMenuItem;
    MenuPathOpen: TMenuItem;
    Pages: TPageControl;
    PanelCheck: TPanel;
    PanelSwitch: TPanel;
    PanelClient: TPanel;
    PanelFilter: TPanel;
    dialogSave: TSaveDialog;
    PopupGrid: TPopupMenu;
    Separator2: TMenuItem;
    btnFilterClear: TSpeedButton;
    dialogPath: TSelectDirectoryDialog;
    Separator1: TMenuItem;
    Separator3: TMenuItem;
    Separator4: TMenuItem;
    Separator5: TMenuItem;
    Separator6: TMenuItem;
    Separator7: TMenuItem;
    Separator8: TMenuItem;
    Separator9: TMenuItem;
    SplitterHeaders: TSplitter;
    SplitterPages: TSplitter;
    SplitterPath: TSplitter;
    StatusBar: TStatusBar;
    Grid: TStringGrid;
    PageTranslate: TTabSheet;
    PageComments: TTabSheet;
    PagePlural: TTabSheet;
    { Form Events }
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure FormResize(Sender: TObject);
    { Application Events }
    procedure ApplicationPropActivate(Sender: TObject);
    procedure ApplicationPropDeactivate(Sender: TObject);
    { Menu Events }
    procedure MenuFileNewClick(Sender: TObject);
    procedure MenuFileNewWindowClick(Sender: TObject);
    procedure MenuFileOpenClick(Sender: TObject);
    procedure MenuFileSaveClick(Sender: TObject);
    procedure MenuFileSaveAsClick(Sender: TObject);
    procedure MeniTranslatePanelClick(Sender: TObject);
    procedure MenuPathOpenClick(Sender: TObject);
    procedure MenuPathCloseClick(Sender: TObject);
    procedure MenuFileExitClick(Sender: TObject);
    procedure MenuHeadersClick(Sender: TObject);
    procedure MenuColumnReferenceClick(Sender: TObject);
    procedure MenuBuyMeACoffeeClick(Sender: TObject);
    procedure MenuCheckForUpdatesClick(Sender: TObject);
    procedure MenuAutoCheckUpdatesClick(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    { Action Events }
    procedure AUndoChangesExecute(Sender: TObject);
    procedure ACopyExecute(Sender: TObject);
    procedure ACutExecute(Sender: TObject);
    procedure APasteExecute(Sender: TObject);
    procedure ADeleteExecute(Sender: TObject);
    procedure ADeleteUpdate(Sender: TObject);
    procedure ASelectAllExecute(Sender: TObject);
    procedure AClearIdenticalExecute(Sender: TObject);
    procedure ACopySourceTextExecute(Sender: TObject);
    procedure AEditTranslationOnlyExecute(Sender: TObject);
    { Grid Headers Events }
    procedure GridHeadersKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure GridHeadersValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
    procedure GridHeadersPrepareCanvas(Sender: TObject; aCol, aRow: integer; aState: TGridDrawState);
    procedure GridHeadersExit(Sender: TObject);
    { Grid Events }
    procedure GridKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure GridHeaderClick(Sender: TObject; IsColumn: boolean; Index: integer);
    procedure GridHeaderSized(Sender: TObject; IsColumn: boolean; Index: integer);
    procedure GridValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
    procedure GridCompareCells(Sender: TObject; ACol, ARow, BCol, BRow: integer; var Result: integer);
    procedure GridColRowInserted(Sender: TObject; IsColumn: boolean; sIndex, tIndex: integer);
    procedure GridMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
    procedure GridGetCellHint(Sender: TObject; ACol, ARow: integer; var HintText: string);
    procedure GridSelectCell(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);
    procedure GridSelectEditor(Sender: TObject; aCol, aRow: integer; var Editor: TWinControl);
    procedure GridPrepareCanvas(Sender: TObject; aCol, aRow: integer; aState: TGridDrawState);
    procedure GridDrawCell(Sender: TObject; aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
    procedure GridExit(Sender: TObject);
    procedure GridTopLeftChanged(Sender: TObject);
    { Inline Editor Events}
    procedure PanelMemoEnter(Sender: TObject);
    procedure PanelMemoUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure MemoEnter(Sender: TObject);
    procedure MemoExit(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    { Other Events }
    procedure EditControlSetBounds(Sender: TWinControl; aCol, aRow: integer; OffsetLeft: integer = 0;
      OffsetTop: integer = 3; OffsetRight: integer = -1; OffsetBottom: integer = 0);
    procedure ListPathClick(Sender: TObject);
    procedure ListPathDrawItem(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
    procedure FilterChange(Sender: TObject);
    procedure btnFilterClearClick(Sender: TObject);
    procedure ImageSwitchClick(Sender: TObject);
    procedure PanelSwitchEnter(Sender: TObject);
    procedure PanelSwitchExit(Sender: TObject);
    procedure PanelSwitchPaint(Sender: TObject);
  private
    Memo: TMemo;
    PanelMemo: TPanel;

    FPoFile: TPoFile;
    FPoFileBackup: TPoFile;
    FFileName: string;
    FInitialized: boolean;
    FCommandLineFile: string;
    FUpdatingGrid: boolean;
    FLastPathIndex: integer;
    FLastRow: integer;
    FPanelFocused: boolean;
    FPoFiles: TStringList;
    FFileStatuses: array of TPoFileStatus;
    FCellValue: string;

    FChanged: boolean;
    FPath: string;
    FAutoCheckUpdates: boolean;
    FSortOrder: TSortOrder;
    FSortColumn: integer;

    { Properties Methods }
    procedure SetChanges(Value: boolean);

    { Methods File Operations }
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
    { Methods }
    procedure UpdateRowHeights;
    procedure UpdateCaption;
    procedure UpdateFileStatus(const AFileName: string);
    procedure UpdateCheck;
    procedure SwitchCheck;
    function CurrentEntry: TPOEntry;
    procedure DelayedSetMemoFocus(Data: PtrInt);
    procedure FixSplitters(Data: PtrInt);
    function CutGridsSelection: boolean;
    function CopyGridsSelection: boolean;
    function PasteGridsSelection: boolean;
    function DeleteGridsSelection: boolean;
    function SelectGridsAll: boolean;
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
  COLUMN_HEADERS_NAME = 0;
  COLUMN_HEADERS_VALUE = 1;
  CELL_HEADERS_NAME = 1;
  CELL_HEADERS_VALUE = 2;

  COLUMN_VALID = 0;
  COLUMN_TEXT = 1;
  COLUMN_TRANSLATION = 2;
  COLUMN_REFERENCE = 3;
  COLUMN_CONTEXT = 4;
  COLUMN_PREVIOUS = 5;
  COLUMN_FUZZY = 6;
  CELL_VALID = 1;
  CELL_TEXT = 2;
  CELL_TRANSLATION = 3;
  CELL_REFERENCE = 4;
  CELL_CONTEXT = 5;
  CELL_PREVIOUS = 6;
  CELL_FUZZY = 7;

  UNDEFINED = 'undefined';

  // Colors
  clRowHighlight = TColor($FFF0DC);
  clRowHighlightDark = TColor($5A4037);
  clInfo = TColor($96FFFF);
  clInfoDark = TColor($009696);
  clLine = TColor($E8E8E8);
  clLineDark = TColor($484848);
  clMidGray = TColor($A0A0A0);
  clMidGrayDark = TColor($404040);
  clFontBlue = TColor($C85020);
  clFontBlueDark = TColor($00DD8F84);
  clSoftBlue = TColor($F0E6D8);
  clSoftBlueDark = TColor($2B1A10);
  clSoftYellow = TColor($E9FEFE);
  clSoftYellowDark = TColor($045757);
  clSoftGreen = TColor($DDFBDF);
  clSoftGreenDark = TColor($07410C);

implementation

uses formabout, formdonate, systemtool, formattool, settings, StringGridHelper, ColorHelper;

  {$R *.lfm}

  { TformPoBatch }

  { Form Events }

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
  SetLength(FFileStatuses, 0);
  FCommandLineFile := string.Empty;
  FSortColumn := -1;
  FSortOrder := soAscending;
  FLastPathIndex := -1;
  FLastRow := -1;

  // Initialize components
  Grid.GridLineColor := ThemeColor(clLine, clLineDark);
  GridHeaders.GridLineColor := ThemeColor(clLine, clLineDark);

  LoadFormSettings(Self);

  // Create FPoFile object
  FPoFile := TPoFile.Create;
  FPoFileBackup := TPoFile.Create;
  NewFile;

  // Load the menu state
  MenuAutoCheckUpdates.Checked := FAutoCheckUpdates;

  // Handle command line parameters
  HandleCommandLineParameters;
end;

procedure TformPoBatch.FormDestroy(Sender: TObject);
begin
  SaveFormSettings(Self);

  FreeAndNil(FPoFile);
  FreeAndNil(FPoFileBackup);
  SetLength(FFileStatuses, 0);
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
    if (Path <> string.Empty) then
    begin
      if OpenPath(Path) then
        UpdatePath
      else
        Path := string.Empty;
    end;

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

procedure TformPoBatch.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if ActiveControl = PanelSwitch then
  begin
    if Key = VK_SPACE then
      SwitchCheck;
  end;
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

{ Application Events }

procedure TformPoBatch.ApplicationPropActivate(Sender: TObject);
begin
  Invalidate;
end;

procedure TformPoBatch.ApplicationPropDeactivate(Sender: TObject);
begin
  Invalidate;
end;

{ Menu Events }

procedure TformPoBatch.MenuFileNewClick(Sender: TObject);
begin
  if not IsCanClose then Exit;

  NewFile;
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

procedure TformPoBatch.MenuFileOpenClick(Sender: TObject);
begin
  if not IsCanClose then Exit;

  if dialogOpen.Execute then
    OpenFile(dialogOpen.FileName);
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
      Changed := False;
      UpdateFileStatus(FFileName);
    end;
  end;
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
      if ExtractFilePath(TempFileName) = IncludeTrailingPathDelimiter(FPath) then
        OpenPath(FPath);
    end;
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

procedure TformPoBatch.MenuPathCloseClick(Sender: TObject);
begin
  ClosePath;
end;

procedure TformPoBatch.MenuFileExitClick(Sender: TObject);
begin
  Close;
end;

procedure TformPoBatch.MenuHeadersClick(Sender: TObject);
begin
  GridHeaders.Visible := MenuHeaders.Checked;
  SplitterHeaders.Visible := MenuHeaders.Checked;
  Application.QueueAsyncCall(@FixSplitters, 0);
end;

procedure TformPoBatch.MeniTranslatePanelClick(Sender: TObject);
begin
  Pages.Visible := MeniTranslatePanel.Checked;
  SplitterPages.Visible := MeniTranslatePanel.Checked;
  Application.QueueAsyncCall(@FixSplitters, 0);
end;

procedure TformPoBatch.MenuColumnReferenceClick(Sender: TObject);
begin
  Grid.Columns[COLUMN_REFERENCE].Visible := MenuColumnReference.Checked;
  if Grid.Columns[COLUMN_REFERENCE].Visible and (Grid.Columns[COLUMN_REFERENCE].Width = 0) then
    Grid.Columns[COLUMN_REFERENCE].Width := 240;
end;

procedure TformPoBatch.MenuBuyMeACoffeeClick(Sender: TObject);
begin
  formDonatePoBatch.ShowModal;
end;

procedure TformPoBatch.MenuCheckForUpdatesClick(Sender: TObject);
var
  LatestVersion: string;
begin
  CheckGithubLatestVersion(LatestVersion, REPO);
end;

procedure TformPoBatch.MenuAutoCheckUpdatesClick(Sender: TObject);
begin
  FAutoCheckUpdates := MenuAutoCheckUpdates.Checked;
end;

procedure TformPoBatch.MenuAboutClick(Sender: TObject);
begin
  formAboutPoBatch.ShowModal;
end;

{ Action Events }

procedure TformPoBatch.AUndoChangesExecute(Sender: TObject);
begin
  if not Changed then
    Exit;

  if MessageDlg('Do you want to discard all unsaved changes?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  FPoFile.Assign(FPoFileBackup);
  FillGrids;
  Changed := False;
end;

procedure TformPoBatch.ACutExecute(Sender: TObject);
begin
  CutGridsSelection;
end;

procedure TformPoBatch.ACopyExecute(Sender: TObject);
begin
  CopyGridsSelection;
end;

procedure TformPoBatch.APasteExecute(Sender: TObject);
begin
  PasteGridsSelection;
end;

procedure TformPoBatch.ADeleteExecute(Sender: TObject);
begin
  DeleteGridsSelection;
end;

procedure TformPoBatch.ADeleteUpdate(Sender: TObject);
begin
  ADelete.Enabled := ((Assigned(Memo)) and not Memo.Focused) and not Filter.Focused;
end;

procedure TformPoBatch.ASelectAllExecute(Sender: TObject);
begin
  SelectGridsAll;
end;

procedure TformPoBatch.AClearIdenticalExecute(Sender: TObject);
var
  Row: integer;
  ReplacedCount: integer;
  StartRow, EndRow: integer;
begin
  if MessageDlg('Clear identical translations in the selected row(s)?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  ReplacedCount := 0;

  if Grid.Selection.Top = Grid.Selection.Bottom then
  begin
    StartRow := Grid.Row;
    EndRow := Grid.Row;
  end
  else
  begin
    StartRow := Grid.Selection.Top;
    EndRow := Grid.Selection.Bottom;
  end;

  for Row := StartRow to EndRow do
  begin
    if Grid.Cells[CELL_TEXT, Row] = Grid.Cells[CELL_TRANSLATION, Row] then
    begin
      Grid.Cells[CELL_TRANSLATION, Row] := string.Empty;
      Grid.Cells[CELL_VALID, Row] := '0';
      Inc(ReplacedCount);
    end;
  end;

  if ReplacedCount > 0 then
  begin
    Changed := True;

    // Re-apply active column sort if any
    if (FSortColumn >= 0) and (Grid.RowCount > Grid.FixedRows) then
      Grid.SortColRow(True, FSortColumn, Grid.FixedRows, Grid.RowCount - 1);

    Grid.Invalidate;
  end;

  MessageDlg(
    Format('%d translations were cleared.', [ReplacedCount]),
    mtInformation,
    [mbOK],
    0
    );

  Grid.Invalidate;
end;

procedure TformPoBatch.ACopySourceTextExecute(Sender: TObject);
var
  Row: integer;
  CopiedCount: integer;
  StartRow, EndRow: integer;
begin
  if MessageDlg('Copy source text to translations in the selected row(s)?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  CopiedCount := 0;

  if Grid.Selection.Top = Grid.Selection.Bottom then
  begin
    StartRow := Grid.Row;
    EndRow := Grid.Row;
  end
  else
  begin
    StartRow := Grid.Selection.Top;
    EndRow := Grid.Selection.Bottom;
  end;

  for Row := StartRow to EndRow do
  begin
    Grid.Cells[CELL_TRANSLATION, Row] := Grid.Cells[CELL_TEXT, Row];
    Grid.Cells[CELL_VALID, Row] := '0';
    Inc(CopiedCount);
  end;

  if CopiedCount > 0 then
  begin
    Changed := True;

    // Re-apply active column sort if any
    if (FSortColumn >= 0) and (Grid.RowCount > Grid.FixedRows) then
      Grid.SortColRow(True, FSortColumn, Grid.FixedRows, Grid.RowCount - 1);

    Grid.Invalidate;
  end;
  MessageDlg(
    Format('%d translations were copied.', [CopiedCount]),
    mtInformation,
    [mbOK],
    0
    );

  Grid.Invalidate;
end;

procedure TformPoBatch.AEditTranslationOnlyExecute(Sender: TObject);
begin
  GridHeaders.EditorMode := False;
  GridHeaders.Columns[COLUMN_HEADERS_NAME].ReadOnly := AEditTranslationOnly.Checked;
  if AEditTranslationOnly.Checked then
    GridHeaders.Options := GridHeaders.Options - [goAutoAddRows]
  else
    GridHeaders.Options := GridHeaders.Options + [goAutoAddRows];

  Grid.EditorMode := False;
  Grid.Columns[COLUMN_VALID].ReadOnly := True;
  Grid.Columns[COLUMN_TEXT].ReadOnly := AEditTranslationOnly.Checked;
  Grid.Columns[COLUMN_REFERENCE].ReadOnly := AEditTranslationOnly.Checked;
  Grid.Columns[COLUMN_CONTEXT].ReadOnly := AEditTranslationOnly.Checked;
  Grid.Columns[COLUMN_PREVIOUS].ReadOnly := AEditTranslationOnly.Checked;
  Grid.Columns[COLUMN_FUZZY].ReadOnly := AEditTranslationOnly.Checked;
  if AEditTranslationOnly.Checked then
    Grid.Options := Grid.Options - [goAutoAddRows]
  else
    Grid.Options := Grid.Options + [goAutoAddRows];
end;

{ Grid Headers Events }

procedure TformPoBatch.GridHeadersKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  SelRow: integer;
begin
  if not AEditTranslationOnly.Checked and (ssCtrl in Shift) and (Key = VK_DELETE) then
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

    Changed := True;
  end
  else
  // Plain Delete clears cell contents
  if Key = VK_DELETE then
  begin
    if DeleteGridsSelection then
      Key := 0;
  end
  else
  if not AEditTranslationOnly.Checked and (Key = VK_INSERT) then
  begin
    GridHeaders.InsertColRow(False, GridHeaders.Row + 1);
    GridHeaders.Row := GridHeaders.ROw + 1;
    Changed := True;
  end
  else
  if (ssCtrl in Shift) and (Key = VK_X) then
  begin
    CutGridsSelection;
    Key := 0;
  end
  else
  if (ssCtrl in Shift) and (Key = VK_C) then
  begin
    CopyGridsSelection;
    Key := 0;
  end
  else
  if (ssCtrl in Shift) and (Key = VK_V) then
  begin
    PasteGridsSelection;
    Key := 0;
  end;
end;

procedure TformPoBatch.GridHeadersValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
begin
  if OldValue <> NewValue then
    Changed := True;
end;

procedure TformPoBatch.GridHeadersPrepareCanvas(Sender: TObject; aCol, aRow: integer; aState: TGridDrawState);
begin
  if (not (gdSelected in aState) and (gdRowHighlight in aState)) or ((gdSelected in aState) and (not GridHeaders.Focused)) then
  begin
    GridHeaders.Canvas.Brush.Color := ThemeColor(clRowHighlight, clRowHighlightDark);
    GridHeaders.Canvas.Font.Color := clWindowText;
  end;
end;

procedure TformPoBatch.GridHeadersExit(Sender: TObject);
begin
  (Sender as TStringGrid).Invalidate;
end;

{ Grid Events }

procedure TformPoBatch.GridKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  SelIndexes: array of integer = ();
  i, Count: integer;
begin
  // Delete rows via Ctrl+Del (only when not in translation-only mode)
  if not AEditTranslationOnly.Checked and (ssCtrl in Shift) and (Key = VK_DELETE) then
  begin
    if MessageDlg('Delete selected rows?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;

    // Collect persistent entry indexes from column 0 of the selected rows
    Count := Grid.Selection.Bottom - Grid.Selection.Top + 1;
    SetLength(SelIndexes, Count);
    for i := Grid.Selection.Top to Grid.Selection.Bottom do
      SelIndexes[i - Grid.Selection.Top] := StrToIntDef(Grid.Cells[0, i], -1);

    // Save any unsaved changes from the grid back to FPoFile
    SaveGrids;   // or SaveGrids, depending on your code

    // Delete the entries from FPoFile (handles index ordering internally)
    FPoFile.DeleteEntriesByIndexes(SelIndexes);

    Changed := True;
    FillGrids;   // rebuild the grid from updated FPoFile (preserves filter & sort)
    Key := 0;
  end
  else
  // Plain Delete clears cell contents
  if Key = VK_DELETE then
  begin
    if DeleteGridsSelection then
      Key := 0;
  end
  else
  if not AEditTranslationOnly.Checked and (Key = VK_INSERT) then
  begin
    Grid.InsertColRow(False, Grid.Row + 1);
    Grid.Row := Grid.Row + 1;
    Changed := True;
  end
  else
  if (ssCtrl in Shift) and (Key = VK_X) then
  begin
    CutGridsSelection;
    Key := 0;
  end
  else
  if (ssCtrl in Shift) and (Key = VK_C) then
  begin
    CopyGridsSelection;
    Key := 0;
  end
  else
  if (ssCtrl in Shift) and (Key = VK_V) then
  begin
    PasteGridsSelection;
    Key := 0;
  end;
end;

procedure TformPoBatch.GridHeaderClick(Sender: TObject; IsColumn: boolean; Index: integer);
begin
  if not IsColumn then Exit;

  // Click on the fixed row-number column (Index=0) resets sorting
  if Index = 0 then
  begin
    FSortColumn := -1;
    FillGrids;
    Exit;
  end;

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
  if (FSortColumn = CELL_VALID) then
  begin
    ValA := Grid.Cells[CELL_FUZZY, ARow];   // +1 because Cells[0] is row number
    ValB := Grid.Cells[CELL_FUZZY, BRow];
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

procedure TformPoBatch.GridColRowInserted(Sender: TObject; IsColumn: boolean; sIndex, tIndex: integer);
var
  NewEntry: TPOEntry;
  NewIndex: integer;
begin
  if IsColumn or FUpdatingGrid then Exit;   // ignore column inserts and programmatic updates

  // Create a new translatable entry and add it to the end of the model
  NewEntry := TPOEntry.Create;
  NewEntry.MsgId := '';
  NewEntry.MsgStrSimple := '';
  NewEntry.IsFuzzy := False;
  NewIndex := FPoFile.Entries.Add(NewEntry);   // returns the new index

  // Put the permanent index into column 0 of the newly inserted row
  Grid.Cells[0, tIndex] := IntToStr(NewIndex);

  FChanged := True;
  UpdateCaption;
end;

procedure TformPoBatch.GridMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
begin
  Grid.EditorMode := False;
end;

procedure TformPoBatch.GridTopLeftChanged(Sender: TObject);
begin
  Grid.EditorMode := False;
end;

procedure TformPoBatch.GridExit(Sender: TObject);
begin
  (Sender as TStringGrid).Invalidate;
end;

procedure TformPoBatch.GridGetCellHint(Sender: TObject; ACol, ARow: integer; var HintText: string);
begin
  HintText := Grid.Cells[ACol, ARow];
end;

procedure TformPoBatch.GridSelectCell(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);
begin
  if aRow <> FLastRow then
  begin
    FLastRow := aRow;
    UpdateCheck;
  end;
end;

procedure TformPoBatch.GridSelectEditor(Sender: TObject; aCol, aRow: integer; var Editor: TWinControl);
begin
  if (aCol in [COLUMN_TEXT, COLUMN_TRANSLATION, COLUMN_REFERENCE]) then
  begin
    PanelMemo := TPanel.Create(Self);
    PanelMemo.Parent := Grid;
    PanelMemo.BorderStyle := bsNone;
    PanelMemo.Caption := string.Empty;
    PanelMemo.BevelOuter := bvNone;
    PanelMemo.TabStop := False;
    PanelMemo.Visible := False;
    PanelMemo.OnEnter := @PanelMemoEnter; // Event Enter
    PanelMemo.OnUTF8KeyPress := @PanelMemoUTF8KeyPress; // Event UTF8KeyPress
    Memo := TMemo.Create(Self);
    Memo.Parent := PanelMemo;
    Memo.Align := alClient;
    if (Grid.IsCellSelected[aCol, aRow]) and ((Grid.Selection.Height > 0) or (Grid.Selection.Width > 0)) then
    begin
      Memo.Color := clHighlight;
      Memo.Font.Color := clWhite;
    end;
    Memo.HideSelection := False;
    Memo.BorderStyle := bsNone;
    Memo.ScrollBars := ssNone;
    Memo.TabStop := False;
    Memo.WantTabs := True;
    Memo.WordWrap := True;
    Memo.WantReturns := True;
    Memo.BiDiMode := bdLeftToRight;
    EditControlSetBounds(PanelMemo, aCol, aRow);
    Memo.OnKeyDown := @MemoKeyDown;
    Memo.OnEnter := @MemoEnter;
    Memo.OnExit := @MemoExit;
    Memo.OnChange := @MemoChange;
    Memo.Text := Grid.Cells[aCol, aRow];
    Memo.SelStart := 0;
    Memo.SelLength := Length(Memo.Text);

    Editor := PanelMemo;
  end;
end;

procedure TformPoBatch.GridPrepareCanvas(Sender: TObject; aCol, aRow: integer; aState: TGridDrawState);
var
  TS: TTextStyle;
  CustomColor: TColor = clWindow;
begin
  TS := Grid.Canvas.TextStyle;
  TS.Wordbreak := True;
  TS.SingleLine := False;
  Grid.Canvas.TextStyle := TS;

  // Color Cells
  if Grid.EditorMode and (aCol = Grid.Col) and (aRow = Grid.Row) then
  begin
    Grid.Canvas.Brush.Color := clWindow;
    Exit;
  end;

  if (not (gdSelected in aState) and (gdRowHighlight in aState)) or ((gdSelected in aState) and (not Grid.Focused)) then
  begin
    Grid.Canvas.Brush.Color := ThemeColor(clRowHighlight, clRowHighlightDark);
    GridHeaders.Canvas.Font.Color := clWindowText;
  end;

  if Grid.Cells[CELL_FUZZY, aRow] = '1' then
    CustomColor := ThemeColor(clInfo, clInfoDark);

  if (CustomColor <> clWindow) and (Grid.Canvas.Brush.Color <> clNone) then
    Grid.Canvas.Brush.Color := Grid.Canvas.Brush.Color.BlendColor(CustomColor, 50);
end;

procedure TformPoBatch.GridDrawCell(Sender: TObject; aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
var
  CellText: string;
  MsgCtxt: string;
begin
  CellText := Grid.Cells[aCol, aRow];

  // Skip fixed cells
  if (aCol < Grid.FixedCols) or (aRow < Grid.FixedRows) then
    Exit;

  // Only these columns use custom drawing
  if not (aCol in [CELL_TEXT, CELL_TRANSLATION, CELL_REFERENCE]) then
    Exit;

  MsgCtxt := ifthen(aCol = CELL_TEXT, Grid.Cells[CELL_CONTEXT, aRow], string.Empty);

  // Need custom drawing if:
  // - filter is active
  // - or text contains line breaks
  if (Filter.Text = string.Empty) and (MsgCtxt = string.empty) and (Pos(#10, CellText) = 0) and (Pos(#13, CellText) = 0) then
    Exit;

  Grid.Canvas.FillRect(aRect);

  InflateRect(aRect, -2, -2);

  Grid.DrawHighlightedText(
    Grid.Canvas,
    Rect(aRect.Left + 1, aRect.Top + 1, aRect.Right, aRect.Bottom),
    GridDrawColors(ThemeColor(clInfo, clInfoDark), clMaroon, ifthen(gdSelected in AState, clWindowText,
    ThemeColor(clFontBlue, clFontBlueDark)), ThemeColor(clSoftBlue, clSoftBlueDark)),
    CellText,
    Filter.Text,
    MsgCtxt,
    True,
    True,
    False
    );
end;

{ Inline Editor Events}

procedure TformPoBatch.PanelMemoEnter(Sender: TObject);
begin
  Application.QueueAsyncCall(@DelayedSetMemoFocus, 0);
end;

procedure TformPoBatch.PanelMemoUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
begin
  if UTF8Key = #8 then  // backspace
    Memo.SelText := string.Empty
  else
    Memo.SelText := UTF8Key;
end;

procedure TformPoBatch.MemoEnter(Sender: TObject);
begin
  FCellValue := Grid.Cells[Grid.Col, Grid.Row];

  if (Grid.IsCellSelected[Grid.Col, Grid.Row]) and ((Grid.Selection.Height > 0) or (Grid.Selection.Width > 0)) then
  begin
    Memo.Color := clHighlight;
    Memo.Font.Color := clWhite;
  end;
  Grid.Invalidate;
end;

procedure TformPoBatch.MemoExit(Sender: TObject);
begin
  Grid.EditorMode := False;
  Grid.Invalidate;
end;

procedure TformPoBatch.MemoChange(Sender: TObject);
begin
  Grid.Cells[Grid.Col, Grid.Row] := TMemo(Sender).Text;
  Changed := True;
  UpdateRowHeights;
  EditControlSetBounds(PanelMemo, Grid.Col, Grid.Row);
end;

procedure TformPoBatch.MemoKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Grid.EditorMode := False;
    Grid.Cells[Grid.Col, Grid.Row] := FCellValue;
    Key := 0;
  end
  else
  if (Key = VK_RETURN) and not ((ssCtrl in Shift) or (ssShift in Shift)) then
  begin
    Grid.EditorMode := False;
    Key := 0;
  end;
end;

{ Other Events }

procedure TformPoBatch.EditControlSetBounds(Sender: TWinControl; aCol, aRow: integer; OffsetLeft: integer;
  OffsetTop: integer; OffsetRight: integer; OffsetBottom: integer);
var
  Rect: TRect;
begin
  if Assigned(Sender) then
  begin
    Rect := Grid.CellRect(aCol, aRow);
    Sender.SetBounds(Rect.Left + OffsetLeft, Max(Rect.Top, Grid.RowHeights[0]) + OffsetTop,
      Rect.Right - Rect.Left + OffsetRight,
      Rect.Bottom - Rect.Top + OffsetBottom);
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

procedure TformPoBatch.ListPathDrawItem(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
var
  Status: TPoFileStatus;
  BgColor: TColor;
begin
  if (Index < 0) or (Index >= Length(FFileStatuses)) then Exit;

  with (Control as TListBox).Canvas do
  begin
    // Determine background color based on file status
    Status := FFileStatuses[Index];
    case Status of
      psCorrect: BgColor := ThemeColor(clSoftGreen, clSoftGreenDark);   // light green
      psFuzzy: BgColor := ThemeColor(clSoftYellow, clSoftYellowDark);   // light yellow
      psEmptyTranslation: BgColor := clWindow;  // default (white)
    end;

    // If the item is selected, use system highlight color
    if odSelected in State then
      BgColor := clHighlight;

    // Fill background
    Brush.Style := bsSolid;
    Brush.Color := BgColor;
    FillRect(ARect);

    // Set text color: white for selected, black otherwise
    if odSelected in State then
      Font.Color := clHighlightText
    else
      Font.Color := clWindowText;

    // Draw the text with a small offset
    TextOut(ARect.Left + 4, ARect.Top + 2, (Control as TListBox).Items[Index]);

    // Draw focus rectangle if the control is focused and item is selected
    if odFocused in State then
      DrawFocusRect(ARect);
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

procedure TformPoBatch.ImageSwitchClick(Sender: TObject);
begin
  SwitchCheck;
end;

procedure TformPoBatch.PanelSwitchEnter(Sender: TObject);
begin
  FPanelFocused := True;
  PanelSwitch.Invalidate;
end;

procedure TformPoBatch.PanelSwitchExit(Sender: TObject);
begin
  FPanelFocused := False;
  PanelSwitch.Invalidate;
end;

procedure TformPoBatch.PanelSwitchPaint(Sender: TObject);
begin
  if FPanelFocused then
    PanelSwitch.Canvas.DrawFocusRect(PanelSwitch.ClientRect);
end;

{ Properties Methods }

procedure TformPoBatch.SetChanges(Value: boolean);
begin
  FChanged := Value;
  AUndoChanges.Enabled := FChanged;
  UpdateCaption;
end;

{ Methods File Operations }

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
      else
        ;
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
  ValidExtensions := ['.po', '.pot'];

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
  ValidExtensions := ['.po', '.pot'];
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
    FPoFile.Reset;
    FPoFile.HeaderValue['X-Generator'] := 'PoBatch ' + GetAppVersion;
    FFileName := AFileName;
    Changed := False;
    FPoFileBackup.Assign(FPoFile);
    FillGrids;
    SyncPath;
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
    Grid.Row := 1;
    UpdateCheck;
    Result := True;
  end;
end;

function TformPoBatch.OpenPath(const AFileName: string): boolean;
var
  SR: TSearchRec;
  TempFiles: TStringList;
  TempNames: TStringList;
  FullPath: string;
  i: integer;
begin
  Result := False;
  if not DirectoryExists(AFileName) then Exit;

  TempFiles := TStringList.Create;
  TempNames := TStringList.Create;
  try
    // Scan the directory into temporary lists
    if FindFirst(IncludeTrailingPathDelimiter(AFileName) + '*.po', faAnyFile, SR) = 0 then
    begin
      repeat
        FullPath := IncludeTrailingPathDelimiter(AFileName) + SR.Name;
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

    // We analyze each file and save the status
    SetLength(FFileStatuses, FPoFiles.Count);
    for i := 0 to FPoFiles.Count - 1 do
      FFileStatuses[i] := TPOFile.GetFileStatus(FPoFiles[i]);

    UpdateCaption;
    SyncPath;

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
  MenuPathClose.Enabled := Enable;
  if not Enabled then
    FLastPathIndex := -1;
end;

procedure TformPoBatch.SyncPath;
var
  Idx: integer;
begin
  ListPath.ItemIndex := -1;
  FLastPathIndex := -1;
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
    ; // Ignore file size check errors
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

      // Load into FPoFile
      Stream := TStringStream.Create(Input.Text, TEncoding.UTF8);
      try
        FPoFile.LoadFromStream(Stream);
      finally
        Stream.Free;
      end;
      FPoFileBackup.Assign(FPoFile);

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
  FPoFile.HeaderValue['X-Generator'] := 'PoBatch ' + GetAppVersion;
  FillGrids;

  Output := TStringList.Create;
  try
    try
      // Save FPoFile content into a string first
      begin
        Stream := TStringStream.Create(string.Empty, TEncoding.UTF8);
        try
          FPoFile.SaveToStream(Stream);          // serialize all entries to UTF-8 stream
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
      FPoFileBackup.Assign(FPoFile);

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

{ Methods }

procedure TformPoBatch.UpdateRowHeights;
var
  Row, Col: integer;
  R: TRect;
  H, MaxH, ColTextWidth: integer;
  SavedFont: TFont;
begin
  // Ensure the grid widget is alive and has a valid canvas handle
  Grid.HandleNeeded;

  // Save current canvas font and assign the grid's actual font
  SavedFont := TFont.Create;
  try
    SavedFont.Assign(Grid.Canvas.Font);
    Grid.Canvas.Font.Assign(Grid.Font);

    for Row := Grid.FixedRows to Grid.RowCount - 1 do
    begin
      MaxH := Grid.DefaultRowHeight;

      for Col := 0 to Grid.ColCount - 1 do
      begin
        // Calculate usable text width inside the cell
        // Subtract grid line widths and small padding (adjust as needed)
        ColTextWidth := Grid.ColWidths[Col] - 2 * Grid.GridLineWidth - 4;

        // Skip columns with no usable width – prevents absurd heights
        if ColTextWidth < 10 then
          Continue;

        R := Rect(0, 0, ColTextWidth, 0);

        // If you have per-cell fonts, apply them here:
        // (e.g. fire Grid.OnPrepareCanvas if assigned)

        DrawText(Grid.Canvas.Handle,
          PChar(Grid.Cells[Col, Row]),
          Length(Grid.Cells[Col, Row]),
          R,
          DT_WORDBREAK or DT_CALCRECT);

        // Add vertical padding
        H := R.Bottom - R.Top + 8;

        if H > MaxH then
          MaxH := H;
      end;

      Grid.RowHeights[Row] := MaxH;
    end;

  finally
    // Restore original canvas font
    Grid.Canvas.Font.Assign(SavedFont);
    SavedFont.Free;
  end;
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

procedure TformPoBatch.UpdateFileStatus(const AFileName: string);
var
  Idx: integer;
begin
  // Only if a folder is open and we have a valid file
  if (FPath = '') or (AFileName = '') then Exit;
  if ExtractFilePath(AFileName) <> IncludeTrailingPathDelimiter(FPath) then Exit;

  Idx := FPoFiles.IndexOf(AFileName);
  if (Idx < 0) or (Idx >= Length(FFileStatuses)) then Exit;

  FFileStatuses[Idx] := TPOFile.GetFileStatus(AFileName);
  ListPath.Invalidate;   // repaint the list
end;

procedure TformPoBatch.UpdateCheck;
begin
  if (Grid.Row > -1) and ((Grid.Cells[CELL_FUZZY, FLastRow] = '0') or (Grid.Cells[CELL_FUZZY, FLastRow] = '1')) then
    ImageSwitch.ImageIndex := StrToInt(Grid.Cells[CELL_FUZZY, FLastRow]);
end;

procedure TformPoBatch.SwitchCheck;
begin
  if Grid.Row > -1 then
  begin
    if ImageSwitch.ImageIndex = 0 then
      ImageSwitch.ImageIndex := 1
    else
      ImageSwitch.ImageIndex := 0;

    Grid.Cells[CELL_FUZZY, Grid.Row] := ImageSwitch.ImageIndex.ToString;
    SaveGrids;
    Grid.Cells[CELL_VALID, Grid.Row] := IfThen(CurrentEntry.IsValid, '1', '0');

    Changed := True;
    Grid.Invalidate;
  end;
end;

function TformPoBatch.CurrentEntry: TPOEntry;
var
  Row: integer;
  EntryIndex: integer;
begin
  Result := nil;
  // Safety check: model must exist
  if not Assigned(FPoFile) then
    Exit;

  Row := Grid.Row;
  // Ignore header row or invalid selection
  if (Row < Grid.FixedRows) or (Row >= Grid.RowCount) then
    Exit;

  // Column 0 stores the permanent index in PoFile.Entries
  EntryIndex := StrToIntDef(Grid.Cells[0, Row], -1);
  if (EntryIndex < 0) or (EntryIndex >= FPoFile.Entries.Count) then
    Exit;

  Result := FPoFile.Entries[EntryIndex];
end;

procedure TformPoBatch.DelayedSetMemoFocus(Data: PtrInt);
begin
  if Assigned(Memo) and (Memo.CanFocus) then
  begin
    Memo.SetFocus;
    if (Memo.SelLength = 0) then
      Memo.SelStart := Length(Memo.Text);
  end;
end;

procedure TformPoBatch.FixSplitters(Data: PtrInt);
begin
  ListPath.Left := 0;
  SplitterPath.Left := ListPath.Left + ListPath.Width;

  GridHeaders.Top := 0;
  SplitterHeaders.Top := GridHeaders.Top + GridHeaders.Height;

  Pages.Top := Height;
  SplitterPages.Top := Pages.Top - 1;
end;

function TformPoBatch.CutGridsSelection: boolean;
begin
  // Perform copy first, then clear the selection
  Result := CopyGridsSelection;
  if Result then
    Result := DeleteGridsSelection;
end;

function TformPoBatch.CopyGridsSelection: boolean;
begin
  try
    if ActiveControl = Grid then
      Grid.CopyToClipboard(True)
    else if ActiveControl = GridHeaders then
      GridHeaders.CopyToClipboard(True)
    else
      Exit;
  except
    Result := False;
  end;
  Result := True;
end;

function TformPoBatch.PasteGridsSelection: boolean;
begin
  Result := False;
  if ActiveControl = Grid then
  begin
    Grid.PasteFromClipboard;
    Result := True;
  end
  else if ActiveControl = GridHeaders then
  begin
    GridHeaders.PasteFromClipboard;
    Result := True;
  end;
  if Result then
  begin
    Changed := True;
    UpdateRowHeights;
  end;
end;

function TformPoBatch.DeleteGridsSelection: boolean;
begin
  Result := False;

  if ActiveControl = Grid then
  begin
    if (not AEditTranslationOnly.Checked or ((Grid.Selection.Left = CELL_TRANSLATION) and
      (Grid.Selection.Right = CELL_TRANSLATION))) then
    begin
      if (Grid.Selection.Height > 0) then
        Grid.Clean(Max(Grid.Selection.Left, CELL_TEXT), Grid.Selection.Top, Grid.Selection.Right, Grid.Selection.Bottom, [gzNormal])
      else
        Grid.Clean(Grid.Col, Grid.Row, Grid.Col, Grid.Row, [gzNormal]);

      Changed := True;
      Result := True;
    end;
  end
  else
  if ActiveControl = GridHeaders then
  begin
    if (not AEditTranslationOnly.Checked or ((GridHeaders.Selection.Left = CELL_HEADERS_VALUE) and
      (GridHeaders.Selection.Right = CELL_HEADERS_VALUE))) and (GridHeaders.Selection.Height > 0) then
    begin
      if (GridHeaders.Selection.Height > 0) then
        GridHeaders.Clean(GridHeaders.Selection, [gzNormal])
      else
        GridHeaders.Clean(GridHeaders.Col, GridHeaders.Row, GridHeaders.Col, GridHeaders.Row, [gzNormal]);

      Changed := True;
      Result := True;
    end;
  end;
end;

function TformPoBatch.SelectGridsAll: boolean;
begin
  if ActiveControl = Grid then
    Grid.Selection := TGridRect.Create(CELL_VALID, 0, CELL_REFERENCE, Grid.RowCount)
  else
  if ActiveControl = GridHeaders then
    GridHeaders.Selection := TGridRect.Create(CELL_VALID, 0, CELL_REFERENCE, GridHeaders.RowCount);
  Result := True;
end;

function TformPoBatch.EntryMatchesFilter(Entry: TPOEntry; const AFilter: string): boolean;
var
  PrevStrings: TStrings;
  LowerFilter: string;
begin
  if AFilter = '' then Exit(True);
  LowerFilter := LowerCase(AFilter);

  if (AFilter = '1') or (AFilter = '=1') then Exit(Entry.IsValid)
  else
  if (AFilter = '0') or (AFilter = '=0') then Exit(not Entry.IsValid);

  // Check original
  if Pos(LowerFilter, LowerCase(Entry.MsgId)) > 0 then Exit(True);

  // Check translation
  if Pos(LowerFilter, LowerCase(Entry.MsgStrSimple)) > 0 then Exit(True);

  // Check reference
  if Pos(LowerFilter, LowerCase(Entry.Reference)) > 0 then Exit(True);

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
  SavedEntryIndex: integer;    // permanent entry index before refill
  TargetRow: integer;          // row to select after refill
begin
  if not Assigned(FPoFile) then
  begin
    Grid.RowCount := Grid.FixedRows;
    GridHeaders.RowCount := GridHeaders.FixedRows;
    Exit;
  end;

  // Fill the headers grid
  FUpdatingGrid := True;
  GridHeaders.BeginUpdate;
  try
    Headers := FPoFile.Headers;
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
    // Remember permanent index of the currently selected entry
    SavedEntryIndex := -1;
    if (Grid.Row >= Grid.FixedRows) and (Grid.Row < Grid.RowCount) then
      SavedEntryIndex := StrToIntDef(Grid.Cells[0, Grid.Row], -1);

    // Reset rows, keep only fixed header row
    RowIndex := Grid.FixedRows;
    Grid.RowCount := RowIndex;

    for i := 0 to FPoFile.Entries.Count - 1 do
    begin
      Entry := FPoFile.Entries[i];
      if Entry.MsgId = '' then Continue;  // skip header entry

      // Apply filter if one is set
      if (Filter.Text <> '') and not EntryMatchesFilter(Entry, Filter.Text) then
        Continue;

      Grid.RowCount := Grid.RowCount + 1;

      // Column 0: permanent index of the entry in the PO list
      Grid.Cells[0, RowIndex] := IntToStr(i);

      // Column 1: valid calculate
      Grid.Cells[CELL_VALID, RowIndex] := IfThen(Entry.IsValid, '1', '0');

      // Column 2: original text (msgid)
      Grid.Cells[CELL_TEXT, RowIndex] := Entry.MsgId;

      // Column 3: translation (msgstr)
      Grid.Cells[CELL_TRANSLATION, RowIndex] := Entry.MsgStrSimple;

      // Column 4: reference (#:)
      Grid.Cells[CELL_REFERENCE, RowIndex] := Entry.Reference;

      // Column 5: context (msgctxt)
      Grid.Cells[CELL_CONTEXT, RowIndex] := Entry.MsgCtxt;

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
      Grid.Cells[CELL_PREVIOUS, RowIndex] := PreviousText;

      // Column 7: fuzzy flag (1 if fuzzy, 0 otherwise)
      Grid.Cells[CELL_FUZZY, RowIndex] := IfThen(Entry.IsFuzzy, '1', '0');

      Inc(RowIndex);
    end;

    // Re-apply active column sort if any
    if (FSortColumn >= 0) and (Grid.RowCount > Grid.FixedRows) then
      Grid.SortColRow(True, FSortColumn, Grid.FixedRows, Grid.RowCount - 1);

    UpdateRowHeights;

    // Restore selection to the previously saved entry index, if possible
    TargetRow := Grid.FixedRows;  // fallback to first data row
    if (SavedEntryIndex >= 0) and (Grid.RowCount > Grid.FixedRows) then
    begin
      for i := Grid.FixedRows to Grid.RowCount - 1 do
        if StrToIntDef(Grid.Cells[0, i], -1) = SavedEntryIndex then
        begin
          TargetRow := i;
          Break;
        end;
      // If not found, stay on the first data row
    end;

    // Set the row only if data rows exist
    if Grid.RowCount > Grid.FixedRows then
    begin
      if TargetRow >= Grid.RowCount then
        TargetRow := Grid.RowCount - 1;
      Grid.Row := TargetRow;
    end;
  finally
    Grid.EndUpdate;
    FUpdatingGrid := False;
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
  if not Assigned(FPoFile) then Exit;

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
    FPoFile.Headers := Headers;
  finally
    Headers.Free;
  end;

  // Save entries from main translation grid
  for Row := Grid.FixedRows to Grid.RowCount - 1 do
  begin
    // Column 0 holds the permanent entry index
    EntryIndex := StrToIntDef(Grid.Cells[0, Row], -1);
    if (EntryIndex < 1) or (EntryIndex >= FPoFile.Entries.Count) then
      Continue;

    Entry := FPoFile.Entries[EntryIndex];

    // Update text from cell CELL_TEXT
    if Trim(Grid.Cells[CELL_TEXT, Row]) = string.Empty then
      Entry.MsgId := UNDEFINED
    else
      Entry.MsgId := Grid.Cells[CELL_TEXT, Row];

    // Update translation from cell CELL_TRANSLATION
    Entry.MsgStrSimple := Grid.Cells[CELL_TRANSLATION, Row];

    // Update reference from cell CELL_REFERENCE
    Entry.Reference := Grid.Cells[CELL_REFERENCE, Row];

    // Update context from cell CELL_CONTEXT
    Entry.Reference := Grid.Cells[CELL_CONTEXT, Row];

    // Update fuzzy flag from cell CELL_FUZZY
    Entry.IsFuzzy := (Grid.Cells[CELL_FUZZY, Row] = '1');
  end;
end;

end.
