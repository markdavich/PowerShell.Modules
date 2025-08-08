Dim fso, shell, path, defaultPath
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("Wscript.Shell")

If fso.FolderExists("C:\Funk\E\Town") Then
    shell.Run "C:\Funk\E\Town"
Else
    ' fallback location if missing
    shell.Run "C:\"
End If
