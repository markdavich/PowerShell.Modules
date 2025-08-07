Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green


class Command {
    [string]$name
    [string]$alias
    [string]$description
    [string[]]$params
    [string]$icon

    Command([string]$name, [string]$alias, [string]$description, [string[]]$params, [string]$icon) {
        $this.name = $name
        $this.alias = $alias
        $this.description = $description
        $this.params = $params
        $this.icon = $icon
    }
}