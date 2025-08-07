using namespace System.IO

using module Bop.U.Logger
using module Cs.Type.Tracker

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

class ProjectPaths {
    # Project Configuration Constants -----------------------------------------------
    static [string] $MainFolderName = '.main'
    static [string] $ReadmeFolderName = '.readme'
    static [string] $FilesFolderName = 'Files'
    static [string] $OutputFolderName = 'Output'
    static [string] $MainScriptName = '.main.ps1'
    static [string] $StartupScriptName = '.startup.ps1'
    static [string] $ReadmeFileName = 'README.md'
    static [string] $ModulesFolderName = 'modules'
    static [string] $ClassModulesFolderName = 'Classes'
    static [string] $FunctionModulesFolderName = 'Functions'
    static [string] $VariableModulesFolderName = 'Variables'
    static [string] $LoaderScriptName = '.loader.ps1'
    static [string] $SettingsJsonName = 'Settings.json'
    static [string] $SettingsClassName = 'Settings.ps1'
    static [string] $ProjectTemplateName = 'Project.Template'
    
    # Backing Fields for Getters ----------------------------------------------------
    hidden [FileSystemInfo] $_root # Initialized in Constructor

    hidden [FileSystemInfo] $_projectRoot
    hidden [FileSystemInfo] $_mainFolder
    hidden [FileSystemInfo] $_readmeFolder
    hidden [FileSystemInfo] $_filesFolder
    hidden [FileSystemInfo] $_outputFolder
    hidden [FileSystemInfo] $_mainScript
    hidden [FileSystemInfo] $_startupScript
    hidden [FileSystemInfo] $_modulesFolder
    hidden [FileSystemInfo] $_functionModulesFolder
    hidden [FileSystemInfo] $_classModulesFolder
    hidden [FileSystemInfo] $_variableModulesFolder
    hidden [FileSystemInfo] $_loaderScript
    hidden [FileSystemInfo] $_settingsJson
    hidden [FileSystemInfo] $_settingsClass
    hidden [FileSystemInfo] $_projectTemplateFolder

    hidden [Logger] $Log

