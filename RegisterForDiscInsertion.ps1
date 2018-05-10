#Requires -version 2.0

# discInserted is my name for this event. Within means poll every N seconds for these events to have occurred. Setting it too low (e.g. .001) can be resource-intensive
register-wmiEvent -query "SELECT * FROM __InstanceModificationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_LogicalDisk' and TargetInstance.DriveType = 5" -sourceIdentifier "discInserted" -timeout 500

# Original example: Register-WmiEvent -Class win32_VolumeChangeEvent -SourceIdentifier volumeChange
write-host (get-date -format s) "     Beginning script..."

# todo: do this only once per system: 
#New-EventLog -Source AutoDVDRip -LogName Application

#do this every time
Write-EventLog -LogName "Application" -Source "AutoDVDRip" -EventId 1 -EntryType Information -Message "Registering for disc insertion."

do{
    Try
    {
        $newEvent = Wait-Event -SourceIdentifier discInserted
        
        # removes the current event from the queue
        Remove-Event -SourceIdentifier discInserted
        
        $eventType = $newEvent.SourceEventArgs
        $eventArgs = $newEvent.SourceEventArgs.NewEvent.Properties["TargetInstance"].Value.Properties
        $volumeName = $eventArgs["VolumeName"].Value    

        #$message = (get-date -format s) "     Event detected. Drive = " $eventArgs["DeviceID"].Value @{$true=" inserted"; $false=" ejected"}[$eventArgs["Access"].Value -eq 1]
        write-host (get-date -format s) "     Event detected. Drive = " $eventArgs["DeviceID"].Value @{$true=" inserted"; $false=" ejected"}[$eventArgs["Access"].Value -eq 1]
       # Write-EventLog -LogName "Application" -Source "AutoDVDRip" -EventId 3 -EntryType Information -Message $message
        
        #foreach($property in  $newEvent.SourceEventArgs.NewEvent.Properties["TargetInstance"].Value.Properties) {
        #	write-host (get-date -format s) "      Property Name = " $property.Name " Value = " $property.Value
        #}	
        
        if($eventArgs["Access"].Value -eq 1)
        {        
            write-host (get-date -format s) "      Disc inserted. Starting task for drive " $eventArgs["DeviceID"].Value
            #start-sleep -seconds 3
            $driveLetter = $eventArgs["DeviceID"].Value
            start-process "cmd.exe" -ArgumentList "/c start /min s:\dev\scripts\AutoDVDRip\MakeMKV_auto.bat $driveLetter"
            write-host (get-date -format s) "      Process started for drive " $eventArgs["DeviceID"].Value
        }
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-EventLog -LogName "Application" -Source "AutoDVDRip" -EventId 101 -EntryType Error -Message $ErrorMessage
        Break
    }
} while (1-eq1) #Loop until next event

Write-EventLog -LogName "Application" -Source "AutoDVDRip" -EventId 2 -EntryType Information -Message "Unregistering event."
Unregister-Event -SourceIdentifier discInserted