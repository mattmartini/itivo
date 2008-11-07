-- iTiVo.applescript
-- iTiVo

--  Created by David Benesch on 12/03/06.
--  Last updated by Yoav Yerushalmi on 11/09/08.
--  Copyright 2006-2007 David Benesch. All rights reserved.
property debug_level : 0
property already_launched : 0
property filenameExtension : ".mp4"
property targetData : missing value
property targetDataQ : missing value
property targetDataS : missing value
property targetDataSList : {}
property IPA : ""
property LaunchCount : 0
property currentProgress : 0
property autoConnect : 0
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
property customHeight : 480
property customWidth : 640
property customAudioBR : 128
property customVideoBR : 512
property openDetail : 1
property DLHistory : {}
property GrowlAppName : ""
property encodeMode : 0
property UserName : ""

(* User-controlled properties *)
property MAK : ""
property DL : ""
property iTunes : ""
property iTunesSync : ""
property iTunesIcon : ""
property format : ""
property postDownloadCmd : ""
property comSkip : 0
property SUFeedURL : "http://itivo.googlecode.com/svn/trunk/www/iTiVo.xml"
property debugLog : false

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
end awake from nib

on will open theObject
	if name of theObject is "iTiVo" and already_launched = 0 then
		my debug_log("     ================    Starting   ===================")
		getTiVos()
		update
		readSettings()
		set already_launched to 1
		set UserName to do shell script "whoami"
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
	if not haveOS1040 then
		display dialog "This Application requires Mac OS X 10.4 or later." buttons {"OK"} default button "OK" attached to window "iTiVo"
		quit
	end if
	performCancelDownload()
	registerSettings()
end will finish launching

on launched theObject
	if LaunchCount > 10 or LaunchCount ≤ 0 then
		display dialog "This is a very alpha program.  For an officially supported program, check http://www.roxio.com/   *Do not distribute copyrighted material*" buttons {"OK"} default button "OK" attached to window "iTiVo"
		set LaunchCount to 0
	end if
	set LaunchCount to LaunchCount + 1
	setSettingsInUI()
	if autoConnect = 1 then
		my ConnectTiVo()
	end if
	if openDetail = 1 then
		switchDrawer2()
	end if
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

on showResSettings()
	tell view "DownloadingView" of tab view "TopTab" of panelWIndow
		set visible of text field "customWidth" to true
		set visible of text field "customHeight" to true
		set visible of text field "customVideoBR" to true
		set visible of text field "customAudioBR" to true
		set visible of text field "title1" to true
		set visible of text field "title2" to true
		set visible of text field "title3" to true
		set visible of text field "title4" to true
		set visible of text field "title5" to true
		set visible of text field "title6" to true
	end tell
end showResSettings

on hideResSettings()
	tell view "DownloadingView" of tab view "TopTab" of panelWIndow
		set visible of text field "customWidth" to false
		set visible of text field "customHeight" to false
		set visible of text field "customVideoBR" to false
		set visible of text field "customAudioBR" to false
		set visible of text field "title1" to false
		set visible of text field "title2" to false
		set visible of text field "title3" to false
		set visible of text field "title4" to false
		set visible of text field "title5" to false
		set visible of text field "title6" to false
	end tell
end hideResSettings


on formatCompatItunes(formatName)
	if (formatName = "No Conversion (native MPEG-2)") then
		return false
	else if (formatName = "iPod/iPhone super-res") then
		return true
	else if (formatName = "iPhone") then
		return true
	else if (formatName = "iPod") then
		return true
	else if (formatName = "Zune") then
		return true
	else if (formatName = "AppleTV") then
		return true
	else if (formatName = "PSP") then
		return false
	else if (formatName = "PS3") then
		return false
	else if (formatName = "DVD (NTSC mpeg-2 AC3)") then
		return false
	else if (formatName = "DVD (PAL mpeg-2 AC3)") then
		return false
	else if (formatName = "Quicktime MPEG-4 (Custom)") then
		return true
	else
		return false
	end if
end formatCompatItunes

