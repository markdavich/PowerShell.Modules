#[<>USING.MODULE.LIST]
using module '.\ClassOne.psm1'
using module '.\ClassTwo.psm1'
#[LIST.MODULE.USING<>]

using module Bop.U.Logger

$logger = [Logger]::new()
$logger.Blank()
$logger.Start("[C] Loading Class Modules")
$logger.Enter($MyInvocation.MyCommand.Path)

# Define the types to export with type accelerators.
$ExportableTypes = @(
    #[<>TYPE.LIST]
    [ClassOne],
    [ClassTwo]
    #[LIST.TYPE<>]
)

# Get the internal TypeAccelerators class to use its static methods.
$TypeAcceleratorsClass = [PSObject].Assembly.GetType(
    'System.Management.Automation.TypeAccelerators'
)

# Ensure none of the types would clobber an existing type accelerator.
# If a type accelerator with the same name exists, throw an exception.
$ExistingTypeAccelerators = $TypeAcceleratorsClass::Get

$logger.Note("Checking for Existing Type Accelerators")
foreach ($Type in $ExportableTypes) {
    if ($Type.FullName -in $ExistingTypeAccelerators.Keys) {
        $TypeAcceleratorsClass::Remove($Type.FullName)

        $logger.IncreaseIndent()
        $logger.BeginLine("--- ", [System.ConsoleColor]::Red)
        $logger.Add("Type Accelerator REMOVED for: '", [System.ConsoleColor]::DarkGray)
        $logger.Add($Type.FullName, [System.ConsoleColor]::White)
        $logger.EndLine("'", [System.ConsoleColor]::DarkGray)
        $logger.DecreaseIndent()
    }
}

$logger.Note("Adding Type Accelerators for Classes")
# Add type accelerators for every exportable type.
foreach ($Type in $ExportableTypes) {
    $TypeAcceleratorsClass::Add($Type.FullName, $Type)
        
    $logger.IncreaseIndent()
    $logger.BeginLine("+++ ", [System.ConsoleColor]::Green)
    $logger.Add("Type Accelerator ADDED for: '", [System.ConsoleColor]::DarkGray)
    $logger.Add($Type.FullName, [System.ConsoleColor]::White)
    $logger.EndLine("'", [System.ConsoleColor]::DarkGray)
    $logger.DecreaseIndent()
}


# Remove type accelerators when the module is removed.
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    foreach ($Type in $ExportableTypes) {
        $TypeAcceleratorsClass::Remove($Type.FullName)
        Write-Host "    Module.OnRemove --- Type Accelerator REMOVED for: '$($Type.FullName)'" -ForegroundColor Red
    }
}.GetNewClosure()

$logger.Note("[C]: DONE")
