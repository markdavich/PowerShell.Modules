using namespace System.IO
using namespace System.Collections.Generic
using module User.Abstracts.Tracker

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