on setupPrefsTab(tabName)
	tell panelWIndow
		if (tabName = "DownloadingTab") then
			set contents of text field "MAK" of view "DownloadingView" of tab view "TopTab" to MAK
			set contents of text field "Location" of view "DownloadingView" of tab view "TopTab" to DL
			set formats to title of every menu item of popup button "format" of view "DownloadingView" of tab view "TopTab"
			if format is in formats then
				set title of popup button "format" of view "DownloadingView" of tab view "TopTab" to format
			else
				set title of popup button "format" of view "DownloadingView" of tab view "TopTab" to first item of formats
				set format to title of popup button "format" of view "DownloadingView" of tab view "TopTab"
			end if
			if (format = "Quicktime MPEG-4 (Custom)") then
				my showResSettings()
			else
				my hideResSettings()
			end if
			set contents of text field "customWidth" of view "DownloadingView" of tab view "TopTab" to customWidth
			set contents of text field "customHeight" of view "DownloadingView" of tab view "TopTab" to customHeight
			set contents of text field "customAudioBR" of view "DownloadingView" of tab view "TopTab" to customAudioBR
			set contents of text field "customVideoBR" of view "DownloadingView" of tab view "TopTab" to customVideoBR
			
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
		else if (tabName = "ComSkipTab") then
			if (format = "No Conversion (native MPEG-2)") then
				set comSkip to 0
				set enabled of button "comSkip" of view "comSkipView" of tab view "TopTab" to false
			else
				set enabled of button "comSkip" of view "comSkipView" of tab view "TopTab" to true
			end if
			set state of button "comSkip" of view "comSkipView" of tab view "TopTab" to comSkip
		else if (tabName = "AdvancedTab") then
			set contents of text field "postDownloadCmd" of view "AdvancedView" of tab view "TopTab" to postDownloadCmd
			if (SUFeedURL = "http://itivo.googlecode.com/svn/trunk/www/iTiVo-beta.xml") then
				set state of button "betaUpdate" of view "AdvancedView" of tab view "TopTab" to true
			else
				set state of button "betaUpdate" of view "AdvancedView" of tab view "TopTab" to false
			end if
			set state of button "debugLog" of view "AdvancedView" of tab view "TopTab" to debugLog
		else
			my debug_log("Can't setup PrefsTab for " & tabName)
		end if
	end tell
end setupPrefsTab

on recordPrefsTab()
	tell panelWIndow
		if (currentPrefsTab = "DownloadingTab") then
			set MAK to contents of text field "MAK" of view "DownloadingView" of tab view "TopTab"
			set DL to contents of text field "Location" of view "DownloadingView" of tab view "TopTab"
			set format to title of popup button "format" of view "DownloadingView" of tab view "TopTab"
			set customWidth to contents of text field "customWidth" of view "DownloadingView" of tab view "TopTab"
			set customHeight to contents of text field "customHeight" of view "DownloadingView" of tab view "TopTab"
			set customAudioBR to contents of text field "customAudioBR" of view "DownloadingView" of tab view "TopTab"
			set customVideoBR to contents of text field "customVideoBR" of view "DownloadingView" of tab view "TopTab"
			set iTunes to state of button "iTunes" of view "DownloadingView" of tab view "TopTab"
			set iTunesSync to state of button "iTunesSync" of view "DownloadingView" of tab view "TopTab"
			set iTunesIcon to title of popup button "icon" of view "DownloadingView" of tab view "TopTab"
		else if (currentPrefsTab = "ComSkipTab") then
			set comSkip to state of button "comSkip" of view "comSkipView" of tab view "TopTab"
		else if (currentPrefsTab = "AdvancedTab") then
			set postDownloadCmd to contents of text field "postDownloadCmd" of view "AdvancedView" of tab view "TopTab"
			set debugLog to state of button "debugLog" of view "AdvancedView" of tab view "TopTab" as boolean
			if (debugLog is true) then
				set debug_level to 3
			end if
			if (state of button "betaUpdate" of view "AdvancedView" of tab view "TopTab" = 1) then
				set SUFeedURL to "http://itivo.googlecode.com/svn/trunk/www/iTiVo-beta.xml"
			else
				set SUFeedURL to "http://itivo.googlecode.com/svn/trunk/www/iTiVo.xml"
			end if
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


on switchDrawer2()
	tell window "iTiVo"
		if state of drawer "Drawer2" is drawer closed then
			tell drawer "Drawer2" to open drawer on right edge
			set state of button "detailButton" to false
			set openDetail to 1
		else
			tell drawer "Drawer2" to close drawer
			set state of button "detailButton" to true
			set openDetail to 0
		end if
	end tell
end switchDrawer2

