using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Cs.Type;

// Navarion
// BEGIN Architecture Specification -------------------------------------------
public enum ListDirection
{
    None,
    Up,
    Down,
}

[Flags]
public enum ItemAction
{
    None = 0,
    MoveUp = 1,
    MoveDown = 2,
    MoveToEnd = 4,
    MoveToTop = 8,
    Complete = 16,
}

public interface IListAction<TItem, TReceipt>
{
    public TReceipt? DoAction(TItem item);
}

public interface IOrderedSet<TItem>
{
    HashSet<TItem> Set { get; }

    List<TItem> Items { get; }

    public TReceipt DoIfExits<TReceipt>(TItem item, IListAction<TItem, TReceipt> action) where TReceipt : new();
}

public class OrderedSet<TItem> : IOrderedSet<TItem>
{
    public HashSet<TItem> Set { get; } = [];
    public List<TItem> Items { get; } = [];

    public XOrderedSet(TItem[] items)
    {
        for (int i = 0; i < items.Length; i++)
        {
            _ = Add(items[i]);
        }
    }

    /// <summary>
    /// Adds a unique item to the end of the list.
    /// </summary>
    public TItem Add(TItem item)
    {
        if (Set.Add(item))
        {
            if (Set.TryGetValue(item, out TItem? reference))
            {
                Items.Add(reference);
                return reference;
            }
        }

        return item;
    }

    public TReceipt DoIfExits<TReceipt>(
        TItem item, 
        IListAction<TItem, TReceipt> action
    ) where TReceipt : new() => Set.TryGetValue(
        item, 
        out TItem? reference
    ) ? action.DoAction(reference)! : new();
}

public abstract class MoveItemBase<TItem>(List<TItem> items) : IListAction<TItem, ItemMoveInfo>
{
    protected readonly List<TItem> Items = items;

    public ItemMoveInfo DoAction(TItem item)
    {
        // The object doing the moving should be in charge of creating the "receipt" right?
        ItemMoveInfo result = new ()
        {
            Action = Action
        };

        int current = Items.IndexOf(item);

        result.Action = Action;

        if (current < 0)
        {
            return result;
        }

        result.OriginalIndex = current;
        result.Index = CalculateTargetIndex(current);

        Move(item, current, result.Index.Value);

        result.Direction = Direction;

        return result;
    }

    private ListDirection Direction => Action switch
    {
        ItemAction.MoveUp or ItemAction.MoveToTop => ListDirection.Up,
        ItemAction.MoveDown or ItemAction.MoveToEnd => ListDirection.Down,
        _ => ListDirection.None
    };

    protected abstract ItemAction Action { get; }

    protected abstract int CalculateTargetIndex(int current);

    private void Move(TItem item, int from, int to)
    {
        if (from == to)
        {
            return;
        }

        Items.RemoveAt(from);

        // Adjust target index if moving "up"
        if (to > from)
        {
            to--;
        }

        Items.Insert(to, item);
    }
}

public class MoveItemDown<TItem>(List<TItem> items) : MoveItemBase<TItem>(items)
{
    protected override ItemAction Action => ItemAction.MoveDown;

    protected override int CalculateTargetIndex(int current)
        => Math.Clamp(current + 1, current, Items.Count);
}

public class MoveItemToEnd<TItem>(List<TItem> items) : MoveItemBase<TItem>(items)
{
    protected override ItemAction Action => ItemAction.MoveToEnd;

    protected override int CalculateTargetIndex(int current)
        => Items.Count;
}

public class MoveItemUp<TItem>(List<TItem> items) : MoveItemBase<TItem>(items)
{
    protected override ItemAction Action => ItemAction.MoveUp;

    protected override int CalculateTargetIndex(int current)
        => Math.Clamp(current - 1, 0, current);
}

public class MoveItemToTop<TItem>(List<TItem> items) : MoveItemBase<TItem>(items)
{
    protected override ItemAction Action => ItemAction.MoveToTop;

    protected override int CalculateTargetIndex(int current)
        => 0;
}

// END Architecture Specification ---------------------------------------------

// BEGIN Implementation -------------------------------------------------------
// These need to be refactored to use the Architecture Specification

public class ItemActions
{
    private readonly List<ItemAction> _actions = new();

    public IReadOnlyList<ItemAction> Actions => _actions.AsReadOnly();

    public int Count => _actions.Count;

    public int CountWhere(ItemAction action) => _actions.Where(
        itemAction => itemAction == action
    ).Count();

    internal void Register(ItemAction action)
    {
        if (action != ItemAction.None)
        {
            return;
        }

        _actions.Add(action);
    }
}

