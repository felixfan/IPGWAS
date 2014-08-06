package Merge::CheckSNPsOrderChrPhy;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

sub CheckSNPsOrderChrPhyPos
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";

my $ooo;
my $ok_frame;

$gp_win->geometry("450x180");
$gp_win->title("Check SNPs Order & Chromosome & Physical Position");

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
														
														my $outname=$output_name->get('0.0', 'end');
														chomp $outname;
														my $outlog="$dir$outname.log";
														my $outname1="$dir$outname"."_order.txt";
														
														my $outname99="$dir$outname"."_probSNPs.txt";
														
														my $m=0; # number of SNPs
														my $n=0; # number of different order SNPs
														my $x=0; # number of different chr SNPs
														my $y=0; # number of different phy SNPs
														
														my (%chr1, %phy1, %chr2, %phy2);
														
														#----------------------
														open(f1, $inpath);
														open(f2, $inpath2);
														open(f3, ">$outname1");
														open(f4, ">$outlog");
														open(f99, ">$outname99");
														my $one;
														my $two;
														
														
														while($one=<f1>)
														{
														$two=<f2>;
														my @arr=split(/\s+/, $one);
														my @arr1=split(/\s+/, $two);
														###check order
															if($arr[1] eq $arr1[1])
															{
															print f3 "Ok\n";
															}
															else
															{
															print f3 "$arr[1]\t$arr1[1]\n";
															$m++;
															}
														###chr
															$chr1{$arr[1]}=$arr[0];
															$chr2{$arr1[1]}=$arr1[0];
														###phy
															$phy1{$arr[1]}=$arr[3];
															$phy2{$arr1[1]}=$arr1[3];
														###														
														$n++;	
														}
														close f3;
														close f2;
														close f1;
														###check order log
														if($m > 0)
														{
														print "Check SNPs order...\n$m of $n SNPs has different order\n";
														$output_text->insert('end', "Check SNPs order...\n$m of $n SNPs has different order\n");
														print f4 "Check SNPs order...\n$m of $n SNPs has different order\n";
														}
														else
														{
														print "Check SNPs order...\nAll SNPs in the same order\n";
														$output_text->insert('end', "Check SNPs order...\nAll SNPs in the same order\n");
														print f4 "Check SNPs order...\nAll SNPs in the same order\n";
														unlink $outname1;
														}
													#----------	
													#check chr
													my $outname2="$dir$outname"."_chr.txt";
													open(f1,">$outname2");
													print f1 "SNP\tCHR1\tCHR2\n";
														foreach my $key (keys %chr1)
														{
															if($chr1{$key} ne $chr2{$key})
															{
															$x++;
															print f1 "$key\t$chr1{$key}\t$chr2{$key}\n";
															print f99 "$key\n";
															}
														}
													close f1;
													
														if($x > 0)
														{
														print "Check chromosome information...\n$x of $n SNPs has different chromosome\nPlease update chromosome information\n";
														$output_text->insert('end', "Check chromosome information...\n$x of $n SNPs has different chromosome\nPlease update chromosome information\n");
														print f4 "Check chromosome information...\n$x of $n SNPs has different chromosome\nPlease update chromosome information\n";
														}
														else
														{
														print "Check chromosome information...\nAll SNPs in the same chromosome\n";
														$output_text->insert('end', "Check chromosome information...\nAll SNPs in the same chromosome\n");
														print f4 "Check chromosome information...\nAll SNPs in the same chromosome\n";
														unlink $outname2;
														}
													#--------------------
													#check phy
													my $outname3="$dir$outname"."_phy.txt";
													open(f1,">$outname3");
													print f1 "SNP\tPhyPos1\tPhyPos2\n";
														foreach my $key (keys %phy1)
														{
															if($phy1{$key} ne $phy2{$key})
															{
															$y++;
															print f1 "$key\t$phy1{$key}\t$phy2{$key}\n";
															print f99 "$key\n";
															}
														}
													close f1;
													
														if($y > 0)
														{
														print "Checking the physical position information...\n$y of $n SNPs has different physical position\nPlease update physical position information\nDone.\n";
														$output_text->insert('end', "Checking the physical position information...\n$y of $n SNPs has different physical position\nPlease update physical position information\nDone.\n");
														print f4 "Checking the physical position information...\n$y of $n SNPs has different physical position\nPlease update physical position information\nDone.";
														}
														else
														{
														print "Checking the physical position information...\nAll SNPs has the same physical position\nDone.\n";
														$output_text->insert('end', "Checking the physical position information...\nAll SNPs has the same physical position\nDone.\n");
														print f4 "Checking the physical position information...\nAll SNPs has the same physical position\nDone.\n";
														unlink $outname3;
														}
													#--------------------
													close f99;
													
													if($x==0 && $y==0)
													{
													unlink $outname99;
													}
													else
													{
													print "Write the PROBLEM SNPs ID to: $outname99\n\nDone.\n";
													print f4 "Write the PROBLEM SNPs ID to: $outname99\n\nDone.\n";
													$output_text->insert('end', "Write the PROBLEM SNPs ID to: $outname99\n\nDone.\n");
													}
													close f4;
													
												}
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

#output_frame
$ooo=Plink::SBoutput::outputFrame($gp_win, $ok_frame);
$output_name=Plink::SBoutput::outputName($ooo);
}
1;