on registerSettings()
	tell user defaults
		make new default entry at end of default entries with properties {name:"IPA", contents:IPA}
		make new default entry at end of default entries with properties {name:"MAK", contents:MAK}
		make new default entry at end of default entries with properties {name:"DL", contents:""}
		make new default entry at end of default entries with properties {name:"LaunchCount", contents:""}
		make new default entry at end of default entries with properties {name:"TiVo", contents:""}
		make new default entry at end of default entries with properties {name:"format", contents:""}
		make new default entry at end of default entries with properties {name:"iTunes", contents:""}
		make new default entry at end of default entries with properties {name:"iTunesSync", contents:""}
		make new default entry at end of default entries with properties {name:"iTunesIcon", contents:""}
		make new default entry at end of default entries with properties {name:"customWidth", contents:""}
		make new default entry at end of default entries with properties {name:"customHeight", contents:""}
		make new default entry at end of default entries with properties {name:"customAudioBR", contents:""}
		make new default entry at end of default entries with properties {name:"customVideoBR", contents:""}
		make new default entry at end of default entries with properties {name:"comSkip", contents:comSkip}
		make new default entry at end of default entries with properties {name:"postDownloadCmd", contents:postDownloadCmd}
		make new default entry at end of default entries with properties {name:"debugLog", contents:debugLog}
		make new default entry at end of default entries with properties {name:"SUFeedURL", contents:SUFeedURL}
		make new default entry at end of default entries with properties {name:"openDetail", contents:""}
		make new default entry at end of default entries with properties {name:"DLHistory", contents:""}
		make new default entry at end of default entries with properties {name:"targetDataSList", contents:{}}
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
			set customWidth to contents of default entry "customWidth"
			set customHeight to contents of default entry "customHeight"
			set customAudioBR to contents of default entry "customAudioBR"
			set customVideoBR to contents of default entry "customVideoBR"
			set SUFeedURL to contents of default entry "SUFeedURL"
			set openDetail to contents of default entry "openDetail"
			set DLHistory to contents of default entry "DLHistory"
			set targetDataSList to contents of default entry "targetDataSList"
			set comSkip to contents of default entry "comSkip"
			set postDownloadCmd to contents of default entry "postDownloadCmd"
		end try
		try
			set debugLog to contents of default entry "debugLog"
			if (debugLog = true) then
				set debug_level to 3
			end if
		end try
	end tell
	try
		tell application "Finder" to set GrowlAppName to name of application file id "com.Growl.GrowlHelperApp"
	end try
	if GrowlAppName = "GrowlHelperApp.app" then
		try
			my registerGrowl()
		on error
			my debug_log("Failed to register growl")
			set GrowlAppName to ""
		end try
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
							set autoConnect to 1
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
			set contents of default entry "LaunchCount" to (LaunchCount as integer)
			set contents of default entry "TiVo" to TiVo as string
			set contents of default entry "format" to format as string
			set contents of default entry "iTunes" to iTunes as string
			set contents of default entry "iTunesSync" to iTunesSync as string
			set contents of default entry "iTunesIcon" to iTunesIcon as string
			set contents of default entry "customWidth" to customWidth as string
			set contents of default entry "customHeight" to customHeight as string
			set contents of default entry "customVideoBR" to customVideoBR as string
			set contents of default entry "customAudioBR" to customAudioBR as string
			set contents of default entry "comSkip" to comSkip
			set contents of default entry "postDownloadCmd" to postDownloadCmd
			set contents of default entry "SUFeedURL" to SUFeedURL
			set contents of default entry "openDetail" to (openDetail as integer)
			set contents of default entry "DLHistory" to DLHistory as list
			set contents of default entry "targetDataSList" to targetDataSList as list
			set contents of default entry "debugLog" to debugLog
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
			my switchDrawer2()
		else if theObjectName = "locationButton" then
			set DL to POSIX path of (choose folder)
			tell panelWIndow
				set contents of text field "Location" of view "DownloadingView" of tab view "TopTab" to DL
			end tell
		else if theObjectName = "CancelDownload" then
			set cancelDownload to 1
			set enabled of button "CancelDownload" to false
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
			if (count of processInfoRecord) = 1 then
				set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to "Download Queue (1 item)"
			else
				set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to "Download Queue (" & (count of processInfoRecord) & " items)"
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
				--set end of currentProcessSelectionQ2 to contents of (data cell "DescriptionVal" of currentProcessSelectionQ)
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
					set shellCmd to "rm /tmp/iTiVoDL*-" & UserName
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
					if (count of processInfoRecord) = 1 then
						set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to "Download Queue (1 item)"
					else
						set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to "Download Queue (" & (count of processInfoRecord) & " items)"
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
				--set end of currentProcessSelection to contents of (data cell "DescriptionVal" of currentProcessSelectionTEMP)
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
		end if
	end tell
	set AppleScript's text item delimiters to ""
