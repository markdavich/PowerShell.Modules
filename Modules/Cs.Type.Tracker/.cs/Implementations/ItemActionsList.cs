using Cs.Type.Enumerations;

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Cs.Type.Implementations;

/// <summary>
/// This class is responsible for managing a dictionary of items and item actions
/// </summary>
public class ItemActionsList<TItem> where TItem : class
{
    private readonly Dictionary<TItem, ItemActions> _items = [];

    public int Count => _items.Values.Sum(
        (ItemActions actions) => actions.Count
    );

    public void CountAction(TItem item, ItemAction action)
    {
        Debug.WriteLine("ItemActionList.CountAction");

        if (_items.TryGetValue(item, out ItemActions? actions) && actions is not null)
        {
            Debug.WriteLine("ItemActionList.CountAction: Found item");
            actions.Register(action);
            Debug.WriteLine("ItemActionList.CountAction: Done");
            return;
        }

        InitializeActions(item).Register(action);
        Debug.WriteLine("ItemActionList.CountAction: Done");
    }

    public int GetCount(TItem item, ItemAction action) =>
        GetActions(item).CountWhere(action);

    public int GetCount(TItem item) => GetActions(item).Count;

    public ItemActions GetActions(TItem item) => _items.TryGetValue(
        item,
        out ItemActions? value
    ) ? value : InitializeActions(item);

    private ItemActions InitializeActions(TItem item)
    {
        Debug.WriteLine($"ItemActionsList.InitializeActions: Initializing actions for item {item}");
        _items.Add(item, new ItemActions());
        return _items[item];
    }
}
