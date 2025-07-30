using System.Collections.Generic;

namespace Cs.Type.Interfaces;

public interface IOrderedSet<TItem>
{
    HashSet<TItem> Set { get; }

    List<TItem> Items { get; }

    public TReceipt DoIfExits<TReceipt>(TItem item, IListAction<TItem, TReceipt> action) where TReceipt : new();
}
