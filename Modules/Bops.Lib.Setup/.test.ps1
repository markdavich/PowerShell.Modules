using namespace System.IO
using module Bop.U.Logger

# !!! Clear-Host

Write-Host "> ? ? ?" -ForegroundColor Yellow
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor DarkGray
Write-Host "Called " -ForegroundColor DarkMagenta -NoNewline
Write-Host "> ? ? ?" -ForegroundColor Yellow

[Logger] $Logger = [Logger]::new()

$TestPath = $MyInvocation.MyCommand.Path
$ModuleFolder = [Path]::GetDirectoryName($TestPath)
$ModuleName = [Path]::GetFileName($ModuleFolder)

$Logger.Start("$ModuleName Test")
$Logger.Enter("$TestPath")

function Test {
    try {
        # $setup = Join-Path -Path $ModuleFolder -ChildPath "$ModuleName.psm1"
        # Import-Module -FullyQualifiedName $setup
        # Test-StartupLocations
        Write-Host "  " -NoNewline
        Write-Host "|" -NoNewline
        Write-Host " " -NoNewline
        Write-Host "|"

        $Logger.ListItem("|", "Testing")
    }
    catch {
        $Logger.Error("$ModuleName Test Failed", $_)
        exit
    }
}

function Test-StartupLocations {
    Set-StartupLocations "C:\Code\Repos\MED"
}

Test

$Logger.Blank()
$Logger.Note("$ModuleName Test Passed", [System.ConsoleColor]::Green)

