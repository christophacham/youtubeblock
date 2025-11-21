# Run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run as Administrator!"
    exit
}

$hostsPath = "C:\Windows\System32\drivers\etc\hosts"

# Check if backup exists
$backupPath = "$hostsPath.backup"
if (Test-Path $backupPath) {
    $useBackup = Read-Host "Backup file found. Restore from backup? (Y/N)"
    if ($useBackup -eq "Y" -or $useBackup -eq "y") {
        Copy-Item $backupPath $hostsPath -Force
        ipconfig /flushdns | Out-Null
        Write-Host "`nRestored from backup. YouTube unblocked!" -ForegroundColor Green
        exit
    }
}

# Remove YouTube entries manually
Write-Host "Removing YouTube blocks from hosts file..." -ForegroundColor Yellow

$hostsContent = Get-Content $hostsPath
$newContent = @()
$removedCount = 0

foreach ($line in $hostsContent) {
    # Keep lines that don't contain youtube.* (but keep youtubekids)
    if ($line -match "127\.0\.0\.1\s+.*youtube\." -and $line -notmatch "youtubekids") {
        $removedCount++
        # Skip this line (don't add to newContent)
    } else {
        $newContent += $line
    }
}

# Write cleaned content back
$newContent | Set-Content $hostsPath -Force

# Flush DNS cache
ipconfig /flushdns | Out-Null

Write-Host "`n$removedCount YouTube domains unblocked!" -ForegroundColor Green
Write-Host "YouTube is now accessible again." -ForegroundColor Cyan