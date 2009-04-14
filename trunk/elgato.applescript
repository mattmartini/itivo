-- elgato.applescript
-- iTiVo

--  Created by Yoav Yerushalmi on 11/20/08.
--  Copyright 2008 home. All rights reserved.

property turboAppName : ""
property logFile : "/dev/null"
property format : "default"
property date_diff : 0

on wait_until_turbo264_idle()
	set startdate to (current date)
	tell application turboAppName
		using terms from application "Turbo.264"
			repeat while isEncoding
				set date_diff to (current date) - startdate
				do shell script "echo " & date_diff & " -1 300 " & lastErrorCode & " >>" & logFile
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
	set format to fourth item of argv
	
	try
		tell application "Finder" to set turboAppName to name of application file id "com.elgato.Turbo"
	end try
	do shell script "echo " & (current date) & " : Starting ElGato >" & logFile
	if not turboAppName = "" then
	       tell application turboAppName to activate
	       delay 5
		my wait_until_turbo264_idle()
		tell application turboAppName
			using terms from application "Turbo.264"
				ignoring case
					if (format = "ipodH") then
						add file sourcefile with destination destfile exporting as iPod High with replacing
					else if (format = "ipodS" or format = "ipod") then
						add file sourcefile with destination destfile exporting as iPod High with replacing
					else if (format = "psp") then
						add file sourcefile with destination destfile exporting as Sony PSP with replacing
					else if (format = "appleTV") then
						add file sourcefile with destination destfile exporting as AppleTV with replacing
					else if (format = "iPhone") then
						add file sourcefile with destination destfile exporting as iPhone with replacing
					else
						add file sourcefile with destination destfile with replacing
					end if
					encode with no error dialogs
				end ignoring
			end using terms from
		end tell
		my wait_until_turbo264_idle()
		do shell script "echo " & date_diff & " 100 0 >>" & logFile
		delay 1
		tell application turboAppName to quit
	else
		do shell script "echo " & (current date) & " : Couldn't find Turbo.264 >>" & logFile
	end if
end run