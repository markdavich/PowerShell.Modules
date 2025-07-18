using module User.Abstracts.Tracker

[string[]] $s = @('a', 'b', 'c')

[AbstractTracker] $t = [AbstractTracker]::new([string], $s)

Write-Host hello