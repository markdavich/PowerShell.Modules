
Clear-Host

Write-Host
Write-Host "╭───────────────────────────────────────────────────╮" -ForegroundColor Blue
Write-Host "│ " -ForegroundColor Blue -NoNewline;
Write-Host "VS Code PowerShell Profile (PowerShell Extension)" -ForegroundColor Magenta -NoNewline;
Write-Host " │" -ForegroundColor Blue
Write-Host "╰───────────────────────────────────────────────────╯" -ForegroundColor Blue
Write-Host "Running" -ForegroundColor Yellow -NoNewline;
Write-Host ": " -ForegroundColor Magenta -NoNewline;
Write-Host "Microsoft." -ForegroundColor DarkCyan -NoNewline;
Write-Host "VSCode" -ForegroundColor Cyan -NoNewline;
Write-Host "_profile.ps1" -ForegroundColor DarkCyan;

$normalProfile = Join-Path -Path $PSScriptRoot -ChildPath 'Microsoft.PowerShell_profile.ps1'

if (Test-Path $normalProfile) {
    . $normalProfile -Fresh:$false
}
else {
    Write-Warning "Missing normal profile: $normalProfile"
}