-- iTiVo.applescript
-- iTiVo

--  Created by David Benesch on 12/03/06.
--  Updated by Yoav Yerushalmi.
--  Copyright 2006-2008 David Benesch, Yoav Yerushalmi. All rights reserved.
property debug_level : 1
property debug_file : "~/iTiVo.log"
property already_launched : 0
property targetData : missing value
property targetDataQ : missing value
property targetDataS : missing value
property targetDataSList : {}
property IPA : ""
property LaunchCount : 0
property currentProgress : 0
property canAutoConnect : false
property fullFileSize : 0
property installedIdleHandler : 0
property showName : ""
property filePath : ""
property timeoutCount : 0
property cancelDownload : 0
property cancelAllDownloads : 0
property showListObject : missing value
property sortOrder : ""
property sortColumn : ""
property openDetail : 2
property DLHistory : {}
property GrowlAppName : ""
property encodeMode : 0
property UserName : ""
property formats_plist : missing value
property formatsList : {}
property tableImages : {}
property haveOS1050 : false
property queue_len : 0

(* User-controlled properties *)
property MAK : ""
property DL : ""
property makeSubdirs : false
property APMetaData : true
property txtMetaData : false
property tivoMetaData : false
property iTunes : ""
property iTunesSync : ""
property iTunesIcon : ""
property format : ""
property encoderUsed : ""
property encoderVideoOptions : ""
property encoderAudioOptions : ""
property encoderOtherOptions : ""
property postDownloadCmd : ""
property filenameExtension : ".mp4"
property comSkip : 0
property SUFeedURL : "http://itivo.googlecode.com/svn/trunk/www/iTiVo.xml"
property debugLog : false
property downloadFirst : false
property tivoSize : 1
property shouldAutoConnect : true
property useTime : false
property useTimeStartTime : date "Tuesday, February 10, 2009 1:00:00 AM"
property useTimeEndTime : date "Tuesday, February 10, 2009 3:00:00 AM"

property panelWIndow : missing value
property currentPrefsTab : "DownloadingTab"

