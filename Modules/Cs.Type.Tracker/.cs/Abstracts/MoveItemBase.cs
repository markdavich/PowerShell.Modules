using Cs.Type.Enumerations;
using Cs.Type.Implementations;
using Cs.Type.Interfaces;

using System.Collections.Generic;

namespace Cs.Type.Abstracts;

public abstract class MoveItemBase<TItem>(List<TItem> items) : IListAction<TItem, ItemMoveInfo>
{
    protected readonly List<TItem> Items = items;

    public ItemMoveInfo DoAction(TItem item)
    {
        // The object doing the moving should be in charge of creating the "receipt" right?
        ItemMoveInfo result = new()
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
