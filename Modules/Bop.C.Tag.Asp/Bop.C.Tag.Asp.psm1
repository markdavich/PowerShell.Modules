using module Bop.C.Parser.Attribute.Markup
using module Bop.U.Strings

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

class AspTag {
    [string] $Prefix
    [string] $Type
    [MarkupAttributeParser] $Attributes
    [string] $Raw

    AspTag([string]$prefix, [string]$type, [MarkupAttributeParser]$attributes, [string]$raw) {
        $this.Prefix = $prefix
        $this.Type = [string]::IsNullOrEmpty($prefix) ? "Html$(ConvertTo-PascalCase $type)" : $type
        $this.Attributes = $attributes
        $this.Raw = $raw
    }

    # Optional: Add property-style getters (if you want them to be read-only outside)
    [string] get_Prefix() { return $this.Prefix }
    [string] get_Type() { return $this.Type }
    [string] get_Raw() { return $this.Raw }
    [MarkupAttributeParser] get_Attributes() { return $this.Attributes }
}

