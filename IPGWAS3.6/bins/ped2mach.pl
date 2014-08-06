#!/usr/bin/perl -w
use strict;

use Getopt::Long;

# use FindBin qw($Bin);
# use lib "$Bin/../lib";

### covert ped/map to dat/ped
### inputs are standard PED/MAP (ACGT code, -9 and 0 =>missing)
### Revised on 10 May 2012
### Yanhui Fan, nolanfyh@gmail.com

my($ped, $map, $num, $sep, $miss, $out);

GetOptions ("ped=s"		=> \$ped,
			"map=s"		=> \$map,
			"num=s"	=> \$num,
			"sep=s"	=> \$sep,
			"miss=s"	=> \$miss,
			"out=s"		=> \$out);

if(!$ped || !$map)
{
print "
\@--------------------------------------------------@
|             ped2mach.pl version 1.0              |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://ipgwas.sourceforge.net/             |
\@--------------------------------------------------@

 --ped:    input ped file.
 --map:    input map file.
 --num:    numerically coded alleles. yes/no. (optional)
 --sep:    use a \"/\" to separate alleles. yes/no. (optional)
 --miss:   encode missing genotypes as \".\" but not \"0\". yes/no. (optional)
 --out:    output file name. (optional)
 
 perl ped2mach.pl --ped example.ped --map example.map --out example.out\n";
exit;
}

$num ||= "no";
$sep ||= "no";
$miss ||= "no";
$out ||= "mach";

print "
\@--------------------------------------------------@
|             ped2mach.pl version 1.0              |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://ipgwas.sourceforge.net/             |
\@--------------------------------------------------@
";

print "\noptions in effect:\n  --ped $ped\n  --map $map\n  --num $num\n  --sep $sep\n  --miss $miss\n  --out $out\n";

my $pedout="$out.ped";
my $datout="$out.dat";

open(f0, ">$datout") || die "can not open $datout: $!\n";
open(f1, $map) || die "can not open $map: $!\n";
while(<f1>)
{
my @arr=split(/\s+/, $_);
print f0 "M $arr[1]\n";
}
close f1;
close f0;

