#!/usr/bin/perl -w
use strict;

use Getopt::Long;

# use FindBin qw($Bin);
# use lib "$Bin/../lib";

### covert tped/tfam to unphased beagle genotype file format
### inputs are standard tped/tfam (ACGT code, -9 and 0 =>missing)
### Revised on 11 Jun 2014
### Yanhui Fan, nolanfyh@gmail.com

my($tped, $tfam, $pht, $out);

GetOptions ("tped=s"		=> \$tped,
			"tfam=s"		=> \$tfam,
			"pht=s"	=> \$pht,
			"out=s"		=> \$out);

if(!$tped || !$tfam || !$pht)
{
print "
\@--------------------------------------------------@
|             tped2beagle.pl version 1.0           |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://ipgwas.sourceforge.net/             |
\@--------------------------------------------------@

 --tped:    input tped file.
 --tfam:    input tfam file.
 --pht:    disease name. such as T1D, AD, ...
 --out:    output file name. (optional)
 
 perl tped2beagle.pl --tped example.tped --tfam example.tfam --pht AD --out example.out\n";
exit;
}

$out ||= "examle.out";

my %ind;
open(f1, $tfam) || die "can not open $tfam\n";
while(<f1>){
	chomp;
	my @arr=split(/\s+/, $_);
	$ind{$arr[1]}=$arr[5];
}
close f1;

open(f0, ">$out") || die "can not open $out\n";
print f0 "I id";
foreach my $key(keys %ind)
{
	print f0 " $key $key";
}
print f0 "\n";
print f0 "A $pht";
foreach my $value(values %ind)
{
	print f0 " $value $value";
}
print f0 "\n";

open(f2, $tped) || die "can not open $tped\n";
while(<f2>){
	chomp;
	my @arr=split(/\s+/, $_);
	print f0 "M $arr[1]";
	for(my $i=4;$i<$#arr;$i+=2){
		my $ii=$i+1;
		if($arr[$i]=~/0|-9/ && $arr[$ii]=~/0|-9/){
			print f0 " ? ?";
		}else{
			print f0 " $arr[$i] $arr[$ii]";
		}
	}
	print f0 "\n";
}
close f2;
close f0;