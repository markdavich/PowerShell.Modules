using module '.\Bops.Lib.Setup.Command.psm1'

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

class Profile {
    $locations
    [Command[]]$commands
    $installs

    Profile($locations, [Command[]]$commands, $installs) {
        $this.locations = $locations
        $this.commands = $commands
        $this.installs = $installs
    }
}

