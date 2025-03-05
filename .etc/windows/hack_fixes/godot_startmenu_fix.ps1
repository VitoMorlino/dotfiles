$GodotStartMenuPath = "$env:appdata\Microsoft\Windows\Start Menu\Programs\Godot"
[System.IO.Directory]::CreateDirectory($GodotStartMenuPath)
$ShortcutTarget= "$env:ProgramData\chocolatey\lib\godot\tools\Godot_v4.3-stable_win64.exe"
$ShortcutFile = "$GodotStartMenuPath\Godot.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $ShortcutTarget
$Shortcut.Save()
