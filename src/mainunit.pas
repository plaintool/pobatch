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
  RichMemo,
  RichMemoCellEditor,
  OneShotTimer,
  SpellChecker,
  LangCodes,
  powrap;

type

  { TformPoBatch }

  TformPoBatch = class(TForm)
    {%Region -fold Form Common}
    ACopySourceText: TAction;
    AClearIdentical: TAction;
    AClosePath: TAction;
    APathNewFilesFromPot: TAction;
    ANewFromPot: TAction;
    AExit: TAction;
    AOpenPath: TAction;
    ASaveAs: TAction;
    ASave: TAction;
    AOpen: TAction;
    ANewWindow: TAction;
    ANew: TAction;
    AWordWrapGrid: TAction;
    AWordWrapTranslatePanel: TAction;
    ASpellCheckTranslation: TAction;
    ASpellCheckSource: TAction;
    APathRenameFiles: TAction;
    AMemoUndo: TAction;
    AMemoDefaultZoom: TAction;
    AMemoBidiRightToLeft: TAction;
    AMemoSelectAll: TAction;
    AMemoClear: TAction;
    AMemoPaste: TAction;
    AMemoCopy: TAction;
    AMemoCut: TAction;
    AValidFile: TAction;
    APathValidFiles: TAction;
    ASyncWithPot: TAction;
    APathSyncFilesWithPot: TAction;
    APathSelectAll: TAction;
    APathDeleteFiles: TAction;
    AEditPluralForm: TAction;
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
    GridComments: TStringGrid;
    GridPlural: TStringGrid;
    ImagesSwitch: TImageList;
    ImageSwitch: TImage;
    LabelSwitch: TLabel;
    ListPath: TListBox;
    MainMenu: TMainMenu;
    MemoSource: TRichMemo;
    MemoPlural: TRichMemo;
    MemoTranslation: TRichMemo;
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
    MenuEditPluralForm: TMenuItem;
    MenuHelpGNUgettext: TMenuItem;
    MenuColumnContext: TMenuItem;
    MenuColumnPlural: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuPathDeleteFile: TMenuItem;
    MenuFormat: TMenuItem;
    MenuItem1: TMenuItem;
    MenuPathValidFile: TMenuItem;
    MenuItem3: TMenuItem;
    MenuPathRenameFile: TMenuItem;
    MenuMemoBidiMode: TMenuItem;
    MenuMemoClear: TMenuItem;
    MenuMemoCopy: TMenuItem;
    MenuMemoCut: TMenuItem;
    MenuMemoDefaultZoom: TMenuItem;
    MenuMemoPaste: TMenuItem;
    MenuMemoSelectAll: TMenuItem;
    MenuMemoUndo: TMenuItem;
    MenuSyncWithPot: TMenuItem;
    MenuSyncFilesWithPot: TMenuItem;
    MenuWordWrapTranslatePanel: TMenuItem;
    MenuWordWrapGrid: TMenuItem;
    MenuPopupEditPluralForm: TMenuItem;
    MenuTranslatePanel: TMenuItem;
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
    PanelTranslation: TPanel;
    PanelSource: TPanel;
    PanelPageTranslation: TPanel;
    PanelCheck: TPanel;
    PanelSwitch: TPanel;
    PanelClient: TPanel;
    PanelFilter: TPanel;
    dialogSave: TSaveDialog;
    PopupGrid: TPopupMenu;
    PopupPath: TPopupMenu;
    PopupMemo: TPopupMenu;
    Separator10: TMenuItem;
    Separator11: TMenuItem;
    Separator12: TMenuItem;
    Separator13: TMenuItem;
    Separator14: TMenuItem;
    Separator15: TMenuItem;
    Separator16: TMenuItem;
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
    ShapePlural: TShape;
    SpellSource: TSpellChecker;
    SpellTranslation: TSpellChecker;
    SplitterTranslate: TSplitter;
    SplitterHeaders: TSplitter;
    SplitterPages: TSplitter;
    SplitterPath: TSplitter;
    StatusBar: TStatusBar;
    Grid: TStringGrid;
    PageTranslate: TTabSheet;
    PageComments: TTabSheet;
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
    procedure ApplicationPropException(Sender: TObject; E: Exception);
    procedure GridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    { Menu Events }
    procedure MenuTranslatePanelClick(Sender: TObject);
    procedure MenuHeadersClick(Sender: TObject);
    procedure MenuColumnContextClick(Sender: TObject);
    procedure MenuColumnReferenceClick(Sender: TObject);
    procedure MenuColumnPluralClick(Sender: TObject);
    procedure MenuBuyMeACoffeeClick(Sender: TObject);
    procedure MenuCheckForUpdatesClick(Sender: TObject);
    procedure MenuAutoCheckUpdatesClick(Sender: TObject);
    procedure MenuHelpGNUgettextClick(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    { Action Events }
    procedure ANewExecute(Sender: TObject);
    procedure ANewWindowExecute(Sender: TObject);
    procedure ANewFromPotExecute(Sender: TObject);
    procedure AOpenExecute(Sender: TObject);
    procedure ASaveExecute(Sender: TObject);
    procedure ASaveAsExecute(Sender: TObject);
    procedure AOpenPathExecute(Sender: TObject);
    procedure AClosePathExecute(Sender: TObject);
    procedure AExitExecute(Sender: TObject);
    procedure AUndoChangesExecute(Sender: TObject);
    procedure ACopyExecute(Sender: TObject);
    procedure ACutExecute(Sender: TObject);
    procedure APasteExecute(Sender: TObject);
    procedure ADeleteExecute(Sender: TObject);
    procedure ASelectAllExecute(Sender: TObject);
    procedure ACutUpdate(Sender: TObject);
    procedure ACopyUpdate(Sender: TObject);
    procedure APasteUpdate(Sender: TObject);
    procedure ADeleteUpdate(Sender: TObject);
    procedure ASelectAllUpdate(Sender: TObject);
    procedure ACopySourceTextExecute(Sender: TObject);
    procedure AClearIdenticalExecute(Sender: TObject);
    procedure AEditPluralFormExecute(Sender: TObject);
    procedure AEditTranslationOnlyExecute(Sender: TObject);
    procedure AMemoUndoExecute(Sender: TObject);
    procedure APathNewFilesFromPotExecute(Sender: TObject);
    procedure APathSyncFilesWithPotExecute(Sender: TObject);
    procedure APathValidFilesExecute(Sender: TObject);
    procedure APathRenameFilesExecute(Sender: TObject);
    procedure APathDeleteFilesExecute(Sender: TObject);
    procedure APathSelectAllExecute(Sender: TObject);
    procedure ASyncWithPotExecute(Sender: TObject);
    procedure AValidFileExecute(Sender: TObject);
    procedure AMemoCutExecute(Sender: TObject);
    procedure AMemoCopyExecute(Sender: TObject);
    procedure AMemoPasteExecute(Sender: TObject);
    procedure AMemoClearExecute(Sender: TObject);
    procedure AMemoSelectAllExecute(Sender: TObject);
    procedure AMemoBidiRightToLeftExecute(Sender: TObject);
    procedure AMemoDefaultZoomExecute(Sender: TObject);
    procedure AWordWrapGridExecute(Sender: TObject);
    procedure AWordWrapTranslatePanelExecute(Sender: TObject);
    procedure ASpellCheckSourceExecute(Sender: TObject);
    procedure ASpellCheckTranslationExecute(Sender: TObject);
    { Grids Universal }
    procedure GridsUniversalKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure GridUniversalColRowInserted(Sender: TObject; IsColumn: boolean; sIndex, tIndex: integer);
    procedure GridUniversalExit(Sender: TObject);
    procedure GridUniversalPrepareCanvas(Sender: TObject; aCol, aRow: integer; aState: TGridDrawState);
    { Grid Headers Events }
    procedure GridHeadersValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
    procedure GridHeadersGetCellHint(Sender: TObject; ACol, ARow: integer; var HintText: string);
    { Grid Plural Events }
    procedure GridPluralValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
    { Grid Comments Events }
    procedure GridCommentsValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
    procedure GridCommentsGetCellHint(Sender: TObject; ACol, ARow: integer; var HintText: string);
    { Grid Events }
    procedure GridKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure GridHeaderClick(Sender: TObject; IsColumn: boolean; Index: integer);
    procedure GridHeaderSized(Sender: TObject; IsColumn: boolean; Index: integer);
    procedure GridCompareCells(Sender: TObject; ACol, ARow, BCol, BRow: integer; var Result: integer);
    procedure GridColRowInserted(Sender: TObject; IsColumn: boolean; sIndex, tIndex: integer);
    procedure GridMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
    procedure GridGetCellHint(Sender: TObject; ACol, ARow: integer; var HintText: string);
    procedure GridSelectCell(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);
    procedure GridSelection(Sender: TObject; aCol, aRow: integer);
    procedure GridPrepareCanvas(Sender: TObject; aCol, aRow: integer; aState: TGridDrawState);
    procedure GridDrawCell(Sender: TObject; aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
    procedure GridExit(Sender: TObject);
    procedure GridTopLeftChanged(Sender: TObject);
    procedure GridSelectEditor(Sender: TObject; aCol, aRow: integer; var Editor: TWinControl);
    procedure GridValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
    { Inline Editor Events}
    procedure MemoEnter(Sender: TObject);
    procedure MemoExit(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    { Other Events }
    procedure EditControlSetBounds(Sender: TWinControl; aCol, aRow: integer; OffsetLeft: integer = 0;
      OffsetTop: integer = 3; OffsetRight: integer = -1; OffsetBottom: integer = 0);
    procedure ListPathClick(Sender: TObject);
    procedure ListPathMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure ListPathKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure ListPathDrawItem(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
    procedure FilterChange(Sender: TObject);
    procedure btnFilterClearClick(Sender: TObject);
    procedure ImageSwitchClick(Sender: TObject);
    procedure PanelPageTranslationResize(Sender: TObject);
    procedure PanelSwitchEnter(Sender: TObject);
    procedure PanelSwitchExit(Sender: TObject);
    procedure PanelSwitchPaint(Sender: TObject);
    procedure SpellSourceSpellCheckComplete(Sender: TObject; ErrorCount: integer);
    procedure SpellTranslationSpellCheckComplete(Sender: TObject; ErrorCount: integer);
    procedure SplitterTranslateMoved(Sender: TObject);
    procedure MemoSourceEnter(Sender: TObject);
    procedure MemoSourceChange(Sender: TObject);
    procedure MemoPluralChange(Sender: TObject);
    procedure MemoTranslationEnter(Sender: TObject);
    procedure MemoTranslationChange(Sender: TObject);
    {%EndRegion}
  private
    FRichEditor: TRichMemoCellEditor;

    FPoFile: TPoFile;
    FPoFileBackup: TPoFile;
    FFileName: string;
    FLanguage: string;
    FInitialized: boolean;
    FCommandLineFile: string;
    FUpdatingGrid: boolean;
    FPathIndex: integer;
    FLastPathIndex: integer;
    FLastRow: integer;
    FPanelFocused: boolean;
    FPoFiles: TStringList;
    FPotFile: string;
    FFileStatuses: TPOFileStatusArray;
    FSelectPathTimer: TTimer;
    FPathMouseSelecting: boolean;
    FFilterUpdating: boolean;
    FFilterPending: boolean;
    FAnalizeGeneration: integer;

    FChanged: boolean;
    FSaving: boolean;
    FPath: string;
    FAutoCheckUpdates: boolean;
    FSortOrder: TSortOrder;
    FSortColumn: integer;
    FSplitRatio: double;
    FWordWrap: boolean;
    FMaxRowHeight: integer;

    // Properties Methods
    procedure SetChanged(Value: boolean);
    procedure SetSplitRatio(Value: double);
    procedure SetWordWrap(Value: boolean);

    // Methods File Operations
    function IsCanClose(Fast: boolean = False): boolean;
    function PromptSaveChanges: TModalResult;
    procedure HandleCommandLineParameters;
    function ValidateFileForOpen(const AFileName: string): boolean;
    function NewFile(AFileName: string = string.Empty): boolean;
    function OpenFile(const AFileName: string; CheckCanClose: boolean = True): boolean;
    function OpenPath(const APath: string; Force: boolean = False): boolean;
    procedure AnalizePath(AIndex: integer = -1; ADraw: boolean = False);
    procedure LoadPath(Data: PtrInt);
    procedure ClosePath;
    procedure UpdatePath;
    procedure SyncPath;
    procedure SelectPath;
    function LoadFile(AFileName: string): boolean;
    function SaveFile(AFileName: string; Fast: boolean = False): boolean;
    function CreatePoFileFromPot(const APotFileName, ACode: string; out ANewFileName: string): boolean;
    // Methods
    procedure UpdateCaption;
    procedure UpdateInterface;
    procedure UpdateFileStatus(const AFileName: string);
    procedure UpdateSwitch(aRow: integer = -1);
    procedure UpdateValid(aRow: integer = -1);
    procedure UpdateTranslatePanel(aRow: integer = -1);
    procedure UpdateSpellCheckMemo(Data: PtrInt);
    procedure SwitchCheck;
    function CanActionEnable: boolean;
    function RowEntry(aRow: integer = -1): TPOEntry;
    procedure DelayedSetMemoFocus(Data: PtrInt);
    procedure FixSplitters(Data: PtrInt);
    function CutGridsSelection: boolean;
    function CopyGridsSelection: boolean;
    function PasteGridsSelection: boolean;
    function DeleteGridsSelection: boolean;
    function SelectGridsAll: boolean;
    function EntryMatchesFilter(Entry: TPOEntry; const AFilter: string): boolean;
    function GetEntiryIndex(aRow: integer = -1): integer;
    function DetectLanguage(const AFileName: string): string;
    procedure FillGrid;
    procedure SaveRow(aRow: integer = -1);   // Save grid row data to model; -1 = current row
    procedure SaveGrid;
    procedure FillGridHeaders;
    procedure SaveGridHeaders;
    procedure FillGridPlural(aRow: integer = -1);
    procedure SaveGridPlural(aRow: integer = -1);
    procedure FillGridComments(aRow: integer = -1);
    procedure SaveGridComments(aRow: integer = -1);
  public
    property Changed: boolean read FChanged write SetChanged;
    property Path: string read FPath write FPath;
    property AutoCheckUpdates: boolean read FAutoCheckUpdates write FAutoCheckUpdates;
    property SortOrder: TSortOrder read FSortOrder write FSortOrder;
    property SortColumn: integer read FSortColumn write FSortColumn;
    property SplitRatio: double read FSplitRatio write SetSplitRatio;
    property PoFiles: TStringList read FPoFiles write FPoFiles;
    property PotFile: string read FPotFile write FPotFile;
    property FileStatuses: TPOFileStatusArray read FFileStatuses write FFileStatuses;
    property WordWrap: boolean read FWordWrap write SetWordWrap;
  end;

var
  formPoBatch: TformPoBatch;

  {%Region -fold Const}

const
  COLUMN_HEADERS_NAME = 0;
  COLUMN_HEADERS_VALUE = 1;
  CELL_HEADERS_NAME = 1;
  CELL_HEADERS_VALUE = 2;
  COLUMN_COMMENTS_TYPE = 0;
  COLUMN_COMMENTS_VALUE = 1;
  CELL_COMMENTS_TYPE = 1;
  CELL_COMMENTS_VALUE = 2;
  COLUMN_PLURAL_PLURAL = 0;
  CELL_PLURAL_PLURAL = 1;

  COLUMN_VALID = 0;
  COLUMN_TEXT = 1;
  COLUMN_TRANSLATION = 2;
  COLUMN_CONTEXT = 3;
  COLUMN_PLURAL = 4;
  COLUMN_REFERENCE = 5;
  COLUMN_FUZZY = 6;
  CELL_VALID = 1;
  CELL_TEXT = 2;
  CELL_TRANSLATION = 3;
  CELL_CONTEXT = 4;
  CELL_PLURAL = 5;
  CELL_REFERENCE = 6;
  CELL_FUZZY = 7;

  UNDEFINED = 'undefined';

  // Colors
  clRowHighlight = TColor($FFF0DC);
  clRowHighlightDark = TColor($5A4037);
  clInfo = TColor($96FFFF);
  clInfoDark = TColor($009696);
  clLine = TColor($E8E8E8);
  clLineDark = TColor($484848);
  clLightGray = TColor($FAFAFA);
  clLightGrayDark = TColor($181818);
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

  {%EndRegion}

const
  REPO = 'plaintool/pobatch';
  APP_NAME = 'pobatch';

implementation

uses formabout, formdonate, settings, stringgridhelper, stringhelper, colorhelper, controlshelper, darkutils, checkupdates, osutils,
  RichMemoHelper, pascalutils;

  {$R *.lfm}

  { TformPoBatch }

  {%Region -fold Form Events}

procedure TformPoBatch.FormCreate(Sender: TObject);
var
  HeaderList: TStringList;
begin
  // Enable file dropping
  AllowDropFiles := True;

  // Initialize state
  FInitialized := False;
  FAutoCheckUpdates := True;
  FFileName := string.Empty;
  FPath := string.Empty;
  FPoFiles := TStringList.Create;
  FPotFile := string.Empty;
  SetLength(FFileStatuses, 0);
  FCommandLineFile := string.Empty;
  FSortColumn := -1;
  FSortOrder := soAscending;
  FLastPathIndex := -1;
  FLastRow := -1;
  FSplitRatio := 0.5;
  FPathIndex := -1;
  FLastPathIndex := -1;
  FWordWrap := True;
  FPathMouseSelecting := False;
  FSaving := False;
  FFilterUpdating := False;
  FFilterPending := False;
  FAnalizeGeneration := 0;

  // Initialize components
  SpellSource.DicPath := TOS.GetSettingsDirectory('plaintool', 'dic');
  SpellTranslation.DicPath := TOS.GetSettingsDirectory('plaintool', 'dic');

  Grid.GridLineColor := TDarkUtils.ThemeColor(clLine, clLineDark);
  Grid.AlternateColor := TDarkUtils.ThemeColor(clLightGray, clLightGrayDark);
  GridHeaders.GridLineColor := TDarkUtils.ThemeColor(clLine, clLineDark);
  GridPlural.GridLineColor := TDarkUtils.ThemeColor(clLine, clLineDark);
  GridComments.GridLineColor := TDarkUtils.ThemeColor(clLine, clLineDark);

  // Upper bound for a single row height, so a row cannot grow taller than the visible grid area
  FMaxRowHeight := Screen.Height div 3;
  if FMaxRowHeight < Grid.DefaultRowHeight then
    FMaxRowHeight := Grid.DefaultRowHeight;

  MemoSource.UpdateState(5);
  MemoTranslation.UpdateState(5);
  MemoPlural.UpdateState(5);

  FRichEditor := TRichMemoCellEditor.Create(Grid);
  FRichEditor.ScrollBars := ssAutoVertical;

  // Headers pick list
  HeaderList := TPOFile.GetHeaderNames;
  try
    GridHeaders.Columns[COLUMN_HEADERS_NAME].PickList.Assign(HeaderList);
  finally
    HeaderList.Free;
  end;

  // LoadSettings
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

    // Paint Form
    if not Application.Terminated then
    begin
      OnShow := nil;
      Visible := True;
      OnShow := @FormShow;
      Application.ProcessMessages;
    end
    else
      Exit;

    // Load Path
    Application.QueueAsyncCall(@LoadPath, 0);

    // Open file from command line if specified, otherwise start with a new document
    if FCommandLineFile <> string.Empty then
    begin
      if not OpenFile(FCommandLineFile) then
        NewFile;
    end
    else
      NewFile;
  end;

  PanelTranslation.Height := Round((PanelSource.Height + PanelTranslation.Height) * FSplitRatio);

  if AutoCheckUpdates then
  begin
    Th := TCheckUpdateThread.Create(REPO, APP_NAME, False);
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

{%EndRegion}

{%Region -fold Application Events}

procedure TformPoBatch.ApplicationPropActivate(Sender: TObject);
begin
  Invalidate;
end;

procedure TformPoBatch.ApplicationPropDeactivate(Sender: TObject);
begin
  Invalidate;
end;

procedure TformPoBatch.ApplicationPropException(Sender: TObject; E: Exception);
begin
  {$IFDEF DEBUG}
  TOS.Log(APP_NAME,
    'Unhandled exception (' + E.ClassName + '): ' + E.Message + LineEnding + TOS.GetExceptionStackTrace(E));
  {$ENDIF}
  MessageDlg(APP_NAME, E.Message, mtWarning, [mbOK], 0);
end;

procedure TformPoBatch.GridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  // Cancel a stuck selection drag in the grid
  Grid.FixStuckSelection(Shift);
end;

{%EndRegion}

{%Region -fold Menu Events}

procedure TformPoBatch.MenuHeadersClick(Sender: TObject);
begin
  GridHeaders.Visible := MenuHeaders.Checked;
  SplitterHeaders.Visible := MenuHeaders.Checked;
  Application.QueueAsyncCall(@FixSplitters, 0);
end;

procedure TformPoBatch.MenuTranslatePanelClick(Sender: TObject);
begin
  Grid.EditorMode := False;
  Pages.Visible := MenuTranslatePanel.Checked;
  SplitterPages.Visible := MenuTranslatePanel.Checked;
  if MenuTranslatePanel.Checked then
  begin
    UpdateTranslatePanel;
    SpellSource.CheckNow;
    SpellTranslation.CheckNow;
  end;
  Application.QueueAsyncCall(@FixSplitters, 0);
end;

procedure TformPoBatch.MenuColumnContextClick(Sender: TObject);
begin
  Grid.Columns[COLUMN_CONTEXT].Visible := MenuColumnContext.Checked;
  if Grid.Columns[COLUMN_CONTEXT].Visible and (Grid.Columns[COLUMN_CONTEXT].Width = 0) then
    Grid.Columns[COLUMN_CONTEXT].Width := 240;
end;

procedure TformPoBatch.MenuColumnReferenceClick(Sender: TObject);
begin
  Grid.Columns[COLUMN_REFERENCE].Visible := MenuColumnReference.Checked;
  if Grid.Columns[COLUMN_REFERENCE].Visible and (Grid.Columns[COLUMN_REFERENCE].Width = 0) then
    Grid.Columns[COLUMN_REFERENCE].Width := 240;
end;

procedure TformPoBatch.MenuColumnPluralClick(Sender: TObject);
begin
  Grid.Columns[COLUMN_PLURAL].Visible := MenuColumnPlural.Checked;
  if Grid.Columns[COLUMN_PLURAL].Visible and (Grid.Columns[COLUMN_PLURAL].Width = 0) then
    Grid.Columns[COLUMN_PLURAL].Width := 240;
end;

procedure TformPoBatch.MenuBuyMeACoffeeClick(Sender: TObject);
begin
  formDonatePoBatch.ShowModal;
end;

procedure TformPoBatch.MenuCheckForUpdatesClick(Sender: TObject);
var
  LatestVersion: string;
begin
  CheckGithubLatestVersion(LatestVersion, REPO, APP_NAME);
end;

procedure TformPoBatch.MenuAutoCheckUpdatesClick(Sender: TObject);
begin
  FAutoCheckUpdates := MenuAutoCheckUpdates.Checked;
end;

procedure TformPoBatch.MenuHelpGNUgettextClick(Sender: TObject);
begin
  OpenUrl((Sender as TMenuItem).Hint);
end;

procedure TformPoBatch.MenuAboutClick(Sender: TObject);
begin
  formAboutPoBatch.ShowModal;
end;

{%EndRegion}

{%Region -fold Action Events}

procedure TformPoBatch.ANewExecute(Sender: TObject);
begin
  if not IsCanClose then Exit;

  NewFile;
end;

procedure TformPoBatch.ANewWindowExecute(Sender: TObject);
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

procedure TformPoBatch.ANewFromPotExecute(Sender: TObject);
var
  PotFileName: string;
  Code: string = string.Empty;
begin
  // Ask to save current changes if modified - abort if user cancels
  if not IsCanClose(True) then
    Exit;

  // Let the user choose a POT file
  dialogOpen.FilterIndex := 2;
  if not dialogOpen.Execute then
    Exit;

  PotFileName := dialogOpen.FileName;
  if not FileExists(PotFileName) then
  begin
    ShowMessageFmt('POT file not found: %s', [PotFileName]);
    Exit;
  end;

  // Ask the user to choose the target language for the new PO file
  if not SelectLanguage(Code, [cqoEditable]) then
    Exit;

  // Load the POT content into the model, this also refreshes the current state
  if not LoadFile(PotFileName) then
    Exit;

  // Fill in the standard headers in the canonical order and set the chosen language
  FPoFile.ApplyDefaultHeaders(Code, 'PoBatch ' + GetAppVersion);

  FLanguage := Code;
  SpellTranslation.Language := FLanguage;

  // The result is a new unsaved document, so clear the file name
  FFileName := string.Empty;

  // Take a snapshot of the initial state for the undo action
  FPoFileBackup.Assign(FPoFile);
  Changed := True;

  // Refresh grids and UI to reflect the loaded POT
  FillGrid;
  FillGridHeaders;
  UpdateTranslatePanel;
  SyncPath;
  UpdateInterface;
end;

procedure TformPoBatch.AOpenExecute(Sender: TObject);
begin
  if not IsCanClose then Exit;

  dialogOpen.FilterIndex := 1;
  if dialogOpen.Execute then
    OpenFile(dialogOpen.FileName, False);
end;

procedure TformPoBatch.ASaveExecute(Sender: TObject);
begin
  if FFileName = string.Empty then
  begin
    // No filename yet, use Save As dialog
    ASaveAs.Execute;
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

procedure TformPoBatch.ASaveAsExecute(Sender: TObject);
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
      begin
        if OpenPath(FPath, True) then
        begin
          UpdatePath;
          AnalizePath(-1, True);
        end;
      end;
    end;
  end;
end;

procedure TformPoBatch.AOpenPathExecute(Sender: TObject);
begin
  if dialogPath.Execute then
  begin
    if not OpenPath(dialogPath.FileName, True) then
    begin
      ShowMessage('No .po files found in the selected directory!');
      Exit;
    end;
    FPath := dialogPath.FileName;
    SetLength(FFileStatuses, 0);
    UpdatePath;
    AnalizePath(-1, True);
  end;
end;

procedure TformPoBatch.AClosePathExecute(Sender: TObject);
begin
  ClosePath;
end;

procedure TformPoBatch.AExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TformPoBatch.AUndoChangesExecute(Sender: TObject);
begin
  if not Changed then
    Exit;

  if MessageDlg('Do you want to discard all unsaved changes?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  FPoFile.Assign(FPoFileBackup);
  FillGrid;
  FillGridHeaders;
  UpdateTranslatePanel;
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

procedure TformPoBatch.ASelectAllExecute(Sender: TObject);
begin
  SelectGridsAll;
end;

procedure TformPoBatch.ACutUpdate(Sender: TObject);
begin
  ACut.Enabled := CanActionEnable;
end;

procedure TformPoBatch.ACopyUpdate(Sender: TObject);
begin
  ACopy.Enabled := CanActionEnable;
end;

procedure TformPoBatch.APasteUpdate(Sender: TObject);
begin
  APaste.Enabled := CanActionEnable;
end;

procedure TformPoBatch.ADeleteUpdate(Sender: TObject);
begin
  ADelete.Enabled := CanActionEnable;
end;

procedure TformPoBatch.ASelectAllUpdate(Sender: TObject);
begin
  ASelectAll.Enabled := CanActionEnable;
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
  Grid.EditorMode := False;

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
    UpdateValid(Row);
    Inc(CopiedCount);
  end;

  if CopiedCount > 0 then
  begin
    Changed := True;

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

  Grid.Invalidate;
end;

procedure TformPoBatch.AClearIdenticalExecute(Sender: TObject);
var
  Row: integer;
  ReplacedCount: integer;
  StartRow, EndRow: integer;
begin
  if MessageDlg('Clear translations that are identical to the source text in the selected row(s)?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  ReplacedCount := 0;
  Grid.EditorMode := False;

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

  Grid.Invalidate;
end;

procedure TformPoBatch.AEditPluralFormExecute(Sender: TObject);
var
  OldValue, Value: string;
begin
  Value := Grid.Cells[CELL_PLURAL, Grid.Row];
  OldValue := Value;
  Grid.EditorMode := False;

  InputQueryLite('Plural form', 'Enter plural form', Value);
  if (Value = string.empty) and ((OldValue = string.Empty) or (MessageDlg('Delete plural form?',
    'Are you sure you want to delete this plural form?', mtConfirmation, mbYesNo, 0) <> mrYes)) then
    Exit;

  if (OldValue <> Value) then
  begin
    Grid.Cells[CELL_PLURAL, Grid.Row] := Value;
    UpdateTranslatePanel;
    Changed := True;
  end;
end;

procedure TformPoBatch.AEditTranslationOnlyExecute(Sender: TObject);
begin
  GridHeaders.EditorMode := False;
  GridHeaders.Columns[COLUMN_HEADERS_NAME].ReadOnly := AEditTranslationOnly.Checked;

  Grid.EditorMode := False;
  Grid.Columns[COLUMN_VALID].ReadOnly := True;
  Grid.Columns[COLUMN_TEXT].ReadOnly := AEditTranslationOnly.Checked;
  Grid.Columns[COLUMN_REFERENCE].ReadOnly := AEditTranslationOnly.Checked;
  Grid.Columns[COLUMN_CONTEXT].ReadOnly := AEditTranslationOnly.Checked;
  Grid.Columns[COLUMN_PLURAL].ReadOnly := AEditTranslationOnly.Checked;
  Grid.Columns[COLUMN_FUZZY].ReadOnly := AEditTranslationOnly.Checked;

  MemoSource.ReadOnly := AEditTranslationOnly.Checked;
  MemoPlural.ReadOnly := AEditTranslationOnly.Checked;

  AEditPluralForm.Enabled := not AEditTranslationOnly.Checked;

  GridPlural.EditorMode := False;
  GridComments.EditorMode := False;

  if AEditTranslationOnly.Checked then
  begin
    GridHeaders.Options := GridHeaders.Options - [goAutoAddRows];
    Grid.Options := Grid.Options - [goAutoAddRows];
    GridPlural.Options := GridPlural.Options - [goAutoAddRows];
    GridComments.Options := GridComments.Options - [goAutoAddRows];
    GridComments.Options := GridComments.Options - [goEditing];
  end
  else
  begin
    GridHeaders.Options := GridHeaders.Options + [goAutoAddRows];
    Grid.Options := Grid.Options + [goAutoAddRows];
    GridPlural.Options := GridPlural.Options + [goAutoAddRows];
    GridComments.Options := GridComments.Options + [goAutoAddRows];
    GridComments.Options := GridComments.Options + [goEditing];
  end;
end;

procedure TformPoBatch.APathNewFilesFromPotExecute(Sender: TObject);
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
begin
  // Use the known reference POT, otherwise ask the user to pick one
  PotFileName := FPotFile;
  if PotFileName = '' then
  begin
    dialogOpen.FilterIndex := 2;
    if not dialogOpen.Execute then
      Exit;
    PotFileName := dialogOpen.FileName;
  end;

  if not FileExists(PotFileName) then
  begin
    ShowMessageFmt('POT file not found: %s', [PotFileName]);
    Exit;
  end;

  // Ask to save the current file if modified - abort if user cancels
  if not IsCanClose(True) then
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

  // Create a PO file for every selected language
  CreatedCount := 0;
  LastCreatedFile := string.Empty;
  for i := 0 to High(Codes) do
  begin
    if CreatePoFileFromPot(PotFileName, Codes[i], NewFileName) then
    begin
      FPoFiles.Add(NewFileName);
      LastCreatedFile := NewFileName;
      Inc(CreatedCount);
    end;
  end;

  if CreatedCount = 0 then
    Exit;

  // The last created file is already loaded and saved, so drop the modified flag
  Changed := False;
  UpdateTranslatePanel;

  // Re-sort the file list keeping statuses aligned; new files get their status computed
  SortList := TStringList.Create;
  try
    for i := 0 to FPoFiles.Count - 1 do
      if i < Length(FFileStatuses) then
        SortList.AddObject(FPoFiles[i], TObject(PtrInt(Ord(FFileStatuses[i]))))
      else
        SortList.AddObject(FPoFiles[i], TObject(PtrInt(Ord(TPOFile.GetFileStatus(FPoFiles[i])))));

    SortList.Sort;

    FPoFiles.Assign(SortList);
    SetLength(FFileStatuses, SortList.Count);
    for i := 0 to SortList.Count - 1 do
      FFileStatuses[i] := TPoFileStatus(PtrInt(SortList.Objects[i]));
  finally
    SortList.Free;
  end;

  // Rebuild the visible list and select the last created file
  ListPath.Items.BeginUpdate;
  try
    ListPath.Items.Clear;
    for i := 0 to FPoFiles.Count - 1 do
      ListPath.Items.Add(ExtractFileName(FPoFiles[i]));

    NewIdx := FPoFiles.IndexOf(LastCreatedFile);
    if NewIdx >= 0 then
    begin
      ListPath.Selected[NewIdx] := True;
      ListPath.ItemIndex := NewIdx;
      FPathIndex := NewIdx;
      FLastPathIndex := NewIdx;
    end;
  finally
    ListPath.Items.EndUpdate;
  end;

  ListPath.Invalidate;
  UpdateCaption;
end;

procedure TformPoBatch.APathSyncFilesWithPotExecute(Sender: TObject);
var
  i, selCount: integer;
  PoFile: TPOFile;
  FileName: string;
  fileList, msg: string;
  SelectedIndices: array of integer = nil; // saved selected indices to survive UI changes
begin
  // Check if the reference POT file is specified
  if FPotFile = '' then
  begin
    ShowMessage('No reference POT file exists in opened path.');
    Exit;
  end;

  // Ask to save current file if modified – if user cancels, abort sync
  if not IsCanClose(True) then
    Exit;

  // Collect selected indices before processing
  SetLength(SelectedIndices, ListPath.Items.Count);
  selCount := 0;
  for i := 0 to ListPath.Items.Count - 1 do
    if ListPath.Selected[i] then
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
      fileList := fileList + FPoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + '... and ' + IntToStr(selCount - 10) + ' more file(s)' + sLineBreak;
  end;

  msg := 'Synchronize the following ' + IntToStr(selCount) + ' file(s) with' + sLineBreak + 'reference POT: ' +
    FPotFile + sLineBreak + 'This action cannot be undone within the application.' + sLineBreak + sLineBreak + fileList;
  if MessageDlg('Confirm synchronization', msg, mtConfirmation, mbYesNo, 0) <> mrYes then
    Exit;

  // Process each selected file using the saved indices
  for i := 0 to selCount - 1 do
  begin
    FileName := FPoFiles[SelectedIndices[i]];
    if not FileExists(FileName) then
    begin
      ShowMessageFmt('File not found: %s', [FileName]);
      Continue;
    end;

    // Skip the reference POT file itself to avoid self-synchronization
    if SameFileName(FileName, FPotFile) then
      Continue;

    PoFile := TPOFile.Create;
    try
      PoFile.LoadFromFile(FileName);
      PoFile.SynchronizeToFile(FPotFile, True);
      PoFile.SaveToFile(FileName);
    except
      on E: Exception do
      begin
        ShowMessageFmt('Error synchronizing file "%s": %s', [FileName, E.Message]);
        PoFile.Free;
        Continue;    // skip reloading this file
      end;
    end;
    PoFile.Free;

    // Refresh list item status
    AnalizePath(SelectedIndices[i]);

    // If this was the currently opened file, reload it in the editor
    if FileName = FFileName then
    begin
      if LoadFile(FFileName) then
      begin
        Changed := False;
        FillGrid;
        FillGridHeaders;
        UpdateTranslatePanel;
      end;
    end;
  end;

  ShowMessage('Synchronization complete.');
end;

procedure TformPoBatch.APathValidFilesExecute(Sender: TObject);
var
  i, j, selCount: integer;
  PoFile: TPOFile;
  FileName: string;
  fileList, msg: string;
  SelectedIndices: array of integer = nil; // saved selected indices to survive UI changes
begin
  // Collect selected indices before showing the dialog
  SetLength(SelectedIndices, ListPath.Items.Count);
  selCount := 0;
  for i := 0 to ListPath.Items.Count - 1 do
    if ListPath.Selected[i] then
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
      fileList := fileList + FPoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + '... and ' + IntToStr(selCount - 10) + ' more file(s)' + sLineBreak;
  end;

  msg := 'Mark the following ' + IntToStr(selCount) + ' file(s) as valid?' + sLineBreak +
    'This will remove the "fuzzy" flag from all entries.' + sLineBreak + 'This action cannot be undone within the application.' +
    sLineBreak + sLineBreak + fileList;
  if MessageDlg('Remove fuzzy flag', msg, mtConfirmation, mbYesNo, 0) <> mrYes then
    Exit;

  // Save current file if modified – abort if user cancels
  if not IsCanClose(True) then
    Exit;

  // Process each selected file using the saved indices
  for i := 0 to selCount - 1 do
  begin
    FileName := FPoFiles[SelectedIndices[i]];
    if not FileExists(FileName) then
    begin
      ShowMessageFmt('File not found: %s', [FileName]);
      Continue;
    end;

    // Skip the reference POT file – it contains no translations
    if SameFileName(FileName, FPotFile) then
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
          ShowMessageFmt('Error processing file "%s": %s', [FileName, E.Message]);
          PoFile.Free;
          Continue;    // skip status update for this file
        end;
      end;
    finally
      PoFile.Free;
    end;

    // Update the status of this file in the path list
    AnalizePath(SelectedIndices[i]);

    // If this was the currently opened file, reload it in the editor
    if FileName = FFileName then
    begin
      if LoadFile(FFileName) then
      begin
        Changed := False;
        FillGrid;
        FillGridHeaders;
        UpdateTranslatePanel;
      end;
    end;
  end;

  ShowMessage('Selected files have been marked as valid. All "fuzzy" flags were removed.');
end;

procedure TformPoBatch.APathRenameFilesExecute(Sender: TObject);
var
  i, selCount, p, NewIdx: integer;
  FileName, Dir, BaseName, LangPart, NewName: string;
  DefaultName, OriginalName: string;
  SelectedIndices: array of integer = nil;
  fileList, msg: string;
  RenamedCount: integer;
  SortList: TStringList;
begin
  // Collect indices of selected items
  SetLength(SelectedIndices, ListPath.Items.Count);
  selCount := 0;
  for i := 0 to ListPath.Items.Count - 1 do
    if ListPath.Selected[i] then
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
  if (FFileName <> string.Empty) and (FPoFiles.IndexOf(FFileName) >= 0) then
    BaseName := ChangeFileExt(ExtractFileName(FFileName), '')
  else
    BaseName := ChangeFileExt(ExtractFileName(FPoFiles[SelectedIndices[0]]), '');

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
      fileList := fileList + FPoFiles[SelectedIndices[i]] + sLineBreak
    else if i = 10 then
      fileList := fileList + '... and ' + IntToStr(selCount - 10) + ' more file(s)' + sLineBreak;
  end;

  msg := 'Rename the following ' + IntToStr(selCount) + ' file(s) using base name "' + DefaultName + '"?' +
    sLineBreak + sLineBreak + fileList;
  if MessageDlg('Confirm rename', msg, mtConfirmation, mbYesNo, 0) <> mrYes then
    Exit;

  // Rename each selected file on disk keeping its language code and extension
  RenamedCount := 0;
  for i := 0 to selCount - 1 do
  begin
    FileName := FPoFiles[SelectedIndices[i]];
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
      ShowMessageFmt('Failed to rename: %s', [FileName]);
      Continue;
    end;

    // Update the in-memory path; the file content is unchanged,
    // so the status entry stays the same
    FPoFiles[SelectedIndices[i]] := NewName;

    // Keep the currently opened file and the reference POT file in sync
    if SameFileName(FileName, FFileName) then
      FFileName := NewName;

    if SameFileName(FileName, FPotFile) then
      FPotFile := NewName;

    Inc(RenamedCount);
  end;

  if RenamedCount = 0 then
    Exit;

  // Re-sort the file list; a renamed file can move to a new position
  SortList := TStringList.Create;
  try
    SortList.Sorted := False;
    for i := 0 to FPoFiles.Count - 1 do
      if i < Length(FFileStatuses) then
        SortList.AddObject(FPoFiles[i], TObject(PtrInt(Ord(FFileStatuses[i]))))
      else
        SortList.AddObject(FPoFiles[i], TObject(PtrInt(Ord(psEmptyTranslation))));

    SortList.Sort;

    for i := 0 to SortList.Count - 1 do
      FPoFiles[i] := SortList[i];

    SetLength(FFileStatuses, SortList.Count);
    for i := 0 to SortList.Count - 1 do
      FFileStatuses[i] := TPoFileStatus(PtrInt(SortList.Objects[i]));
  finally
    SortList.Free;
  end;

  // Rebuild the visible list and keep the same file selected after reordering
  ListPath.Items.BeginUpdate;
  try
    ListPath.Items.Clear;
    for i := 0 to FPoFiles.Count - 1 do
      ListPath.Items.Add(ExtractFileName(FPoFiles[i]));

    NewIdx := FPoFiles.IndexOf(FFileName);
    if NewIdx >= 0 then
    begin
      ListPath.Selected[NewIdx] := True;
      ListPath.ItemIndex := NewIdx;
      FPathIndex := NewIdx;
      FLastPathIndex := NewIdx;
    end
    else
    begin
      FPathIndex := -1;
      FLastPathIndex := -1;
    end;
  finally
    ListPath.Items.EndUpdate;
  end;

  ListPath.Invalidate;
  UpdateCaption;
end;

procedure TformPoBatch.APathDeleteFilesExecute(Sender: TObject);
var
  i, Count, idx: integer;
  selectedIndices: array of integer = ();
  msg, fileList: string;
  FileToDelete: string;
  CurrentFileDeleted: boolean;
  PotDeleted: boolean;
  NewIdx: integer;
begin
  // Collect indices of selected items
  SetLength(selectedIndices, ListPath.Items.Count);
  Count := 0;
  for i := 0 to ListPath.Items.Count - 1 do
    if ListPath.Selected[i] then
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
        fileList := fileList + PoFiles[selectedIndices[i]] + sLineBreak
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
  // Walk the saved indices from the end so earlier ones stay valid while removing
  for i := Count - 1 downto 0 do
  begin
    idx := selectedIndices[i];
    if (idx < 0) or (idx >= FPoFiles.Count) then
      Continue;

    FileToDelete := FPoFiles[idx];

    // Remember whether the currently opened file or the reference POT is going away
    if SameFileName(FileToDelete, FFileName) then
      CurrentFileDeleted := True;
    if (FPotFile <> string.Empty) and SameFileName(FileToDelete, FPotFile) then
      PotDeleted := True;

    DeleteFile(FileToDelete);

    // Remove the entry from the path list and keep statuses aligned
    FPoFiles.Delete(idx);
    if idx < Length(FFileStatuses) then
      Delete(FFileStatuses, idx, 1);
  end;

  if PotDeleted then
    FPotFile := string.Empty;

  // If the currently opened file was removed, reset to an empty document
  if CurrentFileDeleted then
    NewFile;

  // Rebuild the visible list and restore the selection when possible
  ListPath.Items.BeginUpdate;
  try
    ListPath.Items.Clear;
    for i := 0 to FPoFiles.Count - 1 do
      ListPath.Items.Add(ExtractFileName(FPoFiles[i]));

    NewIdx := FPoFiles.IndexOf(FFileName);
    if NewIdx >= 0 then
    begin
      ListPath.Selected[NewIdx] := True;
      ListPath.ItemIndex := NewIdx;
      FPathIndex := NewIdx;
      FLastPathIndex := NewIdx;
    end
    else
    begin
      FPathIndex := -1;
      FLastPathIndex := -1;
    end;
  finally
    ListPath.Items.EndUpdate;
  end;

  ListPath.Invalidate;
  UpdateCaption;
end;

procedure TformPoBatch.APathSelectAllExecute(Sender: TObject);
begin
  ListPath.SelectAll;
end;

procedure TformPoBatch.ASyncWithPotExecute(Sender: TObject);
var
  PotFileName: string;
  Msg: string;
begin
  // Ask to save current changes if modified – abort if user cancels
  if not IsCanClose(True) then
    Exit;

  // Let the user choose a POT file
  dialogOpen.FilterIndex := 2;
  if not dialogOpen.Execute then
    Exit;

  PotFileName := dialogOpen.FileName;
  if not FileExists(PotFileName) then
  begin
    ShowMessageFmt('POT file not found: %s', [PotFileName]);
    Exit;
  end;

  // Confirm synchronization
  Msg := 'Synchronize current file' + sLineBreak + '  ' + FFileName + sLineBreak + 'with reference POT' +
    sLineBreak + '  ' + PotFileName + ' ?';
  if MessageDlg('Confirm synchronization', Msg, mtConfirmation, mbYesNo, 0) <> mrYes then
    Exit;

  // Perform synchronization directly on the already loaded FPoFile object
  try
    FPoFile.SynchronizeToFile(PotFileName, True);   // keep existing header
  except
    on E: Exception do
    begin
      ShowMessageFmt('Error synchronizing file: %s', [E.Message]);
      Exit;
    end;
  end;

  Changed := True;
  FillGrid;
  FillGridHeaders;
  UpdateTranslatePanel;
  if FPathIndex >= 0 then
    AnalizePath(FPathIndex);
end;

procedure TformPoBatch.AValidFileExecute(Sender: TObject);
var
  i: integer;
begin
  // Check if there is anything to process
  if FPoFile.Entries.Count = 0 then Exit;

  // Ask for confirmation
  if MessageDlg('Mark as Valid', 'Mark the current file as valid?' + sLineBreak + 'This will remove the "fuzzy" flag from all entries.',
    mtConfirmation, mbYesNo, 0) <> mrYes then Exit;

  // Save any pending grid changes back to the model
  SaveGrid;

  // Remove the fuzzy flag from every translatable entry
  for i := 0 to FPoFile.Entries.Count - 1 do
  begin
    // Keep the header entry (empty msgid) untouched
    if FPoFile.Entries[i].MsgId <> '' then
      FPoFile.Entries[i].IsFuzzy := False;
  end;

  Changed := True;

  // Rebuild the grid and update the UI
  FillGrid;
  FillGridHeaders;
  UpdateTranslatePanel;

  // Update the file status in the path list if applicable
  if FPathIndex >= 0 then
    AnalizePath(FPathIndex);
end;

procedure TformPoBatch.AMemoUndoExecute(Sender: TObject);
var
  AMemo: TRichMemo;
begin
  if Self.ActiveControl is TRichMemo then
  begin
    AMemo := Self.ActiveControl as TRichMemo;
    AMemo.Undo;
  end;
end;

procedure TformPoBatch.AMemoCutExecute(Sender: TObject);
var
  AMemo: TRichMemo;
begin
  if Self.ActiveControl is TRichMemo then
  begin
    AMemo := Self.ActiveControl as TRichMemo;
    if not AMemo.ReadOnly then
    begin
      AMemo.CutToClipboard;
      AMemo.UpdateState;
    end;
  end;
end;

procedure TformPoBatch.AMemoCopyExecute(Sender: TObject);
var
  AMemo: TRichMemo;
begin
  if Self.ActiveControl is TRichMemo then
  begin
    AMemo := Self.ActiveControl as TRichMemo;
    AMemo.CopyToClipboard;
  end;
end;

procedure TformPoBatch.AMemoPasteExecute(Sender: TObject);
var
  AMemo: TRichMemo;
begin
  if Self.ActiveControl is TRichMemo then
  begin
    AMemo := Self.ActiveControl as TRichMemo;
    if not AMemo.ReadOnly then
    begin
      AMemo.PasteFromClipboard;
      AMemo.UpdateState;
    end;
  end;
end;

procedure TformPoBatch.AMemoClearExecute(Sender: TObject);
var
  AMemo: TRichMemo;
begin
  if Self.ActiveControl is TRichMemo then
  begin
    AMemo := Self.ActiveControl as TRichMemo;
    if not AMemo.ReadOnly then
      AMemo.ClearSelection;
  end;
end;

procedure TformPoBatch.AMemoSelectAllExecute(Sender: TObject);
var
  AMemo: TRichMemo;
begin
  if Self.ActiveControl is TRichMemo then
  begin
    AMemo := Self.ActiveControl as TRichMemo;
    AMemo.SelectAll;
  end;
end;

procedure TformPoBatch.AMemoBidiRightToLeftExecute(Sender: TObject);
var
  AMemo: TRichMemo;
begin
  if Self.ActiveControl is TRichMemo then
  begin
    AMemo := Self.ActiveControl as TRichMemo;

    if AMemoBidiRightToLeft.Checked then
      AMemo.BiDiMode := bdRightToLeft
    else
      AMemo.BiDiMode := bdLeftToRight;

    AMemo.ApplyBidiMode;
  end;
end;

procedure TformPoBatch.AMemoDefaultZoomExecute(Sender: TObject);
var
  AMemo: TRichMemo;
begin
  if Self.ActiveControl is TRichMemo then
  begin
    AMemo := Self.ActiveControl as TRichMemo;
    AMemo.ZoomFactor := 1;
  end;
end;

procedure TformPoBatch.AWordWrapGridExecute(Sender: TObject);
begin
  WordWrap := MenuWordWrapGrid.Checked;
end;

procedure TformPoBatch.AWordWrapTranslatePanelExecute(Sender: TObject);
begin
  MemoSource.WordWrap := MenuWordWrapTranslatePanel.Checked;
  MemoPlural.WordWrap := MenuWordWrapTranslatePanel.Checked;
  MemoTranslation.WordWrap := MenuWordWrapTranslatePanel.Checked;
end;

procedure TformPoBatch.ASpellCheckSourceExecute(Sender: TObject);
begin
  SpellSource.Enabled := ASpellCheckSource.Checked;
  if not SpellSource.Enabled then
    SpellSource.ClearErrors;
end;

procedure TformPoBatch.ASpellCheckTranslationExecute(Sender: TObject);
begin
  SpellTranslation.Enabled := ASpellCheckTranslation.Checked;
  if not SpellTranslation.Enabled then
    SpellTranslation.ClearErrors;
end;

{%EndRegion}

{%Region -fold Grids Universal Events}

procedure TformPoBatch.GridsUniversalKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  SelRow: integer;
  GridAny: TStringGrid;
begin
  GridAny := (Sender as TStringGrid);
  if not Assigned(GridAny) then exit;

  if not AEditTranslationOnly.Checked and (ssCtrl in Shift) and (Key = VK_DELETE) then
  begin
    Key := 0; // swallow the key to prevent default handling

    SelRow := GridAny.Row;
    // Do not delete fixed rows
    if SelRow < GridAny.FixedRows then Exit;

    // Ask for confirmation before deleting
    if MessageDlg('Delete row', 'Are you sure you want to delete the selected row?', mtConfirmation, mbYesNo, 0) <> mrYes then
      Exit;

    // Remove the selected row from the GridAny
    GridAny.DeleteRow(SelRow);

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
    GridAny.InsertColRow(False, GridAny.Row + 1);
    GridAny.Row := GridAny.ROw + 1;
    Changed := True;
  end
  else
  if (Assigned(GridAny.InplaceEditor)) and not GridAny.InplaceEditor.Focused then
  begin
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
end;

procedure TformPoBatch.GridUniversalColRowInserted(Sender: TObject; IsColumn: boolean; sIndex, tIndex: integer);
begin
  if not IsColumn then
    Changed := True;
end;

procedure TformPoBatch.GridUniversalExit(Sender: TObject);
begin
  (Sender as TStringGrid).Invalidate;
end;

procedure TformPoBatch.GridUniversalPrepareCanvas(Sender: TObject; aCol, aRow: integer; aState: TGridDrawState);
var
  GridAny: TStringGrid;
begin
  GridAny := (Sender as TStringGrid);
  if not Assigned(GridAny) then exit;

  if (not (gdSelected in aState) and (gdRowHighlight in aState)) or ((gdSelected in aState) and (not GridAny.Focused)) then
  begin
    GridAny.Canvas.Brush.Color := TDarkUtils.ThemeColor(clRowHighlight, clRowHighlightDark);
    GridAny.Canvas.Font.Color := clWindowText;
  end;
end;

{%EndRegion}

{%Region -fold Grid Headers Events}

procedure TformPoBatch.GridHeadersValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
begin
  if OldValue <> NewValue then
    Changed := True;
end;

procedure TformPoBatch.GridHeadersGetCellHint(Sender: TObject; ACol, ARow: integer; var HintText: string);
begin
  HintText := GridHeaders.Cells[ACol, ARow];
end;

{%EndRegion}

{%Region -fold Grid Plural Events}

procedure TformPoBatch.GridPluralValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
begin
  if OldValue <> NewValue then
  begin
    Changed := True;
    GridPlural.Cells[aCol, aRow] := NewValue;
    SaveGridPlural;
    UpdateValid;

    Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0), Grid.Row);
  end;
end;

{%EndRegion}

{%Region -fold Grid Comments Events}

procedure TformPoBatch.GridCommentsValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
begin
  if OldValue <> NewValue then
  begin
    Changed := True;
    GridComments.Cells[aCol, aRow] := NewValue;
    SaveGridComments;
    UpdateValid;
    Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0), Grid.Row);
  end;
end;

procedure TformPoBatch.GridCommentsGetCellHint(Sender: TObject; ACol, ARow: integer; var HintText: string);
begin
  if ACol = 1 then
    HintText := TPoFile.GetCommentTypeName(GridComments.Cells[ACol, ARow])
  else
    HintText := GridComments.Cells[ACol, ARow];
end;

{%EndRegion}

{%Region -fold Grid Events}

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
    SaveGrid;

    // Delete the entries from FPoFile (handles index ordering internally)
    FPoFile.DeleteEntriesByIndexes(SelIndexes);

    Changed := True;
    FillGrid;   // rebuild the grid from updated FPoFile (preserves filter & sort)
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
    FillGrid;
    Exit;
  end;

  // Ctrl + Click on any column resets sorting to original order
  if GetKeyState(VK_CONTROL) and $8000 <> 0 then
  begin
    FSortColumn := -1;
    FillGrid;
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

  FLastRow := -1;

  if (Grid.RowCount > Grid.FixedRows) and (FSortColumn >= 0) then
    Grid.SortColRow(True, FSortColumn, Grid.FixedRows, Grid.RowCount - 1);
end;

procedure TformPoBatch.GridHeaderSized(Sender: TObject; IsColumn: boolean; Index: integer);
begin
  Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0));
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
  NewEntry.MsgId := string.Empty;
  NewEntry.MsgStrSimple := string.Empty;
  NewEntry.IsFuzzy := False;
  NewIndex := FPoFile.Entries.Add(NewEntry);   // returns the new index

  // Put the permanent index into column 0 of the newly inserted row
  Grid.Cells[0, tIndex] := IntToStr(NewIndex);

  Changed := True;
