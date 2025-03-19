######
### Debloat Windows by uninstalling default apps that I don't want
######

# NOTE: to see a list of all currently installed packages, run the following in powershell:
# Get-AppxPackage | Select Name, PackageFullName | Out-Host

# NOTE: add package names to this list to be uninstalled
$appsToUninstall = 
	"Microsoft.OneDriveSync",
	"Microsoft.YourPhone",
	"Microsoft.WindowsCamera",
	"Microsoft.BingSearch",
	"Microsoft.MicrosoftSolitaireCollection",
	"Clipchamp.Clipchamp",
	"Microsoft.ZuneMusic",
	"Microsoft.BingNews",
	"Microsoft.Todos",
	"Microsoft.WindowsFeedbackHub",
	"Microsoft.StickyNotes",
	"MSTeams",
	"Microsoft.MicrosoftEdge.Stable"

$failedUninstalls = @()
Write-Host "Uninstalling apps I don't want..." -ForegroundColor cyan
foreach ($app in $appsToUninstall) {
	# Get the package, if it exists
        $package = Get-AppxPackage | Where-Object { $_.Name -eq $app -or $_.PackageFullName -eq $app }
		
        if ($package) {
		try {
		        $package | Remove-AppxPackage -ErrorAction Stop
		} catch {
			Write-Host "Error while trying to uninstall $($line): $_" -ForegroundColor magenta
			$failedUninstalls += $app
		}
        } else {
		$failedUninstalls += $app
        }
}

# If there were unsuccessful attempts, print a warning
if ($failedUninstalls) {
	Write-Host "WARNING: The following packages were not found and could not be uninstalled:" -ForegroundColor yellow

	# Print each package name that was not found
	foreach ($package in $failedUninstalls) {
		Write-Host "`t$package" -ForegroundColor yellow
	}
}

Write-Host "Finished uninstalling bloat" -ForegroundColor green


######
### Install packages
######

# NOTE: add chocolatey packages to this list to be installed
# find package names at https://community.chocolatey.org/packages
$chocopacks = 
	"git", # core git
	"neovim", # my favorite text editor
	"fzf", # fuzzy finder for searching in the terminal
	"ripgrep", # grep but fancy (nvim telescope uses this to search)
	"golang", # the Go language
	"python", # the Python language (gdscript parser needs this)
	"sqlite", # best database engine
	"mingw", # c-compiler like gcc, built for windows
	"neovide", # desktop application for neovim
	"godot", # open source game engine
	"nmap", # needed for gdscript lsp
	"github-desktop", # desktop application for github
	"discord", # desktop application for discord
	"steam", # desktop application for steam
	"nvidia-app", # nvidia's desktop app for drivers
	"powertoys", # microsoft suite of utilities to customize parts of Windows
	"glazewm", # window manager inspired by i3wm
	"wezterm", # terminal emulator
	"zebar" # customizable taskbar (to use instead of windows taskbar)

Write-Host "`nInstalling packages..." -ForegroundColor cyan
choco install -y $chocopacks # (-y confirms running scripts without requiring user input)
Write-Host "Finished installing packages." -ForegroundColor green

# clear the desktop because some of the above installers add shortcuts to the desktop
if (Test-Path -Path $HOME\Desktop\*) {
	$desktop_deletions = Get-Item -Path $HOME\Desktop\*
	Write-Host "`nClearing the desktop because some packages added shortcuts:"
	foreach ($item in Split-Path -Leaf $desktop_deletions) { Write-Host "`t$item" } 
	Remove-Item $desktop_deletions
}


######
### Symlink files and directories to where they're expected to live
######

# Linked Files (Destination => Source)
$symlinks = @{
	"$HOME\bin"					= ".\bin"
	"$env:LOCALAPPDATA\nvim"			= ".\.config\nvim\.config\nvim"
	"$HOME\.gitconfig"				= ".\.config\git\.gitconfig"
	"$env:APPDATA\discord"				= ".\.config\discord"
	"$env:APPDATA\godot"				= ".\.config\godot"
	"$env:LOCALAPPDATA\microsoft\powertoys"		= ".\.config\powertoys"
	"$HOME\.glzr\zebar"				= ".\.config\zebar"
	"$HOME\.glzr\glazewm"				= ".\.config\glazewm"
	"$HOME\.wezterm.lua"				= ".\.config\wezterm\wezterm.lua"
	"$HOME\.bash_profile"				= ".\.config\bash\.bash_profile"
	"$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"		= ".\.config\windows-terminal\settings.json"
}

