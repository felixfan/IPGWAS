#!/usr/bin/perl -w
use strict;

use Getopt::Long;

use FindBin qw($Bin);
use lib "$Bin/../lib";

### Cochran-Armitage Trend Test
### inputs are standard PED/MAP (ACGT code, -9 and 0 =>missing, 2->case, 1->control)
### Calculate Cochran-Armitage Trend Test P value for each SNP under certain model (Dominant, Recessive, Additive)
### Revised on 29 May 2012
### Yanhui Fan, nolanfyh@gmail.com

my($file, $ped, $map, $model, $out, $log);

GetOptions ("file=s"   => \$file,
			"ped=s"		=> \$ped,
			"map=s"		=> \$map,
			"model=s"	=> \$model,
			"out=s"		=> \$out,
			"log=s"     => \$log);

if((!$ped || !$map) && !$file)
{
print "
\@--------------------------------------------------@
|              cat.pl version 3.3                  |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://ipgwas.sourceforge.net/             |
\@--------------------------------------------------@

 --file: input ped and map files
 --ped: input ped file
 --map: input map file
 --model:  model to be tested. 'dom', 'rec', 'add', or 'best' 
 --out:    output file name. 
 --log:    log file name.
 
 e.g.
 perl cat.pl --file test --model dom --out test.assoc --log test.log
 or
 perl cat.pl --ped test.ped --map test.map --model dom --out test.assoc --log test.log\n";
exit;
}

$ped ||="$file.ped";
$map ||="$file.map";
$model ||= "best";
$out ||= "cat.assoc";
$log ||= "cat.log";

open(f99, ">$log") || die "can not open $map: $!\n";

print "
\@--------------------------------------------------@
|              cat.pl version 3.3                  |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://ipgwas.sourceforge.net/             |
\@--------------------------------------------------@
";

print "\nCochran-Armitage Trend Test\n\n";
print "options in effect:\n  --ped $ped\n  --map $map\n  --model $model\n  --out $out\n  --log $log\n";

print f99 "
\@--------------------------------------------------@
|              cat.pl version 3.3                  |
|--------------------------------------------------|
|  (C) Yan-Hui Fan, GNU General Public License, v2 |
|--------------------------------------------------|
|       http://ipgwas.sourceforge.net/             |
\@--------------------------------------------------@
";
print f99 "\nCochran-Armitage Trend Test\n\n";

print f99 "options in effect:\n  --ped $ped\n  --map $map\n  --model $model\n  --out $out\n  --log $log\n";

### read map
print "Reading SNPs from $map file...\n";
print f99 "Reading SNPs from $map file...\n";
my @snps; #ordered SNPs
my $n=0; # number of SNPs
my %chr; #chromosome
my %phypos; #physical position

open(f1, $map) || die "can not open $map: $!\n";
while(<f1>)
{
chomp;
my @arr=split(/\s+/, $_);
$snps[$n++]=$arr[1];
$chr{$arr[1]}=$arr[0];
$phypos{$arr[1]}=$arr[3];
}
close f1;
print "There are $n SNPs in $map files.\n";
print f99 "There are $n SNPs in $map files.\n";

