# PsLoc.psm1

$script:ConfigDir   = Join-Path $env:LOCALAPPDATA 'psloc'
$script:CommandFile = Join-Path $script:ConfigDir 'command.ps1'
$script:HandlerPath = Join-Path $script:ConfigDir 'handler.ps1'
$script:Timer       = $null
$script:Subscription = $null

function Install-PsLoc {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if (-not (Test-Path $script:ConfigDir)) {
        New-Item -ItemType Directory -Path $script:ConfigDir -Force | Out-Null
    }

    $handlerCode = @'
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$rawUrl
)

try {
    # Remove quotes that the shell might pass
    $rawUrl = $rawUrl.Trim('"')

    # Strip protocol prefix
    if ($rawUrl -like 'psloc://*') {
        $value = $rawUrl.Substring(8)
    } else {
        $value = $rawUrl
    }

    # Ignore query / fragment if present
    $value = $value.Split('?',2)[0].Split('#',2)[0]

    # Decode URL encoding and normalize slashes
    $value = [System.Uri]::UnescapeDataString($value)
    $value = $value -replace '/', '\'

    if ([string]::IsNullOrWhiteSpace($value)) {
        exit 0
    }

    # If a file is passed, use its directory
    if (Test-Path -LiteralPath $value -PathType Leaf) {
        $targetPath = (Split-Path -LiteralPath $value -Parent)
    } else {
        $targetPath = $value
    }

    if (-not (Test-Path -LiteralPath $targetPath -PathType Container)) {
        $logPath = Join-Path $env:LOCALAPPDATA 'psloc\handler.log'
        $msg = "{0} Invalid location: {1}" -f (Get-Date), $targetPath
        Add-Content -Path $logPath -Value $msg
        exit 1
    }

    $escaped = $targetPath.Replace("'", "''")
    $cmd = "Set-Location -LiteralPath '$escaped'"

    $commandFile = Join-Path $env:LOCALAPPDATA 'psloc\command.ps1'
    Set-Content -Path $commandFile -Value $cmd -Encoding UTF8
}
catch {
    $logPath = Join-Path $env:LOCALAPPDATA 'psloc\handler.log'
    $msg = "{0} Error: {1}" -f (Get-Date), $_
    Add-Content -Path $logPath -Value $msg
    exit 1
}
'@

    Set-Content -Path $script:HandlerPath -Value $handlerCode -Encoding UTF8

    # Choose pwsh if available, else Windows PowerShell
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwsh) {
        $exe = $pwsh.Source
    } else {
        $exe = (Get-Command powershell.exe -ErrorAction Stop).Source
    }

    # Build registry entries under HKCU so no admin needed
    $root = 'HKCU:\Software\Classes\psloc'
    if ($PSCmdlet.ShouldProcess($root, 'Create psloc:// URL protocol')) {
        New-Item -Path $root -Force | Out-Null
        New-ItemProperty -Path $root -Name '(default)' -Value 'URL:psloc Protocol' -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $root -Name 'URL Protocol' -Value '' -PropertyType String -Force | Out-Null

        $shellPath = Join-Path $root 'shell'
        $openPath  = Join-Path $shellPath 'open'
        $cmdPath   = Join-Path $openPath 'command'

        New-Item -Path $shellPath -Force | Out-Null
        New-Item -Path $openPath  -Force | Out-Null
        New-Item -Path $cmdPath   -Force | Out-Null

        $commandLine = '"{0}" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "{1}" "%1"' -f $exe, $script:HandlerPath
        New-ItemProperty -Path $cmdPath -Name '(default)' -PropertyType String -Value $commandLine -Force | Out-Null
    }
}

function Uninstall-PsLoc {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$RemoveFiles
    )

    $root = 'HKCU:\Software\Classes\psloc'
    if (Test-Path $root -PathType Container) {
        if ($PSCmdlet.ShouldProcess($root, 'Remove psloc:// URL protocol')) {
            Remove-Item -Path $root -Recurse -Force
        }
    }

    if ($RemoveFiles) {
        if ($PSCmdlet.ShouldProcess($script:ConfigDir, 'Remove PsLoc config directory')) {
            if (Test-Path $script:ConfigDir) {
                Remove-Item -Path $script:ConfigDir -Recurse -Force
            }
        }
    }
}

function Enable-PsLocSessionListener {
    [CmdletBinding()]
    param(
        [int]$IntervalMilliseconds = 500
    )

    if (-not (Test-Path $script:ConfigDir)) {
        New-Item -ItemType Directory -Path $script:ConfigDir -Force | Out-Null
    }

    # Already enabled for this session?
    if ($script:Subscription) {
        return
    }

    $timer = New-Object System.Timers.Timer
    $timer.Interval = [double]$IntervalMilliseconds
    $timer.AutoReset = $true
    $timer.Enabled = $true

    $subscription = Register-ObjectEvent `
        -InputObject $timer `
        -EventName Elapsed `
        -SourceIdentifier "PsLocTimer-$PID" `
        -MessageData $script:CommandFile `
        -Action {
            # NOTE: MessageData comes from $Event, not from $eventArgs
            $commandFile = $Event.MessageData

            if ($commandFile -and (Test-Path -LiteralPath $commandFile)) {
                $cmd = Get-Content -LiteralPath $commandFile -Raw
                if (-not [string]::IsNullOrWhiteSpace($cmd)) {
                    try {
                        Remove-Item -LiteralPath $commandFile -Force
                    } catch { }

                    try {
                        # Optional: uncomment this for debugging
                        # Write-Host "[PsLoc] Executing: $cmd" -ForegroundColor Cyan
                        Invoke-Expression $cmd
                    } catch {
                        Write-Warning "PsLoc failed to run command from '$commandFile': $_"
                    }
                }
            }
        }

    $script:Timer = $timer
    $script:Subscription = $subscription
}

function Disable-PsLocSessionListener {
    [CmdletBinding()]
    param()

    if ($script:Subscription) {
        Unregister-Event -SourceIdentifier $script:Subscription.SourceIdentifier -ErrorAction SilentlyContinue
        $script:Subscription = $null
    }
    if ($script:Timer) {
        $script:Timer.Stop()
        $script:Timer.Dispose()
        $script:Timer = $null
    }
}

function New-PsLocLink {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path,

        [Parameter(Position = 1)]
        [string]$Label
    )

    try {
        $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
        $fullPath = $resolved.Path
    }
    catch {
        throw "Path '$Path' not found."
    }

    if (-not $Label) {
        $Label = "[cd $fullPath]"
    }

    # Convert to forward-slash form and URL-encode
    $urlPath = $fullPath -replace '\\','/'
    $encoded = [System.Uri]::EscapeDataString($urlPath)

    $esc = "`e"  # ESC (0x1B)
    $link = "$esc]8;;psloc://$encoded`a$Label$esc]8;;`a"
    return $link
}

Export-ModuleMember -Function Install-PsLoc, Uninstall-PsLoc, Enable-PsLocSessionListener, Disable-PsLocSessionListener, New-PsLocLink
