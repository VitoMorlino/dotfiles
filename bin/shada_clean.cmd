@echo off

set shada_path=%LOCALAPPDATA%\nvim-data\shada\
set prev_location=%cd%
cd %shada_path%

echo Removing empty files from [%shada_path%]:

set num_deletions=0
for /F "delims=" %%i in ('dir /b') do (
    if %%~zi equ 0 (
	set /a num_deletions+=1
	echo 	- [%%i]
	del %%i
    )
)

if %num_deletions% equ 0 (
    echo No empty files found
) else (
    echo Removed %num_deletions% files
)

cd %prev_location%
