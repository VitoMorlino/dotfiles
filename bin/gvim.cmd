@echo off
REM open neovim and have it listen to the port that Godot is broadcasting to
nvim --listen 127.0.0.1:6004