end clicked

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
				if rowCount > 1 then
					set contents of text field "detailTitle" of drawer "Drawer2" to "Multiple shows selected"
					set contents of text field "detailTime" of drawer "Drawer2" to ""
					set contents of text field "detailDescription" of drawer "Drawer2" to ""
					set contents of text field "detailQuality" of drawer "Drawer2" to ""
					set contents of text field "detailGenre" of drawer "Drawer2" to ""
					set contents of text field "detailChannel" of drawer "Drawer2" to ""
					set contents of text field "detailActors" of drawer "Drawer2" to ""
					set contents of text field "detailRating" of drawer "Drawer2" to ""
					set contents of text field "detailEpisode" of drawer "Drawer2" to ""
					set contents of text field "detailDate" of drawer "Drawer2" to ""
				else if rowCount = 1 then
					set currentProcessSelectionTEMP to item 1 of currentProcessSelectionsTEMP
					set id to contents of (data cell "IDVal" of currentProcessSelectionTEMP)
					set myPath to my prepareCommand(POSIX path of (path to me))
					set ShellScriptCommand to "perl " & myPath & "Contents/Resources/ParseDetail.pl " & IPA & " " & MAK & " " & id
					my debug_log(ShellScriptCommand)
					set item_list to do shell script ShellScriptCommand
					set AppleScript's text item delimiters to "|"
					set the parts to every text item of item_list
					if (count of parts) = 14 then
						set contents of text field "detailTitle" of drawer "Drawer2" to item 2 of parts
						set contents of text field "detailTime" of drawer "Drawer2" to item 7 of parts
						set contents of text field "detailDescription" of drawer "Drawer2" to item 4 of parts
						set contents of text field "detailQuality" of drawer "Drawer2" to item 6 of parts
						set contents of text field "detailGenre" of drawer "Drawer2" to item 8 of parts
						set contents of text field "detailChannel" of drawer "Drawer2" to item 9 of parts
						set contents of text field "detailActors" of drawer "Drawer2" to item 10 of parts
						set contents of text field "detailRating" of drawer "Drawer2" to item 11 of parts
						set contents of text field "detailEpisode" of drawer "Drawer2" to item 3 of parts
						set contents of text field "detailDate" of drawer "Drawer2" to item 12 of parts
					else
						set contents of text field "detailTitle" of drawer "Drawer2" to ""
						set contents of text field "detailTime" of drawer "Drawer2" to ""
						set contents of text field "detailDescription" of drawer "Drawer2" to ""
						set contents of text field "detailQuality" of drawer "Drawer2" to ""
						set contents of text field "detailGenre" of drawer "Drawer2" to ""
						set contents of text field "detailChannel" of drawer "Drawer2" to ""
						set contents of text field "detailActors" of drawer "Drawer2" to ""
						set contents of text field "detailRating" of drawer "Drawer2" to ""
						set contents of text field "detailEpisode" of drawer "Drawer2" to ""
						set contents of text field "detailDate" of drawer "Drawer2" to ""
					end if
				else
					set contents of text field "detailTitle" of drawer "Drawer2" to ""
					set contents of text field "detailTime" of drawer "Drawer2" to ""
					set contents of text field "detailDescription" of drawer "Drawer2" to ""
					set contents of text field "detailQuality" of drawer "Drawer2" to ""
					set contents of text field "detailGenre" of drawer "Drawer2" to ""
					set contents of text field "detailChannel" of drawer "Drawer2" to ""
					set contents of text field "detailActors" of drawer "Drawer2" to ""
					set contents of text field "detailRating" of drawer "Drawer2" to ""
					set contents of text field "detailEpisode" of drawer "Drawer2" to ""
					set contents of text field "detailDate" of drawer "Drawer2" to ""
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
				if rowCount > 1 then
					set contents of text field "detailTitle" of drawer "Drawer2" to "Multiple shows selected"
					set contents of text field "detailTime" of drawer "Drawer2" to ""
					set contents of text field "detailDescription" of drawer "Drawer2" to ""
					set contents of text field "detailQuality" of drawer "Drawer2" to ""
					set contents of text field "detailGenre" of drawer "Drawer2" to ""
					set contents of text field "detailChannel" of drawer "Drawer2" to ""
					set contents of text field "detailActors" of drawer "Drawer2" to ""
					set contents of text field "detailRating" of drawer "Drawer2" to ""
					set contents of text field "detailEpisode" of drawer "Drawer2" to ""
					set contents of text field "detailDate" of drawer "Drawer2" to ""
				else if rowCount = 1 then
					set currentProcessSelectionTEMP to item 1 of currentProcessSelectionsTEMP
					set id to contents of (data cell "IDVal" of currentProcessSelectionTEMP)
					set myPath to my prepareCommand(POSIX path of (path to me))
					set ShellScriptCommand to "perl " & myPath & "Contents/Resources/ParseDetail.pl " & IPA & " " & MAK & " " & id
					my debug_log(ShellScriptCommand)
					set item_list to do shell script ShellScriptCommand
					set AppleScript's text item delimiters to "|"
					set the parts to every text item of item_list
					if (count of parts) = 14 then
						set contents of text field "detailTitle" of drawer "Drawer2" to item 2 of parts
						set contents of text field "detailTime" of drawer "Drawer2" to item 7 of parts
						set contents of text field "detailDescription" of drawer "Drawer2" to item 4 of parts
						set contents of text field "detailQuality" of drawer "Drawer2" to item 6 of parts
						set contents of text field "detailGenre" of drawer "Drawer2" to item 8 of parts
						set contents of text field "detailChannel" of drawer "Drawer2" to item 9 of parts
						set contents of text field "detailActors" of drawer "Drawer2" to item 10 of parts
						set contents of text field "detailRating" of drawer "Drawer2" to item 11 of parts
						set contents of text field "detailEpisode" of drawer "Drawer2" to item 3 of parts
						set contents of text field "detailDate" of drawer "Drawer2" to item 12 of parts
					else
						set contents of text field "detailTitle" of drawer "Drawer2" to ""
						set contents of text field "detailTime" of drawer "Drawer2" to ""
						set contents of text field "detailDescription" of drawer "Drawer2" to ""
						set contents of text field "detailQuality" of drawer "Drawer2" to ""
						set contents of text field "detailGenre" of drawer "Drawer2" to ""
						set contents of text field "detailChannel" of drawer "Drawer2" to ""
						set contents of text field "detailActors" of drawer "Drawer2" to ""
						set contents of text field "detailRating" of drawer "Drawer2" to ""
						set contents of text field "detailEpisode" of drawer "Drawer2" to ""
						set contents of text field "detailDate" of drawer "Drawer2" to ""
					end if
				else
					set contents of text field "detailTitle" of drawer "Drawer2" to ""
					set contents of text field "detailTime" of drawer "Drawer2" to ""
					set contents of text field "detailDescription" of drawer "Drawer2" to ""
					set contents of text field "detailQuality" of drawer "Drawer2" to ""
					set contents of text field "detailGenre" of drawer "Drawer2" to ""
					set contents of text field "detailChannel" of drawer "Drawer2" to ""
					set contents of text field "detailActors" of drawer "Drawer2" to ""
					set contents of text field "detailRating" of drawer "Drawer2" to ""
					set contents of text field "detailEpisode" of drawer "Drawer2" to ""
					set contents of text field "detailDate" of drawer "Drawer2" to ""
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
		if (myformat = "Quicktime MPEG-4 (Custom)") then
			my showResSettings()
		else
			my hideResSettings()
		end if
		if (myformat = "No Conversion (native MPEG-2)") then
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
				on error
					display dialog "Unable to connect to TiVo " & title of theObject & ".  It is no longer available on your network."
				end try
			end tell
		end if
	end if
