# minutes to look back at:
$minutes = 60*4

# user that is running the updates
$user = "user"

# location of user history config files
$historydir = "c:\users\$user\appdata\local\microsoft\windows\filehistory\configuration"

$files = Get-ChildItem $historydir | Where{$_.LastWriteTime -gt (Get-Date).AddMinutes(- $minutes)}
$count = $files.Count

if($count -gt 0) {
    Write-Host "OK: File History is up to date"
    exit 0;
}
else {
    Write-Host "CRITICAL: No File History updates in more than $minutes minutes"
    exit 2;
}
