using module User.Abstracts.Parser.Attribute
using module User.Abstracts.Attribute
using module User.Implementations.Attribute.Markup

class MarkupAttributeParser : AbstractAttributeParser {
    MarkupAttributeParser([string]$content) : base($content) {}

    [string] GetPattern() {
        return "(\w+\s*=\s*""[^""]*"")"
    }

    [string] GetSeparator() {
        return " "
    }

    [AbstractAttribute] CreateAttribute([string]$text) {
        Write-Host "*** " -ForegroundColor Green -NoNewLine; Write-Host "MarkupAttributeParser.CreateAttribute($text) - OVERLOAD 1" -ForegroundColor Magenta
        return [MarkupAttribute]::new($text)
    }
    
    [AbstractAttribute] CreateAttribute([string]$key, [string]$value) {
        Write-Host "*** " -ForegroundColor Green -NoNewLine; Write-Host "MarkupAttributeParser.CreateAttribute($key, $value) - OVERLOAD 2" -ForegroundColor Magenta
        return [MarkupAttribute]::new($key, $value)
    }
}