end choose menu item

on changed theObject
	if name of theObject = "customWidth" then
		try
			set customWidth to content of theObject as integer
		on error
			set content of theObject to customWidth
		end try
	else if name of theObject = "customHeight" then
		try
			set customHeight to content of theObject as integer
		on error
			set content of theObject to customHeight
		end try
	else if name of theObject = "customAudioBR" then
		try
			set customAudioBR to content of theObject as integer
		on error
			set content of theObject to customAudioBR
		end try
	else if name of theObject = "customVideoBR" then
		try
			set customVideoBR to content of theObject as integer
		on error
			set content of theObject to customVideoBR
		end try
	else if name of theObject = "IP" then
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
		set id to item 5 of currentProcessSelectionParam
		set showName to first item of currentProcessSelectionParam
		set oShowName to showName
		set oShowDate to third item of currentProcessSelectionParam
		set showNameEncoded to my encode_text(my prepareCommand(showName), true, true)
		if second item of currentProcessSelectionParam ≠ "" then
			set oShowEpisode to second item of currentProcessSelectionParam
		else
			set oShowEpisode to id as string
		end if
		set showName to showName & " - " & oShowEpisode
		set showFullNameEncoded to my encode_text(my prepareCommand(showName), true, true)
		set myHomePathP2 to my encode_text(my prepareCommand(DL), true, true)
		set myPath2 to my encode_text(myPath, true, true)
		set ShellScriptCommand to "perl " & myPath & "Contents/Resources/ParseDetail.pl " & IPA & " " & MAK & " " & id
		my debug_log(ShellScriptCommand)
		set item_list to do shell script ShellScriptCommand
		set AppleScript's text item delimiters to "|"
		set the parts to every text item of item_list
		set showLength to seventh item of parts
		set fullFileSize to fourth item of currentProcessSelectionParam
		set fullFileSize to (first word of fullFileSize as integer)
		set showName to my replace_chars(showName, ":", "-")
		set showNameP to my replace_chars(showName, "/", ":")
		set showNameCheck to showName & filenameExtension
		set filePath to (my prepareCommand(DL & showNameP & filenameExtension) as string)
		if (overrideDLCheck < 1) then
			if my checkDLFile(showNameCheck) then
				return 0
			end if
		end if
	end tell
	set currentTry to 0
	my performCancelDownload()
	if format = "No Conversion (native MPEG-2)" then
		set encodeMode to 0
		set filenameExtension to ".mpg"
	else if format = "iPod/iPhone super-res" then
		set encodeMode to 1
		set filenameExtension to ".mp4"
	else if format = "iPhone" then
		set encodeMode to 2
		set filenameExtension to ".mp4"
	else if format = "iPod" then
		set encodeMode to 3
		set filenameExtension to ".mp4"
	else if format = "Zune" then
		set encodeMode to 4
		set filenameExtension to ".mp4"
	else if format = "AppleTV" then
		set encodeMode to 5
		set filenameExtension to ".mp4"
	else if format = "PSP" then
		set encodeMode to 6
		set filenameExtension to ".mp4"
	else if format = "PS3" then
		set encodeMode to 7
		set filenameExtension to ".mp4"
	else if format = "DVD (NTSC mpeg-2 AC3)" then
		set encodeMode to 8
		set filenameExtension to ".mpg"
	else if format = "DVD (PAL mpeg-2 AC3)" then
		set encodeMode to 9
		set filenameExtension to ".mpg"
	else if format = "Quicktime MPEG-4 (Custom)" then
		set encodeMode to 10
		set filenameExtension to ".mp4"
	else
		set format to "No Conversion (native MPEG-2)"
		set encodeMode to 0
		set filenameExtension to ".mpg"
	end if
	try
		set shellCmd to "rm /tmp/iTiVoDL*-" & UserName
		do shell script shellCmd
	end try
	set cancelDownload to 0
	set timeRemaining to 0
	repeat while ((not (my isDownloadComplete(filePath, fullFileSize, currentTry) and (timeRemaining ≤ 5 * (retryCount + 1)))) and currentTry < retryCount and cancelDownload = 0)
		tell window "iTiVo"
			try
				set shellCmd to "rm /tmp/iTiVoDLPipe*-" & UserName & "*"
				my debug_log(shellCmd)
				do shell script shellCmd
			end try
			if (comSkip = 0) then
				set shellCmd to "mkfifo /tmp/iTiVoDLPipe-" & UserName & " /tmp/iTiVoDLPipe2-" & UserName & ".mpg"
			else
				set shellCmd to "mkfifo /tmp/iTiVoDLPipe-" & UserName & " ; touch /tmp/iTiVoDLPipe{2,3}-" & UserName & ".mpg"
			end if
			my debug_log(shellCmd)
			do shell script shellCmd
			set ShellScriptCommand to "perl " & myPath & "Contents/Resources/http-fetcher.pl " & IPA & " " & id & " " & showNameEncoded & " " & MAK & " /tmp/iTiVoDLPipe-" & UserName
			set ShellScriptCommand to ShellScriptCommand & " &> /dev/null & echo $! ;exit 0"
			my debug_log(ShellScriptCommand)
			do shell script ShellScriptCommand
			set ShellScriptCommand to "perl " & myPath & "Contents/Resources/tivo-decoder.pl " & myPath2 & " " & MAK
			set ShellScriptCommand to ShellScriptCommand & " &> /dev/null & echo $! ;exit 0"
			my debug_log(ShellScriptCommand)
			do shell script ShellScriptCommand
			if (comSkip = 0) then
				set ShellScriptCommand to "perl " & myPath & "Contents/Resources/re-encoder.pl " & myPath2 & " " & myHomePathP2 & " " & showFullNameEncoded & filenameExtension & " " & encodeMode & " " & customWidth & " " & customHeight & " " & customVideoBR & " " & customAudioBR
				set ShellScriptCommand to ShellScriptCommand & " &> /dev/null & echo $! ;exit 0"
				my debug_log(ShellScriptCommand)
				do shell script ShellScriptCommand
			end if
			set currentFileSize to 0
			set progressDifference to -1 * currentProgress
			tell progress indicator "Status" to increment by progressDifference
			set progressDifference to 0
			set contents of text field "status" to "Downloading " & first item of currentProcessSelectionParam & " - " & second item of currentProcessSelectionParam
			set currentFileSize to 0
			set prevFileSize to 0
			set timeoutCount to 0
			set downloadExistsCmdString to "du -k -d 0 /tmp/iTiVoDLPipe-" & UserName & " ;exit 0"
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
" & (item 1 of currentProcessSelectionParam) description (item 2 of currentProcessSelectionParam) application name "iTiVo"
						else
							notify with name "Beginning Download" title "Downloading 
