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
        [string[]]$Extensions = @(".cs", ".vb")
    )

    # Get all matching files
    $files = Get-ChildItem -Path $Path -Recurse:$Recurse -File | Where-Object {
        $Extensions -contains $_.Extension
    }

    # Define regex pattern for class definition
    $pattern = "^(?i)\s*(?!//|/\*|'|\*).*?\bclass\s+$ClassName\b"

    # Search for pattern in files
    $found = $files | Select-String -Pattern $pattern

    # Convert to [System.IO.FileInfo] objects
    [System.IO.FileInfo[]]$fileInfos = $found.Path `
        | Sort-Object -Unique `
        | ForEach-Object {
            [System.IO.FileInfo]::new($_)
        }

    return ($fileInfos.Count -eq 0) `
        ? [System.IO.FileInfo[]]@( ) `
        : [System.IO.FileInfo[]]$fileInfos
}

Export-ModuleMember -Function "Find-DotNetClassDefinition"