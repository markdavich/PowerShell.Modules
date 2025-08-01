using module Cs.Type.ClassName

# ╭────────────────────────────────╮
# │ Possible Constructor Arguments │
# ╰────────────────────────────────╯
[string[]] $Strings = @('a', 'b', 'c')
[int[]] $Numbers = @(1, 2, 3)
[string] $String = 'a'
[int] $Number = 1
[FileSystemInfo[]] $FSInfoArray = Get-ChildItem -Path $PSScriptRoot -Exclude 'bin'

# ╭─────────╮
# │ Generic │
# ╰─────────╯
[ClassName[int]] $ClassName = [ClassName[int]]::new()

# ╭──────────╮
# │ Concrete │
# ╰──────────╯
[ClassName] $ClassName = [ClassName]::new()