$ModulePath = "C:\.lib!\Modules"
<#

Clone Repo in C:\Code\Repos\
Rename repo folder to .bops.lib!

Create symbolic link using Admin PowerShell
    New-Item -ItemType SymbolicLink -Path "C:\.lib!" -Target "C:\Code\Repos\.bops.lib!"

Profiles
    Move all the profiles from
        .json: Profiles.PowerShell7.Hosts
    to
        .\Profiles\Users\[UserName]

    Copy all the PowerShell 7 profiles in
        .\Profiles\c.users.username.documents.PowerShell
    to the locations (Path) listed in .json: Profiles.PowerShell7.Hosts

#>

# Copy .\Profiles\...\*profile.ps1 to correct locations
# Copy .uninstall.ps1 to C:\.lib!.uninstall.ps1
# Add bops to the path
<#
#>
$EnvironmentVariables = [PSCustomObject]@{
    System = "Machine"
    User = "User"
    Process = "Process"
    PSModulePath = "PSModulePath"
}

$CurrentPSModulePath = [Environment]::GetEnvironmentVariable($EnvironmentVariables.PSModulePath, $EnvironmentVariables.System)

$PSModulePath = "$ModulePath;"

if (-not [string]::IsNullOrWhiteSpace($CurrentPSModulePath)) {
    if (-not ($CurrentPSModulePath -Split ';' -contains $ModulePath)) {
        $PSModulePath += $CurrentPSModulePath
    } else {
        $PSModulePath = $CurrentPSModulePath
    }
}

[Environment]::SetEnvironmentVariable($EnvironmentVariables.PSModulePath, $PSModulePath, $EnvironmentVariables.System)