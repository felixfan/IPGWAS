#!/usr/bin/perl

####################################################################
# make_alt_pheno.pl	-	CO'D 09/12/08
# create an alternative phenotye dataset from a *.fam input file
####################################################################

if ($ARGV[1] eq '') {
	print "
USAGE:
\tARGV[0] = original plink file *.fam file (e.g. example.fam)
\tARGV[1] = the number of alternative phenotypes to generate
\tThe script generates alternative phenotypes for cases and controls while preserving the overall case/control ratio

"; die;
}
if ($ARGV[1] < 1000) { 
	print "\n#### WARNING!\tYou specified [$ARGV[1]\] alternative phenotypes to generate. This is quite low. You should really specify at least 1000."; 
}
else {
	print "\nYou specified [$ARGV[1]\] alternative phenotypes to generate.\n";
}

print "\n\nReading FAM file: [$ARGV[0]\]...";

## Error check and read in FAM dat
@idarray=(); $index = 0;
open (IN, "$ARGV[0]");
while (<IN>) {
	@split = split(/\s+/, $_);
	$siz = @split;
	if ($siz != 6) {
		die("\nERROR: there must be 6 columns in $ARGV[0] - family_id, individual_id, paternal_id, maternal_id, sex, phenotype (1=unaffected, 2=affected)\n"); 
	}
	else {
		$iid = $split[1]; $pheno = $split[5];
		if (($pheno != 1) && ($pheno != 2)) {
			die("\n\nERROR: phenotype [ $pheno ] for ID [ $iid ] must be 1 (control) or 2 (case) only\n\n");
		}	
		else {
			$PHENO[$index] = $pheno;
		}
		$index++;
	}
}
close IN;

$size = @PHENO;
print "[$size\] individuals read.\nGenerating [$ARGV[1]\] alternative phenotypes\n\n";

## create alternative phenotype file - store details in 2D array
$i = 0; 
while ($i < $ARGV[1]) { # loop over number of alternative phenotypes that are desired
	if (($i%100) == 0) {print "$i/$ARGV[1]\n"; }
	@this = randarray(@PHENO);
	$j = 0;
	while ($j < @this) {
		$ALTPHENO[$i][$j] = $this[$j]; 
	$j++;
	}
$i++;
}

## print to alternative phenotype file
open (IN2, "$ARGV[0]");	
open (OUT, ">$ARGV[0].altpheno.$ARGV[1].txt");
print "\nPrinting alternative phenotypes to $ARGV[0].altpheno";
$a = 0; 
while (<IN2>) {
	@split = split(/\s+/, $_);
	$line = "$split[0]\t$split[1]\t";
	$b = 0;
	while ($b < $ARGV[1]) {
		$line .= "$ALTPHENO[$b][$a]\t";
	$b++;
	}
	chop($line);
	print OUT "$line\n";
	$a++;
}

print "\n\nDONE.\n
##########################################################################
\nAlternative phenotypes written to \'$ARGV[0].altpheno.$ARGV[1].txt\'.
This file may now be used as input for plink.
\te.g. ./plink.exe --bfile example --pheno $ARGV[0].altpheno.$ARGV[1].txt --all-pheno --assoc 
\n\t*** NOTE: this can take a LONG time! ***\n
##########################################################################
\n";


### SUBROUTINES ###
sub randarray {
        my @array = @_;
        my @rand = undef;
        $seed = $#array + 1;
        my $randnum = int(rand($seed));
        $rand[$randnum] = shift(@array);
        while (1) {
                my $randnum = int(rand($seed));
                if ($rand[$randnum] eq undef) {
                        $rand[$randnum] = shift(@array);
                }
                last if ($#array == -1);
        }
        return @rand;
}
