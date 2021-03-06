﻿using module .\Include.psm1

param([String]$MPMVersion, [String]$PSVersion, [String]$NFVersion)

if ($script:MyInvocation.MyCommand.Path) {Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)}

$ProgressPreferenceBackup = $ProgressPreference


$Name = "RainbowMiner"
try {
    $ProgressPreference = "SilentlyContinue"
    $Request = Invoke-RestMethod -Uri "https://api.github.com/repos/rainbowminer/$Name/releases/latest" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    $Version = ($Request.tag_name -replace '^v')
    $Uri = $Request.assets | Where-Object Name -EQ "$($Name)V$($Version).zip" | Select-Object -ExpandProperty browser_download_url

    if ($Version -ne $MPMVersion) {
        $ProgressPreference = $ProgressPreferenceBackup
        Write-Progress -Activity "Updater" -Status $Name -CurrentOperation "Acquiring Online ($URI)"
        $ProgressPreference = "SilentlyContinue"
        Write-Log -Level Warn "The software ($Name) is out of date; there is an updated version available at $URI. "
    }
}
catch {
    Write-Log -Level Warn "The software ($Name) failed to update. "
}

$Name = "PowerShell"
try {
    $ProgressPreference = "SilentlyContinue"
    $Request = Invoke-RestMethod -Uri "https://api.github.com/repos/powershell/$Name/releases" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    $Request = ($Request | Where-Object tag_name -match "^v\d+\.\d+\.\d+$" | Sort-Object -Descending published_at | Select-Object -First 1)
    $Version = ($Request.tag_name -replace '^v')
    $URI = $Request.assets | Where-Object Name -EQ "$($Name)-$($Version)-win-x64.msi" | Select-Object -ExpandProperty browser_download_url

    if ($Version -ne $PSVersion) {
        $ProgressPreference = $ProgressPreferenceBackup
        Write-Progress -Activity "Updater" -Status $Name -CurrentOperation "Acquiring Online ($URI)"
        $ProgressPreference = "SilentlyContinue"
        Expand-WebRequest $URI -ErrorAction Stop
    }
}
catch {
    Write-Log -Level Warn "The software ($Name) failed to update. "
}

$ProgressPreference = $ProgressPreferenceBackup

Write-Progress -Activity "Updater" -Completed