//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit FormAbout;

{$mode ObjFPC}{$H+}

interface

uses
  Forms,
  StdCtrls,
  ExtCtrls,
  Classes,
  Graphics,
  LCLIntf;

type

  { TformAboutPoBatch }

  TformAboutPoBatch = class(TForm)
    buttonOk: TButton;
    imageLogo: TImage;
    Label1: TLabel;
    labelBy: TLabel;
    labelName: TLabel;
    labelLic: TLabel;
    LabelLicUrl: TLabel;
    LabelUrlGithub: TLabel;
    Memo1: TMemo;
    labelVersion: TLabel;
    panelHeader: TPanel;
    panelBody: TPanel;
    panelFooter: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure LabelLicUrlClick(Sender: TObject);
  private
  public
  end;

var
  formAboutPoBatch: TformAboutPoBatch;

implementation

uses CheckUpdates, DarkUtils;

  {$R *.lfm}

  { TformAboutPoBatch }

procedure TformAboutPoBatch.FormCreate(Sender: TObject);
var
  Arch: string;
begin
  {$IFDEF CPU64}
    Arch := 'x64';
  {$ELSE}
    Arch := 'x86';
  {$ENDIF}

  labelName.Caption    := 'PoBatch © 2026';
  labelVersion.Caption := 'Version ' + GetAppVersion + ' · ' + Arch;

  // Links: color within the theme
  LabelLicUrl.Font.Color    := TDarkUtils.ThemeColor(clBlue, clSkyBlue);
  LabelUrlGithub.Font.Color := LabelLicUrl.Font.Color;

  // Panels: light/dark theme adaptation
  panelHeader.Color       := TDarkUtils.ThemeColor(16315632, $002D2D2D);
  panelBody.Color         := TDarkUtils.ThemeColor(clWhite, $001E1E1E);
  labelVersion.Font.Color := TDarkUtils.ThemeColor(clGray, clSilver);
  panelFooter.Color       := panelBody.Color;
  Memo1.Color             := panelBody.Color;
end;

procedure TformAboutPoBatch.LabelLicUrlClick(Sender: TObject);
begin
  OpenUrl((Sender as TLabel).Hint);
end;

end.