" & (item 1 of currentProcessSelectionParam) description (item 2 of currentProcessSelectionParam) application name "iTiVo"
						end if
					end using terms from
				end tell
			end try
		end if
		set currentTry to currentTry + 1
		tell window "iTiVo"
			set ETA to ""
			set visible of progress indicator "Status" to true
			set starttime to ((do shell script "date +%s") as integer) - 10
			repeat while timeoutCount < 480 and cancelDownload as integer = 0 and downloadExists as integer = 1 and cancelAllDownloads as integer = 0
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
					set contents of text field "status" to "Downloading " & first item of currentProcessSelectionParam & " - " & second item of currentProcessSelectionParam
				else
					set timeoutCount to timeoutCount + 1
					if timeoutCount = 20 then
						set contents of text field "status" to "Downloading " & first item of currentProcessSelectionParam & " (waiting for TiVo)"
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
			if (my isDownloadComplete(filePath, fullFileSize, currentTry) and comSkip = 1) then
				tell progress indicator "Status" to increment by -1 * currentProgress
				set currentProgresss to 0
				set downloadExistsCmdString to "du -k -d 0 /tmp/iTiVoDLPipe3-" & UserName & ".mpg ;exit 0"
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
				set visible of progress indicator "Status" to true
				set ShellScriptCommand to "perl " & myPath & "Contents/Resources/remove-commercials.pl " & myPath2
				set ShellScriptCommand to ShellScriptCommand & " &> /dev/null & echo $! ;exit 0"
				my debug_log(ShellScriptCommand)
				do shell script ShellScriptCommand
				repeat while timeoutCount < 120 and cancelDownload as integer = 0 and downloadExists as integer = 1 and cancelAllDownloads as integer = 0
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
						set contents of text field "status" to "Commercial Skip " & first item of currentProcessSelectionParam & " - " & second item of currentProcessSelectionParam
					else
						set timeoutCount to timeoutCount + 1
						if timeoutCount = 20 then
							set contents of text field "status" to "Commercial Skip " & first item of currentProcessSelectionParam & " (stalled)"
						end if
					end if
					try
						set progressDifference to currentPercent - currentProgress
						tell progress indicator "Status" to increment by progressDifference
						set currentProgress to currentPercent as integer
						if currentProgress > 100 then
							set currentProgress to 100
						end if
						set contents of text field "status2" to ((timeOn as string) & " processed      (" & (100 - currentPercent) as string) & "% remaining)"
					end try
					delay 0.5
				end repeat
				tell progress indicator "Status" to increment by -1 * currentProgress
				set currentProgresss to 0
				set downloadExistsCmdString to "du -k -d 0 /tmp/iTiVoDLPipe2-" & UserName & ".mpg ;exit 0"
				set timeoutCount to 0
				set downloadExists to 1
				set currentPercent to 0
				set timeOn to 0.0
				set prevtimeOn to 0
				set visible of progress indicator "Status" to true
				set ShellScriptCommand to "perl " & myPath & "Contents/Resources/re-encoder.pl " & myPath2 & " " & myHomePathP2 & " " & showFullNameEncoded & filenameExtension & " " & encodeMode & " " & customWidth & " " & customHeight & " " & customVideoBR & " " & customAudioBR
				set ShellScriptCommand to ShellScriptCommand & " &> /dev/null & echo $! ;exit 0"
				my debug_log(ShellScriptCommand)
				do shell script ShellScriptCommand
				repeat while timeoutCount < 120 and cancelDownload as integer = 0 and downloadExists as integer = 1 and cancelAllDownloads as integer = 0
					if (debug_level ≥ 3) then
						my debug_log("mencoder timeout: " & timeoutCount & " download:" & downloadExists & "   timeRemaining: " & timeRemaining & "  timeOn:" & timeOn & "   currentPercent: " & currentPercent)
					end if
					set {timeOn, currentPercent, timeRemaining} to my getmencoder()
					set downloadExistsCmd to do shell script downloadExistsCmdString
					if downloadExistsCmd is not equal to "" then
						set downloadExists to 1
					else
						set downloadExists to 0
					end if
					if timeOn as real > prevtimeOn as real then
						set prevtimeOn to timeOn
						set timeoutCount to 0
						set contents of text field "status" to "Encoding " & first item of currentProcessSelectionParam & " - " & second item of currentProcessSelectionParam
					else
						set timeoutCount to timeoutCount + 1
						if timeoutCount = 20 then
							set contents of text field "status" to "Encoding " & first item of currentProcessSelectionParam & " (waiting)"
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
			end if
		end tell
		my performCancelDownload()
		my debug_log("Download completed")
		if GrowlAppName = "GrowlHelperApp.app" then
			try
				tell application GrowlAppName
					using terms from application "GrowlHelperApp"
						if (my isDownloadComplete(filePath, fullFileSize, currentTry)) then
							notify with name "Ending Download" title "Finished
