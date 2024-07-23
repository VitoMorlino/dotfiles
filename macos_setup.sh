#!/bin/sh


# add homebrew package names to the below list and they'll be installed if missing

packages_to_install=(
	neovim
	stow
	ripgrep
	tmux
)


# install homebrew

if [ ! -e /usr/local/Homebrew/ ]
then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	echo "Homebrew is already installed"
fi


# install homebrew packages

missing_packages=()

for package_name in ${packages_to_install[*]}; do
	if [ ! -e /usr/local/Cellar/$package_name ]
	then 
		missing_packages+=($package_name)
	else
		echo $package_name "is already installed"
	fi
done

if [ ! ${#missing_packages[@]} -eq 0 ]
then
	brew install ${missing_packages[*]}
	echo "installed missing packages: " ${missing_packages[*]}
fi


# prep stow

if [ ! -e $HOME/.stow-global-ignore ]
then
	ORIGINAL=$(realpath ./.stow-global-ignore)
	ln -s $ORIGINAL $HOME/.stow-global-ignore
else
	echo "~/.stow-global-ignore already exists"
fi


# use stow to create symlinks

stow nvim
stow git


# set macOS settings

echo "setting macOS defaults..."

defaults write -g com.apple.swipescrolldirection -bool false

defaults write NSGlobalDomain com.apple.mouse.scaling -float "1.5"	# cursor speed (default 1.0)
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain AppleHighlightColor -string "0.5 0.5 1.0"
defaults write NSGlobalDomain AppleAccentColor -int 5

defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock orientation -string left

defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture type -string "png"

defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# set hotkeys
# note: if hotkeys are changed in system settings, enter this in a terminal in this directory:
# defaults export com.apple.symbolichotkeys .etc/macOS/symbolichotkeys.plist
if [ -e .etc/macOS/symbolichotkeys.plist ]
then
	defaults import com.apple.symbolichotkeys .etc/macOS/symbolichotkeys.plist
else
	echo "couldn't find .etc/macOS/symbolichotkeys.plist"
fi

echo "finished setting macOS defaults"


# install Apple Command Line Tools

xcode-select -p 1>/dev/null;has_xcode=$?

if [ $((has_xcode)) -eq 2 ]	# has_xcode should be "2" if xcode-select was found
then
	echo "installing Apple Command Line Tools... this may take a few minutes"
	xcode-select --install
else
	echo "apple command line tools already installed"
fi


echo "
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

echo "setup complete"
