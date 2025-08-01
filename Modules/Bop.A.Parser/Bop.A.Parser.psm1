using namespace System.IO

class AbstractParser {
    hidden [string]$_content
    hidden [string]$_pattern
    hidden [string]$_match
    hidden [System.Collections.Generic.List[string]]$_matches
    hidden [bool]$_test

    AbstractParser([string]$content) {
        $this.Initialize($content)
    }

    AbstractParser([System.IO.FileSystemInfo]$info) {
        if ($info -isnot [System.IO.FileInfo]) {
            throw "Expected a file, got: $($info.GetType().Name)"
        }

        $content = Get-Content -Path $info.FullName -Raw
        $this.Initialize($content)
    }

    hidden [void]Initialize([string]$content) {
        $this._content = $content
        $this._pattern = $this.GetPattern()
        $this._matches = [System.Collections.Generic.List[string]]::new()
        $this.Test()
    }

    [string] GetPattern() {
        throw [System.NotImplementedException]::new("GetPattern must be overridden")
    }

    hidden [void] Test() {
        $this._matches.Clear()

        $regex = [regex]::new($this._pattern)
        $all = $regex.Matches($this._content)

        foreach ($m in $all) {
            $this._matches.Add($m.Value)
        }

        $this._test = $this._matches.Count -gt 0
        $this._match = if ($this._test) { $this._matches[0] } else { $null }
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