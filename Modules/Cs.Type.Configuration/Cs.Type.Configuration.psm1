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
$TypeAccelerator::Add('Configuration', [Cs.Type.Configuration``1])
