namespace Cs.Type.Interfaces;

public interface IListAction<TItem, TReceipt>
{
    public TReceipt? DoAction(TItem item);
}
