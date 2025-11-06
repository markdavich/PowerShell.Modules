Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

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

function Find-VisualStudioSettingsFiles {
    [CmdletBinding()]
    param(
        # Root path to search from (default: C:\)
        [string] $Root = 'C:\',

        # Search depth (optional). Default: unlimited
        [int] $Depth = -1,

        # Include hidden and system files?
        [switch] $IncludeHidden = $true,

        # Return only paths (default) or full FileInfo objects
        [switch] $Detailed
    )

    Write-Host "Searching for .vssettings files under $Root ..." -ForegroundColor Cyan

    # Build Get-ChildItem parameters dynamically
    $params = @{
        Path        = $Root
        Filter      = '*.vssettings'
        Recurse     = $true
        ErrorAction = 'SilentlyContinue'
        Force       = $IncludeHidden.IsPresent
    }

    # If user specified max depth (PowerShell 7+ only)
    if ($Depth -ge 0 -and $PSVersionTable.PSVersion.Major -ge 7) {
        $params['Depth'] = $Depth
    }

    # Skip known problematic folders
    $excludePatterns = @(
        'C:\$Recycle.Bin',
        'C:\Windows',
        'C:\Program Files',
        'C:\Program Files (x86)',
        'C:\ProgramData'
    )

    $results = @()

    foreach ($path in Get-ChildItem @params) {
        $skip = $false
        foreach ($ex in $excludePatterns) {
            if ($path.FullName -like "$ex*") { $skip = $true; break }
        }

        if (-not $skip) {
            $results += $path
        }
    }

    if ($results.Count -eq 0) {
        Write-Host "No .vssettings files found." -ForegroundColor Yellow
        return
    }

    Write-Host "Found $($results.Count) .vssettings file(s):" -ForegroundColor Green

    if ($Detailed) {
        $results
    }
    else {
        $results.FullName
    }
}


Export-ModuleMember -Function `
    "Find-DotNetClassDefinition", 
"Find-VisualStudioSettingsFiles"