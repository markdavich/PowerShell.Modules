using module Bop.A.Parser
using module Bop.A.Attribute

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

class AbstractAttributeParser : AbstractParser {
    hidden [hashtable]$_pairs

    AbstractAttributeParser([string]$Content) : base($Content) {
        $this._pairs = @{}
        if ($this.IsMatch()) {
            foreach ($raw in $this.GetMatches()) {
                $attr = $this.CreateAttribute($raw)
                $this._pairs[$attr.Key] = $attr
            }
        }
    }

    [void] SetAttribute([AbstractAttribute]$Attribute) {
        $this.SetAttribute($Attribute.Key, $Attribute.Value)
        # $this._pairs[$Attribute.Key] = $Attribute
    }

    [void] SetAttribute([string]$Key, [string]$Value) {
        # Write-Host "Add key=$Key, value=$Value"

        $attr = $this.CreateAttribute($Key.Trim(), $Value.Trim())

        # Write-Host "Resulting attribute: $($attr.ToString())"
        
        $this._pairs[$Key] = $attr
    }

    [void] Remove([string]$Key) {
        $this._pairs.Remove($Key) | Out-Null
    }

    [string] Value([string]$Key) {
        return $this._pairs[$Key].Value.Trim()
    }

    [string] ToString() {
        return ($this._pairs.Values | ForEach-Object { $_.ToString() }) -join $this.GetSeparator()
    }

    [string] GetSeparator() {
        throw [System.NotImplementedException]::new(
            "GetSeparator must be overridden"
        )
    }

    hidden [AbstractAttribute] CreateAttribute([string]$text) {
        throw [System.NotImplementedException]::new(
            "CreateAttribute(text) must be overridden"
        )
    }

    hidden [AbstractAttribute] CreateAttribute([string]$key, [string]$value) {
        throw [System.NotImplementedException]::new(
            "CreateAttribute(key, value) must be overridden"
        )
    }

    [bool] HasKey([string]$Key) {
        return $this._pairs.ContainsKey($Key)
    }
}