open(f0, ">$pedout") || die "can not open $pedout: $!\n";
open(f1, $ped) || die "can not open $ped: $!\n";
while(<f1>)
{
my @arr=split(/\s+/, $_);
print f0 "$arr[0]\t$arr[1]\t$arr[2]\t$arr[3]\t$arr[4]";
	if($num =~/^n/i && $sep=~/^n/i && $miss=~/^n/i)
	{
		for(my $i=6; $i<=$#arr; $i++)
		{
			if($arr[$i]=~/[a|c|g|t]/i)
			{
			my $u=uc($arr[$i]);
			print f0 "\t$u";
			}
			elsif($arr[$i]=~/[-9|0]/)
			{
			print f0 "\t0";
			}
			else
			{
			die "genotype error!\nGenotype in $ped is not \"\[A\/C\/G\/T\/0\/-9\]\"\n";
			}
		}
	}
	elsif($num =~/^n/i && $sep=~/^n/i && $miss=~/^y/i)
	{
		for(my $i=6; $i<=$#arr; $i++)
		{
			if($arr[$i]=~/[a|c|g|t]/i)
			{
			my $u=uc($arr[$i]);
			print f0 "\t$u"; 
			}
			elsif($arr[$i]=~/[-9|0]/)
			{
			print f0 "\t.";
			}
			else
			{
			die "genotype error!\nGenotype in $ped is not \"\[A\/C\/G\/T\/0\/-9\]\"\n";
			}
		}
	}
	elsif($num =~/^n/i && $sep=~/^y/i && $miss=~/^n/i)
	{
		for(my $i=6; $i<=$#arr; $i++)
		{
			if($i%2==0)
			{
			print f0 "\t";
			}
			
			if($arr[$i]=~/[a|c|g|t]/i)
			{
			my $u=uc($arr[$i]);
			print f0 "$u";
			}
			elsif($arr[$i]=~/[-9|0]/)
			{
			print f0 "0";
			}
			else
			{
			die "genotype error!\nGenotype in $ped is not \"\[A\/C\/G\/T\/0\/-9\]\"\n";
			}
			
			if($i%2==0)
			{
			print f0 "\/";
			}
		}
	}
	elsif($num =~/^n/i && $sep=~/^y/i && $miss=~/^y/i)
	{
		for(my $i=6; $i<=$#arr; $i++)
		{
			if($i%2==0)
			{
			print f0 "\t";
			}
			
			if($arr[$i]=~/[a|c|g|t]/i)
			{
			my $u=uc($arr[$i]);
			print f0 "$u"; 
			}
			elsif($arr[$i]=~/[-9|0]/)
			{
			print f0 ".";
			}
			else
			{
			die "genotype error!\nGenotype in $ped is not \"\[A\/C\/G\/T\/0\/-9\]\"\n";
			}
			
			if($i%2==0)
			{
			print f0 "\/";
			}
		}
	}
	elsif($num =~/^y/i && $sep=~/^n/i && $miss=~/^n/i)
	{
		for(my $i=6; $i<=$#arr; $i++)
		{
			if($arr[$i]=~/[a|c|g|t]/i)
			{
			my $u=uc($arr[$i]);
			$u=~tr/ACGT/1234/;
			print f0 "\t$u";
			}
			elsif($arr[$i]=~/[-9|0]/)
			{
			print f0 "\t0";
			}
			else
			{
			die "genotype error!\nGenotype in $ped is not \"\[A\/C\/G\/T\/0\/-9\]\"\n";
			}
		}
	}
	elsif($num =~/^y/i && $sep=~/^n/i && $miss=~/^y/i)
	{
		for(my $i=6; $i<=$#arr; $i++)
		{
			if($arr[$i]=~/[a|c|g|t]/i)
			{
			my $u=uc($arr[$i]);
			$u=~tr/ACGT/1234/;
			print f0 "\t$u";
			}
			elsif($arr[$i]=~/[-9|0]/)
			{
			print f0 "\t.";
			}
			else
			{
			die "genotype error!\nGenotype in $ped is not \"\[A\/C\/G\/T\/0\/-9\]\"\n";
			}
		}
	}
	elsif($num =~/^y/i && $sep=~/^y/i && $miss=~/^n/i)
	{
		for(my $i=6; $i<=$#arr; $i++)
		{
			if($i%2==0)
			{
			print f0 "\t";
			}
			
			if($arr[$i]=~/[a|c|g|t]/i)
			{
			my $u=uc($arr[$i]);
			$u=~tr/ACGT/1234/;
			print f0 "$u";
			}
			elsif($arr[$i]=~/[-9|0]/)
			{
			print f0 "0";
			}
			else
			{
			die "genotype error!\nGenotype in $ped is not \"\[A\/C\/G\/T\/0\/-9\]\"\n";
			}
			
			if($i%2==0)
			{
			print f0 "\/";
			}
		}
	}
	elsif($num =~/^y/i && $sep=~/^y/i && $miss=~/^y/i)
	{
		for(my $i=6; $i<=$#arr; $i++)
		{
			if($i%2==0)
			{
			print f0 "\t";
			}
			
			if($arr[$i]=~/[a|c|g|t]/i)
			{
			my $u=uc($arr[$i]);
			$u=~tr/ACGT/1234/;
			print f0 "$u";
			}
			elsif($arr[$i]=~/[-9|0]/)
			{
			print f0 ".";
			}
			else
			{
			die "genotype error!\nGenotype in $ped is not \"\[A\/C\/G\/T\/0\/-9\]\"\n";
			}
			
			if($i%2==0)
			{
			print f0 "\/";
			}
		}
	}
print f0 "\n";
}
close f1;
close f0;

#####################
my($user, $system, $child_system, $child_user)=times();
print "\nTime used: $user seconds\n";
print "\nAnalysis finished.\n";