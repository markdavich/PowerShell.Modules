using namespace System.IO
using namespace System.Collections.Generic

using module Cs.Type.Tracker

# !!! Clear-Host

Write-Host "> ? ? ?" -ForegroundColor Yellow
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor DarkGray
Write-Host "Called " -ForegroundColor DarkMagenta -NoNewline
Write-Host "> ? ? ?" -ForegroundColor Yellow

# ╭────────────────────────────────╮
# │ Possible Constructor Arguments │
# ╰────────────────────────────────╯
[string[]] $Strings = @('a', 'b', 'c')
[int[]] $Numbers = @(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
[string] $String = 'a'
[int] $Number = 1
[FileSystemInfo[]] $FSInfoArray = Get-ChildItem -Path $PSScriptRoot -Exclude 'bin'

# ╭─────────╮
# │ Generic │
# ╰─────────╯
[Tracker[int]] $Tracker = [Tracker[int]]::new($Numbers)

[int[]]$SubList = @(1, 2, 3, 4)

$Tracker.Start($SubList)
$Tracker.Complete(1)

Write-Host "Sub List Processed: $($Tracker.IsFinished), Items Left: $($Tracker.Incomplete -join ', ')"

$Tracker.Complete(2)
$Tracker.Complete(3)
$Tracker.Complete(4)

Write-Host "Sub List Processed: $($Tracker.IsFinished), Number of Items Left: $($Tracker.Incomplete.Count)"

Write-Host 'Good Bye :)'

