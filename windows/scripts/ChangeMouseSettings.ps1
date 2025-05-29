Function Set-MouseSpeed {
    [CmdletBinding()]
    param (
        [ValidateRange(1, 20)]
        [int] $Value
    )

    $winApi = Add-Type -Name user32 -Namespace tq84 -PassThru -MemberDefinition @'
[DllImport("user32.dll")]
public static extern bool SystemParametersInfo(
    uint uiAction,
    uint uiParam,
    uint pvParam,
    uint fWinIni
);
'@

    $SPI_SETMOUSESPEED = 0x0071
    $MouseSpeedRegPath = 'HKCU:\Control Panel\Mouse'
    Write-Verbose "MouseSensitivity before WinAPI call:  $((Get-ItemProperty $MouseSpeedRegPath).MouseSensitivity)"

    $null = $winApi::SystemParametersInfo($SPI_SETMOUSESPEED, 0, $Value, 0)
    Set-ItemProperty $MouseSpeedRegPath -Name MouseSensitivity -Value $Value

    Write-Verbose "MouseSensitivity after WinAPI call:  $((Get-ItemProperty $MouseSpeedRegPath).MouseSensitivity)"
}

Function Set-MouseAcceleration {
    param(
        [ValidateSet("Enable", "Disable")]
        [string]$Mode
    )

    $regPath = 'HKCU:\Control Panel\Mouse'
    
    if ($Mode -eq "Disable") {
        Set-ItemProperty -Path $regPath -Name "MouseSpeed" -Value 0
        Set-ItemProperty -Path $regPath -Name "MouseThreshold1" -Value 0
        Set-ItemProperty -Path $regPath -Name "MouseThreshold2" -Value 0
        Write-Host "Mouse acceleration DISABLED" -ForegroundColor Green
    }
    else {
        Set-ItemProperty -Path $regPath -Name "MouseSpeed" -Value 1
        Set-ItemProperty -Path $regPath -Name "MouseThreshold1" -Value 6
        Set-ItemProperty -Path $regPath -Name "MouseThreshold2" -Value 10
        Write-Host "Mouse acceleration ENABLED" -ForegroundColor Green
    }
}

# Interactive Menu
while ($true) {
    Clear-Host
    Write-Host "`n==== Mouse Configuration Tool ====" -ForegroundColor Cyan
    Write-Host "1. Set Mouse Sensitivity (1-20)"
    Write-Host "2. Disable Mouse Acceleration"
    Write-Host "3. Enable Mouse Acceleration"
    Write-Host "4. Exit`n"
    
    $choice = Read-Host "Please choose an option (1-4)"
    
    switch ($choice) {
        "1" {
            $valid = $false
            while (-not $valid) {
                $speed = Read-Host "Enter mouse sensitivity (1-20)"
                if ($speed -match "^\d+$" -and [int]$speed -ge 1 -and [int]$speed -le 20) {
                    Set-MouseSpeed -Value $speed
                    Write-Host "Mouse sensitivity set to $speed" -ForegroundColor Green
                    $valid = $true
                }
                else {
                    Write-Host "Invalid input! Please enter a number between 1-20" -ForegroundColor Red
                }
            }
            pause
        }
        "2" {
            Set-MouseAcceleration -Mode Disable
            pause
        }
        "3" {
            Set-MouseAcceleration -Mode Enable
            pause
        }
        "4" { exit }
        default {
            Write-Host "Invalid option! Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}
