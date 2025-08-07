Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

function Git-CloneAt {
    param($repo, $destination)
    Write-Host ""
    Write-Host "Git-CloneAt" -ForegroundColor Magenta
    Write-Host ""

    git -C "$destination" clone "$repo"
}

function Git-CloneInto {
    param($repo, $destination)
    Write-Host ""
    Write-Host "Git-CloneInto" -ForegroundColor Magenta
    Write-Host ""

    
    git clone "$repo" "$destination"
}