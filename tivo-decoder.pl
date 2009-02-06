#!/usr/bin/perl

$file2 = $ARGV[0];
$MAK   = $ARGV[1];

$file2 =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;

$TivoDir = "$ENV{'USER'}";
$TivoDir =~ tr/ :\//_../;
$TivoDir = "/tmp/iTiVo-$TivoDir";

`mkdir -p $TivoDir/iTiVoTDC`;
chdir "$TivoDir/iTiVoTDC";

$shellScript2 = "$file2\Contents/Resources/tivodecode -n -D -m $MAK -o $TivoDir/iTiVoDLPipe2.mpg $TivoDir/iTiVoDLPipe";

print "$shellScript2\n";
system($shellScript2);

`mv chunk-01-0001.xml $TivoDir/iTiVoDLMeta.xml`;
chdir;
`rm -rf $TivoDir/iTiVoDLPipe $TivoDir/iTiVoTDC`;
