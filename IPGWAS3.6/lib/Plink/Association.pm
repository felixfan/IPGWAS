package Plink::Association;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

sub BasicAllelicAssoci
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("450x440");
$gp_win->title("Allelic Association Test");

$gp_win->resizable(0, 0);

my ($ci, $adjust, $allownosex)=(0, 0, 0);
my $option="assoc";
my $per_option="";
my ($text1, $text2);
my ($alt_pht, $pheno, $texts1, $texts2, $texts3);
my $AltPht=0;
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
														
														#------------
														my $mycom;
														
														if($ext eq ".ped")
														{
														$mycom="--file $dir$base --assoc";
														}
														elsif($ext eq ".bed")
														{
														$mycom="--bfile $dir$base --assoc";
														}
														#--------------------------
														if($ci==1)
														{
														my $myci=$text1->get('0.0','end');
														chomp $myci;
														$mycom.=" --ci $myci";
														}
														if($adjust==1)
														{
														$mycom.=" --adjust";
														}
														if($allownosex==1)
														{
														$mycom.=" --allow-no-sex";
														}
														if($per_option eq "perm")
														{
														$mycom.=" --perm";
														}
														elsif($per_option eq "mperm")
														{
														my $mymperm=$text2->get('0.0','end');
														chomp $mymperm;
														$mycom.=" --mperm $mymperm";
														}
														if($AltPht==1)
														{
														my $phtPath=$texts1->get('0.0', 'end');
														chomp $phtPath;
														$mycom.=" --pheno $phtPath";
															if($pheno eq "mpheno")
															{
															my $Nth=$texts2->get('0.0', 'end');
															chomp $Nth;
															$mycom.=" --mpheno $Nth";
															}
															elsif($pheno eq "pheno-name")
															{
															my $phtName=$texts3->get('0.0', 'end');
															chomp $phtName;
															$mycom.=" --pheno-name $phtName";
															}
															elsif($pheno eq "all-pheno")
															{
															$mycom.=" --all-pheno";
															}
														}
														#-----------------------------
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
my $opt1_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame 1
		my $opt1_frame1=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame1->Radiobutton(-text=>"Basic Case/Control Association Test (--assoc)                                  	 ", -value=>"assoc", -variable=>\$option)->pack(-side => "left", -anchor=>'w');	
		my $opt1_frame2=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame2->Checkbutton(-text=>"Confidence Interval (--ci)", -variable=>\$ci)->pack(-side => "left", -anchor=>'w');
			$text1=$opt1_frame2->Text(-height => 1, -width => 42)->pack(-side=>"left");
			$text1->insert('end', '0.95');
		my $opt1_frame3=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame3->Checkbutton(-text=>"Adjusted P-Values (--adjust)", -variable=>\$adjust)->pack(-side => "left", -anchor=>'w');
		my $opt1_frame4=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame4->Checkbutton(-text=>"Do Not Set Ambiguously-Sexed Individuals Missing(--allow-no-sex)", -variable=>\$allownosex)->pack(-side => "left", -anchor=>'w');
my $opt2_frame=$gp_win->LabFrame(-label=>"Permutation Options", -labelside=>'acrosstop')->pack(-side => "top", -after=>$opt1_frame, -anchor=>'w');
		my $opt2_frame1=$opt2_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt2_frame1->Radiobutton(-text=>"Max (T) Permutation Mode (--mperm)", -value=>'mperm', -variable=>\$per_option)->pack(-side => "left", -anchor=>'w');
			$text2=$opt2_frame1->Text(-height => 1, -width => 40)->pack(-side=>"left");
			$text2->insert('end', '10000');
		my $opt2_frame2=$opt2_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt2_frame2->Radiobutton(-text=>"Adaptive Permutation Mode (--perm)                                             		", -value=>'perm', -variable=>\$per_option)->pack(-side => "left", -anchor=>'w');