### read ped
print "Reading Genotype data from $ped file...\n";
print f99 "Reading Genotype data from $ped file...\n";
my %allele; # pht/index/allele = #
my %gtp; # pht/index/gtp = #
open(f1, $ped) || die "can not open $map: $!\n";
my $k; # index of SNP (gtp)
while(<f1>)
{
chomp;
my @arr=split(/\s+/, $_);
$k=0;
	for(my $i=6; $i<$#arr; $i+=2)
	{
	my $j=$i+1;
	my $temp="$arr[$i]$arr[$j]";
		if($temp=~/[ACGT]{2}/i)
		{
		$gtp{$arr[5]}{$k}{$temp}++;
		$allele{$arr[5]}{$k}{$arr[$i]}++;
		$allele{$arr[5]}{$k}{$arr[$j]}++;
		}
	$k++;
	}
}
close f1;

### calculate p
print "Calculating p-values for $k SNPs...\n";
print f99 "Calculating p-values for $k SNPs...\n";
open(f9, ">$out") || die "can not open $out: $!\n";
printf f9 "%3s\t%12s\t%10s\t%2s\t%2s\t%14s\t%14s\t%6s\t%6s\t%6s\t%6s\t%6s\t%5s\t%4s\t%4s\t%4s\t%6s\t%6s\n", 'CHR', 'SNP', 'BP', 'A1', 'A2', 'AFF', 'UNAFF', 'OR', 'SE', 'L95', 'U95', 'Model', 'N', 'F_A', 'F_U', 'Freq', 'Chisq', 'P';

my (%ra, %oa); ### %ra => risk allele
my %chisq;

for(my $i=0; $i<=$#snps; $i++)
{
printf f9 "%3d\t%12s\t%10d", $chr{$snps[$i]}, $snps[$i], $phypos{$snps[$i]};
		my @subkey=keys %{$allele{2}{$i}};
		my @subkey2=keys %{$allele{1}{$i}};
		if($#subkey <= 1 && $#subkey2 <= 1)
		{
			### risk allele
			my $OR;
			if($#subkey == 1 && $#subkey2 == 1)
			{
			$OR=($allele{2}{$i}{$subkey[0]}/$allele{2}{$i}{$subkey[1]})/($allele{1}{$i}{$subkey[0]}/$allele{1}{$i}{$subkey[1]});
		    $ra{$i}= $OR > 1 ? $subkey[0] : $subkey[1];
		    $oa{$i}= $OR > 1 ? $subkey[1] : $subkey[0];
			}
			elsif($#subkey == 1 && $#subkey2 == 0)
			{
				if($subkey[0] eq $subkey2[0])
				{
				$ra{$i}=$subkey[1];
				$oa{$i}=$subkey[0];
				}
				else
				{
				$ra{$i}=$subkey[0];
				$oa{$i}=$subkey[1];
				}
			}
			elsif($#subkey == 0 && $#subkey2 == 1)
			{
				if($subkey[0] eq $subkey2[0])
				{
				$ra{$i}=$subkey2[0];
				$oa{$i}=$subkey2[1];
				}
				else
				{
				$ra{$i}=$subkey2[1];
				$oa{$i}=$subkey2[0];
				}
			}
			else # 0 and 0
			{
				if($subkey[0] eq $subkey2[0])
				{
				$ra{$i}=$subkey[0];
				$oa{$i}='0';
				}
				else
				{
				$ra{$i}=$subkey[0];
				$oa{$i}=$subkey2[0];
				}
			}
			
			### gtp
			my $rr="$ra{$i}$ra{$i}";
			my $ro="$ra{$i}$oa{$i}";
			my $or="$oa{$i}$ra{$i}";
			my $oo="$oa{$i}$oa{$i}";
			### number of gtp
			$gtp{2}{$i}{$rr} ||=0;
			$gtp{2}{$i}{$oo} ||=0;
			$gtp{2}{$i}{$ro} ||=0;
			$gtp{2}{$i}{$or} ||=0;
			$gtp{1}{$i}{$rr} ||=0;
			$gtp{1}{$i}{$oo} ||=0;
			$gtp{1}{$i}{$ro} ||=0;
			$gtp{1}{$i}{$or} ||=0;
			my $gtprr=$gtp{2}{$i}{$rr};
			my $gtpoo=$gtp{2}{$i}{$oo};
			my $gtpro=$gtp{2}{$i}{$ro}+$gtp{2}{$i}{$or};
			my $gtnrr=$gtp{1}{$i}{$rr};
			my $gtnoo=$gtp{1}{$i}{$oo};
			my $gtnro=$gtp{1}{$i}{$ro}+$gtp{1}{$i}{$or};
			
			my $tempgtp = "$gtprr\/$gtpro\/$gtpoo";
			my $tempgtn = "$gtnrr\/$gtnro\/$gtnoo";
			
			printf f9 "\t%2s\t%2s\t%14s\t%14s", $ra{$i}, $oa{$i}, $tempgtp, $tempgtn;
			
			### allelic odds ratio
			my $or_a = 2 * $gtprr + $gtpro;
			my $or_b = $gtpro + 2 * $gtpoo;
			my $or_c = 2 * $gtnrr + $gtnro;
			my $or_d = $gtnro + 2 * $gtnoo;
			if($or_a > 0 && $or_b >0 && $or_c >0 && $or_d >0)
			{
			my $or_or = ($or_a * $or_d)/($or_b * $or_c);
			my $or_se = sqrt(1/$or_a + 1/$or_b + 1/$or_c + 1/$or_d);
			my $logor = log($or_or);
			my $logL95 = $logor - 1.96 * $or_se;
			my $logU95 = $logor + 1.96 * $or_se;
			my $L95 = exp($logL95);
			my $U95 = exp($logU95);
			printf f9 "\t%6.3f\t%6.3f\t%6.3f\t%6.3f", $or_or, $or_se, $L95, $U95;
			}
			else
			{
			printf f9 "\t%6s\t%6s\t%6s\t%6s", 'NA', 'NA', 'NA', 'NA';
			}
			### param
			my $R=$gtprr+$gtpro+$gtpoo;
			my $S=$gtnrr+$gtnro+$gtnoo;
			my $N=$R+$S;
			my $n0=$gtpoo + $gtnoo;
			my $n1=$gtpro + $gtnro;
			my $n2=$gtprr + $gtnrr;
			
			### calculate freq
			my $fa = $R!=0 ? (2*$gtprr+$gtpro)/(2*$R) : 0;
			my $fu = $S!=0 ? (2*$gtnrr+$gtnro)/(2*$S) : 0;
			my $freq = $N!=0 ? (2*$gtprr+$gtpro+2*$gtnrr+$gtnro)/(2*$N) : 0;
			
			### calculate chi-square
			my $chisq;
			if($model eq "add")
			{
				if((($N-$R)*$R*($N*($n1+4*$n2)-($n1+2*$n2)**2))!=0)
				{
				$chisq=($N*($N*($gtpro+2*$gtprr)-$R*($n1+2*$n2))**2)/(($N-$R)*$R*($N*($n1+4*$n2)-($n1+2*$n2)**2));
				my $p=chisqrprob(1, $chisq);
				printf f9 "%6s\t%5d\t%4.3f\t%4.3f\t%4.3f\t%6.3f\t$p\n", 'ADD', $N, $fa, $fu, $freq, $chisq;
				}
				else
				{
				printf f9 "%6s\t%5d\t%4.3f\t%4.3f\t%4.3f\t%6s\tNA\n", 'ADD', $N, $fa, $fu, $freq, 'NA';
				}
			}
			elsif($model eq "dom")
			{
				if((($N-$R)*$R*$n0*($n1+$n2))!=0)
				{
				$chisq=($N*($N*($gtpro+$gtprr)-$R*($n1+$n2))**2)/(($N-$R)*$R*$n0*($n1+$n2));
				my $p=chisqrprob(1, $chisq);
				printf f9 "%6s\t%5d\t%4.3f\t%4.3f\t%4.3f\t%6.3f\t$p\n", 'DOM', $N, $fa, $fu, $freq, $chisq;
				}
				else
				{
				printf f9 "%6s\t%5d\t%4.3f\t%4.3f\t%4.3f\t%6s\tNA\n", 'DOM', $N, $fa, $fu, $freq, 'NA';
				}
			}
			elsif($model eq "rec")
			{
				if((($N-$R)*$R*$n2*($n1+$n0))!=0)
				{
				$chisq=($N*($N*($gtpro+$gtpoo)-$R*($n1+$n0))**2)/(($N-$R)*$R*$n2*($n1+$n0));
				my $p=chisqrprob(1, $chisq);
				printf f9 "%8s\t%6.3f\t$p\t%5d\t%4.3f\t%4.3f\t%4.3f\n", 'REC', $chisq, $N, $fa, $fu, $freq;
				}
				else
				{
				printf f9 "%6s\t%5d\t%4.3f\t%4.3f\t%4.3f\t%6s\tNA\n", 'REC', $N, $fa, $fu, $freq, 'NA';
				}
			}
			elsif($model eq "best")
			{
			my ($a,$d,$r);
				if((($N-$R)*$R*($N*($n1+4*$n2)-($n1+2*$n2)**2))!=0)
				{
				$a=($N*($N*($gtpro+2*$gtprr)-$R*($n1+2*$n2))**2)/(($N-$R)*$R*($N*($n1+4*$n2)-($n1+2*$n2)**2));
				}
				else
				{
				$a=-1;
				}
				
				if((($N-$R)*$R*$n0*($n1+$n2))!=0)
				{
				$d=$chisq=($N*($N*($gtpro+$gtprr)-$R*($n1+$n2))**2)/(($N-$R)*$R*$n0*($n1+$n2));
				}
				else
				{
				$d=-1;
				}
				
				if((($N-$R)*$R*$n2*($n1+$n0))!=0)
				{
				$r=$chisq=($N*($N*($gtpro+$gtpoo)-$R*($n1+$n0))**2)/(($N-$R)*$R*$n2*($n1+$n0));
				}
				else
				{
				$r=-1;
				}
				
				$chisq = $a >= $d ? $a : $d;
				$chisq = $chisq >= $r ? $chisq : $r;
				
				if($chisq == -1)
				{
				printf f9 "%6s\t%5d\t%4.3f\t%4.3f\t%4.3f\t%6s\tNA\n", 'NA', $N, $fa, $fu, $freq, 'NA';
				}
				elsif($chisq == $a)
				{
				my $p=chisqrprob(1, $chisq);
				printf f9 "%6s\t%5d\t%4.3f\t%4.3f\t%4.3f\t%6.3f\t$p\n", 'ADD', $N, $fa, $fu, $freq, $chisq;
				}
				elsif($chisq == $d)
				{
				my $p=chisqrprob(1, $chisq);
				printf f9 "%6s\t%5d\t%4.3f\t%4.3f\t%4.3f\t%6.3f\t$p\n", 'DOM', $N, $fa, $fu, $freq, $chisq;
				}
				elsif($chisq == $r)
				{
				my $p=chisqrprob(1, $chisq);
				printf f9 "%6s\t%5d\t%4.3f\t%4.3f\t%4.3f\t%6.3f\t$p\n", 'REC', $N, $fa, $fu, $freq, $chisq;
				}
			}
		}
		else
		{
		die "SNP $snps[$i] has $#subkey A|C|G|T alleles\n";
		}
}
##################################################################################################################
my($user, $system, $child_system, $child_user)=times();
print "Time used: $user seconds\n";
print "Analysis finished.\n";
print f99 "Time used: $user seconds\n";
print f99 "Analysis finished.\n";

####################################################################################################################
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use constant PI => 3.1415926536;
use constant SIGNIFICANT => 5; # number of significant digits to be returned

require Exporter;

@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT_OK = qw(chisqrdistr tdistr fdistr udistr uprob chisqrprob tprob fprob);
$VERSION = '1.02';

# Preloaded methods go here.
   
sub chisqrdistr { # Percentage points  X^2(x^2,n)
	my ($n, $p) = @_;
	if ($n <= 0 || abs($n) - abs(int($n)) != 0) {
		die "Invalid n: $n\n"; # degree of freedom
	}
	if ($p <= 0 || $p > 1) {
		die "Invalid p: $p\n"; 
	}
	return precision_string(_subchisqr($n, $p));
}

sub udistr { # Percentage points   N(0,1^2)
	my ($p) = (@_);
	if ($p > 1 || $p <= 0) {
		die "Invalid p: $p\n";
	}
	return precision_string(_subu($p));
}

sub tdistr { # Percentage points   t(x,n)
	my ($n, $p) = @_;
	if ($n <= 0 || abs($n) - abs(int($n)) != 0) {
		die "Invalid n: $n\n";
	}
	if ($p <= 0 || $p >= 1) {
		die "Invalid p: $p\n";
	}
	return precision_string(_subt($n, $p));
}

sub fdistr { # Percentage points  F(x,n1,n2)
	my ($n, $m, $p) = @_;
	if (($n<=0) || ((abs($n)-(abs(int($n))))!=0)) {
		die "Invalid n: $n\n"; # first degree of freedom
	}
	if (($m<=0) || ((abs($m)-(abs(int($m))))!=0)) {
		die "Invalid m: $m\n"; # second degree of freedom
	}
	if (($p<=0) || ($p>1)) {
		die "Invalid p: $p\n";
	}
	return precision_string(_subf($n, $m, $p));
}

sub uprob { # Upper probability   N(0,1^2)
	my ($x) = @_;
	return precision_string(_subuprob($x));
}

sub chisqrprob { # Upper probability   X^2(x^2,n)
	my ($n,$x) = @_;
	if (($n <= 0) || ((abs($n) - (abs(int($n)))) != 0)) {
		die "Invalid n: $n\n"; # degree of freedom
	}
	return precision_string(_subchisqrprob($n, $x));
}

sub tprob { # Upper probability   t(x,n)
	my ($n, $x) = @_;
	if (($n <= 0) || ((abs($n) - abs(int($n))) !=0)) {
		die "Invalid n: $n\n"; # degree of freedom
	}
	return precision_string(_subtprob($n, $x));
}

sub fprob { # Upper probability   F(x,n1,n2)
	my ($n, $m, $x) = @_;
	if (($n<=0) || ((abs($n)-(abs(int($n))))!=0)) {
		die "Invalid n: $n\n"; # first degree of freedom
	}
	if (($m<=0) || ((abs($m)-(abs(int($m))))!=0)) {
		die "Invalid m: $m\n"; # second degree of freedom
	} 
	return precision_string(_subfprob($n, $m, $x));
}


sub _subfprob {
	my ($n, $m, $x) = @_;
	my $p;

	if ($x<=0) {
		$p=1;
	} elsif ($m % 2 == 0) {
		my $z = $m / ($m + $n * $x);
		my $a = 1;
		for (my $i = $m - 2; $i >= 2; $i -= 2) {
			$a = 1 + ($n + $i - 2) / $i * $z * $a;
		}
		$p = 1 - ((1 - $z) ** ($n / 2) * $a);
	} elsif ($n % 2 == 0) {
		my $z = $n * $x / ($m + $n * $x);
		my $a = 1;
		for (my $i = $n - 2; $i >= 2; $i -= 2) {
			$a = 1 + ($m + $i - 2) / $i * $z * $a;
		}
		$p = (1 - $z) ** ($m / 2) * $a;
	} else {
		my $y = atan2(sqrt($n * $x / $m), 1);
		my $z = sin($y) ** 2;
		my $a = ($n == 1) ? 0 : 1;
		for (my $i = $n - 2; $i >= 3; $i -= 2) {
			$a = 1 + ($m + $i - 2) / $i * $z * $a;
		} 
		my $b = PI;
		for (my $i = 2; $i <= $m - 1; $i += 2) {
			$b *= ($i - 1) / $i;
		}
		my $p1 = 2 / $b * sin($y) * cos($y) ** $m * $a;

		$z = cos($y) ** 2;
		$a = ($m == 1) ? 0 : 1;
		for (my $i = $m-2; $i >= 3; $i -= 2) {
			$a = 1 + ($i - 1) / $i * $z * $a;
		}
		$p = max(0, $p1 + 1 - 2 * $y / PI
			- 2 / PI * sin($y) * cos($y) * $a);
	}
	return $p;
}


sub _subchisqrprob {
	my ($n,$x) = @_;
	my $p;

	if ($x <= 0) {
		$p = 1;
	} elsif ($n > 100) {
		$p = _subuprob((($x / $n) ** (1/3)
				- (1 - 2/9/$n)) / sqrt(2/9/$n));
	} elsif ($x > 400) {
		$p = 0;
	} else {   
		my ($a, $i, $i1);
		if (($n % 2) != 0) {
			$p = 2 * _subuprob(sqrt($x));
			$a = sqrt(2/PI) * exp(-$x/2) / sqrt($x);
			$i1 = 1;
		} else {
			$p = $a = exp(-$x/2);
			$i1 = 2;
		}

		for ($i = $i1; $i <= ($n-2); $i += 2) {
			$a *= $x / $i;
			$p += $a;
		}
	}
	return $p;
}

sub _subu {
	my ($p) = @_;
	my $y = -log(4 * $p * (1 - $p));
	my $x = sqrt(
		$y * (1.570796288
		  + $y * (.03706987906
		  	+ $y * (-.8364353589E-3
			  + $y *(-.2250947176E-3
			  	+ $y * (.6841218299E-5
				  + $y * (0.5824238515E-5
					+ $y * (-.104527497E-5
					  + $y * (.8360937017E-7
						+ $y * (-.3231081277E-8
						  + $y * (.3657763036E-10
							+ $y *.6936233982E-12)))))))))));
	$x = -$x if ($p>.5);
	return $x;
}

sub _subuprob {
	my ($x) = @_;
	my $p = 0; # if ($absx > 100)
	my $absx = abs($x);

	if ($absx < 1.9) {
		$p = (1 +
			$absx * (.049867347
			  + $absx * (.0211410061
			  	+ $absx * (.0032776263
				  + $absx * (.0000380036
					+ $absx * (.0000488906
					  + $absx * .000005383)))))) ** -16/2;
	} elsif ($absx <= 100) {
		for (my $i = 18; $i >= 1; $i--) {
			$p = $i / ($absx + $p);
		}
		$p = exp(-.5 * $absx * $absx) 
			/ sqrt(2 * PI) / ($absx + $p);
	}

	$p = 1 - $p if ($x<0);
	return $p;
}

   
sub _subt {
	my ($n, $p) = @_;

	if ($p >= 1 || $p <= 0) {
		die "Invalid p: $p\n";
	}

	if ($p == 0.5) {
		return 0;
	} elsif ($p < 0.5) {
		return - _subt($n, 1 - $p);
	}

	my $u = _subu($p);
	my $u2 = $u ** 2;

	my $a = ($u2 + 1) / 4;
	my $b = ((5 * $u2 + 16) * $u2 + 3) / 96;
	my $c = (((3 * $u2 + 19) * $u2 + 17) * $u2 - 15) / 384;
	my $d = ((((79 * $u2 + 776) * $u2 + 1482) * $u2 - 1920) * $u2 - 945) 
				/ 92160;
	my $e = (((((27 * $u2 + 339) * $u2 + 930) * $u2 - 1782) * $u2 - 765) * $u2
			+ 17955) / 368640;

	my $x = $u * (1 + ($a + ($b + ($c + ($d + $e / $n) / $n) / $n) / $n) / $n);

	if ($n <= log10($p) ** 2 + 3) {
		my $round;
		do { 
			my $p1 = _subtprob($n, $x);
			my $n1 = $n + 1;
			my $delta = ($p1 - $p) 
				/ exp(($n1 * log($n1 / ($n + $x * $x)) 
					+ log($n/$n1/2/PI) - 1 
					+ (1/$n1 - 1/$n) / 6) / 2);
			$x += $delta;
			$round = sprintf("%.".abs(int(log10(abs $x)-4))."f",$delta);
		} while (($x) && ($round != 0));
	}
	return $x;
}

sub _subtprob {
	my ($n, $x) = @_;

	my ($a,$b);
	my $w = atan2($x / sqrt($n), 1);
	my $z = cos($w) ** 2;
	my $y = 1;

	for (my $i = $n-2; $i >= 2; $i -= 2) {
		$y = 1 + ($i-1) / $i * $z * $y;
	} 

	if ($n % 2 == 0) {
		$a = sin($w)/2;
		$b = .5;
	} else {
		$a = ($n == 1) ? 0 : sin($w)*cos($w)/PI;
		$b= .5 + $w/PI;
	}
	return max(0, 1 - $b - $a * $y);
}

sub _subf {
	my ($n, $m, $p) = @_;
	my $x;

	if ($p >= 1 || $p <= 0) {
		die "Invalid p: $p\n";
	}

	if ($p == 1) {
		$x = 0;
	} elsif ($m == 1) {
		$x = 1 / (_subt($n, 0.5 - $p / 2) ** 2);
	} elsif ($n == 1) {
		$x = _subt($m, $p/2) ** 2;
	} elsif ($m == 2) {
		my $u = _subchisqr($m, 1 - $p);
		my $a = $m - 2;
		$x = 1 / ($u / $m * (1 +
			(($u - $a) / 2 +
				(((4 * $u - 11 * $a) * $u + $a * (7 * $m - 10)) / 24 +
					(((2 * $u - 10 * $a) * $u + $a * (17 * $m - 26)) * $u
						- $a * $a * (9 * $m - 6)
					)/48/$n
				)/$n
			)/$n));
	} elsif ($n > $m) {
		$x = 1 / _subf2($m, $n, 1 - $p)
	} else {
		$x = _subf2($n, $m, $p)
	}
	return $x;
}

sub _subf2 {
	my ($n, $m, $p) = @_;
	my $u = _subchisqr($n, $p);
	my $n2 = $n - 2;
	my $x = $u / $n * 
		(1 + 
			(($u - $n2) / 2 + 
				(((4 * $u - 11 * $n2) * $u + $n2 * (7 * $n - 10)) / 24 + 
					(((2 * $u - 10 * $n2) * $u + $n2 * (17 * $n - 26)) * $u 
						- $n2 * $n2 * (9 * $n - 6)) / 48 / $m) / $m) / $m);
	my $delta;
	do {
		my $z = exp(
			(($n+$m) * log(($n+$m) / ($n * $x + $m)) 
				+ ($n - 2) * log($x)
				+ log($n * $m / ($n+$m))
				- log(4 * PI)
				- (1/$n  + 1/$m - 1/($n+$m))/6
			)/2);
		$delta = (_subfprob($n, $m, $x) - $p) / $z;
		$x += $delta;
	} while (abs($delta)>3e-4);
	return $x;
}

sub _subchisqr {
	my ($n, $p) = @_;
	my $x;

	if (($p > 1) || ($p <= 0)) {
		die "Invalid p: $p\n";
	} elsif ($p == 1){
		$x = 0;
	} elsif ($n == 1) {
		$x = _subu($p / 2) ** 2;
	} elsif ($n == 2) {
		$x = -2 * log($p);
	} else {
		my $u = _subu($p);
		my $u2 = $u * $u;

		$x = max(0, $n + sqrt(2 * $n) * $u 
			+ 2/3 * ($u2 - 1)
			+ $u * ($u2 - 7) / 9 / sqrt(2 * $n)
			- 2/405 / $n * ($u2 * (3 *$u2 + 7) - 16));

		if ($n <= 100) {
			my ($x0, $p1, $z);
			do {
				$x0 = $x;
				if ($x < 0) {
					$p1 = 1;
				} elsif ($n>100) {
					$p1 = _subuprob((($x / $n)**(1/3) - (1 - 2/9/$n))
						/ sqrt(2/9/$n));
				} elsif ($x>400) {
					$p1 = 0;
				} else {
					my ($i0, $a);
					if (($n % 2) != 0) {
						$p1 = 2 * _subuprob(sqrt($x));
						$a = sqrt(2/PI) * exp(-$x/2) / sqrt($x);
						$i0 = 1;
					} else {
						$p1 = $a = exp(-$x/2);
						$i0 = 2;
					}

					for (my $i = $i0; $i <= $n-2; $i += 2) {
						$a *= $x / $i;
						$p1 += $a;
					}
				}
				$z = exp((($n-1) * log($x/$n) - log(4*PI*$x) 
					+ $n - $x - 1/$n/6) / 2);
				$x += ($p1 - $p) / $z;
				$x = sprintf("%.5f", $x);
			} while (($n < 31) && (abs($x0 - $x) > 1e-4));
		}
	}
	return $x;
}

sub log10 {
	my $n = shift;
	return log($n) / log(10);
}
 
sub max {
	my $max = shift;
	my $next;
	while (@_) {
		$next = shift;
		$max = $next if ($next > $max);
	}	
	return $max;
}

sub min {
	my $min = shift;
	my $next;
	while (@_) {
		$next = shift;
		$min = $next if ($next < $min);
	}	
	return $min;
}

sub precision {
	my ($x) = @_;
	return abs int(log10(abs $x) - SIGNIFICANT);
}

sub precision_string {
	my ($x) = @_;
	if ($x) {
		return sprintf "%." . precision($x) . "f", $x;
	} else {
		return "0";
	}
}