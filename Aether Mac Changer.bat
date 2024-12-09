@echo off
title discord.gg/Aether                                                     \\ AETHER MAC SPOOFER //
setlocal EnableDelayedExpansion

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo(
    echo   [33m# Administrator privileges are required.[0m
    echo(
    echo   [35m[i] Restarting as administrator...[0m
    powershell Start-Process -Verb RunAs -FilePath "%~f0"
    exit /b
)

:: Variables
set "reg_path=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"

:SELECTION_MENU
:: Enumerate available NICs
set "count=0"
cls
echo(
echo   [35m[i] Input NIC # to Modify[0m
echo(
for /f "skip=2 tokens=2 delims=," %%A in ('wmic nic get NetConnectionId /format:csv') do (
    for /f "delims=" %%B in ("%%~A") do (
        set /a "count+=1"
        set "nic[!count!]=%%B"
        echo   [36m!count![0m - %%B
    )
)

:: User selection
echo(
echo   [36m99[0m - Revise Networking
echo(
set /p "nic_selection=  [35m# [0m"
if not defined nic_selection (
    cls
    echo(
    echo   [31m[!] No input detected.[0m
    >nul timeout /t 2
    goto :SELECTION_MENU
)
set /a "nic_selection=nic_selection"
if !nic_selection! gtr 0 if !nic_selection! leq !count! (
    set "NetworkAdapter=!nic[!nic_selection!]!"
    goto :ACTION_MENU
)
if !nic_selection! equ 99 (
    cls
    echo(
    echo   [32m# Revising networking configurations...[0m
    >nul 2>&1 (
        ipconfig /release && arp -d * && ipconfig /renew
    )
    goto :SELECTION_MENU
)
cls
echo(
echo   [31m[!] Invalid option.[0m
>nul timeout /t 2
goto :SELECTION_MENU

exit /b

:ACTION_MENU
cls
echo(
echo   [35m[i] Input Action # to Perform[0m
echo(
echo   [36m^> Selected NIC :[0m !NetworkAdapter!
echo(
echo   [36m1[0m - Randomize MAC address
echo   [36m2[0m - Customize MAC address
echo   [36m3[0m - Revert MAC address to original
echo(
echo   [36m0[0m - Menu
echo(
set /p c=  [35m# [0m
if "%c%"=="1" goto :SPOOF_MAC
if "%c%"=="2" goto :CUSTOM_MAC
if "%c%"=="3" goto :REVERT_MAC
if "%c%"=="0" goto :SELECTION_MENU
cls
echo(
echo   [31m[!] Invalid option.[0m
>nul timeout /t 2
goto :ACTION_MENU

:SPOOF_MAC
cls
call :MAC_RECEIVE
call :GEN_MAC
call :NIC_INDEX
echo   [36m^> Selected NIC :[0m !NetworkAdapter!
echo   [36m^> Previous MAC :[0m !MAC!
echo   [36m^> Modified MAC :[0m !mac_address_print!
>nul 2>&1 (
    netsh interface set interface "!NetworkAdapter!" admin=disable
    reg add "!reg_path!\!Index!" /v "NetworkAddress" /t REG_SZ /d "!mac_address!" /f
    netsh interface set interface "!NetworkAdapter!" admin=enable
)
echo(
echo   [35m[i] MAC address successfully spoofed.[0m
echo(
echo   [35m# Press any key to continue...[0m
>nul pause
goto :ACTION_MENU

:REVERT_MAC
cls
call :MAC_RECEIVE
call :NIC_INDEX
echo   [36m^> Selected NIC :[0m !NetworkAdapter!
echo   [36m^> Modified MAC :[0m !MAC!
>nul 2>&1 (
    netsh interface set interface "!NetworkAdapter!" admin=disable
    reg delete "!reg_path!\!Index!" /v "NetworkAddress" /f
    netsh interface set interface "!NetworkAdapter!" admin=enable
)
call :MAC_RECEIVE
echo   [36m^> Reverted MAC :[0m !MAC!
echo(
echo   [35m[i] MAC address reverted.[0m
echo(
echo   [35m# Press any key to continue...[0m
>nul pause
goto :ACTION_MENU

:MAC_RECEIVE
call :NIC_INDEX
for /f "tokens=2 delims==" %%A in ('wmic nic where "Index='!Index!'" get MacAddress /format:value ^| find "MACAddress"') do (
    set "MAC=%%A"
)
exit /b

:GEN_MAC
set hex_chars=0123456789ABCDEF
set mac_address=
for /l %%i in (1,1,12) do (
    set /a rnd=!random! %% 16
    set "mac_address=!mac_address!!hex_chars:~!rnd!,1!"
)
set mac_address_print=!mac_address:~0,2!:!mac_address:~2,2!:!mac_address:~4,2!:!mac_address:~6,2!:!mac_address:~8,2!:!mac_address:~10,2!
exit /b
