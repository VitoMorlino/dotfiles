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

The macOS script is a bit more fleshed out (as of feb 19 2025) than Windows because I was working mostly from macOS when I started building this automation pipeline, but I don't plan on continuing to update it. It should still work in its current state, but I won't be keeping up with it, so it might break in the future.

I'm currently working on the Windows setup script (for the forseeable future - sorry btw-ers, it makes game development easier). The next step is going to be setting Windows's settings to my liking by setting registry values.

## possible future plans (or "nice to have")
- tbd

## how to install
- if you're me:
  ```
  [install git]
  [clone this repo]
  [run the setup file]
  ```
- if you're not me, warning, this is for my specific setup and might not work for you.
  - if you still want to use this repo:
    ```
    [download zip of this repo]
    [unzip to where you want the repo]
    [examine the setup script to make sure it's not going to change things you don't want it to change]
    [run the setup file]
    [keep your own separate repo like this]
    ```
