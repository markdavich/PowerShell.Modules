Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

# 1. Load the Cs.Type.dll from the root of this module
Add-Type -Path (Join-Path $PSScriptRoot 'Cs.Type.dll')

# 2. Get the TypeAccelerator type for static access
$TypeAccelerator = [PSObject].Assembly.GetType(
    'System.Management.Automation.TypeAccelerators'
)

# 3. Register the Type Accelerator using static method "Add"
# ________________________________________________________
# PowerShell equivalent to Class<T> = "Class`1"
# ╭─────────╮
# │ Generic │
# ╰─────────╯
# --------------------------------------------------------
$TypeAccelerator::Add('TestClass', [Cs.Type.TestClass``1])
