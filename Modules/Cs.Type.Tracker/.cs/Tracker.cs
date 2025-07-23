using System.Linq;
using System.Collections.Generic;

namespace Cs.Type;


public enum ListDirection
{
    None,
    Up,
    Down
}

public class ItemMoveInfo
{
    public ListDirection Direction { get; internal set; } = ListDirection.None;
    public int? Index { get; internal set; } = null;
    public int? OriginalIndex { get; internal set; } = null;
    public bool WasMoved =>
        OriginalIndex.HasValue
        &&
        Index.HasValue
        &&
        (OriginalIndex.Value != Index.Value);
}

public class OrderedSet<TItem>
{
    private HashSet<TItem> Set { get; } = new();
    public List<TItem> Items { get; } = new();

    public OrderedSet OrderedSet(TItem[] items)
    {
        for (int i = 0; i < items.Length; i++)
        {
            TItem item = items[i];
            bool added = Set.Add(item);
            if (added)
            {
                TItem reference;
                bool found = Set.TryGetValue(item, out add);

                if (found)
                {
                    Items.Add(reference);
                    ListOrder[reference] = ListOrder.Count;
                }
            }
        }
    }

    public ItemMoveInfo MoveDown(TItem item) => MoveItem(item, 1);

    public ItemMoveInfo MoveUp(TItem item) => MoveItem(item, -1);

    public ItemMoveInfo MoveToEnd(TItem item) => MoveItem(item, Items.Count);

    public ItemMoveInfo MoveToTop(TItem item) => MoveItem(item, -Items.Count);

    private ItemMoveInfo MoveItem(TItem item, int increment)
    {

        ItemMoveInfo result = new();

        if (Set.TryGetValue(item, out TItem reference))
        {
            ProcessNextIndex(item, ref result);
        }

        ProcessMove(result);

        return result;
    }

    private void ProcessNextIndex(TItem item, int increment, ref ItemMoveInfo info)
    {
        int currentIndex = Items.IndexOf(item);

        if (currentIndex < 0)
        {
            return;
        }

        info.OriginalIndex = currentIndex;

        ProcessIndex(ref info, increment);
        ProcessDirection(ref info);
    }

    private int ProcessIndex(ref ItemMoveInfo info, int increment)
    {
        int newIndex = info.OriginalIndex + increment;

        if (newIndex >= Items.Count)
        {
            info.Index = Items.Count - 1;
            return;
        }

        if (newIndex < 0)
        {
            info.Index = 0;
            return;
        }
    }

    private ListDirection ProcessDirection(ref ItemMoveInfo info)
    {
        if (info.Index > info.OriginalIndex)
        {
            info.Direction = ListDirection.Down;
            return;
        }

        if (info.Index < info.OriginalIndex)
        {
            info.Direction = ListDirection.Up;
            return;
        }

        info.Direction = ListDirection.None;
    }

    private void ProcessMove(ref ItemMoveInfo info)
    {
        switch (info.Direction)
        {
            case ListDirection.Up:
                ProcessMoveUp(info);
                break;

            case ListDirection.Down:
                ProcessMoveDown(info);
                break;
        }
    }

    private void ProcessMoveUp(ItemMoveInfo info)
    {
        // When moving up we can remove the item without affecting the
        // index where the item will be inserted. So we just remove the
        // item at the original index and insert a reference at the new
        // index.
        if (Set.TryGetValue(Items[info.OriginalIndex], out TItem referenceItem))
        {
            Items.RemoveAt(info.OriginalIndex);
            Items.Insert(info.Index, referenceItem);
        }
    }

    private void ProcessMoveDown(ItemMoveInfo info)
    {
        // When moving an item down, we can insert a reference a the index,
        // which will not affect the current index of the item, after the
        // insert we remove the item at the original index.
        if (Set.TryGetValue(Items[info.OriginalIndex], out TItem referenceItem))
        {
            Items.Insert(info.Index, referenceItem);
            Items.RemoveAt(info.OriginalIndex);
        }
    }
}

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
