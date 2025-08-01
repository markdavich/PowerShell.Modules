using namespace System.Collections.Generic
class AbstractTracker {
    hidden [Type]$_itemType 
    hidden [Type]$_trackerType
    hidden [object]$_tracker
    hidden [Type]$_setType

    AbstractTracker([Type]$Type, [array]$ToDos) {
        $this._itemType = $Type

        $dllPath = Join-Path $PSScriptRoot 'Cs.Type.dll'

        Write-Host ([DateTime]::Now)
        Write-Host $dllPath
        Write-Host 'asdf'

        $assembly = [System.Reflection.Assembly]::LoadFrom($dllPath)

        # Use the loaded assembly to resolve the type directly:
        $trackerOpenType = $assembly.GetType("Cs.Type.Tracker``1", $true)

        # Construct closed generic type (Tracker[$Type])
        $closedTrackerType = $trackerOpenType.MakeGenericType(@($Type))

        # Build a correctly typed array for Tracker<T>
        $typedArray = $this.GetTypedArray($ToDos)

        # Instantiate: equivalent to `new Tracker<TItem>(ToDos)`
        $this._tracker = [Activator]::CreateInstance($closedTrackerType, @(, $typedArray))

        $this._setType = [HashSet``1].MakeGenericType($this._itemType)
    }

    [void] Complete([object]$Item) {
        $this._tracker.Complete(($Item -as $this._itemType))
    }

    [HashSet[object]] ToDo() {
        return ($this._tracker.ToDo -as $this._setType)
    }

    [HashSet[object]] Done() {
        return ($this._tracker.Done -as $this._setType)
    }

    [void] Start([array]$Items) {
        $typedArray = $this.GetTypedArray($Items)
        $this._tracker.Start($typedArray)
    }

    [bool] IsFinished() {
        return $this._tracker.IsFinished()
    }

    [HashSet[object]] GetIncomplete() {
        $result = $this._tracker.GetIncomplete() -as $this._setType
        return $result
    }

    hidden [array] GetTypedArray([array]$Items) {
        $result = [Array]::CreateInstance($this._itemType, $Items.Length)
        [void]$Items.CopyTo($result, 0)
        return $result
    }
}

$TypeAccelerator = [PSObject].Assembly.GetType(
    'System.Management.Automation.TypeAccelerators'
)

$TypeAccelerator::Add('ClassName', [Cs.Type.ClassName``1])