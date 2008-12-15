#!/usr/bin/perl
$file2     = $ARGV[0];
$encoder   = $ARGV[1];

$file2 =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;

$Progress = "/tmp/iTiVo-$ENV{'USER'}/iTiVoDL3";
`dd if=/dev/zero of=$Progress bs=1k count=1`;
`$file2\Contents/Resources/comskip --ini=$file2\Contents/Resources/comskip.ini /tmp/iTiVo-$ENV{'USER'}/iTiVoDLPipe2.mpg >>$Progress 2>&1`;
`rm -f /tmp/iTiVo-$ENV{'USER'}/iTiVoDLPipe3.mpg`;
