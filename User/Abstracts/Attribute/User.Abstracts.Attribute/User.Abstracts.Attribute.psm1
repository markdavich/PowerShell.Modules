class AbstractAttribute {
    [string]$Key
    [string]$Value
    
    static [string]$KeyTemplateString = "KEY"
    static [string]$ValueTemplateString = "VALUE"
    
    AbstractAttribute([string]$text) {
        Write-Host "*** " -ForegroundColor Green -NoNewLine; Write-Host "AbstractAttribute($text) - OVERLOAD 1" -ForegroundColor Magenta
        $pattern = $this.GetPattern()
        
        Write-Host "Pattern: " -ForegroundColor Cyan -NoNewline; Write-Host $pattern -ForegroundColor Yellow
        Write-Host "   Text: " -ForegroundColor Cyan -NoNewline; Write-Host $text -ForegroundColor Yellow
        Write-Host "   Test: " -ForegroundColor Cyan -NoNewline; Write-Host "$text -match $pattern" -ForegroundColor Yellow
        
        if ($text -match $pattern) {
            Write-Host "  Key: " -ForegroundColor Cyan -NoNewline; Write-Host "|$($Matches[1])|" -ForegroundColor Yellow
            Write-Host "Value: " -ForegroundColor Cyan -NoNewline; Write-Host "|$($Matches[2])|" -ForegroundColor Yellow

            $this.Key = $Matches[1]
            $this.Value = $Matches[2]
        }
        else {
            throw "Invalid attribute format: $text"
        }
    }

    AbstractAttribute([string]$key, [string]$value) {
        Write-Host "*** " -ForegroundColor Green -NoNewLine; Write-Host "AbstractAttribute($key, $value) - OVERLOAD 2" -ForegroundColor Magenta
        $this.Key = $key
        $this.Value = $value
    }

    [string] ToString() {
        return $this.FormatString($this.Key, $this.Value)
    }

    [string] FormatString([string]$key, [string]$value) {
        Write-Host "Formatting: key=$key, value=$value"
        $template = $this.GetFormatTemplate()

        $KeyGuid = (New-Guid).ToString()
        $ValueGuid = (New-Guid).ToString()

        $Kts = [AbstractAttribute]::KeyTemplateString
        $Vts = [AbstractAttribute]::ValueTemplateString

        $result = $template.Replace($Kts, $KeyGuid)
        $result = $result.Replace($Vts, $ValueGuid)

        # Now result = "34c13317-7e45-46b1-91ed-adb4f8c10e0e="0e85acb3-47d8-44e4-85db-f7513121a655""
        # Which will hopefully avoid avoid the situation when an attribute looks like this
        # <value="key">

        $result = $result.Replace($KeyGuid, $key)
        $result = $result.Replace($ValueGuid, $value)

        return $result
    }

    [string] GetPattern() {
        throw [System.NotImplementedException]::new("GetPattern must be overridden")
    }

    [string] GetFormatTemplate() {
        throw [System.NotImplementedException]::new("GetFormatTemplate must be overridden")
    }
}