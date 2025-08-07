using namespace System.IO
using namespace System.Collections.Generic
using module Bop.A.Tracker

Write-Host "<[" -ForegroundColor Green -NoNewline
Write-Host "Bops.Lib! " -ForegroundColor Yellow -NoNewline
Write-Host "[M] " -ForegroundColor Magenta -NoNewline
Write-Host $MyInvocation.MyCommand.Path -ForegroundColor Cyan -NoNewline
Write-Host "]" -ForegroundColor Green

class FileSystemTracker : AbstractTracker {
    hidden [AbstractTracker]$base = [AbstractTracker]$this

    FileSystemTracker([FileSystemInfo[]]$ToDos) : base(
        [FileSystemInfo], 
        $ToDos
    ) { }

    [void] Complete([FileSystemInfo]$Item) {
        $this.base.Complete($Item)
    }

    [HashSet[FileSystemInfo]] ToDo() {
        return [HashSet[FileSystemInfo]]$this.base.ToDo()
    }

    [HashSet[FileSystemInfo]] Done() {
        return [HashSet[FileSystemInfo]]$this.base.Done()
    }

    [HashSet[FileSystemInfo]] GetIncomplete() {
        return [HashSet[FileSystemInfo]]$this.base.GetIncomplete()
    }
}



