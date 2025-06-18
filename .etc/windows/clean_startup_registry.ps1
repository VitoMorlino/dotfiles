###
# for each item in the Run registry list, ask if we should delete the entry
###

$ignore_list = @("PSPath", "PSParentPath", "PSChildName", "PSProvider")
$whitelist_path = "$HOME/dotfiles/.etc/windows/startup_registry_whitelist.txt"
if (Test-Path -Path $whitelist_path) {
        $whitelist = Get-Content -Path $whitelist_path
        $ignore_list += $whitelist
}

$registry_startup_path = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
$startup_apps = Get-ItemProperty -Path $registry_startup_path
$startup_apps = $startup_apps.PSObject.Properties | Where-Object { $_.name -notin $ignore_list }
$entries_to_remove = @()


do {
        $entries_to_remove = @()
        foreach ($app in $startup_apps) {
                Write-Host "Prevent " -nonewline
                Write-Host ($app.name) -nonewline -ForegroundColor yellow
                Write-Host " from running on startup? (y/n/[w]hitelist/[a]bort): " -nonewline
                $should_delete = Read-Host
                switch ($should_delete) {
                        { $_ -eq 'y' } { $entries_to_remove += $app }
                        { $_ -in 'w', 'whitelist' } { 
                                Add-Content -Path "./startup_registry_whitelist.txt" -Value $app.name
                                Write-Host $app.name -nonewline -foregroundcolor yellow
                                Write-Host " added to whitelist file at " -nonewline
                                Write-Host (Resolve-Path -Path $whitelist_path) "`n" -foregroundcolor yellow
                        }
                        { $_ -in 'a', 'abort', 'exit' } { 
                                Write-Host "Aborting... Did not delete anything."
                                exit
                        }
                }
        }

        if ($entries_to_remove.count -eq 0) {
                Write-Host "No on-startup entries to remove."
                break
        }

        Write-Host "`nEntries to remove:" $entries_to_remove.name -Separator "`n`t" -ForegroundColor yellow
        $delete_confirmed = $(Write-Host "Confirm deleting the above list of run-on-startup entries? (y/n): " -nonewline; Read-Host)
} while ($delete_confirmed -ne "y")

foreach ($entry in $entries_to_remove) {
        Remove-ItemProperty -Path $registry_startup_path -Name $entry.name
}

# TODO: fix bug where duplicate entries get added to whitelist when user adds to whitelist,
# but then doesn't confirm the delete list so the loop starts over.
#
# fix by adding to an $entries_to_whitelist variable to use after the loop

