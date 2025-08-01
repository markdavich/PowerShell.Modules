$rootPath = $PSScriptRoot
$old = ''
$new = ''

# Escape regex metacharacters for use in -replace
$escapedOld = [regex]::Escape($old)

# Rename files first
Get-ChildItem -Path $rootPath -Recurse -File |
Where-Object { $_.Name -like "$old*" } |
ForEach-Object {
    $newName = $_.Name -replace "^$escapedOld", $new
    $newPath = Join-Path -Path $_.DirectoryName -ChildPath $newName
    Rename-Item -Path $_.FullName -NewName $newPath
    Write-Host "Renamed File: $($_.FullName) -> $newPath"
}

# Rename folders last to avoid path conflicts
Get-ChildItem -Path $rootPath -Recurse -Directory |
Sort-Object FullName -Descending |  # Deepest paths first
Where-Object { $_.Name -like "$old*" } |
ForEach-Object {
    $newName = $_.Name -replace "^$escapedOld", $new
    $newPath = Join-Path -Path $_.Parent.FullName -ChildPath $newName
    Rename-Item -Path $_.FullName -NewName $newPath
    Write-Host "Renamed Folder: $($_.FullName) -> $newPath"
}

# Replace "using module Bop.C.*" with "using module Bop.C.*"
$pattern = [regex]::Escape("using module $old")
$replacement = "using module $new"

Get-ChildItem -Path $rootPath -Recurse -File -Include *.ps1, *.psm1, *psd1 |
ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match $pattern) {
        $updated = $content -replace $pattern, $replacement
        Set-Content -Path $_.FullName -Value $updated
        Write-Host "Updated using-module in: $($_.FullName)"
    }
}




