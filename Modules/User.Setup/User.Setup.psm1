using module User.Json

$modulePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$jsonPath = Join-Path $modulePath 'User.Setup.json'
$vbsPath = Join-Path $modulePath 'launch.location.vbs'
$regPath = Join-Path $modulePath 'launch.location.reg'
$defaultLocation = "C:\"


function Get-ExplorerLocation {
    # Write-Host "User.Setup: Get-ExplorerLocation" -ForegroundColor Green -BackgroundColor Yellow -NoNewline; Write-Host "" -ForegroundColor White -BackgroundColor Black
    # Write-Host "    Retrieving Explorer location from JSON..."
    
    $settings = Get-UserSettings

    $result = $settings.locations.explorer

    # Write-Host "    Current Explorer location: $result"

    return $result
}

function Set-ExplorerLocation($location) {
    $settings = Get-UserSettings
    $settings.profiles[$env:USERNAME].locations.explorer = $location
    Save-UserSettings $settings $env:USERNAME
}

function Update-VbsLocation($location) {
    $vbsContent = "WScript.CreateObject(`"Wscript.Shell`").Run `"$location`""
    Set-Content -Path $vbsPath -Value $vbsContent -Encoding ASCII
}

function Initialize-Explorer {
    
    $location = Get-ExplorerLocation

    if (-not $location) {
        Write-Host "No location set in JSON. Please set a location first."
        return
    }

    Update-VbsLocation $location

    # Add or update registry entry
    $regKey = "HKCU:\SOFTWARE\Classes\CLSID\{52205fd8-5dfb-447d-801a-d0b52f2e83e1}\shell\opennewwindow\command"
    if (-not (Test-Path $regKey)) {
        New-Item -Path $regKey -Force | Out-Null
    }
    Set-ItemProperty -Path $regKey -Name '(default)' -Value "wscript.exe `"$vbsPath`""
    Set-ItemProperty -Path $regKey -Name 'DelegateExecute' -Value ""
    Write-Host "Explorer launch location initialized."
}

function Reset-ExplorerLocation {
    # Remove registry entry
    $regKey = "HKCU:\SOFTWARE\Classes\CLSID\{52205fd8-5dfb-447d-801a-d0b52f2e83e1}"
    if (Test-Path $regKey) {
        Remove-Item -Path $regKey -Recurse -Force
        Write-Host "Registry entry removed."
    }
    # Optionally remove .json and .vbs
    if (Test-Path $jsonPath) { Remove-Item $jsonPath -Force }
    if (Test-Path $vbsPath) { Remove-Item $vbsPath -Force }
    Write-Host "Explorer location reset."
}

function Open-UserSetupJson {
    Write-Host
    Write-Host "User.Setup.json is located at" -ForegroundColor Cyan -NoNewline; Write-Host ": " -ForegroundColor Magenta -NoNewline; Write-Host -ForegroundColor Yellow $jsonPath
    code $jsonPath
}

Export-ModuleMember -Function *
