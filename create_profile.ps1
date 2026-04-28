[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null

Write-Host "========================================"
Write-Host "  Minecraft PortableMC Profile Creator"
Write-Host "========================================"
Write-Host ""

do {
    $profileName = Read-Host "Enter modpack name (required)"
    if ([string]::IsNullOrWhiteSpace($profileName)) {
        Write-Host "No name entered. Exiting."
        exit 1
    }
    $profileDir = Join-Path "instances" $profileName

    if (Test-Path $profileDir) {
        Write-Host ""
        Write-Host "WARNING: Profile '$profileName' already exists!"
        Write-Host "Directory: $profileDir"
        Write-Host ""
        $choice = Read-Host "Do you want to (S)kip, (O)verwrite, or (C)ancel? [S/O/C]"
        switch ($choice.ToUpper()) {
            'S' { Write-Host "Skipping profile creation. Exiting."; exit 0 }
            'O' { 
                Write-Host "Deleting existing profile folder..."
                Remove-Item $profileDir -Recurse -Force -ErrorAction Stop
                Write-Host "Existing profile removed."
                break
            }
            default { Write-Host "Cancelled by user. Exiting."; exit 0 }
        }
    }
} while ($false)

do {
    $username = Read-Host "Enter Minecraft username (required)"
    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "No username entered. Exiting."
        exit 1
    }
} while ($false)

$defaultModloader = "neoforge::21.1.227"
Write-Host "Enter modloader version (default: $defaultModloader)"
Write-Host "Examples: fabric-0.15.11, forge-47.2.0, neoforge::21.1.227"
$modloader = Read-Host "Modloader version"
if ([string]::IsNullOrWhiteSpace($modloader)) {
    $modloader = $defaultModloader
    Write-Host "Using default modloader: $modloader"
}

$defaultJavaArgs = "-Xmx8G"
Write-Host ""
Write-Host "Java arguments control memory and performance settings."
$javaArgs = Read-Host "Enter Java arguments (default: $defaultJavaArgs) (e.g., -Xmx4G -XX:+UseG1GC)"
if ([string]::IsNullOrWhiteSpace($javaArgs)) {
    $javaArgs = $defaultJavaArgs
    Write-Host "Using default Java arguments: $javaArgs"
}

Write-Host ""
Write-Host "========================================"
Write-Host "Summary:"
Write-Host "  Profile name: $profileName"
Write-Host "  Username:     $username"
Write-Host "  Modloader:    $modloader"
Write-Host "  Java args:    $javaArgs"
Write-Host "========================================"
Write-Host ""
Write-Host "Creating profile '$profileName'..."
Write-Host ""

$null = New-Item -ItemType Directory -Force -Path "main"
$null = New-Item -ItemType Directory -Force -Path "instances"

$null = New-Item -ItemType Directory -Force -Path $profileDir

$templateDir = "template"
if (Test-Path $templateDir) {
    Write-Host "Copying template files to profile..."
    Copy-Item -Path "$templateDir\*" -Destination $profileDir -Recurse -Force
} else {
    Write-Host "WARNING: 'template' folder not found. No default files copied."
}

$config = @{
    username   = $username
    modloader  = $modloader
    javaArgs   = $javaArgs
}
$configJson = $config | ConvertTo-Json
$configPath = Join-Path $profileDir "config.json"
Set-Content -Path $configPath -Value $configJson -Encoding UTF8
Write-Host "config.json created."

Write-Host ""
Write-Host "========================================"
Write-Host "Profile '$profileName' created successfully!"
Write-Host ""
Write-Host "Opening profile folder in Explorer..."
Start-Process "explorer.exe" $profileDir
Write-Host "========================================"
Read-Host "Press Enter to exit"
exit 0
