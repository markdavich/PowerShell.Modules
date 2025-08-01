class DllOutput {
    hidden [string]$DllPath
    hidden [string]$OutputRoot
    hidden [string]$RelativeRoot

    static [string] $AppCodeName = 'App_Code'
    static [string] $AppWebName = 'App_Web'
    static [string] $AppGlobalAsaxName = 'App_global.asax'

    DllOutput([string]$DllPath, [string]$OutputRoot, [string]$RelativeRoot) {
        $this.DllPath = $DllPath
        $this.OutputRoot = $OutputRoot
        $this.RelativeRoot = $RelativeRoot

        # Write-Host "    DllOutput.DllPath      = '$DllPath'"
        # Write-Host "    DllOutput.OutputRoot   = '$OutputRoot'"
        # Write-Host "    DllOutput.RelativeRoot = '$RelativeRoot'"
    }

    [string] BaseName() {
        $result = [System.IO.Path]::GetFileNameWithoutExtension($this.DllPath)

        if ($result -like "$([DllOutput]::AppCodeName)*") {
            return [DllOutput]::AppCodeName
        }

        if ($result -like "$([DllOutput]::AppWebName)*") {
            return [DllOutput]::AppWebName
        }

        if ($result -like "$([DllOutput]::AppGlobalAsaxName)*") {
            return [DllOutput]::AppGlobalAsaxName
        }

        return $result
    }

    [string] Path() {
        return Join-Path $this.OutputRoot $this.BaseName()
    }

    [string] RelativePath() {
        # Write-Host "    DllOutput.RelativePath(): Path         = '$($this.Path())'"
        # Write-Host "    DllOutput.RelativePath(): RelativeRoot = '$($this.RelativeRoot)'"
        # Write-Host "    DllOutput.RelativePath(): Result       = '$($this.Path() -replace [regex]::Escape($this.RelativeRoot), '')'"

        return $this.Path() -replace [regex]::Escape($this.RelativeRoot), ""
    }

    [string] Name() {
        return [DllOutput]::Name($this.DllPath)
    }

    static [string] Name([string]$DllPath) {
        return [System.IO.Path]::GetFileName($DllPath)
    }

    static [Int64] MaxNameLength([string[]]$DllPaths) {
        return ($DllPaths | Measure-Object { [DllOutput]::Name($_).Length } -Maximum).Maximum
    }

    static [Int64] MaxRelativePathLength(
        [string[]]$DllPaths, 
        [string]$OutputRoot, 
        [string]$RelativeRoot
    ) {
        return (
            $DllPaths | `
                Measure-Object { [DllOutput]::new(
                    $_, 
                    $OutputRoot, 
                    $RelativeRoot
                ).RelativePath().Length `
            } -Maximum `
        ).Maximum
    }

    static [string] AppWebRoot([string]$OutputRoot) {
        return Join-Path -Path $OutputRoot -ChildPath [DllOutput]::AppWebName
    }

    static [string] AppCodeRoot([string]$OutputRoot) {
        return Join-Path -Path $OutputRoot -ChildPath ([DllOutput]::AppCodeName)
    }
}