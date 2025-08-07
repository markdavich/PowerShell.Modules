using module Bop.U.Logger

$MyFilePath = $MyInvocation.MyCommand.Path

$modules = Get-ChildItem -Path $PSScriptRoot -Filter "*.psm1" -File | `
    Where-Object { $_.FullName -ne $MyFilePath }

$logger = [Logger]::new()
$logger.Blank()

$logger.Start("[F] Loading Function Modules")
$logger.Enter($MyFilePath)
$logger.IncreaseIndent()

for ($i = 0; $i -lt $modules.Count; $i++) {
    $module = $modules[$i]
    try {
        Import-Module -Name $module -ErrorAction stop
        $logger.BeginLine("<[ ", [System.ConsoleColor]::Yellow)
        $logger.Add($module.Name, [System.ConsoleColor]::DarkCyan)
        $logger.EndLine(" ]", [System.ConsoleColor]::Yellow)
    }
    catch {
        $logger.Error("Error loading: $module", $_)
    }
}

$logger.DecreaseIndent()
$logger.Note("[F]: DONE")
