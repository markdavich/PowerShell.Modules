param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$rawUrl
)

function LogIt {
    param (
        [string]$Text
    )
    
    $logPath = Join-Path $env:LOCALAPPDATA 'psloc\handler.txt'
    Add-Content -Path $logPath -Value $Text
}

LogIt "Entering handler.ps1"

try {
    # Remove quotes that the shell might pass
    $rawUrl = $rawUrl.Trim('"')

    # Strip protocol prefix
    if ($rawUrl -like 'psloc://*') {
        $value = $rawUrl.Substring(8)
    } else {
        $value = $rawUrl
    }

    LogIt "1. `$value = |$value|"
    
    # Ignore query / fragment if present
    $value = $value.Split('?',2)[0].Split('#',2)[0]

    LogIt "2. `$value = |$value|"
    
    # Decode URL encoding and normalize slashes
    $value = [System.Uri]::UnescapeDataString($value)

    LogIt "3. `$value = |$value|"

    $value = $value -replace '/', '\'

    LogIt "4. `$value = |$value|"

    if ([string]::IsNullOrWhiteSpace($value)) {
        LogIt "`$value IS Null or WhiteSpace, EXIT 0"
        exit 0
    }

    # If a file is passed, use its directory
    if (Test-Path -LiteralPath $value -PathType Leaf) {
        $targetPath = (Split-Path -LiteralPath $value -Parent)
    } else {
        $targetPath = $value
    }

    LogIt "1. `$targetPath = |$targetPath|"

    if (-not (Test-Path -LiteralPath $targetPath -PathType Container)) {
        $logPath = Join-Path $env:LOCALAPPDATA 'psloc\handler.log'
        $msg = "{0} Invalid location: {1}" -f (Get-Date), $targetPath
        Add-Content -Path $logPath -Value $msg
        exit 1
    }

    $escaped = $targetPath.Replace("'", "''")

    LogIt "`$escaped = |$escaped|"

    $cmd = "Set-Location -LiteralPath '$escaped'"


    LogIt "`$cmd = |$cmd|"

    $commandFile = Join-Path $env:LOCALAPPDATA 'psloc\command.ps1'

    LogIt "`$commandFile = |$commandFile|"

    LogIt "Set-Content -Path '$commandFile' -Value '$cmd' -Encoding UTF8"

    Set-Content -Path $commandFile -Value $cmd -Encoding UTF8
}
catch {
    $logPath = Join-Path $env:LOCALAPPDATA 'psloc\handler.log'
    $msg = "{0} Error: {1}" -f (Get-Date), $_
    Add-Content -Path $logPath -Value $msg
    exit 1
}
