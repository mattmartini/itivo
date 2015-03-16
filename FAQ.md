# F.A.Q. #

## Program Issues ##
  1. My program crashes / I get 'mencoder' errors / I get tivodecode errors
> > iTiVo is actually a front-end for several programs written by multiple people.  Many of these programs are not perfect (and iTiVo has its own bugs).  If you report bugs in the interface above (under Issues), I will hopefully get around to fixing it.  However, it may be related to underlying programs which I have no control over. The short version:  sorry.  One thing to always try is a different download format, or a different encoder (for example, HandBrake iPhone instead of iPhone).
  1. This program is buggy!
> > I only have a tivo 3 and an intel iMac running Leopard to test with.  I appreciate bug reports. But keep in mind I'm working on this in my spare time and am not charging you anything...
  1. I am getting some popup asking me to find 'GrowlHelperApp'.
> > You have an old version of Growl installed (probably done via one of many applications you have installed in the past?).  The easiest solution is to simply upgrade your installation of Growl to the newest version from http://growl.info/index.php
  1. I clicked "subscribe" but it's not downloading all episodes of CSI!
> > Subscribing only downloads 'future' episodes that show up on the tivo AFTER you started the subscription.  If you want to download all the CSI's currently on your tivo, select the table column heading 'show' (to sort all shows by name), find the first CSI and click on it.  Find the last CSI and shift-click on it.   Then select "Add Shows to Queue"
  1. How do I get "The Daily Show" onto my iPhone automatically?
> > Read the documentation at http://code.google.com/p/itivo/wiki/Subscriptions
  1. I have questions about my TiVo.
> > I'm only responsible for this front-end.  If you have questions about your tivo, I highly recommend going to the tivocommunity forum here: http://tivocommunity.com/tivo-vb/index.php
  1. I have shows on my TiVo that are not listed on iTiVo!
> > Certain shows and certain channels can be marked 'copyrighted'.  Any show marked as such is not available for download from the tivo, and is therefore not listed.  Premium Channels (like HBO) are always marked this way.  Some regular cable channels also do this.  The only ones that are not allowed to be marked copyright are the off-air (networks).
  1. I managed to hide the Show Description drawer
> > To unhide the show description drawer, click the little triangle on the top right of the main window.
  1. I chose a download format and Quicktime will not play my video
> > Some formats are not intended for playing on your computer, and quicktime is unable to play them.  Read the later subsection about download formats for advice.
  1. The reported Hard Drive size is incorrect.
> > Tivo doesn't actually let iTiVo know the size of the hard drive.  So iTiVo tries to figure it out based on how much space is taken up by shows.  This generally works when you have Suggestions enabled.  You can correct the size by directly editting the number, but be aware that a 20G hard drive doesn't actually hold 20G of data.  So a safe guess is to go with 90% of the size of the hard drive, or enable suggestions for a while until Tivo gets a reasonable size, and then disable them again.
  1. Is it supposed to be **this** slow?
> > Several things affect the speed of the download:
    * Model of Tivo.  S3 is fastest, then HD then S2.
    * Size of the original program on the tivo (the more there is to transfer, the slower it will be).
    * The speed of your computer.  Your CPU is used to convert the movies once they get to the computer.
    * Format you are converting to.  The high resolution, high quality formats take a lot of processing power from your computer.
    * The quality of your Tivo->computer network.  Wired 100Mbps will not be fully utilized, but is your best connection.  Wireless will slow it down somewhat.
> > Over a wired connection, from a TiVo S3, converting to iPhone, I can usually get a 1000 megabyte 30 minute show down in about 20 mins. Use those settings as a starting point to see.  If you're seeing MUCH worse times, then something is wrong.
  1. What should I do if I need it to download faster?
