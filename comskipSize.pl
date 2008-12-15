#!/usr/bin/perl

$file = "/tmp/iTiVo-$ENV{'USER'}/iTiVoDL3";
open (CURLFILE, $file);
seek (CURLFILE, -1024, 2);

$line = "";
$lasttime="00:00:00";
$lastframe=0;
$lastpercent=0;

while ($input = <CURLFILE>) {
	@lines = split('\r', $input);
	foreach $line (@lines) {
		if ($line =~ /([\:[:digit:]]+)\s+\-\s+(\d+) frames in.*\, (\d+)\%/) {
			$lasttime=$1;
			$lastframe=$2;
			$lastpercent=$3;
		}
	}
}
print "$lastframe $lastpercent $lasttime\n";
close(CURLFILE);
