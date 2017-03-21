#!/usr/bin/perl

####################################################################
# 
# run_SRT_on_ALL.pl	- CO'D 10/12/08-20/05/09
#
# runs SRT on all available .forSRT files in current directory
# 	- calculates a ratio of significant to no-significant SNPs within each pathway
#  	  based on a p-value cut-off
#
#   *** NOTE ***
#	ONLY USE THIS SCRIPT IF YOU WANT TO USE A CUT-OFF OPTION 
#	INSTEAD OF THE RECOMMENDED TOP N SNPS OPTION. 
#
####################################################################

=pid
	10/08/09 - changes line 83 - ratio was sig to nsig SNPs, should be sig to all
	21/05/09 - now remove .forSRT files are they are parsed (saves space)
=cut

### specify input
### revised on 16 Jul 2011

my ($pval, $dataset, $dir)=@ARGV;

# if ($ARGV[0] eq '') {
	# print "\nERROR:\tPlease enter p-value threshold as ARGV[0]\n\tThis threshold determines what p-values are \'significant\' based on the specified cut-off\n\n"; die;
# }
# if ($ARGV[1] ne '') {
	# print "\n### Alternative pathway dataset was specified (format assumed: [id] [SNP id])\n";
	# $dataset = $ARGV[1];	
# }
# else {
	# $dataset = "KEGG_2_snp_b129.txt"; # default pathway
	# print "\n### Using KEGG as the reference pathway dataset ( format: [pwid] [SNPid] ) (you can specify an alternative as ARGV[1])\n";
# }

# $pval = $ARGV[0];
print "P-value threshold for calculating ratios for SRT: [$pval\]\nReading pathway dataset $dataset (may take a while)...\n";
&readkeggsnp($dataset); 
print "done.\nCalculating SNP ratios for all files with the .forSRT extension...\n";

# opendir(DIR, ".");
opendir(DIR, $dir);
@FILES= readdir(DIR); 
$files = 0; $processed = 0;
while ($files < @FILES) {
	if ($FILES[$files] =~ /.forSRT$/) { 	
		# $file = $FILES[$files];
		$file = "$dir/$FILES[$files]";
		$i++;	
		print "\nINDEX $i\: [ $file ]";
		&readsig($file,$pval);
		$pwindex = 0;
		&SRT($pval,$file,1);
		&CLEAN; # reset the hash recording significance
		$processed++;
	}
	$files++;
}

if ($processed == 0) {
	print "\n\nERROR: no files with the .forSRT extention found!\n\n"; die;
}

print "\n\nDONE.\n
##########################################################################
[ $processed ] *.forSRT files processed\nYou can now run \'get_SRT_p_value.pl\'
##########################################################################
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
	open (PWS, "$dataset");
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
	delete @SIG{keys %SIG};
}
