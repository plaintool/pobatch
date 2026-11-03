#define MyAppName      "PoBatch"

// --- Version resolving ---
#define MyAppExeName       "pobatch.exe"
#define MyAppVersion()     GetVersionComponents("..\" + MyAppExeName, Local[0], Local[1], Local[2], Local[3]), str(Local[0]) + "." + str(Local[1]) + "." + str(Local[2])
#define MyAppPublisher     "Alexander Tverskoy"
#define MyAppURL           "https://github.com/plaintool/pobatch"
#define MyAppExeName32     "pobatch32.exe"
#define CopyrightStartYear "2026"
#define CurrentYear         GetDateTimeString('yyyy','','')

[Setup]
AppId={{D1E4B5C2-8F9A-4B6D-AB12-3F7C9E4D8A21}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}

VersionInfoDescription={#MyAppName} installer
VersionInfoProductName={#MyAppName}
VersionInfoVersion={#MyAppVersion}

#if CurrentYear == CopyrightStartYear
  AppCopyright={#CurrentYear} {#MyAppPublisher}
#else
  AppCopyright={#CopyrightStartYear}-{#CurrentYear} {#MyAppPublisher}
#endif

AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}

RestartApplications=no

ShowLanguageDialog=yes
UsePreviousLanguage=no
LanguageDetectionMethod=uilanguage

LicenseFile=.\LICENSE.rtf

WizardStyle=modern

SetupIconFile=..\pobatch.ico
WizardSmallImageFile=.\wizardsmallimagefile.png

DefaultDirName={autopf}\{#MyAppName}
ArchitecturesAllowed=x64compatible x86
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=.\
OutputBaseFilename=pobatch-{#MyAppVersion}-any-x86-x64
Compression=lzma
SolidCompression=yes

#include "innosetup_languages.iss"

[Registry]
;Registry data for PoBatch .po association
Root: HKA; Subkey: "Software\Classes\.po"; ValueType: string; ValueName: ""; ValueData: "PoBatch"; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\.po\ShellNew"; ValueType: string; ValueName: "NullFile"; ValueData: ""
;Registry data for PoBatch .pot association
Root: HKA; Subkey: "Software\Classes\.pot"; ValueType: string; ValueName: ""; ValueData: "PoBatch"; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\.pot\ShellNew"; ValueType: string; ValueName: "NullFile"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\PoBatch"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\PoBatch"; ValueType: string; ValueName: ""; ValueData: "PoBatch PO File"; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\PoBatch\DefaultIcon"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\PoBatch\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\pobatch.exe,1"; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\PoBatch\shell"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\PoBatch\shell\open"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\PoBatch\shell\open\command"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\PoBatch\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\pobatch.exe"" ""%1"""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\PoBatch\ShellNew"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\pobatch.exe"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\pobatch.exe\shell"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\pobatch.exe\shell\open"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\pobatch.exe\shell\open\command"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\pobatch.exe\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\pobatch.exe"" ""%1"""; Flags: uninsdeletevalue
;End of registry data for PoBatch

[Code]

procedure KillPoBatch();
var
  ResultCode: Integer;
begin
  Exec(
    ExpandConstant('{sys}\taskkill.exe'),
    '/F /IM pobatch.exe /T',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  );
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
    KillPoBatch();
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
    KillPoBatch();
end;


[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
#ifexist "..\" + MyAppExeName
; 64-bit
Source: "..\{#MyAppExeName}"; DestDir: "{app}"; DestName: "{#MyAppExeName}"; Check: Is64BitInstallMode; Flags: ignoreversion
Source: "..\libcrypto-3-x64.dll"; DestDir: "{app}"; Check: Is64BitInstallMode; Flags: ignoreversion
Source: "..\libssl-3-x64.dll"; DestDir: "{app}"; Check: Is64BitInstallMode; Flags: ignoreversion
#endif

#ifexist "..\" + MyAppExeName32
; 32-bit
Source: "..\{#MyAppExeName32}"; DestDir: "{app}"; DestName: "{#MyAppExeName}"; Check: not Is64BitInstallMode; Flags: ignoreversion
Source: "..\libcrypto-1_1.dll"; DestDir: "{app}"; Check: not Is64BitInstallMode; Flags: ignoreversion
Source: "..\libssl-1_1.dll"; DestDir: "{app}"; Check: not Is64BitInstallMode; Flags: ignoreversion
#endif
; License
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
; Config files
Source: "..\config\deepl.ini"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "..\config\google-get-apis.ini"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "..\config\google-get-clients5.ini"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "..\config\google-post.ini"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "..\config\google-webtran.ini"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "..\config\laratranslate.ini"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "..\config\LLM7-ai-api.ini"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "..\config\microsofttranslator.ini"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "..\config\mymemory.ini"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "..\config\reverso.ini"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "..\config\yandex.ini"; DestDir: "{app}\config"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent