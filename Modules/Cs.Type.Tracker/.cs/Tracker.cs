using System.Linq;
using System.Collections.Generic;

namespace Cs.Type;

public class Tracker<TItem>(TItem[] toDos)
{
    private int _initialCount = 0;

    public HashSet<TItem> SubList { get; private set; } = new(toDos);

    public HashSet<TItem> ToDo { get; private set; } = new(toDos);

    public HashSet<TItem> Done { get; private set; } = [];

    /// <summary>
    /// Completes the Item by removing it from ToDo and adding it to Done
    /// </summary>
    /// <param name="item"></param>
    public void Complete(TItem item)
    {
        _ = ToDo.Remove(item);
        _ = Done.Add(item);
    }

    /// <summary>
    /// Items is a sub-list of objects that you have in "ToDo", when you invoke<br></br>
    /// <b>Start</b>, Tracker starts tracking the sub-list, "items". You can track<br></br>
    /// your progress by checking <see cref="IsFinished()"/> and <see cref="GetIncomplete()"/>  
    /// </summary>
    /// <param name="items"></param>
    public void Start(TItem[] items)
    {
        SubList = new(items);
        _initialCount = Done.Count;
    }

    public void Finish()
    {
        SubList = new(ToDo);
        _initialCount = ToDo.Count;
    }

    public bool IsFinished => (Done.Count - _initialCount) == SubList.Count;

    public TItem[] Incomplete =>
        SubList.Where(item => !Done.Contains(item)).ToArray();
}
