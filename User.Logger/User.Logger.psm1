class Logger {
    hidden [Int64] $IndentCount = 0
    hidden [string]$IndentString = "   "

    [void] Start([string] $Message) {
        $this.Start($Message, [System.ConsoleColor]::Green)
    }

    [void] Start([string] $Message, [System.ConsoleColor] $Color) {
        $this.IndentCount = 0
        Write-Host "🧿 $Message" -ForegroundColor $Color
    }

    [void] Enter([string] $Message) {
        $this.Enter($Message, [System.ConsoleColor]::Cyan)
    }

    [void] Enter([string] $Message, [System.ConsoleColor] $Color) {
        $this.IndentCount++
        Write-Host "$($this.Indent())$Message" -ForegroundColor $Color
    }

    [void] Note([string] $Message) {
        $this.Note($Message, [System.ConsoleColor]::Blue)
    }

    [void] Note([string] $Message, [System.ConsoleColor] $Color) {
        $this.WriteInternal($Message, $Color)
    }

    [void] Error([string] $Message) {
        $this.Error($Message, [System.ConsoleColor]::Red)
    }

    [void] Error([string] $Message, [System.ConsoleColor] $Color) {
        $this.WriteInternal($Message, $Color)
    }

    [void] Warning([string] $Message) {
        $this.Warning($Message, [System.ConsoleColor]::Yellow)
    }

    [void] Warning([string] $Message, [System.ConsoleColor] $Color) {
        $this.WriteInternal($Message, $Color)
    }

    [void] Blank() {
        Write-Host
    }

    [void] BeginLine([string] $Message, [System.ConsoleColor] $Color) {
        $this.Add("$($this.InternalIndent())$Message", $Color)
    }

    [void] Add([string] $Message, [System.ConsoleColor] $Color) {
        Write-Host $Message -ForegroundColor $Color -NoNewline
    }

    [void] EndLine([string] $Message, [System.ConsoleColor] $Color) {
        Write-Host $Message -ForegroundColor $Color
    }

    hidden [void] WriteInternal([string] $Message, [System.ConsoleColor] $Color) {
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
}