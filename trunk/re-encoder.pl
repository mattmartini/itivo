#!/usr/bin/perl

$AppDir = $ARGV[0];
$DestDir = $ARGV[1];
$TargetFile = $ARGV[2];
$Encoder = $ARGV[3];
$VideoOpts = $ARGV[4];
$AudioOpts = $ARGV[5];
$OtherOpts = $ARGV[6];

$AppDir =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$DestDir =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$TargetFile =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$TargetFile =~ s/:/-/g;
$TargetFile =~ s/\//:/g;
$Target = $DestDir.$TargetFile;


$Src = "/tmp/iTiVoDLPipe2-$ENV{'USER'}.mpg";
$Progress = "/tmp/iTiVoDL2-$ENV{'USER'}";
$Edl = "/tmp/iTiVoDLPipe2-$ENV{'USER'}.edl";

`touch $Edl`;
$shellScript = "";

if ($Encoder eq "mencoder") {
 $shellScript = $shellScript . $AppDir . "Contents/Resources/mencoder -edl $Edl";
} elsif ($Encoder eq "ffmpeg") {
	$shellScript = $shellScript . $AppDir . "Contents/Resources/mencoder -edl $Edl";
} elsif ($Encoder eq "cat") {
	$shellScript = $shellScript . "cat -u";
} elsif ($Encoder eq "turbo.264") {
	$shellScript = $shellScript . "osascript $AppDir/Contents/Resources/Scripts/elgato.scpt";
} else  {
	$shellScript = $shellScript . $Encoder;
}

$shellScript = $shellScript . " $VideoOpts $AudioOpts $OtherOpts ";

if ($Encoder eq "mencoder") {
	$shellScript = $shellScript . "-o $Target $Src >$Progress 2>&1";
} elsif ($Encoder eq "ffmpeg") {
	$shellScript = $shellScript . "-o $Target $Src >$Progress 2>&1";
} elsif ($Encoder eq "cat") {
	$shellScript = $shellScript . "$Src > $Target";
} elsif ($Encoder eq "turbo.264") {
	$shellScript = $shellScript . "$Src $Target $Progress 2>&1";
} else  {
	$shellScript = $shellScript . "$Src > $Target";
}

print "\n\n$shellScript\n\n";
print `$shellScript`;

`rm -f /tmp/iTiVoDLPipe-$ENV{'USER'} /tmp/iTiVoDLPipe2-$ENV{'USER'}.mpg`;