    # Constructor *******************************************************************
    ProjectPaths([string]$projectRoot) {
        $this.Log = [Logger]::new()
        $this.Log.Start("Project Paths")

        $this._root = Get-Item -Path $projectRoot

        $this | Add-Member -Name ProjectRoot -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: ProjectRoot")
                $result = $this._root
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: ProjectRoot", $_)
            }
        }

        $this | Add-Member -Name MainFolder -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: MainFolder")
                $result = $this.GetProjectItem([ProjectPaths]::MainFolderName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: MainFolder", $_)
            }
        }

        $this | Add-Member -Name ReadmeFolder -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: ReadmeFolder")
                $result = $this.GetProjectItem([ProjectPaths]::ReadmeFolderName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: ReadmeFolder", $_)
            }
        }

        $this | Add-Member -Name FilesFolder -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: FilesFolder")
                $result = $this.GetProjectItem([ProjectPaths]::FilesFolderName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: FilesFolder", $_)
            }
        }

        $this | Add-Member -Name OutputFolder -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: OutputFolder")
                $result = $this.GetProjectItem([ProjectPaths]::OutputFolderName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: OutputFolder", $_)
            }
        }

        $this | Add-Member -Name MainScript -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: MainScript")
                $result = $this.GetProjectItem([ProjectPaths]::MainScriptName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: MainScript", $_)
            }
        }

        $this | Add-Member -Name StartupScript -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: StartupScript")
                $result = $this.GetProjectItem([ProjectPaths]::StartupScriptName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: StartupScript", $_)
            }
        }

        $this | Add-Member -Name ReadmeFile -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: ReadmeFile")
                $result = $this.GetProjectItem([ProjectPaths]::ReadmeFileName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: ReadmeFile", $_)
            }
        }

        $this | Add-Member -Name ModulesFolder -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: ModulesFolder")
                $result = $this.GetMainFolderItem([ProjectPaths]::ModulesFolderName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: ModulesFolder", $_)
            }
        }

        $this | Add-Member -Name FunctionModulesFolder -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: FunctionModulesFolder")
                $result = $this.GetModuleFolder([ProjectPaths]::ModulesFolderName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: FunctionModulesFolder", $_)
            }
        }

        $this | Add-Member -Name ClassModulesFolder -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: ClassModulesFolder")
                $result = $this.GetModuleFolder([ProjectPaths]::ModulesFolderName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: ClassModulesFolder", $_)
            }
        }

        $this | Add-Member -Name VariableModulesFolder -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: VariableModulesFolder")
                $result = $this.GetModuleFolder([ProjectPaths]::ModulesFolderName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: VariableModulesFolder", $_)
            }
        }

        $this | Add-Member -Name LoaderScript -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: LoaderScript")
                $result = $this.GetMainFolderItem([ProjectPaths]::LoaderScriptName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: LoaderScript", $_)
            }
        }

        $this | Add-Member -Name SettingsJson -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: SettingsJson")
                $result = $this.GetMainFolderItem([ProjectPaths]::SettingsJsonName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: SettingsJson", $_)
            }
        }

        $this | Add-Member -Name SettingsClass -MemberType ScriptProperty -TypeName 'FileSystemInfo' -Value {
            try {

                $this.Log.Enter("ProjectPaths.GETTER: SettingsClass")
                $result = $this.GetMainFolderItem([ProjectPaths]::SettingsClassName)
                $this.Log.KeyValue("Value", $result)
                $this.Log.Leave()
                return $result
            }
            catch {
                $this.Log.Error("GETTER: SettingsClass", $_)
            }
        }
    }

    # Properties ====================================================================

    # [FileSystemInfo] get_ProjectRoot() {
    #     return $this._root
    # }

    #region ● Project Root > (.main, .readme, Files, Output, .main.ps1, .startup.ps1)
    # [FileSystemInfo] get_MainFolder() {
    #     return $this.GetProjectItem([ProjectPaths]::MainFolderName)
    # }

    # [FileSystemInfo] get_ReadmeFolder() {
    #     return $this.GetProjectItem([ProjectPaths]::ReadmeFolderName)
    # }

    # [FileSystemInfo] get_FilesFolder() {
    #     return $this.GetProjectItem([ProjectPaths]::FilesFolderName)
    # }

    # [FileSystemInfo] get_OutputFolder() {
    #     return $this.GetProjectItem([ProjectPaths]::OutputFolderName)
    # }

    # [FileSystemInfo] get_MainScript() {
    #     return $this.GetProjectItem([ProjectPaths]::MainScriptName)
    # }

    # [FileSystemInfo] get_StartupScript() {
    #     return $this.GetProjectItem([ProjectPaths]::StartupScriptName)
    # }

    # [FileSystemInfo] get_ReadmeFile() {
    #     return $this.GetProjectItem([ProjectPaths]::ReadmeFileName)
    # }
    #endregion

    #region ● Main > Modules --------------------------------------------------------
    # [FileSystemInfo] get_ModulesFolder() {
    #     return $this.GetMainFolderItem([ProjectPaths]::ModulesFolderName)
    # }

    # [FileSystemInfo] get_FunctionModulesFolder() {
    #     return $this.GetModuleFolder([ProjectPaths]::ModulesFolderName)
    # }

    # [FileSystemInfo] get_ClassModulesFolder() {
    #     return $this.GetModuleFolder([ProjectPaths]::ModulesFolderName)
    # }

    # [FileSystemInfo] get_VariableModulesFolder() {
    #     return $this.GetModuleFolder([ProjectPaths]::ModulesFolderName)
    # }
    #endregion

    #region ● Main > Files (.loader.ps1, Settings.json, Settings.ps1) ---------------
    # [FileSystemInfo] get_LoaderScript() {
    #     return $this.GetMainFolderItem([ProjectPaths]::LoaderScriptName)
    # }

    # [FileSystemInfo] get_SettingsJson() {
    #     return $this.GetMainFolderItem([ProjectPaths]::SettingsJsonName)
    # }

    # [FileSystemInfo] get_SettingsClass() {
    #     return $this.GetMainFolderItem([ProjectPaths]::SettingsClassName)
    # }
    #endregion

    #region ● Property Helpers ------------------------------------------------------
    hidden [FileSystemInfo] GetProjectItem([string] $ItemName) {
        try {

            $this.Log.Enter("METHOD: GetProjectItem")
            $result = Get-Item (Join-Path $this.ProjectRoot $ItemName)
            $this.Log.Leave()
            return $result
        }
        catch {
            $this.Log.Error("METHOD:  GetProjectItem", $_)
            throw
        }
    }

    hidden [FileSystemInfo] GetMainFolderItem([string] $ItemName) {
        try {

            $this.Log.Enter("METHOD: GetMainFolderItem")
            $result = Get-Item (Join-Path $this.MainFolder $ItemName)
            $this.Log.Leave()
            return $result
        }
        catch {
            $this.Log.Error("METHOD:  GetMainFolderItem", $_)
            throw
        }
    }

    hidden [FileSystemInfo] GetModuleFolder([string] $FolderName) {
        try {

            $this.Log.Enter("METHOD: GetModuleFolder")
            $result = Get-Item (Join-Path $this.ModulesFolder $FolderName)
            $this.Log.Leave()
            return $result
        }
        catch {
            $this.Log.Error("METHOD:  GetModuleFolder", $_)
            throw
        }
    }

    #region ● Create New Modules 
    [FileSystemInfo] NewFunctionModule([string]$ModuleName, [string]$Content) {
        $this.Log.Enter("METHOD: NewFunctionModule")
        $result = $this.GetFunctionModuleFilePath($ModuleName)

        $Content | Set-Content -Path $result -Encoding UTF8
        $this.Log.Leave()
        return $result
    }

    [FileSystemInfo] GetFunctionModuleFilePath([string]$ModuleName) {
        try {

            $this.Log.Enter("METHOD: GetFunctionModuleFilePath")
            $result = Get-Item (Join-Path $this.FunctionModulesFolder "$ModuleName.psm1")
            $this.Log.Leave()
            return $result
        }
        catch {
            $this.Log.Error("METHOD: GetFunctionModuleFilePath", $_)
            throw
        }
    }

    [FileSystemInfo] NewClassModule([string]$ModuleName, [string]$Content) {
        $this.Log.Enter("METHOD: NewClassModule")
        $result = $this.GetClassModuleFilePath($ModuleName)

        $Content | Set-Content -Path $result -Encoding UTF8
        $this.Log.Leave()
        return $result
    }

    [FileSystemInfo] GetClassModuleFilePath([string]$ModuleName) {
        try {

            $this.Log.Enter("METHOD: GetClassModuleFilePath")
            $result = Get-Item (Join-Path $this.ClassModulesFolder "$ModuleName.psm1")
            $this.Log.Leave()
            return $result
        }
        catch {
            $this.Log.Error("METHOD: GetClassModuleFilePath", $_)
            throw
        }
    }
    #endregion
}

