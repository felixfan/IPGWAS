package Convert::Mach2Assoc;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;

sub Mach2PedMap
{
my($output_text, $mw, $gp_win, $convert_mach)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";
my $input_path3="";
my $input_path4="";
my $input_path5="";
my $ooo;
my $ok_frame;

my $rsq=0;
my $qc=0;
my $option="chr";

$gp_win->geometry("450x300");
$gp_win->title("Convert MACH Outputs to PED/MAP Files");

$gp_win->resizable(0, 0);


my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $in1_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in1_frame->Label(-text => ".mlgeno File")->pack(-side => "left");
		my $T1=$in1_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button1 = $in1_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['.mlgeno files', '.mlgeno'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
	my $in2_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in2_frame->Label(-text => ".mlinfo File  ")->pack(-side => "left");
		my $T2=$in2_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button2 = $in2_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T2->delete('0.0', 'end');
																	$input_path2=$mw->getOpenFile(-filetypes=>[
																											['.mlinfo files', '.mlinfo'],
																											['All files', '*'],
																																					]);
																	$T2->insert('end', $input_path2);
																	}
													)->pack(-side => "left");
	my $in3_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in3_frame->Label(-text => ".mlqc File    ")->pack(-side => "left");
		my $T3=$in3_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button3 = $in3_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T3->delete('0.0', 'end');
																	$input_path3=$mw->getOpenFile(-filetypes=>[
																											['.mlqc files', '.mlqc'],
																											['All files', '*'],
																																					]);
																	$T3->insert('end', $input_path3);
																	}
													)->pack(-side => "left");
	my $in4_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in4_frame->Label(-text => "Legend File")->pack(-side => "left");
		my $T4=$in4_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button4 = $in4_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T4->delete('0.0', 'end');
																	$input_path4=$mw->getOpenFile(-filetypes=>[
																											['.legend files', '.legend'],
																											['.txt files', '.txt'],
																											['All files', '*'],
																																					]);
																	$T4->insert('end', $input_path4);
																	}
													)->pack(-side => "left");
	my $in5_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in5_frame->Label(-text => "pedinfo File")->pack(-side => "left");
		my $T5=$in5_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button5 = $in5_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T5->delete('0.0', 'end');
																	$input_path5=$mw->getOpenFile(-filetypes=>[
																											['.ped files', '.ped'],
																											['.fam files', '.fam'],
																											['All files', '*'],
																																					]);
																	$T5->insert('end', $input_path5);
																	}
													)->pack(-side => "left");												
#option frame
	my $opt_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
		my $opt0_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
			$opt0_frame->Radiobutton(-text=>"Chromosome (--chr)", -value=>"chr", -variable=>\$option)->pack(-side => "left");	
			my $text0=$opt0_frame->Text(-height => 1, -width => 55)->pack(-side=>'left');
				$text0->insert('end', '');
		my $opt1_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
			my $cb1=$opt1_frame->Checkbutton(-text=>"--rsq", -variable=>\$rsq)->pack(-side => "left", -anchor=>'w');	
				my $text1=$opt1_frame->Text(-height => 1, -width => 57)->pack(-side=>'left');
				$text1->insert('end', '0.3');
		my $opt2_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
			my $cb2=$opt2_frame->Checkbutton(-text=>"--qc_threshold", -variable=>\$qc)->pack(-side => "left", -anchor=>'w');
				my $text2=$opt2_frame->Text(-height => 1, -width => 50)->pack(-side=>'left');
				$text2->insert('end', '0.9');											
#output name frame
	my $out_frame=$gp_win->LabFrame(-label=>"Output File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T6=$out_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
			$T6->delete('0.0','end');
			
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $chr=$text0->get('0.0', 'end');
												chomp $chr;
												if($chr eq "")
												{
												$output_text->insert('end', "Please specify --chr argument\n"); #log
												die "Please specify --chr argument\n";
												}
												
												my $mlgeno=$T1->get('0.0', 'end');
												chomp $mlgeno;
												$output_text->insert('end', "$mlgeno opened\n"); #log
												print "$mlgeno opened\n";
												
												my $mlinfo=$T2->get('0.0', 'end');
												chomp $mlinfo;
												$output_text->insert('end', "$mlinfo opened\n"); #log
												print "$mlinfo opened\n";
												
												my $mlqc=$T3->get('0.0', 'end');
												chomp $mlqc;
												$output_text->insert('end', "$mlqc opened\n"); #log
												print "$mlqc opened\n";
												
												my $legend=$T4->get('0.0', 'end');
												chomp $legend;
												$output_text->insert('end', "$legend opened\n"); #log
												print "$legend opened\n";
												
												my $ped=$T5->get('0.0', 'end');
												chomp $ped;
												$output_text->insert('end', "$ped opened\n"); #log
												print "$ped opened\n";
												
												my($base,$dir,$ext)=fileparse($mlgeno,'\..*');
												
												my $outname=$T6->get('0.0', 'end');
												$output_text->insert('end', "output: $dir$outname"); #log
												chomp $outname;
												$outname="$dir$outname";
												
												#------------------------------
												my $myopt="";
														#------------------------------
														if($rsq == 1)
														{
														my $myrsq=$text1->get('0.0', 'end');
														chomp $myrsq;
														$myopt.=" --rsq $myrsq";
														}
														#------------------------------
														if($qc == 1)
														{
														my $myqc=$text2->get('0.0', 'end');
														chomp $myqc;
														$myopt.=" --qc_threshold $myqc";
														}
												#------------------------------
												print "Running...\n";
												
												my $runcom="perl $convert_mach $mlgeno $mlinfo $mlqc -legend $legend -ped $ped --chr $chr -prefix $outname$myopt";
												#convert_mach.pl chr22_step2.mlgeno chr22_step2.mlinfo chr22_step2.mlqc -legend genotypes_chr22_CEU_r22_nr.b36_fwd_legend.txt -ped chr22.ped -prefix chr22_step2
												
												$output_text->insert('end', "$runcom\n");
												
												my $runcomOut=qx/$runcom/;
														
												$output_text->insert('end', "$runcomOut\nDone.\n");
												print "Done.\n";
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}
##-----------------------
sub Mach2SNPTEST
{
my($output_text, $mw, $gp_win, $convert_mach)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";
my $input_path3="";
my $input_path4="";
my $ooo;
my $ok_frame;

my $rsq=0;
my $bs=0;
my $keep=0;

$gp_win->geometry("450x280");
$gp_win->title("Convert MACH Outputs to SNPTEST Input Files");

$gp_win->resizable(0, 0);


my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $in1_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in1_frame->Label(-text => ".mlprob File")->pack(-side => "left");
		my $T1=$in1_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button1 = $in1_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['.mlprob files', '.mlprob'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
	my $in2_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in2_frame->Label(-text => ".mlinfo File  ")->pack(-side => "left");
		my $T2=$in2_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button2 = $in2_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T2->delete('0.0', 'end');
																	$input_path2=$mw->getOpenFile(-filetypes=>[
																											['.mlinfo files', '.mlinfo'],
																											['All files', '*'],
																																					]);
																	$T2->insert('end', $input_path2);
																	}
													)->pack(-side => "left");
	my $in4_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in4_frame->Label(-text => "Legend File")->pack(-side => "left");
		my $T4=$in4_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button4 = $in4_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T4->delete('0.0', 'end');
																	$input_path3=$mw->getOpenFile(-filetypes=>[
																											['.legend files', '.legend'],
																											['.txt files', '.txt'],
																											['All files', '*'],
																																					]);
																	$T4->insert('end', $input_path3);
																	}
													)->pack(-side => "left");												
