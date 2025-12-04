using namespace System.IO

using module Bop.U.Logger
using module Bop.U.Json
using module Bop.U.Parser.Json
using module Bop.U.Variable
using module Bop.U.Variable.Logger
using module Bop.U.FileSystem
using module Cs.Type.CoreMarshal

using module '.\Bops.Lib.Setup.Config.psm1'

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

# ╭───────────────╮
# │ Configuration │
# ╰───────────────╯
# Constants
$configuration = @(
    (Add-Local 'ExplorerRegistryKey' 'HKCU:\SOFTWARE\Classes\CLSID\{52205fd8-5dfb-447d-801a-d0b52f2e83e1}'),
    (Add-Local 'ExplorerCommandRegistryKey' "$ExplorerRegistryKey\shell\opennewwindow\command"),
    (Add-Local 'ModulePath' $MyInvocation.MyCommand.Path),
    (Add-Local 'SettingsJsonFile' (Get-CompanionName -FileString $ModulePath -CompanionExtension 'json')),
    (Add-Local 'ConfigJsonFile' (Get-CompanionName -FileString $ModulePath -CompanionExtension 'Config.json')),
    (Add-Local 'Config' ([JsonParser]::new($ConfigJsonFile, [Config]).GetInstance())),
    (Add-Local 'VbsPath' (Join-Path ([System.IO.Path]::GetDirectoryName($ModulePath)) $Config.VbsFileName)),
    (Add-Local 'VbsDefaultContent' (Join-Path ([System.IO.Path]::GetDirectoryName($ModulePath)) $Config.VbsDefaultContent))
)

# Write-Host
# [VariableLogger]::Print("Bops.Lib.Setup Configuration Variables", $configuration, [System.ConsoleColor]::Cyan)
# Write-Host

function Get-ExplorerLocation {
    $settings = Get-UserSettings
    $result = $settings.locations.explorer
    return $result
}

function Set-StartupLocations {
    [CmdletBinding()]
    param (
        [string] $Location = (Get-Location).Path
    )

    Set-ExplorerLocation $Location
    Set-TerminalStartupDirectory $Location
    Set-VisualStudioProjectsFolder $Location
}

function Set-VisualStudioProjectsFolder {
    [CmdletBinding()]
    param (
        [string] $Location = (Get-Location).Path
    )

    # Normalize the path
    $Location = (Resolve-Path $Location).Path

    $setting = Get-UserSettings
    $setting.locations.visualStudio = $Location

    # Build the full path to the CurrentSettings.vssettings file
    $settingsPath = Resolve-Path $setting.settingsFiles.visualStudio.file

    if (-not (Test-Path $settingsPath)) {
        Write-Error "Settings file not found at $settingsPath"
        return
    }

    $settingsFolder = [System.IO.Path]::GetDirectoryName($settingsPath)
    $settingsFileName = [System.IO.Path]::GetFileName($settingsPath)

    # Backup
    # $backupPath = ".bak.$(Get-Date -Format 'yyyyMMdd.HHmmss').$settingsPath"
    $backupPath = Join-Path -Path $settingsFolder -ChildPath ".bak.$(Get-Date -Format 'yyyyMMdd.HHmmss').$settingsFileName"
    Copy-Item $settingsPath $backupPath -Force
    Write-Host "Backup created at: $backupPath" -ForegroundColor Yellow

    # Load XML
    [xml]$xml = Get-Content -Path $settingsPath -Raw

    # --- 1) ProjectsLocation -----------------------------------------------
    $projectLocationNode = $xml.SelectSingleNode("//PropertyValue[@name='ProjectsLocation']")
    if ($null -eq $projectLocationNode) {
        Write-Error "Could not find 'ProjectsLocation' node in the settings file."
    }
    else {
        $projectLocationNode.InnerText = $Location
        Write-Host "Updated ProjectsLocation to: $Location" -ForegroundColor Green
    }

    # --- 2) DefaultRepositoryPath (Git Scc Provider) ------------------------
    # Try to find the Git category (VS usually writes it as a top-level <Category>)
    $gitCategory = $xml.SelectSingleNode("//Category[@RegisteredName='Git Version Control_GitSccProvider']")

    if ($null -eq $gitCategory) {
        # Create the category if it doesn't exist (placed under /UserSettings)
        $userSettings = $xml.UserSettings
        if ($null -eq $userSettings) {
            Write-Error "Root <UserSettings> element not found; cannot create Git category."
            return
        }

        $gitCategory = $xml.CreateElement("Category")

        # Populate the common attributes (these match what VS typically writes)
        $gitCategory.SetAttribute("name", "Git Version Control_GitSccProvider")
        $gitCategory.SetAttribute("RegisteredName", "Git Version Control_GitSccProvider")
        $gitCategory.SetAttribute("PackageName", "SccProviderPackage")
        $gitCategory.SetAttribute("Category", "{33a4cda9-b7a6-3f4f-9e1f-e4d71f0a9cfa}")
        $gitCategory.SetAttribute("Package", "{7fe30a77-37f9-4cf2-83dd-96b207028e1b}")

        [void]$userSettings.AppendChild($gitCategory)
        Write-Host "Created Git Scc Provider category." -ForegroundColor Yellow
    }

    # Upsert the DefaultRepositoryPath property
    $defaultRepoNode = $gitCategory.SelectSingleNode("./PropertyValue[@name='DefaultRepositoryPath']")
    if ($null -eq $defaultRepoNode) {
        $defaultRepoNode = $xml.CreateElement("PropertyValue")
        $defaultRepoNode.SetAttribute("name", "DefaultRepositoryPath")
        [void]$gitCategory.AppendChild($defaultRepoNode)
        Write-Host "Created DefaultRepositoryPath property." -ForegroundColor Yellow
    }

    $defaultRepoNode.InnerText = $Location
    Write-Host "Updated DefaultRepositoryPath to: $Location" -ForegroundColor Green

    # Save
    $xml.Save($settingsPath)
    Write-Host "Settings saved to: $settingsPath" -ForegroundColor Cyan

    # Optional: quick verification lines
    $verify = @(
        (Select-String -Path $settingsPath -SimpleMatch "ProjectsLocation").Line
        (Select-String -Path $settingsPath -SimpleMatch "DefaultRepositoryPath").Line
    ) | Where-Object { $_ } | ForEach-Object { $_.Trim() }

    if ($verify.Count) {
        Write-Host "Verification:" -ForegroundColor Gray
        $verify | ForEach-Object { Write-Host $_ }
    }

    Write-Host ""
    Write-Host "Next step: Import or reset settings so VS picks them up:" -ForegroundColor DarkCyan
    Write-Host '  devenv /ResetSettings "PATH\TO\CurrentSettings.vssettings"' -ForegroundColor DarkCyan

    Sync-VisualStudioSettings $settingsPath
}