my $opt3_frame=$gp_win->LabFrame(-label=>"Alternate Phenotypes", -labelside=>'acrosstop')->pack(-side => "top", -after=>$opt2_frame, -anchor=>'w');
		my $opt3_frame1=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame1->Checkbutton(-text=>"Alternate Phenotype File:", -variable=>\$AltPht)->pack(-side => "left", -anchor=>'w');
			$texts1=$opt3_frame1->Text(-height => 1, -width => 35)->pack(-side=>'left');
			$texts1->delete('0.0', 'end');
								$opt3_frame1->Button(-text => 'Browse',
														-command => sub{
																		$texts1->delete('0.0', 'end');
																		$alt_pht=$mw->getOpenFile(-filetypes=>[
																													['TXT files', '.txt'],
																													['All files', '*'],
																												]);
																		$texts1->insert('end', $alt_pht);
																		print "$alt_pht opened.\n";
																	}		   
													)->pack(-side => "left");
		my $opt3_frame2=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame2->Radiobutton(-text=>"Test the Nth Phenotype:  (--mpheno)", -value=>'mpheno', -variable=>\$pheno)->pack(-side => "left", -anchor=>'w');
			$texts2=$opt3_frame2->Text(-height => 1, -width => 34)->pack(-side=>'left');
		my $opt3_frame3=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame3->Radiobutton(-text=>"Specify the Phenotype Name:  (--pheno-name)", -value=>'pheno-name', -variable=>\$pheno)->pack(-side => "left", -anchor=>'w');
			$texts3=$opt3_frame3->Text(-height => 1, -width => 30)->pack(-side=>'left');
		my $opt3_frame4=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame4->Radiobutton(-text=>"Test All Phenotypes:(--all-pheno)", -value=>'all-pheno', -variable=>\$pheno)->pack(-side => "left", -anchor=>'w');
}

###---------

sub GenotypicAssoci
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

my ($alt_pht, $pheno, $texts1, $texts2, $texts3);
my $AltPht=0;

$gp_win->geometry("450x580");
$gp_win->title("Alternate/Full Model Association Tests");

$gp_win->resizable(0, 0);

