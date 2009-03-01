#!/usr/bin/perl
$AppDir = $ARGV[0];
$DestDir = $ARGV[1];
$TargetFile = $ARGV[2];

$AppDir =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$DestDir =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$TargetFile =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
$TargetFile =~ s/:/-/g;
$TargetFile =~ s/\//:/g;
$Target = $DestDir.$TargetFile;

$TivoDir = "$ENV{'USER'}";
$TivoDir =~ tr/ :\//_../;
$TivoDir = "/tmp/iTiVo-$TivoDir";

$Progress = "$TivoDir/iTiVoDL3";

`dd if=/dev/zero of=$Progress bs=1k count=1`;
`$AppDir\Contents/Resources/t2sami -s -o $Target $TivoDir/iTiVoDLPipe2.mpg >>$Progress 2>&1`;
`rm -f $TivoDir/iTiVoDLPipe3.mpg`;
