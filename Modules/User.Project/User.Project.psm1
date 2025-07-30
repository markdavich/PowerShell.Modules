using module User.Logger
using module Cs.Type.Tracker

class ProjectPaths {
    [string]$Root

    ProjectPaths([string]$projectRoot) {
        $this.Root = $projectRoot
    }

    static [string] $MainFolder = '.main'
    static [string] $ModulesFolder = 'modules'
    static [string] $StartupScript = '.startup.ps1'
    static [string] $LoaderScript = '.loader.ps1'
    static [string] $SettingsJson = 'Settings.json'
    static [string] $MainScript = '.main.ps1'

    [string] GetModulesPath() {
        return $this.GetProjectPath([ProjectPaths]::ModulesFolder)
    }

    [string] GetLoaderScriptPath() {
        return $this.GetProjectPath([ProjectPaths]::LoaderScript)
    }

    [string] GetSettingsJsonPath() {
        return $this.GetProjectPath([ProjectPaths]::SettingsJson)
    }

    hidden [string] GetProjectPath([string]$Path) {
        return Join-Path $this.GetMainFolderPath() $Path
    }

    [string] GetMainFolderPath() {
        return Join-Path $this.Root ([ProjectPaths]::MainFolder)
    }

    [string] GetMainScriptPath() {
        return Join-Path $this.Root ([ProjectPaths]::MainScript)
    }

    [string] GetStartupScriptPath() {
        return Join-Path $this.Root ([ProjectPaths]::StartupScript)
    }

    [string] GetModuleFolderPath([string]$ModuleName) {
        return Join-Path ($this.GetModulesPath()) $ModuleName
    }

    [string] GetModuleFilePath([string]$ModuleName) {
        $folder = $this.GetModuleFolderPath($ModuleName)
        return Join-Path $folder "$ModuleName.psm1"
    }

    [string] CreateModuleFile([string]$ModuleName, [string]$Content) {
        $folder = $this.GetModuleFolderPath($ModuleName)
        $file = $this.GetModuleFilePath($ModuleName)

        if (-not (Test-Path $folder)) {
            New-Item -ItemType Directory -Path $folder -Force | Out-Null
        }

        $Content | Set-Content -Path $file -Encoding UTF8
        return $file
    }

    [string] GetSettingsClassPath() {
        return $this.GetProjectPath('Settings.ps1')
    }
}

class ProjectSettings {
    [string]$Root
    [Type]$Type

    ProjectSettings([string]$Root, [Type]$Type) {
        $this.Root = $Root
        $this.Type = $Type
    }

    [object] Get() {
        # Write-Host "    --> ProjectSettings.Get()"
        $jsonPath = (New-Object ProjectPaths $this.Root).GetSettingsJsonPath()

        # Write-Host "        !!! ProjectSettings.Get() `$jsonPath = '$jsonPath'"
        $username = $env:USERNAME

        $jsonObject = @{}

        # Write-Host "        !!! ProjectSettings.Get() Testing Path"
        if (Test-Path $jsonPath) {
            try {
                # Write-Host "        !!! ProjectSettings.Get() Getting Content"
                $jsonContent = Get-Content $jsonPath -Raw

                # Write-Host "        !!! ProjectSettings.Get() Got Content"
                $jsonObject = $jsonContent | ConvertFrom-Json -ErrorAction Stop
            }
            catch {
                Write-Warning '⚠️ Failed to parse Settings.json — creating a fresh one.'
                $jsonObject = @{}
            }
        }

        if (-not $jsonObject.$username) {
            Write-Host "[ℹ️] Creating settings entry for user '$username' in Settings.json"

            $defaultSettings = @{}

            foreach ($property in $this.Type.GetProperties()) {
                $propertyType = $property.PropertyType
                # Write-Host "        !!! Property Name: $($property.Name), Property Type: $($propertyType.FullName)"

                $defaultValue = if ($propertyType.IsArray) {
                    , @()
                }
                else {
                    switch ([System.Type]::GetTypeCode($propertyType)) {
                        'String' { '' }
                        'Int32' { 0 }
                        'Int64' { 0 }
                        'Boolean' { $false }
                        'DateTime' { [DateTime]::MinValue }
                        default { $null }
                    }
                }

                # Write-Host "        !!! Property Name: $($property.Name), Property Type: " -NoNewLine; Write-Host -Object $defaultValue

                $defaultSettings[$property.Name] = $defaultValue
            }

            $jsonObject | Add-Member -MemberType NoteProperty -Name $username -Value @{ Settings = $defaultSettings }

            $jsonObject | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonPath
            Write-Host "Saved default Settings object for user '$username'"
        }

        $userSettings = $jsonObject.$username.Settings

        $settingsObject = [Activator]::CreateInstance($this.Type)
        foreach ($propertyName in $settingsObject.PSObject.Properties.Name) {
            if ($userSettings.PSObject.Properties.Match($propertyName)) {
                $settingsObject.$propertyName = $userSettings.$propertyName
            }
        }

        return $settingsObject
    }
}

