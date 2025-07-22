function Find-DotNetClassDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ClassName,

        [Parameter()]
        [string]$Path = ".",

        [Parameter()]
        [switch]$Recurse = $false,

        [Parameter()]
        [string[]]$Include = @("*.cs", "*.vb")
    )

    # Get all matching files
    $files = Get-ChildItem -Path $Path -Recurse:$Recurse -File | Where-Object {
        $Include -contains $_.Extension
    }

    $file | ForEach-Object { Write-Host "Scanning: $($_.FullName)" }

    # Define regex pattern for class definition
    $pattern = "^(?i)\s*(?!//|/\*|'|\*).*?\bclass\s+$ClassName\b"

    # Search for pattern in files
    $found = $files | Select-String -Pattern $pattern

    # Convert to [System.IO.FileInfo] objects
    $fileInfos = $found.Path | Sort-Object -Unique | ForEach-Object {
        [System.IO.FileInfo]::new($_)
    }

    return , $fileInfos  # ensure array even with one result
}

Export-ModuleMember -Function "Find-DotNetClassDefinition"