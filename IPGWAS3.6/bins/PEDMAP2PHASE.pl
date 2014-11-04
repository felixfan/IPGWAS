#!/usr/bin/perl -w
use strict;
use Getopt::Long;


my($file, $ped, $map, $pht, $out);

GetOptions ("file=s"    => \$file,
			"ped=s"		=> \$ped,
			"map=s"     => \$map,
			"pht=s"     => \$pht,
			"out=s"     => \$out);

if((!$ped || !$map) && !$file)
{
print "
\@--------------------------------------------------@
|           PEDMAP2PHASE.pl version 1.0            |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://ipgwas.sourceforge.net/             |
\@--------------------------------------------------@

 --file:   input ped and map file
 --ped:    input ped file
 --map:    input map file
 --pht:    include phenotype or not, 1 or 0";
exit;
}

$ped ||="$file.ped";
$map ||="$file.map";
$pht ||= 0; #default no case-control status
$out ||="test.txt";

my ($numSNPs, $numIndiv)=(0,0);
my @location;
	
open(f0, ">$out");

open(f1, $ped);
while(<f1>)
{
$numIndiv++;
}
close f1;

open(f1, $map);
while(<f1>)
{
chomp;
my @arr=split(/\s+/, $_);
$location[$numSNPs++]=$arr[3];
}
close f1;

#####print out title info
print f0 "$numIndiv\n";
print f0 "$numSNPs\n";

print "Number of individuals: $numIndiv\n";
print "Number of SNPs: $numSNPs\n";

print f0 "P";
foreach my $key (@location)
{
print f0 " $key";
}
print f0 "\n";

print f0 "S";
for(my $i=0; $i<$#location; $i++)
{
print f0 " S";
}
print f0 "\n";

#####print out genotype
my $indNo=1;
open(f1, $ped);
while(<f1>)
{
chomp;
my @ar=split(/\s+/, $_);
	if($pht == 1) # case control status. control=>0, case=>1
	{
		if($ar[5]==1)
		{
		$ar[5]=0;
		}
		elsif($ar[5]==2)
		{
		$ar[5]=1;
		}
		else
		{
		die "The phenotype of individual $ar[0] $ar[1] is $ar[5] but not 1 or 2\n";
		}
	print f0 "$ar[5] $ar[0]._.$ar[1]\n"; #default individual ID = "FID._.IID"
	}
	else
	{
	print f0 "$ar[0]._.$ar[1]\n"; #default individual ID = "FID._.IID"
	}
	###first line
	$ar[6]= $ar[6] eq "0" ? "?" : $ar[6]; #code missing data as ?
	print f0 "$ar[6]";
	for(my $i=8; $i<=$#ar; $i+=2)
	{
	$ar[$i]= $ar[$i] eq "0" ? "?" : $ar[$i]; #code missing data as ?
	print f0 " $ar[$i]";
	}
	print f0 "\n";
	###second line
	$ar[7]= $ar[7] eq "0" ? "?" : $ar[7]; #code missing data as ?
	print f0 "$ar[7]";
	for(my $i=9; $i<=$#ar; $i+=2)
	{
	$ar[$i]= $ar[$i] eq "0" ? "?" : $ar[$i]; #code missing data as ?
	print f0 " $ar[$i]";
	}
	print f0 "\n";
$indNo++;
}
close f1;

print "Done.\n";
