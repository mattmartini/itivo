#!/usr/bin/perl
use POSIX qw(ceil floor setsid);

$IP = $ARGV[0];
$MAK = $ARGV[1];
$anchor = 0;

$CacheDir = "$ENV{'HOME'}/Library/Caches/iTiVo";
$CacheFile = "$CacheDir/XMLCache-$IP";
$usedCache = 0;

# Make sure we have a place to cache the results
`mkdir -p $CacheDir`;

$fetchScript = "curl -q -s 'https://" . $IP .  ":443/TiVoConnect?Command=QueryContainer&Container=%2FNowPlaying&Recurse=Yes&AnchorOffset=" . $anchor . "' -k --digest -u tivo:" . $MAK;

if ((-e $CacheFile) && (((-M $CacheFile) * 24 * 60) < 5)) {
    # We have already fetched the list from this tivo within the last five minutes, so just use the cached value
    $file =  `cat $CacheFile`;
#    if (((-M $CacheFile) * 24 * 60 * 60) > 5) {
#	# Fetch the new version in the background
#	unless ($pid = fork) {
#	    unless (fork) {
#		setsid;
#		exec "touch -c $CacheFile && $fetchScript > $CacheFile.$^T && mv $CacheFile.$^T $CacheFile";
#		exit 0;
#	    }
#	    exit 0;
#	}
#	waitpid($pid,0);
#    }
} else {
    $file = `$fetchScript`;
    open (RESULT, ">$CacheFile");
    print RESULT "$file";
    close (RESULT);
}

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
		$current_size = $1 / 1024 / 1024;
		$output = $output . "$current_size|";
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

	    if ($show =~ m/<HighDefinition>Y.*<\/HighDefinition>/) {
		$output = $output . "√|";
	    }
	    else {
		$output = $output . "|";
	    }

	    $output = $output . "$id|";

	    $flags = 0;
	    if ($show =~ m/<Url>urn:tivo:image:suggestion-recording<\/Url>/) {
		$flags = 1;
		$show_type = "suggestion";
	    }
	    if ($show =~ m/<Url>urn:tivo:image:expired-recording<\/Url>/) {
		$flags = 2;
		$show_type = "expired";
	    }
	    if ($show =~ m/<Url>urn:tivo:image:expires-soon-recording<\/Url>/) {
		$flags = 3;
		$show_type = "expires-soon";
	    }
	    if ($show =~ m/<Url>urn:tivo:image:save-until-i-delete-recording<\/Url>/) {
		$flags = 4;
		$show_type = "save-until-delete";
	    }
	    if ($show =~ m/<CopyProtected>Yes<\/CopyProtected>/) {
		$flags=5;
		$show_type = "copyrighted";
	    }
	    $output = $output . "$flags";

	    if ($show =~ m/<InProgress>Yes<\/InProgress>/) {
		$show_type = "in_progress";
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
