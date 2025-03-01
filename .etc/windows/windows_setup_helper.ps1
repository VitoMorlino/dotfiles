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
foreach ($app in $appsToUninstall) {
	# Get the package, if it exists
        $package = Get-AppxPackage | Where-Object { $_.Name -eq $app -or $_.PackageFullName -eq $app }
		
        if ($package) {
		try {
		        $package | Remove-AppxPackage -ErrorAction Stop
		} catch {
			Write-Host "Error while trying to uninstall $($line): $_"
			$failedUninstalls += $app
		}
        } else {
		$failedUninstalls += $app
        }
}

# If there were unsuccessful attempts, print a warning
if ($failedUninstalls) {
	Write-Host "WARNING: The following packages were not found and could not be uninstalled:"

	# Print each package name that was not found
	foreach ($package in $failedUninstalls) {
		Write-Host "`t$package"
	}
}

Write-Host "Finished uninstalling bloat"


######
### Install packages
######

# NOTE: add chocolatey packages to this list to be installed
# find package names at https://community.chocolatey.org/packages
$chocopacks = 
	"neovim",
	"ripgrep",
	"golang",
	"sqlite",
	"mingw",
	"neovide",
	"github-desktop",
	"discord",
	"steam",
	"nvidia-app"

# (-y confirms running scripts without requiring user input)
choco install -y $chocopacks


######
### Symlink files and directories to where they're expected to live
######

# Linked Files (Destination => Source)
$symlinks = @{
	"$env:LOCALAPPDATA\nvim"			= ".\nvim\.config\nvim"
	"$HOME\.gitconfig"				= ".\git\.gitconfig"
	"$HOME\bin"					= ".\bin"
	"$env:APPDATA\discord"				= ".\discord"
}


# Create Symbolic Links
Write-Host "Creating Symbolic Links...`r`n"
foreach ($symlink in $symlinks.GetEnumerator()) {
	# if the path exists, ask to confirm overwrite
	if ($(Test-Path -Path $symlink.Key)) {
		$ShouldOverwrite = Read-Host "`tWARNING:" $symlink.Key "already exists. Overwrite? (y/n)"
		if (!($ShouldOverwrite -eq 'y')) {
			Write-Host "`t[==] skipping" $symlink.Value
			continue
		}
	}
	
	Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
	New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
	
	Write-Host "`t[++] symlinking" $symlink.Key
}
Write-Host "`nSymbolic Links Created"


######
### Configure Windows's settings by changing registry values
######

# look for seekerfox usb drive
$seekerFox = Get-WmiObject -Class Win32_Volume -Filter "Label = 'SeekerFox2'"
$seekerFoxDriveLetter = $null
if ($seekerFox) {
	#Select-Object -InputObject $seekerFox -ExpandProperty SerialNumber
	$seekerFoxDriveLetter = Select-Object -InputObject $seekerFox -ExpandProperty DriveLetter
} else {
	Write-Host "SeekerFox not found"
}

# make a backup of the registry
Write-Host "Backing up the registry..."
$timestamp = Get-Date -Format "yyyy MM dd HH:mm" | ForEach-Object { $_ -replace ":", "."  -replace " ", "." }
$computerName = $env:computername
$registryBackupFileName = "$computerName.registry_before_setup_$timestamp"
$registryBackupDirName = "registry_backups"
$registryBackupDirPath = ""
$registryBackupFilePath = ""
if (Test-Path -Path "$seekerFoxDriveLetter\backups") {
	$registryBackupDirPath = "$seekerFoxDriveLetter\backups\$registryBackupDirName"
} else {
	$registryBackupDirPath = "$HOME\$registryBackupDirName"
	Write-Host "Couldn't find seekerfox's backup folder. Creating backup at $registryBackupDirPath."
}
$registryBackupFilePath = "$registryBackupDirPath\$registryBackupFileName"
[System.IO.Directory]::CreateDirectory("$registryBackupFilePath")
Write-Host "Exporting HKCR..."
reg export "HKCR" "$registryBackupFilePath\hkey_classes_root.reg"
Write-Host "Exporting HKCU..."
reg export "HKCU" "$registryBackupFilePath\hkey_current_user.reg"
Write-Host "Exporting HKLM..."
reg export "HKLM" "$registryBackupFilePath\hkey_local_machine.reg"
Write-Host "Exporting HKU..."
reg export "HKU" "$registryBackupFilePath\hkey_users.reg"
Write-Host "Exporting HKCC..."
reg export "HKCC" "$registryBackupFilePath\hkey_current_config.reg"

# add my registry edits
$registryKeysDir = ".\.etc\windows\registry_keys\"
foreach ($file in Get-ChildItem -Path $registryKeysDir) {
	Write-Host "Processing file: $($file.FullName)"
	&reg import $($file.FullName)
}
Write-Host "Registry edits complete."

######
### Set up environment variables
######

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

# TODO: 
# - check for seekerfox drive
# - git clone seekerfox\lifeOS to ~\lifeOS
# - create folder ~\projects

# HACK: There is an issue with installing some newer versions of discord (as of 1.0.9184) from the command line
# where a fatal error will occur on launch.
# A workaround for now is to:
# - delete "~/AppData/Local/Discord/installer.db"
# - copy "~/AppData/Local/Discord/app-1.0.9184/installer.db" to "~/AppData/Local/Discord/"
# The following script will find those files and take care of that.
Write-Host "Fixing discord's install. Hopefully in future versions, we won't have to do this."
$discordFixPath = ".\.etc\windows\discord_install_fix.ps1"
if (Test-Path -Path $discordFixPath) {
	# run the script
	&$discordFixPath
} else {
	Write-Host "couldn't find $discordFixPath"
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
                         (_/"

Write-Host "Setup Complete"
Read-Host -Prompt "Press [Enter] to exit"


