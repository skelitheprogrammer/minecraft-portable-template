@echo off
setlocal enabledelayedexpansion

REM Get the profile name (the folder where this script lives)
for %%I in ("%~dp0.") do set "PROFILE_NAME=%%~nxI"

REM Path to portablemc executable (relative from profile folder)
set "PORTABLEMC_EXE=%~dp0..\..\portablemc-exe\portablemc.exe"
if not exist "%PORTABLEMC_EXE%" (
    echo portablemc.exe not found at %PORTABLEMC_EXE%
    pause
    exit /b 1
)

REM Config file is in the same folder
set "CONFIG_FILE=%~dp0config.json"
if not exist "%CONFIG_FILE%" (
    echo config.json not found in profile folder.
    pause
    exit /b 1
)

REM Extract values from config.json
for /f "usebackq delims=" %%A in (`
    powershell -NoProfile -Command "$c = Get-Content '%CONFIG_FILE%' -Raw | ConvertFrom-Json; Write-Output ('USERNAME=' + $c.username); Write-Output ('MODLOADER=' + $c.modloader); Write-Output ('JAVA_ARGS=' + $c.javaArgs)"
`) do set "%%A"

if "%USERNAME%"=="" (
    echo Failed to read username from config.json
    pause
    exit /b 1
)

REM Split JAVA_ARGS into multiple --jvm-arg options
set "JVM_ARGS_SPLIT="
if not "%JAVA_ARGS%"=="" (
    for %%a in (%JAVA_ARGS%) do (
        set "JVM_ARGS_SPLIT=!JVM_ARGS_SPLIT! --jvm-arg=%%a"
    )
)

echo Starting Minecraft with profile: %PROFILE_NAME%
"%PORTABLEMC_EXE%" start --main-dir "..\..\main" --mc-dir "." !JVM_ARGS_SPLIT! -u "%USERNAME%" "%MODLOADER%"

if errorlevel 1 (
    echo Launch failed.
    pause
    exit /b 1
)

echo Done.
pause
