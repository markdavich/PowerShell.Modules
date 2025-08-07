using module Bops.Lib.Config # This loads the Config type defined by Add-Type
using module Cs.Type.Configuration 

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

$path = Join-Path $PSScriptRoot "Bops.Lib.json"

[Configuration[Config]] $Config = [Configuration[Config]]::new($path)

Export-ModuleMember -Variable 'Config'

