#!/usr/bin/perl -w
use strict;

use Getopt::Long;

### CONVERT PED/MAP TO SPSS
### OUTPUT IS CSV FILE, csv->excel->spss
### inputs are standard PED/MAP (ACGT code, -9 and 0 =>missing, 2->case, 1->control)
### Revised on 31 Jul 2012
### Yanhui Fan, nolanfyh@gmail.com

my($ped, $map, $covar, $out);

GetOptions ("ped=s"		=> \$ped,
			"map=s"		=> \$map,
			"covar=s"	=> \$covar,
			"out=s"		=> \$out);

if(!$ped || !$map)
{
print "
\@--------------------------------------------------@
|             pedmap2spss.pl version 1.0           |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://ipgwas.sourceforge.net/             |
\@--------------------------------------------------@

 --ped:    input ped file
 --map:    input map file
 --covar:  input covariants file (optional)
           plain text file with a headline, first column is 'IID'
           other columns are covariants
 --out:    output file name (optional)
           first column is 'IID' from the PED file
           second and third columns are 'PHT1' AND 'PHT2'
           fourth and fifth columns are 'SEX1' AND 'SEX2'
           'PHT1' and 'SEX1' are number code
           'PHT2' and 'SEX2' are letters code
           sixth to the end columns are the covariants (if any)
           which are followed by genotypes (same order as map file)
 e.g.
 perl pedmap2spss.pl --ped example.ped --map example.map \\
 --covar example.covar.txt --out example.spss.csv
\n";
exit;
}

$out ||= "example.spss.csv";
$covar ||="NA";

print "
\@--------------------------------------------------@
|             pedmap2spss.pl version 1.0           |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://ipgwas.sourceforge.net/             |
\@--------------------------------------------------@

";

print "options in effect:\n  --ped $ped\n  --map $map\n  --covar $covar\n  --out $out\n";

### read covariants
my %covars;
if($covar ne "NA")
{
	open(f1, $covar);
	while(<f1>)
	{
	chomp;
	my @arr=split(/\s+/, $_);
	$covars{$arr[0]}="$arr[1]";
		for(my $i=2; $i<=$#arr;$i++)
		{
		$covars{$arr[0]}.=",$arr[$i]";
		}
	}
	close f1;
}

### read map
my @SNPs;
my $i=0;
open(f1, $map);
while(<f1>)
{
chomp;
my @arr=split(/\s+/, $_);
$SNPs[$i]=$arr[1];
$i++;
}
close f1;

open(f9, ">$out");
### print header
if($covar ne "NA")
{
print f9 "IID,PHT1,PHT2,SEX1,SEX2,$covars{FID}";
}
else
{
print f9 "IID,PHT1,PHT2,SEX1,SEX2";
}

foreach my $snp (@SNPs)
{
print f9 ",$snp";
}
print f9 "\n";

### read ped
open(f2, $ped);
while(<f2>)
{
chomp;
my @arr=split(/\s+/, $_);
print f9 $arr[1];
if($arr[5]==2)
{
print f9 ",2,Case";
}
elsif($arr[5]==1)
{
print f9 ",1,Control";
}
else
{
print f9 ",NA,NA";
}

if($arr[4]==2)
{
print f9 ",2,Female";
}
elsif($arr[4]==1)
{
print f9 ",1,Male";
}
else
{
print f9 ",NA,NA";
}

if($covar ne "NA")
{
print f9 ",$covars{$arr[1]}";
}
	for (my $j=6; $j<$#arr; $j=$j+2)
	{
	print f9 ",$arr[$j] $arr[$j+1]";
	}
print f9 "\n";
}
close f2;
close f9;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900; ## $year contains no. of years since 1900, to add 1900 to make Y2K compliantmy 
my @month_abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
if($min<10)
{
$min="0$min";
}
print "Analysis finised at $hour:$min:$sec, $mday $month_abbr[$mon] $year.\n";
