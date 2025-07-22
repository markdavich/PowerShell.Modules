using module User.Abstracts.Parser
using module User.Abstracts.Attribute

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

    [void] Add([AbstractAttribute]$Attribute) {
        $this._pairs[$Attribute.Key] = $Attribute
    }

    [void] Add([string]$Key, [string]$Value) {
        # Write-Host "Add key=$Key, value=$Value"

        $attr = $this.CreateAttribute($Key, $Value)

        # Write-Host "Resulting attribute: $($attr.ToString())"
        
        $this._pairs[$Key] = $attr
    }

    [void] Remove([string]$Key) {
        $this._pairs.Remove($Key) | Out-Null
    }

    [string] Value([string]$Key) {
        return $this._pairs[$Key].Value
    }

    [string] ToString() {
        return ($this._pairs.Values | ForEach-Object { $_.ToString() }) -join $this.GetSeparator()
    }

    [string] GetSeparator() {
        throw [System.NotImplementedException]::new("GetSeparator must be overridden")
    }

    [AbstractAttribute] CreateAttribute([string]$text) {
        throw [System.NotImplementedException]::new("CreateAttribute(text) must be overridden")
    }

    [AbstractAttribute] CreateAttribute([string]$key, [string]$value) {
        throw [System.NotImplementedException]::new("CreateAttribute(key, value) must be overridden")
    }

    [bool] HasKey([string]$Key) {
        return $this._pairs.ContainsKey($Key)
    }
}