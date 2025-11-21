# Run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run as Administrator!"
    exit
}

$hostsPath = "C:\Windows\System32\drivers\etc\hosts"

# Backup hosts file
Copy-Item $hostsPath "$hostsPath.backup" -Force

# Common country TLDs
$tlds = @(
    "com", "no", "co.uk", "de", "fr", "es", "it", "nl", "se", "dk", "fi",
    "ca", "au", "nz", "jp", "kr", "in", "br", "mx", "ar", "cl", "co",
    "pl", "ru", "tr", "ae", "sa", "eg", "za", "ng", "ke", "gh", "be",
    "at", "ch", "pt", "gr", "cz", "ro", "hu", "ie", "il", "sg", "my",
    "th", "vn", "ph", "id", "pk", "bd", "lk", "np", "af", "iq", "ir"
)

# Build comprehensive block list
$blockedDomains = @(
    "youtube.com",
    "www.youtube.com",
    "m.youtube.com",
    "music.youtube.com",
    "gaming.youtube.com",
    "tv.youtube.com",
    "studio.youtube.com"
)

# Add country-specific domains
foreach ($tld in $tlds) {
    $blockedDomains += "youtube.$tld"
    $blockedDomains += "www.youtube.$tld"
    $blockedDomains += "m.youtube.$tld"
}

# Read current hosts file
$hostsContent = Get-Content $hostsPath

# Add blocked domains
$addedCount = 0
foreach ($domain in $blockedDomains) {
    $entry = "127.0.0.1 $domain"
    if ($hostsContent -notcontains $entry) {
        Add-Content -Path $hostsPath -Value $entry
        $addedCount++
    }
}

# Flush DNS cache
ipconfig /flushdns | Out-Null

Write-Host "`n$addedCount YouTube domains blocked successfully!" -ForegroundColor Green
Write-Host "YouTube Kids (youtubekids.com) remains accessible." -ForegroundColor Cyan
Write-Host "`nBackup saved to: $hostsPath.backup" -ForegroundColor Yellow