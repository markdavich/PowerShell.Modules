using System.Linq;
using System.Collections.Generic;

namespace Cs.Type;

/// <summary>
/// Represents the direction of an item movement within a list.
/// </summary>
public enum ListDirection
{
    None,
    Up,
    Down
}

/// <summary>
/// Contains metadata about an item that was moved in a list, including
/// original index, new index, and the direction of movement.
/// </summary>
public class ItemMoveInfo
{
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
internal class MoveStrategy<TItem>
{
    private readonly OrderedSet<TItem> Set;
    private readonly Dictionary<ListDirection, Action<ItemMoveInfo>> Strategy;

    public MoveStrategy(OrderedSet<TItem> orderedSet)
    {
        Set = orderedSet;
        Strategy = new()
        {
            [ListDirection.Up] = i =>
            {
                if (Set.Set.TryGetValue(Set.Items[i.OriginalIndex!.Value], out TItem item))
                {
                    Set.Items.RemoveAt(i.OriginalIndex.Value);
                    Set.Items.Insert(i.Index!.Value, item);
                }
            },
            [ListDirection.Down] = i =>
            {
                if (Set.Set.TryGetValue(Set.Items[i.OriginalIndex!.Value], out TItem item))
                {
                    Set.Items.Insert(i.Index!.Value, item);
                    Set.Items.RemoveAt(i.OriginalIndex.Value);
                }
            },
            [ListDirection.None] = _ => { }
        };
    }

    /// <summary>
    /// Executes the appropriate move operation based on the direction.
    /// </summary>
    public void Process(ItemMoveInfo info)
    {
        Strategy[info.Direction](info);
    }
}

/// <summary>
/// An ordered set implementation that preserves insertion order and supports
/// controlled item movement (e.g., up, down, top, end) while ensuring uniqueness.
/// </summary>
public class OrderedSet<TItem>
{
    /// <summary>
    /// Internal backing set used to guarantee uniqueness.
    /// </summary>
    internal HashSet<TItem> Set { get; } = new();

    /// <summary>
    /// The ordered list of items.
    /// </summary>
    public List<TItem> Items { get; } = new();

    public OrderedSet(params TItem[] items)
    {
        foreach (var item in items)
        {
            _ = Add(item);
        }
    }

    /// <summary>
    /// Removes an item from the set while preserving order.
    /// </summary>
    public TItem Remove(TItem item)
    {
        if (Set.TryGetValue(item, out TItem reference))
        {
            Items.Remove(reference);
            Set.Remove(reference);
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
            if (Set.TryGetValue(item, out TItem reference))
            {
                Items.Add(reference);
                return reference;
            }
        }

        return item;
    }

    public ItemMoveInfo MoveDown(TItem item) => MoveItem(item, 1);
    public ItemMoveInfo MoveUp(TItem item) => MoveItem(item, -1);
    public ItemMoveInfo MoveToEnd(TItem item) => MoveItem(item, Items.Count);
    public ItemMoveInfo MoveToTop(TItem item) => MoveItem(item, -Items.Count);

    /// <summary>
    /// Orchestrates item movement logic: indexing, direction, and applying the move.
    /// </summary>
    private ItemMoveInfo MoveItem(TItem item, int increment)
    {
        ItemMoveInfo result = new();
        ProcessIndex(result, item, increment);
        ProcessDirection(result);
        ProcessMove(result);
        return result;
    }

    /// <summary>
    /// Calculates and clamps the new index based on the increment.
    /// Sets OriginalIndex and Index on the info object.
    /// This method handles only index logic and allows separation of responsibilities.
    /// </summary>
    private void ProcessIndex(ItemMoveInfo info, TItem item, int increment)
    {
        int currentIndex = Items.IndexOf(item);

        if (currentIndex < 0)
            return;

        info.OriginalIndex = currentIndex;
        int newIndex = currentIndex + increment;
        info.Index = Math.Clamp(newIndex, 0, Items.Count - 1);
    }

    /// <summary>
    /// Determines movement direction (Up, Down, None) from index comparison.
    /// Keeps direction logic isolated to allow reuse and testing.
    /// </summary>
    private void ProcessDirection(ItemMoveInfo info)
    {
        if (info.Index > info.OriginalIndex)
        {
            info.Direction = ListDirection.Down;
        }
        else if (info.Index < info.OriginalIndex)
        {
            info.Direction = ListDirection.Up;
        }
        else
        {
            info.Direction = ListDirection.None;
        }
    }

    /// <summary>
    /// Delegates the actual item movement to a strategy implementation.
    /// This step is the final action in the micro-state machine for MoveItem.
    /// </summary>
    private void ProcessMove(ItemMoveInfo info)
    {
        var strategy = new MoveStrategy<TItem>(this);
        strategy.Process(info);
    }
}
