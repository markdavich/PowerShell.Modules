$dllPath = Join-Path $PSScriptRoot 'Cs.Type.dll'

Write-Host ([DateTime]::Now)
Write-Host $dllPath
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
$TypeAccelerator::Add('ListDirection', [Cs.Type.ListDirection])
$TypeAccelerator::Add('ItemMoveInfo', [Cs.Type.ItemMoveInfo])
$TypeAccelerator::Add('OrderedSet', [Cs.Type.OrderedSet``1])
$TypeAccelerator::Add('TrackerListView', [Cs.Type.TrackerListView``1])
$TypeAccelerator::Add('Tracker', [Cs.Type.Tracker``1])