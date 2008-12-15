#!/usr/bin/perl

$file2 = $ARGV[0];
$MAK   = $ARGV[1];

$file2 =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;

`mkdir -p /tmp/iTiVo-$ENV{'USER'}/iTiVoTDC`;
chdir "/tmp/iTiVo-$ENV{'USER'}/iTiVoTDC";

$shellScript2 = "$file2\Contents/Resources/tivodecode -n -D -m $MAK -o /tmp/iTiVo-$ENV{'USER'}/iTiVoDLPipe2.mpg /tmp/iTiVo-$ENV{'USER'}/iTiVoDLPipe";

print "$shellScript2\n";
system($shellScript2);

`mv chunk-01-0001.xml /tmp/iTiVo-$ENV{'USER'}/iTiVoDLMeta.xml`;
chdir;
`rm -rf /tmp/iTiVo-$ENV{'USER'}/iTiVoDLPipe /tmp/iTiVo-$ENV{'USER'}/iTiVoTDC`;
