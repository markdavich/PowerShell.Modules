using namespace System.Collections.Generic



class AbstractTracker {
    hidden [Type]$_itemType 
    hidden [Type]$_trackerType
    hidden [object]$_tracker
    hidden [Type]$_setType

    AbstractTracker([Type]$Type, [array]$ToDos) {
        $this._itemType = $Type

        # The PowerShell equivalent of the C# type, Tracker<T>, is Tracker`1
        $TrackerClassDefinition = @'
using System.Linq;
using System.Collections.Generic;

public class Tracker<T> {
    private int _initialCount;
    private IEnumerable<T> _items;
    private HashSet<T> _todo;
    private HashSet<T> _done;

    public Tracker(T[] toDos) {
        _todo = new HashSet<T>(toDos);
        _done = new HashSet<T>();
    }

    public void Complete(T item) {
        _todo.Remove(item);
        _done.Add(item);
    }

    public void Start(IEnumerable<T> items) {
        _items = items;
        _initialCount = _done.Count;
    }

    public bool IsFinished() => (_done.Count - _initialCount) == _items.Count();

    public HashSet<T> GetIncomplete() =>
        _items.Where(item => !_done.Contains(item)).ToHashSet();

    public HashSet<T> Done() => _done;

    public HashSet<T> ToDo() => _todo;
}
'@


        Add-Type -TypeDefinition $TrackerClassDefinition -Language CSharp

        $trackerOpenType = [AppDomain]::CurrentDomain.GetAssemblies() |
            ForEach-Object { $_.GetType("Tracker``1", $false) } |
            Where-Object { $_ -ne $null } |
            Select-Object -First 1

        # The PowerShell equivalent of the C# type, Tracker<T>, is Tracker`1
        $this._trackerType = $trackerOpenType.MakeGenericType($this._itemType)

        # Build a correctly typed array for Tracker<T>
        $typedArray = $this.GetTypedArray($ToDos)

        $this._tracker = ([System.Activator]::CreateInstance(
                $this._trackerType, 
                @(, $typedArray))
        )
        
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