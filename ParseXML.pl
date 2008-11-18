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

$space_expires_soon = $space_expired = $space_save_until = $space_copyrighted = $space_in_progress = $space_suggestion = $space_regular = 0;
$total_shows = 0;
$final_result = "";

while ($anchor < $TotalItems) {
    @shows = split(/<Item>/, $file);
    $count = 0;
    foreach (@shows) {
	$count += 1;
	$total_shows += 1;
	$current_size = 0;
	$show_type = "regular";
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
	    if ($show =~ m/<CaptureDate>0x(.*?)<\/CaptureDate>/) {
		$timestamp = hex($1);
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($timestamp+15);
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
		$current_size = $1;
	    }
	    else {
		$output = $output . "|";
	    }
	    $output = $output . "$id|";

	    $flags = 0;
	    if ($show =~ m/<Url>urn:tivo:image:suggestion-recording<\/Url>/) {
		$flags |= 1;
		$show_type = "suggestion";
	    }
	    if ($show =~ m/<Url>urn:tivo:image:expired-recording<\/Url>/) {
		$flags |= 2;
		$show_type = "expired";
	    }
	    if ($show =~ m/<Url>urn:tivo:image:expires-soon-recording<\/Url>/) {
		$show_type = "expires-soon";
	    }
	    if ($show =~ m/<Url>urn:tivo:image:save-until-i-delete-recording<\/Url>/) {
		$show_type = "save-until-delete";
	    }
	    $output = $output . "$flags";

	    if ($show =~ m/<InProgress>Yes<\/InProgress>/) {
		$show_type = "in_progress";
	    } elsif ($show =~ m/<CopyProtected>Yes<\/CopyProtected>/) {
		$show_type = "copyrighted";
	    } else {
		$output = $output .  "\n";
		$final_result = $final_result . $output;
	    }

	    if ($show_type eq "regular") {
		$space_regular += $current_size;
	    } elsif ($show_type eq "suggestion") {
		$space_suggestion += $current_size;
	    } elsif ($show_type eq "expired") {
		$space_expired += $current_size;
	    } elsif ($show_type eq "expires-soon") {
		$space_expires_soon += $current_size;
	    } elsif ($show_type eq "in_progress") {
		$space_in_progress += $current_size;
	    } elsif ($show_type eq "copyrighted") {
		$space_copyrighted += $current_size;
	    } elsif ($show_type eq "save-until-delete") {
		$space_save_until += $current_size;
	    }	    
	}
    }
    $anchor += $count;
    if ($anchor < $TotalItems) {
	$shellScript = "curl -s 'https://" . $IP . ":443/TiVoConnect?Command=QueryContainer&Container=%2FNowPlaying&Recurse=Yes&AnchorOffset=" . $anchor . "' -k --digest -u tivo:" . $MAK;
	$file =  `$shellScript`;
	$count = 0;
    }
}

$total = $space_regular + $space_suggestion + $space_expired + $space_expires_soon + $space_in_progress + $space_copyrighted + $space_save_until;
$final_result = "$total_shows|$total|$space_regular|$space_suggestion|$space_expired|$space_expires_soon|$space_in_progress|$space_copyrighted|$space_save_until\n" . $final_result;

if ($total > 0) {
    print "$final_result";
}
