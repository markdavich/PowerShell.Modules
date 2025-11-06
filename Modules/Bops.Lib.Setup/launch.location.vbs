Dim fso, shell, path, defaultPath
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("Wscript.Shell")

If fso.FolderExists("C:\Code\Repos\.bops.lib!") Then
    shell.Run "C:\Code\Repos\.bops.lib!"
Else
    ' fallback location if missing
    shell.Run "C:\"
End If
