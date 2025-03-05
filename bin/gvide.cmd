@echo off

REM open neovide and have it listen to the port that Godot is broadcasting to for external editor
REM then, open godot (note: file name may need to be updated for future godot versions)
REM TODO: find and generate godot name to run (since "godot" points to the console version)
REM NOTE: instead of finding or generating godot name here, i may be able to use a custom name and point that to the exe (but that would require the same finding process)

start neovide -- --listen 127.0.0.1:6004
start Godot_v4.3-stable_win64
