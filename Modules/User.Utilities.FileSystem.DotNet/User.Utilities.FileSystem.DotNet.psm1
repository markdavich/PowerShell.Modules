using namespace System.IO

function Copy-CodeBehindWithMatchingName {
    param (
        [Parameter(Mandatory)]
        [System.IO.FileInfo]$View,

        [Parameter(Mandatory)]
        [System.IO.FileInfo]$CodeBehind,

        [Parameter(Mandatory)]
        [string]$OutputFolder
    )

    # Step 1: Extract components
    $baseName = $View.BaseName       # e.g., PF_Login
    $viewExt = $View.Extension.TrimStart('.')  # e.g., aspx
    $codeExt = $CodeBehind.Extension.TrimStart('.')  # e.g., cs

    # Step 2: Build new filename
    $newFileName = "$baseName.$viewExt.$codeExt"

    # Step 3: Copy to output
    $destinationPath = Join-Path $OutputFolder $newFileName
    Copy-Item -Path $CodeBehind.FullName -Destination $destinationPath -Force

    return [FileSystemInfo](Get-Item $destinationPath)
}

Export-ModuleMember -Function "Copy-CodeBehindWithMatchingName"