end;

procedure TformPoBatch.GridMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
var
  ScrollBar: TControlScrollBar = nil;
  LinesToScroll: integer = 0;
  NewPos: integer = 0;
  MaxPos: integer = 0;
begin
  // Scroll the editor only if it is visible, active, and the cursor is above it.
  if (Assigned(FRichEditor)) and FRichEditor.Visible and FRichEditor.Focused and
    FRichEditor.ClientRect.Contains(FRichEditor.ScreenToClient(Mouse.CursorPos)) then
  begin
    ScrollBar := FRichEditor.VertScrollBar;

    // And only if the scrollbar is really shown on screen
    if ScrollBar.IsScrollBarVisible then
    begin
      // One notch scrolls several lines; tune the multiplier for comfortable speed
      LinesToScroll := (WheelDelta div 120) * ScrollBar.Increment * 3;

      MaxPos := ScrollBar.Range - ScrollBar.Page;
      if MaxPos < 0 then
        MaxPos := 0;

      NewPos := ScrollBar.Position - LinesToScroll;
      if NewPos < 0 then
        NewPos := 0;
      if NewPos > MaxPos then
        NewPos := MaxPos;

      ScrollBar.Position := NewPos;
      Handled := True;
      Exit;
    end;
  end;

  Handled := False;
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
  if ACol = CELL_TEXT then
    HintText := Grid.Cells[ACol, ARow] + ifthen(Grid.Cells[CELL_CONTEXT, ARow].IsEmpty, string.Empty, sLineBreak) +
      Grid.Cells[CELL_CONTEXT, ARow]
  else
    HintText := Grid.Cells[ACol, ARow];
