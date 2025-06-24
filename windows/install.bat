@echo off
title heitorrosa/.files

:: Execute the script as administrator (Not needeed, UAC already disabled)
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

powershell Set-ExecutionPolicy Unrestricted

:: Chocolatey Installation
set "choco=C:\ProgramData\chocolatey\choco.exe"
powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
%choco% feature enable -n=allowGlobalConfirmation
%choco% feature enable -n useFipsCompliantChecksums
%choco% upgrade all

:: Chocolatey Dependancies
%choco% install chocolatey-core.extension

:: Dependancies and Drivers
%choco% install nvidia-display-driver --params "/MSVCRT"

%choco% install directx
%choco% install vcredist-all
%choco% install dotnet-all

%choco% install 7zip
%choco% install git

:: Terminal Emulator
%choco% install powershell-core --install-arguments='"DISABLE_TELEMETRY=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1"

:: Everything
%choco% install everything --params "/run-on-system-startup /client-service"

:: Ricing Tools
%choco% install windhawk
%choco% install altsnap --ignore-checksums
%choco% install powertoys
%choco% install everythingpowertoys --ignore-checksums
%choco% install everythingcmdpal --ignore-checksums
%choco% install glazewm

:: Remote Access Tool (Parsec)
%choco% install parsec --ignore-checksums

:: VPN
%choco% install tailscale

:: Programs
%choco% install discord
%choco% install thorium
%choco% install obs-studio

git clone https://github.com/heitorrosa/.files
cd .files

:: Import Git settings
git config --global user.name "heitorrosa"
git config --global user.email "76885858+heitorrosa@users.noreply.github.com"

:: Import 7Zip reg files
reg add "HKCU\SOFTWARE\7-Zip\FM\Columns" /v "RootFolder" /t REG_BINARY /d "0100000000000000010000000400000001000000a0000000" /f

reg add "HKCU\SOFTWARE\7-Zip\Options" /v "CascadeMenu" /t REG_DWORD /d "0" /f
reg add "HKCU\SOFTWARE\7-Zip\Options" /v "ContextMenu" /t REG_DWORD /d "261" /f
reg add "HKCU\SOFTWARE\7-Zip\Options" /v "CascadedMenu" /t REG_DWORD /d "0" /f
reg add "HKCU\SOFTWARE\7-Zip\Options" /v "MenuIcons" /t REG_DWORD /d "1" /f
reg add "HKCU\SOFTWARE\7-Zip\Options" /v "ElimDupExtract" /t REG_DWORD /d "1" /f

:: Restore Windhawk Settings
set "SCRIPT_DIR=%~dp0"
set "BACKUP_ZIP=%SCRIPT_DIR%windows\Windhawk\windhawk-backup.zip"
set "WINDHAWK_ROOT=C:\ProgramData\Windhawk"
set "EXTRACT_FOLDER=%TEMP%\WindhawkRestore"

if not exist "%BACKUP_ZIP%" (
    echo Error: Backup file not found at:
    echo   %BACKUP_ZIP%
    pause
    exit /b 1
)

if exist "%EXTRACT_FOLDER%" rmdir /s /q "%EXTRACT_FOLDER%"
mkdir "%EXTRACT_FOLDER%" >nul 2>&1

powershell -command "Expand-Archive -LiteralPath '%BACKUP_ZIP%' -DestinationPath '%EXTRACT_FOLDER%' -Force"


if exist "%EXTRACT_FOLDER%\ModsSource\" (
    if not exist "%WINDHAWK_ROOT%\" mkdir "%WINDHAWK_ROOT%"
    xcopy /e /i /y "%EXTRACT_FOLDER%\ModsSource" "%WINDHAWK_ROOT%\ModsSource\" >nul
)

if exist "%EXTRACT_FOLDER%\Engine\Mods\" (
    if not exist "%WINDHAWK_ROOT%\Engine\" mkdir "%WINDHAWK_ROOT%\Engine"
    xcopy /e /i /y "%EXTRACT_FOLDER%\Engine\Mods" "%WINDHAWK_ROOT%\Engine\Mods\" >nul
)

if exist "%EXTRACT_FOLDER%\Windhawk.reg" (
    reg import "%EXTRACT_FOLDER%\Windhawk.reg" >nul
)

rmdir /s /q "%EXTRACT_FOLDER%"

echo Restore completed successfully!
echo Mods and settings restored from:
echo   %BACKUP_ZIP%


:: Restore GlazeWM Settings

:: Move PowerToys Settings to the Backup Folder

:: Restore MSI Afterburner Settings