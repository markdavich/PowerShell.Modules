using Cs.Type.Abstracts;
using Cs.Type.Enumerations;

using System;
using System.Collections.Generic;

namespace Cs.Type.Implementations.MoveItem;

public class MoveItemUp<TItem>(List<TItem> items) : MoveItemBase<TItem>(items)
{
    protected override ItemAction Action => ItemAction.MoveUp;

    protected override int CalculateTargetIndex(int current)
        => Math.Clamp(current - 1, 0, current);
}
