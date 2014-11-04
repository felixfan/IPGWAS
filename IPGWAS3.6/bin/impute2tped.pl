#!/usr/bin/perl -w
use strict;
use Getopt::Long;

my($gen, $sample, $chr, $t, $out);

GetOptions ("gen=s"        => \$gen,
            "sample=s"     => \$sample,
			"chr=i"        => \$chr,
			"threshold=f"  => \$t,
			"out=s"        => \$out
            );

if(!$gen || !$sample || !$chr)
{
print "
\@--------------------------------------------------@
|             impute2tped.pl version 1.0           |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://sourceforge.net/projects/ipgwas/    |
\@--------------------------------------------------@

 --gen:        the output genotype file of IMPUTE2
 --sample:     sample file related to the genotype
 --chr:        chromosome, 1-22
 --threshold:  threshold to call genotype, [0, 1], default 0.9
 --out:        prefix of output tped/tfam
 
 perl impute2tped.pl --gen gwas_data_chr1.impute2 --sample gwas_data_chr1.sample \
 --chr 1 --threshold 0.9 --out example.out
";
exit;
}

$t ||=0.9;
$out ||="example.out";
my $tpedout="$out.tped";
my $tfamout="$out.tfam";

print "
\@--------------------------------------------------@
|             impute2tped.pl version 1.0           |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://sourceforge.net/projects/ipgwas/    |
\@--------------------------------------------------@

options in effect:

 --gen:       $gen
 --sample:    $sample
 --chr:       $chr
 --threshold: $t
 --out:       $out
 
";

 if($t>1 || $t<0.5)
 {
 die "threshold should be [0.5, 1] , the default value is 0.9\n";
 }
 
 ### sample
 open(f1, $sample) || die "can not open $sample\n";
 open(f0, ">$tfamout") || die "can not open $tfamout\n";
 <f1>;
 <f1>;
 my $n=0;
 while(<f1>)
 {
	chomp;
	my @arr=split(/\s+/, $_);
	$n++;
		if($arr[4] == 1)
		{
		print f0 "$arr[0] $arr[1] 0 0 $arr[3] 2\n";
		}
		elsif($arr[4] == 0)
		{
		print f0 "$arr[0] $arr[1] 0 0 $arr[3] 1\n";
		}
		else
		{
		die "phenotype of $arr[0] $arr[1] in $sample is not [0|1]\n";
		}
 }
 close f1;
 close f0;
 print "there are $n individuals\n";
 
 ### gen
 open(f1, $gen) || die "can not open $gen\n";
 open(f0, ">$tpedout") || die "can not open $tpedout\n";
 $n=0;
 while(<f1>)
 {
 	if($_!~/I|D/)
	{
	 chomp;
	 my @arr=split(/\s+/, $_);
	 print f0 "$chr $arr[1] 0 $arr[2]";
	 $n++;
		for(my $i=5; $i<$#arr; $i+=3)
		{
		my $j=$i+1;
		my $k=$i+2;
			if($arr[$i] >= $t)
			{
			print f0 " $arr[3] $arr[3]";
			}
			elsif($arr[$j] >= $t)
			{
			print f0 " $arr[3] $arr[4]";
			}
			elsif($arr[$k] >= $t)
			{
			print f0 " $arr[4] $arr[4]";
			}
			else
			{
			print f0 " 0 0";
			}
		}
	print f0 "\n";
	}
 }
 close f0;
 close f1;
 print "there are $n SNPs\n";
 
 print "\nAnalysis finished.\n";