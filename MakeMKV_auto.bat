rem take in param for drive number (0 or 1) (%1)
rem this needs RegisterForDeviceInsertion.ps1 to run at startup to kick this off on disc insertion

set driveLetter=%1

echo Drive letter: %driveLetter%

rem todo: Maybe switch this around so drive letter is input, and disc number is out
IF %driveLetter% EQU D: (
	set driveNumber=0
) ELSE (
	set driveNumber=1
)

SET volumeCommand=wmic logicaldisk where Caption^^="%driveLetter%" get volumename
FOR /F "tokens=* skip=1 USEBACKQ" %%G IN (`%volumeCommand%`) DO (
SET volumeName=%%G
GOTO break
)
:break


SETLOCAL ENABLEDELAYEDEXPANSION
rem SET /p volumeName=- volumeName ? 
ECHO "%volumeName%"
CALL :TRIM volumeName
ECHO "%volumeName%"
SETLOCAL DISABLEDELAYEDEXPANSION

set ripDirectory=s:\VideoToEncode\%volumeName%

ECHO Making directory: "%ripDirectory%"
mkdir "%ripDirectory%"

mosquitto_pub -h 192.168.1.70 -p 1883 -t "MakeMKV/%driveNumber%" -m "Ripping %volumeName%"
"c:\Program Files (x86)\MakeMKV\makemkvcon64.exe" mkv -r disc:%driveNumber% all "%ripDirectory%"
mosquitto_pub -h 192.168.1.70 -p 1883 -t "MakeMKV/%driveNumber%" -m "Rip of %volumeName% Complete"

rem todo: this doesn't enqueue, only starts new: C:\Users\marka\AppData\Local\Temp\RarSFX1>C:\Users\marka\AppData\Local\Temp\RarSFX1\vidcodercli.exe encode -s s:\VideoToEncode\Push\Push.mkv -d R:\MarkStorage\Video\Movies\Push.mkv -p "My Custom"
rem pause
rem mosquitto_pub -h 192.168.1.70 -p 1883 -t "MakeMKV/%driveNumber%" -m "Conversion Complete"
GOTO :EOF


:TRIM
SetLocal EnableDelayedExpansion
Call :TRIMSUB %%%1%%
EndLocal & set %1=%tempvar%
GOTO :EOF

:TRIMSUB
set tempvar=%*
GOTO :EOF
