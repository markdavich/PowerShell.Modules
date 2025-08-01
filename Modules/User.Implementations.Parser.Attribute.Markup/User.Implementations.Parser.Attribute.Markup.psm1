using module User.Abstracts.Parser.Attribute
using module User.Abstracts.Attribute
using module Bop.i.Attribute.Markup

class MarkupAttributeParser : AbstractAttributeParser {
    MarkupAttributeParser([string]$content) : base($content) {}

    [string] GetPattern() {
        return "(\w+\s*=\s*""[^""]*"")"
    }

    [string] GetSeparator() {
        return " "
    }

    hidden [AbstractAttribute] CreateAttribute([string]$text) {
        # Write-Host "*** " -ForegroundColor Green -NoNewLine;
        # Write-Host "MarkupAttributeParser.CreateAttribute($text) - OVERLOAD 1" `
        #   -ForegroundColor Magenta

        return [MarkupAttribute]::new($text)
    }
    
    hidden [AbstractAttribute] CreateAttribute([string]$key, [string]$value) {
        # Write-Host "*** " -ForegroundColor Green -NoNewLine;
        # Write-Host "MarkupAttributeParser.CreateAttribute($key, $value) - OVERLOAD 2" `
        #   -ForegroundColor Magenta
        
        return [MarkupAttribute]::new($key, $value)
    }
}