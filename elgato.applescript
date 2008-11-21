-- elgato.applescript
-- iTiVo

--  Created by Yoav Yerushalmi on 11/20/08.
--  Copyright 2008 home. All rights reserved.

property turboAppName : ""
property logFile:"/dev/null"

on wait_until_turbo264_idle()
	set startdate to (current date)
	tell application turboAppName
		using terms from application "Turbo.264"
			repeat while isEncoding
				set date_diff to (current date) - startdate
				do shell script "echo " & date_diff & "-1 300 " & lastErrorCode & " >> " & logFile
				delay 10
			end repeat
		end using terms from
	end tell
	return
end wait_until_turbo264_idle

on run argv
	set sourcefile to first item of argv
	set destfile to second item of argv
	set logFile to third item of argv
	try
		tell application "Finder" to set turboAppName to name of application file id "com.elgato.Turbo"
	end try

	do shell script "echo " & (current date) as string & " : Starting ElGato>> " & logFile
	if not turboAppName = "" then
		my wait_until_turbo264_idle()
		tell application turboAppName
			activate
			using terms from application "Turbo.264"
				add file sourcefile with destination destfile replacing true
				encode no error dialogs true
			end using terms from
		end tell
		my wait_until_turbo264_idle()
		do shell script "echo " & date_diff & "100 0 >> " & logFile
		delay 1
		tell application turboAppName to quit
	else
		do shell script "echo " & (current date) as string & " : Couldn't find Turbo.264 >> " & logFile
	end if
end run