unit FormSettings;

{$mode ObjFPC}{$H+}

interface

uses
  Forms,
  Classes,
  Types,
  SysUtils,
  Controls,
  Graphics,
  Dialogs,
  ComCtrls,
  StdCtrls,
  ExtCtrls,
  Clipbrd,
  FileUtil,
  Themes,
  Spin,
  Math,
  Grids,
  ValEdit,
  CheckLst,
  LCLType,
  LCLIntf, EditBtn, Menus,
  StringHelper,
  Translate,
  Network;

type

  { TformSettingsPoBatch }

  TformSettingsPoBatch = class(TForm)
    {%Region -fold Form Common}
    BtnDefault: TButton;
    BtnApply: TButton;
    BtnCancel: TButton;
    BtnFont: TButton;
    BtnOk: TButton;
    BtnReset: TButton;
    CheckTmEnabled: TCheckBox;
    CheckTmAutoPopulateOnSave: TCheckBox;
    CheckSkipTmMultiLineStrings: TCheckBox;
    CheckSwitchToTable: TCheckBox;
    CheckRememberLastFile: TCheckBox;
    CheckProxyAuthentication: TCheckBox;
    CheckShowSuccess: TCheckBox;
    ClbProxiedConfigs: TCheckListBox;
    ComboProxyMode: TComboBox;
    ComboProxyType: TComboBox;
    EditButtonTmStorage: TEditButton;
    EditProxyHost: TEdit;
    EditProxyLogin: TEdit;
    EditProxyPassword: TEdit;
    EditTranslatorName: TEdit;
    EditTranslatorEmail: TEdit;
    FontDialog: TFontDialog;
    GroupBehavior: TGroupBox;
    GroupTranslationMemory: TGroupBox;
    GroupTmFilters: TGroupBox;
    GroupTmStorage: TGroupBox;
    GroupDefaultInformation: TGroupBox;
    GroupFont: TGroupBox;
    GroupProxiedConfigs: TGroupBox;
    GroupUserParameters: TGroupBox;
    GroupTimeouts: TGroupBox;
    GroupProxy: TGroupBox;
    ImagesPages: TImageList;
    LabelConnectTimeout: TLabel;
    LabelTmMaxSourceLength: TLabel;
    LabelTranslatorName: TLabel;
    LabelTranslatorEmail: TLabel;
    LabelProxyMode: TLabel;
    LabelProxyType: TLabel;
    LabelHost: TLabel;
    LabelPort: TLabel;
    LabelLogin: TLabel;
    LabelPassword: TLabel;
    LabelRequestTimeout: TLabel;
    LabelTmStorage: TLabel;
    ListPages: TListBox;
    MenuTmSelectAll: TMenuItem;
    MenuTmCompactSelected: TMenuItem;
    MenuTmImport: TMenuItem;
    MenuTmExportSelected: TMenuItem;
    MenuTmRefresh: TMenuItem;
    MenuTmClearSelected: TMenuItem;
    PagesSettings: TPageControl;
    PanelFont: TPanel;
    PanelPages: TPanel;
    PanelBottom: TPanel;
    PageGeneral: TTabSheet;
    PopupStats: TPopupMenu;
    ScrollNetwork: TScrollBox;
    Separator1: TMenuItem;
    Separator2: TMenuItem;
    SpinTmMaxSourceLength: TSpinEdit;
    SpinRequestTimeout: TSpinEdit;
    SpinConnectTimeout: TSpinEdit;
    SpinProxyPort: TSpinEdit;
    SplitterPages: TSplitter;
    PageNetwork: TTabSheet;
    PageParameters: TTabSheet;
    PageTranslationMemory: TTabSheet;
    GridTmStorage: TStringGrid;
    ValueListUserParameters: TValueListEditor;
    procedure BtnFontClick(Sender: TObject);
    procedure BtnResetClick(Sender: TObject);
    procedure EditButtonTmStorageButtonClick(Sender: TObject);
    procedure FormChangeBounds(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridTmStorageKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure GridTmStorageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure MenuTmClearSelectedClick(Sender: TObject);
    procedure MenuTmCompactSelectedClick(Sender: TObject);
    procedure MenuTmExportSelectedClick(Sender: TObject);
    procedure MenuTmImportClick(Sender: TObject);
    procedure MenuTmRefreshClick(Sender: TObject);
    procedure MenuTmSelectAllClick(Sender: TObject);
    procedure ScreenActiveControlChanged(Sender: TObject);
    procedure SettingChange(Sender: TObject);
    procedure ListPagesClick(Sender: TObject);
    procedure EditProxyHostKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure BtnApplyClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnDefaultClick(Sender: TObject);
    procedure ValueListUserParametersColRowDeleted(Sender: TObject; IsColumn: boolean; sIndex, tIndex: integer);
    procedure ValueListUserParametersColRowInserted(Sender: TObject; IsColumn: boolean; sIndex, tIndex: integer);
    procedure ValueListUserParametersKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure ValueListUserParametersKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure ValueListUserParametersSelectEditor(Sender: TObject; aCol, aRow: integer; var Editor: TWinControl);
    procedure SplitterPagesMoved(Sender: TObject);
    procedure ClbProxiedConfigsMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: integer;
      MousePos: TPoint; var Handled: boolean);
    procedure ComboMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: integer; MousePos: TPoint; var Handled: boolean);
    procedure ListPagesDrawItem(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
    procedure ClbProxiedConfigsDrawItem(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
    {%EndRegion}
  private
  private
    FOriginalProxy: TTranslateProxy;
    FOriginalTimeout: TTranslateTimeout;
    FOriginalUserParameters: TStringList;
    FOriginalProxiedConfigs: TStringList;
    FOriginalFont: TFont;
    FOriginalRememberLastFile: boolean;
    FOriginalSwitchToTable: boolean;
    FOriginalShowSuccess: boolean;
    FOriginalTranslatorName: string;
    FOriginalTranslatorEmail: string;
    FOriginalTmEnabled: boolean;
    FOriginalTmAutoPopulateOnSave: boolean;
    FOriginalTmStorage: string;
    FOriginalTmMaxSourceLength: integer;
    FOriginalTmSkipMultiline: boolean;
    FTmFileNames: TStringList;

    FApplySettings: boolean;
    FOldValueList: string;
    FLastFocused: TWinControl;
    procedure SetPanelFont(Panel: TPanel; const AFont: TFont);
    function GetTmDirectory: string;
    procedure FillTmStats;
    procedure ImportTmFromLines(ALines: TStrings; const ASourceLang, ATargetLang: string);
    function FormatFileSize(ASize: int64): string;
    procedure GetTmSelectedFiles(AList: TStrings);
  public
    procedure Apply;
    procedure Reset;
    procedure FillListPages;
    procedure FillUserParameters;
    procedure FillProxyMode;
    procedure FillConfigs;
    procedure SetState;

    property ApplySettings: boolean read FApplySettings write FApplySettings;
  end;

var
  formSettingsPoBatch: TformSettingsPoBatch;

const
  ColorBevel = $00D9D9D9;
  ColorBevelDark = $00555555;
  Default = 'default';

  {%Region -fold Resource Strings}

resourcestring
  rdefaultsettings = 'Are you sure you want to restore default settings?';
  rdefaultfont = 'Default';

  rproxymodenoproxy = 'No Proxy';
  rproxymodesystemproxy = 'System Proxy';
  rproxymodecustomproxy = 'Custom Proxy';

  ruserparameterkey = 'Name';
  ruserparametervalue = 'Value';

  rtmstoragetitle = 'Select translation memory folder';
  rtmimporttitle = 'Import translation memory';
  rtmexporttitle = 'Export translation memory';
  rtmimportfilter = 'Translation memory (*.zip;*.txt)|*.zip;*.txt|Zip archives (*.zip)|*.zip|Text files (*.txt)|*.txt';
  rtmexportfilter = 'Zip archives (*.zip)|*.zip';
  rtmimportdone = 'Imported %d language pair(s).';
  rtmexportdone = 'Exported %d language pair(s).';
  rtmcompacttitle = 'Compact translation memory';
  rtmcompactconfirm = 'Rebuild the selected %d language pair(s)?'#13#10'Entries that no longer match the current filters (length, multi-line) will be removed.';
  rtmcompactdone = 'Compacted %d language pair(s).';
  rtmimporterror = 'Cannot import file: %s';
  rtmexportnothing = 'No language pairs selected.';
  rtmcleartitle = 'Clear translation memory';
  rtmclearconfirm = 'Delete the selected %d language pair(s)?'#13#10'This action cannot be undone.';
  rtmclearalldone = 'Deleted %d language pair(s).';
  rtminvalidpair = 'Cannot determine language pair from "%s". Expected format: "xx-yy".';
  rtmreaderror = 'Cannot read archive: %s';
  rtmstatssource = 'Source';
  rtmstatstarget = 'Target';
  rtmstatsentries = 'Entries';
  rtmstatssize = 'Size';
  rtmstatsmodified = 'Modified';
  rtmstatstotal = 'Total';

  {%EndRegion}

implementation

uses MainUnit, DarkUtils, ControlsHelper, StringsHelper, OSUtils, PoTM;

  {$R *.lfm}

  { TformSettingsPoBatch }

  {%Region -fold Form Events}

procedure TformSettingsPoBatch.FormCreate(Sender: TObject);
begin
  PanelPages.BevelColor := TDarkUtils.ThemeColor(ColorBevel, ColorBevelDark);
  PagesSettings.PageIndex := 0;
  BtnCancel.Cancel := True;
  BtnReset.Enabled := True;
  FApplySettings := False;
  FOldValueList := string.Empty;

  ClbProxiedConfigs.SetComposited(True);

  FOriginalUserParameters := TStringList.Create;
  FOriginalProxiedConfigs := TStringList.Create;
  FTmFileNames := TStringList.Create;

  // Wire change events for TM controls so Apply is enabled when they change
  CheckTmEnabled.OnChange := @SettingChange;
  CheckTmAutoPopulateOnSave.OnChange := @SettingChange;
  CheckSkipTmMultiLineStrings.OnChange := @SettingChange;
  EditButtonTmStorage.OnChange := @SettingChange;
  SpinTmMaxSourceLength.OnChange := @SettingChange;

  // Configure the stats grid columns; column 0 holds row numbers and is
  // left empty, the remaining columns hold the archive metadata. The first
  // two rows are fixed: row 0 is the header and row 1 holds the total
  GridTmStorage.ColCount := 6;
  GridTmStorage.FixedCols := 1;
  GridTmStorage.FixedRows := 2;
  GridTmStorage.RowCount := GridTmStorage.FixedRows;
  GridTmStorage.Cells[0, 0] := '';
  GridTmStorage.Cells[1, 0] := rtmstatssource;
  GridTmStorage.Cells[2, 0] := rtmstatstarget;
  GridTmStorage.Cells[3, 0] := rtmstatsentries;
  GridTmStorage.Cells[4, 0] := rtmstatssize;
  GridTmStorage.Cells[5, 0] := rtmstatsmodified;
  GridTmStorage.Cells[0, 1] := '';
  GridTmStorage.Cells[1, 1] := rtmstatstotal;
  GridTmStorage.Cells[2, 1] := '0';
  GridTmStorage.Cells[3, 1] := '0';
  GridTmStorage.Cells[4, 1] := '';
  GridTmStorage.Cells[5, 1] := '';
  GridTmStorage.ColWidths[0] := 30;
  GridTmStorage.ColWidths[1] := 60;
  GridTmStorage.ColWidths[2] := 60;
  GridTmStorage.ColWidths[3] := 60;
  GridTmStorage.ColWidths[4] := 80;
  GridTmStorage.ColWidths[5] := 110;
  GridTmStorage.FixedColor := TDarkUtils.ThemeColor(clLightGray, clLightGrayDark);
  GridTmStorage.FixedGridLineColor := TDarkUtils.ThemeColor(clLine, clLineDark);
  GridTmStorage.GridLineColor := TDarkUtils.ThemeColor(clLine, clLineDark);

  FillConfigs;
  Reset;
  FillListPages;
  FillUserParameters;
  FillProxyMode;

  Screen.OnActiveControlChange := @ScreenActiveControlChanged;
end;

procedure TformSettingsPoBatch.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FOriginalUserParameters);
  FreeAndNil(FOriginalProxiedConfigs);
  FreeAndNil(FTmFileNames);
end;

procedure TformSettingsPoBatch.FormShow(Sender: TObject);
begin
  Self.FitToScreen;
  FillTmStats;
end;

procedure TformSettingsPoBatch.FormResize(Sender: TObject);
begin
  formPoBatch.FormSettingsWidth := Width;
  formPoBatch.FormSettingsHeight := Height;
end;

procedure TformSettingsPoBatch.FormChangeBounds(Sender: TObject);
begin
  formPoBatch.FormSettingsLeft := Left;
  formPoBatch.FormSettingsTop := Top;
end;

{%EndRegion}

{%Region -fold Screen Events}

procedure TformSettingsPoBatch.ScreenActiveControlChanged(Sender: TObject);
begin
  if FApplySettings then Exit;

  // Save focus only if it is not a button or a cell editor
  if (Screen.ActiveControl <> nil) and (not (Screen.ActiveControl is TButton)) and
    (not (Screen.ActiveControl is TStringCellEditor)) then
    FLastFocused := Screen.ActiveControl;
end;

{%EndRegion}

{%Region -fold Events}

procedure TformSettingsPoBatch.SettingChange(Sender: TObject);
begin
  if ApplySettings then exit;

  BtnApply.Enabled := True;

  if (Sender is TSpinEdit) then
  begin
    if (Sender as TSpinEdit).Value < 0 then
      (Sender as TSpinEdit).Value := 0;
  end;

  if Sender = CheckProxyAuthentication then
    SetState
  else
  if Sender = ComboProxyMode then
    SetState;
end;

procedure TformSettingsPoBatch.ListPagesClick(Sender: TObject);
begin
  // Synchronize PageControl with the selected list item
  if (ListPages.ItemIndex >= 0) and (ListPages.ItemIndex < PagesSettings.PageCount) then
  begin
    PagesSettings.ActivePageIndex := ListPages.ItemIndex;
  end;
end;

procedure TformSettingsPoBatch.EditProxyHostKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  s, ip: string;
  port: word;
begin
  // Check for paste shortcut: Ctrl+V or Shift+Insert
  if ((Key = VK_V) and (ssCtrl in Shift)) or ((Key = VK_INSERT) and (Shift = [ssShift])) then
  begin
    if ((EditProxyHost.Text = string.empty) or (EditProxyHost.SelLength = Length(EditProxyHost.Text))) and
      Clipboard.HasFormat(CF_TEXT) then
    begin
      s := Trim(Clipboard.AsText);
      if s.TryParseIPPort(ip, port) then
      begin
        // Replace the current selection with IP only
        EditProxyHost.SelText := ip;
        SpinProxyPort.Value := port;
        if SpinProxyPort.CanFocus then
        begin
          SpinProxyPort.SetFocus;
          SpinProxyPort.SelStart := Length(SpinProxyPort.Text);
        end;
        // Mark the key as handled so default paste does not occur
        Key := 0;
      end;
    end;
    // If it is not an IP:PORT string, the normal paste will happen
  end;
end;

procedure TformSettingsPoBatch.BtnDefaultClick(Sender: TObject);
begin
  if MessageDlg(rdefaultsettings, mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;

  // Reset to standard defaults for the remaining settings
  SpinConnectTimeout.Value := 10;
  SpinRequestTimeout.Value := 10;
  ComboProxyMode.ItemIndex := 0;
  ComboProxyType.ItemIndex := 0;
  EditProxyHost.Text := string.Empty;
  SpinProxyPort.Value := 0;
  CheckProxyAuthentication.Checked := False;
  EditProxyLogin.Text := string.Empty;
  EditProxyPassword.Text := string.Empty;
  EditTranslatorName.Text := string.Empty;
  EditTranslatorEmail.Text := string.Empty;
  ValueListUserParameters.Strings.Clear;
  CheckRememberLastFile.Checked := True;
  CheckSwitchToTable.Checked := True;
  CheckShowSuccess.Checked := True;

  // Translation memory defaults
  CheckTmEnabled.Checked := True;
  CheckTmAutoPopulateOnSave.Checked := True;
  CheckSkipTmMultiLineStrings.Checked := True;
  EditButtonTmStorage.Text := TOS.GetSettingsDirectory('pobatch', 'TranslationMemory');
  SpinTmMaxSourceLength.Value := 100;

  PanelFont.Font.SetDefault;
  SetPanelFont(PanelFont, PanelFont.Font);

  Apply;
end;

procedure TformSettingsPoBatch.BtnOkClick(Sender: TObject);
begin
  Visible := False;
  Apply;
  ModalResult := mrOk;
  Close;
end;

procedure TformSettingsPoBatch.BtnCancelClick(Sender: TObject);
begin
  Visible := False;
  Reset;
  ModalResult := mrCancel;
  Close;
end;

procedure TformSettingsPoBatch.BtnApplyClick(Sender: TObject);
var
  r, c: integer;
begin
  ValueListUserParameters.Options := ValueListUserParameters.Options - [goEditing];
  r := ValueListUserParameters.Row;
  c := ValueListUserParameters.Col;
  try
    if Assigned(FLastFocused) and FLastFocused.Visible and FLastFocused.CanFocus and FLastFocused.CanSetFocus then
      FLastFocused.SetFocus;

    Apply;
  finally
    ValueListUserParameters.Row := r;
    ValueListUserParameters.Col := c;
    ValueListUserParameters.Options := ValueListUserParameters.Options + [goEditing];
  end;
end;

procedure TformSettingsPoBatch.ValueListUserParametersSelectEditor(Sender: TObject; aCol, aRow: integer; var Editor: TWinControl);
begin
  FOldValueList := ValueListUserParameters.Cells[aCol, aRow];
end;

procedure TformSettingsPoBatch.ValueListUserParametersKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  ValueList: TValueListEditor;
  CurrentRow: integer;
begin
  if (Key = VK_DELETE) and (ssCtrl in Shift) then
  begin
    ValueList := Sender as TValueListEditor;

    Key := 0; // Block default processing

    // Safety check: row index must be valid
    if (ValueList.Row < ValueList.FixedRows) or (ValueList.Row >= ValueList.RowCount) then
      Exit;

    CurrentRow := ValueList.Row;

    // Don't delete fixed rows or the last data row
    if (ValueList.RowCount <= ValueList.FixedRows + 1) or (CurrentRow < ValueList.FixedRows) then
      Exit;

    // Move selection to a safe row before deleting (avoids dangling editor)
    if CurrentRow > ValueList.FixedRows then
      ValueList.Row := CurrentRow - 1
    else
      ValueList.Row := ValueList.FixedRows;

    // Now safe to delete
    ValueList.DeleteRow(CurrentRow);
  end;
end;

procedure TformSettingsPoBatch.ValueListUserParametersKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Sender as TValueListEditor).EditorMode and (ValueListUserParameters.Cells[ValueListUserParameters.Col,
    ValueListUserParameters.Row] <> FOldValueList) then
    BtnApply.Enabled := True;
end;

procedure TformSettingsPoBatch.ValueListUserParametersColRowDeleted(Sender: TObject; IsColumn: boolean; sIndex, tIndex: integer);
begin
  BtnApply.Enabled := True;
end;

procedure TformSettingsPoBatch.ValueListUserParametersColRowInserted(Sender: TObject; IsColumn: boolean; sIndex, tIndex: integer);
begin
  BtnApply.Enabled := True;
end;

procedure TformSettingsPoBatch.ClbProxiedConfigsMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: integer;
  MousePos: TPoint; var Handled: boolean);
