#!/usr/bin/perl

$encoder = $ARGV[0];

$file = "/tmp/iTiVo-$ENV{'USER'}/iTiVoDL2";
open (CURLFILE, $file);
seek (CURLFILE, -1024, 2);

$line = "";
$lasttime=0;
$lastpercent=0;
$lasttimeremain=200;

if ($encoder eq "mencoder") {
	while ($line = <CURLFILE>) {
    if ($line =~ /Pos:\s*([\.[:digit:]]+).*\(\s*(\d+)\%\).*Trem\:\s*(\d+)min/) {
			$lasttime=$1;
			$lastpercent=$2;
			$lasttimeremain=$3;
    }
	}
} elsif ($encoder eq "HandBrake") {
	while ($line = <CURLFILE>) {
		if ($line =~ /\rEncoding:.*\,\s*([\.[:digit:]]+)\s*\%.*\(.*avg\s*([\.[:digit:]]+)\s*fps, ETA\s*(\d+)h(\d+)m(\d+)s\s*\)/) {
			$lasttimeremain=($3 * 3600 + $4 * 60 + $5);
			$lasttime=((int (($lasttimeremain * (100/(100-($1-0.001)))) * 100)) / 100) - $lasttimeremain;
			$lastpercent=$1;
			$lasttimeremain=(int(($lasttimeremain * 100) / 60) / 100);
    }
	}
} elsif ($encoder eq "turbo.264") {
	while ($line = <CURLFILE>) {
    if ($line =~ /^([\.[:digit:]]+)\s+(\d+)\s+(\d+)/) {
			$lasttime=$1;
			$lastpercent=$2;
			$lasttimeremain=$3;
    }
	}
}
print "$lasttime $lastpercent $lasttimeremain\n";
close(CURLFILE);