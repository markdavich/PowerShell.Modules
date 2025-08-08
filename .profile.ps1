# using module Bops.Lib.Setup
using module Bop.U.Json
using module User.Common
using module Bops.Lib.Setup.Classes.Command
using module Bops.Lib.Setup


# Write-Host "<[" -ForegroundColor Green -NoNewline
# Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
# Write-Host "[P] " -ForegroundColor Blue -NoNewline
# Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
# Write-Host "]" -ForegroundColor Green

Write-Host
Write-Host "╭──────────────────────────────╮" -ForegroundColor Blue
Write-Host "│ " -ForegroundColor Blue -NoNewline;
Write-Host    "Bops.Lib! PowerShell Profile" -ForegroundColor Magenta -NoNewline;
Write-Host " │" -ForegroundColor Blue
Write-Host "╰──────────────────────────────╯" -ForegroundColor Blue
Write-Host "Running" -ForegroundColor Yellow -NoNewline;
Write-Host ": " -ForegroundColor Magenta -NoNewline;
Write-Host $PSScriptRoot -ForegroundColor DarkCyan -NoNewline;
Write-Host "\.profile.ps1" -ForegroundColor Cyan;
Write-Host

Write-Host

function Get-MajorPSVersion {
    $ver = $PSVersionTable.PSVersion
    $major = $ver.Major
    return $major
}

function Get-MajorMinorPSVersion {
    $ver = $PSVersionTable.PSVersion
    $result = "$($ver.Major).$($ver.Minor)" 
    return $result
}

function Get-FullPSVersion {
    return $PSVersionTable.PSVersion -join "."
}

function Get-PSVersionString {
    $verString = "(v $(Get-FullPSVersion))"

    if ((Get-MajorPSVersion) -eq "5") {
        return "Windows PowerShell $verString"
    }
    else {
        return "PowerShell $verString"
    }
}

function Get-Exe {
    $ver = Get-MajorPSVersion

    switch ($ver) {
        5 { 
            return (Get-Command powershell.exe | Select-Object -ExpandProperty Source)
        }

        7 {
            return (Get-Command pwsh.exe | Select-Object -ExpandProperty Source)
        }

        Default {
            return "Version '$ver' not accounted for. Use Open-Profile to add it"
        }
    }
}

function Write-Parameters {
    param (
        [string[]] $params
    )

    if (-not $params -or $params.Count -eq 0) {
        return;
    }

    Write-Host "(" -ForegroundColor Magenta -NoNewline;
    
    for ($i = 0; $i -lt $params.Count; $i++) {
        Write-Host $params[$i].Trim() -ForegroundColor DarkCyan -NoNewline;

        if ($i -lt $params.Count - 1) {
            Write-Host ", " -ForegroundColor DarkGray -NoNewline;
        }
    }

    Write-Host ")" -ForegroundColor Magenta -NoNewline;
}

function Write-Alias {
    param (
        [string] $alias,
        [int] $length = 0
    )

    if (-not $alias -or $alias.Trim().Length -eq 0) {
        Write-Host (" " * ($length + 4)) -NoNewline;
        return;
    }

    Write-Host " [" -ForegroundColor DarkGreen -NoNewline;
    Write-Host $alias -ForegroundColor Yellow -NoNewline;
    Write-Host "] " -ForegroundColor DarkGreen -NoNewline;
}

function Write-ProfileCommands {
    $env:LC_ALL = 'C.UTF-8'

    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::UTF8

    $commands = (Get-UserSettings).commands | ForEach-Object { `
            [PSCustomObject] @{ `
                Icon    = $_.Icon
            Alias       = $_.Alias
            Name        = $_.Name
            Params      = $_.Params
            Description = $_.Description

            AliasLength = $_.Alias.Length
            Length      = $_.Params.Count -gt 0 `
                ? $_.Name.Length `
                + 2 `
                + ($_.Params | Measure-Object -Property Length -Sum).Sum `
                + ($_.Params.Count - 1) * 2 `
                : $_.Name.Length 
        }
    }

    $maxLength = ($commands | Measure-Object -Property Length -Maximum).Maximum
    $maxAliasLength = ($commands | Measure-Object -Property AliasLength -Maximum).Maximum

    $commands | ForEach-Object {
        Write-Host "  $($_.Icon) " -NoNewline;

        Write-Host $_.Name -ForegroundColor DarkYellow -NoNewline;
        
        Write-Parameters -params $_.Params;
        Write-Host (" " * ($maxLength - $_.Length)) -NoNewline;
        Write-Alias -alias $_.Alias -length $maxAliasLength;
        Write-Host "► " -ForegroundColor Cyan -NoNewline;
        Write-Host $($_.Description) -ForegroundColor Green;
    }
}

function Write-Heading {
    $explorerLocation = Get-ExplorerLocation

    Write-Host "$(Get-PSVersionString)"
    Write-Host "-------------------------------------------------------------------------------"
    Write-Host "             .exe : $(Get-Exe)"
    Write-Host "          Profile : $Profile"
    Write-Host "Explorer Location " -ForegroundColor Cyan -NoNewline
    Write-Host ": " -ForegroundColor Magenta -NoNewline  
    Write-Host -ForegroundColor Yellow $explorerLocation
    Write-Host "-------------------------------------------------------------------------------"
    Write-Host "Commands" -NoNewline;
    Write-Host " [" -ForegroundColor DarkGreen -NoNewline;
    Write-Host "Alias" -ForegroundColor Yellow -NoNewline;
    Write-Host "]" -ForegroundColor DarkGreen;
    Write-ProfileCommands
    Write-Host ""
}

function Open-Profile {
    if (-not (Test-Path $Profile)) {
        New-Item -Path $Profile -Force 
    }

    code $Profile
}

function Initialize-Profile {
    Update-Modules
    . $Profile
}

function Set-Aliases {
    Set-Alias op Open-Profile -Scope Global
    Set-Alias lp Initialize-Profile -Scope Global
    Set-Alias ce Set-ExplorerLocation -Scope Global
    Set-Alias re Reset-ExplorerLocation -Scope Global
    Set-Alias ou Open-UserSetupJson -Scope Global
}

function main {
    Write-Heading
    Initialize-Explorer
    Set-Aliases
}

main

