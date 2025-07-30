using System;

using Cs.Type.Implementations.MoveItem;
using Cs.Type.Interfaces;

namespace Cs.Type.Implementations;

/// <summary>
/// Provides a filtered and controlled view of an OrderedSet for safe access by consumers.
/// </summary>
public class TrackerListView<TItem>(
    OrderedSet<TItem> backing,
    Func<TItem, ItemMoveInfo, ItemMoveInfo>? recorder = null
) where TItem : class
{
    private readonly OrderedSet<TItem> _backing = backing;
    private readonly Func<TItem, ItemMoveInfo, ItemMoveInfo>? _recorder = recorder;

    public TItem[] Items => [.. _backing.Items];

    public ItemMoveInfo MoveUp(TItem item) => Process(
        item,
        new MoveItemUp<TItem>(_backing.Items)
    );

    public ItemMoveInfo MoveDown(TItem item) => Process(
        item,
        new MoveItemDown<TItem>(_backing.Items)
    );

    public ItemMoveInfo MoveToTop(TItem item) => Process(
        item,
        new MoveItemToTop<TItem>(_backing.Items)
    );

    public ItemMoveInfo MoveToEnd(TItem item) => Process(
        item,
        new MoveItemToEnd<TItem>(_backing.Items)
    );

    private ItemMoveInfo Process(TItem item, IListAction<TItem, ItemMoveInfo> mover)
    {
        ItemMoveInfo result = _backing.DoIfExits(item, mover);
        return _recorder?.Invoke(item, result) ?? result;
    }
}
