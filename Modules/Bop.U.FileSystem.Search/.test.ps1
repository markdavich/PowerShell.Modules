using namespace System.IO
using module Bop.U.Logger

Clear-Host

[Logger] $Logger = [Logger]::new()

$TestPath = $MyInvocation.MyCommand.Path
$ModuleFolder = [Path]::GetDirectoryName($TestPath)
$ModuleName = [Path]::GetFileName($ModuleFolder)

$Logger.Start("$ModuleName Test")
$Logger.Enter("$TestPath")

function Test {
    try {
        # Test Scripts and Module functions
        Test-One
    }
    catch {
        $Logger.Error("$ModuleName Test Failed", $_)
        exit
    }
}

function Test-One {
    $Logger.Enter("Test-One")
    Find-VisualStudioSettingsFiles
}

Test

$Logger.Blank()
$Logger.Note("$ModuleName Test Passed", [System.ConsoleColor]::Green)