> > If you really need the faster downloads and are ok with using up more hard drive space, you should probably select the 'decrypt' format.  And install [MPlayer OSX](http://mplayerosx.sttz.ch/#downloads) or [VLC](http://www.videolan.org/vlc/download-macosx.html) to view the downloaded movie.  It will download as fast as the tivo will allow, and do no conversion whatsoever.
  1. I am seeing some errors about looking for Growl or GrowlHelperApp
> > While the program is supposed to correctly detect if you have growl installed and only use it then, there have been some reports that this detection is not always working.  If you get such an error, the simplest thing to do is install Growl from http://growl.info/

## Issues With Specific Formats ##
  1. The Handbrake AppleTV format is creating files that AppleTV still cannot play.
> > It has been reported that the following may help:  Open the preferences.  Select the _Handbrake AppleTV_ format.  Select the _Advanced Tab_.  Change the value
> > > `-Z "AppleTV"`

> > to
> > > `-Z "AppleTV" --rate 29.97`

> > Encode away.

## Which Download Format to use? ##
  1. I want the original mpeg-2 from the tivo.
> > The tivo encrypts your show with your MAK.  If you want to simply decrypt, choose the 'Decrypt' format.  However, keep in mind that quicktime can't play such a file.  You will need to install [VLC](http://www.videolan.org/vlc/download-macosx.html) or [MplayerOSX](http://mplayerosx.sttz.ch/#downloads) (free) to view it.  Media managers like [Plex ](http://elan.plexapp.com/) can also read it.
  1. I want the original mpeg-2 but without commercials.
> > Decrypt/Copy will cut up the file appropriately.  However, you will most likely end up with horrible audio/video sync issues.
  1. Why isn't the DVD format making a burnable DVD image?
> > The DVD format simply creates an mpeg-2 file with specifications appropriate for DVD burning software.  It will not make a DVD image, nor burn one for you.  If you plan on making a DVD, you should then load up the resulting movie into another program like [Burn](http://burn-osx.sourceforge.net/Pages/English/home.html).
  1. What is iphone super-res?
> > The iphone can play movies up to 720x480, although its display is only 480x320.  You can hook up a video cable to hook up your iphone to a TV, and that's the main reason for super-res..  It also uses a much higher bitrate for people who think the iphone setting isn't of a high enough quality.
  1. Audio-only?
> > The audio only re-encodes the video stream, throwing away ALL the movie, and just keeping the soundtrack.  Useful for people who plan on listening but not viewing, as it takes up a LOT less memory, and uses less battery life to play back.
  1. PSP ?
> > Aimed at the Sony PSP handheld:  Connect your PSP via usb or insert the memory stick into a reader. Create a folder named "VIDEO" at the toplevel, and copy the movie into it.  Your PSP will now play your movie for you.
  1. I want to keep my movies as a library on my hard drive... What settings?
> > I'd personally use H.264 at 5mbps.  If you want to get the best quality AND the fastest download, you can simply keep whatever tivo encoded by using the 'decrypt' format, but then to view it you will have to install a viewer like [VLC](http://www.videolan.org/vlc/download-macosx.html) or [MPlayer OSX](http://mplayerosx.sttz.ch/#downloads).  If you later decide you prefer h.264, you can always re-encode your movie with a tool like [[HandBrake](http://trac.handbrake.fr/).
  1. What is HandBrake?
> > A popular mac encoding tool that is an alternative to mencoder.  Some people prefer the speed or the quality of handbrake.  (Even though a lot of code is shared between the two encoders).  If you are seeing a lot of mencoder crashes, it's worth trying out HandBrake instead.
  1. I use HandBrake, but I want to use different options from what you chose.
> > Go into the Advanced tab after selecting your handbrake encoder, and add options to the encoder video options.  You can read up on all the options [on the handbrakeCLI config page](http://trac.handbrake.fr/wiki/CLIGuide).
  1. What is ElGato Turbo.264?
> > It's a hardware encoder.  If you own an old mac, or just want to keep your mac from using a lot of processing power to encode, you can buy the elgato USB stick, and use that to encode shows instead.  As I don't own one, I can't vouch that it will work or do the right thing, although I will try to fix bugs if people tell me about them.
  1. I want to make a custom download format.
> > Select Prefs / Downloading tab.  Select a format that is the most similar to the format you wish to create.  Then select the 'advanced' tab, and make changes to the encoder options.  Save the format via the button, and give it a unique name.  The format config is saved in ~/Library/Application Support/iTiVo/formats/ (in case you want to give it to others, or delete it).
  1. I chose the right download format but it's not working.
> > Submit a bug report under 'Issues' above.  Keep in mind I don't have all these devices, so I appreciate any encoder suggestions you may have.  Also keep in mind that if it's because 'mencoder' or a similar subtool crashes, there is really not much I can do.

## Tips and Tricks ##
  1. I have it automatically add it to itunes, and itunes manages my library.  So every time the download finishes, I have two copies of the movie.. one in the download location, and one in the iTunes library!!  HELP!!
> > Go to your advanced preferences, and under **run when download completes** put:
```
  mv "$file" ~/.Trash
```
> > (That is a tilde next to the word trash: ~ ,  NOT a minus sign.)
> > This will put the file into the trash AFTER itunes copies it out. (the quotes around the $file are important, since there may be spaces in the show name).