/// <summary>
/// This class is responsible for managing a dictionary of items and item actions
/// </summary>
public class ItemActionsList<TItem> where TItem : class
{
    private readonly Dictionary<TItem, ItemActions> _items = [];

    public int Count => _items.Values.Sum(
        (ItemActions actions) => actions.Count
    );

    public int GetCount(TItem item, ItemAction action) =>
        GetActions(item).CountWhere(action);

    public int GetCount(TItem item) => GetActions(item).Count;

    public ItemActions GetActions(TItem item) => _items.TryGetValue(
        item,
        out ItemActions? value
    ) ? value : InitializeActions(item);

    private ItemActions InitializeActions(TItem item) =>
        // ??? _items.TryAdd(item, new ItemActions());
        throw new NotImplementedException();

    p
}

/// <summary>
/// Contains metadata about an item that was moved in a list, including
/// original index, new index, and the direction of movement.
/// </summary>
public class ItemMoveInfo
{
    public ItemAction Action { get; internal set; } = ItemAction.None;

    public ListDirection Direction { get; internal set; } = ListDirection.None;

    public int? Index { get; internal set; } = null;

    public int? OriginalIndex { get; internal set; } = null;

    /// <summary>
    /// Indicates whether the item was actually moved.
    /// </summary>
    public bool WasMoved =>
        OriginalIndex.HasValue
        &&
        Index.HasValue
        &&
        (OriginalIndex.Value != Index.Value);
}

/// <summary>
/// Internal strategy class implementing the Strategy pattern to encapsulate
/// behavior for moving items in different directions within an OrderedSet.
/// </summary>
internal class MoveStrategy<TItem> where TItem : class
{
    private readonly OrderedSet<TItem> _set;
    private readonly Dictionary<ListDirection, Action<ItemMoveInfo>> _strategy;

    public MoveStrategy(OrderedSet<TItem> orderedSet)
    {
        _set = orderedSet;
        _strategy = new()
        {
            [ListDirection.Up] = i =>
            {
                if (
                    _set.Set.TryGetValue(
                        _set.Items[
                        i.OriginalIndex!.Value], out TItem? item
                    )
                )
                {
                    _set.Items.RemoveAt(i.OriginalIndex.Value);
                    _set.Items.Insert(i.Index!.Value, item);
                }
            },
            [ListDirection.Down] = i =>
            {
                if (
                    _set.Set.TryGetValue(
                        _set.Items[
                        i.OriginalIndex!.Value], out TItem? item
                    )
                )
                {
                    _set.Items.Insert(i.Index!.Value, item);
                    _set.Items.RemoveAt(i.OriginalIndex.Value);
                }
            },
            [ListDirection.None] = _ => { }
        };
    }

    /// <summary>
    /// Executes the appropriate move operation based on the direction.
    /// </summary>
    public void Process(ItemMoveInfo info) =>
        _strategy[info.Direction](info);
}

/// <summary>
/// An ordered set implementation that preserves insertion order and supports
/// controlled item movement (e.g., up, down, top, end) while ensuring uniqueness.
/// </summary>
public class OrderedSet<TItem> where TItem : class
{
    internal HashSet<TItem> Set { get; } = [];

    /// <summary>
    /// The ordered list of items.
    /// </summary>
    public List<TItem> Items { get; } = [];

    public OrderedSet(params TItem[] items)
    {
        foreach (TItem item in items)
        {
            _ = Add(item);
        }
    }

    /// <summary>
    /// Removes an item from the set while preserving order.
    /// </summary>
    public TItem Remove(TItem item)
    {
        if (Set.TryGetValue(item, out TItem? reference))
        {
            _ = Items.Remove(reference);
            _ = Set.Remove(reference);
            return reference;
        }

        return item;
    }

    /// <summary>
    /// Adds a unique item to the end of the list.
    /// </summary>
    public TItem Add(TItem item)
    {
        if (Set.Add(item))
        {
            if (Set.TryGetValue(item, out TItem? reference))
            {
                Items.Add(reference);
                return reference;
            }
        }

        return item;
    }

    public ItemMoveInfo MoveUp(TItem item) =>
        MoveItem(item, ItemAction.MoveUp);

    public ItemMoveInfo MoveToTop(TItem item) =>
        MoveItem(item, ItemAction.MoveToTop);

    public ItemMoveInfo MoveDown(TItem item) =>
        MoveItem(item, ItemAction.MoveDown);

    public ItemMoveInfo MoveToEnd(TItem item) =>
        MoveItem(item, ItemAction.MoveToEnd);

    /// <summary>
    /// Orchestrates item movement logic: indexing, direction, and applying the move.
    /// </summary>
    private ItemMoveInfo MoveItem(TItem item, ItemAction action)
    {
        ItemMoveInfo result = new()
        {
            Action = action
        };

        int increment = GetIncrement(action);
        ProcessIndex(result, item, increment);
        ProcessDirection(result);
        ProcessMove(result);
        return result;
    }

