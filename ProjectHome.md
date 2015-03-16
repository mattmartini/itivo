![http://itivo.googlecode.com/svn/trunk/www/iTiVo-small.png](http://itivo.googlecode.com/svn/trunk/www/iTiVo-small.png)
# iTiVo #

iTiVo WAS a Mac front-end to your Series 2, Series 3, and TiVoHD device.

# IT IS DEPRECATED #
## Please switch to using cTivo, which is maintained and works on newer OS releases. ##

You can find cTivo at http://code.google.com/p/ctivo/

---

(rest is the contents of this page before the deprecation)

---






> It will download shows to your mac, and convert them to many popular formats / devices.

Features include:
  * Formats include h.264, mpeg-2, mpeg-1, decrypt-only.
  * Target devices include iPhone, iPod, AppleTV, Xbox 360, PlayStation 3, PSP, youtube.
  * 'subscriptions' to your regular shows: downloading them whenever new episodes are available.
  * Automatically perform an 'iTunes sync' to your device when the download is completed.
  * Automatically remove commercials from downloaded shows.
  * Generate metadata appropriate for use by tools such as pyTivoX.
  * Create subtitle files (.srt) from the closed caption info.
  * Support for different encoders, including HandBrake, Mencoder, FFmpeg, ElGato Turbo.
  * Full control over encoder options.
  * A download queue for batch processing.
  * Scheduling of when the queue will be processed.
  * Automatic discovery of Tivos using Bonjour.
  * Automatic updates.
  * Reporting on tivo's Hard Drive usage.

With appropriate configuration, you can plug in your iPhone to your computer to recharge overnight.  In the morning, you will find all your favorite shows from your tivo loaded onto it.

## Download ##
Download the image file.  Drag the iTiVo application to your Applications Folder, and run it from there.  Full [Installation Document here](http://code.google.com/p/itivo/wiki/Installation).

> iTiVo is **free** to use.  The source is available for anyone to browse and contribute to. I would appreciate bug reports in the 'issues' tab above.

## Screenshots ##
### Main Page ###
![http://itivo.googlecode.com/svn/trunk/www/Sample.png](http://itivo.googlecode.com/svn/trunk/www/Sample.png)
### Preferences Pane open, with tivo info, and formats dropdown ###
![http://itivo.googlecode.com/svn/trunk/www/detail.png](http://itivo.googlecode.com/svn/trunk/www/detail.png)

## Support / FAQ ##
> There is a main [help page](http://code.google.com/p/itivo/wiki/Help).  Please read it and the [FAQ](http://code.google.com/p/itivo/wiki/FAQ) if you're having problems.  If nothing answers your question, either post a bug report under 'issues' above, or post to the [TiVo Community forum](http://tivocommunity.com/tivo-vb/showthread.php?t=409772).

## history ##

This program is a continuation of the tivodecode manager program by David Benesch.  The old program was unsupported and had issues under Leopard and with Tivo3's.  However, this is not a full-time supported program.  It has many bugs, and may not do what you want.  Use at your own risk.

# Links #

## Underlying Tools ##
As mentioned, iTiVo is simply a pretty front-end for a lot of tools written by other people.  Those tools (and relevant source code) are:
  * [tivodecode](http://sourceforge.net/project/showfiles.php?group_id=183716) is used to 'decrypt' shows downloaded from the tivo.
  * [mencoder](http://www.mplayerhq.hu/design7/dload.html) (part of the MPlayer package) is used to convert the shows to smaller files.
  * [etv-comskip](http://code.google.com/p/etv-comskip/) is the mac port of the comskip project.  Used to figure out where the commercials are in the program.
  * [HandBrake](http://handbrake.fr/) provides an alternative encoder with its own ups and downs.
  * [t2sami](http://sourceforge.net/project/showfiles.php?group_id=183716&package_id=227133) is used to generate subtitles from closed caption info.

## Other Useful Tools ##
  * [pyTivoX ](http://pytivox.googlecode.com/) is for doing the reverse of iTiVo (uploading or streaming any media file from your computer to your TiVo).
  * [MetaX](http://www.kerstetter.net/page53/page54/page54.html) will let you add information fields and tags (metadata) to the files you download with iTiVo.  You can add movie posters, additional useful info from imdb, or whatever.
  * [Tivo Tools Roundup](http://www.tivoblog.com/archives/2008/02/20/tivo-software-roundup-mac-only/) maintains a long list of other tivo tools you may want to check out for your mac, including alternatives to iTiVo.
  * [TivoDecodeManager](http://tdm.sourceforge.net/) was the program from which iTiVo was derived.  It should run without issues on Tiger.
  * If you want to view stuff you downloaded using 'decrypt' as the format, you can try [VLC](http://www.videolan.org/vlc/download-macosx.html), [MPlayer OSX Extended](http://mplayerosx.sttz.ch/#downloads) (quicktime-like replacements) or [Plex](http://elan.plexapp.com/) (a FrontRow replacement).