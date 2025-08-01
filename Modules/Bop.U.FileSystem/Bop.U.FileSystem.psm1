using namespace System.IO

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