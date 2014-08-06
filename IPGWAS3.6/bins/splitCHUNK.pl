#!/usr/bin/perl -w
use strict;

use Getopt::Long;

###
### split chromosome in to 5MB if there are more then 200 SNPs in this 5MB region
### if there are less than 200 SNPs, merge with the next 5MB, if it is the last chunk, merge with the previous 5MB chunk
### input is a bim or map file in PLINK format
### 

### if command is specified, such as "prototype_phasing_job.sh"
### merge chunks before run the generated batch commans, if necessary

my ($bim, $comm, $out);
GetOptions ("bim=s"		=> \$bim,
			"comm=s"      => \$comm,
			"out=s"     => \$out
			);
			
if(!$bim)
{
print "
\@--------------------------------------------------@
|             splitCHUNK.pl version 1.0            |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://sourceforge.net/projects/ipgwas/    |
\@--------------------------------------------------@

 --bim:     input map file, *.bim or *.map in PLINK format
 --comm:    command, e.g. prototype_phasing_job.sh (optimal)
 --out:     output file name (optimal)
 
 perl splitCHUNK.pl --bim example.bim --comm prototype_phasing_job.sh --out example.chunks.txt
";
exit;
}

$out ||= "example.chunks.txt";
$comm ||= "NA";
my $commout="$out.comm.txt";

print "
\@--------------------------------------------------@
|             splitCHUNK.pl version 1.0            |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://sourceforge.net/projects/grpm/      |
\@--------------------------------------------------@

options in effect:

 --bim $bim
 --comm $comm
 --out $out
 
";
print "split chromosome in to 5MB length chunks\n";
print "if there are less than 200 SNPs in one chunk, merge with the previous or next chunk\n";
print "chunk has less than 200 SNPs ends with \[***\]\n";
print "manually check and merge with previous or next chunk\n\n";

print "if command is specified, such as \"prototype_phasing_job.sh\"\n";
print "merge chunks before run the generated batch commans, if necessary\n\n";

open(f0, ">$out");
open(f9,">$commout");
print f0 "# split chromosome in to 5MB length chunks\n";
print f0 "# if there are less than 200 SNPs in one chunk, merge with the previous or next chunk\n";
print f0 "# chunk has less than 200 SNPs ends with \[***\] in ($out)\n";
print f0 "# manually check and merge with previous or next chunk\n\n";
print f0 "# if command is specified, such as \"prototype_phasing_job.sh\"\n";
print f0 "# merge chunks before run the generated batch commans ($commout), if necessary\n";

my %info;

open(f1,$bim);
while(<f1>)
{
chomp;
my @arr=split(/\s+/, $_);
$info{$arr[0]}{$arr[3]}=1;  # chr - bp
}
close f1;

my %chunks;

foreach my $key (sort{$a<=>$b}keys %info)
{
my @bp=sort{$a<=>$b} keys %{$info{$key}};

        my $index=0;
		my $start=$bp[0];
		my $end=$start+5000000; # 5MB for each chunk
		my $n=0;
	print f0 "# chromosome $key:\n";
	print f0 "# start end #SNPs\n";
	while(1)
	{
		for(my $i=0; $i<=$#bp; $i++)
		{
			if($bp[$i] >= $start && $bp[$i] <= $end)
			{
			$n++;
			}
		}
		
		my $chunk='';
		if($n > 200)
		{
		$chunk="$start $end $n";  # start end #snp
		}
		else
		{
		$chunk="$start $end $n ***";  # start end #snp
		}
		
		$chunks{$key}{$index}=$chunk;
		print f0 "$chunk\n";
		print f9 "$comm $key $start $end\n";
		
		if($end > $bp[$#bp]) # last chunk
		{
		last;
		}
		else # not last chunk
		{
		$n=0;
		$start=$end+1;
		$end=$start+5000000;
		}
	}	
}
close f0;
close f9;
print "Analysis finished.\n";