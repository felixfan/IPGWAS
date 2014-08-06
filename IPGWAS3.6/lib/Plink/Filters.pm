package Plink::Filters;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

sub FiltersThresholds
{
my($output_text, $mw, $gp_win, $myopt, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $out_format="";
my $ooo;
my $ok_frame;

$gp_win->geometry("450x320");
$gp_win->title("Filters");

$gp_win->resizable(0, 0);

my ($mind, $maf, $geno, $hwe, $me);
my ($text1, $text2, $text3, $text4, $text5, $text6);
my $hwe_opt;
#---
if($myopt eq "mind")
{
($mind, $maf, $geno, $hwe, $me)=(1, 0, 0, 0, 0);
}
elsif($myopt eq "maf")
{
($mind, $maf, $geno, $hwe, $me)=(0, 1, 0, 0, 0);
}
elsif($myopt eq "geno")
{
($mind, $maf, $geno, $hwe, $me)=(0, 0, 1, 0, 0);
}
elsif($myopt eq "hwe")
{
($mind, $maf, $geno, $hwe, $me)=(0, 0, 0, 1, 0);
}
elsif($myopt eq "me")
{
($mind, $maf, $geno, $hwe, $me)=(0, 0, 0, 0, 1);
}
#---

#input_frame
my $ttt=Plink::SBinput::InputFrame($gp_win);
$input_path=Plink::SBinput::InputContent($mw, $ttt);
										  
#sub ok button
$ok_frame = $gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side => "top"); # button frame
	$ok_frame->Button(-text => "OK",-command =>sub{
														my $inpath=$input_path->get('0.0', 'end');
															chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No PED/BED file\n");
															die "No PED/BED file: $!\n";
															}
														
														my $outname=$output_name->get('0.0', 'end');
														chomp $outname;
														
														my($base,$dir,$ext)=fileparse($inpath,'\..*');
														
														my $mycom;
														
														if($ext eq ".ped")
														{
														$mycom="--file $dir$base";
														}
														elsif($ext eq ".bed")
														{
														$mycom="--bfile $dir$base";
														}
														#-------------------
														if($mind == 1)
														{
														my $tt1=$text1->get('0.0', 'end');
														chomp $tt1;
														$mycom.=" --mind $tt1";
														}
														#--------------------
														if($maf == 1)
														{
														my $tt2=$text2->get('0.0', 'end');
														chomp $tt2;
														$mycom.=" --maf $tt2";
														}
														#--------------------
														if($geno == 1)
														{
														my $tt3=$text3->get('0.0', 'end');
														chomp $tt3;
														$mycom.=" --geno $tt3";
														}
														#--------------------
														if($hwe == 1)
														{
														my $tt4=$text4->get('0.0', 'end');
														chomp $tt4;
														$mycom.=" --hwe $tt4";
															if($hwe_opt)
															{
															$mycom.=" --$hwe_opt";
															}
														}
														#--------------------
														if($me == 1)
														{
														my $tt5=$text5->get('0.0', 'end');
														chomp $tt5;
														my $tt6=$text6->get('0.0', 'end');
														chomp $tt6;
														$mycom.=" --me $tt5 $tt6";
														}
														#--------------------
														$output_text->insert('end', "Command used:\nplink $mycom --$out_format --out $dir$outname\n");
														print "Running...\n";
														
														my $runcom="$plink $mycom --$out_format --out $dir$outname";
														my $runcomOut=qx/$runcom/;
														
														$output_text->insert('end', "$runcomOut\nDone.\n");
														print "Done.\n";
												}
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

#output_frame
$ooo=Plink::SBoutput::outputFrame($gp_win, $ok_frame);
my $out_format_frame=$ooo->Frame()->pack(-side=>"top", -anchor=>'w');
	$out_format_frame->Label(-text=>"Output Format:")->pack(-side=>"left");
	$out_format="make-bed";
	$out_format_frame->Radiobutton(-text=>"Standard(--recode)", -value=>"recode",
									-variable=>\$out_format)->pack(-side => "left", -anchor=>"w");
	$out_format_frame->Radiobutton(-text=>"Binary(--make-bed)", -value=>"make-bed",
									-variable=>\$out_format)->pack(-side => "left", -anchor=>"w");
	$out_format_frame->Radiobutton(-text=>"Haploview(--recodeHV)", -value=>"recodeHV",
									-variable=>\$out_format)->pack(-side => "left", -anchor=>"w");
$output_name=Plink::SBoutput::outputName($ooo);

#option_frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
	my $opt1_frame=$option_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
		my $cb1=$opt1_frame->Checkbutton(-text=>"Missing Rate per Person(--mind)				", -variable=>\$mind)->pack(-side => "left", -anchor=>'w');	
		$text1=$opt1_frame->Text(-height => 1, -width => 25)->pack(-side=>'left');
		$text1->insert('end', '0.1');
	my $opt2_frame=$option_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
		my $cb2=$opt2_frame->Checkbutton(-text=>"Minor Allele Frequency(--maf)				", -variable=>\$maf)->pack(-side => "left", -anchor=>'w');
		$text2=$opt2_frame->Text(-height => 1, -width => 25)->pack(-side=>'left');
		$text2->insert('end', '0.05');
	my $opt3_frame=$option_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
		my $cb3=$opt3_frame->Checkbutton(-text=>"Missing Rate per SNP(--geno)				", -variable=>\$geno)->pack(-side => "left", -anchor=>'w');
		$text3=$opt3_frame->Text(-height => 1, -width => 25)->pack(-side=>'left');
		$text3->insert('end', '0.1');
	my $opt4_frame=$option_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
		my $hwe_frame=$opt4_frame->Frame()->pack(-side => "top");
			my $cb4=$hwe_frame->Checkbutton(-text=>"Hardy-Weinberg Equilibrium(--hwe)                         ", -variable=>\$hwe)->pack(-side => "left", -anchor=>'w');
			$text4=$hwe_frame->Text(-height => 1, -width => 25)->pack(-side=>'left');
			$text4->insert('end', '0.001');
		my $hwe_opt_frame=$opt4_frame->Frame()->pack(-side => "top");
			my $new1=$hwe_opt_frame->Radiobutton(-text=>"Family-based(--nonfounders)", -value=>"nonfounders", -variable=>\$hwe_opt)->pack(-side => "left", -anchor=>'w');
			my $new2=$hwe_opt_frame->Radiobutton(-text=>"Ignore Phenotype(--hwe-all)", -value=>"hwe-all", -variable=>\$hwe_opt)->pack(-side => "left", -anchor=>'w');
		
	my $opt5_frame=$option_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
		my $cb5=$opt5_frame->Checkbutton(-text=>"Mendel Error Rate(--me)	", -variable=>\$me)->pack(-side => "left", -anchor=>'w');
		$opt5_frame->Label(-text=>'Families Rate')->pack(-side=>'left');
		$text5=$opt5_frame->Text(-height => 1, -width => 12)->pack(-side=>'left');
		$opt5_frame->Label(-text=>'	SNPs Rate')->pack(-side=>'left');
		$text6=$opt5_frame->Text(-height => 1, -width => 12)->pack(-side=>'left');
		$text5->insert('end', '0.05');
		$text6->insert('end', '0.1');
}
1;
