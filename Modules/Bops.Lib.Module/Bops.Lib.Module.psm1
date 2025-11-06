using module Bop.U.Logger

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

function New-ModuleTest {
    [CmdletBinding()]
    param (
        [string] $Location = (Get-Location).Path
    )

    [Logger] $log = [Logger]::new()
    $log.Start("Adding test to")
    $log.Bullet($Location)

    # Resolve full source path (relative to the module file)
    $moduleRoot = Split-Path -Parent $PSCommandPath
    $sourceFile = Join-Path $moduleRoot "Templates\.test.ps1"

    if (-not (Test-Path $sourceFile)) {
        $log.Error("Source file not found: $sourceFile")
        return
    }

    # Ensure destination directory exists
    if (-not (Test-Path $Location)) {
        $log.Note("Creating target directory: $Location", [System.ConsoleColor]::Yellow)
        New-Item -ItemType Directory -Path $Location -Force | Out-Null
    }

    # Build destination file path
    $destinationFile = Join-Path $Location ".test.ps1"

    # Copy the file
    Copy-Item -Path $sourceFile -Destination $destinationFile -Force

    $log.Add("Copied:")
    $log.KeyValue("From", $sourceFile)
    $log.KeyValue("To", $destinationFile)
}