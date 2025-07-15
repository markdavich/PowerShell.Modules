class AbstractParser {
    hidden [string]$_content
    hidden [string]$_pattern
    hidden [string]$_match
    hidden [System.Collections.Generic.List[string]]$_matches
    hidden [bool]$_test

    AbstractParser([string]$content) {
        $this._content = $content
        $this._pattern = $this.GetPattern()
        $this._matches = [System.Collections.Generic.List[string]]::new()
        $this.Test()
    }

    [string] GetPattern() {
        throw [System.NotImplementedException]::new("GetPattern must be overridden")
    }

    hidden [void] Test() {
        $this._test = $this._content -match $this._pattern
        if ($this._test) {
            $this._match = $Matches[0]
            $this._matches.Clear()
            for ($i = 1; $i -lt $Matches.Count; $i++) {
                $this._matches.Add($Matches[$i])
            }
        }
    }

    [bool] IsMatch() {
        return $this._test
    }

    [string] GetMatch() {
        return $this._match
    }

    [string[]] GetMatches() {
        return $this._matches.ToArray()
    }
}