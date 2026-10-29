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
  Themes,
  Spin,
  Math,
  Grids,
  ValEdit,
  CheckLst,
  LCLType,
  LCLIntf,
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
    BtnOk: TButton;
    CheckProxyAuthentication: TCheckBox;
    ClbProxiedConfigs: TCheckListBox;
    ComboProxyMode: TComboBox;
    ComboProxyType: TComboBox;
    EditProxyHost: TEdit;
    EditProxyLogin: TEdit;
    EditProxyPassword: TEdit;
    EditTranslatorName: TEdit;
    EditTranslatorEmail: TEdit;
    GroupDefaultInformation: TGroupBox;
    GroupProxiedConfigs: TGroupBox;
    GroupUserParameters: TGroupBox;
    GroupTimeouts: TGroupBox;
    GroupProxy: TGroupBox;
    ImagesPages: TImageList;
    LabelConnectTimeout: TLabel;
    LabelTranslatorName: TLabel;
    LabelTranslatorEmail: TLabel;
    LabelProxyMode: TLabel;
    LabelProxyType: TLabel;
    LabelHost: TLabel;
    LabelPort: TLabel;
    LabelLogin: TLabel;
    LabelPassword: TLabel;
    LabelRequestTimeout: TLabel;
    ListPages: TListBox;
    PagesSettings: TPageControl;
    PanelPages: TPanel;
    PanelBottom: TPanel;
    PageGeneral: TTabSheet;
    ScrollNetwork: TScrollBox;
    SpinRequestTimeout: TSpinEdit;
    SpinConnectTimeout: TSpinEdit;
    SpinProxyPort: TSpinEdit;
    SplitterPages: TSplitter;
    PageNetwork: TTabSheet;
    PageParameters: TTabSheet;
    ValueListUserParameters: TValueListEditor;
    procedure FormChangeBounds(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
    FOriginalProxy: TTranslateProxy;
    FOriginalTimeout: TTranslateTimeout;
    FOriginalUserParameters: TStringList;
    FOriginalProxiedConfigs: TStringList;

    FApplySettings: boolean;
    FOldValueList: string;
    FLastFocused: TWinControl;
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

  {%Region -fold Resource Strings}

resourcestring
  rdefaultsettings = 'Are you sure you want to restore default settings?';

  rproxymodenoproxy = 'No Proxy';
  rproxymodesystemproxy = 'System Proxy';
  rproxymodecustomproxy = 'Custom Proxy';

  ruserparameterkey = 'Name';
  ruserparametervalue = 'Value';

  {%EndRegion}

implementation

uses MainUnit, DarkUtils, ControlsHelper, StringsHelper;

  {$R *.lfm}

  { TformSettingsPoBatch }

  {%Region -fold Form Events}

procedure TformSettingsPoBatch.FormCreate(Sender: TObject);
begin
  PanelPages.BevelColor := TDarkUtils.ThemeColor(ColorBevel, ColorBevelDark);
  PagesSettings.PageIndex := 0;
  BtnCancel.Cancel := True;
  FApplySettings := False;
  FOldValueList := string.Empty;

  ClbProxiedConfigs.SetComposited(True);

  FOriginalUserParameters := TStringList.Create;
  FOriginalProxiedConfigs := TStringList.Create;

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
end;

procedure TformSettingsPoBatch.FormShow(Sender: TObject);
begin
  Self.FitToScreen;
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

{%EndRegion}

{%Region -fold Methods}

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

  SpinConnectTimeout.Value := FOriginalTimeout.Connection div 1000;
  SpinRequestTimeout.Value := FOriginalTimeout.Request div 1000;
  ComboProxyMode.ItemIndex := Ord(FOriginalProxy.Mode);
  ComboProxyType.ItemIndex := Ord(FOriginalProxy.Type_);
  EditProxyHost.Text := FOriginalProxy.Host;
  SpinProxyPort.Value := StrToIntDef(FOriginalProxy.Port, 0);
  CheckProxyAuthentication.Checked := FOriginalProxy.Authentication;
  EditProxyLogin.Text := FOriginalProxy.Login;
  EditProxyPassword.Text := FOriginalProxy.Password;
  EditTranslatorName.Text := formPoBatch.TranslatorName;
  EditTranslatorEmail.Text := formPoBatch.TranslatorEmail;

  for i := 0 to ClbProxiedConfigs.Count - 1 do
    if formPoBatch.ConfigManager.ConfigFiles.Count > i then
      ClbProxiedConfigs.Checked[i] := FOriginalProxiedConfigs.Contains(formPoBatch.ConfigManager.ConfigFiles[i]);

  ValueListUserParameters.Strings.Assign(FOriginalUserParameters);

  BtnApply.Enabled := False;
  SetState;
end;

{%EndRegion}

end.
