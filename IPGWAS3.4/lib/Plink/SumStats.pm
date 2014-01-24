package Plink::SumStats;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

sub SummaryStatistics
{
my($output_text, $mw, $gp_win, $option, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("450x310");
$gp_win->title("Summary Statistics");

$gp_win->resizable(0, 0);

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
														$output_text->insert('end', "Command used:\nplink $mycom --$option --out $dir$outname\n");
														print "Running...\n";
														
														my $runcom="$plink $mycom --$option --out $dir$outname";
														my $runcomOut=qx/$runcom/;
														
														$output_text->insert('end', "$runcomOut\nDone.\n");
														
														print "Done.\n";
														
														
												}
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

#output_frame
$ooo=Plink::SBoutput::outputFrame($gp_win, $ok_frame);
$output_name=Plink::SBoutput::outputName($ooo);

#option_frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
		my $opt_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio1=$opt_frame->Radiobutton(-text=>"Genotyping Missingness Rate Statistics(--missing)", -value=>"missing", -variable=>\$option)->pack(-side => "top", -anchor=>'w');	
			my $radio2=$opt_frame->Radiobutton(-text=>"Test of Missingness by Phenotype(--test-missing)", -value=>"test-missing", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
			my $radio3=$opt_frame->Radiobutton(-text=>"Test of Missingness by Genotype(--test-mishap)", -value=>"test-mishap", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
			my $radio4=$opt_frame->Radiobutton(-text=>"Hardy-Weinberg Test Statistics(--hardy)", -value=>"hardy", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
			my $radio5=$opt_frame->Radiobutton(-text=>"Minor Allele Frequencies for Each SNP(--freq)", -value=>"freq", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
			my $radio6=$opt_frame->Radiobutton(-text=>"Mendel Errors for SNPs and Families(--mendel)", -value=>"mendel", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
			my $radio7=$opt_frame->Radiobutton(-text=>"Check the Sex for Each Individual(--check-sex)				         ", -value=>"check-sex", -variable=>\$option)->pack(-side => "top", -anchor=>'w');	

}

###---------
sub LDprune
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $out_format="";
my $ooo;
my $ok_frame;

$gp_win->geometry("450x200");
$gp_win->title("Linkage Disequilibrium Based SNP PRunning");

$gp_win->resizable(0, 0);

my ($text1, $text2, $text3, $text11, $text12, $text13);
my $option="indep";
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
														#-------------------------
														if($option eq "indep")
														{
														my $t1=$text1->get('0.0', 'end');
														my $t2=$text2->get('0.0', 'end');
														my $t3=$text3->get('0.0', 'end');
														chomp $t1;
														chomp $t2;
														chomp $t3;
														$mycom.=" --$option $t1 $t2 $t3";
														}
														else
														{
														my $t11=$text11->get('0.0', 'end');
														my $t12=$text12->get('0.0', 'end');
														my $t13=$text13->get('0.0', 'end');
														chomp $t11;
														chomp $t12;
														chomp $t13;
														$mycom.=" --$option $t11 $t12 $t13";
														}
														
														$output_text->insert('end', "Command used:\nplink $mycom --out $dir$outname\n");
														print "Running...\n";
														
														my $runcom="$plink $mycom --out $dir$outname";
														my $runcomOut=qx/$runcom/;
														
														$output_text->insert('end', "$runcomOut\nDone.\n");
														print "Done.\n";
												}
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

#output_frame
$ooo=Plink::SBoutput::outputFrame($gp_win, $ok_frame);
$output_name=Plink::SBoutput::outputName($ooo);

#option_frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
		my $opt_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio5=$opt_frame1->Radiobutton(-text=>"Based on the Variance Inflation Factor(--indep)                         ",
												-value=>"indep", -variable=>\$option)->pack(-side => "left");
				$text1=$opt_frame1->Text(-height => 1, -width => 5)->pack(-side=>'left');
				$text1->insert('end', '50');
				$text2=$opt_frame1->Text(-height => 1, -width => 5)->pack(-side=>'left');
				$text2->insert('end', '5');
				$text3=$opt_frame1->Text(-height => 1, -width => 5)->pack(-side=>'left');
				$text3->insert('end', '2');
		my $opt_frame2=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio6=$opt_frame2->Radiobutton(-text=>"Based on Pairwise Genotypic Correlation(--indep-pairwise)        ",
												-value=>"indep-pairwise", -variable=>\$option)->pack(-side => "left");
				$text11=$opt_frame2->Text(-height => 1, -width => 5)->pack(-side=>'left');
				$text11->insert('end', '50');
				$text12=$opt_frame2->Text(-height => 1, -width => 5)->pack(-side=>'left');
				$text12->insert('end', '5');
				$text13=$opt_frame2->Text(-height => 1, -width => 5)->pack(-side=>'left');
				$text13->insert('end', '0.5');
}

###---------
sub ImputeSex
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $out_format="";
my $ooo;
my $ok_frame;

$gp_win->geometry("450x200");
$gp_win->title("Impute Sex");

$gp_win->resizable(0, 0);

my $option="impute-sex";
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
														$output_text->insert('end', "Command used:\nplink $mycom --$option --$out_format --out $dir$outname\n");
														print "Running...\n";
														
														my $runcom="$plink $mycom --$option --$out_format --out $dir$outname";
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
my $option_frame=$gp_win->LabFrame(-label=>"Option", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
		my $opt_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio5=$opt_frame1->Radiobutton(-text=>"Impute the Sex Codes Based on the SNP Data(--impute-sex)                                              ",
												-value=>"impute-sex", -variable=>\$option)->pack(-side => "left");
}


1;
