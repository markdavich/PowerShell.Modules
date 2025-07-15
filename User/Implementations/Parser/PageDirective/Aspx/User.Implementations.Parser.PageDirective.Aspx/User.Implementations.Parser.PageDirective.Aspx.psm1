using module User.Abstracts.Parser
using module User.Implementations.Parser.Attribute.Markup

class AspxPageDirectiveParser : AbstractParser {
    [MarkupAttributeParser]$Attributes

    AspxPageDirectiveParser([string]$content) : base($content) {
        if ($this.IsMatch()) {
            $this.Attributes = [MarkupAttributeParser]::new($this.GetMatch())
        }
    }

    [string] GetPattern() {
        # return '(?is)<%@\s+Page\b(.*?)%>'
        return "(?is)<%@\s+Page\b(.*?)%>"
    }

    [void] Save() {
        $new = $this.ToString()
        $this._content = $this._content -replace [regex]::Escape($this._match), $new
    }

    [string] ToString() {
        return "<%@ Page $($this.Attributes.ToString()) %>"
    }

    [string] GetContent() {
        return $this._content
    }
}