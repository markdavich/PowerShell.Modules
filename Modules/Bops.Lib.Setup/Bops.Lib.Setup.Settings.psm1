using module Bop.U.Json
using module Bops.Lib.Setup.Classes.Command
using module Bops.Lib.Setup.Classes.Profile

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

$modulePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$jsonPath = Join-Path $modulePath 'Bops.Lib.Setup.json'

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

function Save-UserSettings {
    param (
        [string] $ProfileName,
        [string] $UserName = $env:USERNAME
    )

    Write-Host "Bops.Lib.Setup.Settings: Save-UserSettings for user '$UserName'" -ForegroundColor Cyan

    Initialize-UserProfile -username $UserName

    $json = Get-Json -path $jsonPath
    $json.profiles[$UserName] = $ProfileName

    # Save the updated JSON
    Save-Json -json $json -path $jsonPath

    Write-Host "User settings saved successfully." -ForegroundColor Green
}

function Get-UserSettings {
    param (
        [string]$username = $env:USERNAME
    )

    # Write-Host "Bops.Lib.Setup.Settings: Get-UserSettings" -ForegroundColor Green -BackgroundColor Yellow -NoNewline; Write-Host "" -ForegroundColor White -BackgroundColor Black
    # Write-Host "    `$username: '$username'" -ForegroundColor Green

    Initialize-UserProfile -username $username

    $json = Get-Json -path $jsonPath

    # Write-Host "    JSON Data"
    # Write-Host ($json | ConvertTo-Json -Depth 23)

    # Write-Host "---------------------------------------"
    # Write-Host "    User Profile: $username"
    # Write-Host "---------------------------------------"
    # Write-Host "PROFILES:"
    # Write-Host ($json.profiles | ConvertTo-Json -Depth 23)
    # Write-Host "---------------------------------------"


    $profileData = $json.profiles.$username

    # Write-Host "    Profile Data"
    # Write-Host ($profileData | ConvertTo-Json -Depth 23)

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

    # Write-Host "    Commands"
    # Write-Host ($commands | ConvertTo-Json -Depth 23)

    # Write-Host "---------------------------------------"
    # Write-Host "Converting profileData.locations Type: ($($profileData.locations.GetType().FullName)) to Hashtable"
    # [System.Management.Automation.PSCustomObject]$locations = $profileData.locations
    # Write-Host "Converting profileData.commands Type: ($($profileData.commands.GetType().FullName)) to Command[]"
    # [Command[]]$commandsParams = $commands
    # Write-Host "Converting profileData.installs Type: ($($profileData.installs.GetType().FullName)) to Hashtable"
    # [System.Management.Automation.PSCustomObject]$installs = $profileData.installs

    # Create and return a Profile object
    [Profile]$result = [Profile]::new(
        $profileData.locations,
        $commands,
        $profileData.installs
    )

    # Write-Host "Returning Profile object: $($result | ConvertTo-Json -Depth 23)"
    return $result
}

function Initialize-UserProfile {
    param (
        [string]$username = $env:USERNAME
    )
    # Write-Host "Bops.Lib.Setup.Settings: Initialize-UserProfile" -ForegroundColor Green -BackgroundColor Yellow -NoNewline; Write-Host "" -ForegroundColor White -BackgroundColor Black
    # Write-Host "    `$username: '$username'" -ForegroundColor Green

    $json = Get-Json -path $jsonPath

    if ($json.profiles.PSObject.Properties.Name -contains $username) {
        # Write-Host "User profile '$username' already exists." -ForegroundColor Yellow
        return;
    }

    # Clone the default profile for the new user
    $json.profiles | Add-Member `
        -MemberType NoteProperty `
        -Name $username `
        -Value $defaultSettings.profiles.default

    # Save the updated JSON
    Save-Json -json $json -path $jsonPath
}

function Initialize-DefaultProfile {
    # Write-Host "Bops.Lib.Setup.Settings: Initialize-DefaultProfile" -ForegroundColor Green -BackgroundColor Yellow -NoNewline; Write-Host "" -ForegroundColor White -BackgroundColor Black
    
    if (-not (Test-Path $jsonPath)) {
        Save-Json -json $defaultSettings -path $jsonPath

        # Write-Host "    Created default Bops.Lib.Setup.json at $jsonPath" -ForegroundColor Green
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
    Initialize-DefaultProfile
    Initialize-UserProfile
}

main

Export-ModuleMember -Function `
    'Save-UserSettings', `
    'Get-UserSettings'