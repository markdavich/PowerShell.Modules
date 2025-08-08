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

$V1 = [Variable]::new('VOne', 'V-1', $ExecutionContext.SessionState)
$V2 = [Variable]::new('VTwo', "$VOne-V-2", $ExecutionContext.SessionState)

$VarExplorerRegistryKey = (Add-Local 'ExplorerRegistryKey' 'HKCU:\SOFTWARE\Classes\CLSID\{52205fd8-5dfb-447d-801a-d0b52f2e83e1}')
$VarExplorerCommandRegistryKey = (Add-Local 'ExplorerCommandRegistryKey' "$ExplorerRegistryKey\shell\opennewwindow\command")
$VarModulePath = (Add-Local 'ModulePath' $MyInvocation.MyCommand.Path)
$VarJsonConfigFile = (Add-Local 'JsonConfigFile' (Get-CompanionName -FileString $ModulePath -CompanionExtension 'Config.json'))
$VarConfig = (Add-Local 'Config' [JsonParser]::new($JsonConfigFile, [Config]))
$VarJsonPath = (Add-Local 'JsonPath' (Get-CompanionName -FileString $ModulePath -CompanionExtension 'json'))
$VarVbsPath = (Add-Local 'VbsPath' (Join-Path [System.IO.Path]::GetDirectoryName($ModulePath) $Config.vbsFileName))


# $configuration = @(
#     (AddVariable 'ExplorerRegistryKey', 'HKCU:\SOFTWARE\Classes\CLSID\{52205fd8-5dfb-447d-801a-d0b52f2e83e1}'),
#     (AddVariable 'ExplorerCommandRegistryKey', "$ExplorerRegistryKey\shell\opennewwindow\command"),
#     (AddVariable 'ModulePath', $MyInvocation.MyCommand.Path),
#     (AddVariable 'JsonConfigFile', (Get-CompanionName -FileString $ModulePath -CompanionExtension 'Config.json')),
#     (AddVariable 'Config', [JsonParser]::new($JsonConfigFile, [Config])),
#     (AddVariable 'JsonPath', (Get-CompanionName -FileString $ModulePath -CompanionExtension 'json')),
#     (AddVariable 'VbsPath', (Join-Path [System.IO.Path]::GetDirectoryName($ModulePath) $Config.vbsFileName)),
# )

[VariableLogger]::Print("Bops.Lib.Setup Configuration Variables", $configuration, [System.ConsoleColor]::Yellow)

# $modulePath = Split-Path -Parent $MyInvocation.MyCommand.Path
# $jsonPath = Join-Path $modulePath 'Bops.Lib.Setup.json'
# $vbsPath = Join-Path $modulePath 'launch.location.vbs'


# Import-Module -Path "$PSScriptRoot\Bops.Lib.Setup.Settings.psm1"

function Get-ExplorerLocation {
    $settings = Get-UserSettings
    $result = $settings.locations.explorer
    return $result
}

function Set-ExplorerLocation {
    param (
        [string] $Location
    )
    throw [System.NotImplementedException] "Set-ExplorerLocation not fully implemented"
    $settings = Get-UserSettings
    $settings.locations.explorer = $Location
    Save-UserSettings $settings $env:USERNAME
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

    Set-Content -Path $vbsPath -Value $content -Encoding ASCII
}

function Initialize-Explorer {
    
    $location = Get-ExplorerLocation

    if (-not $location) {
        Write-Host "No location set in JSON. Please set a location first."
        return
    }

    Update-VbsWithNewLocation $location

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
    Write-Host "Explorer location reset."
}

function Open-UserSetupJson {
    Write-Host
    Write-Host "Bops.Lib.Setup.json is located at" -ForegroundColor Cyan -NoNewline; Write-Host ": " -ForegroundColor Magenta -NoNewline; Write-Host -ForegroundColor Yellow $jsonPath
    code $jsonPath
}

Export-ModuleMember -Function *

