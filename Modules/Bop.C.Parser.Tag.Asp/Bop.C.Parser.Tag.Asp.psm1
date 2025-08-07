using namespace System.IO

using module Bop.A.Parser
using module Bop.C.Parser.Attribute.Markup
using module Bop.C.Tag.Asp

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

class AspTagParser : AbstractParser {
    [PSCustomObject[]] $Tags = @()

    AspTagParser([string]$content) : base($content) {
        $this.Initialize()
    }

    AspTagParser([FileSystemInfo]$Info) : base($Info) {
        $this.Initialize()
    }

    # [string] GetPattern() {
    #     # Match <prefix:Tag ... runat="server" ...> or />
    #     return '<(\w+):(\w+)\s+[^>]*runat\s*=\s*"server"[^>]*(\/?)>'
    # }

    [string] GetPattern() {
        # Match either:
        # - <prefix:Tag ... runat="server" ...>
        # - <tag ... runat="server" ...>
        return '(?i)<(?:(?<prefix>\w+):)?(?<tag>\w+)\b[^>]*runat\s*=\s*"server"[^>]*(\/?)>'
    }

    # hidden [void] Initialize() {
    #     $this.Tags = @()

    #     foreach ($match in $this.GetMatches()) {
    #         if ($match -match '<(?<prefix>\w+):(?<tag>\w+)\b([^>]*?)\/?>') {
    #             $prefix = $Matches['prefix']
    #             $tag = $Matches['tag']
    #             $attrs = [MarkupAttributeParser]::new($match)

    #             $this.Tags += [PSCustomObject]@{
    #                 Prefix     = $prefix
    #                 TagName    = $tag
    #                 Attributes = $attrs
    #                 Raw        = $match
    #             }
    #         }
    #     }
    # }

    # hidden [void] Initialize() {
    #     $this.Tags = @()

    #     foreach ($match in $this.GetMatches()) {
    #         if ($match -match '(?i)<(?:(?<prefix>\w+):)?(?<type>\w+)\b[^>]*runat\s*=\s*"server"[^>]*(/?)>') {
    #             $prefix = if ($Matches['prefix']) { $Matches['prefix'] } else { $null }
    #             $type = $Matches['type']
    #             $attrs = [MarkupAttributeParser]::new($match)

    #             $this.Tags += [PSCustomObject]@{
    #                 Prefix     = $prefix
    #                 Type       = $type
    #                 Attributes = $attrs
    #                 Raw        = $match
    #             }
    #         }
    #     }
    # }

    hidden [void] Initialize() {
        $this.Tags = @()

        foreach ($match in $this.GetMatches()) {
            if ($match -match '(?i)<(?:(?<prefix>\w+):)?(?<type>\w+)\b[^>]*runat\s*=\s*"server"[^>]*(/?)>') {
                $prefix = if ($Matches['prefix']) { $Matches['prefix'] } else { $null }
                $type = $Matches['type']
                $attrs = [MarkupAttributeParser]::new($match)

                $tag = [AspTag]::new($prefix, $type, $attrs, $match)
                $this.Tags += $tag
            }
        }
    }

    [PSCustomObject[]] GetTags() {
        return $this.Tags
    }
}
