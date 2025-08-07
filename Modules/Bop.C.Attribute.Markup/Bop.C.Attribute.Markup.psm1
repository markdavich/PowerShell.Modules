using module Bop.A.Attribute

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

class MarkupAttribute : AbstractAttribute {
    MarkupAttribute([string]$text) : base($text) {
        # Write-Host "*** " -ForegroundColor Green -NoNewLine; Write-Host "MarkupAttribute($text) - OVERLOAD 1" -ForegroundColor Magenta
    }

    MarkupAttribute([string]$key, [string]$value) : base($key, $value) {
        # Write-Host "*** " -ForegroundColor Green -NoNewLine; Write-Host "MarkupAttribute($key, $value) - OVERLOAD 2" -ForegroundColor Magenta
    }

    [string] GetPattern() {
        return "^(\w+)\s*=\s*""([^""]*)""$"
    }

    [string] GetFormatTemplate() {
        return "KEY=""VALUE"""
        # Below is the ideal way to write this, but it is too complicated for
        # implementers to write. The above way is easy to write and read but it uses
        # magic strings which is mitigated in: AbstractAttribute.FormatString
        # return "$([AbstractAttribute]::KeyTemplateString)=""$([AbstractAttribute]::ValueTemplateString)"""
    }
}



