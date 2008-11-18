#!/usr/bin/perl

$file = "/tmp/iTiVoDL2-$ENV{'USER'}";
open (CURLFILE, $file);
seek (CURLFILE, -1024, 2);

$line = "";
$lasttime=0;
$lastpercent=0;
$lasttimeremain=200;

while ($line = <CURLFILE>) {
    if ($line =~ /Pos:\s*([\.[:digit:]]+).*\(\s*(\d+)\%\).*Trem\:\s*(\d+)min/) {
	$lasttime=$1;
	$lastpercent=$2;
	$lasttimeremain=$3;
    }
}
print "$lasttime $lastpercent $lasttimeremain\n";
close(CURLFILE);