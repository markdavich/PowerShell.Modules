using namespace System

using module Bop.u.Strings

class Logger {
    [ConsoleColor] $StartColor = [ConsoleColor]::Green
    [ConsoleColor] $EnterColor = [ConsoleColor]::Cyan
    [ConsoleColor] $NoteColor = [ConsoleColor]::Blue
    [ConsoleColor] $ErrorColor = [ConsoleColor]::Red
    [ConsoleColor] $WarningColor = [ConsoleColor]::Yellow
    [ConsoleColor] $LineColor = [ConsoleColor]::White

    [string] $KeyValueSeparator = ':'
    [ConsoleColor] $KeyColor = [ConsoleColor]::Yellow
    [ConsoleColor] $KeyValueSeparatorColor = [ConsoleColor]::Magenta
    [ConsoleColor] $ValueColor = [ConsoleColor]::Cyan

    [string] $BulletSymbol = "●"
    [ConsoleColor] $BulletColor = [ConsoleColor]::Gray
    [ConsoleColor] $BulletTextColor = [ConsoleColor]::DarkYellow

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

    [void] Error([string] $Message, [System.Management.Automation.ErrorRecord]$E) {
        $this.Error($Message, $this.ErrorColor)
        $this.WriteErrorDetails("EXCEPTION", $E)
    }

    hidden [void] WriteErrorDetails([string]$Tag, [System.Management.Automation.ErrorRecord]$E) {
        $this.Error("☎️  $Tag", [ConsoleColor]::Magenta)
        $this.IncreaseIndent()
        $this.KeyColor = [ConsoleColor]::DarkRed
        $this.ValueColor = [ConsoleColor]::DarkYellow
        $this.KeyValue("Message ──────────► ", $E.Exception.Message)
        $this.KeyValue("Exception Type ───► ", $E.Exception.GetType().FullName)
        $this.KeyValue("Script Name ──────► ", $E.InvocationInfo.ScriptName)
        $this.KeyValue("Line Number ──────► ", $E.InvocationInfo.ScriptLineNumber)
        $this.KeyValue("Code ─────────────► ", $E.InvocationInfo.Line.Trim())
        $this.KeyValue("Position Message ─► ", $this.FormatArray(16, $E.InvocationInfo.PositionMessage))
        $this.KeyValue("Stack Trace ──────► ", $this.FormatArray(16, $E.Exception.StackTrace))

        if ($null -ne $E.Exception.InnerException) {
            $this.WriteErrorDetails("INNER EXCEPTION", $E.Exception.InnerException.ErrorRecord)
            $this.DecreaseIndent()
        }

        $this.DecreaseIndent()
    }

    hidden [string] FormatArray([int]$PrefixLength, [string]$String) {
        $array = $String.Split("`n")
        $indent = "         $($this.Indent())$(" " * $PrefixLength)"

        $array[0] = $array[0].Trim()

        for ($i = 1; $i -lt $array.Count; $i++) {
            $array[$i] = "$indent$($array[$i].Trim())"
        }

        $result = $array -join "`n"

        return $result
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

    [void] BeginLine([string] $Message) {
        $this.BeginLine($Message, $this.LineColor)
    }

    [void] BeginLine([string] $Message, [ConsoleColor] $Color) {
        $this.Add("$($this.InternalIndent())$Message", $Color)
    }

    [void] Add([string] $Message) {
        $this.Add($Message, $this.LineColor)
    }

    [void] Add([string] $Message, [ConsoleColor] $Color) {
        Write-Host $Message -ForegroundColor $Color -NoNewline
    }

    [void] EndLine([string] $Message) {
        $this.EndLine($Message, $this.LineColor)
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

    [void] Bullet([string]$Value) {
        $this.IncreaseIndent()
        $this.BeginLine($this.BulletSymbol.PadRight($this.IndentString.Length), $this.BulletColor)
        $this.EndLine($Value, $this.BulletTextColor)
        $this.DecreaseIndent()
    }
}