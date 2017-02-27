# crappy monitoring scripts

Some nagios/icinga scripts I had to write because nobody else has

## Scripts

### check_win10_backupandrestore.ps1
checks Windows 10 Backup & Restore.
### check_win10_filehistory.ps1
checks Windows 10 File History
### check_shadowcopy.ps1
checks Windows (which?) Shadow Copy scheduling

argument 1: string containing desired hours in 24h format
argument 2: string containing desired days of the week (beginning with Sunday)
argument 3: string containing drive letters to monitor

See first line for example

When you schedule the shadow copies, you *must* schedule them on a weekly basis, or this won't work at all.

## How to add this to nsclient:

Add something like this to nsclient.ini (or whatever.ini):

check_win10backupandrestore=cmd /c echo scripts/check_win10backupandrestore.ps1; exit($lastexitcode) | powershell.exe -command -

You may have to permit powershell scripts:

Open a powershell admin shell and type: Set-ExecutionPolicy Unrestricted