#option frame
	my $opt_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
		my $opt1_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
			my $cb1=$opt1_frame->Checkbutton(-text=>"--rsq", -variable=>\$rsq)->pack(-side => "left", -anchor=>'w');	
				my $text1=$opt1_frame->Text(-height => 1, -width => 57)->pack(-side=>'left');
				$text1->insert('end', '0.3');
		my $opt2_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
			my $cb2=$opt2_frame->Checkbutton(-text=>"--blocksize", -variable=>\$bs)->pack(-side => "left", -anchor=>'w');
				my $text2=$opt2_frame->Text(-height => 1, -width => 51)->pack(-side=>'left');
				$text2->insert('end', '100000000');
		my $opt3_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
			my $cb3=$opt3_frame->Checkbutton(-text=>"--keep", -variable=>\$keep)->pack(-side => "left", -anchor=>'w');
				my $text3=$opt3_frame->Text(-height => 1, -width => 48)->pack(-side=>'left');
					$opt3_frame->Button(-text => 'Browse',
													-command => sub	{
																	$text3->delete('0.0', 'end');
																	$input_path4=$mw->getOpenFile(-filetypes=>[
																											['.txt files', '.txt'],
																											['All files', '*'],
																																					]);
																	$text3->insert('end', $input_path4);
																	}
													)->pack(-side => "left");
#output name frame
	my $out_frame=$gp_win->LabFrame(-label=>"Output File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T6=$out_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
			$T6->delete('0.0','end');
			
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $mlprob=$T1->get('0.0', 'end');
												chomp $mlprob;
												$output_text->insert('end', "$mlprob opened\n"); #log
												print "$mlprob opened\n";
												
												my $mlinfo=$T2->get('0.0', 'end');
												chomp $mlinfo;
												$output_text->insert('end', "$mlinfo opened\n"); #log
												print "$mlinfo opened\n";
												
												my $legend=$T4->get('0.0', 'end');
												chomp $legend;
												$output_text->insert('end', "$legend opened\n"); #log
												print "$legend opened\n";
												
												my($base,$dir,$ext)=fileparse($mlprob,'\..*');
												
												my $outname=$T6->get('0.0', 'end');
												$output_text->insert('end', "output: $dir$outname"); #log
												chomp $outname;
												$outname="$dir$outname";
												
												#------------------------------
												my $myopt="";
														#------------------------------
														if($rsq == 1)
														{
														my $myrsq=$text1->get('0.0', 'end');
														chomp $myrsq;
														$myopt.=" -rsq $myrsq";
														}
														#------------------------------
														if($bs == 1)
														{
														my $mybs=$text2->get('0.0', 'end');
														chomp $mybs;
														$myopt.=" -blocksize $mybs";
														}
														if($keep == 1)
														{
														my $mykeep=$text3->get('0.0', 'end');
														chomp $mykeep;
														$myopt.=" -keep $mykeep";
														}
												#------------------------------
												
												print "Running...\n";
												
												my $runcom="perl $convert_mach $mlprob $mlinfo -legend $legend -prefix $outname$myopt";
												#convert_mach2snptest.pl chr22.mlprob chr22_step2.mlinfo -prefix output -legend genotypes_chr22_CEU_r22_nr.b36_fwd_legend.txt -rsq 0.6 -keep caseid
												
												$output_text->insert('end', "$runcom\n");
												
												my $runcomOut=qx/$runcom/;
														
												$output_text->insert('end', "$runcomOut\nDone.\n");
												print "Done.\n";
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}
1;
