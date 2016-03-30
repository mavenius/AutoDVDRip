#Requires -version 2.0

# discInserted is my name for this event. Within means poll every N seconds for these events to have occurred. Setting it too low (e.g. .001) can be resource-intensive
register-wmiEvent -query "SELECT * FROM __InstanceModificationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_LogicalDisk' and TargetInstance.DriveType = 5" -sourceIdentifier "discInserted" -timeout 500

# Original example: Register-WmiEvent -Class win32_VolumeChangeEvent -SourceIdentifier volumeChange
write-host (get-date -format s) "     Beginning script..."
do{
	$newEvent = Wait-Event -SourceIdentifier discInserted
  
  	$eventType = $newEvent.SourceEventArgs
	$eventArgs = $newEvent.SourceEventArgs.NewEvent.Properties["TargetInstance"].Value.Properties
	$volumeName = $eventArgs["VolumeName"].Value    

	write-host (get-date -format s) "     Event detected. Drive = " $eventArgs["DeviceID"].Value @{$true=" inserted"; $false=" ejected"}[$eventArgs["Access"].Value -eq 1]
	#foreach($property in  $newEvent.SourceEventArgs.NewEvent.Properties["TargetInstance"].Value.Properties) {
	#	write-host (get-date -format s) "      Property Name = " $property.Name " Value = " $property.Value
	#}	
	
	if($eventArgs["Access"].Value -eq 1)
	{
		write-host (get-date -format s) "      Disc inserted. Starting task for drive " $eventArgs["DeviceID"].Value
		#start-sleep -seconds 3
		$driveLetter = $eventArgs["DeviceID"].Value
		start-process "s:\dev\scripts\DVD_Rip\MakeMKV auto.bat" $driveLetter
		write-host (get-date -format s) "      Process started for drive " $eventArgs["DeviceID"].Value
	}

	Remove-Event -SourceIdentifier discInserted
} while (1-eq1) #Loop until next event
Unregister-Event -SourceIdentifier discInserted