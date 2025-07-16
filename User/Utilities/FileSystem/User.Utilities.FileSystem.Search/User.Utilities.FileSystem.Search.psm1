function Find-DotNetClassDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter()]
        [switch]$Recurse,

        [Parameter()]
        [string[]]$Include = @("*.cs", "*.vb"),

        [Parameter(Mandatory = $true)]
        [string]$ClassName
    )

    $files = Get-ChildItem -Path $Path -File -Include $Include -Recurse:$Recurse

    $pattern = "^(?i)\s*(?!//|/\*|'|\*).*?\bclass\s+$ClassName\b"

    $found = $files | Select-String -Pattern $pattern

    return $found | Select-Object -Unique Path
}

Clear-Host

$path = "C:\Code\Repos\IDL\Idl.PrivateFire.Rebuild\dlls-to-asp.net\output\PrivateFire\Staging\App_Web"
$class = "pf_login"

$a = Find-DotNetClassDefinition -Path $path -ClassName $class

Write-Host
Write-Host "A:"

foreach ($file in $a) {
    Write-Host " - $file"
}

Write-Host
Write-Host "B:"

Get-ChildItem -Path $path -Recurse -Include *.cs, *.vb |
Select-String -Pattern "^(?i)\s*(?!//|/\*|'|\*).*?\bclass\s+$($class)\b" |
ForEach-Object {
    Write-Host $_.Path
}