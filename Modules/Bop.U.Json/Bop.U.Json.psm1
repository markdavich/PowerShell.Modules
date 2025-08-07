Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

function Get-Json {
    param($path)

    $result = Get-Content $path -Raw | ConvertFrom-Json
    return $result
}

# Formats JSON in a nicer format than the built-in ConvertTo-Json does.
function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
    Wait-Debugger

    # If the input is a single line, pretty-print it first
    if ($json -notmatch "`n") {
        try {
            $json = $json | ConvertFrom-Json | ConvertTo-Json -Depth 23
        }
        catch {
            Write-Error "Input is not valid JSON."
            return $json
        }
    }
    
    $indent = 0;

    Wait-Debugger
    Write-Debug "Formatting JSON with initial indent level: $indent" -ForegroundColor Cyan

    ($json -Split "`n" | ForEach-Object -Parallel {
        Wait-Debugger
        Write-Debug "Processing line: $_" -ForegroundColor Cyan

        if ($_ -match '[\}\]]\s*,?\s*$') {
            # This line ends with ] or }, decrement the indentation level
            $indent--

            Wait-Debugger
            Write-Debug "Object/Array Closed: Decrementing indent to $indent" -ForegroundColor Yellow
        }

        $line = ('  ' * $indent) + $($_.TrimStart() -replace '":  (["{[])', '": $1' -replace ':  ', ': ')
        
        Wait-Debugger
        Write-Debug "Formatted line: $line" -ForegroundColor Green

        if ($_ -match '[\{\[]\s*$') {
            # This line ends with [ or {, increment the indentation level
            $indent++

            Wait-Debugger
            Write-Debug "Object/Array Opened: Incrementing indent to $indent" -ForegroundColor Yellow
        }

        $line
    }) -Join "`n"
}

function Save-Json(
    [Parameter(Mandatory)][PSCustomObject] $json,
    [Parameter(Mandatory)][string] $path
) {
    # $json | ConvertTo-Json -Depth 23 | Format-Json | Out-File $path -Encoding UTF8
    $json | ConvertTo-Json -Depth 23 | Out-File $path -Encoding utf8BOM
}

Export-ModuleMember -Function *