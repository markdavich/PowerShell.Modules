using namespace System.IO

using module Bop.U.Json
using module Bop.U.Parser.Json
using module Bop.U.Variable
using module Bop.U.Variable.Logger
using module Bop.U.FileSystem

using module '.\Bops.Lib.Setup.Config.psm1'

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

# ╭───────────────╮
# │ Configuration │
# ╰───────────────╯
# Constants
$configuration = @(
    (Add-Local 'ExplorerRegistryKey' 'HKCU:\SOFTWARE\Classes\CLSID\{52205fd8-5dfb-447d-801a-d0b52f2e83e1}'),
    (Add-Local 'ExplorerCommandRegistryKey' "$ExplorerRegistryKey\shell\opennewwindow\command"),
    (Add-Local 'ModulePath' $MyInvocation.MyCommand.Path),
    (Add-Local 'SettingsJsonFile' (Get-CompanionName -FileString $ModulePath -CompanionExtension 'json')),
    (Add-Local 'ConfigJsonFile' (Get-CompanionName -FileString $ModulePath -CompanionExtension 'Config.json')),
    (Add-Local 'Config' ([JsonParser]::new($ConfigJsonFile, [Config]).GetInstance())),
    (Add-Local 'VbsPath' (Join-Path ([System.IO.Path]::GetDirectoryName($ModulePath)) $Config.VbsFileName)),
    (Add-Local 'VbsDefaultContent' (Join-Path ([System.IO.Path]::GetDirectoryName($ModulePath)) $Config.VbsDefaultContent))
)

[VariableLogger]::Print("Bops.Lib.Setup Configuration Variables", $configuration, [System.ConsoleColor]::Cyan)

function Get-ExplorerLocation {
    $settings = Get-UserSettings
    $result = $settings.locations.explorer
    return $result
}

function Set-ExplorerLocation {
    param (
        [string] $Location
    )
    
    if (-not (Test-Path $Location)) {
        Write-Host
        Write-Host "!!! Location Does Not Exist" -ForegroundColor Red
        Write-Host "-->  $Location" -ForegroundColor Magenta
        Write-Host
        Write-Host "Please pick a different location"
        Write-Host

        return
    }


    $settings = Get-UserSettings
    $settings.locations.explorer = $Location
    Save-UserSettings $settings $env:USERNAME
    Set-TerminalStartupDirectory $Location
    Update-VbsWithNewLocation $Location
}

function Set-TerminalStartupDirectory {
    param  (
        $Location
    )
    $settings = Get-UserSettings
    $startingDirectory = $settings.installs.terminal.settings.startingDirectory
    $terminalJsonPath = Resolve-Path $settings.installs.terminal.settings.path.powershell

    $terminalJson = Get-Json $terminalJsonPath

    $terminalJson[$startingDirectory] = $Location

    Save-Json $terminalJson $terminalJsonPath
}

function Update-VbsWithNewLocation {
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

    Set-Content -Path $VbsPath -Value $content -Encoding ASCII
}

function Initialize-Explorer {
    
    $location = Get-ExplorerLocation

    if (-not $location) {
        Write-Host "No location set in JSON. Please set a location first."
        return
    }

    Update-VbsWithNewLocation $location

    # # Add or update registry entry
    # $regKey = "HKCU:\SOFTWARE\Classes\CLSID\{52205fd8-5dfb-447d-801a-d0b52f2e83e1}\shell\opennewwindow\command"

    # if (-not (Test-Path $regKey)) {
    #     New-Item -Path $regKey -Force | Out-Null
    # }

    # Set-ItemProperty -Path $regKey -Name '(default)' -Value "wscript.exe `"$vbsPath`""
    # Set-ItemProperty -Path $regKey -Name 'DelegateExecute' -Value ""
    # Write-Host "Explorer launch location initialized."

    # Add or update registry entry
    if (-not (Test-Path $ExplorerCommandRegistryKey)) {
        New-Item -Path $ExplorerCommandRegistryKey -Force | Out-Null
    }

    Set-ItemProperty -Path $ExplorerCommandRegistryKey -Name '(default)' -Value "wscript.exe `"$vbsPath`""
    Set-ItemProperty -Path $ExplorerCommandRegistryKey -Name 'DelegateExecute' -Value ""

    Write-Host "Explorer launch location initialized."
}

function Reset-ExplorerLocation {
    # # Remove registry entry
    # $regKey = "HKCU:\SOFTWARE\Classes\CLSID\{52205fd8-5dfb-447d-801a-d0b52f2e83e1}"
    # if (Test-Path $regKey) {
    #     Remove-Item -Path $regKey -Recurse -Force
    #     Write-Host "Registry entry removed."
    # }
    # Write-Host "Explorer location reset."

    # Remove registry entry

    if (Test-Path $ExplorerRegistryKey) {
        Remove-Item -Path $ExplorerRegistryKey -Recurse -Force
        Write-Host "Registry entry removed."
    }

    Write-Host "Explorer location reset."
}

function Open-UserSetupJson {
    Write-Host
    Write-Host "Bops.Lib.Setup.json is located at" -ForegroundColor Cyan -NoNewline; Write-Host ": " -ForegroundColor Magenta -NoNewline; Write-Host -ForegroundColor Yellow $SettingsJsonPath
    code $SettingsJsonPath
}

Export-ModuleMember -Function *

