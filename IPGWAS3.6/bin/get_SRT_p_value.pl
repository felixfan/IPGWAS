#!/usr/bin/perl

####################################################################
# get_SRT_p_value.pl	-	CO'D 12/12/08
# Get the permuted p-value from the distribution of p-values of ratios in simulations 
# see North et al. am j hum genet 71 2002
####################################################################

### specify input
### revised on 16 Jul 2011
my ($ratio, $pval, $dir)=@ARGV;

# if ($ARGV[1] eq '') {
	# die("\n\nERROR:\n\tEnter SRT processed original GWAS result as ARGV[0] (e.g. example_original_assoc.assoc.forSRT.p0.05.ratios)\n\tEnter p_value cutoff as ARGV[1]\n\n");
# }
# chomp($ARGV[1]);
# $pval = $ARGV[1];

# open (IN, $ARGV[0]) || die("\nERROR: enter file of pw and ratios as ARGV[0]\n");
open (IN, $ratio) || die("\nERROR: enter file of pw and ratios as $ratio\n");
while (<IN>) {
	@split = split(/\s+/, $_);
	$PW{$split[0]} = $split[1];	
	$R{$split[0]} = 1;
	$N{$split[0]} = 1;
}

# opendir(DIR, ".");
opendir(DIR, $dir);
@FILES= readdir(DIR); 
$files = 0; $processed = 0;
while ($files < @FILES) {
	if ($FILES[$files] =~ /.ratios$/) { 	
		$file = $FILES[$files];
		if  ($file ne $ratio) { # ignore original result
			open (IN, "$file");
			$r = 1; 
			while (<IN>) {
				@split = split(/\s+/, $_);
				# get r
				if ($split[1] >= $PW{$split[0]}) { $R{$split[0]}++; }
				$N{$split[0]}++;
 			}
			$processed++;
		}
	}
	$files++;
}
		
open (OUT, ">$ratio.SRTp.txt"); $pwind = 0;
foreach $key (keys %N) {
	$pwind++;
	$p = $R{$key}/$N{$key};
	print OUT "$key\t$R{$key}\t$N{$key}\t$p\n"; 
}

print "\n\nDONE.\n
##########################################################################
Processed [$pwind\] pathways
[$processed\] *.ratios files were used to calculate empirical p-value
Pathways and their SRT p-values are listed in \'$ARGV[0].SRTp.txt\'
##########################################################################
\n";

