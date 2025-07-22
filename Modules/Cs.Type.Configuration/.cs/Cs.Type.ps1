using module Bops.Lib

$Config | ConvertTo-Json -Depth 10 | Write-Host

Write-Host "bye bye :)"