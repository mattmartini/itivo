#!/usr/bin/perl
$file2 = $ARGV[0];
$file2 =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;

$Progress = "/tmp/iTiVoDL3-$ENV{'USER'}";
`dd if=/dev/zero of=$Progress bs=1k count=1`;
`$file2\Contents/Resources/comskip --ini=$file2\Contents/Resources/comskip.ini /tmp/iTiVoDLPipe2-$ENV{'USER'}.mpg >>$Progress 2>&1`;
`rm -f /tmp/iTiVoDLPipe3-$ENV{'USER'}.mpg`;