var
  Lines: integer;
begin
  // Get system wheel scroll setting (usually 3 lines, or -1 for full page)
  Lines := Mouse.WheelScrollLines;
  if Lines = -1 then
    Lines := ClbProxiedConfigs.Items.Count;

  // Scroll the list manually
  if WheelDelta > 0 then
    ClbProxiedConfigs.TopIndex := Max(0, ClbProxiedConfigs.TopIndex - Lines)
  else
    ClbProxiedConfigs.TopIndex := Min(ClbProxiedConfigs.Items.Count - 1, ClbProxiedConfigs.TopIndex + Lines);

  Handled := True; // Block parent ScrollBox
end;

procedure TformSettingsPoBatch.ComboMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: integer;
  MousePos: TPoint; var Handled: boolean);
var
  SB: TScrollBox;
begin
  // Find the parent ScrollBox
  if (Sender as TWinControl).Parent.Parent is TScrollBox then
  begin
    SB := TScrollBox((Sender as TWinControl).Parent.Parent);
    // WheelDelta > 0 means scroll up (decrease position), so we subtract it
    SB.VertScrollBar.Position := SB.VertScrollBar.Position - WheelDelta div 2;
  end;

  Handled := True; // Prevent the ComboBox from processing the wheel itself
end;

procedure TformSettingsPoBatch.SplitterPagesMoved(Sender: TObject);
begin
  formPoBatch.FormSettingsSplit := ListPages.Width;
