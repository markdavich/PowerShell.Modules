using namespace System.Management.Automation

class Variable {
    [string] $Name
    [object] $Value

    Variable([string] $Name, [object] $Value) {
        $this.Name = $Name
        $this.Value = $Value
        $this.SetGlobal()
    }

    Variable([string] $Name, [object] $Value, [SessionState] $Session) {
        $this.Name = $Name
        $this.Value = $Value
        $this.SetLocal($Session)
    }

    hidden [void] SetGlobal() {
        Remove-Variable -Name $this.Name -Scope Global -Force -ErrorAction SilentlyContinue
        Set-Variable   -Name $this.Name -Value $this.Value -Option ReadOnly -Scope Global -Force -ErrorAction SilentlyContinue
    }

    hidden [void] SetLocal([SessionState] $Session) {
        try { $null = $Session.PSVariable.Remove($this.Name, $true) } catch {}
        $psVar = [PSVariable]::new($this.Name, $this.Value, [ScopedItemOptions]::ReadOnly)
        $Session.PSVariable.Set($psVar)  # sets in caller scope
    }
}

function Add-Local {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][object]$Value
    )

    if ($Value -is [string] -and $Value -match '\$') {
        $Value = $PSCmdlet.SessionState.InvokeCommand.ExpandString($Value)
    }

    return [Variable]::new($Name, $Value, $PSCmdlet.SessionState)
}

function Add-Global {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][object]$Value
    )

    if ($Value -is [string] -and $Value -match '\$') {
        $Value = $PSCmdlet.SessionState.InvokeCommand.ExpandString($Value)
    }

    return [Variable]::new($Name, $Value)
}
