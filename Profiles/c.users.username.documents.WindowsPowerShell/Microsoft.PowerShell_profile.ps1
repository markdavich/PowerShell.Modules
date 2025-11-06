

function Get-MajorPSVersion {
    $ver = $PSVersionTable.PSVersion
    $major = $ver.Major
    return $major
}

function Get-MajorMinorPSVerion {
    $ver = $PSVersionTable.PSVersion
    $result = "$($ver.Major).$($ver.Minor)" 
    return $result
}

function Get-FullPSVersion {
    return $PSVersionTable.PSVersion -join "."
}

function Get-PSVersionString {
    $ver = $PSVersionTable.PSVersion
    $verString = "(v $($ver.Major).$($ver.Minor))" 

    if (Get-MajorPSVersion -eq "5") {
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

function Write-ProfileCommands {
    $commands = @(
        "  📜  Open-Profile - Opens your profile in VS Code",
        "  🔄  Reset-Profile - Reloads your profile",
        "  🪄  Format-Json(json) - Formats JSON strings with standard indentation",
        "  💾  Save-Json(json, path) - Saves JSON to a file with proper formatting"
    )

    $names = ($commands | ForEach-Object { ($_ -split " - ")[0] }) | ForEach-Object { @($_, $_.Split("(")[0])[$_.Contains("(")] }

    $descriptions = $commands | ForEach-Object { ($_ -split " - ")[1] }

    $ni = -1
    $nli = -1

    $parameters = ($commands | ForEach-Object { ($_ -split " - ")[0] }) `
        | ForEach-Object { `
                [PSCustomObject]@{
                    Open=@("", "(")[$_.Contains("(")] 
                    Params=@("", ($_.Split("(")[1]) -replace "\)", "")[$_.Contains("(")] 
                    Close=@("", ")")[$_.Contains("(")] 
                    Length=@(-2, (($_.Split("(")[1]) -replace "\)", "").Length + 2)[$_.Contains("(")]
                    Name=$names[++$ni]
                    NameLength=$names[++$nli].Length
                }
        }

    $maxLength = ($parameters | ForEach-Object { $_.Length + $_.NameLength } | Measure-Object -Maximum).Maximum

    for ($i = 0; $i -lt $names.Length; $i++) {
        #Write-Host ""
        #Write-Host "$($maxLength) - $($parameters[$i].NameLength) - $($parameters[$i].Length) = $($maxLength - $parameters[$i].NameLength - $parameters[$i].Length) "
        Write-Host $parameters[$i].Name   -ForegroundColor DarkYellow -NoNewline;
        Write-Host $parameters[$i].Open   -NoNewline;
        Write-Host $parameters[$i].Params -ForegroundColor DarkCyan -NoNewline;
        Write-Host $parameters[$i].Close  -NoNewline;
        Write-Host (" " * ($maxLength - $parameters[$i].NameLength - $parameters[$i].Length)) -NoNewline;
        Write-Host " - $($descriptions[$i])"
    }
}


Clear-Host
Write-Host "$(Get-PSVersionString)"
Write-Host "   .exe : $(Get-Exe)"
Write-Host "Profile : $Profile"
Write-Host "-------------------------------------------------------------------------------"
Write-Host "Commands"
Write-ProfileCommands
Write-Host ""

function Open-Profile {
    if (-not (Test-Path $Profile)) {
        New-Item -Path $Profile -Force 
    }
    code $Profile
}

function Reset-Profile {
    . $Profile
}

# Formats JSON in a nicer format than the built-in ConvertTo-Json does.
function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
    $indent = 0;
    ($json -Split "`n" | ForEach-Object {
        if ($_ -match '[\}\]]\s*,?\s*$') {
            # This line ends with ] or }, decrement the indentation level
            $indent--
        }
        $line = ('  ' * $indent) + $($_.TrimStart() -replace '":  (["{[])', '": $1' -replace ':  ', ': ')
        if ($_ -match '[\{\[]\s*$') {
            # This line ends with [ or {, increment the indentation level
            $indent++
        }
        $line
    }) -Join "`n"
}

function Save-Json(
    [Parameter(Mandatory)][PSCustomObject] $json,
    [Parameter(Mandatory)][string] $path
) {
    # Old
    # ConvertTo-Json @($json) -Depth 23 | Out-File $path

    $json | ConvertTo-Json | Format-Json | Out-File $path
}