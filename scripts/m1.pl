use List::Compare;


$in_name = shift;
$in2_name = shift;

open FILE, "<$in_name" or die "Couldn't open $in_name for reading: $!\n";
open FILE2, "<$in2_name" or die "Couldn't open $in2_name for reading: $!\n";

while ($line = <FILE>){
	chomp $line;
	@aa=(@aa, $line);

}
close FILE;

while ($line = <FILE2>){
	chomp $line;
	@bb=(@bb, $line);

}
close FILE2;

$lc = List::Compare->new(\@aa, \@bb);
@intersection = $lc->get_intersection;

print (scalar @intersection / scalar @aa);