" & (item 1 of currentProcessSelectionParam as string) description (item 2 of currentProcessSelectionParam as string) application name "iTiVo"
						else
							notify with name "Ending Download" title "Incomplete Download!
" & (item 1 of currentProcessSelectionParam as string) description (item 2 of currentProcessSelectionParam as string) application name "iTiVo"
						end if
					end using terms from
				end tell
			end try
		end if
	end repeat
	tell window "iTiVo"
		set contents of text field "status" to "Finished at " & (current date)
		set contents of text field "status2" to ""
		set visible of progress indicator "Status" to false
		tell progress indicator "Status" to increment by -1 * currentProgress
		set title of button "ConnectButton" to "Update from TiVo"
		set enabled of button "CancelDownload" to false
		my debug_log("Finished Downloading, 85% fullfilesize=" & (0.85 * fullFileSize) & " ;  currentfilesize=" & my getCurrentFilesize(filePath))
		if cancelDownload = 0 and my isDownloadComplete(filePath, fullFileSize, currentTry) then
			set historyCheck to first item of currentProcessSelectionParam & "-" & id as string
			if historyCheck is not in DLHistory then
				set DLHistory to DLHistory & {historyCheck}
				my updateSubscriptionList(oShowName, oShowDate, false)
				my ConnectTiVo()
			end if
			if iTunes as integer > 0 then
				my debug_log("Doing iTunes-related work ")
				my create_playlist()
				my post_process_item(DL & showNameP & filenameExtension, item 1 of currentProcessSelectionParam, item 2 of currentProcessSelectionParam, item 4 of parts, item 14 of parts, item 13 of parts, item 8 of parts, item 7 of parts)
			end if
		end if
	end tell
	if (not postDownloadCmd = "") then
		try
			set shellCmd to "file=" & quoted form of DL & quoted form of showNameP & quoted form of filenameExtension & "; "
			set shellCmd to shellCmd & "show=" & quoted form of oShowName & "; "
			set shellCmd to shellCmd & "episode=" & quoted form of oShowEpisode & "; "
			if isDownloadComplete(filePath, fullFileSize, currentTry) then
				set shellCmd to shellCmd & "success=1; "
			else
				set shellCmd to shellCmd & "success=0; "
			end if
			set shellCmd to shellCmd & postDownloadCmd
			my debug_log("Running: " & shellCmd)
			set shellCmdResult to do shell script shellCmd
			my debug_log(shellCmdResult)
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
			set the item_list to every text item of TiVoList
			set processInfoRecord to {}
			set AppleScript's text item delimiters to "|"
			repeat with currentLine in item_list
				set the parts to every text item of currentLine
				if (count of parts) = 8 then
					set historyCheck to second item of parts & "-" & item 7 of parts
					if item 8 of parts = "1" then
						set first item of parts to "•"
					end if
					if historyCheck is in DLHistory then
						set first item of parts to "✔"
					end if
					set fileSize to ((item 6 of parts) / 1048576)
					set item 6 of parts to ((fileSize as integer) as string) & " MB"
					set showName to item 2 of parts
					set episodeVal to item 3 of parts
					set showDate to item 4 of parts
					set showLength to item 5 of parts
					set showSize to item 6 of parts
					set showID to item 7 of parts
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
					set end of processInfoRecord to parts
				end if
			end repeat
			repeat with currentItem in addedItems
				my updateSubscriptionList(item 1 of currentItem, item 2 of currentItem, true)
			end repeat
			if (count of addedItems) > 0 then
				set enabled of button "decodeQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to true
			end if
			if (count of processInfoRecord) = 1 then
				set contents of text field "nowPlaying" of box "topBox" of split view "splitView1" to "Now Playing (1 item)"
			else
				set contents of text field "nowPlaying" of box "topBox" of split view "splitView1" to "Now Playing (" & (count of processInfoRecord) & " items)"
			end if
			set DLHistoryCount to (count of DLHistory)
			set ListCount to (count of processInfoRecord)
			if (DLHistoryCount > ListCount) then
				set DLHistoryTemp to items (DLHistoryCount - ListCount) thru -1 of DLHistory
				set DLHistory to DLHistoryTemp
			end if
			set content of targetData to processInfoRecord
			set title of button "ConnectButton" to "Update from TiVo"
		end if
		set enabled of button "DownloadButton" of box "topBox" of split view "splitView1" to false
		set key equivalent of button "ConnectButton" to ""
		set contents of text field "status" to "Last Update : " & (current date)
	end tell
