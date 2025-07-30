using Cs.Type.Interfaces;

using System.Collections.Generic;

namespace Cs.Type.Implementations;

public class OrderedSet<TItem> : IOrderedSet<TItem>
{
    public HashSet<TItem> Set { get; } = [];

    public List<TItem> Items { get; } = [];

    public OrderedSet(TItem[] items)
    {
        for (int i = 0; i < items.Length; i++)
        {
            _ = Add(items[i]);
        }
    }

    public OrderedSet() { }

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

    public TReceipt DoIfExits<TReceipt>(
        TItem item,
        IListAction<TItem, TReceipt> action
    ) where TReceipt : new() => Set.TryGetValue(
        item,
        out TItem? reference
    ) ? action.DoAction(reference)! : new();
}
