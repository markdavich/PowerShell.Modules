using module Cs.Type.TestClass

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
[TestClass[int]] $TestClass = [TestClass[int]]::new()

# ╭──────────╮
# │ Concrete │
# ╰──────────╯
[TestClass] $TestClass = [TestClass]::new()
