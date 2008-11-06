#!/usr/bin/perl

$file2 = $ARGV[0];
$MAK   = $ARGV[1];

$file2 =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;

$shellScript2 = "$file2\Contents/Resources/tivodecode -n -m $MAK -o /tmp/iTiVoDLPipe2-$ENV{'USER'}.mpg /tmp/iTiVoDLPipe-$ENV{'USER'}";

`$shellScript2`;

`rm /tmp/iTiVoDLPipe-$ENV{'USER'}`;