end;

procedure TformPoBatch.GridSelectCell(Sender: TObject; aCol, aRow: integer; var CanSelect: boolean);
begin
  if aRow <> FLastRow then
    FLastRow := aRow;
end;

procedure TformPoBatch.GridSelection(Sender: TObject; aCol, aRow: integer);
begin
  UpdateTranslatePanel(aRow);
end;

procedure TformPoBatch.GridPrepareCanvas(Sender: TObject; aCol, aRow: integer; aState: TGridDrawState);
var
  TS: TTextStyle;
  CustomColor: TColor = clWindow;
begin
  TS := Grid.Canvas.TextStyle;
  TS.Wordbreak := FWordWrap;
  TS.SingleLine := False;
  Grid.Canvas.TextStyle := TS;

  // Color Cells
  if Grid.EditorMode and (aCol = Grid.Col) and (aRow = Grid.Row) then
  begin
    Grid.Canvas.Brush.Color := clWindow;
    Grid.Canvas.Font.Color := clWindowText;
    Exit;
  end;

  if (not (gdSelected in aState) and (gdRowHighlight in aState)) or ((gdSelected in aState) and (not Grid.Focused)) then
  begin
    Grid.Canvas.Brush.Color := TDarkUtils.ThemeColor(clRowHighlight, clRowHighlightDark);
    Grid.Canvas.Font.Color := clWindowText;
  end;

  if Grid.Cells[CELL_FUZZY, aRow] = '1' then
    CustomColor := TDarkUtils.ThemeColor(clSoftYellow, clSoftYellowDark);

  if (CustomColor <> clWindow) and (Grid.Canvas.Brush.Color <> clNone) then
  begin
    if (gdSelected in aState) then
      Grid.Canvas.Brush.Color := Grid.Canvas.Brush.Color.BlendColor(CustomColor, 40)
    else
      Grid.Canvas.Brush.Color := CustomColor;
  end;
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
  if not (aCol in [CELL_TEXT, CELL_TRANSLATION, CELL_CONTEXT, CELL_PLURAL, CELL_REFERENCE]) then
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
    GridDrawColors(TDarkUtils.ThemeColor(clInfo, clInfoDark), clMaroon, ifthen(gdSelected in AState,
    clWindowText, TDarkUtils.ThemeColor(clFontBlue, clFontBlueDark)), TDarkUtils.ThemeColor(clSoftBlue, clSoftBlueDark)),
    CellText,
    Filter.Text,
    MsgCtxt,
    FWordWrap,
    True,
    False
    );