on awake from nib theObject
	update theObject
	if name of theObject is "queueListTable" then
		set targetDataQ to make new data source at end of data sources with properties {name:"queueListTable"}
		tell targetDataQ
			make new data column at end of data columns with properties {name:"ShowVal", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"EpisodeVal", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"DateVal", sort order:descending, sort type:alphabetical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"LengthVal", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"SizeVal", sort order:descending, sort type:numerical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"IDVal", sort order:descending, sort type:numerical, sort case sensitivity:case sensitive}
		end tell
		set data source of theObject to targetDataQ
	else if name of theObject is "ShowListTable" then
		set targetData to make new data source at end of data sources with properties {name:"ShowListTable"}
		tell targetData
			make new data column at end of data columns with properties {name:"DLVal", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"ShowVal", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"EpisodeVal", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"DateVal", sort order:descending, sort type:alphabetical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"LengthVal", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"SizeVal", sort order:descending, sort type:numerical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"ChannelVal", sort order:descending, sort type:alphabetical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"HDVal", sort order:descending, sort type:alphabetical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"IDVal", sort order:descending, sort type:numerical, sort case sensitivity:case sensitive}
		end tell
		set data source of theObject to targetData
	else if name of theObject is "subscriptionListTable" then
		set targetDataS to make new data source at end of data sources with properties {name:"subscriptionListTable"}
		tell targetDataS
			make new data column at end of data columns with properties {name:"ShowVal", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
			make new data column at end of data columns with properties {name:"LastDLVal", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
		end tell
		set data source of theObject to targetDataS
		set content of targetDataS to targetDataSList
	end if
	
	set tableImages to {empty:load image "empty.png"}
	set tableImages to tableImages & {empty_check:load image "empty-check.png"}
	set tableImages to tableImages & {expired_recording:load image "expired-recording.png"}
	set tableImages to tableImages & {expired_recording_check:load image "expired-recording-check.png"}
	set tableImages to tableImages & {expires_soon_recording:load image "empty.png"}
	set tableImages to tableImages & {expires_soon_recording_check:load image "empty-check.png"}
	set tableImages to tableImages & {save_until_i_delete_recording:load image "save-until-i-delete-recording.png"}
	set tableImages to tableImages & {save_until_i_delete_recording_check:load image "save-until-i-delete-recording-check.png"}
	set tableImages to tableImages & {suggestion_recording:load image "suggestion-recording.png"}
	set tableImages to tableImages & {suggestion_recording_check:load image "suggestion-recording-check.png"}
	set tableImages to tableImages & {copyright:load image "copyright.png"}
	
end awake from nib

on will open theObject
	if name of theObject is "iTiVo" and already_launched = 0 then
		set UserName to do shell script "whoami | tr ' /:' '_..'"
		try
			set shellCmd to "mkdir -p /tmp/iTiVo-" & UserName
			do shell script shellCmd
		end try
		my debug_log("     ================    Starting   ===================")
		getTiVos()
		update
		readSettings()
		set already_launched to 1
		if MAK is not greater than 0 then
			my displayPrefs()
		end if
	end if
end will open

on was miniaturized theObject
	if name of theObject is "iTiVo" then
		my debug_log("Miniaturizing window")
		writeSettings()
		getTiVos()
		readSettings()
	end if
end was miniaturized

on will finish launching theObject
	set haveOS1040 to minOSVers at 1040
	set haveOS1050 to minOSVers at 1050
	if not haveOS1040 then
		display dialog "This Application requires Mac OS X 10.4 or later." buttons {"OK"} default button "OK" attached to window "iTiVo"
		quit
	end if
	performCancelDownload()
	registerSettings()
end will finish launching

on launched theObject
	if LaunchCount > 100 or LaunchCount ≤ 0 then
		display dialog "This program is under active development. Some features may not work. *Do not distribute copyrighted material*" buttons {"OK"} default button "OK" attached to window "iTiVo"
		set LaunchCount to 0
	end if
	set LaunchCount to LaunchCount + 1
	setSettingsInUI()
	if canAutoConnect = true and shouldAutoConnect = true then
		my ConnectTiVo()
	end if
	setDrawers()
end launched

on displayPrefs()
	if panelWIndow is equal to missing value then
		load nib "PrefsPanel"
		set panelWIndow to window "PrefsPanel"
	else
		my writeSettings()
	end if
	my setupPrefsTab(currentPrefsTab)
	display panel panelWIndow attached to window "iTiVo"
end displayPrefs

on panel ended thePanel with result theResult
	if theResult is 1 then
		my writeSettings()
	else
		my readSettings()
	end if
end panel ended

on formatCompatComSkip(formatName)
	repeat with currentFormat in formatsList
		if name of currentFormat is formatName then
			return comSkip of currentFormat
		end if
	end repeat
	my debug_log("Couldn't find comSkip of format " & formatName)
	return false
end formatCompatComSkip

on formatMustDownloadFirst(formatName)
	repeat with currentFormat in formatsList
		if name of currentFormat is formatName then
			return mustDownloadFirst of currentFormat
		end if
	end repeat
	my debug_log("Couldn't find mustDownloadFirst of format " & formatName)
	return false
end formatMustDownloadFirst

on formatCompatItunes(formatName)
	repeat with currentFormat in formatsList
		if name of currentFormat is formatName then
			return iTunes of currentFormat
		end if
	end repeat
	my debug_log("Couldn't find itunes of format " & formatName)
	return false
end formatCompatItunes

on formatDescription(formatName)
	repeat with currentFormat in formatsList
		if name of currentFormat is formatName then
			return formatDescription of currentFormat
		end if
	end repeat
	my debug_log("Couldn't find description of format " & formatName)
	return ""
end formatDescription

on getFormatSettings(formatName)
	repeat with currentFormat in formatsList
		if name of currentFormat is formatName then
			return {encoderUsed of currentFormat, encoderVideoOptions of currentFormat, encoderAudioOptions of currentFormat, encoderOtherOptions of currentFormat, filenameExtension of currentFormat}
		end if
	end repeat
	return {"mencoder", "", "", "", ".mp4"}
end getFormatSettings

on getFormatsNames()
	my debug_log("getFormatsNames")
	set formatsNameList to {} as list
	repeat with currentFormat in formatsList
		set formatsNameList to formatsNameList & {name of currentFormat}
	end repeat
	return formatsNameList
end getFormatsNames

on readFormats()
	set formatsList to {}
	set myLocalPath to path to me
	try
		set myExtraFormats to path to home folder as string
		set myExtraFormats to myExtraFormats & "Library:Application Support:iTiVo:formats:"
		tell application "Finder" to set other_formats to name of every file in folder myExtraFormats
	on error
		set other_formats to {}
	end try
	set prev_delim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ""
	set files_list to {(myLocalPath & "Contents:Resources:formats.plist" as string)}
	my debug_log("Using " & files_list)
	repeat with filename in other_formats
		set files_list to files_list & (myExtraFormats & filename)
	end repeat
	repeat with filename in files_list
		my debug_log("Using format file : " & filename)
		tell application "System Events"
			set formats_plist to contents of property list file filename
			set formatsArray to (value of property list item "formats" of formats_plist)
			try
				repeat with currentFormat in formatsArray
					set newItem to {}
					set newItem to newItem & {name:|name| of currentFormat}
					set newItem to newItem & {encoderUsed:|encoderUsed| of currentFormat}
					set newItem to newItem & {encoderVideoOptions:|encoderVideoOptions| of currentFormat}
					set newItem to newItem & {encoderAudioOptions:|encoderAudioOptions| of currentFormat}
					set newItem to newItem & {encoderOtherOptions:|encoderOtherOptions| of currentFormat}
					set newItem to newItem & {filenameExtension:|filenameExtension| of currentFormat}
					set newItem to newItem & {iTunes:|iTunes| of currentFormat}
					set newItem to newItem & {comSkip:|comSkip| of currentFormat}
					set newItem to newItem & {mustDownloadFirst:|mustDownloadFirst| of currentFormat}
					set newItem to newItem & {formatDescription:|formatDescription| of currentFormat}
					set formatsList to formatsList & {newItem}
				end repeat
			on error
				my debug_log("Couldn't read formats from " & filename)
				display alert "Unable to read formats from " & filename & "."
			end try
		end tell
	end repeat
	set AppleScript's text item delimiters to prev_delim
end readFormats

on write_out_custom_format(outputfile, baseformat, newfilenameExtension, newencoderUsed, newencoderVideoOptions, newencoderAudioOptions, newencoderOtherOptions)
	try
		set shellCmd to "mkdir -p ~/Library/Application' 'Support/iTiVo/formats"
		do shell script shellCmd
	end try
	set myExtraFormats to path to home folder as string
	set myExtraFormats to myExtraFormats & "Library:Application Support:iTiVo:formats:"
	set myfilename to myExtraFormats & outputfile & ".plist"
	my debug_log("Writing to format file : " & myfilename)
	tell application "System Events"
		set parent_dictionary to make new property list item with properties {kind:record}
		set my_plistfile to make new property list file with properties {contents:parent_dictionary, name:myfilename}
		make new property list item at end of property list items of contents of my_plistfile with properties {kind:number, name:"version", value:1}
		set result_list to {|name|:outputfile}
		set result_list to result_list & {|formatDescription|:"Custom Format " & outputfile & " created on " & (current date) as string}
		set result_list to result_list & {|encoderUsed|:newencoderUsed, |encoderVideoOptions|:newencoderVideoOptions}
		set result_list to result_list & {|encoderAudioOptions|:newencoderAudioOptions, |encoderOtherOptions|:newencoderOtherOptions}
		set result_list to result_list & {|filenameExtension|:newfilenameExtension}
		set myitunes to my formatCompatItunes(baseformat)
		set result_list to result_list & {|iTunes|:myitunes}
		set mycomskip to my formatCompatComSkip(baseformat)
		set result_list to result_list & {|comSkip|:mycomskip}
		set mymustdlf to my formatMustDownloadFirst(baseformat)
		set result_list to result_list & {|mustDownloadFirst|:mymustdlf}
		set my_formats to {result_list}
		make new property list item at end of property list items of contents of my_plistfile with properties {kind:list, name:"formats", value:my_formats}
	end tell
end write_out_custom_format

on setupPrefsTab(tabName)
	tell panelWIndow
		if (tabName = "DownloadingTab") then
			set contents of text field "MAK" of view "DownloadingView" of tab view "TopTab" to MAK
			set state of button "shouldAutoConnect" of view "DownloadingView" of tab view "TopTab" to shouldAutoConnect
			set contents of text field "Location" of view "DownloadingView" of tab view "TopTab" to DL
			set state of button "makeSubdirs" of view "DownloadingView" of tab view "TopTab" to makeSubdirs
			set formats to my getFormatsNames()
			delete every menu item of menu of popup button "format" of view "DownloadingView" of tab view "TopTab"
			repeat with formatitem in formats
				make new menu item at the end of menu items of menu of popup button "format" of view "DownloadingView" of tab view "TopTab" with properties {title:formatitem, enabled:true}
			end repeat
			if format is not in formats then
				set format to first item of formats
				set title of popup button "format" of view "DownloadingView" of tab view "TopTab" to format
				set {encoderUsed, encoderVideoOptions, encoderAudioOptions, encoderOtherOptions, filenameExtension} to getFormatSettings(format)
			end if
			set title of popup button "format" of view "DownloadingView" of tab view "TopTab" to format
			set contents of text field "formatDescription" of view "DownloadingView" of tab view "TopTab" to my formatDescription(format)
			if (my formatCompatItunes(format)) then
				set enabled of button "iTunes" of view "DownloadingView" of tab view "TopTab" to true
				set enabled of button "iTunesSync" of view "DownloadingView" of tab view "TopTab" to true
				set enabled of popup button "icon" of view "DownloadingView" of tab view "TopTab" to true
			else
				set enabled of button "iTunes" of view "DownloadingView" of tab view "TopTab" to false
				set enabled of button "iTunesSync" of view "DownloadingView" of tab view "TopTab" to false
				set enabled of popup button "icon" of view "DownloadingView" of tab view "TopTab" to false
			end if
			set state of button "iTunes" of view "DownloadingView" of tab view "TopTab" to iTunes
			if iTunes > 0 then
				set enabled of button "iTunesSync" of view "DownloadingView" of tab view "TopTab" of panelWIndow to true
				set enabled of popup button "icon" of view "DownloadingView" of tab view "TopTab" of panelWIndow to true
			else
				set enabled of button "iTunesSync" of view "DownloadingView" of tab view "TopTab" of panelWIndow to false
				set iTunesSync to false
				set enabled of popup button "icon" of view "DownloadingView" of tab view "TopTab" of panelWIndow to false
			end if
			set state of button "iTunesSync" of view "DownloadingView" of tab view "TopTab" to iTunesSync
			set iTunesIcons to title of every menu item of popup button "icon" of view "DownloadingView" of tab view "TopTab"
			if (iTunesIcon is in iTunesIcons) then
				set title of popup button "icon" of view "DownloadingView" of tab view "TopTab" to iTunesIcon
			else
				set title of popup button "icon" of view "DownloadingView" of tab view "TopTab" to first item of iTunesIcons
			end if
			set state of button "APMetaData" of view "DownloadingView" of tab view "TopTab" to APMetaData
			set state of button "txtMetaData" of view "DownloadingView" of tab view "TopTab" to txtMetaData
			set state of button "tivoMetaData" of view "DownloadingView" of tab view "TopTab" to tivoMetaData
		else if (tabName = "ComSkipTab") then
			if (not my formatCompatComSkip(format)) then
				set comSkip to 0
				set enabled of button "comSkip" of view "comSkipView" of tab view "TopTab" to false
			else
				set enabled of button "comSkip" of view "comSkipView" of tab view "TopTab" to true
			end if
			set state of button "comSkip" of view "comSkipView" of tab view "TopTab" to comSkip
		else if (tabName = "SchedulingTab") then
			set state of button useTime of view "SchedulingView" of tab view "TopTab" to useTime
			set content of control "useTimeStartTime" of view "SchedulingView" of tab view "TopTab" to useTimeStartTime
			set content of control "useTimeEndTime" of view "SchedulingView" of tab view "TopTab" to useTimeEndTime
			if (useTime = true) then
				set enabled of control "useTimeStartTime" of view "SchedulingView" of tab view "TopTab" to true
				set enabled of control "useTimeEndTime" of view "SchedulingView" of tab view "TopTab" to true
			else
				set enabled of control "useTimeStartTime" of view "SchedulingView" of tab view "TopTab" to false
				set enabled of control "useTimeEndTime" of view "SchedulingView" of tab view "TopTab" to false
			end if
		else if (tabName = "AdvancedTab") then
			set contents of text field "postDownloadCmd" of view "AdvancedView" of tab view "TopTab" to postDownloadCmd
			if (SUFeedURL = "http://itivo.googlecode.com/svn/trunk/www/iTiVo-beta.xml") then
				set state of button "betaUpdate" of view "AdvancedView" of tab view "TopTab" to true
			else
				set state of button "betaUpdate" of view "AdvancedView" of tab view "TopTab" to false
			end if
			set state of button "debugLog" of view "AdvancedView" of tab view "TopTab" to debugLog
			set state of button "downloadFirst" of view "AdvancedView" of tab view "TopTab" to downloadFirst
			set contents of text field "filenameExtension" of view "AdvancedView" of tab view "TopTab" to filenameExtension
			set contents of text field "encoderUsed" of view "AdvancedView" of tab view "TopTab" to encoderUsed
			set contents of text field "encoderVideoOptions" of view "AdvancedView" of tab view "TopTab" to encoderVideoOptions
			set contents of text field "encoderAudioOptions" of view "AdvancedView" of tab view "TopTab" to encoderAudioOptions
			set contents of text field "encoderOtherOptions" of view "AdvancedView" of tab view "TopTab" to encoderOtherOptions
		else
			my debug_log("Can't setup PrefsTab for " & tabName)
		end if
	end tell
end setupPrefsTab

on recordPrefsTab()
	tell panelWIndow
		if (currentPrefsTab = "DownloadingTab") then
			set MAK to contents of text field "MAK" of view "DownloadingView" of tab view "TopTab"
			set shouldAutoConnect to state of button "shouldAutoConnect" of view "DownloadingView" of tab view "TopTab" as boolean
			set DL to contents of text field "Location" of view "DownloadingView" of tab view "TopTab"
			set makeSubdirs to state of button "makeSubdirs" of view "DownloadingView" of tab view "TopTab" as boolean
			set format to title of popup button "format" of view "DownloadingView" of tab view "TopTab"
			set iTunes to state of button "iTunes" of view "DownloadingView" of tab view "TopTab"
			set iTunesSync to state of button "iTunesSync" of view "DownloadingView" of tab view "TopTab"
			set iTunesIcon to title of popup button "icon" of view "DownloadingView" of tab view "TopTab"
			set APMetaData to state of button "APMetaData" of view "DownloadingView" of tab view "TopTab" as boolean
			set txtMetaData to state of button "txtMetaData" of view "DownloadingView" of tab view "TopTab" as boolean
			set tivoMetaData to state of button "tivoMetaData" of view "DownloadingView" of tab view "TopTab" as boolean
		else if (currentPrefsTab = "ComSkipTab") then
			set comSkip to state of button "comSkip" of view "comSkipView" of tab view "TopTab"
		else if (currentPrefsTab = "SchedulingTab") then
			set useTime to state of button useTime of view "SchedulingView" of tab view "TopTab" as boolean
			set useTimeStartTime to content of control "useTimeStartTime" of view "SchedulingView" of tab view "TopTab"
			set useTimeEndTime to content of control "useTimeEndTime" of view "SchedulingView" of tab view "TopTab"
		else if (currentPrefsTab = "AdvancedTab") then
			set postDownloadCmd to contents of text field "postDownloadCmd" of view "AdvancedView" of tab view "TopTab"
			set debugLog to state of button "debugLog" of view "AdvancedView" of tab view "TopTab" as boolean
			if (debugLog is true) then
				set debug_level to 3
			end if
			set downloadFirst to state of button "downloadFirst" of view "AdvancedView" of tab view "TopTab" as boolean
			if (state of button "betaUpdate" of view "AdvancedView" of tab view "TopTab" = 1) then
				set SUFeedURL to "http://itivo.googlecode.com/svn/trunk/www/iTiVo-beta.xml"
			else
				set SUFeedURL to "http://itivo.googlecode.com/svn/trunk/www/iTiVo.xml"
			end if
			set filenameExtension to contents of text field "filenameExtension" of view "AdvancedView" of tab view "TopTab"
			set encoderUsed to contents of text field "encoderUsed" of view "AdvancedView" of tab view "TopTab"
			set encoderVideoOptions to contents of text field "encoderVideoOptions" of view "AdvancedView" of tab view "TopTab"
			set encoderAudioOptions to contents of text field "encoderAudioOptions" of view "AdvancedView" of tab view "TopTab"
			set encoderOtherOptions to contents of text field "encoderOtherOptions" of view "AdvancedView" of tab view "TopTab"
		else
			my debug_log("What tab are we on?? ")
			return false
		end if
	end tell
	return true
end recordPrefsTab

on should select tab view item theObject tab view item tabViewItem
	return my recordPrefsTab()
end should select tab view item

on selected tab view item theObject tab view item tabViewItem
	set currentPrefsTab to name of tabViewItem
	my setupPrefsTab(name of tabViewItem)
end selected tab view item


on setDrawers()
	if (openDetail > 2) then set openDetail to 0
	tell window "iTiVo"
		tell drawer "Drawer1" to close drawer
		tell drawer "Drawer2" to close drawer
		if (openDetail = 1) then tell drawer "Drawer1" to open drawer on right edge
		if (openDetail = 2) then tell drawer "Drawer2" to open drawer on right edge
	end tell
end setDrawers

on registerSettings()
	tell user defaults
		make new default entry at end of default entries with properties {name:"IPA", contents:IPA}
		make new default entry at end of default entries with properties {name:"MAK", contents:MAK}
		make new default entry at end of default entries with properties {name:"DL", contents:""}
		make new default entry at end of default entries with properties {name:"LaunchCount", contents:""}
		make new default entry at end of default entries with properties {name:"TiVo", contents:""}
		make new default entry at end of default entries with properties {name:"format", contents:""}
		make new default entry at end of default entries with properties {name:"makeSubdirs", contents:makeSubdirs}
		make new default entry at end of default entries with properties {name:"iTunes", contents:""}
		make new default entry at end of default entries with properties {name:"iTunesSync", contents:""}
		make new default entry at end of default entries with properties {name:"iTunesIcon", contents:""}
		make new default entry at end of default entries with properties {name:"APMetaData", contents:APMetaData}
		make new default entry at end of default entries with properties {name:"txtMetaData", contents:txtMetaData}
		make new default entry at end of default entries with properties {name:"tivoMetaData", contents:tivoMetaData}
		make new default entry at end of default entries with properties {name:"comSkip", contents:comSkip}
		make new default entry at end of default entries with properties {name:"postDownloadCmd", contents:postDownloadCmd}
		make new default entry at end of default entries with properties {name:"debugLog", contents:debugLog}
		make new default entry at end of default entries with properties {name:"downloadFirst", contents:downloadFirst}
		make new default entry at end of default entries with properties {name:"SUFeedURL", contents:SUFeedURL}
		make new default entry at end of default entries with properties {name:"filenameExtension", contents:filenameExtension}
		make new default entry at end of default entries with properties {name:"encoderUsed", contents:encoderUsed}
		make new default entry at end of default entries with properties {name:"encoderVideoOptions", contents:encoderVideoOptions}
		make new default entry at end of default entries with properties {name:"encoderAudioOptions", contents:encoderAudioOptions}
		make new default entry at end of default entries with properties {name:"encoderOtherOptions", contents:encoderOtherOptions}
		make new default entry at end of default entries with properties {name:"openDetail", contents:""}
		make new default entry at end of default entries with properties {name:"DLHistory", contents:""}
		make new default entry at end of default entries with properties {name:"targetDataSList", contents:{}}
		make new default entry at end of default entries with properties {name:"tivoSize", contents:1}
		make new default entry at end of default entries with properties {name:"shouldAutoConnect", contents:shouldAutoConnect}
		make new default entry at end of default entries with properties {name:"useTime", contents:useTime}
		make new default entry at end of default entries with properties {name:"useTimeStartTime", contents:useTimeStartTime}
		make new default entry at end of default entries with properties {name:"useTimeEndTime", contents:useTimeEndTime}
		register
	end tell
end registerSettings

on readSettings()
	my debug_log("read settings")
	tell user defaults
		try
			set IPA to contents of default entry "IPA"
			set MAK to contents of default entry "MAK"
			set DL to contents of default entry "DL" as string
			set LaunchCount to contents of default entry "LaunchCount"
			set TiVo to contents of default entry "TiVo"
		on error
			set TiVo to ""
			set DL to ""
			set IPA to ""
			set MAK to ""
			set LaunchCount to 0
		end try
		try
			set format to contents of default entry "format"
		end try
		try
			set iTunes to contents of default entry "iTunes"
			set iTunesSync to contents of default entry "iTunesSync"
			set iTunesIcon to contents of default entry "iTunesIcon"
			set SUFeedURL to contents of default entry "SUFeedURL"
			set openDetail to contents of default entry "openDetail"
			set DLHistory to contents of default entry "DLHistory"
			set targetDataSList to contents of default entry "targetDataSList"
			set comSkip to contents of default entry "comSkip"
			set postDownloadCmd to contents of default entry "postDownloadCmd"
			set encoderUsed to contents of default entry "encoderUsed"
			set encoderVideoOptions to contents of default entry "encoderVideoOptions"
			set encoderAudioOptions to contents of default entry "encoderAudioOptions"
			set encoderOtherOptions to contents of default entry "encoderOtherOptions"
			set filenameExtension to contents of default entry "filenameExtension"
			set tivoSize to contents of default entry "tivoSize"
			set makeSubdirs to contents of default entry "makeSubdirs"
			set txtMetaData to contents of default entry "txtMetaData"
			set tivoMetaData to contents of default entry "tivoMetaData"
			set shouldAutoConnect to contents of default entry "shouldAutoConnect"
			set useTime to contents of default entry "useTime"
			set useTimeStartTime to contents of default entry "useTimeStartTime"
			set useTimeEndTime to contents of default entry "useTimeEndTime"
			set APMetaData to contents of default entry "APMetaData"
		end try
		try
			set debugLog to contents of default entry "debugLog"
			if (debugLog = true) then
				set debug_level to 3
			end if
			set downloadFirst to contents of default entry "downloadFirst"
		end try
	end tell
	try
		tell application "Finder" to set GrowlAppName to name of application file id "com.Growl.GrowlHelperApp"
	end try
	if GrowlAppName = "GrowlHelperApp.app" then
		try
			if my growlIsRunning() then
				my debug_log("Found Growl")
				my registerGrowl()
			else
				my debug_log("No Growl")
				set GrowlAppName to ""
			end if
		on error
			my debug_log("Failed to register growl")
			set GrowlAppName to ""
		end try
	end if
	my readFormats()
	set formats to my getFormatsNames()
	my debug_log("Format is " & format)
	if format is not in formats then
		set format to first item of formats
		set {encoderUsed, encoderVideoOptions, encoderAudioOptions, encoderOtherOptions, filenameExtension} to getFormatSettings(format)
	else
		if (encoderUsed = "") then
			set {encoderUsed, encoderVideoOptions, encoderAudioOptions, encoderOtherOptions, filenameExtension} to getFormatSettings(format)
		end if
	end if
	my debug_log("using format : " & format)
	set TiVos to title of every menu item of popup button "MyTiVos" of window "iTiVo"
	if TiVo is in TiVos then
		if TiVo ≠ "My TiVos" then
			set title of popup button "MyTiVos" of window "iTiVo" to TiVo
			try
				set theScript to "mDNS -L \"" & TiVo & "\" _tivo-videos._tcp local | colrm 1 42 &
sleep 2
killall mDNS"
				set hostList to paragraphs 1 thru -1 of (do shell script theScript)
				repeat with j in hostList
					try
						if text 17 thru 19 of j is "443" then
							set IPA to first word of j
							set contents of text field "IP" of window "iTiVo" to IPA
							set canAutoConnect to true
						end if
					end try
				end repeat
			on error
				display dialog "Unable to connect to TiVo " & TiVo & ".  It is no longer available on your network."
			end try
		end if
	end if
	if DL = "" then
		set myHomePathP to POSIX path of (path to home folder)
		set DL to myHomePathP & "Desktop/" as string
	end if
end readSettings

on will quit theObject
	getSettingsFromUI()
	writeSettings()
	performCancelDownload()
end will quit

on getSettingsFromUI()
	tell window "iTiVo"
		set IPA to contents of text field "IP"
	end tell
end getSettingsFromUI

on writeSettings()
	my debug_log("write_settings")
	try
		set TiVo to title of current menu item of popup button "MyTiVos" of window "iTiVo"
		set targetDataSList to content of targetDataS
		tell user defaults
			set contents of default entry "IPA" to IPA
			set contents of default entry "MAK" to MAK
			set contents of default entry "DL" to DL
			set contents of default entry "makeSubdirs" to makeSubdirs
			set contents of default entry "LaunchCount" to (LaunchCount as integer)
			set contents of default entry "TiVo" to TiVo as string
			set contents of default entry "format" to format as string
			set contents of default entry "iTunes" to iTunes as string
			set contents of default entry "iTunesSync" to iTunesSync as string
			set contents of default entry "iTunesIcon" to iTunesIcon as string
			set contents of default entry "APMetaData" to APMetaData
			set contents of default entry "txtMetaData" to txtMetaData
			set contents of default entry "tivoMetaData" to tivoMetaData
			set contents of default entry "comSkip" to comSkip
			set contents of default entry "postDownloadCmd" to postDownloadCmd
			set contents of default entry "encoderUsed" to encoderUsed
			set contents of default entry "encoderVideoOptions" to encoderVideoOptions
			set contents of default entry "encoderAudioOptions" to encoderAudioOptions
			set contents of default entry "encoderOtherOptions" to encoderOtherOptions
			set contents of default entry "filenameExtension" to filenameExtension
			set contents of default entry "SUFeedURL" to SUFeedURL
			set contents of default entry "openDetail" to (openDetail as integer)
			set contents of default entry "DLHistory" to DLHistory as list
			set contents of default entry "targetDataSList" to targetDataSList as list
			set contents of default entry "debugLog" to debugLog
			set contents of default entry "downloadFirst" to downloadFirst
			set contents of default entry "tivoSize" to tivoSize
			set contents of default entry "shouldAutoConnect" to shouldAutoConnect
			set contents of default entry "useTime" to useTime
			set contents of default entry "useTimeStartTime" to useTimeStartTime
			set contents of default entry "useTimeEndTime" to useTimeEndTime
		end tell
	on error
		my debug_log("Failed to write out initial settings")
	end try
end writeSettings

on setSettingsInUI()
	tell window "iTiVo"
		set contents of text field "IP" to IPA
	end tell
end setSettingsInUI

on getTiVos()
	set theScript to "mDNS -B _tivo-videos._tcp local | colrm 1 74| grep -v 'Instance Name' |sort | uniq & 
sleep 2
killall mDNS"
	tell window "iTiVo"
		my debug_log(theScript)
		set scriptResult to (do shell script theScript)
		set scriptLineCount to count of paragraphs of scriptResult
		if scriptLineCount > 1 then
			delete every menu item of menu of popup button "MyTiVos"
			make new menu item at the end of menu items of menu of popup button "MyTiVos" with properties {title:"My TiVos", enabled:true}
			set nameList to paragraphs 2 thru -1 of scriptResult
			repeat with i in nameList
				if length of i > 1 then
					make new menu item at the end of menu items of menu of popup button "MyTiVos" with properties {title:i, enabled:true}
				end if
			end repeat
		end if
	end tell
end getTiVos

on clicked theObject
	set theObjectName to name of theObject
	getSettingsFromUI()
	tell window "iTiVo"
		if theObjectName = "prefButton" then
			my displayPrefs()
		else if theObjectName = "PrefsOK" then
			my recordPrefsTab()
			close panel (window of theObject) with result 1
		else if theObjectName = "PrefsCancel" then
			close panel (window of theObject) with result 0
		else if theObjectName = "detailButton" then
			set openDetail to openDetail + 1
			my setDrawers()
		else if theObjectName = "locationButton" then
			set DL to POSIX path of (choose folder)
			tell panelWIndow
				set contents of text field "Location" of view "DownloadingView" of tab view "TopTab" to DL
			end tell
		else if theObjectName = "CancelDownload" then
			set cancelDownload to 1
			set enabled of button "CancelDownload" to false
		else if theObjectName = "imdb" then
			set imdbURL to "http://imdb.com/find?q="
			set component to my encode_text(contents of text field "detailTitle" of drawer "Drawer2", true, true)
			set imdbURL to imdbURL & component & ";s=tt"
			my debug_log("Opening " & imdbURL)
			tell application "System Events" to open location imdbURL
		else if theObjectName = "tvdb" then
			set imdbURL to "http://www.thetvdb.com/index.php?seriesname="
			set component to my encode_text(contents of text field "detailTitle" of drawer "Drawer2", true, true)
			set imdbURL to imdbURL & component & "&fieldlocation=1&language=7&genre=&year=&network=&zap2it_id=&tvcom_id=&imdb_id=&order=translation&searching=Search&tab=advancedsearch"
			my debug_log("Opening " & imdbURL)
			tell application "System Events" to open location imdbURL
		else if theObjectName = "ConnectButton" then
			my ConnectTiVo()
		else if theObjectName = "queueButton" then
			my debug_log("adding to download...")
			set currentProcessSelectionTEMP to (selected data rows of table view "ShowListTable" of scroll view "ShowList" of box "topBox" of split view "splitView1")
			set rowCount to count of currentProcessSelectionTEMP
			set currentCount to 0
			set currentProcessSelectionTEMPAll to (selected data rows of table view "ShowListTable" of scroll view "ShowList" of box "topBox" of split view "splitView1")
			repeat while currentCount < rowCount
				set currentProcessSelection to {}
				set currentCount to currentCount + 1
				set currentProcessSelectionTEMP to item currentCount of currentProcessSelectionTEMPAll
				set end of currentProcessSelection to contents of (data cell "ShowVal" of currentProcessSelectionTEMP)
				set end of currentProcessSelection to contents of (data cell "EpisodeVal" of currentProcessSelectionTEMP)
				set end of currentProcessSelection to contents of (data cell "DateVal" of currentProcessSelectionTEMP)
				set end of currentProcessSelection to contents of (data cell "LengthVal" of currentProcessSelectionTEMP)
				set end of currentProcessSelection to contents of (data cell "SizeVal" of currentProcessSelectionTEMP)
				set end of currentProcessSelection to contents of (data cell "IDVal" of currentProcessSelectionTEMP)
				my addSelectionToQueue(currentProcessSelection)
			end repeat
			set tempStatus to ""
			try
				set tempStatus to text 1 thru 11 of (contents of text field "status" as string)
			end try
			if tempStatus ≠ "Downloading" then
				set enabled of button "decodeQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to true
			end if
		else if theObjectName = "subscribeButton" then
			set currentProcessSelectionTEMP to (selected data rows of table view "ShowListTable" of scroll view "ShowList" of box "topBox" of split view "splitView1")
			set currentProcessSelectionTEMP to item 1 of currentProcessSelectionTEMP
			set showName to contents of data cell "ShowVal" of currentProcessSelectionTEMP
			my debug_log("Attempting to subscribe to " & showName)
			set rowCountS to count of data rows of data source 1 of table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1"
			set currentRow to 0
			set currentProcessSelection to {}
			set processInfoRecord to {}
			set end of currentProcessSelection to showName
			set end of currentProcessSelection to (current date)
			repeat while currentRow < rowCountS
				set currentRow to currentRow + 1
				set currentProcessSelectionS2 to {}
				set currentProcessSelectionS to (data row currentRow of data source 1 of table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1")
				set name2 to contents of (data cell "ShowVal" of currentProcessSelectionS)
				if not name2 = showName then
					set end of currentProcessSelectionS2 to contents of (data cell "ShowVal" of currentProcessSelectionS)
					set end of currentProcessSelectionS2 to contents of (data cell "LastDLVal" of currentProcessSelectionS)
					set end of processInfoRecord to currentProcessSelectionS2
				end if
			end repeat
			set end of processInfoRecord to currentProcessSelection
			set content of targetDataS to processInfoRecord
			update table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1"
		else if theObjectName = "deleteSubscriptionButton" then
			set currentProcessSelectionTEMP to (selected data row of table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1")
			set showName to contents of data cell "ShowVal" of currentProcessSelectionTEMP
			my debug_log("Attempting to remove subscription to " & showName & "  date: " & (current date))
			set selectedRows to selected rows of table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1"
			set processInfoRecordTemp to content of targetDataS
			set processInfoRecord to {}
			set rowCount to 1
			set totalCount to 0
			repeat with currentLine in processInfoRecordTemp
				set totalCount to totalCount + 1
				if rowCount is not in selectedRows then
					set end of processInfoRecord to currentLine
				else
					set totalCount to totalCount - 1
				end if
				set rowCount to rowCount + 1
			end repeat
			set content of targetDataS to processInfoRecord
			if (totalCount = 0) then
				set enabled of button "deleteSubscriptionButton" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
			end if
			update table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1"
		else if theObjectName = "removeButton" then
			set selectedRows to selected rows of table view "queueListTable" of scroll view "queueList" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1"
			set processInfoRecordTemp to content of targetDataQ
			set processInfoRecord to {}
			set rowCount to 1
			set totalCount to 0
			repeat with currentLine in processInfoRecordTemp
				set totalCount to totalCount + 1
				if rowCount is not in selectedRows then
					set end of processInfoRecord to currentLine
				else
					set totalCount to totalCount - 1
				end if
				set rowCount to rowCount + 1
			end repeat
			set content of targetDataQ to processInfoRecord
			set queue_len to count of processInfoRecord
			if queue_len = 0 then
				set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to "Download Queue (empty)"
				my setDockTile("")
			else if queue_len = 1 then
				set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to "Download Queue (1 item)"
				my setDockTile(queue_len as string)
			else
				set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to "Download Queue (" & queue_len & " items)"
				my setDockTile(queue_len as string)
			end if
			if totalCount = 0 then
				set enabled of button "decodeQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
			end if
			set enabled of button "removeButton" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
			update table view "queueListTable" of scroll view "queueList" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1"
		else if theObjectName = "decodeQueue" then
			my debug_log("starting queue download...")
			set enabled of button "DownloadButton" of box "topBox" of split view "splitView1" to false
			set enabled of button "decodeQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
			set enabled of button "connectButton" to false
			set cancelAllDownloads to 0
			set success to 0
			set rowCountQ to count of data rows of data source 1 of table view "queueListTable" of scroll view "queueList" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1"
			repeat until rowCountQ = 0 or cancelAllDownloads = 1
				set currentProcessSelectionQ2 to {}
				set currentProcessSelectionQ to (data row 1 of data source 1 of table view "queueListTable" of scroll view "queueList" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1")
				set end of currentProcessSelectionQ2 to contents of (data cell "ShowVal" of currentProcessSelectionQ)
				set end of currentProcessSelectionQ2 to contents of (data cell "EpisodeVal" of currentProcessSelectionQ)
				set end of currentProcessSelectionQ2 to contents of (data cell "DateVal" of currentProcessSelectionQ)
				set end of currentProcessSelectionQ2 to contents of (data cell "SizeVal" of currentProcessSelectionQ)
				set end of currentProcessSelectionQ2 to contents of (data cell "IDVal" of currentProcessSelectionQ)
				
				set showName to first item of currentProcessSelectionQ2
				set showNameEncoded to my encode_text(my prepareCommand(showName), true, true)
				if second item of currentProcessSelectionQ2 ≠ "" then
					set showName to showName & " - " & second item of currentProcessSelectionQ2
				end if
				set showName to showName & " - " & fifth item of currentProcessSelectionQ2
				set showNameP to my replace_chars(showName, "/", ":")
				set filePath to (my prepareCommand(DL & showNameP & filenameExtension) as string)
				set fullFileSize to fourth item of currentProcessSelectionQ2
				set fullFileSize to (first word of fullFileSize as integer)
				
				set success to 1
				try
					set shellCmd to "rm /tmp/iTiVo-" & UserName & "/iTiVoDL{,2,3}"
					do shell script shellCmd
				end try
				set success to my downloadItem(currentProcessSelectionQ2, 1, 4)
				if success > 0 and cancelAllDownloads = 0 then
					set processInfoRecordTemp to content of targetDataQ
					set processInfoRecord to {}
					set rowCount to 1
					set totalCount to 0
					repeat with currentLine in processInfoRecordTemp
						set totalCount to totalCount + 1
						if not rowCount = 1 then
							set end of processInfoRecord to currentLine
						else
							set totalCount to totalCount - 1
						end if
						set rowCount to rowCount + 1
					end repeat
					set content of targetDataQ to processInfoRecord
					set queue_len to count of processInfoRecord
					if queue_len = 0 then
						set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to "Download Queue (empty)"
						my setDockTile("")
					else if queue_len = 1 then
						set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to "Download Queue (1 item)"
						my setDockTile(queue_len as string)
					else
						set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to "Download Queue (" & queue_len & " items)"
						my setDockTile(queue_len as string)
					end if
					set rowCountQ to count of data rows of data source 1 of table view "queueListTable" of scroll view "queueList" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1"
				else
					set rowCountQ to 0
					set enabled of button "decodeQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to true
				end if
			end repeat
			if success > 0 and cancelAllDownloads = 0 then
				set currentProcessSelectionQ to {}
				set content of targetDataQ to currentProcessSelectionQ
			end if
			set enabled of button "connectButton" to true
			if (count of (selected data rows of table view "ShowListTable" of scroll view "ShowList" of box "topBox" of split view "splitView1")) = 1 then
				set enabled of button "DownloadButton" of box "topBox" of split view "splitView1" to true
				set enabled of button "subscribeButton" of box "topBox" of split view "splitView1" to true
			end if
			set enabled of button "queueButton" of box "topBox" of split view "splitView1" to true
		else if theObjectName = "DownloadButton" then
			try
				set enabled of button "DownloadButton" of box "topBox" of split view "splitView1" to false
				set enabled of button "decodeQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
				set enabled of button "connectButton" to false
				set currentProcessSelection to {}
				set currentProcessSelectionTEMP to (selected data rows of table view "ShowListTable" of scroll view "ShowList" of box "topBox" of split view "splitView1")
				set currentProcessSelectionTEMP to item 1 of currentProcessSelectionTEMP
				set end of currentProcessSelection to contents of (data cell "ShowVal" of currentProcessSelectionTEMP)
				set end of currentProcessSelection to contents of (data cell "EpisodeVal" of currentProcessSelectionTEMP)
				set end of currentProcessSelection to contents of (data cell "DateVal" of currentProcessSelectionTEMP)
				set end of currentProcessSelection to contents of (data cell "SizeVal" of currentProcessSelectionTEMP)
				set end of currentProcessSelection to contents of (data cell "IDVal" of currentProcessSelectionTEMP)
				
				set showName to first item of currentProcessSelection
				set showNameEncoded to my encode_text(my prepareCommand(showName), true, true)
				if second item of currentProcessSelection ≠ "" then
					set showName to showName & " - " & second item of currentProcessSelection
				end if
				set showName to showName & " - " & fifth item of currentProcessSelection
				set showNameP to my replace_chars(showName, "/", ":")
				set filePath to (my prepareCommand(DL & showNameP & ".") as string)
				set fullFileSize to fourth item of currentProcessSelection
				set fullFileSize to (first word of fullFileSize as integer)
				
				set success to 1
				set success to my downloadItem(currentProcessSelection, 0, 4)
				if (count of (selected data rows of table view "ShowListTable" of scroll view "ShowList" of box "topBox" of split view "splitView1")) = 1 then
					set enabled of button "DownloadButton" of box "topBox" of split view "splitView1" to true
					set enabled of button "subscribeButton" of box "topBox" of split view "splitView1" to true
				end if
				if (count of data rows of data source 1 of table view "queueListTable" of scroll view "queueList" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1") > 0 then
					set enabled of button "decodeQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to true
				end if
				set enabled of button "queueButton" of box "topBox" of split view "splitView1" to true
				set enabled of button "connectButton" to true
			end try
		else if theObjectName = "iTunes" then
			set iTunes to state of theObject
			if iTunes > 0 then
				set enabled of button "iTunesSync" of view "DownloadingView" of tab view "TopTab" of panelWIndow to true
				set enabled of popup button "icon" of view "DownloadingView" of tab view "TopTab" of panelWIndow to true
			else
				set enabled of button "iTunesSync" of view "DownloadingView" of tab view "TopTab" of panelWIndow to false
				set enabled of popup button "icon" of view "DownloadingView" of tab view "TopTab" of panelWIndow to false
			end if
		else if theObjectName = "useTime" then
			set useTime to state of theObject as boolean
			my debug_log("useTime is set to " & useTime)
			if (useTime = true) then
				set enabled of control "useTimeStartTime" of view "SchedulingView" of tab view "TopTab" of panelWIndow to true
				set enabled of control "useTimeEndTime" of view "SchedulingView" of tab view "TopTab" of panelWIndow to true
			else
				set enabled of control "useTimeStartTime" of view "SchedulingView" of tab view "TopTab" of panelWIndow to false
				set enabled of control "useTimeEndTime" of view "SchedulingView" of tab view "TopTab" of panelWIndow to false
			end if
		else if theObjectName = "customFormat" then
			set temp to display dialog "Enter a name for the custom format" default answer "Custom Format"
			set text_user_entered to the text returned of temp
			if button returned of temp is "OK" then
				my debug_log("Writing out " & text_user_entered)
				set newfilenameExtension to contents of text field "filenameExtension" of view "AdvancedView" of tab view "TopTab" of panelWIndow
				set newencoderUsed to contents of text field "encoderUsed" of view "AdvancedView" of tab view "TopTab" of panelWIndow
				set newencoderVideoOptions to contents of text field "encoderVideoOptions" of view "AdvancedView" of tab view "TopTab" of panelWIndow
				set newencoderAudioOptions to contents of text field "encoderAudioOptions" of view "AdvancedView" of tab view "TopTab" of panelWIndow
				set newencoderOtherOptions to contents of text field "encoderOtherOptions" of view "AdvancedView" of tab view "TopTab" of panelWIndow
				my write_out_custom_format(text_user_entered, format, newfilenameExtension, newencoderUsed, newencoderVideoOptions, newencoderAudioOptions, newencoderOtherOptions)
				set format to text_user_entered
				my readFormats()
			end if
		end if
	end tell
	set AppleScript's text item delimiters to ""
end clicked


on should select row theObject row theRow
	tell window "iTiVo" to update
	if name of theObject = "ShowListTable" then
		if ((count of sorted data rows of data source of theObject) > 0) then
			set myRows to get sorted data rows of data source of theObject
			set myvalue to contents of data cell "IDVal" of item theRow of myRows
		else
			set myvalue to contents of data cell "IDVal" of data row theRow of data source of theObject
		end if
		if (myvalue = "copyright") then
			return false
		else
			return true
		end if
	end if
	return true
end should select row

on selection changing theObject
	tell window "iTiVo"
		if name of theObject = "ShowListTable" and title of button "ConnectButton" = "Update from TiVo" then
			set selected rows of table view "queueListTable" of scroll view "queueList" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to {}
			set selected rows of table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to {}
		else if name of theObject = "queueListTable" and title of button "ConnectButton" = "Update from TiVo" then
			set selected rows of table view "showListTable" of scroll view "showList" of box "topBox" of split view "splitView1" to {}
			set selected rows of table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to {}
		else if name of theObject = "subscriptionListTable" and title of button "ConnectButton" = "Update from TiVo" then
			set selected rows of table view "queueListTable" of scroll view "queueList" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to {}
			set selected rows of table view "showListTable" of scroll view "showList" of box "topBox" of split view "splitView1" to {}
		end if
	end tell
end selection changing

on selection changed theObject
	tell window "iTiVo"
		if name of theObject = "ShowListTable" and title of button "ConnectButton" = "Update from TiVo" then
			set currentProcessSelection to {}
			try
				set currentProcessSelectionsTEMP to selected data rows of theObject
				set rowCount to count of currentProcessSelectionsTEMP
				set transparent of button "imdb" of drawer "Drawer2" to true
				set enabled of button "imdb" of drawer "Drawer2" to false
				set transparent of button "tvdb" of drawer "Drawer2" to true
				set enabled of button "tvdb" of drawer "Drawer2" to false
				set contents of text field "detailTitle" of drawer "Drawer2" to ""
				set contents of text field "detailTime" of drawer "Drawer2" to ""
				set contents of text field "detailDescription" of drawer "Drawer2" to ""
				set contents of text field "detailQuality" of drawer "Drawer2" to ""
				set contents of text field "detailGenre" of drawer "Drawer2" to ""
				set contents of text field "detailActors" of drawer "Drawer2" to ""
				set contents of text field "detailWriter" of drawer "Drawer2" to ""
				set contents of text field "detailDirector" of drawer "Drawer2" to ""
				set contents of text field "detailRating" of drawer "Drawer2" to ""
				set contents of text field "detailEpisode" of drawer "Drawer2" to ""
				set contents of text field "detailEpisodeNum" of drawer "Drawer2" to ""
				set contents of text field "detailDate" of drawer "Drawer2" to ""
				if rowCount = 1 then
					set currentProcessSelectionTEMP to item 1 of currentProcessSelectionsTEMP
					set showID to contents of (data cell "IDVal" of currentProcessSelectionTEMP)
					set myPath to my prepareCommand(POSIX path of (path to me))
					set ShellScriptCommand to "perl " & myPath & "Contents/Resources/ParseDetail.pl " & IPA & " " & MAK & " " & showID
					my debug_log(ShellScriptCommand)
					set item_list to do shell script ShellScriptCommand
					set AppleScript's text item delimiters to "|"
					set the parts to every text item of item_list
					if (count of parts) = 15 then
						set transparent of button "imdb" of drawer "Drawer2" to false
						set enabled of button "imdb" of drawer "Drawer2" to true
						set transparent of button "tvdb" of drawer "Drawer2" to false
						set enabled of button "tvdb" of drawer "Drawer2" to true
						set contents of text field "detailTitle" of drawer "Drawer2" to item 2 of parts
						set contents of text field "detailTime" of drawer "Drawer2" to item 7 of parts
						set contents of text field "detailDescription" of drawer "Drawer2" to item 4 of parts
						set contents of text field "detailQuality" of drawer "Drawer2" to item 6 of parts
						set contents of text field "detailGenre" of drawer "Drawer2" to item 8 of parts
						set contents of text field "detailActors" of drawer "Drawer2" to item 9 of parts
						set contents of text field "detailWriter" of drawer "Drawer2" to item 10 of parts
						set contents of text field "detailDirector" of drawer "Drawer2" to item 11 of parts
						set contents of text field "detailRating" of drawer "Drawer2" to item 12 of parts
						set contents of text field "detailEpisode" of drawer "Drawer2" to item 3 of parts
						set contents of text field "detailEpisodeNum" of drawer "Drawer2" to item 15 of parts
						set contents of text field "detailDate" of drawer "Drawer2" to item 13 of parts
					end if
					set AppleScript's text item delimiters to ""
				end if
				if rowCount = 0 then
					set enabled of button "queueButton" of box "topBox" of split view "splitView1" to false
					set enabled of button "subscribeButton" of box "topBox" of split view "splitView1" to false
					set enabled of button "DownloadButton" of box "topBox" of split view "splitView1" to false
					set enabled of button "deleteSubscriptionButton" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
				else
					set tempStatus to ""
					try
						set tempStatus to text 1 thru 11 of (contents of text field "status" as string)
					end try
					if tempStatus ≠ "Downloading" then
						if rowCount = 1 then
							set enabled of button "DownloadButton" of box "topBox" of split view "splitView1" to true
							set title of button "queueButton" of box "topBox" of split view "splitView1" to "Add Show to Queue"
							set enabled of button "subscribeButton" of box "topBox" of split view "splitView1" to true
						else
							set enabled of button "DownloadButton" of box "topBox" of split view "splitView1" to false
							set title of button "queueButton" of box "topBox" of split view "splitView1" to "Add Shows to Queue"
							set enabled of button "subscribeButton" of box "topBox" of split view "splitView1" to false
						end if
					end if
					set enabled of button "queueButton" of box "topBox" of split view "splitView1" to true
					set enabled of button "deleteSubscriptionButton" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
				end if
			on error
				set enabled of button "queueButton" of box "topBox" of split view "splitView1" to false
				set enabled of button "DownloadButton" of box "topBox" of split view "splitView1" to false
				set enabled of button "subscribeButton" of box "topBox" of split view "splitView1" to false
				set enabled of button "deleteSubscriptionButton" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
			end try
		else if name of theObject = "queueListTable" and title of button "ConnectButton" = "Update from TiVo" then
			set currentProcessSelectionQ to {}
			try
				set currentProcessSelectionsTEMP to selected data rows of theObject
				set rowCount to count of currentProcessSelectionsTEMP
				set transparent of button "imdb" of drawer "Drawer2" to true
				set enabled of button "imdb" of drawer "Drawer2" to false
				set transparent of button "tvdb" of drawer "Drawer2" to true
				set enabled of button "tvdb" of drawer "Drawer2" to false
				set contents of text field "detailTitle" of drawer "Drawer2" to ""
				set contents of text field "detailTime" of drawer "Drawer2" to ""
				set contents of text field "detailDescription" of drawer "Drawer2" to ""
				set contents of text field "detailQuality" of drawer "Drawer2" to ""
				set contents of text field "detailGenre" of drawer "Drawer2" to ""
				set contents of text field "detailActors" of drawer "Drawer2" to ""
				set contents of text field "detailRating" of drawer "Drawer2" to ""
				set contents of text field "detailEpisode" of drawer "Drawer2" to ""
				set contents of text field "detailEpisodeNum" of drawer "Drawer2" to ""
				set contents of text field "detailDate" of drawer "Drawer2" to ""
				if rowCount = 1 then
					set currentProcessSelectionTEMP to item 1 of currentProcessSelectionsTEMP
					set showID to contents of (data cell "IDVal" of currentProcessSelectionTEMP)
					set myPath to my prepareCommand(POSIX path of (path to me))
					set ShellScriptCommand to "perl " & myPath & "Contents/Resources/ParseDetail.pl " & IPA & " " & MAK & " " & showID
					my debug_log(ShellScriptCommand)
					set item_list to do shell script ShellScriptCommand
					set AppleScript's text item delimiters to "|"
					set the parts to every text item of item_list
					if (count of parts) = 15 then
						set transparent of button "imdb" of drawer "Drawer2" to false
						set enabled of button "imdb" of drawer "Drawer2" to true
						set transparent of button "tvdb" of drawer "Drawer2" to false
						set enabled of button "tvdb" of drawer "Drawer2" to true
						set contents of text field "detailTitle" of drawer "Drawer2" to item 2 of parts
						set contents of text field "detailTime" of drawer "Drawer2" to item 7 of parts
						set contents of text field "detailDescription" of drawer "Drawer2" to item 4 of parts
						set contents of text field "detailQuality" of drawer "Drawer2" to item 6 of parts
						set contents of text field "detailGenre" of drawer "Drawer2" to item 8 of parts
						set contents of text field "detailActors" of drawer "Drawer2" to item 9 of parts
						set contents of text field "detailWriter" of drawer "Drawer2" to item 10 of parts
						set contents of text field "detailDirector" of drawer "Drawer2" to item 11 of parts
						set contents of text field "detailRating" of drawer "Drawer2" to item 12 of parts
						set contents of text field "detailEpisode" of drawer "Drawer2" to item 3 of parts
						set contents of text field "detailEpisodeNum" of drawer "Drawer2" to item 15 of parts
						set contents of text field "detailDate" of drawer "Drawer2" to item 13 of parts
					end if
					set AppleScript's text item delimiters to ""
				end if
				set enabled of button "deleteSubscriptionButton" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
				if rowCount = 0 then
					set enabled of button "removeButton" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
				else
					set enabled of button "removeButton" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to true
					set tempStatus to ""
					try
						set tempStatus to text 1 thru 11 of (contents of text field "status" as string)
					end try
					if tempStatus ≠ "Downloading" then
						set enabled of button "queueButton" of box "topBox" of split view "splitView1" to true
					end if
				end if
			on error
				set enabled of button "removeButton" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
			end try
		else if name of theObject = "subscriptionListTable" and title of button "ConnectButton" = "Update from TiVo" then
			set currentProcessSelectionsTEMP to selected data rows of theObject
			set rowCount to count of currentProcessSelectionsTEMP
			set enabled of button "queueButton" of box "topBox" of split view "splitView1" to false
			set enabled of button "subscribeButton" of box "topBox" of split view "splitView1" to false
			set enabled of button "DownloadButton" of box "topBox" of split view "splitView1" to false
			set enabled of button "removeButton" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
			if ((count of currentProcessSelectionsTEMP) > 0) then
				set enabled of button "deleteSubscriptionButton" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to true
			else
				set enabled of button "deleteSubscriptionButton" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to false
			end if
		end if
	end tell
end selection changed

on column clicked theObject table column tableColumn
	if name of theObject = "ShowListTable" then
		if (name of tableColumn = "DLVal") then
			return
		end if
		set use sort indicators of theObject to true
		set sorted of targetData to true
		if sortColumn = name of tableColumn then
			set dataColumn to data column (name of tableColumn) of targetData
			if sort order of dataColumn is ascending then
				set sort order of dataColumn to descending
			else
				set sort order of dataColumn to ascending
			end if
		end if
		set sortColumn to name of tableColumn
		set sort column of targetData to data column sortColumn of targetData
		set data source of theObject to targetData
		set selected rows of theObject to {}
		update theObject
	end if
end column clicked

on choose menu item theObject
	if name of theObject = "Help" then
		open location "http://code.google.com/p/itivo/wiki/Help"
	else if name of theObject = "Preferences" then
		my displayPrefs()
	else if name of theObject = "format" then
		local myformat
		set myformat to title of popup button "format" of view "DownloadingView" of tab view "TopTab" of panelWIndow
		set {encoderUsed, encoderVideoOptions, encoderAudioOptions, encoderOtherOptions, filenameExtension} to getFormatSettings(myformat)
		set contents of text field "formatDescription" of view "DownloadingView" of tab view "TopTab" of panelWIndow to my formatDescription(myformat)
		if (not my formatCompatComSkip(myformat)) then
			set comSkip to 0
		end if
		if (my formatCompatItunes(myformat)) then
			set enabled of button "iTunes" of view "DownloadingView" of tab view "TopTab" of panelWIndow to true
			set enabled of button "iTunesSync" of view "DownloadingView" of tab view "TopTab" of panelWIndow to true
			set enabled of popup button "icon" of view "DownloadingView" of tab view "TopTab" of panelWIndow to true
		else
			set state of button "iTunes" of view "DownloadingView" of tab view "TopTab" of panelWIndow to false
			set enabled of button "iTunes" of view "DownloadingView" of tab view "TopTab" of panelWIndow to false
			set enabled of button "iTunesSync" of view "DownloadingView" of tab view "TopTab" of panelWIndow to false
			set enabled of popup button "icon" of view "DownloadingView" of tab view "TopTab" of panelWIndow to false
		end if
	else if name of theObject = "MyTiVos" and not title of theObject = "My TiVos" then
		set tivoSize to 1
		if title of theObject ≠ "My TiVos" then
			tell window "iTiVo"
				try
					set theScript to "mDNS -L \"" & title of theObject & "\" _tivo-videos._tcp local | colrm 1 42 &
sleep 2
killall mDNS"
					set hostList to paragraphs 1 thru -1 of (do shell script theScript)
					repeat with j in hostList
						try
							if text 17 thru 19 of j is "443" then
								set IPA to first word of j
								set contents of text field "IP" to IPA
							end if
						end try
					end repeat
					my ConnectTiVo()
				on error
					display dialog "Unable to connect to TiVo " & title of theObject & ".  It is no longer available on your network."
				end try
			end tell
		end if
	end if
end choose menu item

on changed theObject
	if name of theObject = "IP" then
		set title of popup button "MyTiVos" of window "iTiVo" to "My TiVos"
	end if
end changed

on will close theObject
	if name of theObject = "Drawer2" then
		tell theObject to close drawer
		set state of button "detailButton" of window "iTiVo" to true
		set openDetail to 0
	end if
end will close

on encode_char(this_char)
	set the ASCII_num to (the ASCII number this_char)
	set the hex_list to ¬
		{"0", "1", "2", "3", "4", "5", "6", "7", "8", ¬
			"9", "A", "B", "C", "D", "E", "F"}
	set x to item ((ASCII_num div 16) + 1) of the hex_list
	set y to item ((ASCII_num mod 16) + 1) of the hex_list
	return ("%" & x & y) as string
end encode_char

on encode_text(this_text, encode_URL_A, encode_URL_B)
	set the standard_characters to ¬
		"abcdefghijklmnopqrstuvwxyz0123456789"
	set the URL_A_chars to "$+!'/?;&@=#%><{}[]\"~`^\\|*"
	set the URL_B_chars to ".-_:"
	set the acceptable_characters to the standard_characters
	if encode_URL_A is false then ¬
		set the acceptable_characters to ¬
			the acceptable_characters & the URL_A_chars
	if encode_URL_B is false then ¬
		set the acceptable_characters to ¬
			the acceptable_characters & the URL_B_chars
	set the encoded_text to ""
	repeat with this_char in this_text
		if this_char is in the acceptable_characters then
			set the encoded_text to ¬
				(the encoded_text & this_char)
		else
			set the encoded_text to ¬
				(the encoded_text & encode_char(this_char)) as string
		end if
	end repeat
	return the encoded_text
end encode_text

on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars

on checkProcess()
	set myPath to my prepareCommand(POSIX path of (path to me))
	set ShellScriptCommand to "" & myPath & "Contents/Resources/getProcess.sh;exit 0"
	my debug_log(ShellScriptCommand)
	tell window "iTiVo"
		set scriptResult to (do shell script ShellScriptCommand)
		set scriptLineCount to count of paragraphs of scriptResult
		if scriptLineCount > 1 then
			return true
		else
			return false
		end if
	end tell
end checkProcess

on downloadItem(currentProcessSelectionParam, overrideDLCheck, retryCount)
	my debug_log("downloadItem called: " & overrideDLCheck & "," & retryCount)
	tell window "iTiVo"
		if not (my checkDL()) then
			return 0
		end if
		set enabled of button "CancelDownload" to true
		set myPath to my prepareCommand(POSIX path of (path to me))
		set myHomePathP to POSIX path of (path to home folder)
		set showID to item 5 of currentProcessSelectionParam
		set showName to first item of currentProcessSelectionParam as string
		set oShowName to showName
		set oShowDate to third item of currentProcessSelectionParam
		set showNameEncoded to my encode_text(my prepareCommand(showName), true, true)
		set oShowEpisode to second item of currentProcessSelectionParam as string
		if oShowEpisode ≠ "" then
			set showEpisode to second item of currentProcessSelectionParam as string
		else
			set showEpisode to showID as string
		end if
		set showName to showName & " - " & showEpisode
		set showFullNameEncoded to my encode_text(my prepareCommand(showName), true, true)
		set myHomePathP2 to my encode_text(my prepareCommand(DL), true, true)
		set myPath2 to my encode_text(myPath, true, true)
		set ShellScriptCommand to "perl " & myPath & "Contents/Resources/ParseDetail.pl " & IPA & " " & MAK & " " & showID
		my debug_log(ShellScriptCommand)
		set item_list to do shell script ShellScriptCommand
		set AppleScript's text item delimiters to "|"
		set the parts to every text item of item_list
		set showDescription to item 4 of parts as string
		set showEpisodeLength to item 7 of parts
		set showEpisodeGenre to item 8 of parts
		set showEpisodeNum to item 15 of parts
		set showEpisodeYear to item 14 of parts
		set fullFileSize to fourth item of currentProcessSelectionParam
		set fullFileSize to (first word of fullFileSize as integer)
		if (fullFileSize ≤ 0) then
			my debug_log("fullFileSize is <= 0???")
			set fullFileSize to 1
		end if
		set showName to my replace_chars(showName, ":", "-")
		set showNameP to my replace_chars(showName, "/", ":")
		set showNameCheck to showName & filenameExtension
		set filePath to (my prepareCommand(DL & showNameP & filenameExtension) as string)
		if (overrideDLCheck < 1) then
			if my checkDLFile(showNameCheck) then
				return 0
			end if
		end if
		set AppleScript's text item delimiters to ""
	end tell
	set currentTry to 0
	if (encoderUsed = "") then set encoderUsed to " "
	if (encoderVideoOptions = "") then set encoderVideoOptions to " "
	if (encoderAudioOptions = "") then set encoderAudioOptions to " "
	if (encoderOtherOptions = "") then set encoderOtherOptions to " "
	try
		set shellCmd to "rm /tmp/iTiVo-" & UserName & "/iTiVoDL{,2,3}"
		my debug_log(shellCmd)
		do shell script shellCmd
	end try
	set cancelDownload to 0
	set timeRemaining to 0
	set totalSteps to 0
	
	if (showID = "copyright") then
		my debug_log("Attempted to download copyrighted show " & oShowName)
		if GrowlAppName = "GrowlHelperApp.app" then
			try
				tell application GrowlAppName
					using terms from application "GrowlHelperApp"
						notify with name "Can't Download" title "Downloading Failure 
" & (oShowName) description "is marked copyrighted by your tivo" application name "iTiVo"
					end using terms from
				end tell
			end try
		end if
		return 1
	end if
	
	repeat while ((not (my isDownloadComplete(filePath, fullFileSize, currentTry) and (timeRemaining ≤ 5 * (retryCount + 1)))) and currentTry < retryCount and cancelDownload = 0)
		my performCancelDownload()
		tell window "iTiVo"
			try
				set shellCmd to "rm -f /tmp/iTiVo-" & UserName & "/iTiVoDLPipe*" & " /tmp/iTiVo-" & UserName & "/iTiVoTDC* /tmp/iTiVo-" & UserName & "/iTiVoDLMeta*"
				my debug_log(shellCmd)
				do shell script shellCmd
			end try
			if (comSkip = 0 and downloadFirst = false and my formatMustDownloadFirst(format) = false) then
				set shellCmd to "mkfifo /tmp/iTiVo-" & UserName & "/iTiVoDLPipe /tmp/iTiVo-" & UserName & "/iTiVoDLPipe2.mpg"
				set totalSteps to 1
			else
				set shellCmd to "mkfifo /tmp/iTiVo-" & UserName & "/iTiVoDLPipe ; touch /tmp/iTiVo-" & UserName & "/iTiVoDLPipe{2,3}.mpg"
				if (comSkip = 1) then
					if (not encoderUsed = "mencoder") then
						set totalSteps to 4
					else
						set totalSteps to 3
					end if
				else
					set totalSteps to 2
				end if
			end if
			call method "setMaxValue:" of control "StatusLevel" with parameters {totalSteps}
			my debug_log(shellCmd)
			do shell script shellCmd
			set ShellScriptCommand to "perl " & myPath & "Contents/Resources/http-fetcher.pl " & IPA & " " & showID & " " & showNameEncoded & " " & MAK & " /tmp/iTiVo-" & UserName & "/iTiVoDLPipe"
			set ShellScriptCommand to ShellScriptCommand & " >> " & debug_file & " 2>&1 & echo $! ;exit 0"
			my debug_log(ShellScriptCommand)
			do shell script ShellScriptCommand
			set ShellScriptCommand to "perl " & myPath & "Contents/Resources/tivo-decoder.pl " & myPath2 & " " & MAK
			set ShellScriptCommand to ShellScriptCommand & " >> " & debug_file & " 2>&1 & echo $! ;exit 0"
			my debug_log(ShellScriptCommand)
			do shell script ShellScriptCommand
			if (comSkip = 0 and downloadFirst = false and my formatMustDownloadFirst(format) = false) then
				set ShellScriptCommand to "perl " & myPath & "Contents/Resources/re-encoder.pl " & myPath2 & " " & myHomePathP2 & " " & showFullNameEncoded & filenameExtension & " "
				set ShellScriptCommand to ShellScriptCommand & quoted form of encoderUsed & " " & quoted form of encoderVideoOptions & " "
				set ShellScriptCommand to ShellScriptCommand & quoted form of encoderAudioOptions & " " & quoted form of encoderOtherOptions & " "
				set ShellScriptCommand to ShellScriptCommand & " >> " & debug_file & " 2>&1 & echo $! ;exit 0"
				my debug_log(ShellScriptCommand)
				do shell script ShellScriptCommand
			end if
			set currentFileSize to 0
			set progressDifference to -1 * currentProgress
			tell progress indicator "Status" to increment by progressDifference
			set progressDifference to 0
			set contents of text field "status" to "Downloading " & showName
			set currentFileSize to 0
			set prevFileSize to 0
			set timeoutCount to 0
			set downloadExistsCmdString to "du -k -d 0 /tmp/iTiVo-" & UserName & "/iTiVoDLPipe ;exit 0"
			set downloadExistsCmd to do shell script downloadExistsCmdString
			if downloadExistsCmd is not equal to "" then
				set downloadExists to 1
			else
				set downloadExists to 0
			end if
		end tell
		if GrowlAppName = "GrowlHelperApp.app" then
			try
				my debug_log("Informing via Growl")
				tell application GrowlAppName
					using terms from application "GrowlHelperApp"
						if currentTry > 0 then
							notify with name "Beginning Download" title "Retrying (try number " & currentTry + 1 & ")
" & (oShowName) description (showEpisode) application name "iTiVo"
						else
							notify with name "Beginning Download" title "Downloading 
" & (oShowName) description (showEpisode) application name "iTiVo"
						end if
					end using terms from
				end tell
			end try
		end if
		set currentTry to currentTry + 1
		set currentStep to 1
		tell window "iTiVo"
			set ETA to ""
			set visible of progress indicator "Status" to true
			set visible of control "StatusLevel" to true
			set integer value of control "StatusLevel" to currentStep
			set starttime to ((do shell script "date +%s") as integer) - 10
			
			-- Download, decrypt, and potentially re-encode in one pipeline
			repeat while timeoutCount < 1200 and cancelDownload as integer = 0 and downloadExists as integer = 1 and cancelAllDownloads as integer = 0
				if (debug_level ≥ 3) then
					my debug_log("timeout: " & timeoutCount & "   currentFileSize: " & currentFileSize & "  fullFileSize:" & fullFileSize)
				end if
				if currentFileSize = 0 then
					set starttime to do shell script "date +%s"
				end if
				set currenttime to ((do shell script "date +%s") as integer)
				set currentFileSize to my getCurrentFilesize(filePath)
				set downloadExistsCmd to do shell script downloadExistsCmdString
				if downloadExistsCmd is not equal to "" then
					set downloadExists to 1
				else
					set downloadExists to 0
				end if
				if currentFileSize as real > prevFileSize as real then
					set prevFileSize to currentFileSize
					set timeoutCount to 0
					set contents of text field "status" to "(phase " & currentStep & "/" & totalSteps & ") Downloading " & showName
				else
					set timeoutCount to timeoutCount + 1
					if timeoutCount = 20 then
						set contents of text field "status" to "(phase " & currentStep & "/" & totalSteps & ") Downloading " & oShowName & " (waiting for TiVo)"
					end if
				end if
				try
					set progressDifference to (100 * (currentFileSize / fullFileSize)) - currentProgress
					tell progress indicator "Status" to increment by progressDifference
					set currentProgress to (100 * (currentFileSize / fullFileSize))
					if currentProgress > 100 then
						set currentProgress to 100
					end if
					if encodeMode > 0 then
						set contents of text field "status2" to ((my roundThis(currentProgress, 2)) as string) & "% complete" & ETA as string
					else
						set contents of text field "status2" to (((currentFileSize as integer) as string) & " MB of " & fullFileSize as string) & " MB (" & ((my roundThis(currentProgress, 1)) as string) & "%)" & ETA as string
					end if
				end try
				if currentFileSize > 0 then
					try
						set remainingData to (fullFileSize - currentFileSize)
						if remainingData < 0 then
							set remainingData to 0
						end if
						set ETA to (((my truncate(remainingData * ((currenttime - starttime) / currentFileSize))) + 15) / 60) as integer
						set hour to my truncate(ETA / 60) as integer
						set min to ETA - (hour * 60)
						if hour > 0 then
							set ETA to " (" & hour & " hour"
							if hour ≠ 1 then
								set ETA to ETA & "s"
							end if
							set ETA to ETA & ", "
						else
							set ETA to " ("
						end if
						set ETA to ETA & min & " minute"
						if min ≠ 1 then
							set ETA to ETA & "s"
						end if
						set ETA to ETA & " remaining)"
					end try
				end if
				delay 0.5
			end repeat
			tell progress indicator "Status" to increment by -1 * currentProgress
			
			-- The following are only done if above didnt do everything in one pipeline
			-- Scan for Commercials
			if (my isDownloadComplete(filePath, fullFileSize, currentTry) and comSkip = 1) then
				set currentProgresss to 0
				set downloadExistsCmdString to "du -k -d 0 /tmp/iTiVo-" & UserName & "/iTiVoDLPipe3.mpg ;exit 0"
				set timeoutCount to 0
				set timeRemaining to 200
				set downloadExists to 1
				set currentPercent to 0
				set hrs to 0
				set mins to 0
				set secs to 0
				set timeOn to "0:0:0"
				set frameOn to 0
				set prevframeOn to 0
				set ShellScriptCommand to "perl " & myPath & "Contents/Resources/remove-commercials.pl " & myPath2 & " " & encoderUsed
				set ShellScriptCommand to ShellScriptCommand & " >> " & debug_file & " 2>&1  & echo $! ;exit 0"
				my debug_log(ShellScriptCommand)
				do shell script ShellScriptCommand
				set currentStep to currentStep + 1
				set integer value of control "StatusLevel" to currentStep
				repeat while timeoutCount < 1200 and cancelDownload as integer = 0 and downloadExists as integer = 1 and cancelAllDownloads as integer = 0
					if (debug_level ≥ 3) then
						my debug_log("comskip timeout: " & timeoutCount & " download:" & downloadExists & "   frameOn: " & frameOn & "  timeOn:" & timeOn & "   currentPercent: " & currentPercent)
					end if
					set {frameOn, currentPercent, timeOn} to my getcomskip()
					set downloadExistsCmd to do shell script downloadExistsCmdString
					if downloadExistsCmd is not equal to "" then
						set downloadExists to 1
					else
						set downloadExists to 0
					end if
					if frameOn as integer > prevframeOn as integer then
						set prevframeOn to frameOn
						set timeoutCount to 0
						set contents of text field "status" to "(phase " & currentStep & "/" & totalSteps & ") Commercial Detect " & showName
					else
						set timeoutCount to timeoutCount + 1
						if timeoutCount = 20 then
							set contents of text field "status" to "(phase " & currentStep & "/" & totalSteps & ") Commercial Detect " & oShowName & " (stalled)"
						end if
					end if
					try
						set progressDifference to currentPercent - currentProgress
						tell progress indicator "Status" to increment by progressDifference
						set currentProgress to currentPercent as integer
						if currentProgress > 100 then
							set currentProgress to 100
						end if
						set contents of text field "status2" to (timeOn as string) & " processed      (" & (currentPercent as string) & "% )"
					end try
					delay 0.5
				end repeat
				if (timeoutCount ≥ 1200) then
					my debug_log("Time out on comskip ...  Resetting EDL list")
					set shellCmd to "rm -f /tmp/iTiVo-" & UserName & "/iTiVoDLPipe2.edl"
					my debug_log(ShellScriptCommand)
					do shell script shellCmd
				end if
				tell progress indicator "Status" to increment by -1 * currentProgress
			end if
			
			-- Cut out the commercials using mencoder for other encoders
			
			if (my isDownloadComplete(filePath, fullFileSize, currentTry) and (comSkip = 1 and (not encoderUsed = "mencoder"))) then
				my debug_log("Cutting Commercials")
				set currentProgresss to 0
				set downloadExistsCmdString to "du -k -d 0 /tmp/iTiVo-" & UserName & "/iTiVoDLPipe2.mpg ;exit 0"
				set timeRemaining to 200
				set timeoutCount to 0
				set downloadExists to 1
				set currentPercent to 0
				set timeOn to 0.0
				set prevtimeOn to 0
				set ShellScriptCommand to "perl " & myPath & "Contents/Resources/re-encoder.pl " & myPath2 & " /tmp/iTiVo-" & UserName & "/ iTiVoDLPipe3.mpg "
				set ShellScriptCommand to ShellScriptCommand & "mencoder " & quoted form of "-ovc copy -of mpeg -mpegopts format=mpeg2:tsaf:muxrate=36000 -noskip -mc 0 -forceidx" & " "
				set ShellScriptCommand to ShellScriptCommand & quoted form of "-oac copy" & " " & quoted form of " "
				set ShellScriptCommand to ShellScriptCommand & " >> " & debug_file & " 2>&1 & echo $! ;exit 0"
				my debug_log(ShellScriptCommand)
				do shell script ShellScriptCommand
				set currentStep to currentStep + 1
				set integer value of control "StatusLevel" to currentStep
				repeat while timeoutCount < 1200 and cancelDownload as integer = 0 and downloadExists as integer = 1 and cancelAllDownloads as integer = 0
					if (debug_level ≥ 3) then
						my debug_log("mencoder timeout: " & timeoutCount & " download:" & downloadExists & "   timeRemaining: " & timeRemaining & "  timeOn:" & timeOn & "   currentPercent: " & currentPercent)
					end if
					set {timeOn, currentPercent, timeRemaining} to my getEncoderProgress(encoderUsed)
					set downloadExistsCmd to do shell script downloadExistsCmdString
					if downloadExistsCmd is not equal to "" then
						set downloadExists to 1
					else
						set downloadExists to 0
					end if
					if timeOn as real > prevtimeOn as real then
						set prevtimeOn to timeOn
						set timeoutCount to 0
						set contents of text field "status" to "(phase " & currentStep & "/" & totalSteps & ") Commercial Cut " & showName
					else
						set timeoutCount to timeoutCount + 1
						if timeoutCount = 20 then
							set contents of text field "status" to "(phase " & currentStep & "/" & totalSteps & ") Commercial Cut " & oShowName & " (waiting)"
						end if
					end if
					try
						set progressDifference to currentPercent - currentProgress
						tell progress indicator "Status" to increment by progressDifference
						set currentProgress to currentPercent as integer
						if currentProgress > 100 then
							set currentProgress to 100
						end if
						set timedone to timeOn as integer
						set hrs to (timedone div 3600)
						if (hrs < 10) then
							set hrs to "0" & hrs as string
						else
							set hrs to hrs as string
						end if
						set timedone to timedone mod 3600
						set mins to (timedone div 60)
						if (mins < 10) then
							set mins to "0" & mins as string
						else
							set mins to mins as string
						end if
						set secs to (timedone mod 60)
						if (secs < 10) then
							set secs to "0" & secs as string
						else
							set secs to secs as string
						end if
						set timedone to hrs & ":" & mins & ":" & secs
						set contents of text field "status2" to (timedone & " encoded      (" & (timeRemaining + 1) as string) & " mins remaining)"
					end try
					delay 0.5
				end repeat
				if (timeoutCount ≥ 1200) then
					my debug_log("Time out on pre-cutting commercials, just using original movie instead")
					set shellCmd to "rm -f /tmp/iTiVo-" & UserName & "/iTiVoDLPipe3.mpg"
					my debug_log(shellCmd)
					do shell script shellCmd
				else
					set ShellScriptCommand to "mv /tmp/iTiVo-" & UserName & "/iTiVoDLPipe3.mpg /tmp/iTiVo-" & UserName & "/iTiVoDLPipe2.mpg"
					my debug_log(ShellScriptCommand)
					do shell script ShellScriptCommand
				end if
				tell progress indicator "Status" to increment by -1 * currentProgress
			end if
			
			-- Finally run the encoder
			if (my isDownloadComplete(filePath, fullFileSize, currentTry) and (comSkip = 1 or downloadFirst = true or my formatMustDownloadFirst(format) = true)) then
				set currentProgresss to 0
				set downloadExistsCmdString to "du -k -d 0 /tmp/iTiVo-" & UserName & "/iTiVoDLPipe2.mpg ;exit 0"
				set timeRemaining to 200
				set timeoutCount to 0
				set downloadExists to 1
				set currentPercent to 0
				set timeOn to 0.0
				set prevtimeOn to 0
				set ShellScriptCommand to "perl " & myPath & "Contents/Resources/re-encoder.pl " & myPath2 & " " & myHomePathP2 & " " & showFullNameEncoded & filenameExtension & " "
				set ShellScriptCommand to ShellScriptCommand & quoted form of encoderUsed & " " & quoted form of encoderVideoOptions & " "
				set ShellScriptCommand to ShellScriptCommand & quoted form of encoderAudioOptions & " " & quoted form of encoderOtherOptions
				set ShellScriptCommand to ShellScriptCommand & " >> " & debug_file & " 2>&1 & echo $! ;exit 0"
				my debug_log(ShellScriptCommand)
				do shell script ShellScriptCommand
				set currentStep to currentStep + 1
				set integer value of control "StatusLevel" to currentStep
				repeat while timeoutCount < 1200 and cancelDownload as integer = 0 and downloadExists as integer = 1 and cancelAllDownloads as integer = 0
					if (debug_level ≥ 3) then
						my debug_log("mencoder timeout: " & timeoutCount & " download:" & downloadExists & "   timeRemaining: " & timeRemaining & "  timeOn:" & timeOn & "   currentPercent: " & currentPercent)
					end if
					set {timeOn, currentPercent, timeRemaining} to my getEncoderProgress(encoderUsed)
					set downloadExistsCmd to do shell script downloadExistsCmdString
					if downloadExistsCmd is not equal to "" then
						set downloadExists to 1
					else
						set downloadExists to 0
					end if
					if timeOn as real > prevtimeOn as real then
						set prevtimeOn to timeOn
						set timeoutCount to 0
						set contents of text field "status" to "(phase " & currentStep & "/" & totalSteps & ") Encoding " & showName
					else
						set timeoutCount to timeoutCount + 1
						if timeoutCount = 20 then
							set contents of text field "status" to "(phase " & currentStep & "/" & totalSteps & ") Encoding " & oShowName & " (waiting)"
						end if
					end if
					try
						set progressDifference to currentPercent - currentProgress
						tell progress indicator "Status" to increment by progressDifference
						set currentProgress to currentPercent as integer
						if currentProgress > 100 then
							set currentProgress to 100
						end if
						set timedone to timeOn as integer
						set hrs to (timedone div 3600)
						if (hrs < 10) then
							set hrs to "0" & hrs as string
						else
							set hrs to hrs as string
						end if
						set timedone to timedone mod 3600
						set mins to (timedone div 60)
						if (mins < 10) then
							set mins to "0" & mins as string
						else
							set mins to mins as string
						end if
						set secs to (timedone mod 60)
						if (secs < 10) then
							set secs to "0" & secs as string
						else
							set secs to secs as string
						end if
						set timedone to hrs & ":" & mins & ":" & secs
						set contents of text field "status2" to (timedone & " encoded      (" & (timeRemaining + 1) as string) & " mins remaining)"
					end try
					delay 0.5
				end repeat
				tell progress indicator "Status" to increment by -1 * currentProgress
			end if
		end tell
		my debug_log("Download completed")
		if GrowlAppName = "GrowlHelperApp.app" then
			try
				tell application GrowlAppName
					using terms from application "GrowlHelperApp"
						if (my isDownloadComplete(filePath, fullFileSize, currentTry)) then
							notify with name "Ending Download" title "Finished
" & (oShowName) description (showEpisode) application name "iTiVo"
						else
							notify with name "Ending Download" title "Incomplete Download!
" & (oShowName) description (showEpisode) application name "iTiVo"
						end if
					end using terms from
				end tell
			end try
		end if
		my performCancelDownload()
	end repeat
	
	set complete to false
	if cancelDownload = 0 and my isDownloadComplete(filePath, fullFileSize, currentTry) then
		set complete to true
	end if
	
	my debug_log("Complete=" & complete & "  , 85% fullfilesize=" & (0.85 * fullFileSize) & " ;  currentfilesize=" & my getCurrentFilesize(filePath))
	
	tell window "iTiVo"
		set contents of text field "status" to "Generating MetaData "
		set contents of text field "status2" to ""
	end tell
	
	set DLDest to DL
	set safeOShowName to my replace_chars(oShowName, ":", "-")
	set safeOShowName to my replace_chars(safeOShowName, "/", ":")
	set safeName to my replace_chars(showName, ":", "-")
	set safeName to my replace_chars(safeName, "/", ":")
	set newFile to DL & safeName & filenameExtension
	
	set AppleScript's text item delimiters to ":"
	set the parts to every text item of showEpisodeLength
	set episodeLength2 to (60 * ((first item of parts) as integer)) + ((second item of parts) as integer)
	set isMovie to oShowEpisode = "" and showEpisodeNum = "" and episodeLength2 > 70
	set shouldSubdir to makeSubdirs and not isMovie
	set AppleScript's text item delimiters to ""
	
	if (complete = true) then
		set myPath to my prepareCommand(POSIX path of (path to me))
		set ShellScriptCommand to "perl " & myPath & "Contents/Resources/GetExtraInfo.pl " & IPA & " " & MAK & " " & showID
		my debug_log(ShellScriptCommand)
		set item_list to do shell script ShellScriptCommand
		set AppleScript's text item delimiters to "|"
		set the parts to every text item of item_list
		
		if (count of parts) = 7 then
			set showSeriesID to item 3 of parts
			set showEpisodeID to item 4 of parts
			set showChannelNum to item 5 of parts
			set showChannelCall to item 6 of parts
		else
			set showSeriesID to ""
			set showEpisodeID to ""
			set showChannelNum to ""
			set showChannelCall to ""
		end if
		set AppleScript's text item delimiters to ""
	end if
	
	if (complete = true and shouldSubdir = true) then
		try
			my debug_log("Moving to subdir")
			set DLDest to DL & safeOShowName
			set newFile to (DLDest & "/" & safeName & filenameExtension)
			tell window "iTiVo"
				set contents of text field "status" to "Moving file to subdirectory " & DLDest
			end tell
			set shellCmd to "mkdir -p " & my prepareCommand(DLDest) as string
			set shellCmd to shellCmd & ";  mv " & filePath & " " & my prepareCommand(newFile) as string
			my debug_log("Running: " & shellCmd)
			set shellCmdResult to do shell script shellCmd
			my debug_log("Result: " & shellCmdResult)
		end try
	end if
	
	if (complete = true and tivoMetaData = true) then
		my debug_log("Making tivo metadata")
		tell window "iTiVo"
			set contents of text field "status" to "Making TiVo Metadata " & DLDest & "/" & safeName & ".xml"
		end tell
		set shellCmd to "cp /tmp/iTiVo-" & UserName & "/iTiVoDLMeta.xml " & my prepareCommand(DLDest & "/" & safeName & ".xml") as string
		my debug_log("Running: " & shellCmd)
		set shellCmdResult to do shell script shellCmd
		my debug_log("Result: " & shellCmdResult)
	end if
	
	if (complete = true and txtMetaData = true) then
		my debug_log("Making pytivo txt data")
		tell window "iTiVo"
			set contents of text field "status" to "Making pyTivo Metadata " & newFile & ".txt"
		end tell
		my generate_text_metadata(newFile & ".txt", "/tmp/iTiVo-" & UserName & "/iTiVoDLMeta.xml", myPath & "Contents/Resources/pytivo_txt.xslt")
		set AddedData to "(/usr/bin/true"
		if not (showSeriesID = "") then
			set AddedData to AddedData & "; echo seriesID = " & quoted form of showSeriesID
		end if
		if not (showChannelNum = "") then
			set AddedData to AddedData & "; echo displayMajorNumber = " & quoted form of showChannelNum
		end if
		if not (showChannelCall = "") then
			set AddedData to AddedData & "; echo callsign = " & quoted form of showChannelCall
		end if
		set shellCmd to AddedData & " ) >> " & my prepareCommand(newFile & ".txt") as string
		my debug_log("Running: " & quoted form of shellCmd)
		try
			set shellCmdResult to do shell script shellCmd
		end try
	end if
	
	if (complete = true and APMetaData = true) then
		if ((filenameExtension = ".mp4") or (filenameExtension = ".m4v") or (filenameExtension = ".mov") or (filenameExtension = ".3gp")) then
			my debug_log("Making Atomic Parsley metadata")
			tell window "iTiVo"
				set contents of text field "status" to "Using AtomicParsley"
			end tell
			set shellCmd to "" & myPath & "Contents/Resources/AtomicParsley " & my prepareCommand(newFile) as string
			if (isMovie = true) then
				set shellCmd to shellCmd & " --title " & quoted form of oShowName
				set shellCmd to shellCmd & " --stik Movie"
			else
				set shellCmd to shellCmd & " --title " & quoted form of showEpisode
				set shellCmd to shellCmd & " --stik \"TV Show\""
				set shellCmd to shellCmd & " --TVShowName " & quoted form of oShowName
				if not (oShowEpisode = "") then
					set shellCmd to shellCmd & " --TVEpisode " & quoted form of oShowEpisode
				end if
				if not (showEpisodeNum = "") then
					set shellCmd to shellCmd & " --TVEpisodeNum " & quoted form of showEpisodeNum
				end if
			end if
			if not (showDescription = "") then
				set shellCmd to shellCmd & " --description " & quoted form of showDescription
			end if
			if not (showChannelCall = "") then
				set shellCmd to shellCmd & " --TVNetwork " & quoted form of showChannelCall
			end if
			set shellCmd to shellCmd & " --overWrite "
			my debug_log("Running: " & shellCmd)
			try
				set shellCmdResult to do shell script shellCmd
			end try
		else
			my debug_log("Not tagging with AtomicParsley, filename extension unknown: " & filenameExtension)
		end if
	end if
	
	tell window "iTiVo"
		if (complete = true) then
			set contents of text field "status" to "Finished at " & (current date)
		else
			set contents of text field "status" to "Couldn't Download " & oShowName & " - " & oShowEpisode
		end if
		set contents of text field "status2" to ""
		set visible of progress indicator "Status" to false
		set visible of control "StatusLevel" to false
		tell progress indicator "Status" to increment by -1 * currentProgress
		set title of button "ConnectButton" to "Update from TiVo"
		set enabled of button "CancelDownload" to false
		set historyCheck to first item of currentProcessSelectionParam & "-" & showID as string
		if (complete = true) then
			if historyCheck is not in DLHistory then
				set DLHistory to DLHistory & {historyCheck}
				my updateSubscriptionList(oShowName, oShowDate, false)
				my ConnectTiVo()
			end if
			if iTunes as integer > 0 then
				my debug_log("Doing iTunes-related work ")
				my create_playlist()
				my post_process_item(newFile, oShowName, oShowEpisode, showID, showDescription, showEpisodeNum, showEpisodeYear, showEpisodeGenre, showEpisodeLength)
			end if
		end if
	end tell
	
	if (complete = true and not postDownloadCmd = "") then
		try
			set shellCmd to ("file=" & my prepareCommand(newFile) as string) & "; "
			set shellCmd to shellCmd & "show=" & quoted form of oShowName & "; "
			set shellCmd to shellCmd & "episode=" & quoted form of showEpisode & "; "
			if isDownloadComplete(my prepareCommand(newFile) as string, fullFileSize, currentTry) then
				set shellCmd to shellCmd & "success=1; "
			else
				set shellCmd to shellCmd & "success=0; "
			end if
			set shellCmd to shellCmd & postDownloadCmd & " 2>&1"
			my debug_log("Running: " & shellCmd)
			try
				set shellCmdResult to do shell script shellCmd
				my debug_log("Result: " & shellCmdResult)
			on error
				my debug_log("Command Failed")
			end try
		end try
	end if
	if cancelDownload = 0 then
		set cancelDownload to 0
		return 1
	else
		set cancelDownload to 0
		return 2
	end if
end downloadItem

on downloadEncodeItem()
	tell window "iTiVo"
	end tell
end downloadEncodeItem

on roundThis(n, numDecimals)
	set x to 10 ^ numDecimals
	(((n * x) + 0.5) div 1) / x
end roundThis

on truncate(num)
	set truncatedInt to num as integer
	if (truncatedInt - num is greater than 0) then
		set truncatedInt to truncatedInt - 1
	end if
	return truncatedInt
end truncate

on prepareCommand(myPath)
	set encoded_text to ""
	set the URL_A_chars to " !$&*()|][;'\"?><`~{"
	repeat with this_char in myPath
		if this_char is in the URL_A_chars then
			set the encoded_text to (the encoded_text & "\\" & this_char)
		else
			set the encoded_text to (the encoded_text & this_char) as string
		end if
	end repeat
	return encoded_text
end prepareCommand

on minOSVers at reqVers
	set numList to characters of (reqVers as string)
	set decNum to 0
	repeat with num in numList
		set decNum to (16 * decNum) + num
	end repeat
	set sysv to (system attribute "sysv")
	if sysv < decNum then return false
	return true
end minOSVers

on ConnectTiVo()
	tell window "iTiVo"
		set contents of text field "status" to "Connecting..."
		update
		set myPath to my prepareCommand(POSIX path of (path to me))
		set ShellScriptCommand to "perl " & myPath & "Contents/Resources/ParseXML.pl " & (contents of text field "IP") & " " & MAK
		my debug_log(ShellScriptCommand)
		set TiVoList to do shell script ShellScriptCommand
	end tell
	if TiVoList = "" then
		if (MAK < 1) then
			display dialog "Your Media Access Key is not set correctly. (Select *Help* from the menu if you don't know how) " buttons {"OK"} default button "OK" attached to window "iTiVo"
			my displayPrefs()
		else
			display dialog "iTiVo could not communicate with your TiVo.  Please make sure your IP address and Media Access Key are correct (check your Prefs) and try again." buttons {"OK"} default button "OK" attached to window "iTiVo"
		end if
		set contents of text field "status" of window "iTiVo" to "Failed to connect to tivo!"
		return
	end if
	tell window "iTiVo"
		if TiVoList ≠ "" then
			set addedItems to {}
			set AppleScript's text item delimiters to return
			set the tivo_usage to text item 1 of TiVoList
			set the item_list to text items 2 thru -1 of TiVoList
			set AppleScript's text item delimiters to "|"
			-- First we parse out the usage information and set it in the drawer
			set total_memory to second text item of tivo_usage as integer
			if total_memory < (tivoSize * 1024) then
				set total_memory to tivoSize * 1024
			else
				my debug_log("updating TiVo's known HD space: " & tivoSize * 1024 & " , " & total_memory)
				set tivoSize to (total_memory / 1024) as integer
			end if
			set contents of text field "tivoName" of drawer "Drawer1" to title of popup button "MyTiVos"
			set contents of text field "tivoIP" of drawer "Drawer1" to IPA
			set contents of text field "tivoShows" of drawer "Drawer1" to first text item of tivo_usage
			set contents of text field "tivoSpace" of drawer "Drawer1" to tivoSize as string
			set contents of text field "tivoRegular" of drawer "Drawer1" to (((third text item of tivo_usage) as integer) as string) & " MB"
			set contents of text field "tivoSuggestion" of drawer "Drawer1" to (((fourth text item of tivo_usage) as integer) as string) & " MB"
			set contents of text field "tivoExpired" of drawer "Drawer1" to (((fifth text item of tivo_usage) as integer) as string) & " MB"
			set contents of text field "tivoExpiresSoon" of drawer "Drawer1" to (((sixth text item of tivo_usage) as integer) as string) & " MB"
			set contents of text field "tivoInProgress" of drawer "Drawer1" to (((seventh text item of tivo_usage) as integer) as string) & " MB"
			set contents of text field "tivoCopyrighted" of drawer "Drawer1" to (((eighth text item of tivo_usage) as integer) as string) & " MB"
			set contents of text field "tivoSaved" of drawer "Drawer1" to (((ninth text item of tivo_usage) as integer) as string) & " MB"
			set contents of text field "tivoTotal" of drawer "Drawer1" to (my roundThis((text item 2 of tivo_usage) / 1024, 2) as string) & " GB"
			set theURL to "http://chart.apis.google.com/chart?cht=p3&chs=180x180&chd=t:"
			set hd_sum to 0
			set per_sum to 0
			repeat with usage_item in text items 3 thru 9 of tivo_usage
				set hd_sum to hd_sum + usage_item
				set current_percent to my roundThis(usage_item / total_memory * 100, 1)
				set theURL to theURL & (current_percent as string) & ","
				set per_sum to per_sum + current_percent
			end repeat
			set hd_free to total_memory - hd_sum
			set contents of text field "tivoWiggle" of drawer "Drawer1" to (my roundThis((hd_free + (text item 4 of tivo_usage)) / 1024, 2) as string) & " GB"
			set theURL to theURL & (((100 - per_sum) as integer) as string)
			set myURL to "33CCFF|003300|FF3333|CC9900|33CC00|9900CC|00CC00|999999"
			set theURL to theURL & "&chco=" & my encode_text(myURL, true, true)
			set AppleScript's text item delimiters to ""
			my debug_log("fetching : " & theURL)
			set URLWithString to call method "URLWithString:" of class "NSURL" with parameter theURL
			set requestWithURL to call method "requestWithURL:" of class "NSURLRequest" with parameter URLWithString
			set mainFrame to call method "mainFrame" of object (view "tivoWeb" of drawer "Drawer1")
			call method "loadRequest:" of mainFrame with parameter requestWithURL
			
			-- Now we work on the actual shows
			set AppleScript's text item delimiters to "|"
			set showcount to 0
			set update views of targetData to false
			delete every data row of targetData
			repeat with currentLine in item_list
				set theDataRow to make new data row at end of data rows of targetData
				set the parts to every text item of currentLine
				if (count of parts) = 10 then
					set showName to item 2 of parts
					set episodeVal to item 3 of parts
					set showDate to item 4 of parts
					set showLength to item 5 of parts
					set showSize to (item 6 of parts & " MB")
					set showStation to item 7 of parts
					set showHD to item 8 of parts
					set showID to item 9 of parts
					set historyCheck to showName & "-" & showID
					set flags to item 10 of parts
					if historyCheck is in DLHistory then
						if flags = "1" then
							set downloadImage to suggestion_recording_check of tableImages
						else if flags = "2" then
							set downloadImage to expired_recording_check of tableImages
						else if flags = "3" then
							set downloadImage to expires_soon_recording_check of tableImages
						else if flags = "4" then
							set downloadImage to save_until_i_delete_recording_check of tableImages
						else
							set downloadImage to empty_check of tableImages
						end if
					else
						if flags = "1" then
							set downloadImage to suggestion_recording of tableImages
						else if flags = "2" then
							set downloadImage to expired_recording of tableImages
						else if flags = "3" then
							set downloadImage to expires_soon_recording of tableImages
						else if flags = "4" then
							set downloadImage to save_until_i_delete_recording of tableImages
						else
							set downloadImage to empty of tableImages
						end if
					end if
					if (flags = "5") then
						set showID to "copyright"
						set downloadImage to copyright of tableImages
					else
						if (my isSubscribed(showName, showDate) = true) then
							set currentProcessSelectionQ to {}
							set end of currentProcessSelectionQ to showName
							set end of currentProcessSelectionQ to episodeVal
							set end of currentProcessSelectionQ to showDate
							set end of currentProcessSelectionQ to showLength
							set end of currentProcessSelectionQ to showSize
							set end of currentProcessSelectionQ to showID
							my addSelectionToQueue(currentProcessSelectionQ)
							set end of addedItems to {showName, showDate}
						end if
					end if
					set contents of data cell "DLVal" of theDataRow to downloadImage
					set contents of data cell "ShowVal" of theDataRow to showName
					set contents of data cell "EpisodeVal" of theDataRow to episodeVal
					set contents of data cell "DateVal" of theDataRow to showDate
					set contents of data cell "LengthVal" of theDataRow to showLength
					set contents of data cell "SizeVal" of theDataRow to showSize
					set contents of data cell "ChannelVal" of theDataRow to showStation
					set contents of data cell "HDVal" of theDataRow to showHD
					set contents of data cell "IDVal" of theDataRow to showID
					set showcount to showcount + 1
				end if
			end repeat
			set AppleScript's text item delimiters to "|"
			set update views of targetData to true
			repeat with currentItem in addedItems
				my updateSubscriptionList(item 1 of currentItem, item 2 of currentItem, true)
			end repeat
			if (count of addedItems) > 0 then
				set enabled of button "decodeQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to true
			end if
			if showcount = 1 then
				set contents of text field "nowPlaying" of box "topBox" of split view "splitView1" to "Now Playing (1 item)"
			else
				set contents of text field "nowPlaying" of box "topBox" of split view "splitView1" to "Now Playing (" & showcount & " items)"
			end if
			set DLHistoryCount to (count of DLHistory)
			if (DLHistoryCount > showcount) then
				set DLHistoryTemp to items (DLHistoryCount - showcount) thru -1 of DLHistory
				set DLHistory to DLHistoryTemp
			end if
			set title of button "ConnectButton" to "Update from TiVo"
		end if
		set enabled of button "DownloadButton" of box "topBox" of split view "splitView1" to false
		set key equivalent of button "ConnectButton" to ""
		set contents of text field "status" to "Last Update : " & (current date)
	end tell
end ConnectTiVo

on shouldDownloadNow()
	my debug_log("Checking if should download: " & useTime & "   : " & time of useTimeStartTime & " : " & time of (current date) & " : " & time of useTimeEndTime)
	if (useTime = false) then
		return true
	else
		set starttime to time of useTimeStartTime
		set endTime to time of useTimeEndTime
		set curTime to time of (current date)
		if (endTime ≥ starttime) then
			if (curTime ≤ endTime and curTime ≥ starttime) then
				return true
			else
				return false
			end if
		else
			if (curTime ≥ starttime or curTime ≤ endTime) then
				return true
			else
				return false
			end if
		end if
	end if
end shouldDownloadNow


on create_playlist()
	set playlist_name to "TiVo Shows"
	tell application "iTunes"
		launch
		set all_playlists to the number of playlists
		set found to 0
		repeat with i from 1 to all_playlists
			set pl to the name of playlist i
			if pl = playlist_name then
				set found to 1
			end if
		end repeat
		if found is not 1 then
			set this_playlist to make new playlist
			set the name of this_playlist to the playlist_name
		end if
	end tell
end create_playlist


on generate_text_metadata(this_item, srcXML, xsltFile)
	set ShellScriptCommand to "/usr/bin/xsltproc " & quoted form of xsltFile & " " & quoted form of srcXML & " > " & quoted form of this_item
	my debug_log("Running: " & ShellScriptCommand)
	try
		set scriptResult to (do shell script ShellScriptCommand)
		my debug_log(scriptResult)
	on error
		my debug_log("Command Failed")
	end try
end generate_text_metadata

on post_process_item(this_item, show_name, episodeName, showID, file_description, episodeNum, episodeYear, episodeGenre, episodeLength)
	my debug_log("post Process item" & " " & this_item & " " & show_name & " " & episodeName & " " & showID & " " & file_description & " " & episodeNum & " " & episodeYear & " " & episodeGenre & " " & episodeLength)
	set prev_delim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ":"
	set the parts to every text item of episodeLength
	set episodeLength2 to (60 * ((first item of parts) as integer)) + ((second item of parts) as integer)
	set AppleScript's text item delimiters to prev_delim
	
	try
		set this_item2 to (this_item as string) as POSIX file
		tell application "Finder"
			set comment of this_item2 to (((show_name as string) & " - " & episodeName as string) & " - " & file_description as string)
		end tell
	end try
	try
		tell window "iTiVo"
			set contents of text field "status" to "Importing " & show_name & " into iTunes..."
			my debug_log("Importing " & show_name & " into iTunes...")
			update
		end tell
		tell application "iTunes"
			launch
			set this_track to add (POSIX file this_item as alias) to playlist "Library" of source "Library"
			duplicate this_track to playlist "TiVo Shows"
			if episodeName = "" and episodeNum = "" and episodeLength2 > 70 then
				set this_track's video kind to movie
				set the name of this_track to show_name
			else
				set this_track's video kind to TV show
				set this_track's album to show_name
				set this_track's album artist to show_name
				if (episodeName = "") then
					set the name of this_track to show_name & " - " & showID
					set this_track's episode ID to showID as string
				else
					set the name of this_track to episodeName
					set this_track's episode ID to episodeName as string
				end if
				if (not episodeNum = "") then
					set this_track's episode number to episodeNum as integer
				end if
			end if
			set this_track's comment to file_description as string
			set this_track's description to file_description as string
			set this_track's show to show_name as string
			set this_track's year to episodeYear as string
			set this_track's genre to episodeGenre as string
			if iTunesIcon = "Generic iTiVo" then
				set pict_item to path to me as string
				set pict_item to pict_item & "Contents:Resources:iTiVo.pict"
				set file_ref to open for access pict_item
				set ott to read file_ref from 513 as picture
				close access file_ref
				set data of artwork 1 of (this_track) to ott
				set ott to ""
			end if
		end tell
		my debug_log("itunes config done now syncing")
		if iTunesSync as integer > 0 then
			set contents of text field "status" of window "iTiVo" to "Initiating sync to all connected devices on iTunes..."
			tell application "iTunes"
				repeat with s in sources
					if (kind of s is iPod) then
						update s
					end if
				end repeat
			end tell
		end if
		my debug_log("done with itunes")
	end try
	set contents of text field "status" of window "iTiVo" to "Download of " & show_name & " completed at " & (current date)
end post_process_item

on performCancelDownload()
	set myPath to my prepareCommand(POSIX path of (path to me))
	try
		set result to do shell script "perl " & myPath & "Contents/Resources/killProcesses.pl ;exit 0"
		my debug_log("killed : " & result)
	end try
end performCancelDownload

on registerGrowl()
	set myAllNotesList to {"Beginning Download", "Ending Download"}
	tell application GrowlAppName
		using terms from application "GrowlHelperApp"
			register as application "iTiVo" all notifications myAllNotesList default notifications myAllNotesList icon of application "iTiVo"
		end using terms from
	end tell
end registerGrowl

on checkDL()
	my debug_log("checkDL")
	set FinderPath to (path to application "Finder") as string
	set prev_delim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ":"
	set the parts to every text item of FinderPath
	set the partsDL to every text item of ((DL as POSIX file) as string)
	set HDName to first item of parts
	set HDNameDL to first item of partsDL
	set AppleScript's text item delimiters to prev_delim
	
	set DLLocation2 to (HDName & (DL as string)) as POSIX file
	set DLLocation to (DL as POSIX file)
	
	tell application "Finder"
		set DLExists to exists folder (DLLocation as string)
		set DLExists2 to exists folder (DLLocation2 as string)
	end tell
	
	if not DLExists and not DLExists2 then
		display dialog "Your download location is not valid.  Please select a valid location." attached to window "iTiVo"
		my displayPrefs()
		return false
	else
		return true
	end if
end checkDL

on checkDLFile(showName)
	my debug_log("CheckDLFile")
	set FinderPath to (path to application "Finder") as string
	set prev_delim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ":"
	set the parts to every text item of FinderPath
	set the partsDL to every text item of ((DL as POSIX file) as string)
	set HDName to first item of parts
	set HDNameDL to first item of partsDL
	set AppleScript's text item delimiters to prev_delim
	
	set DLLocation2 to (HDName & (DL as string)) as POSIX file
	set DLLocation to (DL as POSIX file)
	
	set DFExists to false
	set DFExists2 to false
	tell application "Finder"
		if exists folder (DLLocation as string) then
			set DFExists to exists file showName in folder (DLLocation as string)
		else if exists folder (DLLocation2 as string) then
			if text 1 thru 1 of (DLLocation2 as string) = ":" then
				set DLLocation2 to ((text 2 thru -1 of (DLLocation2 as string)) as string)
			end if
			set DFExists2 to exists file showName in folder (DLLocation2 as string)
		end if
	end tell
	
	if DFExists or DFExists2 then
		set theReply to display dialog "The file already exists.  Would you like to overwrite?" buttons {"Yes", "No"} default button "Yes" --attached to window "iTiVo"
		if button returned of theReply = "Yes" then
			return false
		else
			return true
		end if
	else
		return false
	end if
end checkDLFile

on getCurrentFilesize(filePath)
	set myPath to my prepareCommand(POSIX path of (path to me))
	set myresult to (do shell script "perl " & myPath & "Contents/Resources/curlSize.pl")
	if myresult = "" then
		return "0"
	else
		return myresult
	end if
end getCurrentFilesize

on getcomskip()
	set myPath to my prepareCommand(POSIX path of (path to me))
	set myresult to (do shell script "perl " & myPath & "Contents/Resources/comskipSize.pl")
	if (myresult = "") then
		return {0, 0, "0:0:0"}
	else
		return {first word of myresult, second word of myresult, "" & third word of myresult & ":" & fourth word of myresult & ":" & fifth word of myresult}
	end if
end getcomskip

on getEncoderProgress(encoderUsed)
	set myPath to my prepareCommand(POSIX path of (path to me))
	set myresult to (do shell script "perl " & myPath & "Contents/Resources/encoderProgress.pl " & encoderUsed)
	if (myresult = "") then
		return {0, 0, 0}
	else
		return words in myresult
	end if
end getEncoderProgress

on updateSubscriptionList(nname, ndate, umissing)
	set newdate to my getDate(ndate)
	set rowCountS to count of data rows of data source 1 of table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo"
	set currentRow to 0
	set alreadyIn to false
	set processInfoRecord to {}
	repeat while currentRow < rowCountS
		set currentRow to currentRow + 1
		set currentProcessSelectionS2 to {}
		set currentProcessSelectionS to data row currentRow of data source 1 of table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo"
		set name2 to contents of (data cell "ShowVal" of currentProcessSelectionS)
		set date2 to contents of (data cell "LastDLVal" of currentProcessSelectionS)
		if (not name2 = nname) then
			set end of currentProcessSelectionS2 to name2
			set end of currentProcessSelectionS2 to date2
		else
			set alreadyIn to true
			set end of currentProcessSelectionS2 to name2
			if (newdate > date2) then
				set end of currentProcessSelectionS2 to newdate
			else
				set end of currentProcessSelectionS2 to date2
			end if
		end if
		set end of processInfoRecord to currentProcessSelectionS2
	end repeat
	if (alreadyIn = false and umissing = true) then
		set currentProcessSelectionS2 to {}
		set end of currentProcessSelectionS2 to nname
		set end of currentProcessSelectionS2 to newdate
		set end of processInfoRecord to currentProcessSelectionS2
	end if
	set content of targetDataS to processInfoRecord
	update table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo"
end updateSubscriptionList

on isSubscribed(name1, date1)
	set myDate to my getDate(date1)
	set rowCountS to count of data rows of data source 1 of table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo"
	set currentRow to 0
	repeat while currentRow < rowCountS
		set currentRow to currentRow + 1
		set currentProcessSelectionS to data row currentRow of data source 1 of table view "subscriptionListTable" of scroll view "subscriptionList" of view "bottomRightView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo"
		set name2 to contents of (data cell "ShowVal" of currentProcessSelectionS)
		if (name1 = name2) then
			set date2 to contents of (data cell "LastDLVal" of currentProcessSelectionS)
			if (date2 < myDate) then
				return true
			end if
		end if
	end repeat
	return false
end isSubscribed

on getDate(dateStr)
	set myDate to (current date)
	set tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "-"
	set the dateparts to every text item of dateStr
	set the year of myDate to first item of dateparts
	set the month of myDate to second item of dateparts
	set remaining to third item of dateparts
	set AppleScript's text item delimiters to " "
	set the dateparts to every text item of remaining
	set the day of myDate to first item of dateparts
	set remaining2 to second item of dateparts
	set AppleScript's text item delimiters to ":"
	set the dateparts to every text item of remaining2
	set the hours of myDate to first item of dateparts
	set the minutes of myDate to second item of dateparts
	set the seconds of myDate to 0
	set AppleScript's text item delimiters to tid
	return myDate
end getDate

on addSelectionToQueue(currentProcessSelection)
	set id1 to sixth item of currentProcessSelection
	set rowCountQ to count of data rows of data source 1 of table view "queueListTable" of scroll view "queueList" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo"
	set currentRow to 0
	set processInfoRecord to {}
	repeat while currentRow < rowCountQ
		set currentRow to currentRow + 1
		set currentProcessSelectionQ2 to {}
		set currentProcessSelectionQ to (data row currentRow of data source 1 of table view "queueListTable" of scroll view "queueList" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo")
		set id2 to contents of (data cell "IDVal" of currentProcessSelectionQ)
		if not id1 = id2 then
			set end of currentProcessSelectionQ2 to contents of (data cell "ShowVal" of currentProcessSelectionQ)
			set end of currentProcessSelectionQ2 to contents of (data cell "EpisodeVal" of currentProcessSelectionQ)
			set end of currentProcessSelectionQ2 to contents of (data cell "DateVal" of currentProcessSelectionQ)
			set end of currentProcessSelectionQ2 to contents of (data cell "LengthVal" of currentProcessSelectionQ)
			set end of currentProcessSelectionQ2 to contents of (data cell "SizeVal" of currentProcessSelectionQ)
			set end of currentProcessSelectionQ2 to contents of (data cell "IDVal" of currentProcessSelectionQ)
			set end of processInfoRecord to currentProcessSelectionQ2
		end if
	end repeat
	set end of processInfoRecord to currentProcessSelection
	set content of targetDataQ to processInfoRecord
	set queue_len to count of processInfoRecord
	if (count of processInfoRecord) = 1 then
		set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo" to "Download Queue (1 item)"
	else
		set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo" to "Download Queue (" & queue_len & " items)"
	end if
	update table view "queueListTable" of scroll view "queueList" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo"
	if (queue_len > 0) then
		my setDockTile(queue_len as string)
	else
		my setDockTile("")
	end if
end addSelectionToQueue

on isDownloadComplete(filePath, fullFileSize, tryCount)
	set currentSize to (my getCurrentFilesize(filePath) as real)
	if ((currentSize < (((fullFileSize * (1 - (0.25 * tryCount))) as real) - 5)) or (currentSize < 1 as real)) then
		return false
	else
		return true
	end if
end isDownloadComplete

on setDockTile(message)
	if (haveOS1050 = true) then
		set docktile to call method "dockTile" of class "NSApp"
		call method "setBadgeLabel:" of docktile with parameter message
	end if
end setDockTile

on growlIsRunning()
	tell application "System Events" to set myRunning to ((application processes whose (name is equal to "GrowlHelperApp")) count)
	my debug_log("growlisrun: " & myRunning)
	return (myRunning > 0)
end growlIsRunning

on debug_log(log_string)
	try
		if (debug_level ≤ 1) then
			set debug_file to "/dev/null"
		end if
		if (debug_level ≥ 1) then
			set debug_file to "/tmp/iTiVo-" & UserName & "/iTiVo.log"
			log log_string
		end if
		if (debug_level ≥ 2) then
			set theLine to (do shell script "date  +'%Y-%m-%d %H:%M:%S'" as string) & " " & quoted form of log_string
			do shell script "echo " & theLine & ">> " & debug_file
		end if
	on error
		log "Failed to output string :" & log_string
		set theLine to (do shell script "date  +'%Y-%m-%d %H:%M:%S'" as string) & " ERROR: Failing to output correct string"
		do shell script "echo '" & theLine & "' >> " & debug_file
	end try
end debug_log

on mouse down theObject event theEvent
	if option key down of theEvent then
		set cancelAllDownloads to 1
	else
		set cancelAllDownloads to 0
	end if
end mouse down

on idle
	if (installedIdleHandler = 0) then
		set installedIdleHandler to 900
		return installedIdleHandler
	end if
	if enabled of button "ConnectButton" of window "iTiVo" is true then
		my ConnectTiVo()
		if (my shouldDownloadNow()) then
			tell window "iTiVo"
				my debug_log("starting download")
				set enabled of button "decodeQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to true
				tell button "decodeQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to perform action
			end tell
		end if
	else
		my debug_log("probably downloading things right now")
	end if
	return installedIdleHandler
end idle

on should quit after last window closed theObject
	return true
end should quit after last window closed

on should close theObject
	if name of theObject = "iTiVo" then
		tell application "System Events" to set visible of process "iTiVo" to false
		return false
	end if
	return true
end should close

on end editing theObject
	if name of theObject = "tivoSpace" then
		set tivoSize to contents of text field "tivoSpace" of drawer "Drawer1" of window "iTiVo"
		if enabled of button "ConnectButton" of window "iTiVo" is true then
			my ConnectTiVo()
		end if
	end if
end end editing
