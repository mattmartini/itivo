#!/usr/bin/perl

$TivoDir = "$ENV{'USER'}";
$TivoDir =~ tr/ :\//_../;
$TivoDir = "/tmp/iTiVo-$TivoDir";

$file = "$TivoDir/iTiVoDL3";
open (CURLFILE, $file);
seek (CURLFILE, -1024, 2);

$line = "";
$lastpercent=0;

while ($input = <CURLFILE>) {
    @lines = split(' ', $input);
    foreach $line (@lines) {
	if ($line =~ /(\d+)\%$/) {
	    $lastpercent="$1";
	}
    }
}
print "$lastpercent\n";
close(CURLFILE);
