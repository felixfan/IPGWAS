package Merge::commonSNPs;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

sub IdentifyExtractCommonSNPs
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";

my $ooo;
my $ok_frame;

$gp_win->geometry("450x180");
$gp_win->title("Identify & Extract Common SNPs");

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
														my $outlog="$dir$outname.log";
														$outname="$dir$outname.txt";
														my $m=0;
														my $n=0;
														my $t=0;
														my %snp;
														#----------------------
														open(f1, $inpath);
														while(<f1>)
														{
														my @arr=split(/\s+/, $_);
														$snp{$arr[1]}=1;
														$n++;
														}
														close f1;
														#----------------------
														open(f2, $inpath2);
														open(f3, ">$outname");
														open(f4, ">$outlog");
														while(<f2>)
														{
														my @arr=split(/\s+/, $_);
															if(exists $snp{$arr[1]})
															{
															print f3 "$arr[1]\n";
															$t++;
															}
														$m++;	
														}
														close f3;
														close f2;
														print "$inpath has $n SNPs\n$inpath2 has $m SNPs\nThere are $t common SNPs\n";
														print f4 "$inpath has $n SNPs\n$inpath2 has $m SNPs\nThere are $t common SNPs\n";
														close f4;
														$output_text->insert('end', "$inpath has $n SNPs\n$inpath2 has $m SNPs\nThere are $t common SNPs\n");
														###Extract common SNPs
														if($t>0)
														{
														print "Extracting common SNPs from $inpath\n";
														$output_text->insert('end', "Extracting common SNPs from $inpath\n");
														
														my $bim1out="$base"."_commonSNPs";
														my $runcom="$plink --bfile $dir$base --extract $outname --make-bed --out $dir$bim1out";
														my $runcomOut=qx/$runcom/;
														
														$output_text->insert('end', "$runcomOut\n");
														
														print "Extracting common SNPs from $inpath2\n";
														$output_text->insert('end', "Extracting common SNPs from $inpath2\n");
														
														my $bim2out="$base2"."_commonSNPs";
														my $runcom2="$plink --bfile $dir2$base2 --extract $outname --make-bed --out $dir$bim2out";
														my $runcomOut2=qx/$runcom2/;
														
														$output_text->insert('end', "$runcomOut2\n");
														}
														else
														{
														print "There is no common SNPs in $inpath and $inpath2\n";
														unlink $outname;
														}
														
														print "Done.\n";
														$output_text->insert('end', "Done.\n");
												}
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

#output_frame
$ooo=Plink::SBoutput::outputFrame($gp_win, $ok_frame);
$output_name=Plink::SBoutput::outputName($ooo);
}
1;

