#!/usr/bin/perl

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename ;

my $ploteig="$Bin/ploteig.pl";

my ($evec, $gfile, $gnuplot, $m, $output, $dir)=@ARGV;
####
###$evec evec file from eigenstrat
###$gfile: input file name for gnuplot
###$gnuplot: executable gnuplot
###$m output format, ps or png
###$output: file name of the plot
####

### make string of populations for ploteig
$popstring = "";
open(EVEC,$evec) || die("OOPS couldn't open file $evec for reading");
while($line = <EVEC>)
{
  chomp($line);
  my @array = split(/[\t ]+/,$line);
  $x = @array;
  if($array[1] =~ /eigvals/) { next; } # eigvals header line
  $pop = $array[$x-1];
  if($popfound{$pop}) { next; }
  $popstring = $popstring . "$pop:";
  $popfound{$pop} = 1;
}
close(EVEC);
chop($popstring); # remove last ":"

### cax ploteig
system("perl $ploteig $evec $popstring $gfile $m $output $dir");

### plot
system("$gnuplot $gfile");
