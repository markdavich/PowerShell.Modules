using module User.Json
using module User.Setup.Classes.Command
using module User.Setup.Classes.Profile

Clear-Host

$modulePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$jsonPath = Join-Path $modulePath 'User.Setup.json'

Remove-Item -Path $jsonPath -ErrorAction SilentlyContinue

# Default JSON structure
$defaultSettings = @{
    profiles = @{
        default = @{
            locations = @{
                explorer   = "C:\Code\Repos"
                powershell = "C:\Code\Repos"
            }
            commands  = @(
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
            installs  = @{
                vsCode = @{
                    install         = "Microsoft.VisualStudioCode"
                    extensions      = @("yzhang.markdown-all-in-one")
                    "settings.json" = @{
                        file    = "$($env:APPDATA)\Code\User\settings.json"
                        content = @{
                            "security.workspace.trust.untrustedFiles" = "open"
                            "editor.rulers"                           = @(
                                @{ column = 80; color = "#00ff6a50" }
                                @{ column = 85; color = "#ff000050" }
                            )
                        }
                    }
                }
            }
        }
    }
}

# function Get-UserSettings {
#     param (
#         [string]$profileName = "default"
#     )

#     if (-not (Test-Path $jsonPath)) {
#         Write-Host "User.Setup.json not found at $jsonPath" -ForegroundColor Red
#         return $null
#     }

#     $json = Get-Json -path $jsonPath

#     if ($json.profiles.ContainsKey($profileName)) {
#         return $json.profiles[$profileName]
#     }
#     else {
#         Write-Host "Profile '$profileName' not found in User.Setup.json" -ForegroundColor Yellow
#         return $null
#     }
# }

function Get-UserSettings {
    param (
        [string]$username = $env:USERNAME
    )

    Write-Host "User.Setup.Settings: Get-UserSettings for user '$username'" -ForegroundColor Cyan

    Initialize-UserProfile -username $username

    $json = Get-Json -path $jsonPath
    $profileData = $json.profiles[$profile]

    # Convert each command hashtable to a Command object
    $commands = @()
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
    return [Profile]::new(
        $profileData.locations,
        $commands,
        $profileData.installs
    )
}

function Initialize-UserProfile {
    param (
        [string]$username = $env:USERNAME
    )

    Write-Host "User.Setup.Settings: Initialize-UserProfile for user '$username'" -ForegroundColor Cyan

    $json = Get-Json -path $jsonPath

    if ($json.profiles.PSObject.Properties.Name -contains $username) {
        Write-Host "User profile '$username' already exists." -ForegroundColor Yellow
        return;
    }

    # Clone the default profile for the new user
    $json.profiles | Add-Member `
        -MemberType Property `
        -Name $username `
        -Value $defaultSettings.profiles.default

    Write-Host ($json | ConvertTo-Json -Depth 23)


    # Save the updated JSON
    Save-Json -json $json -path $jsonPath
}

function Initialize-DefaultProfile {
    Write-Host "User.Setup.Settings: Initialize-DefaultProfile" -ForegroundColor Cyan
    
    if (-not (Test-Path $jsonPath)) {
        Save-Json -json $defaultSettings -path $jsonPath

        Write-Host "Created default User.Setup.json at $jsonPath" -ForegroundColor Green
        return
    }

    # Load current JSON
    $json = Get-Json -path $jsonPath

    # Overwrite the 'default' profile with the latest $defaultSettings default profile
    $json.profiles.default = $defaultSettings.profiles.default

    # Optionally update other top-level properties (like 'profile') if you want:
    # $json.profile = $defaultSettings.profile

    # Save the updated JSON
    Save-Json -json $json -path $jsonPath
}

function main {
    Write-Host "User.Setup.Settings: main" -ForegroundColor Cyan

    Initialize-DefaultProfile
    # Initialize-UserProfile
}

main