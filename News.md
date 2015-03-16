# News #
Apr. 14 2013:
Folks, [cTiVo](https://code.google.com/p/ctivo) has come a very long way and seems to be nearly equivalent to iTiVo functionality.  As the internals will be much cleaner, folks should try it out.

Dec. 16, 2012:
Thanks to Gene Civillico, we believe we've been able to sort out the last problem.  The test image from 12/12/2012 is the latest and greatest and seems to work on Mountain Lion.

Oct. 11, 2012:
A potential fix for issues 198 and 214 has been posted.  Testing is incomplete at this time, so use with caution.  All credit to Drew Moseley for the fixes, and apologies for the delay on my part.  This release drops support for MacOS X prior to 10.6.

Apr. 26, 2012:
Yesterday's fix for [issue 196](https://code.google.com/p/itivo/issues/detail?id=196) was incomplete.  There were a number of other images included that were dynamically linked as well.  Replaced.  Also tried to use 'curl -q' to address [issue 187](https://code.google.com/p/itivo/issues/detail?id=187).

Apr. 25, 2012:
Put a new test image that has a fix for [issue 196](https://code.google.com/p/itivo/issues/detail?id=196).  In the previous test image, I tried to build a new mencoder, but didn't realize that the version was dynamically linked.  This works fine on my system, but not on anyone else's.  Replaced it with the previous version of mencoder.

Feb. 26, 2012:
Added a developer to the team.  Tony1athome is an experienced developer and longtime TiVo addict, but a complete newbie to Applescript.  Put up a test image that has a fix for [issue 129](https://code.google.com/p/itivo/issues/detail?id=129) (bad episode name when running the queue).  Your feedback is welcome, and your patience is appreciated.  Better yet, more help would be welcome.