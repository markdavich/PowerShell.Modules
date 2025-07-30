using Cs.Type.Enumerations;

namespace Cs.Type.Implementations;

/// <summary>
/// Contains metadata about an item that was moved in a list, including
/// original index, new index, and the direction of movement.
/// </summary>
public class ItemMoveInfo
{
    public ItemAction Action { get; internal set; } = ItemAction.None;

    public ListDirection Direction { get; internal set; } = ListDirection.None;

    public int? Index { get; internal set; } = null;

    public int? OriginalIndex { get; internal set; } = null;

    /// <summary>
    /// Indicates whether the item was actually moved.
    /// </summary>
    public bool WasMoved =>
        OriginalIndex.HasValue
        &&
        Index.HasValue
        &&
        (OriginalIndex.Value != Index.Value);
}
