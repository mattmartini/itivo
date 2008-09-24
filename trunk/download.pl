#!/usr/bin/perl

$file = $ARGV[1];
$file2 = $ARGV[4];
$file3 = $ARGV[5];

$file =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$file2 =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$file3 =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$file =~ s/:/-/g;
$file =~ s/\//:/g;
$width = $ARGV[8];
$height = $ARGV[9];
$vbitrate = $ARGV[10];
$abitrate = $ARGV[11];
$expectedSize = $ARGV[12] * 1024;
$filenameExtension = $ARGV[13];

$shellScript = "curl 'http://" . $ARGV[0] . ":80/download/" . $ARGV[6] . ".TiVo?Container=%2FNowPlaying&id=" . $ARGV[2] . "' -c /tmp/cookies.txt --retry 12 --retry-delay 10 --digest -u tivo:" . $ARGV[3] . " -o ~/.TiVoDLPipe --stderr ~/.TiVoDL";

`$shellScript`;

