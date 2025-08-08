using namespace System.IO
using namespace User.U.Logger

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

function Find-AndReplaceTextInFile {
    param (
        [FileSystemInfo] $Path,
        [string] $TextToFind,
        [string] $NewValue
    )

    (Get-Content $Path -Raw) -replace $TextToFind, $NewValue | Set-Content $Path

}

function Find-TextInFile {
    param (
        [FileSystemInfo] $Path,
        [string] $TextToFind
    )

    return Select-String -Path $Path -Pattern $TextToFind -Quiet
}

function Get-CompanionName {
    param (
        [string] $FileString,
        [string] $CompanionExtension
    )

    $result = [Path]::ChangeExtension($FileString, $CompanionExtension)
    return $result
}

function Get-CompanionFile {
    param (
        [FileInfo] $File,
        [string] $CompanionExtension
    )

    $companion = [Path]::ChangeExtension($File.FullName, $CompanionExtension)

    if (Test-Path $companion) {
        return Get-Item -Path $companion
    }

    throw [FileNotFoundException] "No '$CompanionExtension' Companion for $($File.FullName)"
}