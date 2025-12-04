Dim fso, shell, path, defaultPath
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("Wscript.Shell")

If fso.FolderExists("C:\Code\Repos") Then
    shell.Run "C:\Code\Repos"
Else
    ' fallback location if missing
    shell.Run "C:\"
End If
