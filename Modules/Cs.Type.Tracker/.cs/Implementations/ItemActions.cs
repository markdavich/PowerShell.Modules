using Cs.Type.Enumerations;

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Cs.Type.Implementations;

public class ItemActions
{
    private readonly List<ItemAction> _actions = [];

    public IReadOnlyList<ItemAction> Actions => _actions.AsReadOnly();

    public int Count => _actions.Count;

    public int CountWhere(ItemAction action) => _actions.Where(
        itemAction => itemAction == action
    ).Count();

    internal void Register(ItemAction action)
    {
        Debug.WriteLine($"ItemActions.Register(ItemAction: {action})");

        if (action == ItemAction.None)
        {
            Debug.WriteLine($"ItemActions.Register: Exit Early -> ItemAction.None");
            return;
        }

        Debug.WriteLine($"ItemActions.Register: Adding action {action} to actions list");

        _actions.Add(action);

        Debug.WriteLine($"ItemActions.Register: Done");
    }
}
