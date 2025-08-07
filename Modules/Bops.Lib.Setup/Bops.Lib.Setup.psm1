using module Bop.U.Json

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

$modulePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$jsonPath = Join-Path $modulePath 'Bops.Lib.Setup.json'
$vbsPath = Join-Path $modulePath 'launch.location.vbs'
$regPath = Join-Path $modulePath 'launch.location.reg'
$defaultLocation = "C:\"


Import-Module -Path "$PSScriptRoot\Bops.Lib.Setup.Settings.psm1"

function Get-ExplorerLocation {
    # Write-Host "Bops.Lib.Setup: Get-ExplorerLocation" -ForegroundColor Green -BackgroundColor Yellow -NoNewline; Write-Host "" -ForegroundColor White -BackgroundColor Black
    # Write-Host "    Retrieving Explorer location from JSON..."
    
    $settings = Get-UserSettings

    $result = $settings.locations.explorer

    # Write-Host "    Current Explorer location: $result"

    return $result
}

function Set-ExplorerLocation {
    param (
        [string] $Location
    )

    Write-Host
    Write-Host "Set-ExplorerLocation(Location: '$Location')"

    $settings = Get-UserSettings

    Write-Host "    `$settings = $settings"

    $settings.profiles[$env:USERNAME].locations.explorer = $Location

    Write-Host "    Calling: 'Save-UserSettings'"

    # This line FAILS with:
    #   Save-UserSettings: The term 'Save-UserSettings' is not recognized as a name of a
    #   cmdlet, function, script file, or executable program. Check the spelling of the  
    #   name, or if a path was included, verify that the path is correct and try again."
    Save-UserSettings $settings $env:USERNAME
}

function Update-VbsLocation {
    param (
        [string] $Location
    )

    $fallback = 'C:\'
    $content = @"
Dim fso, shell, path, defaultPath
Set fso = CreateObject(`"Scripting.FileSystemObject`")
Set shell = CreateObject(`"Wscript.Shell`")

If fso.FolderExists(`"$Location`") Then
    shell.Run `"$Location`"
Else
    ' fallback location if missing
    shell.Run `"$fallback`"
End If
"@

    Set-Content -Path $vbsPath -Value $content -Encoding ASCII
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
    Write-Host "Bops.Lib.Setup.json is located at" -ForegroundColor Cyan -NoNewline; Write-Host ": " -ForegroundColor Magenta -NoNewline; Write-Host -ForegroundColor Yellow $jsonPath
    code $jsonPath
}

Export-ModuleMember -Function *

