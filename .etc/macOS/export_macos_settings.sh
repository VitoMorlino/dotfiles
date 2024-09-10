#!/bin/sh

###
# this is a helper file for macOS, to be run instead of having to type these commands in a terminal
#
# it will read the current settings for default open-with programs and for hotkeys/keymaps
# and export them into files in the same directory as this file
#
# to import these settings (for example, when setting up a new machine or restoring a backup of settings),
# use the same commands, but replace "export" with "import"
###

echo "exporting hotkeys and default programs"

defaults export com.apple.symbolichotkeys symbolichotkeys.plist
defaults export com.apple.LaunchServices/com.apple.launchservices.secure.plist launchservices.secure.plist

echo "finished exporting hotkeys and default programs"
