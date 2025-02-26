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
	"$HOME\AppData\Local\nvim"			= ".\nvim\.config\nvim"
	"$HOME\.gitconfig"				= ".\git\.gitconfig"
	"$HOME\bin"					= ".\bin"
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

# make a backup file of the windows settings portion of the registry
if (Test-Path -Path "$seekerFoxDriveLetter\") {
	$timestamp = Get-Date -Format "yyyy MM dd HH:mm" | ForEach-Object { $_ -replace ":", "."  -replace " ", "." }
	$registryBackupFileName = "registry_before_setup_$timestamp.reg"
	$registryBackupDirName = "registry_backups"
	$registryBackupFilePath = "$seekerFoxDriveLetter\$registryBackupDirName\$registryBackupFileName"

	# create the directory if it doesn't exist
	[System.IO.Directory]::CreateDirectory("$seekerFoxDriveLetter\$registryBackupDirName")

	reg export "HKCU\Software\Microsoft\Windows\CurrentVersion" $registryBackupFilePath
} else {
	# TODO: make the backup folder at $HOME
}

# TODO: add all my registry edits


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

Read-Host -Prompt "Press [Enter] to exit"