# This is a module scoped variable which stores the parent directory path of this file
$projectTemplateName = [ProjectPaths]::ProjectTemplateName
$scriptRoot = $PSScriptRoot

Write-Host
Write-Host "------------------------------------------------------------------------"
Write-Host "Bops.Lib! [M]: Bops.Lib.Project.psm1"
Write-Host "------------------------------------------------------------------------"
Write-Host "         `$projectTemplateName = $projectTemplateName"
Write-Host "                  `$scriptRoot = $scriptRoot"
$script:ProjectTemplateFolder = Get-Item (Join-Path -Path $scriptRoot -ChildPath $projectTemplateName)
Write-Host "`$script:ProjectTemplateFolder = $($script:ProjectTemplateFolder)"
Write-Host "========================================================================"
Write-Host

class ProjectSettings {
    [string]$Root
    [Type]$Type

    ProjectSettings([string]$Root, [Type]$Type) {
        $this.Root = $Root
        $this.Type = $Type
    }

    [object] Get() {
        # Write-Host "    --> ProjectSettings.Get()"
        $jsonPath = (New-Object ProjectPaths $this.Root).SettingsJson

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

function New-FunctionModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Name,

        [string] $Prefix = $null,
        [string] $Verb = $null
    )

    $paths = [ProjectPaths]::newName((Get-Location))
    $moduleName = Get-NameWithPrefix -Name:$Name -Prefix:$Prefix Separator "."
    $content = Get-FunctionModuleContent -MethodName:$Name -Verb:$Verb

