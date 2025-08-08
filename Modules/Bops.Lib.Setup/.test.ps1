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
        $setup = Join-Path -Path $ModuleFolder -ChildPath "$ModuleName.psm1"
        Import-Module -FullyQualifiedName $setup
    }
    catch {
        $Logger.Error("$ModuleName Test Failed", $_)
        exit
    }
}

Test

$Logger.Blank()
$Logger.Note("$ModuleName Test Passed", [System.ConsoleColor]::Green)