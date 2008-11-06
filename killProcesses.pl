#!/usr/bin/perl

# going through in order trying to kill gently first, and then again hard

@tokill = ("curl", "tivodecode", "comskip", "mencoder", "http-fetcher", "tivo-decoder", "remove-commercials", "re-encoder" );

foreach $procname (@tokill) {
	$processes = `ps -jAww -o command | grep -e 'iTiVo.app'`;
	@lines = split('\n', $processes);
	foreach $n (@lines) {
		if ($n =~ /^[a-z]+\s+(\d+).*\/$procname/) {
			`kill $1`;
		}
	}
}

sleep 1;
foreach $procname (@tokill) {
	$processes = `ps -jAww -o command | grep -e 'iTiVo.app'`;
	@lines = split('\n', $processes);
	foreach $n (@lines) {
		if ($n =~ /^[a-z]+\s+(\d+).*\/$procname/) {
			`kill $1`;
		}
	}
}

$processes = `ps -jAww -o command | grep -e 'TiVoDLPipe'`;
@lines = split('\n', $processes);
foreach $n (@lines) {
	if ($n =~ /^[a-z]+\s+(\d+).*cat/) {
		`kill -9 $1`;
	}
	if ($n =~ /^[a-z]+\s+(\d+).*tee/) {
		`kill -9 $1`;
	}
}

`rm -f /tmp/iTiVoDLPipe*-$ENV{'USER'}*`;
