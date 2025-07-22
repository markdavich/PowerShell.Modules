using namespace System.IO

using module User.Abstracts.Parser
using module User.Implementations.Parser.Attribute.Markup

class AspxDirectiveParser : AbstractParser {
    [MarkupAttributeParser]$Attributes = [MarkupAttributeParser]::new("")

    static [hashtable] $Directives = @{
        Page    = 'Page'
        Control = 'Control'
        Html    = 'Html'
    }

    [PSCustomObject]$AttributeNames = @{
        Inherits        = "inherits"
        AutoEventWireup = "autoeventwireup"
        Language        = "language"
    }

    [string]$DirectiveType

    [bool] IsPage() { return $this.DirectiveType -eq $this.Directives.Page }
    [bool] IsControl() { return $this.DirectiveType -eq $this.Directives.Control }

    AspxDirectiveParser([string]$content) : base($content) {
        $this.Initialize()
    }

    AspxDirectiveParser([FileSystemInfo]$Info) : base($Info) {
        $this.Initialize()
    }

    hidden [void] Initialize() {
        $this.DirectiveType = $this.DetectDirectiveType()

        if ($this.IsMatch()) {
            $this.Attributes = [MarkupAttributeParser]::new($this.GetMatch())
        }

        # $content = $this.IsMatch() ? $this.GetMatch() : ""
        # $this.Attributes = [MarkupAttributeParser]::new($content)
    }

    hidden [string] DetectDirectiveType() {
        if ($this._content -match '<%@\s*(\w+)\b') {
            $type = $Matches[1].ToLowerInvariant()

            $validTypes = [AspxDirectiveParser]::Directives.Values | ForEach-Object { $_.ToLowerInvariant() }

            if (-not ($validTypes -contains $type)) {
                throw "Unsupported directive type '$type'"
            }

            return $Matches[1]
        }

        return [AspxDirectiveParser]::Directives.Html
    }

    [string] GetPattern() {
        return "(?is)<%@\s+$($this.DirectiveType)\b(.*?)%>"
    }

    [void] Save() {
        if (-not $this._match) {
            throw "Cannot save: no directive match found."
        }

        $new = $this.ToString()
        $this._content = $this._content -replace [regex]::Escape($this._match), $new
    }

    [string] ToString() {
        return "<%@ $($this.DirectiveType) $($this.Attributes.ToString()) %>"
    }

    [string] GetContent() {
        return $this._content
    }
}