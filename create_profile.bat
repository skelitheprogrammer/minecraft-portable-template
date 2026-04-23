@echo off
setlocal enabledelayedexpansion

REM ----- Guard: ensure we are inside .minecraft\portablemc -----
for %%I in (.) do set "CURFOLDER=%%~nxI"
for %%I in (..) do set "PARENTFOLDER=%%~nxI"
if /i not "%CURFOLDER%"=="portablemc" goto :wrong_folder
if /i not "%PARENTFOLDER%"==".minecraft" goto :wrong_folder

echo ========================================
echo   Minecraft PortableMC Profile Creator
echo ========================================
echo.

REM ----- Get modpack name -----
set /p "PROFILE_NAME=Enter modpack name: "
if "!PROFILE_NAME!"=="" (
    echo No name entered. Exiting.
    exit /b 1
)

set "PROFILE_DIR=instances\!PROFILE_NAME!"

REM ----- Check if profile already exists -----
if exist "!PROFILE_DIR!" (
    echo.
    echo WARNING: Profile "!PROFILE_NAME!" already exists!
    echo Directory: !PROFILE_DIR!
    echo.
    echo Overwriting will DELETE all files inside that profile folder.
    echo.
    set /p "choice=Do you want to (S)kip, (O)verwrite, or (C)ancel? [S/O/C]: "
    if /i "!choice!"=="S" (
        echo Skipping profile creation. Exiting.
        exit /b 0
    )
    if /i "!choice!"=="O" (
        echo Deleting existing profile folder...
        rmdir /s /q "!PROFILE_DIR!"
        if errorlevel 1 (
            echo Failed to delete existing profile folder.
            pause
            exit /b 1
        )
        echo Existing profile removed.
    ) else (
        echo Cancelled by user. Exiting.
        exit /b 0
    )
)

REM ----- Get username -----
set /p "USERNAME=Enter Minecraft username: "
if "!USERNAME!"=="" (
    echo No username entered. Exiting.
    exit /b 1
)

REM ----- Get modloader version -----
echo Enter modloader version (e.g., fabric-0.15.11, forge-47.2.0):
set /p "MODLOADER=Modloader version: "
if "!MODLOADER!"=="" (
    echo No modloader version entered. Exiting.
    exit /b 1
)

REM ----- Get Java arguments -----
echo Enter Java arguments (e.g., -Xmx4G -XX:+UseG1GC):
set /p "JAVA_ARGS=Java args: "
if "!JAVA_ARGS!"=="" set "JAVA_ARGS=-Xmx2G"

echo.
echo Creating profile "!PROFILE_NAME!"...
echo.

REM ----- Ensure directories exist -----
if not exist "main" mkdir "main"
if not exist "instances" mkdir "instances"

REM Create fresh profile directory
mkdir "!PROFILE_DIR!"
if errorlevel 1 (
    echo Failed to create profile directory.
    pause
    exit /b 1
)

REM ----- Copy template files if template folder exists -----
if exist "template" (
    echo Copying template files to profile...
    xcopy "template\*" "!PROFILE_DIR!\" /E /I /Y >nul
)

REM ----- Create config.json inside profile -----
(
    echo {
    echo   "username": "!USERNAME!",
    echo   "modloader": "!MODLOADER!",
    echo   "javaArgs": "!JAVA_ARGS!"
    echo }
) > "!PROFILE_DIR!\config.json"
echo config.json created.

REM ----- Create portablemc-run.bat inside profile -----
(
    echo @echo off
    echo setlocal enabledelayedexpansion
    echo.
    echo REM Get the directory where this script resides ^(the profile folder^)
    echo set "SCRIPT_DIR=%%~dp0"
    echo.
    echo REM Read config.json using PowerShell
    echo set "CONFIG_FILE=%%SCRIPT_DIR%%config.json"
    echo if not exist "%%CONFIG_FILE%%" ^(
    echo     echo config.json not found in profile folder.
    echo     pause
    echo     exit /b 1
    echo ^)
    echo.
    echo REM Extract values from config.json
    echo for /f "usebackq delims=" %%%%A in ^(`
    echo     powershell -NoProfile -Command ^
    echo     "$c = Get-Content '%%CONFIG_FILE%%' -Raw ^| ConvertFrom-Json; ^
    echo     Write-Output ('USERNAME=' + $c.username); ^
    echo     Write-Output ('MODLOADER=' + $c.modloader); ^
    echo     Write-Output ('JAVA_ARGS=' + $c.javaArgs)"`
    echo `^) do set "%%%%A"
    echo.
    echo if "%%USERNAME%%"=="" ^(
    echo     echo Failed to read username from config.json
    echo     pause
    echo     exit /b 1
    echo ^)
    echo.
    echo REM Path to portablemc executable ^(adjust if needed^)
    echo set "PORTABLEMC_PATH=%%SCRIPT_DIR%%..\..\portablemc-exe\portablemc.exe"
    echo if not exist "%%PORTABLEMC_PATH%%" ^(
    echo     echo portablemc.exe not found at %%PORTABLEMC_PATH%%
    echo     pause
    echo     exit /b 1
    echo ^)
    echo.
    echo echo Starting Minecraft with profile: %%~n0
    echo "%%PORTABLEMC_PATH%%" start ^
    echo     --work-dir "%%SCRIPT_DIR%%" ^
    echo     --username "%%USERNAME%%" ^
    echo     --modloader "%%MODLOADER%%" ^
    echo     --java-args "%%JAVA_ARGS%%"
    echo.
    echo if errorlevel 1 ^(
    echo     echo Launch failed.
    echo     pause
    echo     exit /b 1
    echo ^)
    echo echo Done.
    echo pause
) > "!PROFILE_DIR!\portablemc-run.bat"

echo portablemc-run.bat created inside profile folder.
echo.
echo ========================================
echo Profile "!PROFILE_NAME!" created successfully!
echo.
echo To launch this profile, run:
echo   cd /d "!PROFILE_DIR!"
echo   portablemc-run.bat
echo ========================================
pause
exit /b 0

:wrong_folder
echo ERROR: This script must be run from inside the .minecraft\portablemc folder.
echo Current directory: %CD%
echo Please cd to your .minecraft\portablemc folder first.
pause
exit /b 1
