#!/usr/bin/perl

$TivoDir = "$ENV{'USER'}";
$TivoDir =~ tr/ :\//_../;
$TivoDir = "/tmp/iTiVo-$TivoDir";

$file = "$TivoDir/iTiVoDL";

my $downloadedSize = `cat $file | tr '\r' '\n' | awk 'NF > 0 {print \$4}' | tail -n 1`;
chomp ($downloadedSize);
my $unit = substr $downloadedSize,-1,1;
my $base = chop($downloadedSize);

if ($unit eq "k") {
    printf ("%.1f", $downloadedSize / 1024);
}
elsif ($unit eq "M") {
    printf ("%.1f", $downloadedSize);
}
elsif ($unit eq "G") {
    printf ("%.1f", $downloadedSize * 1024);
}
else {
    printf ("%.1f", $downloadedSize / (1024 * 1024));
}