my ($cell, $ci, $adjust, $allownosex)=(0, 0, 0, 0);
my $option="model";
my $per_option="";
my $per_option2="";
my ($text1, $text2, $text3);

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
														
														#------------
														my $mycom;
														
														if($ext eq ".ped")
														{
														$mycom="--file $dir$base --model";
														}
														elsif($ext eq ".bed")
														{
														$mycom="--bfile $dir$base --model";
														}
														#--------------------------
														if($ci==1)
														{
														my $myci=$text1->get('0.0', 'end');
														chomp $myci;
														$mycom.=" --ci $myci";
														}
														if($adjust==1)
														{
														$mycom.=" --adjust";
														}
														if($allownosex==1)
														{
														$mycom.=" --allow-no-sex";
														}
														if($cell==1)
														{
														my $mycell=$text2->get('0.0', 'end');
														chomp $mycell;
														$mycom.=" --cell $mycell";
														}
														if($per_option eq "mperm")
														{
														my $mymperm=$text3->get('0.0', 'end');
														chomp $mymperm;
														$mycom.=" --mperm $mymperm";
														}
														elsif($per_option eq "perm")
														{
														$mycom.=" --perm";
														}
														if($per_option2 ne "")
														{
														$mycom.=" --$per_option2";
														}
														if($AltPht==1)
														{
														my $phtPath=$texts1->get('0.0', 'end');
														chomp $phtPath;
														$mycom.=" --pheno $phtPath";
															if($pheno eq "mpheno")
															{
															my $Nth=$texts2->get('0.0', 'end');
															chomp $Nth;
															$mycom.=" --mpheno $Nth";
															}
															elsif($pheno eq "pheno-name")
															{
															my $phtName=$texts3->get('0.0', 'end');
															chomp $phtName;
															$mycom.=" --pheno-name $phtName";
															}
															elsif($pheno eq "all-pheno")
															{
															$mycom.=" --all-pheno";
															}
														}
														#-----------------------------
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
my $opt1_frame=$gp_win->LabFrame(-label=>"options", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame 1
		my $opt1_frame1=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame1->Radiobutton(-text=>"Alternate/Full Model Association Tests (--model)                                  	 ", -value=>"model", -variable=>\$option)->pack(-side => "left", -anchor=>'w');	
		my $opt1_frame2=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame2->Checkbutton(-text=>"Confidence Interval (--ci)", -variable=>\$ci)->pack(-side => "left", -anchor=>'w');
			$text1=$opt1_frame2->Text(-height => 1, -width => 42)->pack(-side=>"left");
			$text1->insert('end', '0.95');
		my $opt1_frame3=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame3->Checkbutton(-text=>"Adjusted P-Values (--adjust)", -variable=>\$adjust)->pack(-side => "left", -anchor=>'w');
		my $opt1_frame4=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame4->Checkbutton(-text=>"Minimum Required Observation Per Cell (--cell)", -variable=>\$cell)->pack(-side => "left", -anchor=>'w');
			$text2=$opt1_frame4->Text(-height => 1, -width => 30)->pack(-side=>"left");
			$text2->insert('end', '20');
		my $opt1_frame5=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame5->Checkbutton(-text=>"Do Not Set Ambiguously-Sexed Individuals Missing(--allow-no-sex)", -variable=>\$allownosex)->pack(-side => "left", -anchor=>'w');
my $opt2_frame=$gp_win->LabFrame(-label=>"Permutation Options", -labelside=>'acrosstop')->pack(-side => "top", -after=>$opt1_frame, -anchor=>'w');
		my $opt2_frame1=$opt2_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt2_frame1->Radiobutton(-text=>"Max (T) Permutation Mode (--mperm)", -value=>'mperm', -variable=>\$per_option)->pack(-side => "left", -anchor=>'w');
			$text3=$opt2_frame1->Text(-height => 1, -width => 34)->pack(-side=>"left");
			$text3->insert('end', '10000');
		my $opt2_frame2=$opt2_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt2_frame2->Radiobutton(-text=>"Adaptive Permutation Mode (--perm)                                             		", -value=>'perm', -variable=>\$per_option)->pack(-side => "left", -anchor=>'w');
my $opt3_frame=$gp_win->LabFrame(-label=>"Permutation Flags", -labelside=>'acrosstop')->pack(-side => "top", -after=>$opt2_frame, -anchor=>'w');
		my $opt3_frame1=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame1->Radiobutton(-text=>"Permute Genotypic Test (--model-gen)", -value=>'model-gen', -variable=>\$per_option2)->pack(-side => "left", -anchor=>'w');
		my $opt3_frame2=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame2->Radiobutton(-text=>"Permute Trend Test (--model-trend)", -value=>'model-trend', -variable=>\$per_option2)->pack(-side => "left", -anchor=>'w');
		my $opt3_frame3=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame3->Radiobutton(-text=>"Permute Dominant Test (--model-dom)", -value=>'model-dom', -variable=>\$per_option2)->pack(-side => "left", -anchor=>'w');
		my $opt3_frame4=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame4->Radiobutton(-text=>"Permute Recessive Test (--model-rec)					          ", -value=>'model-rec', -variable=>\$per_option2)->pack(-side => "left", -anchor=>'w');
my $opt4_frame=$gp_win->LabFrame(-label=>"Alternate Phenotypes", -labelside=>'acrosstop')->pack(-side => "top", -after=>$opt3_frame, -anchor=>'w');
		my $opt4_frame1=$opt4_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt4_frame1->Checkbutton(-text=>"Alternate Phenotype File:", -variable=>\$AltPht)->pack(-side => "left", -anchor=>'w');
			$texts1=$opt4_frame1->Text(-height => 1, -width => 35)->pack(-side=>'left');
			$texts1->delete('0.0', 'end');
								$opt4_frame1->Button(-text => 'Browse',
														-command => sub{
																		$texts1->delete('0.0', 'end');
																		$alt_pht=$mw->getOpenFile(-filetypes=>[
																													['TXT files', '.txt'],
																													['All files', '*'],
																												]);
																		$texts1->insert('end', $alt_pht);
																		print "$alt_pht opened.\n";
																	}		   
													)->pack(-side => "left");
		my $opt4_frame2=$opt4_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt4_frame2->Radiobutton(-text=>"Test the Nth Phenotype:  (--mpheno)", -value=>'mpheno', -variable=>\$pheno)->pack(-side => "left", -anchor=>'w');
			$texts2=$opt4_frame2->Text(-height => 1, -width => 34)->pack(-side=>'left');
		my $opt4_frame3=$opt4_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt4_frame3->Radiobutton(-text=>"Specify the Phenotype Name:  (--pheno-name)", -value=>'pheno-name', -variable=>\$pheno)->pack(-side => "left", -anchor=>'w');
			$texts3=$opt4_frame3->Text(-height => 1, -width => 30)->pack(-side=>'left');
		my $opt4_frame4=$opt4_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt4_frame4->Radiobutton(-text=>"Test All Phenotypes:(--all-pheno)", -value=>'all-pheno', -variable=>\$pheno)->pack(-side => "left", -anchor=>'w');
}

