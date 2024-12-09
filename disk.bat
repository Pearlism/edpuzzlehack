@echo off
title  discord.gg/Aether                                                    \\ AETHER DISK SPOOFER //

:: Check for administrative privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrative privileges.
    echo Right-click and select "Run as Administrator."
    pause
    exit /b
)

:: Specify the drive letter
set "drive=C:"

:: Generate random serial number (4 hex digits + 4 hex digits)
set "rand1=%random%"
set "rand2=%random%"
set /a "rand1=rand1 %% 65536"
set /a "rand2=rand2 %% 65536"
set "new_serial=%rand1:~-4%-%rand2:~-4%"

:: URL to download VolumeID.exe
set "volumeid_url=https://download.sysinternals.com/files/VolumeId.zip"

:: Temporary paths
set "download_folder=%temp%\VolumeID"
set "downloaded_file=%download_folder%\VolumeId.zip"
set "extracted_path=%download_folder%\VolumeID.exe"

:: Create a temporary folder
if not exist "%download_folder%" (
    mkdir "%download_folder%"
)

:: Download VolumeID
color 0A
echo Connecting to server...
curl -o "%downloaded_file%" "%volumeid_url%" --silent --show-error
if %errorlevel% neq 0 (
    color 0C
    echo Failed to Connect. Check your internet connection.
    pause
    exit /b
)

:: Extract VolumeID.exe (requires PowerShell for built-in unzipping)
color 0A
echo Connecting to disk...
powershell -Command "Expand-Archive -Path '%downloaded_file%' -DestinationPath '%download_folder%' -Force"
if not exist "%extracted_path%" (
    color 0C
    echo Failed to Connect. Ensure the Disk is not corrupted.
    pause
    exit /b
)

:: Change the serial number
color 0E
echo Changing the serial number of %drive% to %new_serial%...
"%extracted_path%" %drive% %new_serial%

:: Check for success
if %errorlevel% equ 0 (
    color 0A
    echo Serial number changed successfully to %new_serial%!
) else (
    color 0C
    echo Failed to change the serial number. Ensure the drive is not in use.
)

:: Cleanup (optional)
color 0E
echo Cleaning up...
rd /s /q "%download_folder%"

pause
exit /b
