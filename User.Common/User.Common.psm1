function Update-Modules {
    $coreModules = @(
        'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility', 'Microsoft.PowerShell.Security',
        'Microsoft.PowerShell.Host', 'Microsoft.PowerShell.Core', 'PSReadLine'
    )
    $modulesToReload = Get-Module | Where-Object { $_.Name -notin $coreModules } | Select-Object -ExpandProperty Name
    $modulesToReload | ForEach-Object { Remove-Module $_ -Force -ErrorAction SilentlyContinue }
    $modulesToReload | ForEach-Object { Import-Module $_ -Force -ErrorAction SilentlyContinue }
}

function Test-IsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    write-host $currentUser
    $result = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) 
    write-host $result
    return $result
}

function Update-EnvPath {
    $env:PATH = [Environment]::GetEnvironmentVariable('Path', 'Machine'),
    [Environment]::GetEnvironmentVariable('Path', 'User') -join ';'
}

function Start-Application {
    param($path)

    Write-Host ""
    Write-Host "Start-Application"
    Write-Host "    path: $path"
    Write-Host ""

    Start-Process `
        -FilePath $path `
        -NoNewWindow `
        -Wait `
        -PassThru `

    Update-EnvPath
}

function Get-AmPm {
    $hour = [int]("{0:HH}" -f $Date)

    $result = @( { "AM" }, { "PM" })[$hour -lt 13]

    return $result.ToString().Replace("""", "")
}

function Draw-Helper {
    Write-Host '¯' -ForegroundColor Green      -BackgroundColor Black -NoNewline;
    Write-Host '\' -ForegroundColor Cyan       -BackgroundColor Black -NoNewline;
    Write-Host '_' -ForegroundColor Yellow     -BackgroundColor Black -NoNewline;
    Write-Host '(' -ForegroundColor DarkGray   -BackgroundColor Black -NoNewline;
    Write-Host 'ツ'-ForegroundColor Gray       -BackgroundColor Black -NoNewline;
    Write-Host ')' -ForegroundColor DarkGray   -BackgroundColor Black -NoNewline;
    Write-Host '_' -ForegroundColor Yellow     -BackgroundColor Black -NoNewline;
    Write-Host '/' -ForegroundColor Magenta    -BackgroundColor Black -NoNewline;
    Write-Host '¯' -ForegroundColor Red        -BackgroundColor Black -NoNewline;
    Write-Host '   '                           -BackgroundColor Black;
}

function Get-MaxLength([OutputType([int])] [string[]]$values) {
    $result = (
        $values `
        | Select-Object -Property $_ `
        | ForEach-Object { $_.Length } `
        | Measure-Object -Maximum `
    ).Maximum

    return $result
}

function Get-PaddedString(
    [string]$string, 
    [int]$left, 
    [int]$length, 
    [string]$prefix = "", 
    [string]$suffix = ""
) {
    $prefix = "$prefix$(" " * $left)"
    $result = "$prefix$($string.PadRight($length))$suffix"
    return $result;    
}

function Get-PaddedArray(
    [string[]]$values, 
    [int]$left, 
    [int]$right,
    [int]$length = -1, 
    [string]$prefix = "", 
    [string]$suffix = ""
) {
    if ($length -lt 0) {
        $length = (Get-MaxLength($values)) + $right
    }

    $result = $values `
    | Select-Object -Property $_ `
    | ForEach-Object { Get-PaddedString $_ $left $length $prefix $suffix }

    return $result
}

function Ask-Question ([string[]]$question, [string[]]$commands) {
    # [int] $qLength = Get-MaxLength($question)
    # [int] $cLength = Get-MaxLength($commands)

    # [int] $length = ($qLength, $cLength | Measure-Object -Maximum).Maximum

    [int] $length = (Get-MaxLength($question + $commands)) + 2
    
    # We can do this because PowerShell passes a copy of these to the method
    $question = Get-PaddedArray $question 2 2 $length "   │" "│"
    $commands = Get-PaddedArray $commands 2 2 $length "   │" "│"
    
    [string]$top = "   ╭$("─" * ($length + 2))╮"
    [string]$gap = "   │$(" " * ($length + 2))│"
    [string]$bottom = "   ╰─╮╭$("─" * ($length - 1))╯"

    if (($null -eq $commands) -or ($commands.Length -eq 0)) {
        $question = @($top) + $question + @($bottom)    
    }
    else {
        $question = @($top) + $question + @($gap) + $commands + @($bottom)
    }

    for ($i = 0; $i -lt $question.Count; $i++) {
        Write-Host $question[$i]
        Start-Sleep -Milliseconds 75 
    }

    Draw-Helper
}

function Think([int]$seconds, [string]$prefix = "") {
    try {
        [console]::CursorVisible = $false

        [System.ConsoleColor[]]$colors = [System.Enum]::getvalues([System.ConsoleColor])
        [int]$maxColors = $colors.Count - 1
        
        [string]$chars = "♥☺☻*αβ♪♫Ω∞"

        [int]$maxChars = $chars.Length - 1

        [string[]]$dots = @(
            ".    ",
            "  .  ",
            "    ."
        )

        [int]$length = $dots[0].Length
        [int]$keyCount = $dots.Count
        [string]$back = "`b" * $length

        $dots = $dots `
        | Select-Object -Property $_ `
        | ForEach-Object { $_.ToString().Replace(".", "{0}") }
            
        [int]$i = 0
        
        [datetime]$start = Get-Date
        [datetime]$end = $start.AddMilliseconds(($seconds * 1000))
    
        Write-Host "$prefix$(" " * $length)" -NoNewline

        while ((Get-Date) -lt $end) {
            Write-Host $back -NoNewline

            [int]$color = Get-Random -Maximum $maxColors -Minimum 0
            [int]$char = Get-Random -Maximum $maxChars -Minimum 0

            [int]$key = $i % $keyCount

            [string]$line = $dots[$key] -f $chars[$char]
    
            Write-Host $line -ForegroundColor $colors[$color] -NoNewline
    
            $i++
    
            Start-Sleep -Milliseconds 75;
        }
    }
    finally {
        Write-Host ""
        [console]::CursorVisible = $true
    }
}

function Get-RelativePath {
    param (
        [string]$Path,
        [string]$RelativeRoot
    )

    return $Path -replace [regex]::Escape($RelativeRoot), ""
}

Export-ModuleMember -Function *



