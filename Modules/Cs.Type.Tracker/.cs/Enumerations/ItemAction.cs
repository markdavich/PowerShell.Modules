using System;

namespace Cs.Type.Enumerations;

[Flags]
public enum ItemAction
{
    None = 0,
    MoveUp = 1,
    MoveDown = 2,
    MoveToEnd = 4,
    MoveToTop = 8,
    Complete = 16,
}
