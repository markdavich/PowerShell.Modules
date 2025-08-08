using module Bop.U.Variable

class VariableLogger {

    static [void] Print([string]$Title, [Variable[]]$Variables, [System.ConsoleColor]$Color) {
        [VariableLogger]::PrintTitle($Title, $Color)

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