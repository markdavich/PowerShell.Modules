using module Bops.Lib.Project

function Invoke-Startup {
    param(
        [Parameter(Mandatory)][string]$ProjectRoot
    )

    try {
        $Global:ProjectRoot = $ProjectRoot
        $Global:ProjectId = (Get-Item $ProjectRoot).FullName.Replace('\', '_')
        $Global:ProjectPaths = [ProjectPaths]::new($ProjectRoot)

        . "$($ProjectPaths.GetSettingsClassPath())"

        [Settings]$Global:Settings = [ProjectSettings]::new($ProjectRoot, [Settings]).Get()

        # Import the .loader which loads project modules and exposes the Load method
        $loader = $ProjectPaths.GetLoaderScriptPath()

        # Dot-Source the .loader.ps1 Script
        . "$loader"
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Error $_
    }

    # Call the Load method, this was made available by Dot-Sourcing the .loader.ps1 Script
    Load
}

