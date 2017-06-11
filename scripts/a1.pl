#! usr/bin/perl -w




$in_name = shift;
$out_name = shift;
$out_name2 = "faraid_" . $out_name;

#### Ca sa rulezi acest program trebuie sa specifici un fisier de intrare  si  un fisier de iesire.Programul va numara numarul de linii ,cuvinte si litere din document.

open FILE, "<$in_name" or die "Couldn't open for reading: $!\n";
open OUT, ">$out_name" || die "Couldn't open for reading: $!\n";
open OUT2, ">$out_name2" || die "Couldn't open for reading: $!\n";

$lines   = 0;
$words   = 0;
$letters = 0;
$id =0;
$mediecuv=0;

while ($line = <FILE>){
    	if($line =~m/^\s*(Supplementary material|references|Acknowledgement)\s*$/i){
		last;
	}
	else{
	$line =~ s/( vs| mr| dr| al|\d)\./$1SSSSSSSSSSSSSSSMNHDN/g;
	$line =~ s/\t/\s/g;
	$line =~ s/(\. |\? |\n)/! /g;
	$line =~ s/!!/!/g;
	$line =~ s/SSSSSSSSSSSSSSSMNHDN/\./g;
	@sentences = split (/!/, $line);
	foreach $sen (@sentences){
		if(($sen =~ m/^\s+$/)|
		($sen =~ m/^\s*[a-zA-Z1-9]\.*\s*$/) |
		($sen =~ m/^\s*\(\d\)\s*$/) |
		($sen =~ m/^\s*[=?†*]+\s*$/)|
		($sen =~ m/^\s*(\d+\.\d+)\s*$/)|
		($sen =~ m/^\s*(\d+\s*)*(\w+)\s*$/)|
		($sen =~ m/^\s*(table|figure)\s/i)
		){
                next;
	}
	else{
            $id++;
            @words = split( " ", $sen );
            $nwords = @words;
            print OUT "$id \t $nwords\t$sen \n";
            print OUT2 "$sen\n";

	}
        }
	}

    $nwords = @words;

    for ( $i = 0 ; $i < $nwords ; $i = $i + 1 ) {
        @letters = split( "", $words[$i] );

        $nletters = @letters;


        $letters = $letters + $nletters;
    }

    $words = $words + $nwords;
    $lines = $lines + 1;
    $mediecuv = $words/$id;
}
print "$in_name contains $id sentences, $words words " . "and $letters letters.\n";
print " Medie cuvinte: $mediecuv\n";

close OUT;
close FILE;








