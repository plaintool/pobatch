@echo off
setlocal

SET INNO-SETUP-PATH=C:\Program Files (x86)\Inno Setup 6
SET SIGN-TOOL-PATH=C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64

echo.
echo ############################################################
echo #                Build InnoSetup installer                 #
echo ############################################################
echo.

:: Define paths
SET "SOURCE_DIR=%~dp0"
SET "VERSION=%VERSION%"
IF "%~2" NEQ "" (
    SET "VERSION=%~2"
)
IF "%VERSION%"=="" (
    FOR /F "usebackq delims=" %%i IN ("%SOURCE_DIR%..\VERSION") DO SET "VERSION=%%i"
)

SET OUTPUT-FILE=pobatch-%VERSION%-x86-x64-installer.exe

:: --- Build inno setup ---
"%INNO-SETUP-PATH%\ISCC.exe" "%SOURCE_DIR%\innosetup.iss"
echo.
echo File created: %OUTPUT-FILE%
echo.

echo.
echo ############################################################
echo #                Sign InnoSetup installer                  #
echo ############################################################
echo.

::Wait 2 seconds to ensure file is free
ping 127.0.0.1 -n 3 >nul

:: --- Sign installers ---
IF "%SIGNTOOL%"=="" (
    SET "SIGNTOOL=%SIGN-TOOL-PATH%\signtool.exe"
)
IF "%CERTFILE%"=="" (
    IF EXIST "%SOURCE_DIR%AlexanderT.pfx" (
        SET "CERTFILE=%SOURCE_DIR%AlexanderT.pfx"
    ) ELSE (
        IF NOT "%CERT_PFX%"=="" (
            SET "CERTFILE=%TEMP%\pobatch-cert.pfx"
            powershell -NoProfile -Command "[IO.File]::WriteAllBytes('%TEMP%\\pobatch-cert.pfx',[Convert]::FromBase64String($env:CERT_PFX))"
        ) ELSE (
            SET "CERTFILE="
        )
    )
)
SET "CERTPASS=1234"
::SET "TIMESTAMP_URL=http://timestamp.digicert.com"
SET "TIMESTAMP_URL=http://timestamp.sectigo.com"
::SET "TIMESTAMP_URL=http://ts.ssl.com"

if not "%CERTFILE%"=="" (
    if exist "%CERTFILE%" (
        if exist "%SIGNTOOL%" (
            echo Signing file...
            "%SIGNTOOL%" sign /f "%CERTFILE%" /p "%CERTPASS%" /fd SHA256 /tr %TIMESTAMP_URL% /td SHA256 "%SOURCE_DIR%\%OUTPUT-FILE%" < nul
            IF %ERRORLEVEL% EQU 0 (
                echo Signing of '%OUTPUT-FILE%' completed successfully
            ) else (
                echo Signing failed for '%OUTPUT-FILE%'
            )
        ) else (
            echo Skipping signing: signtool not found.
        )
    ) else (
        echo Skipping signing: cert file not found.
    )
) else (
    echo Skipping signing: CERTFILE not set.
)

echo.
echo Build and signing '%OUTPUT-FILE%' completed successfully!

endlocal


IF "%1" == "" (
   echo.
   echo.

   ECHO *** Press any key to exit ***
   pause >NUL
)
SET INNO-SETUP-PATH=
SET SIGN-TOOL-PATH=
