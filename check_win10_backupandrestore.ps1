
*** add to nsclient.ini:

check_win10backupandrestore=cmd /c echo scripts/check_win10backupandrestore.ps1; exit($lastexitcode) | powershell.exe -command -

*** save as scripts/check_win10backupandrestore.ps1

# days to look back at:
$days = 1
# backups expected to occur in the last $days:
$backups = 1

$period = (get-date).AddDays(- $days)

$event = Get-EventLog -LogName Application | ? {$_.EventID -match 4098 -and $_.TimeGenerated -gt $period};

$count = $event.Count

if($count -lt 1) {
    Write-Host "CRITICAL: No successful backup in the last $days days."
    exit 2
}
elseif ($count -lt $backups) {
    Write-Host "WARNING: Found $count successful backups in the last $days days. Expected $backups or more."
    exit 1
}
else {
    Write-Host "OK: Found $count successful backups in the last $days days."
    exit 0
}

*** EOF

Set-ExecutionPolicy Unrestricted