# Cs.Type.CoreMarshal

## Overview
This **PowerShell** module uses a compiled C# class.

### C# Class Library & PowerShell Module Project

```
📁Modules
╰──📁Cs.Type.CoreMarshal
    ├──📁.cs
    │   ├──📦Cs.Type.csproj
    │   ├──📜Cs.Type.ps1 (For testing the module)
    │   ╰──📜CoreMarshal.cs
    ├──🧰Cs.Type.CoreMarshal.psm1
    ├──📥Cs.Type.dll
    ╰──📖README.md
```

## Prerequsites
- Install .NET SDK <span style="padding: 0.20em 1em 0.25em 1em ; border-radius: calc(4rem / 2); background-color: #7455dd; color: #ded3ffff"><a href="https://dotnet.microsoft.com/en-us/download">Standard Term Support</a></span>
- Latest version of PowerShell  
  
  ```powershell
  # Check the latest version of PowerShell
  winget search Microsoft.PowerShell

  # Install the latest version of PowerShell
  winget install --id Microsoft.PowerShell --source winget

  # Upgrade installed PowerShell to latest version
  winget upgrade Microsoft.PowerShell
  ```

## Implementation
- `Cs.Type` is the `C#` namespace
- `CoreMarshal` is the `C#` class

### 1. Build `.dll`

Open a terminal at the project root and build using the following:  
| Tool         | Command                         | Notes                                   |
| :----------- | :------------------------------ | :-------------------------------------- |
| **.NET CLI** | `dotnet build .\Cs.Type.csproj` | Uses `Cs.Type.csproj` for configuration |

### 2. Import `.dll` and Create Type Accelerator in PowerShell Module

**Cs.Type.CoreMarshal.psm1**

```powershell
# 1. Load the Cs.Type.dll from the root of this module
Add-Type -Path (Join-Path $PSScriptRoot "Cs.Type.dll")

# 2. Get the TypeAccelerator type for static access
$TypeAccelerator = [PSObject].Assembly.GetType(
    "System.Management.Automation.TypeAccelerators"
)

# 3. Register the Type Accelerator using static method "Add"

# _________________________________
# When CoreMarshal IS a GENERIC class
# ╭─────────╮
# │ Generic │
# ╰─────────╯
# ---------------------------------
$TypeAccelerator::Add("CoreMarshal", [Cs.Type.CoreMarshal``1])

# ___________________________________________________
# When CoreMarshal IS NOT a GENERIC class, or, Concrete
# ╭──────────╮
# │ Concrete │
# ╰──────────╯
# ----------------------------------------------------
$TypeAccelerator::Add("CoreMarshal", [Cs.Type.CoreMarshal])
```

## Usage
**Cs.Type.ps1**

```powershell
using module Cs.Type.CoreMarshal

# ╭────────────────────────────────╮
# │ Possible Constructor Arguments │
# ╰────────────────────────────────╯
[string[]] $Strings = @('a', 'b', 'c')
[int[]] $Numbers = @(1, 2, 3)
[string] $String = 'a'
[int] $Number = 1
[FileSystemInfo[]] $FSInfoArray = Get-ChildItem -Path $PSScriptRoot -Exclude 'bin'

# ╭─────────╮
# │ Generic │
# ╰─────────╯
[CoreMarshal[int]] $CoreMarshal = [CoreMarshal[int]]::new()

# ╭──────────╮
# │ Concrete │
# ╰──────────╯
[CoreMarshal] $CoreMarshal = [CoreMarshal]::new()
```
