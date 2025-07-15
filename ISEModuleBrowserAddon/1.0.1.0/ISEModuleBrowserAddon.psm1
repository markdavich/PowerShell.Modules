#requires -Version 3

# Imports Localized Data
if ($Host.Name -ne "Windows PowerShell ISE Host")
{
  Write-Warning "This module does only run inside PowerShell ISE"
  return
}

# Adds Module Browser to Windows PowerShell ISE.
Add-Type -Path $PSScriptRoot\ISEModuleBrowserAddon.dll -PassThru
$typeModuleBrowser = [ModuleBrowser.Views.MainView]
$moduleBrowser = $psISE.CurrentPowerShellTab.VerticalAddOnTools.Add('Module Browser', $typeModuleBrowser, $true)
$psISE.CurrentPowerShellTab.VisibleVerticalAddOnTools.SelectedAddOnTool = $moduleBrowser
     


 