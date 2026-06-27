//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit formabout;

{$mode ObjFPC}{$H+}

interface

uses
  Forms,
  StdCtrls,
  ExtCtrls,
  LCLIntf, Classes;

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
    procedure FormCreate(Sender: TObject);
    procedure LabelLicUrlClick(Sender: TObject);
  private
  public
  end;

var
  formAboutPoBatch: TformAboutPoBatch;

implementation

uses systemtool;

  {$R *.lfm}

  { TformAboutPoBatch }

procedure TformAboutPoBatch.FormCreate(Sender: TObject);
begin
  labelName.Caption := 'PoBatch © ' + GetAppVersion;
end;

procedure TformAboutPoBatch.LabelLicUrlClick(Sender: TObject);
begin
  OpenUrl((Sender as TLabel).Hint);
end;

end.
