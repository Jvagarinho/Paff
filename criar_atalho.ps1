$WshShell = New-Object -comObject WScript.Shell
$Desktop = [Environment]::GetFolderPath("Desktop")
$Shortcut = $WshShell.CreateShortcut("$Desktop\Sticky Notes.lnk")
$Shortcut.TargetPath = "C:\Users\Comerciais\Desktop\Apps\Paff\build\windows\x64\runner\Release\sticky_notes_app.exe"
$Shortcut.WorkingDirectory = "C:\Users\Comerciais\Desktop\Apps\Paff\build\windows\x64\runner\Release"
$Shortcut.IconLocation = "C:\Users\Comerciais\Desktop\Apps\Paff\build\windows\x64\runner\Release\sticky_notes_app.exe"
$Shortcut.Save()
Write-Host "Atalho criado com sucesso na area de trabalho!" -ForegroundColor Green