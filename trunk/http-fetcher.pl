#!/usr/bin/perl

$tivoip=$ARGV[0];
$showID=$ARGV[1];
$showNAME=$ARGV[2];
$MAK=$ARGV[3];

$shellScript = "curl \'http://$tivoip\:80/download/$showNAME\.TiVo?Container=%2FNowPlaying&id=$showID\' -c /tmp/cookies.txt --retry 12 --retry-delay 10 --digest -u tivo:$MAK -o /tmp/iTiVoDLPipe-$ENV{'USER'} --stderr /tmp/iTiVoDL-$ENV{'USER'}";

`$shellScript`;

