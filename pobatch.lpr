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
  Localize,
  ConsoleOp,
  Consts;

  {$R *.res}

  {$IFDEF WINDOWS}
  procedure InitConsole;
  var
    StdHandle: THandle;
    OutHandle: THandle;
    ErrorHandle: THandle;
    HandleType: DWORD;
  begin
    // Preserve redirected standard handles supplied by the parent process
    OutHandle := GetStdHandle(STD_OUTPUT_HANDLE);
    ErrorHandle := GetStdHandle(STD_ERROR_HANDLE);

    if (OutHandle <> 0) and (OutHandle <> INVALID_HANDLE_VALUE) then
    begin
      HandleType := GetFileType(OutHandle);

      if HandleType <> FILE_TYPE_UNKNOWN then
      begin
        IsConsole := True;
        StdInputHandle := GetStdHandle(STD_INPUT_HANDLE);
        StdOutputHandle := OutHandle;
        StdErrorHandle := ErrorHandle;
        SysInitStdIO;
        Exit;
      end;
    end;

    // Attach to the parent console when launched from cmd.exe
    if AttachConsole(ATTACH_PARENT_PROCESS) then
    begin
      IsConsole := True;
      StdInputHandle := GetStdHandle(STD_INPUT_HANDLE);
      StdOutputHandle := GetStdHandle(STD_OUTPUT_HANDLE);
      StdErrorHandle := GetStdHandle(STD_ERROR_HANDLE);
      SysInitStdIO;
      Exit;
    end;

    // No parent console or redirected output - send stdio to NUL
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
  Language := TLocalize.GetOSLanguage;
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
  TLocalize.ApplicationTranslate(APP_NAME, Language, nil, TLocalize.LoadCustomPoFile(Localize.CustomPoFile));
  TLocalize.UpdatePackageTranslations(APP_NAME, 'checkupdates', Language, ['CheckUpdates']);
  Application.Run;
end.
