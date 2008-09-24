#!/usr/bin/perl

$processes = `ps -jAww -o command | grep -e 'iTiVo.app'`;

@lines = split('\n', $processes);

foreach $n (@lines) {
	if ($n =~ /^[a-z]+\s+(\d+).*\/download/) {
		`kill -9 $1`;
	}
	if ($n =~ /^[a-z]+\s+(\d+).*\/curl/) {
		`kill $1`;
	}
	if ($n =~ /^[a-z]+\s+(\d+).*\/tivodecode/) {
		`kill $1`;
	}
	if ($n =~ /^[a-z]+\s+(\d+).*\/mencoder/) {
		`kill -9 $1`;
	}
}

$processes = `ps -jAww -o command | grep -e 'TiVoDLPipe'`;

@lines = split('\n', $processes);

foreach $n (@lines) {
	if ($n =~ /^[a-z]+\s+(\d+).*\/cat/) {
		`kill -9 $1`;
	}
}
