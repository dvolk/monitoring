param([string]$wanted_hours_in = "7 12 17", [string]$wanted_days_in = "011110", $wanted_drives_in = "C: D:")

$wanted_hours = $wanted_hours_in.split(" ")
# daysofweek is a bitarray beginning with sunday
$wanted_days = [Convert]::ToInt32($wanted_days_in, 2)
$monitored_drives = $wanted_drives_in.split(" ")

$ret = 0

$ofs = ", "

try {
	$vss = get-service "vss" -erroraction stop
}
catch {
	write-host "CRITICAL: Couldn't find VSS service?!"
	exit 2
}

$monitored_volumes = New-Object System.Collections.ArrayList

$r = gwmi win32_volume | foreach {
	if($monitored_drives -contains $_.driveletter) {
		$_.deviceid -match ".*({.*})\\"
		$monitored_volumes.add($matches[1])
	}
}

$messages = New-Object System.Collections.ArrayList

$r = $monitored_volumes | foreach {
	$vol = $_
	$name = "ShadowCopyVolume$vol"
	$continue = $true

	try {
		$task = get-scheduledtask -taskname $name -erroraction stop
	}
	catch {
		$messages.add("CRITICAL: Shadow Copy task for NTFS volume $vol doesn't exist")
		$ret = 2
		$continue = $false
	}
	if($continue) {

	$hours = New-Object System.Collections.ArrayList

	$r = $task.triggers | foreach {
		# eg 2017-02-23T07:00:00

		$_.startboundary -match ".*T(.{2}):.*"

		$hour = $matches[1]
		$hours.add([int]$hour)
	}

	$days_ok = $true

	$r = $task.triggers | foreach {
		if(($_.daysofweek -band $wanted_days) -ne $wanted_days) {
			$days_ok = $false
		}
	}

	$hours_ok = @($wanted_hours | where {$hours -notcontains $_}).Count -eq 0

	if($days_ok -and $hours_ok) {
		$messages.add("OK: Shadow Copy task for NTFS volume $vol scheduled at hours $hours")
	}
	else {
		$str = "WARNING: Shadow Copy task for NTFS volume $vol"
		if(-not $days_ok) {
			$str = "$str missing days"
		}
		if(-not $hours_ok) {
			$str = "$str wrong hours (got $hours, expected $wanted_hours)"
		}

		$messages.add($str)

		if($ret -eq 0) {
			$ret = 1
		}
	}
	}
}

if($ret -eq 0) {
	write-host "OK: All Shadow Copy task(s) are correctly set up"
}
if($ret -eq 1) {
	write-host "WARNING: Shadow Copy task(s) not correctly set up"
}
if($ret -eq 2) {
	write-host "CRITICAL: Shadow Copy task(s) disabled"
}

$r = $messages | foreach {
	write-host $_
}

exit $ret