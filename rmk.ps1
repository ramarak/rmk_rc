<#
.SYNOPSIS
  rmk - Deletes a file/folder, freeing up space and attempting to destroy the data.

.DESCRIPTION
  For Windows on an SSD:
  1. Attempts to overwrite the data using SDelete (Sysinternals), if available. 
  2. Deletes the file/folder from the file system (frees up space). 
  3. Attempts to force a TRIM operation on the volume (requires administrator privileges). 

  WARNING: On an unencrypted SSD, no software can guarantee the physical
  erasure of an individual file. To ensure that data is truly unrecoverable,
  enable BitLocker on your drive.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)
if (-not (Test-Path $Path)) {
    Write-Error "Error: '$Path' it does not exist."
    exit 1
}
# --- Step 1: Attempt to overwrite using SDelete if it exists ---
$sdelete = Get-Command sdelete.exe -ErrorAction SilentlyContinue
if (-not $sdelete) {
    $candidates = @(
        "$env:USERPROFILE\Downloads\sdelete.exe",
        "$env:USERPROFILE\Desktop\sdelete.exe",
        "C:\Tools\SDelete\sdelete.exe",
        "C:\Program Files\SDelete\sdelete.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { $sdelete = $c; break }
    }
}
if ($sdelete) {
    Write-Host "Overwriting with SDelete..." -ForegroundColor Cyan
    if (Test-Path $Path -PathType Container) {
        & $sdelete -s -p 1 -q -a $Path
    } else {
        & $sdelete -p 1 -q -a $Path
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "SDelete failed, but the standard deletion process will continue."
    }
} else {
    Write-Warning "SDelete not found. Standard deletion will be used."
    Write-Host "Download SDelete from: https://learn.microsoft.com/sysinternals/downloads/sdelete" -ForegroundColor Yellow
}
# --- Step 2: Confirmation and deletion of the file system ---
if (Test-Path $Path -PathType Container) {
    $reply = Read-Host "Delete folder '$Path' and ALL its contents? [y/N]"
    if ($reply -notmatch '^[sSyY]$') { Write-Host "Canceled."; exit 1 }
    Remove-Item -Recurse -Force -Path $Path
} else {
    $reply = Read-Host "Delete '$Path'? [y/N]"
    if ($reply -notmatch '^[sSyY]$') { Write-Host "Canceled."; exit 1 }
    Remove-Item -Force -Path $Path
}
Write-Host "Removed from the file system. Space freed up." -ForegroundColor Green
# --- Step 3: Force TRIM (requires administrator) ---
$volume = Split-Path $Path -Qualifier
if ($volume) {
    try {
        Optimize-Volume -DriveLetter $volume.Replace(':','') -ReTrim -ErrorAction Stop
        Write-Host "Forced TRIM on $volume" -ForegroundColor Green
    } catch {
        Write-Warning "Could not force TRIM (run PowerShell as Administrator)."
    }
}
