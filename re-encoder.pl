#!/usr/bin/perl

$AppDir = $ARGV[0];
$DestDir = $ARGV[1];
$TargetFile = $ARGV[2];
$encodeMode = $ARGV[3];
$width = $ARGV[4];
$height = $ARGV[5];
$vbitrate = $ARGV[6];
$abitrate = $ARGV[7];

$AppDir =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$DestDir =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$TargetFile =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$TargetFile =~ s/:/-/g;
$TargetFile =~ s/\//:/g;
$Target = $DestDir.$TargetFile;

$Src = "/tmp/iTiVoDLPipe2-$ENV{'USER'}.mpg";
$Progress = "/tmp/iTiVoDL2-$ENV{'USER'}";
$Edl = "/tmp/iTiVoDLPipe2-$ENV{'USER'}.edl";

`touch $Edl`;

if ($encodeMode == 0) {
# Native, no conversion
	$shellScript3 = "cat -u $Src >" . $Target;
} elsif ($encodeMode == 1) {
# iphone high-res
   $vbitrate=1500;
   $abitrate=128;
   $width=640;
   $height=480;
   $shellScript3 = $AppDir . "Contents/Resources/mencoder -hr-edl-seek -edl $Edl -af volume=13:1 -of lavf -lavfopts format=ipod -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=30:bitrate=$vbitrate:threads=auto:bframes=0:global_header -vf pp=lb,dsize=$width:$height:0,scale=-8:-8,harddup -o $Target $Src >$Progress 2>&1";
} elsif ($encodeMode == 2) {
# iphone
   $vbitrate=384;
   $abitrate=128;
   $width=480;
   $height=320;
   $shellScript3 = $AppDir . "Contents/Resources/mencoder -hr-edl-seek -edl $Edl -af volume=13:1 -of lavf -lavfopts format=ipod -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=30:bitrate=$vbitrate:threads=auto:bframes=0:global_header -vf pp=lb,dsize=$width:$height:0,scale=-8:-8,harddup -o $Target $Src >$Progress 2>&1";
} elsif ($encodeMode == 3) {
# ipod
   $vbitrate=256;
   $abitrate=128;
   $width=320;
   $height=240;
   $shellScript3 = $AppDir . "Contents/Resources/mencoder -hr-edl-seek -edl $Edl -af volume=13:1 -of lavf -lavfopts format=ipod -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=30:bitrate=$vbitrate:threads=auto:bframes=0:global_header -vf pp=lb,dsize=$width:$height:0,scale=-8:-8,harddup -o $Target $Src >$Progress 2>&1";
} elsif ($encodeMode == 4) {
# zune
   $vbitrate=960;
   $abitrate=128;
   $width=640;
   $height=-10;
   $shellScript3 = $AppDir . "Contents/Resources/mencoder -hr-edl-seek -edl $Edl -af volume=13:1 -of lavf -lavfopts format=mp4 -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=30:bitrate=$vbitrate:threads=auto:bframes=0:global_header -vf pp=lb,scale=$width:$height,harddup -o $Target $Src >$Progress 2>&1";
} elsif ($encodeMode == 5) {
# AppleTV
   $vbitrate=960;
   $abitrate=128;
   $width=640;
   $height=-10;
   $shellScript3 = $AppDir . "Contents/Resources/mencoder -hr-edl-seek -edl $Edl -af volume=13:1 -of lavf -lavfopts format=mp4 -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=30:bitrate=$vbitrate:threads=auto:bframes=0:global_header -vf pp=lb,scale=$width:$height,harddup -o $Target $Src >$Progress 2>&1";
} elsif ($encodeMode == 6) {
# PSP
   $vbitrate=768;
   $abitrate=128;
   $width=480;
   $height=272;
   $shellScript3 = $AppDir . "Contents/Resources/mencoder -hr-edl-seek -edl $Edl -af volume=13:1 -of lavf -lavfopts format=psp -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=21:bitrate=$vbitrate:threads=auto:bframes=0:global_header:subq=5:me=umh -vf pp=lb,scale=$width:$height,harddup -o $Target $Src >$Progress 2>&1";
} elsif ($encodeMode == 7) {
	# PS3
	$vbitrate=960;
	$abitrate=128;
	$width=640;
	$height=-10;
	$shellScript3 = $AppDir . "Contents/Resources/mencoder -hr-edl-seek -edl $Edl -af volume=13:1 -of lavf -lavfopts format=mp4 -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts level_idc=41:bitrate=$vbitrate:threads=auto:bframes=0:global_header:subq=5:me=umh -vf pp=lb,scale=$width:$height,harddup -o $Target $Src >$Progress 2>&1";
} elsif ($encodeMode == 8) {
	# DVD NTSC
	$shellScript3 = $AppDir . "Contents/Resources/mencoder -hr-edl-seek -edl $Edl -oac copy -ovc lavc -of mpeg -mpegopts format=dvd:tsaf:telecine -vf scale=720:480,harddup -lavcopts vcodec=mpeg2video:vrc_buf_size=1835:vrc_maxrate=9800:vbitrate=5000:keyint=15:vstrict=0:aspect=16/9 -ofps 24000/1001 -o $Target $Src >$Progress 2>&1";
} elsif ($encodeMode == 9) {
	# DVD PAL
	$shellScript3 = $AppDir . "Contents/Resources/mencoder -hr-edl-seek -edl $Edl -oac copy -ovc lavc -of mpeg -mpegopts format=dvd:tsaf -vf scale=720:576,harddup -ofps 25 -lavcopts vcodec=mpeg2video:vrc_buf_size=1835:vrc_maxrate=9800:vbitrate=5000:keyint=15:vstrict=0:aspect=16/9 -o $Target $Src >$Progress 2>&1";
} elsif ($encodeMode == 10) {
	# mpeg-2 minimimal
	$shellScript3 = $AppDir . "Contents/Resources/mencoder -edl $Edl -oac copy -ovc copy -of mpeg -mpegopts format=mpeg2:tsaf:muxrate=36000 -noskip -mc 0 -forceidx -o $Target $Src >$Progress 2>&1";
} else {
	# Custom mp4
	$shellScript3 = $AppDir . "Contents/Resources/mencoder -hr-edl-seek -edl $Edl -af volume=13:1 -of lavf -lavfopts format=ipod -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=30:bitrate=$vbitrate:threads=auto:bframes=0:global_header -vf pp=lb,scale=$width:$height,harddup -o $Target $Src >$Progress 2>&1";
}

`$shellScript3`;

`rm -f /tmp/iTiVoDLPipe-$ENV{'USER'} /tmp/iTiVoDLPipe2-$ENV{'USER'}.mpg`;
