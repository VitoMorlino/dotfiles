$GodotStartMenuPath = "$env:appdata\Microsoft\Windows\Start Menu\Programs\Godot"
[System.IO.Directory]::CreateDirectory($GodotStartMenuPath)
$ShortcutTarget= "$env:homepath\dotfiles\bin\gvide.cmd"
$ShortcutFile = "$GodotStartMenuPath\geovide.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $ShortcutTarget
$Shortcut.IconLocation = "$env:homepath\dotfiles\.etc\windows\geovide.ico"
$Shortcut.Save()
