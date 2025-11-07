using module Cs.Type.CoreMarshal

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
[CoreMarshal[int]] $CoreMarshal = [CoreMarshal[int]]::new()

# ╭──────────╮
# │ Concrete │
# ╰──────────╯
[CoreMarshal] $CoreMarshal = [CoreMarshal]::new()
