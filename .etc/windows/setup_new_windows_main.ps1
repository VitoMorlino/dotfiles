# TODO: extract the symlink process to its own file so i can run it standalone sometimes

######
### Debloat Windows by uninstalling default apps that I don't want
######

# NOTE: to see a list of all currently installed packages, run the following in powershell:
# Get-AppxPackage | Select Name, PackageFullName | Out-Host

# NOTE: add package names to this list to be uninstalled
$apps_to_uninstall = 
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

$failed_uninstalls = @()
Write-Host "Uninstalling apps I don't want..." -ForegroundColor cyan
foreach ($app in $apps_to_uninstall) {
	# Get the package, if it exists
        $package = Get-AppxPackage | Where-Object { $_.Name -eq $app -or $_.PackageFullName -eq $app }
		
        if ($package) {
		try {
		        $package | Remove-AppxPackage -ErrorAction Stop
		} catch {
			Write-Host "Error while trying to uninstall $($line): $_" -ForegroundColor magenta
			$failed_uninstalls += $app
		}
        } else {
		$failed_uninstalls += $app
        }
}

# If there were unsuccessful attempts, print a warning
if ($failed_uninstalls) {
	Write-Host "WARNING: The following packages were not found and could not be uninstalled:" -ForegroundColor yellow

	# Print each package name that was not found
	foreach ($package in $failed_uninstalls) {
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

# set windows theme by executing my packed theme file
# save a new theme from windows "Personalization" and right-click -> save theme for sharing
Write-Host "`nSetting windows theme..." -ForegroundColor cyan
$win_theme_path = "$HOME\dotfiles\.etc\windows\tivo_theme.deskthemepack"
if (Test-Path -Path $win_theme_path) {
	&$win_theme_path
	# TODO: close the settings window that opens when the theme file is executed
} else {
	Write-Host "couldn't find theme file at $win_theme_path" -ForegroundColor red
}

# look for seekerfox usb drive
$seekerfox = Get-WmiObject -Class Win32_Volume -Filter "Label = 'SeekerFox2'"
$seekerfox_path = $null
if ($seekerfox) {
	# NOTE: leaving this commented line here in case we want to use the serial number to identify seekerfox later
	#Select-Object -InputObject $seekerfox -ExpandProperty SerialNumber
	$seekerfox_path = Select-Object -InputObject $seekerfox -ExpandProperty DriveLetter
} else {
	Write-Host "SeekerFox not found" -ForegroundColor magenta
}

# make a backup of the registry
Write-Host "`nBacking up the registry..." -ForegroundColor cyan
$timestamp = Get-Date -Format "yyyy MM dd HH:mm" | ForEach-Object { $_ -replace ":", "."  -replace " ", "." }
$computer_name = $env:computername
$registry_backup_filename = "$computer_name.registry_before_setup_$timestamp"
$registry_backup_dir_name = "registry_backups"
$registry_backup_dir_path = ""
$registry_backup_file_path = ""
if (Test-Path -Path "$seekerfox_path\backups") {
	$registry_backup_dir_path = "$seekerfox_path\backups\$registry_backup_dir_name"
} else {
	$registry_backup_dir_path = "$HOME\$registry_backup_dir_name"
	Write-Host "Couldn't find seekerfox's backup folder. Creating backup at $registry_backup_dir_path." -ForegroundColor yellow
}
$registry_backup_file_path = "$registry_backup_dir_path\$registry_backup_filename"
[System.IO.Directory]::CreateDirectory("$registry_backup_file_path")
Write-Host "Exporting HKEY_CLASSES_ROOT..."
reg export "HKCR" "$registry_backup_file_path\hkey_classes_root.reg"
Write-Host "Exporting HKEY_CURRENT_USER..."
reg export "HKCU" "$registry_backup_file_path\hkey_current_user.reg"
Write-Host "Exporting HKEY_LOCAL_MACHINE..."
reg export "HKLM" "$registry_backup_file_path\hkey_local_machine.reg"
Write-Host "Exporting HKEY_USERS..."
reg export "HKU" "$registry_backup_file_path\hkey_users.reg"
Write-Host "Exporting HKEY_CURRENT_CONFIG..."
reg export "HKCC" "$registry_backup_file_path\hkey_current_config.reg"

# add my registry edits by importing all .reg files in the registry_keys folder
Write-Host "`nAdding my registry edits to change Windows settings" -ForegroundColor cyan
$registry_keys_dir = "$HOME\dotfiles\.etc\windows\registry_keys\"
foreach ($file in Get-ChildItem -Path $registry_keys_dir) {
	Write-Host "Processing file: $($file.FullName)"
	&reg import $($file.FullName)
}

# install fonts
Write-Host "`nInstalling fonts:"
$font_dir = "$HOME\dotfiles\usr\fonts\"
$font_list = Get-ChildItem -Path $font_dir -Include ('*.fon','*.otf','*.ttc','*.ttf') -Recurse
foreach ($font in $font_list) {

	Write-Host "Installing font: " $font.BaseName
	Copy-Item $font "C:\Windows\fonts"
  
	# add the fonts to the registry
	# NOTE: when installing font through windows's gui, it adds them to `$env:LOCALAPPDATA\Microsoft\Windows\Fonts\`
	# and registry entries point there. If this script doesn't install fonts properly, try that.
	Set-ItemProperty -Name $font.BaseName -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Value $font.name
}

# make translucent taskbar run on startup
Write-Host "`nAdding translucent taskbar to run on startup:"
$ttb_portable_path = "$HOME\dotfiles\.config\translucenttb\ttb_portable\translucenttb.exe"
if (Test-Path -Path $ttb_portable_path) {
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "TranslucentTB" /t REG_SZ /f /d "$ttb_portable_path"
	# run ttb now so we don't have to wait for next startup
	&$ttb_portable_path
} else {
	Write-Host "Couldn't find translucent taskbar at [$ttb_portable_path]" -ForegroundColor yellow
}

# make glaze window manager run on startup
Write-Host "`nAdding glaze window manager to run on startup:"
$glazewm_path = "$env:ProgramFiles\glzr.io\glazewm\glazewm.exe"
if (Test-Path -Path $glazewm_path) {
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "GlazeWM" /t REG_SZ /f /d "$glazewm_path"
	# run glazewm now so we don't have to wait for next startup
	&$glazewm_path
} else {
	Write-Host "Couldn't find glaze window manager at [$glazewm_path]" -ForegroundColor yellow
}


Write-Host "Registry edits complete." -ForegroundColor green


######
### Set up environment variables
######

Write-Host "`nSetting up environment variables..." -ForegroundColor cyan
# add my bin folder to Windows's PATH variable
$home_bin_path = "$HOME\bin"
$scope = "User" # scope options: "Process", "User", "Machine"
$regex_escaped_bin_path = [regex]::Escape($home_bin_path)
$path_array = [System.Environment]::GetEnvironmentVariable('PATH', $scope) -split ';'
$path_array = $pathArray | Where-Object { $_ -notMatch "^$regex_escaped_bin_path\\?" }
$new_path = ($path_array + $home_bin_path) -join ';'
[System.Environment]::SetEnvironmentVariable('PATH', $new_path, $scope)

# add HOME as an environment variable
[System.Environment]::SetEnvironmentVariable('HOME', $HOME, $scope)


######
### Set up personal folders in home folder
######

Write-Host "Setting up personal folders in home directory..." -ForegroundColor cyan
$local_lifeOS_path = "$HOME\lifeOS"
$remote_lifeOS_path = "$seekerfox_path\lifeOS"
[System.IO.Directory]::CreateDirectory($local_lifeOS_path)
[System.IO.Directory]::CreateDirectory("$HOME\projects")
if (Test-Path -Path $remote_lifeOS_path) {
	&git clone $remote_lifeOS_path $local_lifeOS_path
} else {
	Write-Host "Failed to clone lifeOS. Path not found: $remote_lifeOS_path" -ForegroundColor magenta
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
$discord_fix_path = "$HOME\dotfiles\.etc\windows\hack_fixes\discord_install_fix.ps1"
if (Test-Path -Path $discord_fix_path) {
	# run the script
	&$discord_fix_path
} else {
	Write-Host "Discord fix failed. Path not found: $discord_fix_path" -ForegroundColor red
}

# HACK: The Godot package (on chocolatey, at least) doesn't create a start menu shortcut for some reason?
# So, I figured I could just make one by creating a shortcut to the godot exe in the start menu programs folder
Write-Host "`nAdding start menu shortcut for Godot. Hopefully future versions of the chocolatey package do this automatically" -ForegroundColor cyan
$godot_start_fix_path = "$HOME\dotfiles\.etc\windows\hack_fixes\godot_startmenu_fix.ps1"
if (Test-Path -Path $godot_start_fix_path) {
	# run the script
	&$godot_start_fix_path
} else {
	Write-Host "Godot Start Menu fix failed. Path not found: $godot_start_fix_path" -ForegroundColor red
}

# While we're at it, we'll go ahead and add a start menu shortcut for my godot-neovim pipeline
Write-Host "`nAdding start menu shortcut for geovide." -ForegroundColor cyan
$geovide_script_path = "$HOME\dotfiles\.etc\windows\geovide_add_startmenu.ps1"
if (Test-Path -Path $geovide_script_path) {
	# run the script
	&$geovide_script_path
} else {
	Write-Host "Failed to add geovide start menu shortcut. Path not found: $geovide_script_path" -ForegroundColor red
}


Write-Host "
         *                  *
             __                *
          ,db'    *     *
         ,d8/       *        *    *
         888
         ``db\       *     *
           ``o``_                    **
      *               *   *    _      *
            *                 / )
         *    (\__/) *       ( (  *
       ,-.,-.,)    (.,-.,-.,-.) ).,-.,-.
      | @|  ={      }= | @|  / / | @|o |
     _j__j__j_)     ``-------/ /__j__j__j_
     ________(               /___________
      |  | @| \              | o|O | @|
      |o |  |,'\       ,   ,'|  |  |  |
     vV\|/vV|``-'\  ,---\   | \Vv\hjwVv\//v
                _) )    ``. \ /
               (__/       ) )
                         (_/" -ForegroundColor magenta

Write-Host "Setup Complete" -ForegroundColor green

$should_continue = $(Write-Host "Press [Enter] to exit, or type `y` to continue with optional additional setup: " -nonewline; Read-Host)
if ($should_continue -ne 'y') {
	exit
}


######
### optional additional setup
######

$optional_setup_path = "$HOME\dotfiles\.etc\windows\setup_optional.ps1"
if (Test-Path -Path $optional_setup_path) {
	&$optional_setup_path
} else {
	Write-Host "Optional setup failed. Path not found: $optional_setup_path" -ForegroundColor red
}

