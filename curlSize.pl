#!/usr/bin/perl

$file = "/tmp/iTiVo-$ENV{'USER'}/iTiVoDL";
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

if ($line =~ /^\s*\S+\s+\S+\s+\S+\s+([0-9.]+)([kMG]?)\s+\S+\s+\S+\s+[0-9.]+[kMG]?\s+\d\s+[0-9\-:]+\s+[0-9\-:]+\s+[0-9\-:]+\s+[0-9.]+[kMG]?/) {
	if ($2 eq "k") {
		print $1 / 1024;
	}
	elsif ($2 eq "M") {
		print $1;
	}
	elsif ($2 eq "G") {
		print $1 * 1024;
	}
	else {
		print $1 / (1024 * 1024);
	}
}
elsif ($prevLine =~ /^\s*\S+\s+\S+\s+\S+\s+([0-9.]+)([kMG]?)\s+\S+\s+\S+\s+[0-9.]+[kMG]?\s+\d\s+[0-9\-:]+\s+[0-9\-:]+\s+[0-9\-:]+\s+[0-9.]+[kMG]?/) {
	if ($2 eq "k") {
		print $1 / 1024;
	}
	elsif ($2 eq "M") {
		print $1;
	}
	elsif ($2 eq "G") {
		print $1 * 1024;
	}
	else {
		print $1 / (1024 * 1024);
	}
}