end;

procedure TformPoBatch.GridSelectEditor(Sender: TObject; aCol, aRow: integer; var Editor: TWinControl);
begin
  if (aCol in [CELL_TEXT, CELL_TRANSLATION, CELL_CONTEXT, CELL_PLURAL, CELL_REFERENCE]) then
  begin
    Editor := FRichEditor;

    FRichEditor.OnEnter := @MemoEnter;
    FRichEditor.OnExit := @MemoExit;
    FRichEditor.OnChange := @MemoChange;
    FRichEditor.OnKeyDown := @MemoKeyDown;
  end;
end;

procedure TformPoBatch.GridValidateEntry(Sender: TObject; aCol, aRow: integer; const OldValue: string; var NewValue: string);
begin
  // Read the actual editor content directly
  if Assigned(FRichEditor) and FRichEditor.Visible then
    NewValue := FRichEditor.Lines.Text;

  if not OldValue.EqualNormalized(NewValue) then
    Changed := True;
end;

{%EndRegion}

{%Region -fold Inline Editor Events}

procedure TformPoBatch.MemoEnter(Sender: TObject);
begin
  if (Grid.IsCellSelected[Grid.Col, Grid.Row]) and ((Grid.Selection.Height > 0) or (Grid.Selection.Width > 0)) then
  begin
    FRichEditor.Color := clHighlight;
    FRichEditor.Font.Color := clWhite;
  end
  else
  begin
    FRichEditor.Color := clWindow;
    FRichEditor.Font.Color := clWindowText;
  end;

  Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0), Grid.Row);

  Application.QueueAsyncCall(@UpdateSpellCheckMemo, 1);

  FRichEditor.UpdateState(1, True);
  Grid.Invalidate;
