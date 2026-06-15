//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the MIT License
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//-----------------------------------------------------------------------------------

program pobatch;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  mainunit,
  formabout,
  formdonate
  {$IFDEF WINDOWS}
  ,uDarkStyle
  ,uWin32WidgetSetDark, formattool
  {$ENDIF}
  ;

  {$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title:='PoBatch';
  Application.Scaled:=True;
  {$PUSH}
  {$WARN 5044 OFF}
  Application.MainFormOnTaskbar := True;
  {$POP}
  Application.Initialize;
  {$IFDEF WINDOWS}
  ApplyDarkStyle;
  {$ENDIF}
  Application.CreateForm(TformPoBatch, formPoBatch);
  Application.CreateForm(TformAboutPoBatch, formAboutPoBatch);
  Application.CreateForm(TformDonatePoBatch, formDonatePoBatch);
  Application.Run;
end.
