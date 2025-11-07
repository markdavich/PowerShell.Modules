Dim fso, shell, path, defaultPath
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("Wscript.Shell")

If fso.FolderExists("C:\Code\Repos\MED") Then
    shell.Run "C:\Code\Repos\MED"
Else
    ' fallback location if missing
    shell.Run "C:\"
End If
