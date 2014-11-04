#!/usr/bin/perl

####################################################################
# run_SRT_on_all.pl	-	CO'D 17/02/10 (10/12/08)
# runs SRT on all available .forSRT files in current directory
# 	- calculates a ratio of significant to no-significant SNPs within each pathway
####################################################################

### specify input file
### revised on 16 Jul 2011

my ($pval, $file, $dataset)=@ARGV;
=pid
	10/08/09 - changed line 59 - ratio was sig to nsig SNPs, should be sig to all
	21/05/09 - now remove .forSRT files are they are parsed (saves space)
=cut

# if ($ARGV[0] eq '') {
	# print "\nERROR:\n\tPlease enter p-value threshold as ARGV[0] (This threshold determines what p-values are \'significant\' based on the specified cut-off)
# \tPlease enter .forSRT file for original dataset as ARGV[1]\n\n
# "; die;
# }
# if ($ARGV[1] eq '') {
	# print "\nERROR:\n\tPlease enter .forSRT file for original dataset\n\n"; die; 
# }
# if ($ARGV[2] ne '') {
	# print "\n### Alternative pathway dataset was specified (format assumed: [id] [SNP id])\n";
	# $dataset = $ARGV[2];	
# }
# else {
	# $dataset = "KEGG_2_snp_b129.txt"; # default pathway
	# print "\n### Using KEGG as the reference pathway dataset ( format: [pwid] [SNPid] ) (you can specify an alternative as ARGV[1])\n\n";
# }

# $pval = $ARGV[0];
print "P-value threshold for calculating ratios for SRT: [$pval\]\nReading pathway dataset $dataset (may take a while)...";
&readkeggsnp($dataset); 
print "\n\tDONE.\nCalculating SNP ratios for all files with the .forSRT extension...\n";
# $file = $ARGV[1];
&readsig($file,$pval);
$pwindex = 0;
&SRT($pval,$file,1);
&CLEAN; # reset the hash recording significance

print "\n\nDONE.\n
[$file\] processed\n
\n";


############################## SUBROUTINES ##############################
sub SRT {
	$pv = $_[0];
	$f = $_[1];
	open (OUT, ">$f.p$pv.ratios");
	foreach $key (sort keys %KEGGPWSNPS) {		# loop over pws															
		$sigsnp = 0; $nssnp = 0; $ratio = 0;	
		$time = gmtime;
		if (($pwindex%10) == 0) {
			#print "\n\t\tON PATHWAY $pwindex $key...";
		}
		foreach $subkey (sort keys %{$KEGGPWSNPS{$key}}) {	# loop over snpw within pws
			if (($ALLKEGGSNPS{$subkey} ne '') && ($SIG{$subkey} ne '')) { # if SNP is in KEGG *AND* in the association study - N.B.
				if ($SIG{$subkey} == 1) { $sigsnp++; } else {$nssnp++; }
			}
		}
		if ($nssnp == 0 ) {$ratio = 0; } else {	$ratio = $sigsnp/($nssnp+$sigsnp); }
	
		print OUT "$key\t$sigsnp\t$nssnp\t$ratio\n";
		if (($pwindex%10) == 0) {
			#print "sig $sigsnp ns $nssnp";
		}
		$pwindex++;
	}
}

sub readkeggsnp {
	## read in pathways and their genes
	$dataset = $_[0];
	open (PWS, "$dataset") || die("\nERROR: pathways dataset [$dataset\] not found in this directory!\n\n");
	while (<PWS>) {
		#----> hsa00010.gene.snps:rs10918247
		@splitp = split(/\s+/, $_);
		$snp = $splitp[1];
		$pw = $splitp[0];
		$PW{$pw} .= "$snp "; # add to this pathway
		$ALLKEGGSNPS{$snp} = 1; # '1' denoting that this SNP is in KEGG
		$KEGGPWSNPS{$pw}{$snp} = 1; # record yesnosig status for this snp in this pathway
		$readpw++;
	}
	#print ":\t$readpw snps in pathways read"; #\n- Looping over pathways...";
}

sub readsig {
	$snpfile = $_[0]; 
	$cutoff = $_[1];
	#print "\n\t- reading results file $snpfile (SNP and p-value)";
	open (SNPLIST, "$snpfile");
	while (<SNPLIST>) { # format snpid // p-val
		@split = split(/\s+/, $_);
		if ($split[1] <= $cutoff) { $split[1] = 1; } else { $split[1] = 0; } # label as 'significant' or 'nonsignificant'

		if ($ALLKEGGSNPS{$split[0]} ne '') {  # SNP is a KEGG SNP
			$SIG{$split[0]} = $split[1]; #significant
			$totalsnpsread++;
		}
	}
}

sub CLEAN {
	foreach $cleanthis (keys %SIG) {
		delete($SIG{$cleanthis});
	}
}
