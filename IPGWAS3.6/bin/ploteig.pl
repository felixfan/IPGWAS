#!/usr/local/bin/perl  -w 

use File::Basename ;

my($infile, $pops, $gnfile, $m, $output, $dir)=@ARGV;

$title = "" ;
$zsep = ":";

open (FF, $infile) || die "can't open $infile\n" ;
@L = (<FF>) ;
chomp @L ;
$nf = 0 ;
foreach $line (@L) { 
 next if ($line =~ /\#/) ;
 @Z = split " ", $line ;
 $x = @Z ;
 $nf = $x if ($nf < $x) ;
}
printf "## number of fields: %d\n", $nf ;
$popcol = $nf-1 ;

$popsname = setpops ($pops) ;
print "$popsname\n" ;

$c1 = 1; $c2 =2 ;

$stem = "$infile.$c1.$c2" ;

@T = () ; ## trash 
open (GG, ">$gnfile") || die "can't open $gnfile\n" ;

	if($m eq "ps")
	{
	$m="postscript color";
	$output.=".ps" if($output!~/.ps$/);
	}
	elsif($m eq "png")
	{
	$m="png";
	$output.=".png" if($output!~/.png$/);
	}
	elsif($m eq "eps")
	{
	$m="postscript eps enhanced color";
	$output.=".eps" if($output!~/.eps$/);
	}
	elsif($m eq "gif")
	{
	$m="gif";
	$output.=".gif" if($output!~/.gif$/);
	}
	elsif($m eq "jpeg")
	{
	$m="jpeg";
	$output.=".jpeg" if($output!~/.jpeg$/);
	}
	else
	{
	die "term can only be \"ps\", \"png\", \"eps\", \"gif\", \"jpeg\"\n";
	}
print GG "set terminal $m\n"; ### output png file/ps file
print GG "set output \"$output\"\n";
print GG "set title  \"$title\" \n" ; 
print GG "set key outside\n";
print GG "set xlabel  \"eigenvector $c1\" \n" ; 
print GG "set ylabel  \"eigenvector $c2\" \n" ; 
print GG "plot " ;

$np = @P ;
$lastpop = $P[$np-1] ;
$d1 = $c1+1 ;
$d2 = $c2+1 ;
foreach $pop (@P)  { 
 $dfile = "$stem.$pop.txt" ;
 push @T, $dfile ;
 print GG " \"$dfile\" using $d1:$d2 title \"$pop\" " ;
 print GG ", \\\n" unless ($pop eq $lastpop) ;
 # $dfile="$dir$dfile";
 open (YY, ">$dfile") || die "can't open $dfile\n" ;
 foreach $line (@L) {
  next if ($line =~ /\#/) ;
  @Z = split " ", $line ;
  next unless (defined $Z[$popcol]) ;
  next unless ($Z[$popcol] eq $pop) ;
  print YY "$line\n" ;
 }
 close YY ;
}
print GG "\n" ;
close GG ;

# system "ps2pdf  $psfile " ;

# unlink (@T) unless $keepflag ;

sub usage { 
 
print "ploteig -i eigfile -p pops -c a:b [-t title] [-s stem] [-o outfile] [-x] [-k]\n" ;  
print "-i eigfile     input file first col indiv-id last col population\n" ;
print "## as output by smartpca in outputvecs \n" ;
print "-c a:b         a, b columns to plot.  1:2 would be common and leading 2 eigenvectors\n" ;
print "-p pops        Populations to plot.  : delimited.   eg  -p Bantu:San:French\n" ;
print "## pops can also be a filename.  List populations 1 per line\n" ;
print "[-s stem]      stem will start various output files\n"  ;
print "[-o ofile]     ofile will be gnuplot control file.  Should have xtxt suffix\n"; 
print "[-x]           make ps and pdf files\n" ; 
print "[-k]           keep various intermediate files although  -x set\n" ;
print "## necessary if .xtxt file is to be hand edited\n" ;
print "[-y]           put key at top right inside box (old mode)\n" ;
print "[-t]           title (legend)\n" ;

print "The xtxt file is a gnuplot file and can be easily hand edited.  Intermediate files
needed if you want to make your own plot\n" ;

}
sub setpops {      
 my ($pops) = @_  ; 
 local (@a, $d, $b, $e) ; 

 if (-e $pops) {  
  open (FF1, $pops) || die "can't open $pops\n" ;
  @P = () ;
  foreach $line (<FF1>) { 
  ($a) = split " ", $line ;
  next unless (defined $a) ;
  next if ($a =~ /\#/) ;
  push  @P, $a ;
  }
  $out = join ":", @P ; 
  print "## pops: $out\n" ;
  ($b, $d , $e) = fileparse($pops) ;
  return $b ;
 }
 @P = split $zsep, $pops ;
 return $pops ;

}
