Clear-Host

$dllPath = Join-Path $PSScriptRoot 'Cs.Type.dll'

Write-Host ([DateTime]::Now)
Write-Host $dllPath
Write-Host 'Yellow'

# $assembly = [System.Reflection.Assembly]::LoadFrom($dllPath)

# # Use the loaded assembly to resolve the type directly:
# $trackerOpenType = $assembly.GetType("Cs.Type.Tracker``1", $true)

# # Construct closed generic type (Tracker[$Type])
# $closedTrackerType = $trackerOpenType.MakeGenericType(@($Type))

Write-Host
Write-Host '1. Load Cs.Type.dll'

# 1. Load the Cs.Type.dll from the root of this module
$TrackerTypes = Add-Type -Path $dllPath -PassThru

$TrackerTypes | Get-Member

Write-Host '2. Get TypeAccelerator'
# 2. Get the TypeAccelerator type for static access
$TypeAccelerator = [PSObject].Assembly.GetType(
    'System.Management.Automation.TypeAccelerators'
)

Write-Host '3. Register the Type Accelerator'
# 3. Register the Type Accelerator using static method "Add"
# ________________________________________________________
# PowerShell equivalent to Class<T> = "Class`1"
# ╭─────────╮
# │ Generic │
# ╰─────────╯
# --------------------------------------------------------
$TypeAccelerator::Add('Tracker', [Cs.Type.Tracker``1])
