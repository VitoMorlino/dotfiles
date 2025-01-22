# add chocolatey packages to this list to be installed
$chocopacks = 
	"git",
	"neovim",
	"ripgrep",
	"neovide",
	"golang",
	"sqlite",
	"mingw"

# Install chocolatey packages (-y confirms running scripts without requiring user input)
choco install -y $chocopacks


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


# add my bin folder to Windows's PATH variable
$binPath = "$HOME\bin"
$scope = "User" # scope options: "Process", "User", "Machine"
$regexEscapedPath = [regex]::Escape($binPath)
$pathArray = [System.Environment]::GetEnvironmentVariable('PATH', $scope) -split ';'
$pathArray = $pathArray | Where-Object { $_ -notMatch "^$regexEscapedPath\\?" }
$newPath = ($pathArray + $binPath) -join ';'
[System.Environment]::SetEnvironmentVariable('PATH', $newPath, $scope)


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