end;

procedure TformPoBatch.MemoExit(Sender: TObject);
begin
  Application.QueueAsyncCall(@UpdateSpellCheckMemo, 0);

  Grid.EditorMode := False;

  if (Grid.Col = CELL_TRANSLATION) or ((not MenuEditTranslationOnly.Checked) and
    (Grid.Col in [CELL_TEXT, CELL_CONTEXT, CELL_PLURAL, CELL_REFERENCE])) then
  begin
    UpdateTranslatePanel;
    UpdateValid;
  end;

  Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0), Grid.Row);

  Grid.Invalidate;
end;

procedure TformPoBatch.MemoChange(Sender: TObject);
begin
  Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0), Grid.Row);
end;

procedure TformPoBatch.MemoKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Grid.EditorMode := False;
    Key := 0;
  end
  else
  if Key = VK_RETURN then
  begin
    if (ssCtrl in Shift) or (ssShift in Shift) then
    begin
      FRichEditor.SelText := sLineBreak;
      FRichEditor.SelStart := FRichEditor.SelStart + 1;
      FRichEditor.SelLength := 0;
      Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0),
        Grid.Row);
    end
    else
    begin
      Grid.Cells[Grid.Col, Grid.Row] := FRichEditor.Lines.Text;
      UpdateValid;
      Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0),
        Grid.Row);
      Changed := True;
      Grid.EditorMode := False;
    end;

    Key := 0;
  end
  else if ((Key = Ord('V')) and (ssCtrl in Shift)) or ((Key = VK_INSERT) and (ssShift in Shift)) then
  begin
    // Standard paste for now, will be replaced later
    if Sender is TRichMemo then
      TRichMemo(Sender).PasteWithLineEnding
    else
      TMemo(Sender).PasteWithLineEnding;
    Key := 0;
  end;
end;

{%EndRegion}

{%Region -fold Control Events}

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
begin
  if ListPath.ItemIndex = FLastPathIndex then Exit;

  ClearTimeout(FselectPathTimer);
  SetTimeout(FSelectPathTimer, 50, @SelectPath);
end;

procedure TformPoBatch.ListPathMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  idx: integer;
begin
  // Get item under mouse
  idx := ListPath.ItemAtPos(Point(X, Y), True);
  if idx <> -1 then
  begin
    if Button = mbRight then
    begin
      // Do nothing if right-clicked on already selected item with multi-selection
      if ListPath.Selected[idx] and (ListPath.SelCount > 1) then
        Exit;
      // MenuMemoClear and set selection to force visual update (fixes initial zero-state highlight)
      ListPath.ClearSelection;
      ListPath.Selected[idx] := True;
      ListPath.ItemIndex := idx; // also set focus rectangle
      SelectPath;
      if idx <> FLastPathIndex then
        FPathMouseSelecting := True;
    end
    else
    begin
      if idx <> FLastPathIndex then
        FPathMouseSelecting := True;
      // other mouse buttons (e.g., left) can be processed here
    end;
  end;
end;

procedure TformPoBatch.ListPathKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = Ord('A')) and (ssCtrl in Shift) then
  begin
    ListPath.SelectAll;
    Key := 0; // suppress default handling (e.g., beep)
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
      psCorrect: BgColor := TDarkUtils.ThemeColor(clSoftGreen, clSoftGreenDark);   // light green
      psFuzzy: BgColor := TDarkUtils.ThemeColor(clSoftYellow, clSoftYellowDark);   // light yellow
      psEmptyTranslation: BgColor := clWindow;  // default (white)
      else
        BgColor := clWindow;
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
  // Reentrancy guard: fast typing fires OnChange while a previous pass is
  // still running because UpdateTranslatePanel calls Application.ProcessMessages.
  // The nested call only marks that another pass is required; the outer loop
  // will rerun with the already-updated Filter.Text
  if FFilterUpdating then
  begin
    FFilterPending := True;
    Exit;
  end;

  FFilterUpdating := True;
  try
    repeat
      FFilterPending := False;
      SaveGrid;
      FillGrid;
    until not FFilterPending;
    UpdateTranslatePanel;
  finally
    FFilterUpdating := False;
  end;
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

procedure TformPoBatch.PanelPageTranslationResize(Sender: TObject);
begin
  PanelTranslation.Height := Round((PanelSource.Height + PanelTranslation.Height) * FSplitRatio);
  MemoPlural.Width := PanelSource.Width div 2;
  GridPlural.Width := PanelTranslation.Width div 2;
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

procedure TformPoBatch.SplitterTranslateMoved(Sender: TObject);
begin
  FSplitRatio := PanelTranslation.Height / (PanelSource.Height + PanelTranslation.Height);
end;

procedure TformPoBatch.SpellSourceSpellCheckComplete(Sender: TObject; ErrorCount: integer);
begin
  if (Grid.Col = CELL_TEXT) and (SpellSource.RichMemo = FRichEditor) then
    SpellSource.ApplyErrorsTo(MemoSource);
end;

procedure TformPoBatch.SpellTranslationSpellCheckComplete(Sender: TObject; ErrorCount: integer);
begin
  if (Grid.Col = CELL_TRANSLATION) and (SpellTranslation.RichMemo = FRichEditor) then
    SpellTranslation.ApplyErrorsTo(MemoTranslation);