    private int GetIncrement(ItemAction action) => action switch
    {
        ItemAction.MoveUp => -1,
        ItemAction.MoveToTop => -Items.Count,
        ItemAction.MoveDown => 1,
        ItemAction.MoveToEnd => Items.Count,
        _ => 0
    };

    /// <summary>
    /// Calculates and clamps the new index based on the increment.
    /// Sets OriginalIndex and Index on the info object.
    /// This method handles only index logic and allows separation of responsibilities.
    /// </summary>
    private void ProcessIndex(ItemMoveInfo info, TItem item, int increment)
    {
        int currentIndex = Items.IndexOf(item);

        if (currentIndex < 0)
        {
            return;
        }

        info.OriginalIndex = currentIndex;
        int newIndex = currentIndex + increment;
        info.Index = Math.Clamp(newIndex, 0, Items.Count);
    }

    /// <summary>
    /// Determines movement direction (Up, Down, None) from index comparison.
    /// Keeps direction logic isolated to allow reuse and testing.
    /// </summary>
    private static void ProcessDirection(ItemMoveInfo info)
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

    /// <summary>
    /// Delegates the actual item movement to a strategy implementation.
    /// This step is the final action in the micro-state machine for MoveItem.
    /// </summary>
    private void ProcessMove(ItemMoveInfo info) =>
        new MoveStrategy<TItem>(this).Process(info);
}

/// <summary>
/// Provides a filtered and controlled view of an OrderedSet for safe access by consumers.
/// </summary>
public class TrackerListView<TItem>(
    OrderedSet<TItem> backing,
    Func<ItemMoveInfo, ItemMoveInfo>? recorder = null
) where TItem : class
{
    private readonly OrderedSet<TItem> _backing = backing;

    private readonly Func<ItemMoveInfo, ItemMoveInfo>? _recorder = recorder;

    public TItem[] Items => [.. _backing.Items];

    public ItemMoveInfo MoveUp(TItem item) => Process(item, _backing.MoveUp);

    public ItemMoveInfo MoveDown(TItem item) => Process(item, _backing.MoveDown);

    public ItemMoveInfo MoveToTop(TItem item) => Process(item, _backing.MoveToTop);

    public ItemMoveInfo MoveToEnd(TItem item) => Process(item, _backing.MoveToEnd);

    private ItemMoveInfo Process(TItem item, Func<TItem, ItemMoveInfo> mover)
    {
        ItemMoveInfo result = mover(item);
        return _recorder?.Invoke(result) ?? result;
    }
}

/// <summary>
/// A generic tracker used to manage processing of items across states: ToDo, Done, and SubList.
/// Ensures controlled state transitions, maintains item order, and supports retry metrics.
/// </summary>
public class Tracker<TItem> where TItem : class
{
    private int _initialCount = 0;

    private readonly ItemActionsList<TItem> _actions = new();

    private readonly OrderedSet<TItem> _toDo;

    private readonly OrderedSet<TItem> _done = new();

    private OrderedSet<TItem> subList;

    public TrackerListView<TItem> ToDo { get; }

    public TrackerListView<TItem> SubList { get; }

    public IReadOnlyList<TItem> Done => _done.Items.AsReadOnly();

    public Tracker(TItem[] toDos)
    {
        _toDo = new(toDos);
        subList = new(toDos);

        ToDo = new(_toDo, OnMove);
        SubList = new(subList, OnMove);
    }

    /// <summary>
    /// Begins tracking a new set of sub-items, clearing any previous sub-tracking.
    /// </summary>
    public void Start(TItem[] items)
    {
        subList = new(items);
        _initialCount = _done.Items.Count;
    }

    public bool IsFinished => (Done.Count - _initialCount) == SubList.Items.Length;

    public TItem[] Incomplete =>
        SubList.Items.Where(item => !Done.Contains(item)).ToArray();

    /// <summary>
    /// Marks an item as completed, moving it from ToDo to Done.
    /// </summary>
    public void Complete(TItem item) => _ = _done.Add(
        _toDo.Remove(
            Count(item)
        )
    );

    /// <summary>
    /// Increments the handle count for a given item.
    /// </summary>
    private TItem Count(TItem item) => _actions.GetCount(item);

    private ItemMoveInfo OnMove(ItemMoveInfo info) // info will now use the ItemAction enum instead of the ListDirection enum
    {
        throw new NotImplementedException();
        _actions.GetActions(item).Register(item.Action); // this will throw
    }
}
// END Implementation ---------------------------------------------------------