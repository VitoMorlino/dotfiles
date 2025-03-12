# what's a dotfiles...?
The settings files for many programs and services are stored in files/folders whose names start with a dot, which is where we get the name "dotfiles"
>The reason for the dot is a remnant of early UNIX file systems. To make it easier to navigate the filesystem, an empty file named `.` was automatically created in each directory as a shortcut to represent that directory. Another empty file named `..` was added as a shortcut to one directory up in the structure.
>
>Since these were just empty helper files, they didn't need to be listed when the user wanted a list of files in a directory. So, a change was made to the `ls` binary that ignored files starting with a `.` when listing the contents of a directory. Problem solved.
>
>What they didn't expect, however, was that this would also hide other files. The change to `ls` was basically "if the file name starts with `.`, don't list it." and they didn't anticipate that actual files might start with a `.` and that those files wouldn't be listed either. The result is what we now know as "hidden files"

## current goal(s)
I'm working on a way to automate setting up a new machine by running a script that will:
- set the operating system's settings to my liking
- download the programs I use and set their settings
- set up my environment and file structure

The macOS script should still work in its current state, but I won't be keeping up with it, so it might break in the future.

I'm currently working on the Windows setup script (for the forseeable future - sorry btw-ers, it makes game development easier). The next step is going to be changing Windows's settings to my liking with the registry

# how to install (Windows)
### _if you're me_:
  * Insert SeekerFox usb drive and run `.\installers\setup_new_win.cmd`

  This will use portable Git from the drive to clone this repo to the home directory on the machine and automatically run the `.\setup_windows`

  >Alternatively (if SeekerFox is unavailable):
  >1. open cmd or powershell and run the following commands
  >2. install git with `winget install --id Git.Git -e --source winget`
  >3. `cd` to where you want this repo to live
  >4. clone this repo with `git clone https://github.com/VitoMorlino/dotfiles.git`
  >5. run the setup script with `.\setup_windows`

  * Note: git might get angy about dubious ownership of the repo when running terminal (or github-desktop) as Admin vs User or on a new machine. Here are a couple solutions I've found:
    - the automatically-provided solution is to mark the directory as "safe" in the .gitconfig
    - another solution is to take ownership of the files by running `takeown /f .\dotfiles /r` in powershell (f = file, r = recursive) (change file path as necessary)

### _if you're not me_:
>[!Warning]
>this is for my specific setup and might not work for you.  
>If you still want to use this repo and tailor it to your needs:
  1. download a zip of this repo with the green "Code" button at the top right of the github page or run one of the following commands in your command line tool:  
    - `wget https://github.com/VitoMorlino/dotfiles/archive/master.zip`  
    - `curl -L -O https://github.com/VitoMorlino/dotfiles/archive/master.zip`  
  2. unzip with `tar -xf .\dotfiles-master.zip` (note: the file name may need to be changed to match the zip file you downloaded
  3. examine the setup script to ensure it's not going to change things you don't want it to change
  4. run the setup script with `.\setup_windows`


---
**_credits_**
- neovim config started out as [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) before making my own customizations.
- ascii art (in various files) made by [Hayley Wakenshaw](https://www.ludd.ltu.se/~vk/pics/ascii/junkyard/techstuff/tutorials/Hayley_Wakenshaw.html), signed `hjw`.
- windows layout inspired by [vimichael](https://github.com/vimichael). I used their window-manager and taskbar configs as a starting point to customize my own.
- emacs config (old) was inspired by [hrs](https://github.com/hrs), [sachac](https://github.com/sachac), and [magnars](https://github.com/magnars) (credit given in-line alongside their contributions to my config)