###---------

sub BasicLinearLogistic
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

my ($alt_pht, $pheno, $texts1, $texts2, $texts3);
my $AltPht=0;

$gp_win->geometry("450x350");
$gp_win->title("Linear and Logistic Models--Basic Usage");

$gp_win->resizable(0, 0);

my $ci=0;
my $text1;
my $option="linear";

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
														
														#------------
														my $mycom;
														
														if($ext eq ".ped")
														{
														$mycom="--file $dir$base --$option";
														}
														elsif($ext eq ".bed")
														{
														$mycom="--bfile $dir$base --$option";
														}
														#--------------------------
														if($ci==1)
														{
														my $myci=$text1->get('0.0','end');
														chomp $myci;
														$mycom.=" --ci $myci";
														}
														#---------------------------
														if($AltPht==1)
														{
														my $phtPath=$texts1->get('0.0', 'end');
														chomp $phtPath;
														$mycom.=" --pheno $phtPath";
															if($pheno eq "mpheno")
															{
															my $Nth=$texts2->get('0.0', 'end');
															chomp $Nth;
															$mycom.=" --mpheno $Nth";
															}
															elsif($pheno eq "pheno-name")
															{
															my $phtName=$texts3->get('0.0', 'end');
															chomp $phtName;
															$mycom.=" --pheno-name $phtName";
															}
															elsif($pheno eq "all-pheno")
															{
															$mycom.=" --all-pheno";
															}
														}
														#-----------------------------
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
my $opt1_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame 1
		my $opt1_frame1=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame1->Radiobutton(-text=>"For Quantitative Traits(--linear)                                  	 ", -value=>"linear", -variable=>\$option)->pack(-side => "left", -anchor=>'w');	
		my $opt1_frame11=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame11->Radiobutton(-text=>"For Disease Traits(--logistic)                                  	 ", -value=>"logistic", -variable=>\$option)->pack(-side => "left", -anchor=>'w');	
		my $opt1_frame2=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame2->Checkbutton(-text=>"Confidence Interval (--ci)", -variable=>\$ci)->pack(-side => "left", -anchor=>'w');
			$text1=$opt1_frame2->Text(-height => 1, -width => 42)->pack(-side=>"left");
			$text1->insert('end', '0.95');
my $opt3_frame=$gp_win->LabFrame(-label=>"Alternate Phenotypes", -labelside=>'acrosstop')->pack(-side => "top", -after=>$opt1_frame, -anchor=>'w');
		my $opt3_frame1=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame1->Checkbutton(-text=>"Alternate Phenotype File:", -variable=>\$AltPht)->pack(-side => "left", -anchor=>'w');
			$texts1=$opt3_frame1->Text(-height => 1, -width => 35)->pack(-side=>'left');
			$texts1->delete('0.0', 'end');
								$opt3_frame1->Button(-text => 'Browse',
														-command => sub{
																		$texts1->delete('0.0', 'end');
																		$alt_pht=$mw->getOpenFile(-filetypes=>[
																													['TXT files', '.txt'],
																													['All files', '*'],
																												]);
																		$texts1->insert('end', $alt_pht);
																		print "$alt_pht opened.\n";
																	}		   
													)->pack(-side => "left");
		my $opt3_frame2=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame2->Radiobutton(-text=>"Test the Nth Phenotype:  (--mpheno)", -value=>'mpheno', -variable=>\$pheno)->pack(-side => "left", -anchor=>'w');
			$texts2=$opt3_frame2->Text(-height => 1, -width => 34)->pack(-side=>'left');
		my $opt3_frame3=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame3->Radiobutton(-text=>"Specify the Phenotype Name:  (--pheno-name)", -value=>'pheno-name', -variable=>\$pheno)->pack(-side => "left", -anchor=>'w');
			$texts3=$opt3_frame3->Text(-height => 1, -width => 30)->pack(-side=>'left');
		my $opt3_frame4=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame4->Radiobutton(-text=>"Test All Phenotypes:(--all-pheno)", -value=>'all-pheno', -variable=>\$pheno)->pack(-side => "left", -anchor=>'w');
}

###---------

sub CovarInteract
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

