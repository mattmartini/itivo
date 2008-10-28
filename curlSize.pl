#!/usr/bin/perl

$file = "/tmp/iTiVoDL-$ENV{'USER'}";
open (CURLFILE, $file);

$line = "";
$prevLine = "";

<CURLFILE>;
<CURLFILE>;
$file = <CURLFILE>;

close(CURLFILE);

my @lines = split('\r', $file);

$line = pop(@lines);
$prevLine = pop(@lines);

if ($line =~ /^\s+\S+\s+\S+\s+\S+\s+([0-9.]+)([kM]?)\s+\S+\s+\S+\s+[0-9.]+[kM]?\s+\d\s+[0-9\-:]+\s+[0-9\-:]+\s+[0-9\-:]+\s+[0-9.]+[kM]?/) {
	if ($2 eq "k") {
		print $1 / 1024;
	}
	elsif ($2 eq "M") {
		print $1;
	}
	else {
		print $1 / (1024 * 1024);
	}
}
elsif ($prevLine =~ /^\s+\S+\s+\S+\s+\S+\s+([0-9.]+)([kM]?)\s+\S+\s+\S+\s+[0-9.]+[kM]?\s+\d\s+[0-9\-:]+\s+[0-9\-:]+\s+[0-9\-:]+\s+[0-9.]+[kM]?/) {
	if ($2 eq "k") {
		print $1 / 1024;
	}
	elsif ($2 eq "M") {
		print $1;
	}
	else {
		print $1 / (1024 * 1024);
	}
}
