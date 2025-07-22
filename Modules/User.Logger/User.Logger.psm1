using namespace System

class Logger {
    [ConsoleColor] $StartColor = [ConsoleColor]::Green
    [ConsoleColor] $EnterColor = [ConsoleColor]::Cyan
    [ConsoleColor] $NoteColor = [ConsoleColor]::Blue
    [ConsoleColor] $ErrorColor = [ConsoleColor]::Red
    [ConsoleColor] $WarningColor = [ConsoleColor]::Yellow

    [string] $KeyValueSeparator = ':'
    [ConsoleColor] $KeyColor = [ConsoleColor]::Yellow
    [ConsoleColor] $KeyValueSeparatorColor = [ConsoleColor]::Magenta
    [ConsoleColor] $ValueColor = [ConsoleColor]::Cyan

    hidden [Int64] $IndentCount = 0
    hidden [string]$IndentString = '   '

    [void] Start([string] $Message) {
        $this.Start($Message, $this.StartColor)
    }

    [void] Start([string] $Message, [ConsoleColor] $Color) {
        $this.IndentCount = 0
        Write-Host
        Write-Host "🧿 $Message" -ForegroundColor $Color
    }

    [void] Enter([string] $Message) {
        $this.Enter($Message, $this.EnterColor)
    }

    [void] Enter([string] $Message, [ConsoleColor] $Color) {
        $this.IndentCount++
        Write-Host "$($this.Indent())$Message" -ForegroundColor $Color
    }

    [void] Note([string] $Message) {
        $this.Note($Message, $this.NoteColor)
    }

    [void] Note([string] $Message, [ConsoleColor] $Color) {
        $this.WriteInternal($Message, $Color)
    }

    [void] Error([string] $Message) {
        $this.Error($Message, $this.ErrorColor)
    }

    [void] Error([string] $Message, [ConsoleColor] $Color) {
        $this.WriteInternal($Message, $Color)
    }

    [void] Warning([string] $Message) {
        $this.Warning($Message, $this.WarningColor)
    }

    [void] Warning([string] $Message, [ConsoleColor] $Color) {
        $this.WriteInternal($Message, $Color)
    }

    [void] Blank() {
        Write-Host
    }

    [void] BeginLine([string] $Message, [ConsoleColor] $Color) {
        $this.Add("$($this.InternalIndent())$Message", $Color)
    }

    [void] Add([string] $Message, [ConsoleColor] $Color) {
        Write-Host $Message -ForegroundColor $Color -NoNewline
    }

    [void] EndLine([string] $Message, [ConsoleColor] $Color) {
        Write-Host $Message -ForegroundColor $Color
    }

    hidden [void] WriteInternal([string] $Message, [ConsoleColor] $Color) {
        Write-Host "$($this.InternalIndent())$Message" -ForegroundColor $Color
    }

    hidden [string] InternalIndent() {
        return $this.BuildIndent($this.IndentCount + 1)
    }

    hidden [string] Indent() {
        return $this.BuildIndent($this.IndentCount)
    }

    hidden [string] BuildIndent([Int64] $Count) {
        return $this.IndentString * $Count
    }

    [void] IncreaseIndent() {
        $this.IndentCount++
    }

    [void] DecreaseIndent() {
        $this.IndentCount--
    }

    [void] Leave() {
        $this.DecreaseIndent()
    }

    [void] KeyValue([string]$Key, [string]$Value) {
        $this.BeginLine($Key, $this.KeyColor)
        $this.Add("$($this.KeyValueSeparator) ", $this.KeyValueSeparatorColor)
        $this.EndLine($Value, $this.ValueColor)
    }
}