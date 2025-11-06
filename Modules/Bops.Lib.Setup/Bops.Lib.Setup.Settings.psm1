using module Bop.U.Json
using module Bops.Lib.Setup.Classes.Command
using module Bops.Lib.Setup.Classes.Profile
using module Bop.U.Logger

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

$ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$JsonPath = Join-Path $ModulePath 'Bops.Lib.Setup.json'
$Logger = [Logger]::new()

# Default JSON structure
$defaultSettings = @{
    profiles = @{
        default = @{
            locations     = @{
                explorer     = "C:\Code\Repos"
                visualStudio = "C:\Code\Repos"
                terminal     = "C:\Code\Repos"
                vsCode       = "C:\Code\Repos"
            }
            settingsFiles = @{
                visualStudio = @{
                    file       = "$env:LOCALAPPDATA\Microsoft\VisualStudio\17.0_b2d1ddb7\settings\CurrentSettings.vssettings"
                    properties = @{
                        projectsLocation = "PropertyValue[@name='ProjectsLocation']"
                    }
                }
                terminal     = @{
                    file       = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
                    properties = @{
                        startingDirectory = "profiles.defaults.startingDirectory"
                    }
                }
                vsCode       = @{
                    file       = "$env:APPDATA\Code\User\settings.json"
                    properties = @{
                        startingDirectory = "files.defaultWorkspace"
                    }
                }
            }
            commands      = @(
                @{
                    name        = "Open-Profile"
                    alias       = "op"
                    description = "Open the PowerShell profile in the default editor."
                    params      = @()
                    icon        = "📜"
                },
                @{
                    name        = "Load-Profile"
                    alias       = "lp"
                    description = "Reload the PowerShell profile."
                    params      = @()
                    icon        = "🔄"
                },
                @{
                    name        = "Format-Json"
                    alias       = ""
                    description = "Format JSON strings with standard indentation."
                    params      = @("json")
                    icon        = "🪄"
                },
                @{
                    name        = "Save-Json"
                    alias       = ""
                    description = "Save JSON to a file with proper formatting."
                    params      = @("json", "path")
                    icon        = "💾"
                },
                @{
                    name        = "Set-StartupLocations"
                    alias       = "ss"
                    description = "Set startup locations for Explorer, Terminal, and Visual Studio."
                    params      = @("path")
                    icon        = "🚀"
                },
                @{
                    name        = "Set-ExplorerLocation"
                    alias       = "se"
                    description = "Change the current Explorer location."
                    params      = @("path")
                    icon        = "🚀"
                },
                @{
                    name        = "Reset-ExplorerLocation"
                    alias       = "re"
                    description = "Reset the Explorer location to the default."
                    params      = @()
                    icon        = "🧑‍🚀"
                },
                @{
                    name        = "Open-UserSetupJson"
                    alias       = "ou"
                    description = "Open the User Setup JSON file."
                    params      = @()
                    icon        = "📝"
                }
            )
            installs      = @{
                vsCode   = @{
                    install         = "Microsoft.VisualStudioCode"
                    extensions      = @("yzhang.markdown-all-in-one")
                    "settings.json" = @{
                        file    = "$env:APPDATA\Code\User\settings.json"
                        content = @{
                            "security.workspace.trust.untrustedFiles" = "open"
                            "editor.rulers"                           = @(
                                @{ column = 80; color = "#00ff6a50" }
                                @{ column = 85; color = "#ff000050" }
                            )
                        }
                    }
                }
                terminal = @{
                    settings = @{
                        path              = @{
                            powershell = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
                            absolute   = "C:\Users\mark.davich\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
                            env        = "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
                        }
                        startingDirectory = "profiles.defaults.startingDirectory"
                    }
                }
            }
        }
    }
}

function Save-UserSettings {
    param (
        $UserProfile,
        [string] $UserName = $env:USERNAME
    )

    try {
        Initialize-UserProfile -username $UserName
    
        $json = Get-Json -path $JsonPath
        $json.profiles[$UserName] = $UserProfile
    
        # Save the updated JSON
        Save-Json -json $json -path $JsonPath
    }
    catch {
        $Logger.Error("Saving User Settings", $_)
        throw
    }

}

function Get-UserSettings {
    param (
        [string]$username = $env:USERNAME
    )

    try {
        Initialize-UserProfile -username $username
    
        $json = Get-Json -path $JsonPath
    
        $profileData = $json.profiles.$username
    
        # Convert each command hashtable to a Command object
        $commands = [Command[]]@()
        foreach ($cmd in $profileData.commands) {
            $commands += [Command]::new(
                $cmd.name,
                $cmd.alias,
                $cmd.description,
                $cmd.params,
                $cmd.icon
            )
        }
    
        # Create and return a Profile object
        [Profile]$result = [Profile]::new(
            $profileData.locations,
            $profileData.settingsFiles,
            $commands,
            $profileData.installs
        )
    
        return $result
    }
    catch {
        $Logger.Error("Getting User Settings", $_)
        throw
    }
}

function Initialize-UserProfile {
    param (
        [string]$username = $env:USERNAME
    )

    try {
        $json = Get-Json -Path $JsonPath
        if (-not $json) { throw "Get-Json returned `$null for '$JsonPath'." }

        # Ensure 'profiles' container exists and is a hashtable
        if (-not $json.ContainsKey('profiles') -or $null -eq $json['profiles']) {
            $json['profiles'] = @{}
        }

        $profiles = [hashtable]$json['profiles']

        # Bail if already present
        if ($profiles.ContainsKey($username)) { return }

        # Deep clone the default so users don't share the same reference
        $default = $defaultSettings.profiles.default
        if ($null -eq $default) { throw "Missing `$defaultSettings.profiles.default." }

        $clone = ($default | ConvertTo-Json -Depth 100) | ConvertFrom-Json -AsHashtable

        # Add the user profile
        $profiles[$username] = $clone

        # Persist
        Save-Json -json $json -path $JsonPath
    }
    catch {
        $Logger.Error("Initializing User Profile: '$username'", $_)
        throw
    }
}

function Initialize-DefaultProfile {
    try {
        if (-not (Test-Path $JsonPath)) {
            Save-Json -json $defaultSettings -path $JsonPath
            return
        }
    
        # Load current JSON
        $json = Get-Json -path $JsonPath
    
        # Overwrite the 'default' profile with the latest $defaultSettings default profile
        $json.profiles.default = $defaultSettings.profiles.default
    
        # Save the updated JSON
        Save-Json -json $json -path $JsonPath
    }
    catch {
        $Logger.Error("Initializing Default Profile", $_)
        throw
    }
}

function main {
    Initialize-DefaultProfile
    Initialize-UserProfile
}

main

Export-ModuleMember -Function `
    'Save-UserSettings', `
    'Get-UserSettings'