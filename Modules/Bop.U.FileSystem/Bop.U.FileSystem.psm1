using namespace System.IO

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