end;

procedure TformPoBatch.MemoSourceEnter(Sender: TObject);
begin
  Application.QueueAsyncCall(@UpdateSpellCheckMemo, 0);
end;

procedure TformPoBatch.MemoSourceChange(Sender: TObject);
begin
  if Grid.RowCount <= Grid.FixedRows then Exit;

  if not MemoSource.Focused then Exit;

  if not MemoSource.Text.EqualNormalized(Grid.Cells[CELL_TEXT, Grid.Row]) then
  begin
    Grid.Cells[CELL_TEXT, Grid.Row] := MemoSource.Text;
    Changed := True;
    UpdateValid;
    Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0), Grid.Row);
  end;
end;

procedure TformPoBatch.MemoPluralChange(Sender: TObject);
begin
  if Grid.RowCount <= Grid.FixedRows then Exit;

  if not MemoPlural.Focused then Exit;

  if not MemoPlural.Text.EqualNormalized(Grid.Cells[CELL_PLURAL, Grid.Row]) then
  begin
    Grid.Cells[CELL_PLURAL, Grid.Row] := MemoPlural.Text;
    Changed := True;
    UpdateValid;
    Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0), Grid.Row);
  end;
end;

procedure TformPoBatch.MemoTranslationEnter(Sender: TObject);
begin
  Application.QueueAsyncCall(@UpdateSpellCheckMemo, 0);
end;

procedure TformPoBatch.MemoTranslationChange(Sender: TObject);
begin
  if Grid.RowCount <= Grid.FixedRows then Exit;

  if not MemoTranslation.Focused then Exit;

  if not MemoTranslation.Text.EqualNormalized(Grid.Cells[CELL_TRANSLATION, Grid.Row]) then
  begin
    Grid.Cells[CELL_TRANSLATION, Grid.Row] := MemoTranslation.Text;
    Changed := True;
    UpdateValid;
    Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0), Grid.Row);
  end;
end;

{%EndRegion}

{%Region -fold Properties Methods}

procedure TformPoBatch.SetChanged(Value: boolean);
begin
  FChanged := Value;
  AUndoChanges.Enabled := FChanged;
  UpdateInterface;
end;

procedure TformPoBatch.SetSplitRatio(Value: double);
begin
  FSplitRatio := Value;
end;

procedure TformPoBatch.SetWordWrap(Value: boolean);
begin
  FWordWrap := Value;

  FRichEditor.WordWrap := FWordWrap;
  if FWordWrap then
    FRichEditor.ScrollBars := ssAutoVertical
  else
    FRichEditor.ScrollBars := ssAutoBoth;

  Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0));
end;

{%EndRegion}

{%Region -fold Methods File Operations}

function TformPoBatch.IsCanClose(Fast: boolean = False): boolean;
var
  mr: TModalResult;
begin
  Result := True;
  if FSaving then
  begin
    Result := False;
    Exit;
  end;

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
            if not SaveFile(dialogSave.FileName, Fast) then
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
          if not SaveFile(FFileName, Fast) then
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
    FillGrid;
    FillGridHeaders;
    UpdateTranslatePanel;
    SyncPath;
  except
    Result := False;
    raise;
  end;
end;

function TformPoBatch.OpenFile(const AFileName: string; CheckCanClose: boolean = True): boolean;
begin
  Result := False;

  // Validate file before opening
  if not ValidateFileForOpen(AFileName) then
    Exit;

  // Check if we need to save current changes
  if CheckCanClose and not IsCanClose then
    Exit;

  // Try to load the file
  if LoadFile(AFileName) then
  begin
    FFileName := AFileName;
    Changed := False;
    FillGrid;
    FillGridHeaders;
    SyncPath;

    if Grid.RowCount > 1 then
    begin
      Grid.Row := 1;
      FLastRow := 1;
      UpdateTranslatePanel;
    end;

    Result := True;
  end;
end;

function TformPoBatch.OpenPath(const APath: string; Force: boolean = False): boolean;
var
  TempFiles: TStringList;
  i: integer;
begin
  Result := False;
  if not DirectoryExists(APath) then Exit;

  // Cancel any pending analysis from a previously opened path
  Inc(FAnalizeGeneration);

  if (PoFiles.Count = 0) or Force then
  begin
    TempFiles := TStringList.Create;
    try
      // Scan for both .po and .pot files
      TOS.FindFilesByMasks(APath, ['*.po', '*.pot'], TempFiles);

      // If no files found, leave the current state unchanged
      if TempFiles.Count = 0 then
        Exit;

      // Success: replace the old list with the new one
      FPoFiles.Assign(TempFiles);
      FPathIndex := -1;
      SetLength(FFileStatuses, 0);
    finally
      TempFiles.Free;
    end;
  end
  else
  begin
    // Files came from settings, drop entries that no longer exist on disk
    // and keep FFileStatuses aligned with the shortened list
    for i := FPoFiles.Count - 1 downto 0 do
      if not FileExists(FPoFiles[i]) then
      begin
        FPoFiles.Delete(i);
        if i < Length(FFileStatuses) then
          Delete(FFileStatuses, i, 1);

        // Adjust the index of the currently opened file
        if FPathIndex = i then
          FPathIndex := -1
        else
        if FPathIndex > i then
          Dec(FPathIndex);
      end;
  end;

  // Find and store the last .pot file (if any)
  FPotFile := string.Empty;
  for i := PoFiles.Count - 1 downto 0 do
    if SameText(ExtractFileExt(PoFiles[i]), '.pot') then
    begin
      FPotFile := PoFiles[i];
      Break;
    end;

  ListPath.Items.Clear;
  for i := 0 to FPoFiles.Count - 1 do
    ListPath.Items.Add(ExtractFileName(FPoFiles[i]));
  FLastPathIndex := -1;   // no file is selected in the new folder

  UpdateInterface;
  SyncPath;

  Result := True;
end;

procedure TformPoBatch.AnalizePath(AIndex: integer = -1; ADraw: boolean = False);
var
  Gen, i: integer;
begin
  Gen := FAnalizeGeneration;
  try
    // We analyze each file and save the status
    if AIndex < 0 then
    begin
      SetLength(FFileStatuses, FPoFiles.Count);
      for i := 0 to FPoFiles.Count - 1 do
      begin
        if Gen <> FAnalizeGeneration then Exit;
        if i >= FPoFiles.Count then Exit;

        FFileStatuses[i] := TPOFile.GetFileStatus(FPoFiles[i]);
        if ADraw then ListPath.Invalidate;
        Application.ProcessMessages;
      end;
    end
    else
    begin
      if (AIndex < 0) or (AIndex >= FPoFiles.Count) or (AIndex >= Length(FFileStatuses)) then
        Exit;

      FFileStatuses[AIndex] := TPOFile.GetFileStatus(FPoFiles[AIndex]);
      if ADraw then ListPath.Repaint;
    end;
  finally
    ListPath.Invalidate;
  end;
end;

procedure TformPoBatch.LoadPath(Data: PtrInt);
begin
  if (Path <> string.Empty) then
  begin
    if OpenPath(Path) then
    begin
      UpdatePath;
      AnalizePath(-1, True);
    end
    else
    begin
      Path := string.Empty;
      UpdateInterface; // refresh caption and UI after clearing invalid path
    end;
  end;
end;

procedure TformPoBatch.ClosePath;
begin
  FPath := string.Empty;
  UpdatePath;
  UpdateInterface;
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
  UpdateCaption;
end;

procedure TformPoBatch.SyncPath;
var
  Idx: integer;
begin
  ListPath.ItemIndex := -1;
  FLastPathIndex := -1;
  if (Path = string.Empty) or (FFileName = string.Empty) then Exit;
  if ExtractFilePath(FFileName) <> IncludeTrailingPathDelimiter(Path) then Exit;

  Idx := FPoFiles.IndexOf(FFileName);
  if Idx < 0 then Exit;

  if ListPath.Items.Count > Idx then
  begin
    ListPath.Selected[Idx] := True;
    ListPath.ItemIndex := Idx;
    ListPath.Invalidate;
  end;
  FLastPathIndex := Idx;
end;

procedure TformPoBatch.SelectPath;
var
  Idx: integer;
  FullPath: string;
  SavedRow, SavedTopRow: integer;   // Remember grid position and scroll
begin
  Idx := ListPath.ItemIndex;
  if Idx < 0 then Exit;   // no file selected

  // Save current row and scroll before any changes
  SavedRow := Grid.Row;
  SavedTopRow := Grid.TopRow;

  // Remember the previous valid selection
  FPathIndex := FLastPathIndex;

  // Tentatively accept the new index (will be confirmed or reverted)
  FLastPathIndex := Idx;

  if Idx >= FPoFiles.Count then Exit;   // safety check
  FullPath := FPoFiles[Idx];

  // Attempt to load the file
  Self.LockUpdate;
  Grid.OnSelectCell := nil;
  try
    // Ask to save current changes – if user cancels, revert the selection
    if not IsCanClose(True) then
    begin
      ListPath.ItemIndex := FPathIndex;
      FLastPathIndex := FPathIndex;
      Exit;
    end;

    if LoadFile(FullPath) then
    begin
      FFileName := FullPath;
      Changed := False;
      FillGrid;
      FillGridHeaders;
      if Grid.RowCount > 1 then
      begin
        // Try to restore saved row, default to 1 if out of range
        if SavedRow < Grid.RowCount then
          Grid.Row := SavedRow
        else
          Grid.Row := 1;
        // Restore vertical scroll position
        Grid.TopRow := SavedTopRow;
        FLastRow := Grid.Row;
        FPathIndex := ListPath.ItemIndex;
        // Reuse the already loaded model instead of re-reading the file
        if (FPathIndex >= 0) and (FPathIndex < Length(FFileStatuses)) then
        begin
          FFileStatuses[FPathIndex] := TPOFile.ComputeStatusFromModel(FPoFile);
          ListPath.Invalidate;
        end;
      end;
      UpdateTranslatePanel;
    end
    else
    begin
      // Loading failed – revert to the previous selection
      ListPath.ItemIndex := FPathIndex;
      FLastPathIndex := FPathIndex;
    end;
  finally
    Self.UnlockUpdate;

    if FPathMouseSelecting then
    begin
      FPathMouseSelecting := False;
      if Grid.CanFocus then Grid.SetFocus;
      Grid.Invalidate;
    end;

    Grid.OnSelectCell := @GridSelectCell;
  end;
end;

function TformPoBatch.LoadFile(AFileName: string): boolean;
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
    Input.TrailingLineBreak := TOS.FileEndsWithLineBreak(AFileName);
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

      FLanguage := DetectLanguage(AFileName);
      SpellTranslation.Language := FLanguage;

      UpdateInterface;
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

function TformPoBatch.SaveFile(AFileName: string; Fast: boolean = False): boolean;
var
  Output: TStringList;
  Stream: TStringStream;
begin
  Result := False;
  if FSaving then Exit; // already saving

  // Validate filename
  if Trim(AFileName) = string.Empty then
  begin
    MessageDlg('Error', 'Invalid file name', mtError, [mbOK], 0);
    Exit;
  end;

  FSaving := True;
  try
    SaveGrid;
    SaveGridHeaders;
    FPoFile.HeaderValue['X-Generator'] := 'PoBatch ' + GetAppVersion;
    if not Fast then FillGridHeaders;

    Screen.Cursor := crHourGlass;
    Output := TStringList.Create;
    try
      try
        // Save FPoFile content into a string first
        begin
          Stream := TStringStream.Create(string.Empty, TEncoding.UTF8);
          try
            FPoFile.SaveToStream(Stream);         // serialize all entries to UTF-8 stream
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

        AnalizePath(FPathIndex);
        if not Fast then
        begin
          UpdateInterface;
          UpdateTranslatePanel;
        end;

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
      Screen.Cursor := crDefault;
      Output.Free;
    end;
  finally
    FSaving := False;
  end;
end;

function TformPoBatch.CreatePoFileFromPot(const APotFileName, ACode: string; out ANewFileName: string): boolean;
var
  BaseName: string;
begin
  // Creates a single PO file from the POT template for the given language code;
  // returns the full path of the new file in ANewFileName on success.
  Result := False;
  ANewFileName := string.Empty;

  // Build the target file name as <base>.<lang>.po in the POT directory
  BaseName := ChangeFileExt(ExtractFileName(APotFileName), '');
  ANewFileName := IncludeTrailingPathDelimiter(ExtractFilePath(APotFileName)) + BaseName + '.' + ACode + '.po';

  // Load the POT content into the model
  if not LoadFile(APotFileName) then
    Exit;

  // Fill in the standard headers in the canonical order and set the chosen language
  FPoFile.ApplyDefaultHeaders(ACode, 'PoBatch ' + GetAppVersion);

  FLanguage := ACode;
  SpellTranslation.Language := FLanguage;
  FFileName := ANewFileName;

  // Populate the grid from the freshly loaded POT before saving, otherwise
  // SaveGrid inside SaveFile would push the previous document back into the model
  FillGrid;
  FillGridHeaders;

  // Save the new file to disk
  if not SaveFile(ANewFileName) then
    Exit;

  Result := True;
end;

{%EndRegion}

{%Region -fold Methods}

procedure TformPoBatch.UpdateCaption;
var
  BaseTitle: string;
  AppName: string;
  FileInPath: boolean;
