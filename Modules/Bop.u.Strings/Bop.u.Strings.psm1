Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

function Split-StringAtWordBoundary {
    param (
        [string]$String,
        [int]$MaxLength = 60
    )

    $result = @()
    $remainingString = $String

    while ($remainingString.Length -gt 0) {
        if ($remainingString.Length -le $MaxLength) {
            $result += $remainingString
            $remainingString = ""
        }
        else {
            $substring = $remainingString.Substring(0, $MaxLength)
            $lastSpaceIndex = $substring.LastIndexOf(' ')

            if ($lastSpaceIndex -ne -1 -and $lastSpaceIndex -gt 0) {
                # Split at the last space before MaxLength
                $result += $substring.Substring(0, $lastSpaceIndex)
                $remainingString = $remainingString.Substring($lastSpaceIndex + 1).TrimStart()
            }
            else {
                # No space found, or space is at the very beginning, so break the word
                $result += $substring
                $remainingString = $remainingString.Substring($MaxLength).TrimStart()
            }
        }
    }
    return $result
}

function ConvertTo-PascalCase {
    param (
        [string]$Text
    )

    if (-not $Text) { return "" }

    return ($Text -split '[^a-zA-Z0-9]+' | ForEach-Object {
            if ($_ -ne '') {
                $_.Substring(0, 1).ToUpper() + $_.Substring(1).ToLower()
            }
        }) -join ''
}

Export-ModuleMember -Function `
    'Split-StringAtWordBoundary', `
    'ConvertTo-PascalCase'