end;

procedure TformSettingsPoBatch.ListPagesDrawItem(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
var
  ListBox: TListBox;
  ImgY: integer;
  TextOffset: integer;
  TextRect: TRect;
  TextStyle: TTextStyle;
begin
  ListBox := Control as TListBox;

  // Draw item background
  ListBox.Canvas.FillRect(ARect);

  TextOffset := 4;

  // Calculate vertical centering for the image
  ImgY := ARect.Top + (ARect.Height - ImagesPages.Height) div 2;

  // Draw image if index is valid
  if (Index >= 0) and (Index < ImagesPages.Count) then
  begin
    ImagesPages.Draw(ListBox.Canvas, ARect.Left + TextOffset, ImgY, Index);
  end;

  // Prepare text rectangle
  TextRect := ARect;
  TextRect.Left := ARect.Left + ImagesPages.Width + (TextOffset * 2);
  TextRect.Right := ARect.Right - TextOffset;

  // Configure text style for LCL (Lazarus)
  TextStyle := ListBox.Canvas.TextStyle;
  TextStyle.Wordbreak := True;
  TextStyle.SingleLine := False;
  TextStyle.Layout := tlCenter;

  // Draw wrapped text
  ListBox.Canvas.Brush.Style := bsClear;
  ListBox.Canvas.TextRect(TextRect, TextRect.Left, TextRect.Top, ListBox.Items[Index], TextStyle);
end;

procedure TformSettingsPoBatch.ClbProxiedConfigsDrawItem(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
var
  Bmp: TBitmap;
  IconIdx: integer;
  Images: TImageList;
begin
  // Prepare optional icon
  Bmp := nil;
  Images := nil;
  if Assigned(formPoBatch.ConfigManager) then
    Images := formPoBatch.ConfigManager.Images;
  if Assigned(Images) and Assigned(formPoBatch.ConfigManager.ConfigImages) and (Index < formPoBatch.ConfigManager.ConfigImages.Count) then
  begin
    IconIdx := formPoBatch.ConfigManager.ConfigImages.ValueFromIndex[Index].ToInteger;
    if (IconIdx >= 0) and (IconIdx < Images.Count) then
    begin
      Bmp := TBitmap.Create;
      Images.GetBitmap(IconIdx, Bmp);
      Bmp.Transparent := True;
      Bmp.TransparentColor := clWhite;
    end;
  end;

  try
    // Draw the whole item using the helper method
    ClbProxiedConfigs.DrawCheckListItem(
      ARect,
      State,
      ClbProxiedConfigs.Checked[Index],
      ClbProxiedConfigs.Enabled,
      ClbProxiedConfigs.Focused,
      ClbProxiedConfigs.Color,
      ClbProxiedConfigs.Font.Color,
      ClbProxiedConfigs.Items[Index],
      Bmp,
      TDarkUtils.IsDarkMode);
  finally
    if Assigned(Bmp) then
      Bmp.Free;
  end;
end;

procedure TformSettingsPoBatch.BtnFontClick(Sender: TObject);
begin
  FontDialog.Font.Assign(PanelFont.Font);
  if FontDialog.Execute then
  begin
    PanelFont.Font.Assign(FontDialog.Font);
    SetPanelFont(PanelFont, FontDialog.Font);

    BtnReset.Enabled := True;
    BtnApply.Enabled := True;
  end;
end;

procedure TformSettingsPoBatch.BtnResetClick(Sender: TObject);
begin
  PanelFont.Font.SetDefault;
  PanelFont.Font.Color := TDarkUtils.ThemeColor(clBlack, clWhite);
  SetPanelFont(PanelFont, PanelFont.Font);
  SettingChange(Self);
end;

procedure TformSettingsPoBatch.EditButtonTmStorageButtonClick(Sender: TObject);
var
  DirDialog: TSelectDirectoryDialog;
begin
  DirDialog := TSelectDirectoryDialog.Create(nil);
  try
    DirDialog.Title := rtmstoragetitle;
    if DirectoryExists(EditButtonTmStorage.Text) then
      DirDialog.InitialDir := EditButtonTmStorage.Text
    else if Assigned(formPoBatch.TM) and DirectoryExists(formPoBatch.TM.Directory) then
      DirDialog.InitialDir := formPoBatch.TM.Directory;
    if DirDialog.Execute then
    begin
      EditButtonTmStorage.Text := DirDialog.FileName;
      SettingChange(Sender);
      // Show the contents of the newly picked folder immediately,
      // without waiting for Apply
      FillTmStats;
    end;
  finally
    DirDialog.Free;
  end;
end;

procedure TformSettingsPoBatch.MenuTmClearSelectedClick(Sender: TObject);
var
  Files: TStringList;
  I: integer;
begin
  Files := TStringList.Create;
  try
    GetTmSelectedFiles(Files);
    if Files.Count = 0 then
    begin
      ShowMessage(rtmexportnothing);
      Exit;
    end;

    if MessageDlg(rtmcleartitle, Format(rtmclearconfirm, [Files.Count]), mtConfirmation, mbYesNo, 0) <> mrYes then
      Exit;

    for I := 0 to Files.Count - 1 do
      DeleteFile(Files[I]);

    FillTmStats;
    ShowMessageFmt(rtmclearalldone, [Files.Count]);
  finally
    Files.Free;
  end;
end;

procedure TformSettingsPoBatch.MenuTmCompactSelectedClick(Sender: TObject);
var
  Files: TStringList;
  I, DotPos, Compacted: integer;
  BaseName, Src, Tgt: string;
  TempTM: TPoTranslationMemory;
begin
  if not Assigned(formPoBatch.TM) then
    Exit;

  Files := TStringList.Create;
  try
    GetTmSelectedFiles(Files);
    if Files.Count = 0 then
    begin
      ShowMessage(rtmexportnothing);
      Exit;
    end;

    if MessageDlg(rtmcompacttitle, Format(rtmcompactconfirm, [Files.Count]), mtConfirmation, mbYesNo, 0) <> mrYes then
      Exit;

    Compacted := 0;
    Screen.Cursor := crHourGlass;
    try
      for I := 0 to Files.Count - 1 do
      begin
        BaseName := ChangeFileExt(ExtractFileName(Files[I]), '');
        DotPos := Pos('-', BaseName);
        if DotPos <= 1 then
          Continue;
        Src := Copy(BaseName, 1, DotPos - 1);
        Tgt := Copy(BaseName, DotPos + 1, MaxInt);

        TempTM := TPoTranslationMemory.Create;
        try
          TempTM.Directory := GetTmDirectory;
          TempTM.SourceLang := Src;
          TempTM.TargetLang := Tgt;
          // ContextSensitive has no UI toggle, so keep the applied value
          if Assigned(formPoBatch.TM) then
            TempTM.ContextSensitive := formPoBatch.TM.ContextSensitive
          else
            TempTM.ContextSensitive := True;
          TempTM.MaxSourceLength := SpinTmMaxSourceLength.Value;
          TempTM.SkipMultiline := CheckSkipTmMultiLineStrings.Checked;
          TempTM.Enabled := True;
          TempTM.Load;
          TempTM.Compact;
          TempTM.Save;
          Inc(Compacted);
        finally
          TempTM.Free;
        end;
      end;
    finally
      Screen.Cursor := crDefault;
    end;

    FillTmStats;
    if Compacted > 0 then
      ShowMessageFmt(rtmcompactdone, [Compacted]);
  finally
    Files.Free;
  end;
end;

procedure TformSettingsPoBatch.MenuTmExportSelectedClick(Sender: TObject);
var
  Files, Entries: TStringList;
  SaveDialog: TSaveDialog;
  ArcName: string;
  I: integer;
  Stream: TMemoryStream;
begin
  Files := TStringList.Create;
  try
    GetTmSelectedFiles(Files);
    if Files.Count = 0 then
    begin
      ShowMessage(rtmexportnothing);
      Exit;
    end;

    SaveDialog := TSaveDialog.Create(nil);
    try
      SaveDialog.Title := rtmexporttitle;
      SaveDialog.Filter := rtmexportfilter;
      SaveDialog.Options := SaveDialog.Options + [ofOverwritePrompt];
      SaveDialog.DefaultExt := 'zip';
      SaveDialog.FileName := 'pobatch-tm-' + FormatDateTime('yyyy-mm-dd', Now) + '.zip';
      if not SaveDialog.Execute then
        Exit;

      // Extract each archive's .txt content into memory, then pack them
      // into a single export archive without touching the file system
      Entries := TStringList.Create;
      try
        for I := 0 to Files.Count - 1 do
        begin
          ArcName := ChangeFileExt(ExtractFileName(Files[I]), '.txt');
          Stream := nil;
          if TOS.UnZipFileToStream(Files[I], ArcName, Stream) then
            Entries.AddObject(ArcName, Stream)
          else
            Stream.Free;
        end;

        if Entries.Count = 0 then
        begin
          ShowMessage(rtmexportnothing);
          Exit;
        end;

        if TOS.ZipListToFile(Entries, SaveDialog.FileName) then
          ShowMessageFmt(rtmexportdone, [Entries.Count])
        else
          ShowMessageFmt(rtmreaderror, [SaveDialog.FileName]);
      finally
        for I := 0 to Entries.Count - 1 do
          TMemoryStream(Entries.Objects[I]).Free;
        Entries.Free;
      end;
    finally
      SaveDialog.Free;
    end;
  finally
    Files.Free;
  end;
end;

procedure TformSettingsPoBatch.MenuTmImportClick(Sender: TObject);
var
  Dialog: TOpenDialog;
  Entries: TStringList;
  I, DotPos, ImportedCount: integer;
  BaseName, Src, Tgt: string;
  Lines: TStringList;
  Stream: TMemoryStream;
begin
  if not Assigned(formPoBatch.TM) then
    Exit;

  Dialog := TOpenDialog.Create(nil);
  try
    Dialog.Title := rtmimporttitle;
    Dialog.Filter := rtmimportfilter;
    Dialog.FilterIndex := 1;
    if not Dialog.Execute then
      Exit;

    ImportedCount := 0;
    Screen.Cursor := crHourGlass;
    try
      if SameText(ExtractFileExt(Dialog.FileName), '.txt') then
      begin
        // Single .txt file: derive the language pair from its name
        BaseName := ChangeFileExt(ExtractFileName(Dialog.FileName), '');
        DotPos := Pos('-', BaseName);
        if DotPos <= 1 then
        begin
          Screen.Cursor := crDefault;
          ShowMessageFmt(rtminvalidpair, [ExtractFileName(Dialog.FileName)]);
          Exit;
        end;
        Src := Copy(BaseName, 1, DotPos - 1);
        Tgt := Copy(BaseName, DotPos + 1, MaxInt);
        Lines := TStringList.Create;
        try
          try
            Lines.LoadFromFile(Dialog.FileName, TEncoding.UTF8);
            ImportTmFromLines(Lines, Src, Tgt);
            ImportedCount := 1;
          except
            on E: Exception do
            begin
              Screen.Cursor := crDefault;
              ShowMessageFmt(rtmimporterror, [E.Message]);
              Exit;
            end;
          end;
        finally
          Lines.Free;
        end;
      end
      else if SameText(ExtractFileExt(Dialog.FileName), '.zip') then
      begin
        // Zip archive: extract every .txt entry via the TOS helper
        Entries := TStringList.Create;
        try
          if not TOS.UnZipFileToList(Dialog.FileName, '.txt', Entries) then
          begin
            Screen.Cursor := crDefault;
            ShowMessageFmt(rtmreaderror, [Dialog.FileName]);
            Exit;
          end;

          for I := 0 to Entries.Count - 1 do
          begin
            BaseName := ChangeFileExt(Entries[I], '');
            DotPos := Pos('-', BaseName);
            if DotPos <= 1 then
              Continue;
            Src := Copy(BaseName, 1, DotPos - 1);
            Tgt := Copy(BaseName, DotPos + 1, MaxInt);
            Stream := TMemoryStream(Entries.Objects[I]);
            Stream.Position := 0;
            Lines := TStringList.Create;
            try
              Lines.LoadFromStream(Stream, TEncoding.UTF8);
              ImportTmFromLines(Lines, Src, Tgt);
              Inc(ImportedCount);
            finally
              Lines.Free;
            end;
          end;
        finally
          for I := 0 to Entries.Count - 1 do
            TMemoryStream(Entries.Objects[I]).Free;
          Entries.Free;
        end;
      end
      else
      begin
        Screen.Cursor := crDefault;
        ShowMessage('Unsupported file type.');
        Exit;
      end;
    finally
      Screen.Cursor := crDefault;
    end;

    FillTmStats;
    if ImportedCount > 0 then
      ShowMessageFmt(rtmimportdone, [ImportedCount]);
  finally
    Dialog.Free;
  end;
end;

procedure TformSettingsPoBatch.MenuTmRefreshClick(Sender: TObject);
begin
  FillTmStats;
end;

procedure TformSettingsPoBatch.MenuTmSelectAllClick(Sender: TObject);
var
  LastDataRow: integer;
begin
  if not Assigned(FTmFileNames) or (FTmFileNames.Count = 0) then
    Exit;

  // Exclude the total summary row, which is always the last row in the grid
  LastDataRow := GridTmStorage.FixedRows + FTmFileNames.Count - 1;
  GridTmStorage.Selection := TGridRect.Create(GridTmStorage.FixedCols, GridTmStorage.FixedRows, GridTmStorage.ColCount - 1, LastDataRow);

  if GridTmStorage.CanFocus then
    GridTmStorage.SetFocus;
end;

procedure TformSettingsPoBatch.GridTmStorageKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  // Ctrl+A selects every data row, mirroring the popup menu entry
  if (Key = Ord('A')) and (ssCtrl in Shift) then
  begin
    MenuTmSelectAllClick(Sender);
    Key := 0;
  end;
end;

procedure TformSettingsPoBatch.GridTmStorageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  Col, Row, DataRow: integer;
  AFileName: string;
begin
  // Respond only to a left-button double click
  if (Button <> mbLeft) or not (ssDouble in Shift) then
    Exit;
  if not Assigned(FTmFileNames) or (FTmFileNames.Count = 0) then
    Exit;

  GridTmStorage.MouseToCell(X, Y, Col, Row);
  if Row < GridTmStorage.FixedRows then
    Exit;

  // The last row is the total summary and has no backing file
  DataRow := Row - GridTmStorage.FixedRows;
  if (DataRow < 0) or (DataRow >= FTmFileNames.Count) then
    Exit;

  AFileName := FTmFileNames[DataRow];
  if FileExists(AFileName) then
    TOS.ShowFileInExplorer(AFileName);
end;

{%EndRegion}

{%Region -fold Methods}

procedure TformSettingsPoBatch.SetPanelFont(Panel: TPanel; const AFont: TFont);
var
  CaptionText: string;
begin
  if (Trim(AFont.Name) = string.Empty) or (LowerCase(AFont.Name) = default) then
    CaptionText := rdefaultfont
  else
    CaptionText := AFont.Name;
  Panel.Caption := CaptionText + ',' + IntToStr(AFont.Size);
end;

function TformSettingsPoBatch.FormatFileSize(ASize: int64): string;
begin
  if ASize < 1024 then
    Result := IntToStr(ASize) + ' B'
  else if ASize < 1024 * 1024 then
    Result := FormatFloat('#,##0.0', ASize / 1024) + ' KB'
  else
    Result := FormatFloat('#,##0.0', ASize / 1024 / 1024) + ' MB';
end;

procedure TformSettingsPoBatch.GetTmSelectedFiles(AList: TStrings);
var
  I, Row: integer;
begin
  AList.Clear;
  if not Assigned(FTmFileNames) then
    Exit;

  if GridTmStorage.Selection.Top = GridTmStorage.Selection.Bottom then
  begin
    Row := GridTmStorage.Row;
    if (Row >= GridTmStorage.FixedRows) and (Row - GridTmStorage.FixedRows < FTmFileNames.Count) then
      AList.Add(FTmFileNames[Row - GridTmStorage.FixedRows]);
  end
  else
  begin
    for I := GridTmStorage.Selection.Top to GridTmStorage.Selection.Bottom do
      if (I >= GridTmStorage.FixedRows) and (I - GridTmStorage.FixedRows < FTmFileNames.Count) then
        AList.Add(FTmFileNames[I - GridTmStorage.FixedRows]);
  end;
end;

function TformSettingsPoBatch.GetTmDirectory: string;
begin
  // Actions inside this dialog always operate on the path currently shown
  // in the editor, even before Apply moves it into the main form's TM object
  Result := Trim(EditButtonTmStorage.Text);
  if Result = '' then
    Result := TOS.GetSettingsDirectory('pobatch', 'TranslationMemory');
end;

procedure TformSettingsPoBatch.FillTmStats;
var
  SearchRec: TSearchRec;
  Dir, FileName, BaseName, Src, Tgt: string;
  DotPos, DataRow: integer;
  TotalEntries: int64;
  TotalSize, SingleSize: int64;
  EntryCount: integer;
  Lines: TStringList;
  Stream: TMemoryStream;
begin
  // Reset the grid to just the two fixed rows: header (0) and total (1)
  GridTmStorage.RowCount := GridTmStorage.FixedRows;
  FTmFileNames.Clear;
  TotalEntries := 0;
  TotalSize := 0;

  Dir := GetTmDirectory;
  if (Dir <> '') and DirectoryExists(Dir) then
  begin
    // Collect every .zip archive in the storage folder
    if FindFirst(IncludeTrailingPathDelimiter(Dir) + '*.zip', faAnyFile, SearchRec) = 0 then
    try
      repeat
        if (SearchRec.Name = '.') or (SearchRec.Name = '..') then
          Continue;
        if (SearchRec.Attr and faDirectory) <> 0 then
          Continue;
        FTmFileNames.Add(IncludeTrailingPathDelimiter(Dir) + SearchRec.Name);
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;

    FTmFileNames.Sort;

    // Fill one grid row per archive and accumulate totals
    for DataRow := 0 to FTmFileNames.Count - 1 do
    begin
      FileName := FTmFileNames[DataRow];
      BaseName := ChangeFileExt(ExtractFileName(FileName), '');
      DotPos := Pos('-', BaseName);
      if DotPos > 1 then
      begin
        Src := Copy(BaseName, 1, DotPos - 1);
        Tgt := Copy(BaseName, DotPos + 1, MaxInt);
      end
      else
      begin
        Src := BaseName;
        Tgt := '';
      end;

      GridTmStorage.RowCount := GridTmStorage.RowCount + 1;
      GridTmStorage.Cells[1, DataRow + GridTmStorage.FixedRows] := Src;
      GridTmStorage.Cells[2, DataRow + GridTmStorage.FixedRows] := Tgt;

      // Count entries by reading the .txt inside the archive
      EntryCount := 0;
      Stream := nil;
      try
        if TOS.UnZipFileToStream(FileName, BaseName + '.txt', Stream) then
        begin
          Lines := TStringList.Create;
          try
            Lines.LoadFromStream(Stream, TEncoding.UTF8);
            EntryCount := Lines.Count;
          finally
            Lines.Free;
          end;
        end;
      finally
        Stream.Free;
      end;
      GridTmStorage.Cells[3, DataRow + GridTmStorage.FixedRows] := IntToStr(EntryCount);
      Inc(TotalEntries, EntryCount);

      // Size and modification time from the file system
      SingleSize := FileUtil.FileSize(FileName);
      TotalSize := TotalSize + SingleSize;
      GridTmStorage.Cells[4, DataRow + GridTmStorage.FixedRows] := FormatFileSize(SingleSize);
      GridTmStorage.Cells[5, DataRow + GridTmStorage.FixedRows] :=
        FormatDateTime('yyyy-mm-dd hh:nn', FileDateToDateTime(FileAge(FileName)));
    end;
  end;

  // Total summary lives in the second fixed row, so it stays visible while
  // the user scrolls through the data rows below it
  GridTmStorage.Cells[1, 1] := rtmstatstotal;
  GridTmStorage.Cells[2, 1] := IntToStr(FTmFileNames.Count);
  GridTmStorage.Cells[3, 1] := IntToStr(TotalEntries);
  GridTmStorage.Cells[4, 1] := FormatFileSize(TotalSize);
  GridTmStorage.Cells[5, 1] := '';
end;

procedure TformSettingsPoBatch.ImportTmFromLines(ALines: TStrings; const ASourceLang, ATargetLang: string);
var
  TempTM: TPoTranslationMemory;
  Dir: string;
begin
  Dir := GetTmDirectory;
  if (Dir = '') or (ASourceLang = '') or (ATargetLang = '') then
    Exit;

  // Use a temporary instance so the currently active pair in the main
  // form is not disturbed by the import
  TempTM := TPoTranslationMemory.Create;
  try
    TempTM.Directory := Dir;
    TempTM.SourceLang := ASourceLang;
    TempTM.TargetLang := ATargetLang;
    TempTM.ContextSensitive := formPoBatch.TM.ContextSensitive;
    // Import bypasses the filters: we want everything that is in the file
    TempTM.MaxSourceLength := 0;
    TempTM.SkipMultiline := False;
    TempTM.Enabled := True;

    TempTM.Load;
    TempTM.ImportFromStrings(ALines);
    if TempTM.Dirty then
      TempTM.Save;
  finally
    TempTM.Free;
  end;
end;

procedure TformSettingsPoBatch.FillListPages;
var
  i: integer;
begin
  if PagesSettings.ShowTabs then
    PagesSettings.ShowTabs := False;
  ListPages.Clear;
  for i := 0 to PagesSettings.PageCount - 1 do
    ListPages.Items.Add(PagesSettings.Pages[i].Caption);
  ListPages.ItemIndex := PagesSettings.PageIndex;
end;

procedure TformSettingsPoBatch.FillUserParameters;
begin
  ValueListUserParameters.TitleCaptions.Clear;
  ValueListUserParameters.TitleCaptions.Add(ruserparameterkey);
  ValueListUserParameters.TitleCaptions.Add(ruserparametervalue);
end;

procedure TformSettingsPoBatch.FillProxyMode;
var
  SavedIndex: integer;
begin
  // Save current selection
  SavedIndex := ComboProxyMode.ItemIndex;

  ComboProxyMode.Items.Clear;
  ComboProxyMode.Items.Add(rproxymodenoproxy);
  ComboProxyMode.Items.Add(rproxymodesystemproxy);
  ComboProxyMode.Items.Add(rproxymodecustomproxy);

  // Restore selection safely
  if (SavedIndex >= 0) and (SavedIndex < ComboProxyMode.Items.Count) then
    ComboProxyMode.ItemIndex := SavedIndex
  else
    ComboProxyMode.ItemIndex := Ord(formPoBatch.Translate.Proxy.Mode);
end;

procedure TformSettingsPoBatch.FillConfigs;
var
  i: integer;
  Item, Path: string;
begin
  ClbProxiedConfigs.Items.Clear;
  for i := 0 to formPoBatch.ConfigManager.ConfigFiles.Count - 1 do
  begin
    Path := formPoBatch.ConfigManager.ConfigFiles[i];
    Item := formPoBatch.ConfigManager.ConfigTitles.Values[Path];
    ClbProxiedConfigs.Checked[ClbProxiedConfigs.Items.Add(Item)] := formPoBatch.ConfigManager.ProxiedConfigs.Contains(Path);
  end;
end;

procedure TformSettingsPoBatch.SetState;
begin
  // Proxy
  LabelProxyType.Enabled := ComboProxyMode.ItemIndex > 1;
  ComboProxyType.Enabled := LabelProxyType.Enabled;
  LabelHost.Enabled := LabelProxyType.Enabled;
  EditProxyHost.Enabled := LabelProxyType.Enabled;
  LabelPort.Enabled := LabelProxyType.Enabled;
  SpinProxyPort.Enabled := LabelProxyType.Enabled;
  ClbProxiedConfigs.Enabled := ComboProxyMode.ItemIndex > 0;

  // Proxy Auth
  CheckProxyAuthentication.Enabled := ComboProxyMode.ItemIndex > 1;
  EditProxyLogin.Enabled := CheckProxyAuthentication.Checked and (ComboProxyMode.ItemIndex > 1);
  EditProxyPassword.Enabled := EditProxyLogin.Enabled;
  LabelLogin.Enabled := EditProxyLogin.Enabled;
  LabelPassword.Enabled := EditProxyLogin.Enabled;
end;

procedure TformSettingsPoBatch.Apply;
var
  T: TTranslateTimeout;
  P: TTranslateProxy;
  i: integer;
begin
  FApplySettings := True;
  ValueListUserParameters.EditingDone;
  try
    formPoBatch.Translate.UserParameters.Assign(ValueListUserParameters.Strings);

    formPoBatch.ConfigManager.ProxiedConfigs.Clear;
    for i := 0 to ClbProxiedConfigs.Count - 1 do
      if ClbProxiedConfigs.Checked[i] and (i < formPoBatch.ConfigManager.ConfigFiles.Count) then
        formPoBatch.ConfigManager.ProxiedConfigs.Add(formPoBatch.ConfigManager.ConfigFiles[i]);

    T := formPoBatch.Translate.Timeout;
    T.Connection := SpinConnectTimeout.Value * 1000;
    T.Request := SpinRequestTimeout.Value * 1000;
    formPoBatch.Translate.Timeout := T;

    P := formPoBatch.Translate.Proxy;
    P.Mode := TProxyMode(ComboProxyMode.ItemIndex);
    P.Type_ := TProxyType(ComboProxyType.ItemIndex);
    P.Host := EditProxyHost.Text;
    P.Port := SpinProxyPort.Value.ToString;
    P.Authentication := CheckProxyAuthentication.Checked;
    P.Login := EditProxyLogin.Text;
    P.Password := EditProxyPassword.Text;
    formPoBatch.Translate.Proxy := P;

    formPoBatch.TranslatorName := EditTranslatorName.Text;
    formPoBatch.TranslatorEmail := EditTranslatorEmail.Text;
    formPoBatch.RememberLastFile := CheckRememberLastFile.Checked;
    formPoBatch.SwitchToTable := CheckSwitchToTable.Checked;
    formPoBatch.ShowSuccess := CheckShowSuccess.Checked;

    formPoBatch.ApplyFont(PanelFont.Font);

    // Apply translation memory settings
    if Assigned(formPoBatch.TM) then
    begin
      // Change the storage folder only when the path actually differs;
      // pending changes must be flushed to the old folder first
      if (Trim(EditButtonTmStorage.Text) <> '') and (ExcludeTrailingPathDelimiter(EditButtonTmStorage.Text) <>
        ExcludeTrailingPathDelimiter(formPoBatch.TM.Directory)) then
      begin
        if formPoBatch.TM.Dirty then
        begin
          try
            formPoBatch.TM.Save;
          except
            // Ignore save errors; the in-memory data stays intact
          end;
        end;
        formPoBatch.TM.Directory := Trim(EditButtonTmStorage.Text);
        try
          formPoBatch.TM.Load;
        except
          // Ignore load errors; the memory starts empty
        end;
      end;

      formPoBatch.TM.MaxSourceLength := SpinTmMaxSourceLength.Value;
      formPoBatch.TM.SkipMultiline := CheckSkipTmMultiLineStrings.Checked;
      formPoBatch.TMEnabled := CheckTmEnabled.Checked;
    end;
    formPoBatch.TMAutoPopulateOnSave := CheckTmAutoPopulateOnSave.Checked;

    Reset;
  finally
    FApplySettings := False;
  end;
end;

procedure TformSettingsPoBatch.Reset;
var
  i: integer;
begin
  FOriginalProxy := formPoBatch.Translate.Proxy;
  FOriginalTimeout := formPoBatch.Translate.Timeout;
  FOriginalUserParameters.Assign(formPoBatch.Translate.UserParameters);
  FOriginalProxiedConfigs.Assign(formPoBatch.ConfigManager.ProxiedConfigs);
  FOriginalFont := formPoBatch.Font;
  FOriginalRememberLastFile := formPoBatch.RememberLastFile;
  FOriginalSwitchToTable := formPoBatch.SwitchToTable;
  FOriginalShowSuccess := formPoBatch.ShowSuccess;
  FOriginalTranslatorName := formPoBatch.TranslatorName;
  FOriginalTranslatorEmail := formPoBatch.TranslatorEmail;

  // Snapshot translation memory settings
  if Assigned(formPoBatch.TM) then
  begin
    FOriginalTmEnabled := formPoBatch.TM.Enabled;
    FOriginalTmStorage := formPoBatch.TM.Directory;
    FOriginalTmMaxSourceLength := formPoBatch.TM.MaxSourceLength;
    FOriginalTmSkipMultiline := formPoBatch.TM.SkipMultiline;
  end
  else
  begin
    FOriginalTmEnabled := True;
    FOriginalTmStorage := TOS.GetSettingsDirectory('pobatch', 'TranslationMemory');
    FOriginalTmMaxSourceLength := 100;
    FOriginalTmSkipMultiline := True;
  end;
  FOriginalTmAutoPopulateOnSave := formPoBatch.TMAutoPopulateOnSave;

  SpinConnectTimeout.Value := FOriginalTimeout.Connection div 1000;
  SpinRequestTimeout.Value := FOriginalTimeout.Request div 1000;
  ComboProxyMode.ItemIndex := Ord(FOriginalProxy.Mode);
  ComboProxyType.ItemIndex := Ord(FOriginalProxy.Type_);
  EditProxyHost.Text := FOriginalProxy.Host;
  SpinProxyPort.Value := StrToIntDef(FOriginalProxy.Port, 0);
  CheckProxyAuthentication.Checked := FOriginalProxy.Authentication;
  EditProxyLogin.Text := FOriginalProxy.Login;
  EditProxyPassword.Text := FOriginalProxy.Password;
  EditTranslatorName.Text := FOriginalTranslatorName;
  EditTranslatorEmail.Text := FOriginalTranslatorEmail;
  CheckRememberLastFile.Checked := FOriginalRememberLastFile;
  CheckSwitchToTable.Checked := FOriginalSwitchToTable;
  CheckShowSuccess.Checked := FOriginalShowSuccess;

  for i := 0 to ClbProxiedConfigs.Count - 1 do
    if formPoBatch.ConfigManager.ConfigFiles.Count > i then
      ClbProxiedConfigs.Checked[i] := FOriginalProxiedConfigs.Contains(formPoBatch.ConfigManager.ConfigFiles[i]);

  ValueListUserParameters.Strings.Assign(FOriginalUserParameters);

  PanelFont.Font.Assign(FOriginalFont);
  SetPanelFont(PanelFont, FOriginalFont);

  // Restore translation memory fields to their snapshots
  CheckTmEnabled.Checked := FOriginalTmEnabled;
  CheckTmAutoPopulateOnSave.Checked := FOriginalTmAutoPopulateOnSave;
  CheckSkipTmMultiLineStrings.Checked := FOriginalTmSkipMultiline;
  EditButtonTmStorage.Text := FOriginalTmStorage;
  SpinTmMaxSourceLength.Value := FOriginalTmMaxSourceLength;

  // Redraw the grid for the restored path; Apply and Cancel both end up
  // here, so the visible stats always match the current storage setting
  FillTmStats;

  BtnApply.Enabled := False;
  SetState;
end;

{%EndRegion}

end.
