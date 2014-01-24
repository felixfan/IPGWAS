#!/usr/bin/perl -w
use strict;

use Getopt::Long;

# use FindBin qw($Bin);
# use lib "$Bin/../lib";

### covert ped/map to gen/sample/strand
### inputs are standard PED/MAP (ACGT code, -9 and 0 =>missing)
### Revised on 6 July 2012
### Yanhui Fan, nolanfyh@gmail.com

my($ped, $map, $out);

GetOptions ("ped=s"		=> \$ped,
			"map=s"		=> \$map,
			"out=s"		=> \$out);

if(!$ped || !$map)
{
print "
\@--------------------------------------------------@
|             ped2impute.pl version 3.0            |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://ipgwas.sourceforge.net/             |
\@--------------------------------------------------@

 --ped:    input ped file.
 --map:    input map file.
 --out:    output file name. (optional)
 
 perl ped2impute.pl --ped example.ped --map example.map --out example.out\n";
exit;
}

$out ||= "example.out";

print "
\@--------------------------------------------------@
|             ped2impute.pl version 2.0            |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://ipgwas.sourceforge.net/             |
\@--------------------------------------------------@
";
print "\noptions in effect:\n  --ped $ped\n  --map $map\n  --out $out\n";

my $pedout="$out.gen";
my $datout="$out.sample";
my $strandout="$out.strand";

my (@chr,@rs,@bp);
open(f1, $map) || die "can not open $map: $!\n";
my $i=0;
while(<f1>)
{
chomp;
my @arr=split(/\s+/, $_);
$chr[$i]=$arr[0];
$rs[$i]=$arr[1];
$bp[$i++]=$arr[3];
}
close f1;

open(f1, $ped) || die "can not open $ped: $!\n";
my (%geno, %allele, @miss, @id1, @id2, @sex, @pht);
my $j=0; # index/number of individual
$i=0;    # index/number of snp
while(<f1>)
{
my @arr=split(/\s+/, $_);
$id1[$j]=$arr[0];
$id2[$j]=$arr[1];
$sex[$j]=$arr[4];
	if($arr[5]==2)
	{
	$pht[$j]=1;
	}
	elsif($arr[5]==1)
	{
	$pht[$j]=0;
	}
	else
	{
	die "phenptype of individual: $id1[$j] $id2[$j] is not 1 or 2\n";
	}

	my $m=0;
	my $n=0;
	###genotype
	for(my $k=6;$k<=$#arr;$k++)
	{
		if($arr[$k]=~/A|C|G|T/i)
		{
		$n++;
		}
		elsif($arr[$k]=~/0|-9/)
		{
		$n++;
		$m++;
		}
		else
		{
		die "genotype of individual: $id1[$j] $id2[$j] is not A|C|G|T or 0|-9\n";
		}
		
	$geno{$j}{$k}=$arr[$k];
	$i = ($k-6)%2 == 0 ? ($k-6)/2 : ($k-7)/2;
	$allele{$i}{$arr[$k]}=1;
	}
	$miss[$j++]=$m/$n;
}
close f1;

###sample
open(f0, ">$datout") || die "can not open $datout: $!\n";
print f0 "ID_1 ID_2 Missing Gender Phenotype\n";
print f0 "0 0 0 D B\n";
for(my $k=0;$k<=$#id1;$k++)
{
print f0 "$id1[$k] $id2[$k] $miss[$k] $sex[$k] $pht[$k]\n";
}
close f0;

###geno
open(f0, ">$pedout") || die "can not open $pedout: $!\n";
open(f9, ">$strandout") || die "can not open $strandout: $!\n";
for(my $k=0;$k<=$#rs;$k++)
{
my $a1='';
my $a2='';
print f0 "$chr[$k] $rs[$k] $bp[$k]";      # chr rsid bp
print f9 "$bp[$k] +\n";                   # strand file, all snp on + strand, flip snp in previous step
my $a1a2="";
	
	
	foreach my $key(sort keys %{$allele{$k}})
	{
		if($key=~/A|C|G|T/i)
		{
		$key=uc($key);
		$a1a2.=$key;
		}
	}
	
	if($a1a2 eq 'A')
	{
	$a1='A';
	$a2='A';
	}
	elsif($a1a2 eq 'C')
	{
	$a1='C';
	$a2='C';
	}
	elsif($a1a2 eq 'G')
	{
	$a1='G';
	$a2='G';
	}
	elsif($a1a2 eq 'T')
	{
	$a1='T';
	$a2='T';
	}
	elsif($a1a2 eq 'AC')
	{
	$a1='A';
	$a2='C';
	}
	elsif($a1a2 eq 'AG')
	{
	$a1='A';
	$a2='G';
	}
	elsif($a1a2 eq 'AT')
	{
	$a1='A';
	$a2='T';
	}
	elsif($a1a2 eq 'CG')
	{
	$a1='C';
	$a2='G';
	}
	elsif($a1a2 eq 'CT')
	{
	$a1='C';
	$a2='T';
	}
	elsif($a1a2 eq 'GT')
	{
	$a1='G';
	$a2='T';
	}

print f0 " $a1 $a2";

my $x=2*$k+6;
my $y=2*$k+7;
	foreach my $key(sort {$geno{$a} <=> $geno{$b}} keys %geno)
	{
		if("$geno{$key}{$x}$geno{$key}{$y}" eq "$a1$a1")
		{
		print f0 " 1 0 0";
		}
		elsif("$geno{$key}{$x}$geno{$key}{$y}" eq "$a1$a2")
		{
		print f0 " 0 1 0";
		}
		elsif("$geno{$key}{$x}$geno{$key}{$y}" eq "$a2$a1")
		{
		print f0 " 0 1 0";
		}
		elsif("$geno{$key}{$x}$geno{$key}{$y}" eq "$a2$a2")
		{
		print f0 " 0 0 1";
		}
		else
		{
		print f0 " 0 0 0";
		}
	}
print f0 "\n";	
}
close f0;
close f9;

#####################
my($user, $system, $child_system, $child_user)=times();
print "\nTime used: $user seconds\n";
print "\nAnalysis finished.\n";
