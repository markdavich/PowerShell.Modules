using Cs.Type.Enumerations;
using Cs.Type.Implementations;

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Cs.Type;

/// <summary>
/// A generic tracker used to manage processing of items across states: ToDo, Done, and SubList.
/// Ensures controlled state transitions, maintains item order, and supports retry metrics.
/// </summary>
public class Tracker<TItem> where TItem : class
{
    private int _initialCount = 0;

    private readonly ItemActionsList<TItem> _actions = new();

    private OrderedSet<TItem> _toDo = default!;

    private readonly OrderedSet<TItem> _done = new();

    private OrderedSet<TItem> _subList = default!;

    public TrackerListView<TItem> ToDo { get; private set; } = default!;

    public TrackerListView<TItem> SubList { get; private set; } = default!;

    public IReadOnlyList<TItem> Done => _done.Items.AsReadOnly();

    public Tracker(TItem[] toDos)
    {
        SetToDos(toDos);
        SetSubItems(toDos);
    }

    /// <summary>
    /// Begins tracking a new set of sub-items, clearing any previous sub-tracking.
    /// </summary>
    public void Start(TItem[] items)
    {
        SetSubItems(items);

        _initialCount = _done.Items.Count;
    }

    private void SetSubItems(TItem[] items)
    {
        _subList = new(items);
        SubList = new(_subList, OnMove);
    }

    private void SetToDos(TItem[] items)
    {
        _toDo = new(items);
        ToDo = new(_toDo, OnMove);
    }

    public bool IsFinished
    {
        get
        {
            return Done.Count - _initialCount == SubList.Items.Length;
        }
    }

    public TItem[] Incomplete =>
        SubList.Items.Where(item => !Done.Contains(item)).ToArray();

    /// <summary>
    /// Marks an item as completed, moving it from ToDo to Done.
    /// </summary>
    public void Complete(TItem item) => _ = _done.Add(
        _toDo.Remove(
            Count(item, ItemAction.Complete)
        )
    );

    /// <summary>
    /// Increments the handle count for a given item.
    /// </summary>
    private TItem Count(TItem item, ItemAction action)
    {
        Debug.WriteLine($"Tracker.Count({item}, {action})");

        _actions.CountAction(item, action);
        return item;
    }

    private ItemMoveInfo OnMove(TItem item, ItemMoveInfo info) // info will now use the ItemAction enum instead of the ListDirection enum
    {
        _ = Count(item, info.Action);
        return info;
    }
}