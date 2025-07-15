using module User.Abstracts.Parser
using module User.Abstracts.Attribute

class AbstractAttributeParser : AbstractParser {
    hidden [hashtable]$_pairs

    AbstractAttributeParser([string]$content) : base($content) {
        $this._pairs = @{}
        if ($this.IsMatch()) {
            foreach ($raw in $this.GetMatches()) {
                $attr = $this.CreateAttribute($raw)
                $this._pairs[$attr.Key] = $attr
            }
        }
    }

    [void] Add([AbstractAttribute]$attr) {
        $this._pairs[$attr.Key] = $attr
    }

    [void] Add([string]$key, [string]$value) {
        Write-Host "Add key=$key, value=$value"
        $attr = $this.CreateAttribute($key, $value)
        Write-Host "Resulting attribute: $($attr.ToString())"
        $this._pairs[$key] = $attr
    }

    [void] Remove([string]$key) {
        $this._pairs.Remove($key) | Out-Null
    }

    [string] GetValue([string]$key) {
        return $this._pairs[$key].Value
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
}