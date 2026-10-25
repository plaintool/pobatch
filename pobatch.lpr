//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the MIT License
//  You may obtain a copy of the License at https://opensource.org/licenses/MIT
//-----------------------------------------------------------------------------------

program PoBatch;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  Interfaces,
  Forms,
  SysUtils,
  {$IFDEF WINDOWS}
  uDarkStyle,
  uWin32WidgetSetDark,
  {$ENDIF}
  MainUnit,
  FormAbout,
  FormDonate,
  ConsoleOp;

  {$R *.res}

  {$IFDEF WINDOWS}
procedure InitConsole;
var
  StdHandle: THandle;
begin
  // Attach to the parent console when launched from cmd.exe.
  // On failure (launch from Explorer), redirect stdio to NUL so that
  // WriteLn calls do not raise an exception in a GUI application.
  if AttachConsole(ATTACH_PARENT_PROCESS) then
  begin
    IsConsole := True;
    StdInputHandle := GetStdHandle(STD_INPUT_HANDLE);
    StdOutputHandle := GetStdHandle(STD_OUTPUT_HANDLE);
    StdErrorHandle := GetStdHandle(STD_ERROR_HANDLE);
    SysInitStdIO;
  end
  else
  begin
    // No parent console - send output to NUL to keep WriteLn harmless
    StdHandle := FileOpen('NUL', fmOpenReadWrite);
    if StdHandle <> THandle(-1) then
    begin
      StdInputHandle := StdHandle;
      StdOutputHandle := StdHandle;
      StdErrorHandle := StdHandle;
      IsConsole := True;
      SysInitStdIO;
    end;
  end;
end;
  {$ENDIF}

begin
  {$IFDEF DEBUG}
  GlobalSkipIfNoLeaks := True;
  {$ENDIF}

  // Help-only mode does not need the GUI toolkit at all
  if TConsoleOp.IsHelpOnly then
  begin
    {$IFDEF WINDOWS}
    InitConsole;
    {$ENDIF}
    TConsoleOp.PrintHelp;
    Halt(0);
  end;

  // Console command mode: run the operation without showing the form
  if TConsoleOp.IsConsoleMode then
  begin
    {$IFDEF WINDOWS}
    InitConsole;
    {$ENDIF}
    RequireDerivedFormResource := True;
    Application.Title := 'PoBatch';
    Application.Scaled := True;
    {$PUSH}
    {$WARN 5044 OFF}
    Application.MainFormOnTaskbar := True;
    {$POP}
    Application.Initialize;
    {$IFDEF WINDOWS}
    ApplyDarkStyle;
    {$ENDIF}
    Application.CreateForm(TformPoBatch, formPoBatch);
    ExitCode := TConsoleOp.Run(formPoBatch);
    Halt(ExitCode);
  end;

  // Normal GUI mode
  RequireDerivedFormResource := True;
  Application.Title := 'PoBatch';
  Application.Scaled := True;
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
