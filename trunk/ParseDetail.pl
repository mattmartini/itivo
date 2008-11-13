#!/usr/bin/perl

$IP = $ARGV[0];
$MAK = $ARGV[1];
$ID = $ARGV[2];
$anchor = 0;

$shellScript = "curl -s 'https://" . $IP .  ":443/TiVoVideoDetails?id=" . $ID . "' -k --digest -u tivo:" . $MAK;
#$shellScript = "cat ~/Desktop/detail.xml";

$show =  `$shellScript`;

$show =~ s/&amp;/&/g;
$show =~ s/&gt;/>/g;
$show =~ s/&lt;/</g;
$show =~ s/&quot;/"/g;
$show =~ s/&apos;/'/g;
$show =~ s/\|/~/g;

$output = "";
$output = $output . "$ID|";
if ($show =~ m/<title>(.*?)<\/title>/) {
	$output = $output . "$1|";
}
else {
	$output = $output . "|";
}
if ($show =~ m/<episodeTitle>(.*?)<\/episodeTitle>/) {
	$output = $output . "$1|";
}
else {
	$output = $output . "|";
}
if ($show =~ m/<description>(.*?)( Copyright Tribune Media Services, Inc.)?<\/description>/) {
	$output = $output . "$1|";
}
else {
	$output = $output . "|";
}
if ($show =~ m/<recordingQuality value="(.*?)">(.*?)<\/recordingQuality>/) {
	$quality = "\L\u$2\E"; 
	$output = $output . "$1|$quality|";
}
else {
	$output = $output . "100|HD|";
}
if ($show =~ m/<recordedDuration>(.*?)<\/recordedDuration>/) {
	#$output = $output . "$1|";
	$time = $1;
	if ($time =~ /(\d+)H/) {
		$hour = $1;
	}
	if ($time =~ /(\d+)S/) {
		$second = $1;
	}
	if ($time =~ /(\d+)M/) {
		$minute = $1;
	}
	$second = $second + 15;
	if ($second > 60) {
		$second = $second - 60;
		$minute++;
	}
	if ($minute >= 60) {
		$minute = $minute - 60;
		$hour++;
	}
	if ($hour == 0) {
		$hour = "0";
	}
	if ($minute == 0) {
		$minute = "00";
	}
	elsif ($minute < 10) {
		$minute = "0" . $minute;
	}
	$output = $output . "$hour:$minute|";
}
else {
	$output = $output . "|";
}
if ($show =~ m/<vProgramGenre>(.*?)<\/vProgramGenre>/) {
	$genre = $1;
	$genre =~ s/<\/element><element>/, /g;
	$genre =~ s/<.*?>//g;
	$output = $output . "$genre|";
}
else {
	$output = $output . "|";
}
if ($show =~ m/<displayMajorNumber>(.*?)<\/displayMajorNumber>/) {
	$output = $output . "$1|";
}
else {
	$output = $output . "|";
}


if ($show =~ m/<vActor>(.*?)<\/vActor>/) {
$actors = $1;
$actors =~ s/<\/element><element>/, /g;
$actors =~ s/([A-Za-z.'\-]*)~([A-Za-z.'\-]*)/$2 $1/g;
$actors =~ s/<.*?>//g;
$output = $output . "$actors";
}
if ($show =~ m/<vGuestStar>(.*?)<\/vGuestStar>/) {
$actors = $1;
$actors =~ s/<\/element><element>/, /g;
$actors =~ s/([A-Za-z.'\-]*)~([A-Za-z.'\-]*)/$2 $1/g;
$actors =~ s/<.*?>//g;
$output = $output . "\n\nGUESTS: $actors";
}
$output = $output . "|";


if ($show =~ m/<vWriter>(.*?)<\/vWriter>/) {
$actors = $1;
$actors =~ s/<\/element><element>/, /g;
$actors =~ s/([A-Za-z.'\-]*)~([A-Za-z.'\-]*)/$2 $1/g;
$actors =~ s/<.*?>//g;
$output = $output . "$actors|";
}
else {
$output = $output . "|";
}

if ($show =~ m/<vDirector>(.*?)<\/vDirector>/) {
$actors = $1;
$actors =~ s/<\/element><element>/, /g;
$actors =~ s/([A-Za-z.'\-]*)~([A-Za-z.'\-]*)/$2 $1/g;
$actors =~ s/<.*?>//g;
$output = $output . "$actors|";
}
else {
$output = $output . "|";
}

if ($show =~ m/<mpaaRating.*?>(.*?)<\/mpaaRating>.*<tvRating.*?>(.*?)<\/tvRating>/) {
		$rating1 = $1;
		$rating2 = $2;
		$rating1 =~ s/_/-/g;
		$rating2 =~ s/_//g;
		$output = $output . "$rating1, TV-$rating2|";
}
elsif ($show =~ m/<mpaaRating.*?>(.*?)<\/mpaaRating>/) {
		$rating1 = $1;
		$rating1 =~ s/_/-/g;
		$output = $output . "$rating1|";
}
elsif ($show =~ m/<tvRating.*?>(.*?)<\/tvRating>/) {
		$rating2 = $1;
		$rating2 =~ s/_//g;
		$output = $output . "TV-$rating2|";
}
else {
	$output = $output . "|";
}
if ($show =~ m/<originalAirDate>(.*?)<\/originalAirDate>/) {
	$originalAirDate = substr($1, 0, 10);
	$originalAirYear = substr($1, 0, 4);
	$output = $output . "$originalAirDate|$originalAirYear|";
} else {
	$output = $output . "||";
}

if ($show =~ m/<episodeNumber>(.*?)<\/episodeNumber>/) {
  if ($1 != 0) {
	  $output = $output . "$1|";
  } else {
    $output = $output . "|";
  }
} else {
	$output = $output . "|";
}


print substr($output, 0, length($output)-1);
