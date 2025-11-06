$ExplorerRegistryKey = 'HKCU:\SOFTWARE\Classes\CLSID\{52205fd8-5dfb-447d-801a-d0b52f2e83e1}'

if (Test-Path $ExplorerRegistryKey) {
    Remove-Item -Path $ExplorerRegistryKey -Recurse -Force
    Write-Host "Registry entry removed."
}