function New-ProjectModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$Verb = 'Invoke'
    )

    $projectRoot = Get-Location
    $paths = [ProjectPaths]::new($projectRoot)

    $folderName = $Name

    $moduleContent = Get-ModuleContent $Name $Verb

    try {
        $fullPath = $paths.CreateModuleFile($folderName, $moduleContent)
        Write-Host "[✅] Method module created: $fullPath"
    }
    catch {
        Write-Error "❌ Failed to create module: $_"
    }
}

function New-ProjectClass {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string]$ModulePrefix = ""
    )

    $projectRoot = Get-Location
    $paths = [ProjectPaths]::new($projectRoot)

    $prefix = $ModulePrefix.Trim() -eq "" ? "" : "$ModulePrefix."

    $folderName = "$($prefix)Class.$Name"

    $classContent = @"
<#
.SYNOPSIS
    A BRIEF description of the class
.DESCRIPTION
    A DETAILED description of the class
.PARAMETER <Parameter-Name>
    Describe each constructor parameter in it's own .PARAMETER tag
.EXAMPLE
    Example usage
.OUTPUTS
    Public properties and methods
.NOTES
    This function is a wrapper around Get-Process.
#>
class $Name {
    $Name() {

    }
}
"@

    try {
        $fullPath = $paths.CreateModuleFile($folderName, $classContent)
        code "$fullPath"
        Write-Host "[✅] Class module created: $fullPath"
    }
    catch {
        Write-Error "❌ Failed to create module: $_"
    }
}

function Get-ModuleContent {
    param(
        [string]$MethodName,
        [string]$Verb
    )

    return @"
function $Verb-$MethodName {
    `$Log.Start(`"$Verb-$MethodName`")
    `$Log.Error(`"NOT IMPLEMENTED`")
    Step-OneMethod
}