my ($alt_pht, $pheno, $texts1, $texts2, $texts3);
my $AltPht=0;

$gp_win->geometry("450x560");
$gp_win->title("Covariates and Interactions");

$gp_win->resizable(0, 0);

my ($text1, $text2, $text3, $text4, $text5);
my $option="linear";
my $option2="";
my ($genotypic, $sex, $interaction, $covar)=(0, 0, 0, 0);
my $covar_list;
my $covar_opt;
my $condition_list;

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
														
														#------------
														my $mycom;
														
														if($ext eq ".ped")
														{
														$mycom="--file $dir$base --$option";
														}
														elsif($ext eq ".bed")
														{
														$mycom="--bfile $dir$base --$option";
														}
														#--------------------------
														
														
															if($genotypic==1)
															{
															$mycom.=" --genotypic";
															}
															if($covar==1)
															{
															$mycom.=" --covar $covar_list";
																if($covar_opt eq "covar-name")
																{
																my $t2=$text2->get('0.0','end');
																chomp $t2;
																$mycom.=" --$covar_opt $t2";
																}
																elsif($covar_opt eq "covar-number")
																{
																my $t3=$text3->get('0.0','end');
																chomp $t3;
																$mycom.=" --$covar_opt $t3";
																}
															}
															if($interaction ==1)
															{
															$mycom.=" --interaction";
															}
														
														if($option2 eq "condition")
														{
														my $t1=$text4->get('0.0', 'end');
														chomp $t1;
														$mycom.=" --$option2 $t1";
														}
														elsif($option2 eq "condition-list")
														{
														$mycom.=" --$option2 $condition_list";
														}
														
														if($sex==1)
														{
														$mycom.=" --sex";
														}
														
														if($AltPht==1)
														{
														my $phtPath=$texts1->get('0.0', 'end');
														chomp $phtPath;
														$mycom.=" --pheno $phtPath";
															if($pheno eq "mpheno")
															{
															my $Nth=$texts2->get('0.0', 'end');
															chomp $Nth;
															$mycom.=" --mpheno $Nth";
															}
															elsif($pheno eq "pheno-name")
															{
															my $phtName=$texts3->get('0.0', 'end');
															chomp $phtName;
															$mycom.=" --pheno-name $phtName";
															}
															elsif($pheno eq "all-pheno")
															{
															$mycom.=" --all-pheno";
															}
														}
														#-----------------------------
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
my $opt1_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame 1
		my $opt1_frame1=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame1->Radiobutton(-text=>"For Quantitative Traits(--linear)                                  	 ", -value=>"linear", -variable=>\$option)->pack(-side => "left", -anchor=>'w');	
		my $opt1_frame2=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt1_frame2->Radiobutton(-text=>"For Disease Traits(--logistic)                                  	                                                          ", 
													-value=>"logistic", -variable=>\$option)->pack(-side => "left", -anchor=>'w');	
		my $opt2_frame0=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt2_frame0->Checkbutton(-text=>"--genotypic", -variable=>\$genotypic)->pack(-side => "left", -anchor=>'w');
		my $opt2_frame2=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt2_frame2->Checkbutton(-text=>'--interaction', -variable=>\$interaction)->pack(-side => "left", -anchor=>'w');
		my $opt2_frame3=$opt1_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt2_frame3->Checkbutton(-text=>'Sex as a Covariate (--sex)', -variable=>\$sex)->pack(-side => "left", -anchor=>'w');
			 	
