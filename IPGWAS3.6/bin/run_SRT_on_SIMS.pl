#!/usr/bin/perl

####################################################################
# run_SRT_on_all.pl	-	CO'D 17/02/09
# runs SRT.pl on all available .forSRT files in current directory
# 	- invokes SRT.pl on east .forSRT file
#	- this version uses N to determine SNP cut-off, not p-value
#		N is designed to match the number of SNPs that are below
#		a given p-value in the origial data
####################################################################

### specify input
### revised on 16 Jul 2011

my ($nnumber, $dataset, $dir)=@ARGV;

=pid
 ** CHANGES/UPDATES:
	23/01/10 - if a .forSRT... file exists already, don't process (assume it was done before) - see lines 42+
	10/08/09 - changed line 80 - ratio was sig to nsig SNPs, should be sig to all
	21/05/09 - now remove .forSRT files are they are parsed (saves space)
=cut

# if ($ARGV[0] eq '') {
	# print "\nERROR:\tPlease enter N as ARGV[0]\n\tThis threshold determines what p-values are \'significant\' based on the specified cut-off. The number is the number of significant SNPs in the original dataset. See count_sig_SNPs.pl.\n\n\n"; die;
# }
# if ($ARGV[1] ne '') {
	# print "\n### Alternative pathway dataset was specified (format assumed: [id] [SNP id])\n";
	# $dataset = $ARGV[1];	
# }
# else {
	# $dataset = "KEGG_2_snp_b129.txt"; # default pathway
	# print "\n### Using KEGG as the reference pathway dataset ( format: [pwid] [SNPid] ) (you can specify an alternative as ARGV[1])\n\n";
# }

$suppress = 1;

# $nnumber = $ARGV[0]; #WAS: $pval = $ARGV[0]; (still will be for the original data)
print "Calculating ratios by filtering top [$nnumber\] SNPs from each simulation\nReading pathway dataset [$dataset\]..."; 
&readkeggsnp($dataset); 
print "\n\tDONE.\nCalculating SNP ratios for all files (except original) with the .forSRT extension...\n";

# opendir(DIR, ".");
opendir(DIR, $dir);
@FILES= readdir(DIR); 
$files = 0; $processed = 0; $i = 0;
while ($files < @FILES) {
	if ($FILES[$files] =~ /.forSRT$/) { 	
		$file = "$dir/$FILES[$files]";	
		if ($file !~ /original.assoc.forSRT$/) { # only want to look at simulates
			$i++;	
			print "\nINDEX $i\: [ $file ]";
			if ( -e "$file.n$nnumber.ratios") {
				print "\n\tprocessed already, skip";
			}
			else {	
				&readsig($file,$nnumber);
				$pwindex = 0;
				&SRT($nnumber,$file,1);
				&CLEAN;
			}
			$processed++;
		}
	}
	$files++;
}

if ($processed == 0) {
	print "\n\nERROR: no files with the .forSRT extention found!\n\n"; die;
}

print "\n\nDONE.\n
##########################################################################
[$processed\] *.forSRT files processed\nYou can now run \'get_SRT_p_value.pl\'
##########################################################################
\n";


sub SRT {
	$pv = $_[0];
	$f = $_[1];
	open (OUT, ">$f.n$pv.ratios");
	foreach $key (sort keys %KEGGPWSNPS) {		# loop over pws															
		$sigsnp = 0; $nssnp = 0; $ratio = 0;	
		$time = gmtime;
		if (($pwindex%10) == 0) {
			#print "\n\t\tON PATHWAY $pwindex $key...";
		}
		foreach $subkey (sort keys %{$KEGGPWSNPS{$key}}) {	# loop over snpw within pws
			#print "\nCheck $ALLKEGGSNPS{$subkey} $SIG{$subkey}\n" ; <STDIN>;
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
	open (PWS, "$dataset") || die("\n\n\nERROR: pathways dataset [$dataset\] not found in this directory!\n\n\n");
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
}

sub readsig {
	$snpfile = $_[0]; 
	$cutoff = $_[1];
	@sorted_array = ();
	open (SNPLIST, "$snpfile"); 
	@not_sorted = (<SNPLIST>); close (SNPLIST);
	@mainarray=();
	for ($x=0; $x < @not_sorted; $x++) {
		@tmp = split(/\s+/, $not_sorted[$x]);
		$mainarray[$x][0] = $tmp[0];
		$mainarray[$x][1] = $tmp[1];
	}
	@sorted_array = sort { $a->[1] <=> $b->[1] } @mainarray;
	
	$jj = 0; 
	for ($k=0; $k < @sorted_array; $k++) {
		if ($SIG{$sorted_array[$k][0]} ne 'SNP') {
			$jj++;
			if ($jj <= $cutoff) { $sorted_array[$k][1] = 1; } else { $sorted_array[$k][1] = 0; } # label as 'significant' or 'nonsignificant' w.r.t. n sig in original dataset
			if ($ALLKEGGSNPS{$sorted_array[$k][0]} ne '') {  # SNP is a KEGG SNP
				$SIG{$sorted_array[$k][0]} = $sorted_array[$k][1];
				$totalsnpsread++;
			}
		}
	}
}

sub CLEAN {
	delete @SIG{keys %SIG};
}
