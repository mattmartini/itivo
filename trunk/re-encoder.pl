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

if ($Encoder == "mencoder") {
 $shellScript = $shellScript . $AppDir . "Contents/Resources/mencoder -edl $Edl";
} elsif ($Encoder == "ffmpeg") {
	$shellScript = $shellScript . $AppDir . "Contents/Resources/mencoder -edl $Edl";
} elsif ($Encoder == "cat") {
	$shellScript = $shellScript . "cat -u";
} else  {
	$shellScript = $shellScript . $Encoder;
}

$shellScript = $shellScript . " $VideoOpts $AudioOpts $OtherOpts ";

if ($Encoder == "mencoder") {
	$shellScript = $shellScript . "-o $Target $Src >$Progress 2>&1";
} elsif ($Encoder == "ffmpeg") {
	$shellScript = $shellScript . "-o $Target $Src >$Progress 2>&1";
} elsif ($Encoder == "cat") {
	$shellScript = $shellScript . "$Src > $Target";
} else  {
	$shellScript = $shellScript . "$Src > $Target";
}

`$shellScript`;

`rm -f /tmp/iTiVoDLPipe-$ENV{'USER'} /tmp/iTiVoDLPipe2-$ENV{'USER'}.mpg`;
