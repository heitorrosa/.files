# Windows Installation

# Automatic Installation

# Manual Installation
<br>

Install Scoop
```powershell
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
```
<br>

Install Chocolatey
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```
