#!/usr/bin/perl

# going through in order trying to kill gently first, and then again hard

@tokill = ("curl", "tivodecode", "comskip", "mencoder", "http-fetcher", "tivo-decoder", "remove-commercials", "re-encoder", "cat", "tee" );

foreach $procname (@tokill) {
	$processes = `ps -ww -U $ENV{'USER'} -o pid,command | grep -e 'iTiVo'`;
	@lines = split('\n', $processes);
	foreach $n (@lines) {
		if ($n =~ /^(\d+)\s+\S*$procname/) {
			`kill $1`;
		}
	}
}

sleep 1;
foreach $procname (@tokill) {
	$processes = `ps -ww -U $ENV{'USER'} -o pid,command | grep -e 'iTiVo'`;
	@lines = split('\n', $processes);
	foreach $n (@lines) {
		if ($n =~ /^(\d+)\s+\S*$procname/) {
			`kill -9 $1`;
		}
	}
}

`rm -f /tmp/iTiVoDLPipe*-$ENV{'USER'}*`;