    try {
        $fullPath = $paths.NewFunctionModule($moduleName, $content)
        Write-Host "[✅] Method module created: $fullPath"
    }
    catch {
        Write-Error "❌ Failed to create module: $_"
    }
}

function Get-FunctionModuleContent {
    param(
        [string]$Name,
        [string]$Verb = $null
    )

    $functionName = Get-NameWithPrefix -Name:$Name -Prefix:$Verb -Separator '-'

    return @"
function $functionName {
    `$Log.Start(`"$functionName`")
    `$Log.Error(`"NOT IMPLEMENTED`")
    PrivateMethod
}

function PrivateMethod {
    `$Log.Enter(`"PrivateMethod`")
    `$Log.Error(`"NOT IMPLEMENTED`")
    `$Log.Note(`"This is a note...`")
    `$Log.Leave()
}

Export-ModuleMember -Function '$functionName'
"@
}

function Get-NameWithPrefix {
    param (
        [string] $Name,
        [string] $Prefix = $null,
        [string] $Separator
    )

    $prefixValue = Get-Suffix -StringToSuffix:$Prefix -Suffix:$Separator

    $result = Remove-WhiteSpace "$prefixValue$Name"

    return $result
}

function New-ClassModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string]$Prefix = $null
    )

    $paths = [ProjectPaths]::newName((Get-Location))
    $moduleName = Get-NameWithPrefix -Name:$Name -Prefix:$Prefix -Separator "."
    $className = Remove-WhiteSpace $Name

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
class $className {
    $className() {

    }
}
"@

    try {
        $fullPath = $paths.NewClassModule($moduleName, $classContent)
        Write-Host "[✅] Class module created: $fullPath"
    }
    catch {
        Write-Error "❌ Failed to create module: $_"
    }
}

function Get-Suffix {
    param (
        [string] $Text = $null,
        [string] $Suffix
    )

    [string] $result = [string]::IsNullOrEmpty($Text) `
        ? '' `
        : (Remove-WhiteSpace "$Text$Suffix")
    
    return $result
}

function Remove-WhiteSpace {
    param (
        [string] $Text
    )

    return $Text -replace '\s', ''
}

function New-PowerShellProject {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    Write-Host
    Write-Host "New-PowerShellProject ($Name)"

    $new = Join-Path -Path (Get-Location) -ChildPath $Name


    Write-Host "    `$new = $new"

    if (Test-Path $new) {
        Write-Warning "Project folder already exists: $new"
        return
    }

    New-Item -Path $new -ItemType Directory -Force | Out-Null

    $source = $script:ProjectTemplateFolder

    Write-Host "    `$source = $source"

    Copy-Item -Path (Join-Path $source.FullName '*') -Destination $new -Recurse -Force

    Write-Host "✅ PowerShell project '$Name' created at: $new"
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
    'New-FunctionModule', `
    'New-ClassModule', `
    'New-PowerShellProject', `
    'New-CsTypeModule'
 



