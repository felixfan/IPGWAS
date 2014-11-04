#!/usr/bin/perl

####################################################################
# parse_alt_pheno.pl	-	CO'D 12/12/08
# reads all PLINK *.assoc files in current directory
# generates *.forSRT files that can be used as SRT inputs
####################################################################

### read from the specified directory and write to the specified directory
### close IN file so it can be removed
### revised on 16 Jul 2011


=pid
21/05/09 - mention run_SRT_on_ALL.pl in report at end
		 - now remove .assoc files are they are parsed (saves space)
12/12/08 - now compatible for both unix and dos 
=cut
my($dir)=@ARGV;

opendir(DIR, $dir);
@FILES= readdir(DIR); 
$files = 0; $processed = 0;
while ($files < @FILES) {
	if ($FILES[$files] =~ /.assoc$/) { 	# get all files with .assoc extension
		$file = $FILES[$files];
		$processed++;
		print "\nParsing [$file\]...index $processed"; 
		open (IN, "$dir/$file");			# read in the PLINK output file 
		open (OUT, ">$dir/$file.forSRT");# create .forSRT file - SNP and p-value
		while (<IN>) {
			$_ =~ s/^\s+//g;		# remove leading spaces
			@split = split(/\s+/, $_);
			print OUT "$split[1]\t$split[8]\n"; # print out SNP and p-value
		}
		close OUT;
		close IN;
	}
	$files++;
}
if ($processed == 0) {
	print "\nNO FILES WITH THE \'.assoc\' EXTENSION FOUND!\nMake sure you ran the associations in PLINK\n\n"; die;
}
print "\n\nDONE.\n
##########################################################################
[$processed\] .assoc files processed\nYou can now run \'run_SRT_on_ORIGINAL.pl\' and \'run_SRT_on_SIMS.pl\' (or alternatively, \'run_SRT_on_ALL.pl\')
##########################################################################
\n";

