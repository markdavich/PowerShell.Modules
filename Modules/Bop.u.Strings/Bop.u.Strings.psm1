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

Export-ModuleMember -Function `
    Split-StringAtWordBoundary