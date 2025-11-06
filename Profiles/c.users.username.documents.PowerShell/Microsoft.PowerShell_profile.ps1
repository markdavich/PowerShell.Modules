using module Bop.U.Logger

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter()]
    [bool]$Fresh = $true
)

if ($Fresh) {
    Clear-Host
}

# Write-Host "<[" -ForegroundColor Green -NoNewline
# Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
# Write-Host "[P] " -ForegroundColor Blue -NoNewline
# Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
# Write-Host "]" -ForegroundColor Green

Write-Host
Write-Host "╭──────────────────────╮" -ForegroundColor Blue
Write-Host "│ " -ForegroundColor Blue -NoNewline;
Write-Host    "PowerShell Profile 7" -ForegroundColor Magenta -NoNewline;
Write-Host " │" -ForegroundColor Blue
Write-Host "╰──────────────────────╯" -ForegroundColor Blue
Write-Host "Running" -ForegroundColor Yellow -NoNewline;
Write-Host ": " -ForegroundColor Magenta -NoNewline;
Write-Host "Microsoft." -ForegroundColor DarkCyan -NoNewline;
Write-Host "PowerShell" -ForegroundColor Cyan -NoNewline;
Write-Host "_profile.ps1" -ForegroundColor DarkCyan;

# . (Join-Path -Path $PSScriptRoot -ChildPath 'Microsoft.PowerShell_profile.ps1')

# 📂 1. Define your custom module path
$CustomModules = "C:\.lib!\Modules"

# 📌 2. Add to PSModulePath if not already included
if (-not ($env:PSModulePath -split ';' | Where-Object { $_ -eq $CustomModules })) {
    $env:PSModulePath = "$CustomModules;$env:PSModulePath"
}

$libSymlink = "C:\.lib!"
#$libSymlink = "C:\.lib!\.profile.ps1"

$target = (Get-Item $libSymlink).Target

if ($target -and -not [System.IO.Path]::IsPathRooted($target)) {
    $linkDir = (Get-Item $libSymlink).Directory.FullName
    $resolved = Join-Path $linkDir $target
}
else {
    $resolved = $target
}

$libProfile = Get-Item (Join-Path -Path $resolved -ChildPath '.profile.ps1')

$logger = [Logger]::new()

try {
    . $libProfile
}
catch {
    $logger.Error("Error Loading '$($libProfile.Name)'", $_)
}

