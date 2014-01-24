package Merge::diffStrandSNPs;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

#identify & remove bad SNPs
#identify & extract common SNPs
#identify & flip different strand SNPs

sub IdentifyDiffStrandSNPs 
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";

my $ooo;
my $ok_frame;
my $out_format="make-bed";

$gp_win->geometry("480x180");
$gp_win->title("Remove bad SNPs and combine common SNPs");

$gp_win->resizable(0, 0);

my $input_path2="";
#input_frame
my $ttt=Plink::SBinput::InputFrame($gp_win);
$input_path=Plink::SBinput::InputContentBim($mw, $ttt);
$input_path2=Plink::SBinput::InputContentBim($mw, $ttt);
										  
#sub ok button
$ok_frame = $gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side => "top"); # button frame
	$ok_frame->Button(-text => "OK",-command =>sub{
														my $inpath=$input_path->get('0.0', 'end');
															chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No bim 1 file\n");
															die "No bim 1 file: $!\n";
															}
														my $inpath2=$input_path2->get('0.0', 'end');
															chomp $inpath2;
															if(! $inpath2)
															{
															$output_text->insert('end', "No bim 2 file\n");
															die "No bim 2 file: $!\n";
															}	
														my($base,$dir,$ext)=fileparse($inpath,'\..*');
														my($base2,$dir2,$ext2)=fileparse($inpath2,'\..*');
														
														my $outname=$output_name->get('0.0', 'end');
														chomp $outname;
														# my $outname1=$outname;  #plink out
														my $outname2="$dir$outname"."_diffStrand.txt"; #diff strand
														my $outname3="$dir$base"."_badSNPs.txt"; # bim 1 bad SNP list
														my $outname4="$dir2$base2"."_badSNPs.txt"; # bim 2 bad SNP list
														my $outname5="$dir$base.$base2"."_commonSNPs.txt"; # bim1 & bim 2 common SNP list
														my $outname6="$dir$outname"."_ipgwas.log"; # log
														#----------------------
														
														my (%bim1AlleleA, %bim2AlleleA, %bim2AlleleB, %snpid);
														
														my ($n1, $n2, $m1, $m2, $z1, $z2)=(0,0,0,0,0,0); #n1: snp in bim1, n2: snp in bim2, m1: common snp, m2: diff strand in common, z1: bim1 bad snp, z2: bim2 bad snp 
														
														print "Reading data from $inpath\n";
														$output_text->insert('end', "Reading data from $inpath\n");
														
														#read data 1
														open(f1, $inpath);
														open(f2, ">$outname3");
														while(<f1>)
														{
														chomp;
														my @arr=split(/\s+/, $_);
														$n1++;
															#BAD SNP
															if($arr[4] eq "G" && $arr[5] eq "C" || $arr[4] eq "C" && $arr[5] eq "G" || $arr[4] eq "A" && $arr[5] eq "T" || $arr[4] eq "T" && $arr[5] eq "A")
															{
															print f2 "$arr[1]\n";
															$z1++;
															}
															else
															{
															$snpid{$arr[1]}=1;
															$bim1AlleleA{$arr[1]}=$arr[4];
															}
														}
														close f1;
														close f2;
														
														print "Reading data from $inpath2\n";
														$output_text->insert('end', "Reading data from $inpath2\n");
														
														#read data 2
														open(f1, $inpath2);
														open(f2, ">$outname4");
														while(<f1>)
														{
														chomp;
														my @arr=split(/\s+/, $_);
														$n2++;
															#BAD SNP
															if($arr[4] eq "G" && $arr[5] eq "C" || $arr[4] eq "C" && $arr[5] eq "G" || $arr[4] eq "A" && $arr[5] eq "T" || $arr[4] eq "T" && $arr[5] eq "A")
															{
															print f2 "$arr[1]\n";
															$z2++;
															}
															else
															{
																if(exists $snpid{$arr[1]})
																{
																$snpid{$arr[1]}++;
																}
																else
																{
																$snpid{$arr[1]}=1;
																}
															$bim2AlleleA{$arr[1]}=$arr[4];
															$bim2AlleleB{$arr[1]}=$arr[5];
															}
														}
														close f1;
														close f2;
														
														my $rmBadSNP="rmBadSNP";
														
														### remove bad SNPs
														if($z1 > 0)
														{
														print "$z1 of $n1 SNPs are bad SNPs in $inpath\nWrite bad SNP list to: $outname3\nRemoving bad SNPs...\n";
														$output_text->insert('end', "$z1 of $n1 SNPs are bad SNPs\nWrite bad SNP list to: $outname3\nRemoving bad SNPs...\n");
														
														my $runcom="$plink --bfile $dir$base --exclude $outname3 --$out_format --out $dir$base$rmBadSNP";
														my $runcomOut=qx/$runcom/;
														
														$output_text->insert('end', "$runcomOut\n");
														}
														else
														{
														print "$z1 of $n1 SNPs are bad SNPs in $inpath\n";
														$output_text->insert('end', "$z1 of $n1 SNPs are bad SNPs in $inpath\n");
														unlink $outname3;
														}
														###
														if($z2 > 0)
														{
														print "$z2 of $n2 SNPs are bad SNPs in $inpath2\nWrite bad SNP list to: $outname4\nRemoving bad SNPs...\n";
														$output_text->insert('end', "$z2 of $n2 SNPs are bad SNPs\nWrite bad SNP list to: $outname4\nRemoving bad SNPs...\n");
														
														my $runcom2="$plink --bfile $dir2$base2 --exclude $outname4 --$out_format --out $dir2$base2$rmBadSNP";
														my $runcomOut2=qx/$runcom2/;
														
														$output_text->insert('end', "$runcomOut2\n");
														}
														else
														{
														print "$z2 of $n2 SNPs are bad SNPs in $inpath2\n";
														$output_text->insert('end', "$z2 of $n2 SNPs are bad SNPs\n");
														unlink $outname4;
														}
														
														my $bs1=$n1-$z1;
														my $bs2=$n2-$z2;
														
														print "After removing the bad SNPs\n$bs1 SNPs left in $inpath\n$bs2 SNPs left in $inpath2\n";
														$output_text->insert('end', "After removing the bad SNPs\n$bs1 SNPs left in $inpath\n$bs2 SNPs left in $inpath2\n");
														
														### commonSNPs && different strand
														
														open(f1, ">$outname5");
														open(f2, ">$outname2");
														foreach my $key (keys %snpid)
														{
															if($snpid{$key}==2)
															{
															print f1 "$key\n";
															$m1++;
																if($bim1AlleleA{$key} ne $bim2AlleleA{$key} && $bim1AlleleA{$key} ne $bim2AlleleB{$key})
																{
																$m2++;
																print f2 "$key\n";
																}
															}
														}
														close f1;
														close f2;
														
														my $commonSNP="commonSNP";
														
														###
														if($m1 > 0)
														{
														print "There are $m1 common SNPs\nWrite common SNP list to: $outname5\nExtract common SNPs...\n";
														$output_text->insert('end', "There are $m1 common SNPs\nWrite common SNP list to: $outname5\nExtract common SNPs...\n");
															if($z1 > 0)
															{
															my $runcom3="$plink --bfile $dir$base$rmBadSNP --extract $outname5 --$out_format --out $dir$base$commonSNP";
															my $runcomOut3=qx/$runcom3/;
															
															$output_text->insert('end', "$runcomOut3\n");
															
															unlink "$dir$base$rmBadSNP.bed" if(-e "$dir$base$rmBadSNP.bed");
															unlink "$dir$base$rmBadSNP.bim" if(-e "$dir$base$rmBadSNP.bim");
															unlink "$dir$base$rmBadSNP.fam" if(-e "$dir$base$rmBadSNP.fam");
															unlink "$dir$base$rmBadSNP.log" if(-e "$dir$base$rmBadSNP.log");
															unlink "$dir$base$rmBadSNP.hh" if(-e "$dir$base$rmBadSNP.hh");
															}
															else
															{
															my $runcom4="$plink --bfile $dir$base --extract $outname5 --$out_format --out $dir$base$commonSNP";
															my $runcomOut4=qx/$runcom4/;
															
															$output_text->insert('end', "$runcomOut4\n");
															}
															###
															if($z2 > 0)
															{
															my $runcom5="$plink --bfile $dir2$base2$rmBadSNP --extract $outname5 --$out_format --out $dir2$base2$commonSNP";
															my $runcomOut5=qx/$runcom5/;
															
															$output_text->insert('end', "$runcomOut5\n");
															
															unlink "$dir2$base2$rmBadSNP.bed" if(-e "$dir2$base2$rmBadSNP.bed");
															unlink "$dir2$base2$rmBadSNP.bim" if(-e "$dir2$base2$rmBadSNP.bim");
															unlink "$dir2$base2$rmBadSNP.fam" if(-e "$dir2$base2$rmBadSNP.fam");
															unlink "$dir2$base2$rmBadSNP.log" if(-e "$dir2$base2$rmBadSNP.log");
															unlink "$dir2$base2$rmBadSNP.hh" if(-e "$dir2$base2$rmBadSNP.hh");
															}
															else
															{
															my $runcom6="$plink --bfile $dir2$base2 --extract $outname5 --$out_format --out $dir2$base2$commonSNP";
															my $runcomOut6=qx/$runcom6/;
															
															$output_text->insert('end', "$runcomOut6\n");
															}
														}
														else
														{
														print "There are $m1 common SNPs\n";
														$output_text->insert('end', "There are $m1 common SNPs\n");
														unlink $outname5;
														}
														
														my $flip="flip";
														
														###different strand
														if($m2 > 0)
														{
														print "$m2 SNPs in different strand\nWrite SNP list to: $outname2\nFlipping strand...\n";
														$output_text->insert('end', "$m2 SNPs in different strand\nWrite SNP list to: $outname2\nFlipping strand...\n");
															if($m1 > 0)
															{
															my $runcom7="$plink --bfile $dir2$base2$commonSNP --flip $outname2 --$out_format --out $dir2$base2$commonSNP$flip";
															my $runcomOut7=qx/$runcom7/;
															
															$output_text->insert('end', "$runcomOut7\n");
															
															unlink "$dir2$base2$commonSNP.bed" if(-e "$dir2$base2$commonSNP.bed");
															unlink "$dir2$base2$commonSNP.bim" if(-e "$dir2$base2$commonSNP.bim");
															unlink "$dir2$base2$commonSNP.fam" if(-e "$dir2$base2$commonSNP.fam");
															unlink "$dir2$base2$commonSNP.log" if(-e "$dir2$base2$commonSNP.log");
															unlink "$dir2$base2$commonSNP.hh" if(-e "$dir2$base2$commonSNP.hh");
															}
															else
															{
																if($z2 > 0)
																{
																my $runcom8="$plink --bfile $dir2$base2$rmBadSNP --flip $outname2 --$out_format --out $dir2$base2$commonSNP$flip";
																my $runcomOut8=qx/$runcom8/;
																
																$output_text->insert('end', "$runcomOut8\n");
																
																unlink "$dir2$base2$rmBadSNP.bed" if(-e "$dir2$base2$rmBadSNP.bed");
																unlink "$dir2$base2$rmBadSNP.bim" if(-e "$dir2$base2$rmBadSNP.bim");
																unlink "$dir2$base2$rmBadSNP.fam" if(-e "$dir2$base2$rmBadSNP.fam");
																unlink "$dir2$base2$rmBadSNP.log" if(-e "$dir2$base2$rmBadSNP.log");
																unlink "$dir2$base2$rmBadSNP.hh" if(-e "$dir2$base2$rmBadSNP.hh");
																}
																else
																{
																my $runcom9="$plink --bfile $dir2$base2 --flip $outname2 --$out_format --out $dir2$base2$commonSNP$flip";
																my $runcomOut9=qx/$runcom9/;
																
																$output_text->insert('end', "$runcomOut9\n");
																}
															}
														
														print "Done.\n";
														}
														else
														{
														unlink $outname2;
														print "All SNPs in the same strand\n";
														$output_text->insert('end', "All SNPs in the same strand\n");
														}
														
														############log
														
														###bim 1
														
															if($m1 > 0)
															{
															print "Common SNPs of $inpath were write to: $dir$base$commonSNP(.bed, .bim, .fam)\n";
															$output_text->insert('end', "Common SNPs of $inpath were write to: $dir$base$commonSNP(.bed, .bim, .fam)\n");
															}
															
														### bim 2
												
														if($m2 > 0)
														{
														print "Common SNPs of $inpath2 were write to: $dir2$base2$commonSNP$flip(.bed, .bim, .fam)\n";
														$output_text->insert('end', "Common SNPs of $inpath2 were write to: $dir2$base2$commonSNP$flip(.bed, .bim, .fam)\n");
														}
														else
														{
															if($m1 > 0)
															{
															print "Common SNPs of $inpath2 were write to: $dir2$base2$commonSNP(.bed, .bim, .fam)\n";
															$output_text->insert('end', "Common SNPs of $inpath2 were write to: $dir$base$commonSNP(.bed, .bim, .fam)\n");
															}
															else
															{
															print "No common SNPs in $inpath and $inpath2\n";
															}
														}
														###write log file
														
														print "Write log to: $outname6\nDone\n";
														$output_text->insert('end', "Write log to: $outname6\nDone\n");
														
														my $mylog=$output_text->get('0.0', 'end');
														open(f0, ">$outname6");
														print f0 $mylog;
														close f0;
														
												}
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

#output_frame
$ooo=Plink::SBoutput::outputFrame($gp_win, $ok_frame);
$output_name=Plink::SBoutput::outputName($ooo);
}
1;

