# Cs.Type.ClassName

## Overview
This **PowerShell** module uses a compiled C# class.

### C# Class Library & PowerShell Module Project

```
📁Modules
╰──📁Cs.Type.ClassName
    ├──📁.cs
    │   ├──📦Cs.Type.csproj
    │   ├──📜Cs.Type.ps1 (For testing the module)
    │   ╰──📜ClassName.cs
    ├──🧰Cs.Type.ClassName.psm1
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
- `ClassName` is the `C#` class

### 1. Build `.dll`

Open a terminal at the project root and build using the following:  
| Tool         | Command                         | Notes                                   |
| :----------- | :------------------------------ | :-------------------------------------- |
| **.NET CLI** | `dotnet build .\Cs.Type.csproj` | Uses `Cs.Type.csproj` for configuration |

### 2. Import `.dll` and Create Type Accelerator in PowerShell Module

**Cs.Type.ClassName.psm1**

```powershell
# 1. Load the Cs.Type.dll
Add-Type -Path (Join-Path $PSScriptRoot "Cs.Type.dll")

# 2. Get the TypeAccelerator type for static access
$TypeAccelerator = [PSObject].Assembly.GetType(
    "System.Management.Automation.TypeAccelerators"
)

#3. Register the Type Accelerator using static method "Add"
$TypeAccelerator::Add("ClassName", [Cs.Type.ClassName``1])
```

## Usage
**Cs.Type.ps1**

```powershell
using module Cs.Type.ClassName

[string[]] $s = @('a', 'b', 'c')

[ClassName[int]] $t = [ClassName[int]]::new($s)
```
