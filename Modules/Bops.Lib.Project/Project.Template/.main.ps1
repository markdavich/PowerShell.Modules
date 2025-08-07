using module Bops.Lib.Project
using module Bop.U.Logger

Clear-Host
Write-Host

Set-Location $PSScriptRoot

# Dot-Source the Program Script to Access Invoke-Startup
. ".\$([ProjectPaths]::StartupScript)"

try {
    Invoke-Startup -ProjectRoot $PSScriptRoot
}
catch {
    $Log.Error(
        "Unhandled Error during startup in main",
        $_
    )
}

function Main {
    try {
        Invoke-Step_1_0_Initialize
    }
    catch {
        $Log.Error(
            "Unhandled Exception in .main.ps1",
            $_
        )
    }
}

Main

