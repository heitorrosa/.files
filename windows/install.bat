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

:: Programs
%choco% install discord
%choco% install thorium
%choco% install obs-studio

git clone https://github.com/heitorrosa/.files
