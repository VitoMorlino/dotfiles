######
### install optional packages
######

# NOTE: add chocolatey packages to this list to be optionally installed
# find package names at https://community.chocolatey.org/packages
$optional_chocopacks = 
	"protonpass", # proton password manager
	"ps-remote-play" # playstation remote-play from pc

$confirmed_optional_chocopacks
foreach ($package in $optional_chocopacks) {
	# $ShouldInstallOptional = 'n'
	# should we install [this pack]?
	# if yes, add to $confirmed
}

Write-Host "`nInstalling optional packages..." -ForegroundColor cyan
choco install -y $confirmed_optional_chocopacks # (-y confirms running scripts without requiring user input)
Write-Host "Finished installing optional packages." -ForegroundColor green


######
### interactively clean out on-startup registry
######

Write-Host "`nInteractively cleaning out on-startup registry entries..." -ForegroundColor cyan
$cleanStartupRegistryPath = "$HOME\dotfiles\.etc\windows\clean_startup_registry.ps1"
if (Test-Path -Path $cleanStartupRegistryPath) {
	&$cleanStartupRegistryPath
} else {
	Write-Host "On-Startup cleanup failed. Path not found: $cleanStartupRegistryPath" -ForegroundColor red
}

Write-Host "Optional setup complete! Thanks for playing!" -ForegroundColor green
Read-Host "Press [Enter] to exit"

