//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the MIT License
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//-----------------------------------------------------------------------------------

unit formabout;

{$mode ObjFPC}{$H+}

interface

uses
  Forms,
  StdCtrls,
  ExtCtrls,
  LCLIntf;

type

  { TformAboutPoBatch }

  TformAboutPoBatch = class(TForm)
    buttonOk: TButton;
    imageLogo: TImage;
    labelBy: TLabel;
    labelName: TLabel;
    labelLic: TLabel;
    LabelLicUrl: TLabel;
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
  OpenUrl(labelLicUrl.Hint);
end;

end.
