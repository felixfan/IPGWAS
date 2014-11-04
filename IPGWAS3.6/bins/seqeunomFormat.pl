#!/usr/bin/perl -w
use strict;

my ($geno,$out)=@ARGV;

########################
if(!$geno)
{
die "\n
How to prepare the input file?

(1) open xxx_genotype_transpose.xls

(2) delete the first 2-3 row (rows above \"SAMPLE_ID\" row) with description information.

(3) Also delete the last line with summary information (e.g. \"Total ...\").

(4) Delete rows contain GRC and GRC duplicate (Keep your own duplicate!).

!!!The clean data only contains SNP genotype information for individuals!!!

The first colume is SAMPLE_ID. The other columes are genotypes, one SNP 
each colume (contains two letters, e.g. AC or NA for missing).

The fist row is header information contains \"SAMPLE_ID\" and SNP id (in HKU GRC format)
The other rows are genotype information, each row for an individual.

(5) save xxx_genotype_transpose.xls as Text (Tab Delimited) (e.g. genotype.txt).

(6) Then, run this script:

perl $0 genotype.txt

Three files (myGeno.ped and myGeno.map in PLINK format, and myGeno.SNPlist.txt) will be generated.

to change the output name:

perl $0 genotype.txt yourOutputName

revised on 15 Aug 2013
\@ Felix Yanhui Fan, nolanfyh\@gmail.com
\n";
}

print "\nreading the genotype data ...";
$out ||= "myGeno";

# read data
open(f1,$geno);
my $firstLine=<f1>;
chomp $firstLine;
my @head=split("\t",$firstLine);
my $n=$#head;

my %genotype;

# second to the last line
while(my $line=<f1>)
{
chomp $line;
my @arr=split("\t",$line);
my $m=$#arr;
	if($m != $n)
	{
	die"Genotype line has different columes from the header line\nPlease check your data format\n";
	}
	else
	{
		for(my $i=1; $i <=$m; $i++)
		{
			if(exists $genotype{$arr[0]}{$head[$i]})
			{
				if($genotype{$arr[0]}{$head[$i]} eq "-")
				{
				$genotype{$arr[0]}{$head[$i]}=$arr[$i];
				}
			}
			else
			{
			$genotype{$arr[0]}{$head[$i]}=$arr[$i];
			}
		}
	}
}
close(f1);

# write .ped data
open(f2,">$out.ped");
print "Done.\nrecond the genotype ...";
print "Done.\nwrite the genotype to $out.ped ...";
my @individuals = keys %genotype;
for(my $j=0;$j<=$#individuals;$j++)
{
print f2 "$individuals[$j]\t$individuals[$j]\t0\t0\t0\t0";
	for(my $i=1;$i<=$#head;$i++)
	{
		if($genotype{$individuals[$j]}{$head[$i]} eq "NA")
		{
		print f2 "\t0\t0";
		}
		else
		{
		my @ar=split("",$genotype{$individuals[$j]}{$head[$i]});
		print f2 "\t$ar[0]\t$ar[1]";
		}
	
	}
print f2 "\n";
}
close f2;

print "Done.\n
Note: $out.ped is PLINK formatted. more details:
http://pngu.mgh.harvard.edu/~purcell/plink/data.shtml#ped

FID was set to equal to IID, you may need to update it if necessary.
(if you do not know what does this mean, just ignore it *)

PID and MID was set to 0, you may need to update it if necessary.
(if you do not know what does this mean, just ignore it *)

Sex and Phenotype was set to 0. This must be updated!!!
see http://pngu.mgh.harvard.edu/~purcell/plink/dataman.shtml#updatefam
";

# write .map data
print "\nwrite map file to $out.map ...";
open(f3,">$out.map");
open(f4,">$out.SNPlist.txt");
for(my $i=1;$i<=$#head;$i++)
{
my @a=split("_",$head[$i]);
print f3 "$i\trs$a[1]\t0\t$i\n";
print f4 "rs$a[1]\n";
}
close(f3);
close(f4);
print "Done.\n
Note: $out.map is PLINK formatted. more details:
http://pngu.mgh.harvard.edu/~purcell/plink/data.shtml#map

Chromosome and Physical position data must be updated!!!
see http://pngu.mgh.harvard.edu/~purcell/plink/dataman.shtml#updatemap

";

print "\nwrite SNP list to $out.SNPlist.txt ...";
print "Done.\n
Note: Check SNPs listed in the $out.SNPlist.txt

if these SNPs are not same as SNPs you genotyped, you may need to revise
this script!!!!!!!

if these SNPs ID are right, search the Chromosome and Physical position data
of these SNPs to update the map file.

see http://pngu.mgh.harvard.edu/~purcell/plink/dataman.shtml#updatemap
";

print "\nThere are total $#individuals individuals (include dup) and $n SNPs\n";
print "\nDone\n";