end ConnectTiVo

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

on post_process_item(this_item, show_name, episodeName, file_description, episodeNum, episodeYear, episodeGenre, episodeLength)
	my debug_log("post Process item" & " " & this_item & " " & show_name & " " & episodeName & " " & file_description & " " & episodeNum & " " & episodeYear & " " & episodeGenre & " " & episodeLength)
	set AppleScript's text item delimiters to ":"
	set the parts to every text item of episodeLength
	set episodeLength2 to (60 * ((first item of parts) as integer)) + ((second item of parts) as integer)
	set AppleScript's text item delimiters to "|"
	
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
			if episodeName = "" and episodeLength2 > 70 then
				set this_track's video kind to movie
			else
				set this_track's video kind to TV show
			end if
			set this_track's comment to file_description as string
			set this_track's description to file_description as string
			set this_track's show to show_name as string
			set this_track's episode ID to episodeName as string
			set this_track's year to episodeYear as string
			set this_track's episode number to episodeNum as string
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
	do shell script "perl " & myPath & "Contents/Resources/killProcesses.pl ;exit 0"
	my debug_log("performCancelDownload")
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
	set AppleScript's text item delimiters to ":"
	set the parts to every text item of FinderPath
	set the partsDL to every text item of ((DL as POSIX file) as string)
	set HDName to first item of parts
	set HDNameDL to first item of partsDL
	set AppleScript's text item delimiters to "|"
	
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
	set AppleScript's text item delimiters to ":"
	set the parts to every text item of FinderPath
	set the partsDL to every text item of ((DL as POSIX file) as string)
	set HDName to first item of parts
	set HDNameDL to first item of partsDL
	set AppleScript's text item delimiters to "|"
	
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

on getmencoder()
	set myPath to my prepareCommand(POSIX path of (path to me))
	set myresult to (do shell script "perl " & myPath & "Contents/Resources/mencoderSize.pl")
	if (myresult = "") then
		return {0, 0, 0}
	else
		return words in myresult
	end if
end getmencoder

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
	if (count of processInfoRecord) = 1 then
		set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo" to "Download Queue (1 item)"
	else
		set contents of text field "downloadQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo" to "Download Queue (" & (count of processInfoRecord) & " items)"
	end if
	update table view "queueListTable" of scroll view "queueList" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" of window "iTiVo"
end addSelectionToQueue

on isDownloadComplete(filePath, fullFileSize, tryCount)
	if (my getCurrentFilesize(filePath)) as real < (fullFileSize * (1 - (0.2 * tryCount))) as real then
		return false
	else
		return true
	end if
end isDownloadComplete

on debug_log(log_string)
	try
		if (debug_level ≥ 1) then
			log log_string
		end if
		if (debug_level ≥ 2) then
			set theLine to (do shell script "date  +'%Y-%m-%d %H:%M:%S'" as string) & " " & log_string
			do shell script "echo '" & theLine & "' >> ~/iTiVo.log"
		end if
	on error
		log "Failed to output string"
		set theLine to (do shell script "date  +'%Y-%m-%d %H:%M:%S'" as string) & " ERROR: Failing to output correct string"
		do shell script "echo '" & theLine & "' >> ~/iTiVo.log"
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
		tell window "iTiVo"
			my debug_log("starting download")
			set enabled of button "decodeQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to true
			tell button "decodeQueue" of view "bottomLeftView" of split view "splitView2" of box "bottomBox" of split view "splitView1" to perform action
		end tell
	else
		my debug_log("probably downloading things right now")
	end if
	return installedIdleHandler
end idle

on should quit after last window closed theObject
	return true
end should quit after last window closed
