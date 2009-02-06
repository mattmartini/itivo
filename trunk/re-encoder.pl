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

$TivoDir = "$ENV{'USER'}";
$TivoDir =~ tr/ :\//_../;
$TivoDir = "/tmp/iTiVo-$TivoDir";


$Src = "$TivoDir/iTiVoDLPipe2.mpg";
$Progress = "$TivoDir/iTiVoDL2";
$Edl = "$TivoDir/iTiVoDLPipe2.edl";

`touch $Edl`;
$shellScript = "";

if ($Encoder eq "mencoder") {
  $shellScript = $shellScript . $AppDir . "Contents/Resources/mencoder -edl $Edl";
  $shellScript = $shellScript . " $VideoOpts $AudioOpts $OtherOpts -o $Target $Src >$Progress 2>&1";
} elsif ($Encoder eq "HandBrake") {
	$shellScript = $shellScript . $AppDir . "Contents/Resources/HandBrakeCLI";
	$shellScript = $shellScript . " $VideoOpts $AudioOpts $OtherOpts -o $Target -i $Src >$Progress 2>&1 < /dev/null";
} elsif ($Encoder eq "cat") {
	$shellScript = $shellScript . "cat -u";
	$shellScript = $shellScript . " $VideoOpts $AudioOpts $OtherOpts $Src > $Target";
} elsif ($Encoder eq "turbo.264") {
	$shellScript = $shellScript . "osascript $AppDir\/Contents/Resources/Scripts/elgato.scpt";
	$shellScript = $shellScript . " $Src $Target $Progress $VideoOpts $AudioOpts $OtherOpts 2>&1";
} elsif ($Encoder eq "ffmpeg") {
	$ENV{'PATH'} = "$ENV{'PATH'}:/Applications/pyTivoX.app/Contents/Resources";
	$shellScript = $shellScript . "ffmpeg ";
	$shellScript = $shellScript . " -i $Src $VideoOpts $AudioOpts $OtherOpts $Target >$Progress 2>&1";
} else  {
	$shellScript = $shellScript . $Encoder;
	$shellScript = $shellScript . " $Src > $Target";
}

print "\n\n$shellScript\n\n";
system($shellScript);

`rm -f $TivoDir/iTiVoDLPipe $TivoDir/iTiVoDLPipe2.mpg`;
