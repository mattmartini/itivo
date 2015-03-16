# Help #
iTiVo is a tool that is intended to help you get shows from your TiVo to your computer or to your portable device (such as an iPhone).  It is really just a compilation of tools written by others, combined with a friendly interface to make life simple for you.  It is still under heavy development, so you may notice bugs and new releases often.

> If you have bugs to report, please use the [bug report form](http://code.google.com/p/itivo/issues/entry?template=Defect%20report%20from%20user).

> If you have a question, check out the [FAQ](http://code.google.com/p/itivo/wiki/FAQ).

> Alternatively, you can go to the [TiVo Community iTiVo page](http://tivocommunity.com/tivo-vb/showthread.php?t=409772) and ask there.

# Installation/Configuration #
Before you can use iTiVo, you need to install it, tell your TiVo to allow transfers, and tell iTiVo your 'tivo key (MAK)'.  Instructions on how to do all of this are in the [Installation Document](http://code.google.com/p/itivo/wiki/Installation).

# Setting the Media Access Key #
Instructions on finding out your MAK is documented in the [Installation Document](http://code.google.com/p/itivo/wiki/Installation).

# Basic Usage #
Once the media access key is set (see above), bring up the main window of iTiVo
  * Select the tivo from the "My TiVos" button
  * Choose "Connect to TiVo", and a list of shows should appear after a few seconds
  * Click on a show you wish to download
  * Click the "Download Show" button.
  * _wait_

# What the Buttons/Options Mean #
  * TiVo IP Address
> > The IP address to connect to for your tivo.  Only use this if you failed to automatically find your tivo in the "My TiVos" dropdown.

  * My TiVos dropdown
> > This will attempt to find your tivo if it's on the local network.  If it is a remote tivo, you will need to specify an IP address, which you can find from the network settings of your tivo.

  * Update from TiVo
> > Clicking this button will attempt to connect to your tivo, and download show information.  This goes much faster if you are using a wired instead of wireless connection, and can also be slow if this is an old tivo with a LOT of shows.

  * Info
> > Clicking this will alternate between the 'show info' sidetab,  the 'tivo info' sidetab, and nothing.

### Now Playing ###

> This part of the window is dedicated to the shows currently available to download from your tivo.

  * Subscribe
> > Selecting a show and clicking "subscribe" will add the show to your subscription list.  Read further on subscription lists below.

  * Add to Queue
> > Add the show to the download queue for later downloading.  Read below for more info.

  * Download show
> > Immediately download the selected show.  This is only available if iTiVo is not already busy downloading something.

### Download Queue ###

> This part of the window is a queue of downloads that are scheduled to happen.  Subscriptions automatically add to the queue, and clicking "Add to Queue" above will also add to the queue.  The queue is processed regularly.

  * Remove
> > Delete the selected show from the download queue.

  * Download Now
> > Start processing the download queue now.

### Subscriptions List ###

> This part of the window is a list of shows you have subscribed to.  Subscribed shows are automatically added to the queue when new episodes appear on the tivo.

  * Delete (subscription)
> > Remove the selected subscription from the subscriptions list.  This will only stop the show from being downloaded automatically in the future.  Any shows already on the queue will have to be removed manually.

### Bottom Row ###

> Here you can get status information on what is going on, and modify the preferences.

  * Prefs
> > Opens and closes the preferences window.

  * Cancel Download
> > When a download is happening, clicking this button will tell iTiVo to stop downloading it.  A partial download will be left in the download location, but nothing else will be done.

# Preferences #
To access the preferences window, click on the 'Prefs' button at the bottom of the window. Here you can configure how iTiVo will behave.  There are tabs associated with different functions.

  * Media Access Key
> > This 10-digit number is the code used to access your TiVo.  It is different for each customer.  Without the correct MAK, iTiVo will not work.  You must get yours from the TiVo or from the tivo.com website.  Instructions on how to do this are in the [Installation Document](http://code.google.com/p/itivo/wiki/Installation).

  * Download Location:
> > This is the directory into which downloads will go.  Clicking on the button will enable you to select a new location.  Remember that downloads can get very big, so make sure you have a lot of space available.

  * Download Format:
> > This is a pulldown menu with multiple selections. The higher quality/size you select, the slower the conversion process will be.

  * iTunes Icon:
> > Lets you select if it should include a starting frame from the video as your icon in itunes.

  * Import to iTunes
> > If a download completes successfully, and this button is selected, iTiVo will automatically attempt to add that show to your iTunes library.  It will generally show up under TV shows (sometimes under Movies).  Only some download formats are supported by iTunes.

  * Sync (iTunes) after import
> > If a download is successfully added, then selecting this will tell iTunes to 'sync' to all attached devices.  If you had earlier configured your iTunes to add all TV shows to you iPhone, then a completed download will automatically be downloaded to your iPhone if it is connected.

  * MetaData buttons
> > MetaData is information about the contents of your 'file'.  For example, name of the show, actors, genre, length, rating, etc.  There are several ways to store such data, and this section lets you select which ways you want to use.
      * AtomicParsley will insert the metadata into the file directly, but will only try on mp4 and quicktime files (other formats dont support it).
      * pyTivo creates another file alongside the movie file, which contains text descriptions of all the tags. This is used by programs like [pyTiVoX](http://code.google.com/p/pytivox/) when making the shows available back to the tivo for downloading or viewing.
      * .tivo is an XML formatted entries list directly from the tivo, with no processing.

  * Commercial Skip
> > If enabled, it will attempt to use a program named "comskip" to detect where commercials are in your show, and remove them.  Turning this option on slows down downloads considerably. It also takes up a LOT of hard drive space on your Main Drive for temporary data.  And most importantly, it does its best to figure out what a commercial is, but can make mistakes (leaving commercials in, or worse, cutting out parts of your show).  You can read up on comskip on [its homepage](http://www.kaashoek.com/comskip/).

  * Scheduling
> > Here you can set the program to only start automatic queue processing during certain times.  Keep in mind that this is when queue processing STARTS.  It will keep running until it clears the queue no matter how long it takes.
> > You can also set the computer to be put to sleep whenever queue processing is done.  This will put the computer to sleep both after scheduled OR manual queue processing.

  * Advanced
> > Can be used to control advanced options like encoder settings.

# Download Queue #
The download queue is simply a list of shows scheduled for downloading.  Since the tivo only allows you to download one show at a time, it's sometimes easier to make a list of shows you want downloaded, and then have them all go at once while you go out for a while.  The list is processed top-to-bottom.  Even if you do not select to 'download queue', if the program has been idle, it will attempt to download the queue (this is to support subscriptions).

# Subscriptions #
If there is a show you always choose to download from your tivo (daily news for example, or a show you always watch on your iphone) you can 'subscribe' to that show.  When a subscription exists, the iTiVo program checks hourly for shows on that list.  If a new show with that title has become available, it will add it to the queue automatically.  A show only gets added once (so if you cancel, or quit iTiVo, you will need to manually add the show to the queue again if you still want it).


# Frequently Asked Questions #
The FAQ is at http://code.google.com/p/itivo/wiki/FAQ