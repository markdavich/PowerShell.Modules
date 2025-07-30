using Cs.Type.Abstracts;
using Cs.Type.Enumerations;

using System;
using System.Collections.Generic;

namespace Cs.Type.Implementations.MoveItem;

public class MoveItemToTop<TItem>(List<TItem> items) : MoveItemBase<TItem>(items)
{
    protected override ItemAction Action => ItemAction.MoveToTop;

    protected override int CalculateTargetIndex(int current) => 0;
}
