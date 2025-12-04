using module Bops.Lib.Setup
using module Bop.U.Logger

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter()]
    [bool]$Fresh = $true
)

if ($Fresh) {
    # !!! Clear-Host
}

Write-RunningProfileHeader "PowerShell 7 Profile" $MyInvocation.MyCommand.Path


# 📂 1. Define your custom module path
$CustomModules = "C:\.lib!\Modules"

# 📌 2. Add to PSModulePath if not already included
if (-not ($env:PSModulePath -split ';' | Where-Object { $_ -eq $CustomModules })) {
    $env:PSModulePath = "$CustomModules;$env:PSModulePath"
}

$libSymlink = "C:\.lib!"

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

function prompt {
    $location = Get-Location
    "PS $location`n> " # This places the '>' on a new line
}

