function Convert-ToType {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]$Value,

        [Parameter(Mandatory)]
        [Type]$Type,

        [switch]$ThrowOnFailure
    )

    # Null passthrough
    if ($null -eq $Value) {
        return $null
    }

    # If already assignable
    if ($Type.IsInstanceOfType($Value)) {
        return $Value
    }

    try {
        # Try Convert.ChangeType for primitives and some common types
        return [Convert]::ChangeType($Value, $Type)
    }
    catch {
        # Fall back to -as casting (safe but returns null if invalid)
        $casted = $Value -as $Type

        if ($null -eq $casted -and $ThrowOnFailure) {
            throw "Failed to cast value of type [$($Value.GetType().FullName)] to [$($Type.FullName)]"
        }

        return $casted
    }
}

function Test-IsPrimitive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object]$Value
    )

    $type = if ($Value -is [Type]) {
        $Value
    }
    else {
        $Value.GetType()
    }

    if ($type.IsGenericType -and $type.GetGenericTypeDefinition() -eq [Nullable``1]) {
        $type = $type.GetGenericArguments()[0]
    }

    return (
        $type -eq [string] -or
        $type -eq [char] -or
        $type -eq [bool] -or
        $type -eq [byte] -or
        $type -eq [int16] -or
        $type -eq [int32] -or
        $type -eq [int64] -or
        $type -eq [uint16] -or
        $type -eq [uint32] -or
        $type -eq [uint64] -or
        $type -eq [float] -or
        $type -eq [double] -or
        $type -eq [decimal] -or
        $type -eq [datetime] -or
        $type.IsEnum
    )
}


Export-ModuleMember -Function `
    'Convert-ToType', `
    'Test-IsPrimitive'