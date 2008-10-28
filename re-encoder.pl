#!/usr/bin/perl

$file = $ARGV[1];
$file2 = $ARGV[4];
$file3 = $ARGV[5];

$file =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$file2 =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$file3 =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$file =~ s/:/-/g;
$file =~ s/\//:/g;
$encodeMode=$ARGV[7];
$width = $ARGV[8];
$height = $ARGV[9];
$vbitrate = $ARGV[10];
$abitrate = $ARGV[11];
$expectedSize = $ARGV[12] * 1024;
$filenameExtension = $ARGV[13];


if ($encodeMode == 0) {
# Native, no conversion
	$shellScript3 = "cat -u /tmp/iTiVoDLPipe2-$ENV{'USER'} >" . $file3 . $file . $filenameExtension;
} elsif ($encodeMode == 1) {
# iphone high-res
   $vbitrate=1500;
   $abitrate=128;
   $width=640;
   $height=-10;
   $shellScript3 = $file2 . "Contents/Resources/mencoder -af volume=13:1 -of lavf -lavfopts format=ipod -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=30:bitrate=$vbitrate:threads=auto:bframes=0:global_header -vf pp=lb,scale=$width:$height,harddup -o " . $file3 . $file . $filenameExtension ." /tmp/iTiVoDLPipe2-$ENV{'USER'}";
} elsif ($encodeMode == 2) {
# iphone med-res
   $vbitrate=800;
   $abitrate=128;
   $width=480;
   $height=360;
   $shellScript3 = $file2 . "Contents/Resources/mencoder -af volume=13:1 -of lavf -lavfopts format=ipod -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=30:bitrate=$vbitrate:threads=auto:bframes=0:global_header -vf pp=lb,scale=$width:$height,harddup -o " . $file3 . $file . $filenameExtension ." /tmp/iTiVoDLPipe2-$ENV{'USER'}";
} elsif ($encodeMode == 3) {
# iphone low-res
   $vbitrate=256;
   $abitrate=128;
   $width=320;
   $height=240;
   $shellScript3 = $file2 . "Contents/Resources/mencoder -af volume=13:1 -of lavf -lavfopts format=ipod -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=30:bitrate=$vbitrate:threads=auto:bframes=0:global_header -vf pp=lb,scale=$width:$height,harddup -o " . $file3 . $file . $filenameExtension ." /tmp/iTiVoDLPipe2-$ENV{'USER'}";
} elsif ($encodeMode == 4) {
# zune
   $vbitrate=960;
   $abitrate=128;
   $width=640;
   $height=-10;
   $shellScript3 = $file2 . "Contents/Resources/mencoder -af volume=13:1 -of lavf -lavfopts format=mp4 -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=30:bitrate=$vbitrate:threads=auto:bframes=0:global_header -vf pp=lb,scale=$width:$height,harddup -o " . $file3 . $file . $filenameExtension ." /tmp/iTiVoDLPipe2-$ENV{'USER'}";
} elsif ($encodeMode == 5) {
# AppleTV
   $vbitrate=960;
   $abitrate=128;
   $width=640;
   $height=-10;
   $shellScript3 = $file2 . "Contents/Resources/mencoder -af volume=13:1 -of lavf -lavfopts format=mp4 -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=30:bitrate=$vbitrate:threads=auto:bframes=0:global_header -vf pp=lb,scale=$width:$height,harddup -o " . $file3 . $file . $filenameExtension ." /tmp/iTiVoDLPipe2-$ENV{'USER'}";
} elsif ($encodeMode == 6) {
# PSP
   $vbitrate=768;
   $abitrate=128;
   $width=480;
   $height=272;
   $shellScript3 = $file2 . "Contents/Resources/mencoder -af volume=13:1 -of lavf -lavfopts format=psp -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=21:bitrate=$vbitrate:threads=auto:bframes=0:global_header:subq=5:me=umh -vf pp=lb,scale=$width:$height,harddup -o " . $file3 . $file . $filenameExtension ." /tmp/iTiVoDLPipe2-$ENV{'USER'}";
} elsif ($encodeMode == 7) {
# PS3
   $vbitrate=960;
   $abitrate=128;
   $width=640;
   $height=-10;
   $shellScript3 = $file2 . "Contents/Resources/mencoder -af volume=13:1 -of lavf -lavfopts format=mp4 -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts level_idc=41:bitrate=$vbitrate:threads=auto:bframes=0:global_header:subq=5:me=umh -vf pp=lb,scale=$width:$height,harddup -o " . $file3 . $file . $filenameExtension ." /tmp/iTiVoDLPipe2-$ENV{'USER'}";
} else {
	$shellScript3 = $file2 . "Contents/Resources/mencoder -af volume=13:1 -of lavf -lavfopts format=ipod -oac faac -faacopts mpeg=4:object=2:raw:br=$abitrate -ovc x264 -x264encopts nocabac:level_idc=30:bitrate=$vbitrate:threads=auto:bframes=0:global_header -vf pp=lb,scale=$width:$height,harddup -o " . $file3 . $file . $filenameExtension ." /tmp/iTiVoDLPipe2-$ENV{'USER'}";
}

`$shellScript3`;

`rm -f /tmp/iTiVoDLPipe-$ENV{'USER'}*`;
