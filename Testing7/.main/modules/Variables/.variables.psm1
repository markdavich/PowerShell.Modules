using module Bop.U.Logger


$logger = [Logger]::new()
$logger.Blank()
$logger.Start("[V] Loading Variables Module")
$logger.Enter($MyInvocation.MyCommand.Path)

# Settings.json
$json = @(
    [Var]::new('PropertyOne', ($Settings.PropertyOne)),
    [Var]::new('PropertyTwo', ($Settings.PropertyTwo)),
    [Var]::new('PropertyThree', ($Settings.PropertyThree))
)

# Configuration Constants
$constants = @(
    [Var]::new('ExampleFolderName', 'ExampleFolder'),
    [Var]::new('NestedFolderName', 'NestedFolder')
)

# Derived Paths
$derived = @(
    [Var]::new('ExampleFolder', (Join-Path $ProjectRoot $ExampleFolderName)),
    [Var]::new('NestedFolder', (Join-Path $ExampleFolder $NestedFolderName))
)

# Existing Paths
$existingPaths = @(

)

# General: Singletons, Collections, and Instructional Data
$general = @(
    [Var]::new('Log', ([Logger]::new()))
)

function Show-Variables {
    Write-Host
    Write-Host "``````"
    Write-Host '# ***************************************************************************' -ForegroundColor DarkRed
    Write-Host '# Use ' -NoNewline; Write-Host ' Show-Variable ' -BackgroundColor Yellow -ForegroundColor Red -NoNewline; Write-Host ' to print this list again'
    Write-Host '# ***************************************************************************' -ForegroundColor DarkRed
    Write-Host -BackgroundColor Black
    [Vars]::Print('Settings.json', $json, [System.ConsoleColor]::Cyan)
    [Vars]::Print('Project Configuration Constants', $constants, [System.ConsoleColor]::Green)
    [Vars]::Print('Project Derived Paths', $derived, [System.ConsoleColor]::Blue)
    [Vars]::Print('Existing Paths', $existingPaths, [System.ConsoleColor]::DarkRed)
    [Vars]::Print('General: Singletons, Collections, and Instructional Data', $general, [System.ConsoleColor]::DarkGreen)
    Write-Host "``````"
    Write-Host
}

class Var {
    [string]$Name
    [object]$Value

    Var([string]$Name, [object]$Value) {
        $this.Name = $Name
        $this.Value = $Value
        $this.Set()
    }

    hidden [void] Set() {
        Remove-Variable -Name $this.Name -Force -ErrorAction SilentlyContinue

        Set-Variable `
            -Name $this.Name `
            -Value $this.Value `
            -Option ReadOnly `
            -Scope Global `
            -Force `
            -ErrorAction SilentlyContinue
    }
}

class Vars {

    static [void] Print([string]$Title, [Var[]]$Variables, [System.ConsoleColor]$Color) {
        [Vars]::PrintTitle($Title, $Color)

        $maxLength = (
            $Variables |`
                Select-Object -ExpandProperty Name |`
                Measure-Object -Property Length -Maximum
        ).Maximum + 1

        foreach ($var in $Variables) {
            $name = $var.Name
            $value = $var.Value

            Write-Host "`$$name".PadLeft($maxLength) -NoNewline -ForegroundColor Yellow;
            Write-Host ' = ' -NoNewline -ForegroundColor Magenta

            if ($value -is [array]) {
                $display = ($value | ForEach-Object { "$(" " * ($maxLength + 7))`"$_`"" }) -join ",`n"
                Write-Host "@(`n$display`n$(" " * ($maxLength + 3)))" -ForegroundColor $Color
            }
            else {
                Write-Host "`"$value`"" -ForegroundColor $Color
            }
        }
    }

    static hidden [void] PrintTitle([string]$Title, [System.ConsoleColor]$Color) {
        Write-Host '# _________________________________________________________________________' -ForegroundColor $Color
        Write-Host "# $Title" -ForegroundColor $Color
        Write-Host '# -------------------------------------------------------------------------' -ForegroundColor $Color
    }
}

Show-Variables

$logger.Note("[V]: DONE")

Export-ModuleMember -Function Show-Variables -Variable *

