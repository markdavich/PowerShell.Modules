using namespace System.IO
using module Bop.U.Parser.Json
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

class Profile {
    [string]$Bio
    [string]$Location
}

class User {
    [string]$Name
    [int]$Age
    [string[]]$Tags
    [Profile]$Profile
}


function Test {
    try {
        $JsonFile = Get-CompanionFile -File $TestPath -CompanionExtension '.json'
        
        [JsonParser] $Parser = [JsonParser]::new($JsonFile, [User])
        [User] $User = $Parser.GetInstance()
        
        $Logger.Blank()

        $Logger.PrettyPrint($User, "User")
    }
    catch {
        $Logger.Error("$ModuleName Test Failed", $_)
        exit
    }
}

Test

$Logger.Blank()
$Logger.Note("$ModuleName Test Passed", [System.ConsoleColor]::Green)