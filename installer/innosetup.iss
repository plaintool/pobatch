#define MyAppName      "PoBatch"

// --- Version resolving ---
#ifndef MyVersion
  #define FileHandle FileOpen("..\VERSION")
  #if FileHandle
    #define MyVersion Trim(FileRead(FileHandle))
    #expr FileClose(FileHandle)
  #else
    #define MyVersion "0.0.0"
  #endif
#endif

#define MyAppVersion   MyVersion
#define MyAppPublisher "Alexander Tverskoy"
#define MyAppURL       "https://github.com/plaintool/pobatch"
#define MyAppExeName   "pobatch"
#define CurrentYear    GetDateTimeString('yyyy','','')

[Setup]
AppId={{D1E4B5C2-8F9A-4B6D-AB12-3F7C9E4D8A21}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}

VersionInfoDescription={#MyAppName} installer
VersionInfoProductName={#MyAppName}
VersionInfoVersion={#MyAppVersion}

AppCopyright={#CurrentYear} {#MyAppPublisher}

AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

UninstallDisplayName={#MyAppName} {#MyAppVersion}
UninstallDisplayIcon={app}\pobatch.exe

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

[Languages]
Name: "arabic";     MessagesFile: "compiler:Languages\Arabic.isl"
Name: "belarusian"; MessagesFile: "compiler:Languages\Belarusian.isl"
Name: "chinese";    MessagesFile: "compiler:Languages\ChineseSimplified.isl"
Name: "czech";      MessagesFile: "compiler:Languages\Czech.isl"
Name: "danish";     MessagesFile: "compiler:Languages\Danish.isl"
Name: "dutch";      MessagesFile: "compiler:Languages\Dutch.isl"
Name: "english";    MessagesFile: "compiler:Default.isl"
Name: "finnish";    MessagesFile: "compiler:Languages\Finnish.isl"
Name: "french";     MessagesFile: "compiler:Languages\French.isl"
Name: "german";     MessagesFile: "compiler:Languages\German.isl"
Name: "greek";      MessagesFile: "compiler:Languages\Greek.isl"
Name: "hebrew";     MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "hindi";      MessagesFile: "compiler:Languages\Hindi.isl"
Name: "indonesian"; MessagesFile: "compiler:Languages\Indonesian.isl"
Name: "italian";    MessagesFile: "compiler:Languages\Italian.isl"
Name: "japanese";   MessagesFile: "compiler:Languages\Japanese.isl"
Name: "korean";     MessagesFile: "compiler:Languages\Korean.isl"
Name: "polish";     MessagesFile: "compiler:Languages\Polish.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "romanian";   MessagesFile: "compiler:Languages\Romanian.isl"
Name: "russian";    MessagesFile: "compiler:Languages\Russian.isl"
Name: "spanish";    MessagesFile: "compiler:Languages\Spanish.isl"
Name: "swedish";    MessagesFile: "compiler:Languages\Swedish.isl"
Name: "turkish";    MessagesFile: "compiler:Languages\Turkish.isl"
Name: "ukrainian";  MessagesFile: "compiler:Languages\Ukrainian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
#ifexist "..\pobatch.exe"
; 64-bit
Source: "..\{#MyAppExeName}.exe"; DestDir: "{app}"; DestName: "{#MyAppExeName}.exe"; Check: Is64BitInstallMode; Flags: ignoreversion
;Source: "..\libcrypto-1_1-x64.dll"; DestDir: "{app}"; Check: Is64BitInstallMode; Flags: ignoreversion
;Source: "..\libssl-1_1-x64.dll"; DestDir: "{app}"; Check: Is64BitInstallMode; Flags: ignoreversion
#endif

#ifexist "..\{#MyAppExeName}32.exe"
; 32-bit
Source: "..\#MyAppExeName}32.exe"; DestDir: "{app}"; DestName: "{#MyAppExeName}32.exe"; Check: not Is64BitInstallMode; Flags: ignoreversion
;Source: "..\libcrypto-1_1.dll"; DestDir: "{app}"; Check: not Is64BitInstallMode; Flags: ignoreversion
;Source: "..\libssl-1_1.dll"; DestDir: "{app}"; Check: not Is64BitInstallMode; Flags: ignoreversion
#endif
; License
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}.exe"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}.exe"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
