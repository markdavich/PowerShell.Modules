# PowerShell Module & C# DLL

## C#
Tracker.cs

```cs
namespace cs;

public class Tracker<TItem> {
    ...
```

msbuild => .cs.dll


## PowerShell
...Modules\Tracker\Tracker.psm1

```powershell
class AbstractTracker {
    AbstractTracker([Type]$Type, [array]$ToDos) {
        $dll = ..\.cs.dll

        if (-not ([System.Reflection.Assembly]::LoadFrom($dll))) {
            throw "Failed to load Tracker dll (.cs.dll)"
        }

        <# Navarion!

        Below, "cs.Tracker" is underlined red with the following error:

        Unable to find type [cs.Tracker`1].PowerShell
        Ignoring 'TypeNotFound' parse error on type 'cs.Tracker``1'. Check if the  
        specified type is correct. This can also be due the type not being known at  
        parse time due to types imported by 'using' statements.  
        PSScriptAnalyzer(TypeNotFound)
        
        #>
        $open = [cs.Tracker``1] # Navarion!!! "

        ...
```

## Folder Structure

```
Modules\Tracker\Tracker.psm1
|
+-- Tracker
    |
    +-- .cs.dll
    |
    +-- Tracker.psm1
```