begin
  AppName := 'PoBatch';

  if FFileName = string.Empty then
  begin
    // No file loaded – show path (if any) with "Untitled"
    if FPath <> string.Empty then
      BaseTitle := FPath + ' - Untitled'
    else
      BaseTitle := 'Untitled';
  end
  else
  begin
    // Check whether the opened file resides inside the currently open folder
    FileInPath := (FPath <> string.Empty) and (ExtractFilePath(FFileName) = IncludeTrailingPathDelimiter(FPath));

    if (FPath <> string.Empty) and not FileInPath then
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
end;

procedure TformPoBatch.UpdateInterface;
begin
  UpdateCaption;
  ListPath.ItemHeight := ListPath.Canvas.TextHeight('Hg') + 4;
  Application.QueueAsyncCall(@FixSplitters, 0);
end;

procedure TformPoBatch.UpdateFileStatus(const AFileName: string);
var
  Idx: integer;
begin
  // Only if a folder is open and we have a valid file
  if (FPath = string.Empty) or (AFileName = string.Empty) then Exit;
  if ExtractFilePath(AFileName) <> IncludeTrailingPathDelimiter(FPath) then Exit;

  Idx := FPoFiles.IndexOf(AFileName);
  if (Idx < 0) or (Idx >= Length(FFileStatuses)) then Exit;

  FFileStatuses[Idx] := TPOFile.GetFileStatus(AFileName);
  ListPath.Invalidate;   // repaint the list
end;

procedure TformPoBatch.UpdateSwitch(aRow: integer = -1);
var
  StartRow, EndRow, Row: integer;
  HasFuzzy: boolean;
begin
  if aRow = -1 then aRow := Grid.Row;

  PanelCheck.Visible := Grid.RowCount > Grid.FixedRows;

  // Determine the range of rows to inspect
  if Grid.Selection.Top <> Grid.Selection.Bottom then
  begin
    StartRow := Grid.Selection.Top;
    EndRow := Grid.Selection.Bottom;
  end
  else
  begin
    StartRow := aRow;
    EndRow := aRow;
  end;

  // Safety clamp: selection may exceed actual row count
  if EndRow >= Grid.RowCount then
    EndRow := Grid.RowCount - 1;
  if StartRow < Grid.FixedRows then
    StartRow := Grid.FixedRows;

  // Check if any selected row has the fuzzy flag set to '1'
  HasFuzzy := False;
  for Row := StartRow to EndRow do
  begin
    if (Row >= Grid.FixedRows) and ((Grid.Cells[CELL_FUZZY, Row] = '0') or (Grid.Cells[CELL_FUZZY, Row] = '1')) then
    begin
      if Grid.Cells[CELL_FUZZY, Row] = '1' then
      begin
        HasFuzzy := True;
        Break;
      end;
    end;
  end;

  // Update the switch image and styling based on the presence of any fuzzy row
  if (PanelCheck.Visible) and (Grid.Row > -1) then
  begin
    if HasFuzzy then
    begin
      ImageSwitch.Tag := 1;
      ImageSwitch.ImageIndex := TDarkUtils.ThemeValue(1, 3);
    end
    else
    begin
      ImageSwitch.Tag := 0;
      ImageSwitch.ImageIndex := TDarkUtils.ThemeValue(0, 2);
    end;

    PanelCheck.Color := ifthen(ImageSwitch.Tag = 1, TDarkUtils.ThemeColor(clSoftYellow, clSoftYellowDark), clWindow);
    MemoCheck.Color := PanelCheck.Color;
    if ImageSwitch.Tag = 0 then
      LabelSwitch.Font.Color := TDarkUtils.ThemeColor(clMidGray, clMidGrayDark)
    else
      LabelSwitch.Font.Color := clWindowText;
  end
  else
  begin
    ImageSwitch.Tag := 0;
    ImageSwitch.ImageIndex := TDarkUtils.ThemeValue(0, 2);
    PanelCheck.Color := clWindow;
    LabelSwitch.Font.Color := TDarkUtils.ThemeColor(clMidGray, clMidGrayDark);
  end;
end;

procedure TformPoBatch.UpdateValid(aRow: integer = -1);
var
  Entry: TPOEntry;
begin
  SaveRow(aRow);
  if aRow = -1 then aRow := Grid.Row;
  Entry := RowEntry(aRow);
  if Assigned(Entry) then
    Grid.Cells[CELL_VALID, aRow] := IfThen(Entry.IsValid, '1', '0');
end;

procedure TformPoBatch.UpdateTranslatePanel(aRow: integer = -1);
var
  OriginalOnChange: TNotifyEvent;
  NewText: string;
begin
  if not Pages.Visible then Exit;
  if aRow = -1 then aRow := Grid.Row;

  UpdateSwitch(aRow);

  // Source memo
  NewText := Grid.Cells[CELL_TEXT, aRow];
  if not MemoSource.Text.EqualNormalized(NewText) then
  begin
    OriginalOnChange := MemoSource.OnChange;
    MemoSource.OnChange := nil;
    try
      MemoSource.Text := NewText;
    finally
      MemoSource.OnChange := OriginalOnChange;
    end;
  end;
  MemoSource.UpdateState(5);

  // Plural memo
  NewText := Grid.Cells[CELL_PLURAL, aRow];
  if not MemoPlural.Text.EqualNormalized(NewText) then
  begin
    MemoPlural.OnChange := nil;
    try
      MemoPlural.Text := NewText;
    finally
      MemoPlural.OnChange := @MemoPluralChange;
    end;
  end;
  MemoPlural.Visible := MemoPlural.Text <> string.Empty;
  ShapePlural.Visible := MemoPlural.Text <> string.Empty;
  MemoPlural.UpdateState(5);

  if MemoPlural.Visible then
  begin
    FillGridPlural(aRow);
    GridPlural.Visible := True;
    MemoTranslation.Visible := False;
    GridPlural.Align := alClient;
  end
  else
  begin
    MemoTranslation.Align := alClient;
    GridPlural.Visible := False;
    MemoTranslation.Visible := True;

    NewText := Grid.Cells[CELL_TRANSLATION, aRow];
    if not MemoTranslation.Text.EqualNormalized(NewText) then
    begin
      OriginalOnChange := MemoTranslation.OnChange;
      MemoTranslation.OnChange := nil;
      try
        MemoTranslation.Text := NewText;
      finally
        MemoTranslation.OnChange := OriginalOnChange;
      end;
    end;
    MemoTranslation.UpdateState(5);
  end;
  FillGridComments(aRow);
  Application.QueueAsyncCall(@FixSplitters, 0);
end;

procedure TformPoBatch.UpdateSpellCheckMemo(Data: PtrInt);
begin
  if Data = 1 then
  begin
    // Switch spell check to active memo (only when it changes)
    if (Grid.Col = CELL_TEXT) and (SpellSource.RichMemo <> FRichEditor) then
      SpellSource.RichMemo := FRichEditor;
    if (Grid.Col = CELL_TRANSLATION) and (SpellTranslation.RichMemo <> FRichEditor) then
      SpellTranslation.RichMemo := FRichEditor;
  end
  else
  begin
    // Switch spell check to bottom memo
    if SpellSource.RichMemo = FRichEditor then
      SpellSource.RichMemo := MemoSource;
    if SpellTranslation.RichMemo = FRichEditor then
      SpellTranslation.RichMemo := MemoTranslation;
  end;
end;

procedure TformPoBatch.SwitchCheck;
var
  StartRow, EndRow, Row: integer;
begin
  // toggle switch image and remember new state
  if ImageSwitch.Tag = 0 then
  begin
    ImageSwitch.Tag := 1;
    ImageSwitch.ImageIndex := TDarkUtils.ThemeValue(1, 3);
  end
  else
  begin
    ImageSwitch.Tag := 0;
    ImageSwitch.ImageIndex := TDarkUtils.ThemeValue(0, 2);
  end;

  // apply to all selected rows
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
    if Row >= Grid.FixedRows then
    begin
      Grid.Cells[CELL_FUZZY, Row] := ImageSwitch.Tag.ToString;
      UpdateValid(Row);
    end;
  end;

  UpdateSwitch;
  UpdateTranslatePanel;

  Changed := True;
  Grid.Invalidate;
end;

function TformPoBatch.CanActionEnable: boolean;
begin
  //jcf:format=off
  Result :=
    not (Assigned(FRichEditor) and FRichEditor.Focused) and
    not (Assigned(MemoSource) and MemoSource.Focused) and
    not (Assigned(MemoPlural) and MemoPlural.Focused) and
    not (Assigned(MemoTranslation) and MemoTranslation.Focused) and
    not (Assigned(Filter) and Filter.Focused) and
    not (Assigned(GridHeaders.InplaceEditor) and GridHeaders.InplaceEditor.Focused) and
    not (Assigned(GridPlural.InplaceEditor) and GridPlural.InplaceEditor.Focused) and
    not (Assigned(GridComments.InplaceEditor) and GridComments.InplaceEditor.Focused);
  //jcf:format=on
end;

function TformPoBatch.RowEntry(aRow: integer = -1): TPOEntry;
var
  Row: integer;
  EntryIndex: integer;
begin
  Result := nil;
  // Safety check: model must exist
  if not Assigned(FPoFile) then
    Exit;

  Row := ifthen(aRow = -1, Grid.Row, aRow);
  // Ignore header row or invalid selection
  if (Row < Grid.FixedRows) or (Row >= Grid.RowCount) then
    Exit;

  // Column 0 stores the permanent index in PoFile.Entries
  EntryIndex := StrToIntDef(Grid.Cells[0, Row], -1);
  if (EntryIndex < 0) or (EntryIndex >= FPoFile.Entries.Count) then
  begin
    EntryIndex := FPoFile.Entries.Add(TPOEntry.Create);
    Grid.Cells[0, Row] := EntryIndex.ToString;
  end;

  Result := FPoFile.Entries[EntryIndex];
end;

procedure TformPoBatch.DelayedSetMemoFocus(Data: PtrInt);
begin
  if Assigned(FRichEditor) and (FRichEditor.CanFocus) then
  begin
    FRichEditor.SetFocus;
    if Data = 1 then
      FRichEditor.SelectAll
    else
    if (FRichEditor.SelLength = 0) then
      FRichEditor.SelStart := FRichEditor.GetTextLen;
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

  ShapePlural.Left := 0;
end;

function TformPoBatch.CutGridsSelection: boolean;
begin
  // Perform copy first, then MenuMemoClear the selection
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
    else if ActiveControl = GridPlural then
      GridPlural.CopyToClipboard(True)
    else if ActiveControl = GridComments then
      GridComments.CopyToClipboard(True)
    else
      Exit;
  except
    Result := False;
  end;
  Result := True;
end;

function TformPoBatch.PasteGridsSelection: boolean;
var
  i: integer;
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
  end
  else if ActiveControl = GridPlural then
  begin
    GridPlural.PasteFromClipboard;
    Result := True;
  end
  else if ActiveControl = GridComments then
  begin
    GridComments.PasteFromClipboard;
    Result := True;
  end;

  if Result then
  begin
    Changed := True;
    if (Grid.Col = CELL_TRANSLATION) or ((Grid.Col = CELL_TEXT) and (not MenuEditTranslationOnly.Checked)) then
    begin
      UpdateTranslatePanel;
      for i := Grid.FixedRows to Grid.RowCount - 1 do
        UpdateValid(i);
    end;
    Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0));
  end;
end;

function TformPoBatch.DeleteGridsSelection: boolean;
var
  i: integer;
begin
  Result := False;

  if ActiveControl = Grid then
  begin
    if (not AEditTranslationOnly.Checked or ((Grid.Selection.Left = CELL_TRANSLATION) and
      (Grid.Selection.Right = CELL_TRANSLATION))) then
    begin
      if (Grid.Selection.Height > 0) then
      begin
        Grid.Clean(Max(Grid.Selection.Left, CELL_TEXT), Grid.Selection.Top, Grid.Selection.Right, Grid.Selection.Bottom, [gzNormal]);

        // Refresh the valid flag for every affected row
        for i := Grid.Selection.Top to Grid.Selection.Bottom do
          UpdateValid(i);
      end
      else
      begin
        Grid.Clean(Grid.Col, Grid.Row, Grid.Col, Grid.Row, [gzNormal]);
        UpdateValid;
      end;

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
  end
  else
  if ActiveControl = GridPlural then
  begin
    if (GridPlural.Selection.Height > 0) then
      GridPlural.Clean(GridPlural.Selection, [gzNormal])
    else
      GridPlural.Clean(GridPlural.Col, GridPlural.Row, GridPlural.Col, GridPlural.Row, [gzNormal]);

    SaveGridPlural;
    UpdateValid;
    Changed := True;
    Result := True;
  end
  else
  if (ActiveControl = GridComments) and (not AEditTranslationOnly.Checked) then
  begin
    if (GridComments.Selection.Height > 0) then
      GridComments.Clean(GridComments.Selection, [gzNormal])
    else
      GridComments.Clean(GridComments.Col, GridComments.Row, GridComments.Col, GridComments.Row, [gzNormal]);

    SaveGridComments;
    UpdateValid;
    Changed := True;
    Result := True;
  end;
end;

