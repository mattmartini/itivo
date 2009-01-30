#!/usr/bin/perl

# going through in order trying to kill gently first, and then again hard

@tokill = ("curl", "http-fetcher.pl", "tivodecode", "comskip", "mencoder", "HandBrakeCLI", "osascript", "tivo-decoder.pl", "remove-commercials.pl", "re-encoder.pl", "cat", "tee" );

foreach $procname (@tokill) {
	$processes = `ps -ww -U $ENV{'USER'} -o pid,command | grep -e 'iTiVo'`;
	@lines = split('\n', $processes);
	foreach $n (@lines) {
		if ($n =~ /^\s*(\d+)\s+(\S+)/) {
		    $pid = $1;
		    if ($2 =~ /$procname$/) {
					print "$procname:$pid ,";
					`kill $pid`;
		    }
		}
	}
}

sleep 1;

foreach $procname (@tokill) {
	$processes = `ps -ww -U $ENV{'USER'} -o pid,command | grep -e 'iTiVo'`;
	@lines = split('\n', $processes);
	foreach $n (@lines) {
		if ($n =~ /^\s*(\d+)\s+(\S+)/) {
		    $pid = $1;
		    if ($2 =~ /$procname$/) {
					`kill -9 $pid`;
		    }
		}
	}
}

`rm -f /tmp/iTiVo-$ENV{'USER'}/iTiVoDLPipe*`;