function Step-OneMethod {
    `$Log.Enter(`"Step-OneMethod`")
    `$Log.Error(`"NOT IMPLEMENTED`")
    `$Log.Note(`"This is a note...`")
    `$Log.Leave()
}

Export-ModuleMember -Function $Verb-$MethodName
"@
}

function New-PowerShellProject {
    param(
        [Parameter(Mandatory)][string]$Name
    )

    $projectRoot = Join-Path (Get-Location) $Name
    $paths = [ProjectPaths]::new($projectRoot)

    if (Test-Path $projectRoot) {
        Write-Warning "Project folder already exists: $projectRoot"
        return
    }

    New-Item -ItemType Directory -Path $paths.GetModulesPath() -Force | Out-Null

    Publish-Main -Paths $paths
    Publish-Startup -Paths $paths
    Publish-Loader -Paths $paths
    Publish-SettingsClass -Paths $paths

    Write-Host "✅ PowerShell project '$Name' created at: $projectRoot"
}

function Publish-Main {
    param([ProjectPaths]$Paths)

    @'
using module User.Project

param (
    [switch]$Refresh
)

# Dot-Source the Program Script to Access Invoke-Startup
. ".\$([ProjectPaths]::StartupScript)"

Invoke-Startup -ProjectRoot $PSScriptRoot -Refresh:$Refresh

function Main {
    # Call Project Module Methods
}

Main
'@ | Set-Content -Path $Paths.GetMainScriptPath() -Encoding UTF8
}

function Publish-Startup {
    param([ProjectPaths]$Paths)

    @'
function Invoke-Startup {
    param(
        [Parameter(Mandatory)][string]$ProjectRoot,
        [switch]$Refresh
    )

    $Global:ProjectRoot = $ProjectRoot
    $Global:ProjectId = (Get-Item $ProjectRoot).FullName.Replace('\', '_')
    $Global:ProjectPaths = [ProjectPaths]::new($ProjectRoot)

    . "$($Global:ProjectPaths.GetSettingsClassPath())"

    [Settings]$Global:Settings = [ProjectSettings]::new($ProjectRoot, [Settings]).Get()

    . "$($Global:ProjectPaths.GetLoaderScriptPath())"

    Invoke-LoadModules $Refresh
}
'@ | Set-Content -Path $Paths.GetStartupScriptPath() -Encoding UTF8
}

function Publish-Loader {
    param([ProjectPaths]$Paths)

    @'
function Invoke-LoadModules {
    param (
        [switch]$Refresh
    )

    if ($Refresh) {
        if (Get-Variable -Name $Global:ProjectId -Scope Global -ErrorAction SilentlyContinue) {
            Remove-Variable -Name $Global:ProjectId -Scope Global
            Write-Host "[🔄] Cleared setup flag: $Global:ProjectId"
        }
    }

    if (-not (Get-Variable -Name $Global:ProjectId -Scope Global -ErrorAction SilentlyContinue)) {
        Set-Variable -Name $Global:ProjectId -Value $true -Scope Global

        Import-ProjectModules

        Write-Host "[✔] Project setup loaded: $Global:ProjectRoot"
    }
    else {
        Write-Host "[ℹ️] Project already initialized: $Global:ProjectRoot"
    }
}
'@ | Set-Content -Path $Paths.GetLoaderScriptPath() -Encoding UTF8
}

function Publish-SettingsClass {
    param([ProjectPaths]$Paths)

    @'
class Settings {
    [string]$String
    [Int64]$Integer
    [string[]]$StringArray
    [DateTime]$DateTime
}
'@ | Set-Content -Path $Paths.GetSettingsClassPath() -Encoding UTF8
}

function New-CsTypeModule {
    param (
        [string]$ClassName,
        [switch]$Generic,
        [string]$GenericTypeName = 'T'
    )

    $namespace = 'Cs.Type'
    $moduleName = "$namespace.$ClassName"

    # PowerShell Module Root (Don't use $env:PSModuleRoot, this library may move)
    $psModuleRoot = (Get-Item $PSScriptRoot).Parent.FullName
    
    # ╭───────────────────╮
    # │ Destination Files │
    # ╰───────────────────╯
    $csModuleFolder = Join-Path $psModuleRoot $moduleName
    $csProjectFolder = Join-Path $csModuleFolder '.cs'

    $outCs = Join-Path $csProjectFolder "$ClassName.cs"
    $outCsProj = Join-Path $csProjectFolder "$namespace.csproj"
    $outMd = Join-Path $csModuleFolder 'README.md'
    $outPs1 = Join-Path $csProjectFolder "$namespace.ps1"
    $outPsm1 = Join-Path $csModuleFolder "$moduleName.psm1"

    # ╭────────────────╮
    # │ Create Folders │
    # ╰────────────────╯
    # 1. Create C# Module Folder ...Modules\Cs.Type.ClassName\
    New-Item -Path $csModuleFolder -ItemType Directory -Force

    # 2. Create C# Project Folder ...Modules\Cs.Type.ClassName\.cs\
    New-Item -Path $csProjectFolder -ItemType Directory -Force

    # ╭────────────────╮
    # │ Template Files │
    # ╰────────────────╯
    $templatesFolder = Join-Path $PSScriptRoot 'Cs.Type.Templates'

    $templateCs = Join-Path $templatesFolder '.cs'
    $templateCsGeneric = Join-Path $templatesFolder '.cs.generic'
    $templateCsproj = Join-Path $templatesFolder '.csproj'
    $templateMd = Join-Path $templatesFolder '.md'
    $templatePs1 = Join-Path $templatesFolder '.ps1'
    $templatePsm1 = Join-Path $templatesFolder '.psm1'
    $templatePsm1Generic = Join-Path $templatesFolder '.psm1.generic'

    if ($Generic) {
        # Override concrete implementation with generic
        $templatePsm1 = $templatePsm1Generic
        $templateCs = $templateCsGeneric
    }

    # Copy Files to Output Location
    Copy-Item -Path $templateCs -Destination $outCs
    Copy-Item -Path $templateCsproj -Destination $outCsproj
    Copy-Item -Path $templateMd -Destination $outMd
    Copy-Item -Path $templatePs1 -Destination $outPs1
    Copy-Item -Path $templatePsm1 -Destination $outPsm1

    # Replace ClassName in all files with $ClassName
    $files = @(
        $outCs,
        $outCsproj,
        $outMd,
        $outPs1,
        $outPsm1    
    )

    foreach ($file in $files) {
        (Get-Content -Path $file) -replace 'ClassName', $ClassName | Set-Content -Path $file
    }

    # Replace <T> in .cs with <$GenericTypeName>
    if ($Generic) {
        (Get-Content -Path $outCs) -replace '<T>', "<$GenericTypeName>" | Set-Content -Path $outCs
    }
}


Export-ModuleMember -Function `
    New-ProjectModule, `
    Import-ProjectModules, `
    New-PowerShellProject, `
    New-CsTypeModule, `
    New-ProjectClass