# Create Symbolic Links
Write-Host "`nCreating Symbolic Links...`r" -ForegroundColor cyan
foreach ($symlink in $symlinks.GetEnumerator()) {
	# if the path exists, ask to confirm overwrite
	if ($(Test-Path -Path $symlink.Key)) {
		$ShouldOverwrite = $(Write-Host "`tWARNING:" $symlink.Key "already exists. Overwrite? (y/n): " -ForegroundColor yellow -nonewline; Read-Host)
		if (!($ShouldOverwrite -eq 'y')) {
			Write-Host "`t[==] skipping" $symlink.Value
			continue
		}
	}
	
	Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
	New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
	
	Write-Host "`t[++] symlinking" $symlink.Key
}
Write-Host "Symbolic Links Created" -ForegroundColor green


######
### Configure Windows
######

# set windows theme by executing my .theme file
Write-Host "`nSetting windows theme..." -ForegroundColor cyan
$themePath = "$HOME\dotfiles\.etc\windows\tivo_theme.theme"
if (Test-Path -Path $themePath) {
	&$themePath
	# TODO: close the settings window that opens when the theme file is executed
} else {
	Write-Host "couldn't find theme file at $themePath" -ForegroundColor red
}

# look for seekerfox usb drive
$seekerFox = Get-WmiObject -Class Win32_Volume -Filter "Label = 'SeekerFox2'"
$seekerFoxPath = $null
if ($seekerFox) {
	#Select-Object -InputObject $seekerFox -ExpandProperty SerialNumber
	$seekerFoxPath = Select-Object -InputObject $seekerFox -ExpandProperty DriveLetter
} else {
	Write-Host "SeekerFox not found" -ForegroundColor magenta
}

# make a backup of the registry
Write-Host "`nBacking up the registry..." -ForegroundColor cyan
$timestamp = Get-Date -Format "yyyy MM dd HH:mm" | ForEach-Object { $_ -replace ":", "."  -replace " ", "." }
$computerName = $env:computername
$registryBackupFileName = "$computerName.registry_before_setup_$timestamp"
$registryBackupDirName = "registry_backups"
$registryBackupDirPath = ""
$registryBackupFilePath = ""
if (Test-Path -Path "$seekerFoxPath\backups") {
	$registryBackupDirPath = "$seekerFoxPath\backups\$registryBackupDirName"
} else {
	$registryBackupDirPath = "$HOME\$registryBackupDirName"
	Write-Host "Couldn't find seekerfox's backup folder. Creating backup at $registryBackupDirPath." -ForegroundColor yellow
}
$registryBackupFilePath = "$registryBackupDirPath\$registryBackupFileName"
[System.IO.Directory]::CreateDirectory("$registryBackupFilePath")
Write-Host "Exporting HKEY_CLASSES_ROOT..."
reg export "HKCR" "$registryBackupFilePath\hkey_classes_root.reg"
Write-Host "Exporting HKEY_CURRENT_USER..."
reg export "HKCU" "$registryBackupFilePath\hkey_current_user.reg"
Write-Host "Exporting HKEY_LOCAL_MACHINE..."
reg export "HKLM" "$registryBackupFilePath\hkey_local_machine.reg"
Write-Host "Exporting HKEY_USERS..."
reg export "HKU" "$registryBackupFilePath\hkey_users.reg"
Write-Host "Exporting HKEY_CURRENT_CONFIG..."
reg export "HKCC" "$registryBackupFilePath\hkey_current_config.reg"

# add my registry edits by importing all .reg files in the keys folder
Write-Host "`nAdding my registry edits to change Windows settings" -ForegroundColor cyan
$registryKeysDir = "$HOME\dotfiles\.etc\windows\registry_keys\"
foreach ($file in Get-ChildItem -Path $registryKeysDir) {
	Write-Host "Processing file: $($file.FullName)"
	&reg import $($file.FullName)
}

# install fonts
Write-Host "`nInstalling fonts:"
$fontDir = "$HOME\dotfiles\usr\fonts\"
$fontList = Get-ChildItem -Path $fontDir -Include ('*.fon','*.otf','*.ttc','*.ttf') -Recurse
foreach ($font in $fontList) {

	Write-Host "Installing font: " $font.BaseName
	Copy-Item $font "C:\Windows\fonts"
  
	# add the fonts to the registry
	# NOTE: when installing font through windows's gui, it adds them to `$env:LOCALAPPDATA\Microsoft\Windows\Fonts\`
	# and registry entries point there. If this script doesn't install fonts properly, try that.
	Set-ItemProperty -Name $font.BaseName -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Value $font.name
}

# make translucent taskbar run on startup
Write-Host "`nAdding translucent taskbar to run on startup:"
$ttbPortablePath = "$HOME\dotfiles\.config\translucenttb\ttb_portable\translucenttb.exe"
if (Test-Path -Path $ttbPortablePath) {
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "TranslucentTB" /t REG_SZ /f /d "$ttbPortablePath"
	# run ttb now so we don't have to wait for next startup
	&$ttbPortablePath
} else {
	Write-Host "Couldn't find translucent taskbar at [$ttbPortablePath]" -ForegroundColor yellow
}

