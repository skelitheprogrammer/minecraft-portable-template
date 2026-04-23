@echo off
setlocal enabledelayedexpansion

echo ========================================
echo  Minecraft PortableMC Bootstrapper
echo ========================================
echo.

set "TARGET_DIR=%AppData%\.minecraft\portablemc"

REM ----- Check if already installed -----
if exist "%TARGET_DIR%\create_profile.bat" (
    echo Environment already exists at: %TARGET_DIR%
    echo To reinstall from scratch, delete or rename that folder first.
    echo.
    set /p "run_creator=Do you want to run the profile creator anyway? (Y/N): "
    if /i "!run_creator!"=="Y" (
        cd /d "%TARGET_DIR%"
        call create_profile.bat
    ) else (
        echo Exiting.
    )
    pause
    exit /b 0
)

echo Installing to: %TARGET_DIR%
echo.

REM Create target directory if it doesn't exist
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
    if errorlevel 1 (
        echo Failed to create directory. Exiting.
        pause
        exit /b 1
    )
)

REM Move into target directory
cd /d "%TARGET_DIR%"
if errorlevel 1 (
    echo Failed to change to target directory.
    pause
    exit /b 1
)

REM Download the repository archive
echo Downloading repository...
curl -L -o master.zip https://github.com/skelitheprogrammer/minecraft-portable-template/archive/refs/heads/master.zip
if errorlevel 1 (
    echo Download failed.
    pause
    exit /b 1
)

REM Extract directly into current folder
echo Extracting files...
tar -xf master.zip --strip-components=1
if errorlevel 1 (
    echo Extraction failed.
    pause
    exit /b 1
)

REM Clean up
del master.zip

echo.
echo Bootstrap complete! Files installed to %TARGET_DIR%
echo.

REM Run the profile creation script
echo Creating a modpack profile...
call create_profile.bat

pause
