using Cs.Type.Abstracts;
using Cs.Type.Enumerations;

using System;
using System.Collections.Generic;

namespace Cs.Type.Implementations.MoveItem;

public class MoveItemToEnd<TItem>(List<TItem> items) : MoveItemBase<TItem>(items)
{
    protected override ItemAction Action => ItemAction.MoveToEnd;

    protected override int CalculateTargetIndex(int current) => Items.Count;
}
