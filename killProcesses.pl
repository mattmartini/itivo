#!/usr/bin/perl

# going through in order trying to kill gently first, and then again hard

$processes = `ps -jAww -o command | grep -e 'iTiVo.app'`;
@lines = split('\n', $processes);
foreach $n (@lines) {
	if ($n =~ /^[a-z]+\s+(\d+).*\/curl/) {
		`kill $1`;
	}
}
foreach $n (@lines) {
	if ($n =~ /^[a-z]+\s+(\d+).*\/tivodecode/) {
		`kill $1`;
	}
}
foreach $n (@lines) {
	if ($n =~ /^[a-z]+\s+(\d+).*\/mencoder/) {
		`kill $1`;
	}
}
foreach $n (@lines) {
	if ($n =~ /^[a-z]+\s+(\d+).*\/download/) {
		`kill $1`;
	}
}
$processes = `ps -jAww -o command | grep -e 'TiVoDLPipe'`;
@lines = split('\n', $processes);
foreach $n (@lines) {
	if ($n =~ /^[a-z]+\s+(\d+).*\/cat/) {
		`kill $1`;
	}
}

sleep 1;
$processes = `ps -jAww -o command | grep -e 'iTiVo.app'`;
@lines = split('\n', $processes);
foreach $n (@lines) {
	if ($n =~ /^[a-z]+\s+(\d+).*\/curl/) {
		`kill -9 $1`;
	}
}
foreach $n (@lines) {
	if ($n =~ /^[a-z]+\s+(\d+).*\/tivodecode/) {
		`kill -9 $1`;
	}
}
foreach $n (@lines) {
	if ($n =~ /^[a-z]+\s+(\d+).*\/mencoder/) {
		`kill -9 $1`;
	}
}
foreach $n (@lines) {
	if ($n =~ /^[a-z]+\s+(\d+).*\/download/) {
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
