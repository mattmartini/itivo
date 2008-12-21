#!/usr/bin/perl
use POSIX qw(ceil floor);

$IP = $ARGV[0];
$MAK = $ARGV[1];
$ID_ARG = $ARGV[2];

$anchor = 0;

$shellScript = "curl -s 'https://" . $IP .  ":443/TiVoConnect?Command=QueryContainer&Container=%2FNowPlaying&Recurse=Yes&AnchorOffset=" . $anchor . "' -k --digest -u tivo:" . $MAK;
$file =  `$shellScript`;

$file =~ m/<TotalItems>(.*?)<\/TotalItems>/g;
$TotalItems = $1;

$file =~ s/&amp;/&/g;
$file =~ s/&gt;/>/g;
$file =~ s/&lt;/</g;
$file =~ s/&quot;/"/g;
$file =~ s/&apos;/'/g;
$file =~ s/\|/-/g;

while ($anchor < $TotalItems) {
    @shows = split(/<Item>/, $file);
    $count = 0;
    foreach (@shows) {
	$count += 1;
	$output = "|";
	$show = $_;
	$show =~ m/<Url>http.*id=(.*)<\/Url>/;
	if ($1 > 0) {
	    $id = $1;
	    $output = $output . "$id|";
	    if ($show =~ m/<SeriesId>(.*?)<\/SeriesId>/) {
		$output = $output . "$1|";
	    }
	    else {
		$output = $output . "|";
	    }
	    if ($show =~ m/<ProgramId>(.*?)<\/ProgramId>/) {
		$output = $output . "$1|";
	    }
	    else {
		$output = $output . "|";
	    }
	    if ($show =~ m/<SourceChannel>(.*?)<\/SourceChannel>/) {
		$output = $output . "$1|";
	    }
	    else {
		$output = $output . "|";
	    }
	    if ($show =~ m/<SourceStation>(.*?)<\/SourceStation>/) {
		$output = $output . "$1|";
	    }
	    else {
		$output = $output . "|";
	    }
	    if ($id eq $ID_ARG) {
		print "$output\n";
		exit(0);
	    }
	}
    }
    $anchor += $count;
    if ($anchor < $TotalItems) {
	$shellScript = "curl -s 'https://" . $IP . ":443/TiVoConnect?Command=QueryContainer&Container=%2FNowPlaying&Recurse=Yes&AnchorOffset=" . $anchor . "' -k --digest -u tivo:" . $MAK;
	$file =  `$shellScript`;
	$count = 0;
    }
    print "|$ID_ARG|||||\n";
}
