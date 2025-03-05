### There is problem when discord is installed from the command line, caused by discord's silent installer, resulting in a fatal error on launch
### This code is based on a solution by konfusedungobunga on r/discordapp
### It will delete "~/AppData/Local/Discord/installer.db" and copy "~/AppData/Local/Discord/app-[version]/installer.db" to its place


# Get the Local AppData path dynamically using %LocalAppData% environment variable
$localAppData = [System.Environment]::GetFolderPath('LocalApplicationData')
$discordPath = Join-Path $localAppData "Discord"

# Navigate to the Discord folder
Set-Location -Path $discordPath

# Get the folder that starts with "app-"
$appVersionFolder = Get-ChildItem -Path $discordPath | Where-Object { $_.Name -like 'app-*' } | Select-Object -First 1

# Check if the app version folder was found
if ($appVersionFolder -ne $null) {
        $sourceDbPath = Join-Path $appVersionFolder.FullName "installer.db"
        
        # Check if the installer.db file exists in the app version folder
        if (Test-Path $sourceDbPath) {
                # Copy the installer.db file to the Discord folder, overriting the old one if it exists
                Copy-Item -Path $sourceDbPath -Destination $discordPath -Force
                Write-Host "Copied installer.db from $($appVersionFolder.Name) to $discordPath"
        } else {
                Write-Host "No installer.db file found in $($appVersionFolder.Name)"
        }
} else {
        Write-Host "Discord fix Failed - Couldn't find the app version folder"
        Write-Host "This could be because we tried to run this before the files were ready. Try running this again."
}