function Sync-VisualStudioSettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$SettingsPath
    )

    $settings = (Resolve-Path $SettingsPath).Path

    # Find devenv.exe (VS 2022) via vswhere or common path
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    $devenv = $null
    if (Test-Path $vswhere) {
        $devenv = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property productPath 2>$null
    }
    if (-not $devenv) {
        $devenv = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe"
    }

    $vsRunning = Get-Process -Name devenv -ErrorAction SilentlyContinue

    if ($vsRunning) {
        # --- Try DTE import first (same instance, no restart)
        try {
            $dte = Get-VsDte -Version '17.0'   # helper from previous message
            $dte.MainWindow.Visible = $true
            $dte.MainWindow.Activate()
            $dte.ExecuteCommand('Tools.ImportandExportSettings', "/import:`"$settings`"")
            Write-Host "✔ Imported settings into the running Visual Studio instance." -ForegroundColor Green
            return
        }
        catch {
            Write-Warning "Could not access the running VS via DTE (likely elevation/session mismatch). Falling back to /Command…"
            # This starts (or reuses) VS and runs the command to import settings.
            # Works even if another instance is open.

            $arguments = "/Command `"Tools.ImportandExportSettings /import:$settings`""
            $command = "`"Tools.ImportandExportSettings /import:$settings`""
            # $process = Start-Process -FilePath $devenv -ArgumentList $arguments -PassThru
            # Think -seconds 20
            # $process.Kill()

            $dte = [CoreMarshal]::GetActiveObject("VisualStudio.DTE.17.0")
            # $dte.ExecuteCommand("Tools.ImportandExportSettings", '/import:'+$filenameEscaped)
            $dte.ExecuteCommand('Tools.ImportandExportSettings', "/import:`"$settings`"")
            # Start-Process -FilePath $devenv -ArgumentList @('/Command', "Tools.ImportandExportSettings /ResetSettings `"$settings`"") -Wait
            Write-Host "✔ Imported settings via /Command." -ForegroundColor Green
            return
        }
    }
    else {
        # VS not running → do a full reset with the file
        Start-Process -FilePath $devenv -ArgumentList @('/ResetSettings', "`"$settings`"") -Wait
        Write-Host "✔ Visual Studio reset with your settings file." -ForegroundColor Green
    }
}

function Get-VsDte {
    [CmdletBinding()]
    param(
        [ValidateSet('17.0','16.0','15.0')]
        [string]$Version = '17.0'
    )

    $progId = "VisualStudio.DTE.$Version"

    # This scriptblock does the COM call; we'll run it on an STA thread.
    $getDteScript = {
        param($progId)

        $dte = $null
        # Try GetActiveObject if available in this runtime
        try {
            $marshalType = [System.Runtime.InteropServices.Marshal]
            $mi = $marshalType.GetMethod('GetActiveObject', [Type[]]@([string]))
            if ($mi) {
                $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject($progId)
            }
        } catch { }

        # Fallback: BindToMoniker to the ROT (works even when GetActiveObject isn't present)
        if (-not $dte) {
            try {
                $dte = [System.Runtime.InteropServices.Marshal]::BindToMoniker("!$progId")
            } catch { }
        }

        if (-not $dte) { throw "No running Visual Studio instance found for $progId." }
        return $dte
    }

    # Ensure STA apartment for the COM call
    if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
        $ps = [PowerShell]::Create()
        try {
            $ps.Runspace.ApartmentState = 'STA'
            $null = $ps.AddScript($getDteScript).AddArgument($progId)
            $res = $ps.Invoke()
            if ($ps.Streams.Error.Count) { throw $ps.Streams.Error[0] }
            return $res[0]
        } finally {
            $ps.Dispose()
        }
    } else {
        & $getDteScript $progId
    }
}


function Set-ExplorerLocation {
    [CmdletBinding()]
    param (
        [string] $Location = (Get-Location).Path
    )
    
    if (-not (Test-Path $Location)) {
        Write-Host
        Write-Host "!!! Location Does Not Exist" -ForegroundColor Red
        Write-Host "-->  $Location" -ForegroundColor Magenta
        Write-Host
        Write-Host "Please pick a different location"
        Write-Host
        return
    }

    $settings = Get-UserSettings
    $settings.locations.explorer = $Location
    Save-UserSettings $settings $env:USERNAME
    Update-VbsWithNewLocation $Location
}

function Set-TerminalStartupDirectory {
    [CmdletBinding()]
    param (
        [string] $Location = (Get-Location).Path
    )

    $settings = Get-UserSettings
    $startingDirectory = $settings.installs.terminal.settings.startingDirectory
    $terminalJsonPath = Resolve-Path $settings.installs.terminal.settings.path.powershell

    $terminalJson = Get-Json $terminalJsonPath

    Set-JsonValue -hash $terminalJson -path $startingDirectory -value $Location

    Save-Json $terminalJson $terminalJsonPath
}

function Update-VbsWithNewLocation {
    param (
        [string] $Location
    )

    $fallback = 'C:\'
    $content = @"
Dim fso, shell, path, defaultPath
Set fso = CreateObject(`"Scripting.FileSystemObject`")
Set shell = CreateObject(`"Wscript.Shell`")

If fso.FolderExists(`"$Location`") Then
    shell.Run `"$Location`"
Else
    ' fallback location if missing
    shell.Run `"$fallback`"
End If
"@

    Set-Content -Path $VbsPath -Value $content -Encoding ASCII
}

function Initialize-Explorer {
    
    $location = Get-ExplorerLocation

    if (-not $location) {
        Write-Host "No location set in JSON. Please set a location first."
        return
    }

    Update-VbsWithNewLocation $location

    # Add or update registry entry
    if (-not (Test-Path $ExplorerCommandRegistryKey)) {
        New-Item -Path $ExplorerCommandRegistryKey -Force | Out-Null
    }

    Set-ItemProperty -Path $ExplorerCommandRegistryKey -Name '(default)' -Value "wscript.exe `"$vbsPath`""
    Set-ItemProperty -Path $ExplorerCommandRegistryKey -Name 'DelegateExecute' -Value ""
}

function Reset-ExplorerLocation {
    # # Remove registry entry
    # $regKey = "HKCU:\SOFTWARE\Classes\CLSID\{52205fd8-5dfb-447d-801a-d0b52f2e83e1}"
    # if (Test-Path $regKey) {
    #     Remove-Item -Path $regKey -Recurse -Force
    #     Write-Host "Registry entry removed."
    # }
    # Write-Host "Explorer location reset."

    # Remove registry entry

    if (Test-Path $ExplorerRegistryKey) {
        Remove-Item -Path $ExplorerRegistryKey -Recurse -Force
        Write-Host "Registry entry removed."
    }

    Write-Host "Explorer location reset."
}

function Write-RunningProfileHeader
{
    param (
        [string]$Name,
        [string]$Path
    )

    [Logger]$log = [Logger]::new()

    $line = "─" * ($Name.Length + 2)

    Write-Host
    Write-Host "╭" -ForegroundColor Blue -NoNewline
    Write-Host $line -ForegroundColor Blue -NoNewline
    Write-Host "╮" -ForegroundColor Blue

    Write-Host "│ " -ForegroundColor Blue -NoNewline;
    Write-Host  $Name -ForegroundColor Magenta -NoNewline;
    Write-Host " │" -ForegroundColor Blue

    Write-Host "╰" -ForegroundColor Blue -NoNewline
    Write-Host $line -ForegroundColor Blue -NoNewline
    Write-Host "╯" -ForegroundColor Blue

    Write-Host " Running Profile" -ForegroundColor Yellow -NoNewline;
    Write-Host ": " -ForegroundColor Magenta

    $profileName = [Path]::GetFileName($Path)
    $root = [Path]::GetDirectoryName($Path)

    $profileDirLink = "`e]8;;$root`e\$root`e]8;;`e\"
    $profileLink    = "`e]8;;$Path`e\$profileName`e]8;;`e\"
    
    $log.ListTextColor = [System.ConsoleColor]::Cyan
    $log.ListItem("📜", $profileLink)
    $log.ListTextColor = [System.ConsoleColor]::DarkCyan
    $log.ListItem("📁", $profileDirLink)

}

Export-ModuleMember -Function *

