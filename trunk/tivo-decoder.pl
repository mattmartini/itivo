#!/usr/bin/perl

$file2 = $ARGV[0];
$MAK   = $ARGV[1];

$file2 =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;

`mkdir -p /tmp/iTiVoTDC-$ENV{'USER'}`;
chdir "/tmp/iTiVoTDC-$ENV{'USER'}";

$shellScript2 = "$file2\Contents/Resources/tivodecode -n -D -m $MAK -o /tmp/iTiVoDLPipe2-$ENV{'USER'}.mpg /tmp/iTiVoDLPipe-$ENV{'USER'}";

print "$shellScript2\n";
system($shellScript2);

`mv chunk-01-0001.xml /tmp/iTiVoDLMeta-$ENV{'USER'}.xml`;
chdir;
`rm -rf /tmp/iTiVoDLPipe-$ENV{'USER'} /tmp/iTiVoTDC-$ENV{'USER'}`;
