using namespace System

using module Bop.U.Strings

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

class Logger {
    hidden [ConsoleColor] $_defaultStartColor = [ConsoleColor]::Green
    hidden [ConsoleColor] $_defaultEnterColor = [ConsoleColor]::Cyan
    hidden [ConsoleColor] $_defaultNoteColor = [ConsoleColor]::Blue
    hidden [ConsoleColor] $_defaultErrorColor = [ConsoleColor]::Red
    hidden [ConsoleColor] $_defaultWarningColor = [ConsoleColor]::Yellow
    hidden [ConsoleColor] $_defaultLineColor = [ConsoleColor]::White
    hidden [ConsoleColor] $_defaultKeyColor = [ConsoleColor]::Yellow
    hidden [ConsoleColor] $_defaultKeyValueSeparatorColor = [ConsoleColor]::Magenta
    hidden [ConsoleColor] $_defaultValueColor = [ConsoleColor]::Cyan
    hidden [ConsoleColor] $_defaultBulletColor = [ConsoleColor]::Gray
    hidden [ConsoleColor] $_defaultBulletTextColor = [ConsoleColor]::DarkYellow

    [ConsoleColor] $StartColor
    [ConsoleColor] $EnterColor
    [ConsoleColor] $NoteColor
    [ConsoleColor] $ErrorColor
    [ConsoleColor] $WarningColor
    [ConsoleColor] $LineColor

    [string] $KeyValueSeparator = ':'
    [ConsoleColor] $KeyColor
    [ConsoleColor] $KeyValueSeparatorColor
    [ConsoleColor] $ValueColor

    [string] $BulletSymbol = "●"
    [ConsoleColor] $BulletColor
    [ConsoleColor] $BulletTextColor

    hidden [Int64] $IndentCount = 0
    hidden [string]$IndentString = '   '

    Logger() {
        $this.ResetDefaults()
    }

    [void] ResetDefaults() {
        $this.GetType().GetProperties() |
        Where-Object {
            $_.Name.StartsWith('_default') -and $_.PropertyType -eq [ConsoleColor]
        } |
        ForEach-Object {
            $defaultProp = $_
            $targetName = $_.Name.Substring(8)  # Remove "_default"
            $targetProp = $this.GetType().GetProperty($targetName)
            
            if ($targetProp -and $targetProp.CanWrite) {
                $targetProp.SetValue($this, $defaultProp.GetValue($this))
            }
        }
    }

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

    [void] PrettyPrint([object] $Object, [string] $Name = $null) {
        if ($null -eq $Object) {
            if ($null -ne $Name) {
                $this.KeyValue("`"$Name`"", "null")
            }
            else {
                $this.Note("null", $this.ValueColor)
            }
            return
        }

        $isArray = $Object -is [System.Collections.IEnumerable] -and -not ($Object -is [string])
        $isDict = $Object -is [System.Collections.IDictionary]
        $isPrimitive = Test-IsPrimitive $Object
        $isCustomObj = -not $isPrimitive -and -not $isArray -and -not $isDict -and $Object.PSObject.Properties.Count -gt 0

        # Print opening line
        if (-not [string]::IsNullOrEmpty($Name)) {
            if ($isArray) {
                $this.ValueColor = [ConsoleColor]::White
                $this.KeyValue("`"$Name`"", "[")
                $this.ResetDefaults()
            }
            elseif ($isDict -or $isCustomObj) {
                $this.ValueColor = [ConsoleColor]::White
                $this.KeyValue("`"$Name`"", "{")
                $this.ResetDefaults()
            }
            elseif ($isPrimitive) {
                $prettyValue = if ($Object -is [string]) { "`"$Object`"" } else { $Object }
                $this.KeyValue("`"$Name`"", $prettyValue)
                return
            }
            else {
                $this.KeyValue("`"$Name`"", $Object)
                return
            }
        }
        else {
            if ($isArray) {
                $this.Note("[", [ConsoleColor]::White)
            }
            elseif ($isDict -or $isCustomObj) {
                $this.Note("{", [ConsoleColor]::White)
            }
            elseif ($isPrimitive) {
                $prettyValue = if ($Object -is [string]) { "`"$Object`"" } else { $Object }
                $this.Note($prettyValue, $this.ValueColor)
                return
            }
            else {
                $this.Note("$Object", $this.ValueColor)
                return
            }
        }

        $this.IncreaseIndent()

        if ($isDict) {
            foreach ($key in $Object.Keys) {
                $this.PrettyPrint($Object[$key], $key)
            }
        }
        elseif ($isArray) {
            foreach ($item in $Object) {
                $this.PrettyPrint($item, $null)
            }
        }
        elseif ($isCustomObj) {
            foreach ($prop in $Object.PSObject.Properties) {
                $this.PrettyPrint($prop.Value, $prop.Name)
            }
        }

        $this.DecreaseIndent()

        if ($isArray) {
            $this.Note("]", [ConsoleColor]::White)
        }
        elseif ($isDict -or $isCustomObj) {
            $this.Note("}", [ConsoleColor]::White)
        }
    }
}

