//-----------------------------------------------------------------------------------
//  Trayslate © 2026 by Alexander Tverskoy
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit formdonate;

{$mode ObjFPC}{$H+}

interface

uses
  Forms,
  Classes,
  StdCtrls,
  Buttons,
  Clipbrd,
  Graphics,
  LCLIntf, ExtCtrls;

type

  { TformDonatePoBatch }

  TformDonatePoBatch = class(TForm)
    BtnOk: TButton;
    ImageBank: TImage;
    ImageCrypto: TImage;
    LabelDonate: TLabel;
    LabelSupport: TLabel;
    LabelContribution: TLabel;
    labelBank: TLabel;
    labelCrypto: TLabel;
    procedure labelBankClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  formDonatePoBatch: TformDonatePoBatch;

implementation

uses darkutils;

  {$R *.lfm}

  { TformDonatePoBatch }

procedure TformDonatePoBatch.FormCreate(Sender: TObject);
begin
  labelBank.Font.Color := TDarkUtils.ThemeColor(clBlue, clSkyBlue);
  //labelCrypto.Font.Color := TDarkUtils.ThemeColor(clBlue, clSkyBlue);
  labelCrypto.Font.Color := TDarkUtils.ThemeColor(clBlue, clSkyBlue);
end;

procedure TformDonatePoBatch.labelBankClick(Sender: TObject);
begin
  OpenUrl((Sender as TLabel).Hint);
end;

end.