my $opt2_frame=$gp_win->LabFrame(-label=>"Covariates", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame 1
	my $opt2_frame1=$opt2_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top", -anchor=>'w');	
		my $opt2_frame1_1=$opt2_frame1->Frame()->pack(-side => "top", -anchor=>'w');
			$opt2_frame1_1->Checkbutton(-text=>'Covariates (--covar)', -variable=>\$covar)->pack(-side => "left", -anchor=>'w');
			$text1=$opt2_frame1_1->Text(-height => 1, -width => 39)->pack(-side=>'left');
			$text1->delete('0.0', 'end');
								$opt2_frame1_1->Button(-text => 'Browse',
														-command => sub{
																		$text1->delete('0.0', 'end');
																		$covar_list=$mw->getOpenFile(-filetypes=>[
																													['TXT files', '.txt'],
																													['All files', '*'],
																												]);
																		$text1->insert('end', $covar_list);
																		print "$covar_list opened.\n";
																	}		   
													)->pack(-side => "left");
		my $opt2_frame1_2=$opt2_frame1->Frame()->pack(-side => "top", -anchor=>'w');
			$opt2_frame1_2->Radiobutton(-text=>"--covar-name   ", -value=>"covar-name", -variable=>\$covar_opt)->pack(-side => "left", -anchor=>'w');
			$text2=$opt2_frame1_2->Text(-height => 1, -width => 50)->pack(-side => "left", -anchor=>'w');
			$text2->delete('0.0', 'end');
		my $opt2_frame1_3=$opt2_frame1->Frame()->pack(-side => "top", -anchor=>'w');	
			$opt2_frame1_3->Radiobutton(-text=>"--covar-number", -value=>"covar-number", -variable=>\$covar_opt)->pack(-side => "left", -anchor=>'w');
			$text3=$opt2_frame1_3->Text(-height => 1, -width => 50)->pack(-side => "left", -anchor=>'w');
			$text3->delete('0.0', 'end');
	
my $opt3_frame=$gp_win->LabFrame(-label=>"Interactions", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame 1
		my $opt3_frame1=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame1->Radiobutton(-text=>"Condition Analysis on a Specific SNP (--condition)", -value=>"condition", -variable=>\$option2)->pack(-side => "left", -anchor=>'w');
			$text4=$opt3_frame1->Text(-height => 1, -width => 25)->pack(-side => "left", -anchor=>'w');
			$text4->delete('0.0', 'end');
		my $opt3_frame2=$opt3_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt3_frame2->Radiobutton(-text=>"Condition Analysis on Multiple SNP (--condition-list)", -value=>"condition-list", -variable=>\$option2)->pack(-side => "left", -anchor=>'w');
			$text5=$opt3_frame2->Text(-height => 1, -width => 18)->pack(-side => "left", -anchor=>'w');
			$text5->delete('0.0', 'end');
			my $list_button2 = $opt3_frame2->Button(-text => 'Browse',
														-command => sub{
																		$text5->delete('0.0', 'end');
																		$condition_list=$mw->getOpenFile(-filetypes=>[
																													['TXT files', '.txt'],
																													['All files', '*'],
																												]);
																		$text5->insert('end', $condition_list);
																		print "$condition_list opened.\n";
																	}		   
													)->pack(-side => "left");
my $opt4_frame=$gp_win->LabFrame(-label=>"Alternate Phenotypes", -labelside=>'acrosstop')->pack(-side => "top", -after=>$opt3_frame, -anchor=>'w');
		my $opt4_frame1=$opt4_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt4_frame1->Checkbutton(-text=>"Alternate Phenotype File:", -variable=>\$AltPht)->pack(-side => "left", -anchor=>'w');
			$texts1=$opt4_frame1->Text(-height => 1, -width => 35)->pack(-side=>'left');
			$texts1->delete('0.0', 'end');
								$opt4_frame1->Button(-text => 'Browse',
														-command => sub{
																		$texts1->delete('0.0', 'end');
																		$alt_pht=$mw->getOpenFile(-filetypes=>[
																													['TXT files', '.txt'],
																													['All files', '*'],
																												]);
																		$texts1->insert('end', $alt_pht);
																		print "$alt_pht opened.\n";
																	}		   
													)->pack(-side => "left");
		my $opt4_frame2=$opt4_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt4_frame2->Radiobutton(-text=>"Test the Nth Phenotype:  (--mpheno)", -value=>'mpheno', -variable=>\$pheno)->pack(-side => "left", -anchor=>'w');
			$texts2=$opt4_frame2->Text(-height => 1, -width => 34)->pack(-side=>'left');
		my $opt4_frame3=$opt4_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt4_frame3->Radiobutton(-text=>"Specify the Phenotype Name:  (--pheno-name)", -value=>'pheno-name', -variable=>\$pheno)->pack(-side => "left", -anchor=>'w');
			$texts3=$opt4_frame3->Text(-height => 1, -width => 30)->pack(-side=>'left');
		my $opt4_frame4=$opt4_frame->Frame()->pack(-side => "top", -anchor=>'w');
			$opt4_frame4->Radiobutton(-text=>"Test All Phenotypes:(--all-pheno)", -value=>'all-pheno', -variable=>\$pheno)->pack(-side => "left", -anchor=>'w');
}


###---------

1;
