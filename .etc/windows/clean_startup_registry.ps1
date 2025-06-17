# for each item in the Run registry list, ask if we should keep the entry
# if not, delete the registry entry

$startup_apps = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run

foreach ($app in $startup_apps.PSObject.Properties) {
        $ignore_list = @("PSPath", "PSParentPath", "PSChildName", "PSProvider")
        if ($ignore_list -contains $($app.name)) {
                continue
        }
        Write-Host ("entry name: $($app.name)")

        #TODO: copy read-host logic from windows_setup_script to ask about each entry
        #
        # add each item to-be-deleted to a list and print the list and ask for confirmation
        # before deleting anything (don't delete during the loop)
        #
        # if user says its not right, just start the loop over and ask about everything again
}
