#! usr/bin/perl -w


$in_name = shift;
$out_name = shift;
open FILE, "<$in_name" or die "Couldn't open $in_name for reading: $!\n";
open OUT, ">$out_name" || die "Couldn't open $out_name for reading: $!\n";
$numar_diatezaPasiva = 0;
$numar_verbe = 0;
$numar_persI = 0;
$numar_pron = 0;
$percent_vb = 0;
$percent_pron = 0;

while ($line = <FILE>){
	chomp $line;
	if ($line =~ /\t/) {
	@feature = split (/\t/, $line);
	$pos = $feature[5];
	print "$pos\n";
		if ($pos eq "_") {
		next;
		}
		else {
			if ($pos =~ m/Person\=1/) {
			print "Person $1\n";
			$numar_persI ++;

			}
			elsif ($pos =~ m/Voice\=Pass/) {
			print "Voice Passive\n";
			$numar_diatezaPasiva++;

			}

		}
	}
	$pos1 = $feature[3];
	print "$pos1\n";
		if ($pos1 eq "_") {
		next;
		}
		else {
			if ($pos1 =~ m/VERB/) {
			print "VERB\n";
			$numar_verbe++;
			}
			elsif ($pos1 =~ m/PRON/) {
			print "PRON\n";
			$numar_pron++;
			}
			}

}
$percent_vb = $numar_diatezaPasiva / $numar_verbe;
$percent_pron = $numar_persI / $numar_pron;
close OUT;
close FILE;
print "diat pass: $numar_diatezaPasiva\npers I: $numar_persI\nverbe: $numar_verbe\npronume: $numar_pron\nprocentVB: $percent_vb\nprocentPron: $percent_pron";