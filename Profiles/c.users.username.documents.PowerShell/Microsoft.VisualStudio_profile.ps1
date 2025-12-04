using module Bops.Lib.Setup

Write-RunningProfileHeader "VS Code PowerShell Profile (PowerShell Extension)" $MyInvocation.MyCommand.Path

$normalProfile = Join-Path -Path $PSScriptRoot -ChildPath 'Microsoft.PowerShell_profile.ps1'

if (Test-Path $normalProfile) {
    . $normalProfile -Fresh:$false
}
else {
    Write-Warning "Missing normal profile: $normalProfile"
}