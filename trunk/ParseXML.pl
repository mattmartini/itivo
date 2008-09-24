#!/usr/bin/perl
use POSIX qw(ceil floor);

$IP = $ARGV[0];
$MAK = $ARGV[1];
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
		$output = "|";
		$show = $_;
		$show =~ m/<Url>http.*id=(.*)<\/Url>/;
		if ($1 > 0) {
			$id = $1;
			if ($show =~ m/<Title>(.*?)<\/Title>/) {
				$output = $output . "$1|";
			}
			else {
				$output = $output . "|";
			}
			if ($show =~ m/<EpisodeTitle>(.*?)<\/EpisodeTitle>/) {
				$output = $output . "$1|";
			}
			else {
				$output = $output . "|";
			}
#			if ($show =~ m/<Description>(.*?)( Copyright Tribune Media Services, Inc.)?<\/Description>/) {
#				$output = $output . "$1|";
#			}
#			else {
#				$output = $output . "|";
#			}
			if ($show =~ m/<CaptureDate>0x(.*?)<\/CaptureDate>/) {
				$timestamp = hex($1);
				($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($timestamp+15);
				#if ($hour == 0) {
				#	$hour = 12;
				#	$merd = "am";
				#}
				#elsif ($hour > 12) {
				#	$merd = "pm";
				#	$hour = $hour - 12;
				#}
				#else {
				#	$merd = "am";
				#}
				#$year = substr($year + 1900, 2, 2);
				$year = $year + 1900;
				$mon = $mon + 1;
				$output = $output . sprintf ("%04d-%02d-%02d %02d:%02d|", $year, $mon, $mday, $hour, $min);
			}
			else {
				$output = $output . "|";
			}
			if ($show =~ m/<Duration>(.*?)<\/Duration>/) {
				$duration = $1 + 3000;
				$duration = floor($duration / 60000);
				$hours = floor($duration / 60);
				$min = $duration - ($hours * 60);
				if ($hours == 0) {$hours = "0";}
				if ($min == 0) {$min = "00";}
				elsif ($min < 10) {$min = "0" . $min;}
				$output = $output . "$hours:$min|";
			}
			else {
				$output = $output . "|";
			}
			if ($show =~ m/<SourceSize>(.*?)<\/SourceSize>/) {
				$output = $output . "$1|";
			}
			else {
				$output = $output . "|";
			}
			$output = $output . "$id|";
			if ($show =~ m/<Url>urn:tivo:image:suggestion-recording<\/Url>/) {
				$output = $output . "1";
			}
			if ($show !~ m/<InProgress>Yes<\/InProgress>/ && $show !~ m/<CopyProtected>Yes<\/CopyProtected>/) {
				$output = $output .  "\n";
				print $output;
			}
		}
	}
	$anchor = $anchor + 128;
	if ($anchor < $TotalItems) {
		$shellScript = "curl -s 'https://" . $IP . ":443/TiVoConnect?Command=QueryContainer&Container=%2FNowPlaying&Recurse=Yes&AnchorOffset=" . $anchor . "' -k --digest -u tivo:" . $MAK;
		$file =  `$shellScript`;
	}
}