# make glaze window manager run on startup
Write-Host "`nAdding glaze window manager to run on startup:"
$glazewmPath = "$env:ProgramFiles\glzr.io\glazewm\glazewm.exe"
if (Test-Path -Path $glazewmPath) {
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "GlazeWM" /t REG_SZ /f /d "$glazewmPath"
	# run glazewm now so we don't have to wait for next startup
	&$glazewmPath
} else {
	Write-Host "Couldn't find glaze window manager at [$glazewmPath]" -ForegroundColor yellow
}


Write-Host "Registry edits complete." -ForegroundColor green


######
### Set up environment variables
######

Write-Host "`nSetting up environment variables..." -ForegroundColor cyan
# add my bin folder to Windows's PATH variable
$binPath = "$HOME\bin"
$scope = "User" # scope options: "Process", "User", "Machine"
$regexEscapedPath = [regex]::Escape($binPath)
$pathArray = [System.Environment]::GetEnvironmentVariable('PATH', $scope) -split ';'
$pathArray = $pathArray | Where-Object { $_ -notMatch "^$regexEscapedPath\\?" }
$newPath = ($pathArray + $binPath) -join ';'
[System.Environment]::SetEnvironmentVariable('PATH', $newPath, $scope)

# add HOME as an environment variable
[System.Environment]::SetEnvironmentVariable('HOME', $HOME, $scope)


######
### Set up personal folders in home folder
######

Write-Host "Setting up personal folders in home directory..." -ForegroundColor cyan
$localLifeOSPath = "$HOME\lifeOS"
$remoteLifeOSPath = "$seekerFoxPath\lifeOS"
[System.IO.Directory]::CreateDirectory($localLifeOSPath)
[System.IO.Directory]::CreateDirectory("$HOME\projects")
if (Test-Path -Path $remoteLifeOSPath) {
	&git clone $remoteLifeOSPath $localLifeOSPath
} else {
	Write-Host "Failed to clone lifeOS. Path not found: $remoteLifeOSPath" -ForegroundColor magenta
}


######
### fix some app installations
######

# HACK: There is an issue with installing some newer versions of discord (as of 1.0.9184) from the command line
# where a fatal error will occur on launch.
# A workaround for now is to:
# - delete "~/AppData/Local/Discord/installer.db"
# - copy "~/AppData/Local/Discord/app-1.0.9184/installer.db" to "~/AppData/Local/Discord/"
# The following script will find those files and take care of that.
Write-Host "`nFixing discord's install. Hopefully in future versions, we won't have to do this." -ForegroundColor cyan
$discordFixPath = "$HOME\dotfiles\.etc\windows\hack_fixes\discord_install_fix.ps1"
if (Test-Path -Path $discordFixPath) {
	# run the script
	&$discordFixPath
} else {
	Write-Host "Discord fix failed. Path not found: $discordFixPath" -ForegroundColor red
}

# HACK: The Godot package (on chocolatey, at least) doesn't create a start menu shortcut for some reason?
# So, I figured I could just make one by creating a shortcut to the godot exe in the start menu programs folder
Write-Host "`nAdding start menu shortcut for Godot. Hopefully future versions of the chocolatey package do this automatically" -ForegroundColor cyan
$godotStartFixPath = "$HOME\dotfiles\.etc\windows\hack_fixes\godot_startmenu_fix.ps1"
if (Test-Path -Path $godotStartFixPath) {
	# run the script
	&$godotStartFixPath
} else {
	Write-Host "Godot Start Menu fix failed. Path not found: $godotStartFixPath" -ForegroundColor red
}

# While we're at it, we'll go ahead and add a start menu shortcut for my godot-neovim pipeline
Write-Host "`nAdding start menu shortcut for geovide." -ForegroundColor cyan
$geovideScriptPath = "$HOME\dotfiles\.etc\windows\geovide_add_startmenu.ps1"
if (Test-Path -Path $geovideScriptPath) {
	# run the script
	&$geovideScriptPath
} else {
	Write-Host "Failed to add geovide start menu shortcut. Path not found: $geovideScriptPath" -ForegroundColor red
}


Write-Host "
         *                  *
             __                *
          ,db'    *     *
         ,d8/       *        *    *
         888
         \`db\       *     *
           \`o\`_                    **
      *               *   *    _      *
            *                 / )
         *    (\__/) *       ( (  *
       ,-.,-.,)    (.,-.,-.,-.) ).,-.,-.
      | @|  ={      }= | @|  / / | @|o |
     _j__j__j_)     \`-------/ /__j__j__j_
     ________(               /___________
      |  | @| \              || o|O | @|
      |o |  |,'\       ,   ,\'|  |  |  |  hjw
     vV\|/vV|\`-'\  ,---\   | \Vv\hjwVv\//v
                _) )    \`. \ /
               (__/       ) )
                         (_/" -ForegroundColor magenta

Write-Host "Setup Complete" -ForegroundColor green
Read-Host -Prompt "Press [Enter] to exit"

