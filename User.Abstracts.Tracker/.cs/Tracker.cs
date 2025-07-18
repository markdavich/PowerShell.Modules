using System.Linq;
using System.Collections.Generic;

namespace Cs.Type;

public class Tracker<TItem> {
    private int _initialCount;
    private IEnumerable<TItem> _items;
    private HashSet<TItem> _todo;
    private HashSet<TItem> _done;

    public Tracker(TItem[] toDos) {
        _todo = new HashSet<TItem>(toDos);
        _done = new HashSet<TItem>();
    }

    public void Complete(TItem item) {
        _todo.Remove(item);
        _done.Add(item);
    }

    public void Start(IEnumerable<TItem> items) {
        _items = items;
        _initialCount = _done.Count;
    }

    public bool IsFinished() => (_done.Count - _initialCount) == _items.Count();

    public HashSet<TItem> GetIncomplete() =>
        _items.Where(item => !_done.Contains(item)).ToHashSet();

    public HashSet<TItem> Done() => _done;

    public HashSet<TItem> ToDo() => _todo;
}