function TformPoBatch.SelectGridsAll: boolean;
begin
  if ActiveControl = Grid then
    Grid.Selection := TGridRect.Create(CELL_VALID, 0, CELL_REFERENCE, Grid.RowCount)
  else
  if ActiveControl = GridHeaders then
    GridHeaders.Selection := TGridRect.Create(CELL_HEADERS_NAME, 0, CELL_HEADERS_VALUE, GridHeaders.RowCount)
  else
  if ActiveControl = GridPlural then
    GridPlural.Selection := TGridRect.Create(1, 0, 1, GridPlural.RowCount)
  else
  if ActiveControl = GridComments then
    GridComments.Selection := TGridRect.Create(CELL_COMMENTS_TYPE, 0, CELL_COMMENTS_VALUE, GridPlural.RowCount);
  Result := True;
end;

function TformPoBatch.EntryMatchesFilter(Entry: TPOEntry; const AFilter: string): boolean;
var
  PrevStrings: TStrings;
  LowerFilter: string;
begin
  if AFilter = string.Empty then Exit(True);
  LowerFilter := LowerCase(AFilter);

  if (AFilter = '1') or (AFilter = '=1') then Exit(Entry.IsValid)
  else
  if (AFilter = '0') or (AFilter = '=0') then Exit(not Entry.IsValid);

  // Check original
  if Pos(LowerFilter, LowerCase(Entry.MsgId)) > 0 then Exit(True);

  // Check translation
  if Pos(LowerFilter, LowerCase(Entry.MsgStrSimple)) > 0 then Exit(True);

  // Check context
  if Grid.Columns[COLUMN_CONTEXT].Visible and (Pos(LowerFilter, LowerCase(Entry.MsgCtxt)) > 0) then Exit(True);

  // Check plural
  if Grid.Columns[COLUMN_PLURAL].Visible and (Pos(LowerFilter, LowerCase(Entry.MsgIdPlural)) > 0) then Exit(True);

  // Check reference
  if Grid.Columns[COLUMN_REFERENCE].Visible and (Pos(LowerFilter, LowerCase(Entry.Reference)) > 0) then Exit(True);

  // Check previous text
  PrevStrings := Entry.GetCommentsOfType(poctPrevious);
  try
    Result := Pos(LowerFilter, LowerCase(PrevStrings.Text)) > 0;
  finally
    PrevStrings.Free;
  end;
end;

function TformPoBatch.GetEntiryIndex(aRow: integer = -1): integer;
var
  Row: integer;
begin
  // Determine row to save
  if aRow = -1 then
    Row := Grid.Row
  else
    Row := aRow;

  // Validate that the row is a data row
  if (Row < Grid.FixedRows) or (Row >= Grid.RowCount) then Exit(-1);

  // Column 0 holds the permanent entry index
  Result := StrToIntDef(Grid.Cells[0, Row], -1);
  if (Result < 1) or (Result >= FPoFile.Entries.Count) then Exit(-1);
end;

function TformPoBatch.DetectLanguage(const AFileName: string): string;
var
  HeaderLang: string;
  BaseName: string;
  Ext: string;
  Parts: TStringArray;
  LangCode: string;
begin
  Result := '';

  // Prefer the language from the PO header
  HeaderLang := Trim(FPoFile.HeaderValue['Language']);   // <-- было FPoFile.Headers.Values['Language']
  if HeaderLang <> '' then
    Exit(HeaderLang);

  // Fall back to the file name, e.g. "file.en.po" or "app.ru_RU.po"
  BaseName := ExtractFileName(AFileName);
  Ext := ExtractFileExt(BaseName);
  if not SameText(Ext, '.po') then
    Exit;

  BaseName := ChangeFileExt(BaseName, '');
  LangCode := '';
  Parts := BaseName.Split('.');
  if Length(Parts) > 1 then
    LangCode := Trim(Parts[High(Parts)]);

  // Sanity check: the candidate must differ from the base name (i.e. the file had a dot)
  if (LangCode <> '') and (LangCode <> BaseName) then
    Result := LangCode;
end;

{%EndRegion}

{%Region -fold Fill / Save Grids}

procedure TformPoBatch.FillGrid;
var
  i, RowIndex: integer;
  Entry: TPOEntry;
  SavedEntryIndex: integer;    // permanent entry index before refill
  TargetRow: integer;          // row to select after refill
begin
  if not Assigned(FPoFile) then
  begin
    Grid.RowCount := Grid.FixedRows;
    Exit;
  end;

  // Fill main translation grid
  Grid.BeginUpdate;
  FUpdatingGrid := True;
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
      if Entry.MsgId = string.Empty then Continue;  // skip header entry

      // Apply filter if one is set
      if (Filter.Text <> string.Empty) and not EntryMatchesFilter(Entry, Filter.Text) then
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

      // Column 6: plural (msgidplural)
      Grid.Cells[CELL_PLURAL, RowIndex] := Entry.MsgIdPlural;

      // Column 7: fuzzy flag (1 if fuzzy, 0 otherwise)
      Grid.Cells[CELL_FUZZY, RowIndex] := IfThen(Entry.IsFuzzy, '1', '0');

      Inc(RowIndex);
    end;

    // Re-apply active column sort if any
    if (FSortColumn >= 0) and (Grid.RowCount > Grid.FixedRows) then
      Grid.SortColRow(True, FSortColumn, Grid.FixedRows, Grid.RowCount - 1);

    Grid.UpdateRowHeights(FWordWrap, FMaxRowHeight, iif(Grid.EditorMode, FRichEditor.GetTextHeight(FRichEditor.Lines.Text), 0));

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

procedure TformPoBatch.SaveRow(aRow: integer);
var
  Row: integer;
  EntryIndex: integer;
  Entry: TPOEntry;
begin
  if not Assigned(FPoFile) then Exit;

  if aRow = -1 then
    Row := Grid.Row
  else
    Row := aRow;

  EntryIndex := GetEntiryIndex(aRow);
  if EntryIndex < 0 then Exit;

  Entry := FPoFile.Entries[EntryIndex];

  // Update msgid (empty becomes UNDEFINED)
  if Trim(Grid.Cells[CELL_TEXT, Row]) = string.Empty then
    Entry.MsgId := UNDEFINED
  else
    Entry.MsgId := Grid.Cells[CELL_TEXT, Row];

  // Update translation
  Entry.MsgStrSimple := Grid.Cells[CELL_TRANSLATION, Row];

  // Update reference
  Entry.Reference := Grid.Cells[CELL_REFERENCE, Row];

  // Update context
  Entry.MsgCtxt := Grid.Cells[CELL_CONTEXT, Row];

  // Update plural
  Entry.MsgIdPlural := Grid.Cells[CELL_PLURAL, Row];

  // Update fuzzy flag
  Entry.IsFuzzy := (Grid.Cells[CELL_FUZZY, Row] = '1');
end;

procedure TformPoBatch.SaveGrid;
var
  i: integer;
begin
  if not Assigned(FPoFile) then Exit;

  Grid.EditorMode := False;

  // Save all data rows using the common SaveRow method
  for i := Grid.FixedRows to Grid.RowCount - 1 do
    SaveRow(i);

  if GridPlural.Visible then
    SaveGridPlural;
  SaveGridComments;
end;

procedure TformPoBatch.FillGridHeaders;
var
  Headers: TStrings;
  Key, Value: string;
  i, p: integer;
begin
  if not Assigned(FPoFile) then
  begin
    GridHeaders.RowCount := GridHeaders.FixedRows;
    Exit;
  end;

  // Fill the headers grid
  GridHeaders.BeginUpdate;
  GridHeaders.OnColRowInserted := nil;
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
          Value := string.Empty;
        end;
        // Column 0 is fixed, store key and value in columns 1 and 2
        GridHeaders.Cells[1, GridHeaders.FixedRows + i] := Key;
        GridHeaders.Cells[2, GridHeaders.FixedRows + i] := Value;
      end;
    finally
      Headers.Free;
    end;
  finally
    GridHeaders.OnColRowInserted := @GridUniversalColRowInserted;
    GridHeaders.EndUpdate;
  end;
end;

procedure TformPoBatch.SaveGridHeaders;
var
  Headers: TStringList;
  i: integer;
begin
  if not Assigned(FPoFile) then Exit;

  GridHeaders.EditorMode := False;

  // Save headers from GridHeaders
  Headers := TStringList.Create;
  try
    for i := GridHeaders.FixedRows to GridHeaders.RowCount - 1 do
    begin
      // Skip completely empty rows
      if (Trim(GridHeaders.Cells[1, i]) = string.Empty) and (Trim(GridHeaders.Cells[2, i]) = string.Empty) then
        Continue;
      Headers.Add(GridHeaders.Cells[1, i] + '=' + GridHeaders.Cells[2, i]);
    end;
    FPoFile.Headers := Headers;
  finally
    Headers.Free;
  end;
end;

procedure TformPoBatch.FillGridPlural(aRow: integer = -1);
var
  EntryIndex: integer;
  i: integer;
begin
  GridPlural.RowCount := GridPlural.FixedRows;
  if not Assigned(FPoFile) then Exit;

  EntryIndex := GetEntiryIndex(aRow);
  if EntryIndex < 0 then Exit;

  // Fill the headers grid
  GridPlural.BeginUpdate;
  GridPlural.OnColRowInserted := nil;
  try
    GridPlural.RowCount := GridPlural.FixedRows + Max(FPoFile.Entries[EntryIndex].MsgStrCount, FPoFile.PluralFormsCount);
    for i := 0 to FPoFile.Entries[EntryIndex].MsgStrCount - 1 do
      GridPlural.Cells[1, GridPlural.FixedRows + i] := FPoFile.Entries[EntryIndex].MsgStr[i];
  finally
    GridPlural.OnColRowInserted := @GridUniversalColRowInserted;
    GridPlural.EndUpdate;
  end;
end;

procedure TformPoBatch.SaveGridPlural(aRow: integer = -1);
var
  EntryIndex, Row, i, Count: integer;
  Entry: TPOEntry;
  NewList: TStringList;
begin
  if not Assigned(FPoFile) then
    Exit;

  GridPlural.EditorMode := False;

  if aRow = -1 then
    Row := Grid.Row
  else
    Row := aRow;

  EntryIndex := GetEntiryIndex(Row);
  if EntryIndex < 0 then
    Exit;

  Entry := FPoFile.Entries[EntryIndex];
  Count := GridPlural.RowCount - GridPlural.FixedRows;

  // Build a temporary list from grid cells
  NewList := TStringList.Create;
  try
    for i := 0 to Count - 1 do
      NewList.Add(GridPlural.Cells[1, GridPlural.FixedRows + i]);

    // Replace all msgstr forms in one go via the TStrings property
    Entry.MsgStrList := NewList;

    if (NewList.Count > 0) and (Row >= Grid.FixedRows) then
      Grid.Cells[CELL_TRANSLATION, Row] := NewList[0];
  finally
    NewList.Free;
  end;
end;

procedure TformPoBatch.FillGridComments(aRow: integer);
var
  EntryIndex: integer;
  Comments: TStrings;
  Key, Value: string;
  i, p: integer;
begin
  GridComments.RowCount := GridComments.FixedRows;
  if not Assigned(FPoFile) then Exit;

  EntryIndex := GetEntiryIndex(aRow);
  if EntryIndex < 0 then Exit;

  // Fill the headers grid
  GridComments.BeginUpdate;
  GridComments.OnColRowInserted := nil;
  try
    Comments := FPoFile.Entries[EntryIndex].CommentsStr;
    try
      GridComments.RowCount := GridComments.FixedRows + Comments.Count;
      for i := 0 to Comments.Count - 1 do
      begin
        // Parse "Key=Value" line
        p := Pos('=', Comments[i]);
        if p > 0 then
        begin
          Key := Copy(Comments[i], 1, p - 1);
          Value := Copy(Comments[i], p + 1, MaxInt);
        end
        else
        begin
          Key := Comments[i];
          Value := string.Empty;
        end;
        // Column 0 is fixed, store key and value in columns 1 and 2
        GridComments.Cells[1, GridComments.FixedRows + i] := Key;
        GridComments.Cells[2, GridComments.FixedRows + i] := Value;
      end;
    finally
      Comments.Free;
    end;
  finally
    GridComments.OnColRowInserted := @GridUniversalColRowInserted;
    GridComments.EndUpdate;
  end;
end;

procedure TformPoBatch.SaveGridComments(aRow: integer = -1);
var
  EntryIndex, i, Row: integer;
  Comments: TStringList;
begin
  if not Assigned(FPoFile) then Exit;
  if Grid.RowCount <= Grid.FixedRows then Exit;

  GridComments.EditorMode := False;

  if aRow = -1 then
    Row := Grid.Row
  else
    Row := aRow;

  EntryIndex := GetEntiryIndex(Row);
  if EntryIndex < 0 then
    Exit;

  // Save headers from GridHeaders
  Comments := TStringList.Create;
  try
    for i := GridComments.FixedRows to GridComments.RowCount - 1 do
    begin
      // Skip completely empty rows
      if (Trim(GridComments.Cells[1, i]) = string.Empty) or (Trim(GridComments.Cells[2, i]) = string.Empty) then
        Continue;
      Comments.Add(GridComments.Cells[1, i] + '=' + GridComments.Cells[2, i]);
    end;
    FPoFile.Entries[EntryIndex].CommentsStr := Comments;
  finally
    Comments.Free;
  end;
end;

{%EndRegion}

end.
