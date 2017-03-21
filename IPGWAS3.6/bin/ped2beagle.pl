#!/usr/bin/perl -w
use strict;

use Getopt::Long;

# use FindBin qw($Bin);
# use lib "$Bin/../lib";

### covert ped/map to unphased beagle genotype file format
### inputs are standard PED/MAP (ACGT code, -9 and 0 =>missing)
### Revised on 12 May 2012
### Yanhui Fan, nolanfyh@gmail.com

### ped/map should include markers on the same chromosome!!!!

my($ped, $map, $pht, $out);

GetOptions ("ped=s"		=> \$ped,
			"map=s"		=> \$map,
			"pht=s"	=> \$pht,
			"out=s"		=> \$out);

if(!$ped || !$map || !$pht)
{
print "
\@--------------------------------------------------@
|             ped2beagle.pl version 1.0            |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://ipgwas.sourceforge.net/             |
\@--------------------------------------------------@

 --ped:    input ped file.
 --map:    input map file.
 --pht:    disease name. such as T1D, AD, ...
 --out:    output file name. (optional)
 
 perl ped2beagle.pl --ped example.ped --map example.map --pht AD --out example.out\n";
exit;
}

$out ||= "examle.out";

my @trait;
my $i=0;
my %geno1;
my %geno2;
my @ind;

open(f0, ">$out") || die "can not open $out: $!\n";
print f0 "I\tid";
open(f1, $ped) || die "can not open $ped: $!\n";
while(<f1>)
{
chomp;
my @arr=split(/\s+/, $_);
print f0 "\t$arr[1]\t$arr[1]";
$ind[$i]=$arr[1];
$trait[$i++]=$arr[5];
my $t=0;
	for(my $j=6; $j<$#arr; $j+=2)
	{
	my $s=$j+1;
	$arr[$j]="?" if($arr[$j]=~/0|-9/);
	$arr[$s]="?" if($arr[$s]=~/0|-9/);
	$geno1{$arr[1]}{$t}=$arr[$j];
	$geno2{$arr[1]}{$t++}=$arr[$s];
	}
}
close f1;
print f0 "\n";

print f0 "A\t$pht";
for(my $j=0;$j<=$#trait; $j++)
{
print f0 "\t$trait[$j]\t$trait[$j]";
}
print f0 "\n";

my @snp;
my $k=0;
open(f1, $map)|| die "can not open $map: $!\n";
while(<f1>)
{
chomp;
my @arr=split(/\s+/, $_);
$snp[$k++]=$arr[1];
}
close f1;

for(my $j=0; $j<=$#snp; $j++)
{
print f0 "M\t$snp[$j]";
	for (my $s=0; $s<=$#ind; $s++)
	{
	print f0 "\t$geno1{$ind[$s]}{$j}\t$geno2{$ind[$s]}{$j}";
	}
print f0 "\n";
}

close f0;
