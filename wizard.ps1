[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null

Write-Host "========================================"
Write-Host " Minecraft PortableMC Bootstrapper"
Write-Host "========================================"
Write-Host ""

$targetDir = Join-Path $env:APPDATA ".minecraft\portablemc"

if (Test-Path $targetDir) {
    Write-Host "Environment already exists at: $targetDir"
    Write-Host "To reinstall from scratch, delete or rename that folder first."
    Write-Host ""
    $runCreator = Read-Host "Do you want to run the profile creator anyway? (Y/N)"
    if ($runCreator -eq "Y" -or $runCreator -eq "y") {
        Set-Location $targetDir
        & ".\create_profile.bat"
    } else {
        Write-Host "Exiting."
    }
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host "Installing to: $targetDir"
Write-Host ""

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

Set-Location $targetDir

Write-Host "Downloading repository..."
$zipUrl = "https://github.com/skelitheprogrammer/minecraft-portable-template/archive/refs/heads/master.zip"
$zipPath = Join-Path $targetDir "master.zip"

try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
} catch {
    Write-Host "Download failed: $_"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Extracting files..."
try {
    Expand-Archive -Path $zipPath -DestinationPath $targetDir -Force
    $extractedFolder = Get-ChildItem -Directory -Filter "minecraft-portable-template-master" | Select-Object -First 1
    if ($extractedFolder) {
        Get-ChildItem -Path $extractedFolder.FullName | Move-Item -Destination $targetDir -Force
        Remove-Item $extractedFolder.FullName -Force
    }
} catch {
    Write-Host "Extraction failed: $_"
    Read-Host "Press Enter to exit"
    exit 1
}

Remove-Item $zipPath -Force

Write-Host ""
Write-Host "Bootstrap complete! Files installed to $targetDir"
Write-Host ""

Write-Host "Creating a modpack profile..."
& ".\create_profile.ps1"

Read-Host "Press Enter to exit"
