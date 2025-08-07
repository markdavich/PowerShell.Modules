using module Bop.A.Parser.Attribute
using module Bop.A.Attribute
using module Bop.C.Attribute.Markup

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

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







