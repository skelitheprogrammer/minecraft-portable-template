[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null
Set-Location $PSScriptRoot 

$profileName = Split-Path (Get-Location) -Leaf
$portableExe = Resolve-Path "..\..\portablemc-exe\portablemc.exe" -ErrorAction SilentlyContinue
if (-not $portableExe) {
    Write-Host "portablemc.exe not found. Please run the wizard first."
    pause; exit 1
}

$configFile = ".\config.json"
if (-not (Test-Path $configFile)) {
    Write-Host "config.json not found in profile folder."
    pause; exit 1
}

$config = Get-Content $configFile -Raw | ConvertFrom-Json
$username = $config.username
$modloader = $config.modloader
$javaArgs = $config.javaArgs

if (-not $username) {
    Write-Host "username missing in config.json"
    pause; exit 1
}

$jvmArgs = @()
if ($javaArgs) { $jvmArgs = $javaArgs -split ' ' | ForEach-Object { "--jvm-arg=$_" } }

Write-Host "Starting Minecraft with profile: $profileName"

& $portableExe start --main-dir "..\..\main" --mc-dir "." $jvmArgs -u $username $modloader 2>&1 | ForEach-Object { Write-Host $_ }

if ($LASTEXITCODE -ne 0) {
    Write-Host "Launch failed (exit code: $LASTEXITCODE)."
    pause; exit 1
}

Write-Host "Minecraft closed. Exiting."
