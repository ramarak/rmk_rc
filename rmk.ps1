<#
.SYNOPSIS
  rmk - Secure Remove for Windows (PowerShell)
  
.DESCRIPTION
  Deletes files/folders by attempting to overwrite them before removal. 
  Windows lacks a native 'shred' utility. This script attempts to use SDelete
  (from Sysinternals/Microsoft) if it is installed; otherwise, it falls back to
  Remove-Item (a standard deletion, which is NOT forensically secure on SSDs). 
  
  For truly secure deletion on an SSD, use BitLocker disk encryption or the
  ATA/NVMe Secure Erase feature provided by the disk manufacturer.
  
.PARAMETER Path
  The path to the file or folder to be deleted.

.PARAMETER Passes
  The number of overwrite passes (applies only if SDelete is available). 
  Default: 1

.NOTES
  Requires PowerShell. Run as follows:
  .\rmk.ps1 "C:\path\to\file"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [int]$Passes = 1
)
if (-not (Test-Path $Path -PathType Leaf) -and -not (Test-Path $Path -PathType Container)) {
    Write-Error "Error: '$Path' It does not exist."
    exit 1
}
# Search for sdelete.exe in the PATH or in common Sysinternals locations
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
    Write-Host "Using SDelete ($sdelete) with $Passes pass(es)..." -ForegroundColor Cyan
    if (Test-Path $Path -PathType Container) {
        # Folder: /s recursive, /p passes, /q quiet, /a includes hidden/system files
        & $sdelete -s -p $Passes -q -a $Path
    } else {
        & $sdelete -p $Passes -q -a $Path
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Error "SDelete failed with code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
} else {
    Write-Warning "SDelete not found. Remove-Item will be used (standard deletion; NOT secure on an SSD)."
    Write-Host "Download SDelete from: https://learn.microsoft.com/sysinternals/downloads/sdelete" -ForegroundColor Yellow
    if (Test-Path $Path -PathType Container) {
        $reply = Read-Host "Confirm folder deletion '$Path' and ALL of its content? [y/N]"
        if ($reply -notmatch '^[sSyY]$') { Write-Host "Canceled."; exit 1 }
        Remove-Item -Recurse -Force -Path $Path
    } else {
        $reply = Read-Host "¿Confirmar eliminación de '$Path'? [s/N]"
        if ($reply -notmatch '^[sSyY]$') { Write-Host "Canceled."; exit 1 }
        Remove-Item -Force -Path $Path
    }
}
Write-Host "Done." -ForegroundColor Green
