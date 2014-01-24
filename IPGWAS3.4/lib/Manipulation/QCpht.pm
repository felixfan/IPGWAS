package Manipulation::QCpht;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;
use File::Copy;

sub Setpht
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";
my $input_path3="";
my $ooo;
my $ok_frame;

my $pht=-9;

$gp_win->geometry("450x300");
$gp_win->title("Change Affection Status");

$gp_win->resizable(0, 0);


my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

my $out_format;
my $output_name;

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $in1_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in1_frame->Label(-text => ".ped/.fam File")->pack(-side => "left");
		my $T1=$in1_frame->Text(-height => 1, -width => 46)->pack(-side=>"left");
		my $browse_button1 = $in1_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['ped files', '.ped'],
																											['fam files', '.fam'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
#option frame 1
my $option_frame=$gp_win->LabFrame(-label=>"Options 1", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		my $pht1_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $label2=$pht1_frame->Label(-text => "Change All Subjects Affection status to:")->pack(-side => "left");
		my $pht2_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio4=$pht2_frame->Radiobutton(-text=>"Unaffected(1)         ", -value=> 1, -variable=>\$pht)->pack(-side => "left");
			my $radio5=$pht2_frame->Radiobutton(-text=>"Affected(2)         ", -value=> 2, -variable=>\$pht)->pack(-side => "left");
			my $radio6=$pht2_frame->Radiobutton(-text=>"Missing(-9)         ", -value=> -9, -variable=>\$pht)->pack(-side => "left");
			my $radio7=$pht2_frame->Radiobutton(-text=>"Missing(0)           ", -value=> 0, -variable=>\$pht)->pack(-side => "left");
#option frame 2
my $option_frame2=$gp_win->LabFrame(-label=>"Options 2: Alternate phenotype files", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		my $pht3_frame=$option_frame2->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio8=$pht3_frame->Radiobutton(-text=>"One alternate phenotype file", -value=> 21, -variable=>\$pht)->pack(-side => "left");
			my $alt1=$pht3_frame->Text(-height => 1, -width => 33)->pack(-side=>"left");
								$pht3_frame->Button(-text => 'Browse',
													-command => sub	{
																	$alt1->delete('0.0', 'end');
																	$input_path2=$mw->getOpenFile(-filetypes=>[
																											['txt files', '.txt'],
																											['All files', '*'],
																																					]);
																	$alt1->insert('end', $input_path2);
																	}
													)->pack(-side => "left");
													
		my $pht4_frame=$option_frame2->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio9=$pht4_frame->Radiobutton(-text=>"two or more alternate phenotypes file", -value=> 22, -variable=>\$pht)->pack(-side => "left");
			my $alt2=$pht4_frame->Text(-height => 1, -width => 27)->pack(-side=>"left");
								$pht4_frame->Button(-text => 'Browse',
													-command => sub	{
																	$alt2->delete('0.0', 'end');
																	$input_path3=$mw->getOpenFile(-filetypes=>[
																											['txt files', '.txt'],
																											['All files', '*'],
																																					]);
																	$alt2->insert('end', $input_path3);
																	}
													)->pack(-side => "left");
		my $pht5_frame=$option_frame2->Frame()->pack(-side=>"top", -anchor=>'w');
			$pht5_frame->Label(-text=>"Specify the Nth phenotype OR phenotype name to be used: ")->pack(-side => "left");
			my $alt3=$pht5_frame->Text(-height => 1, -width => 40)->pack(-side=>"left");
			
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $sequenom=$T1->get('0.0', 'end');
												chomp $sequenom;
															if(! $sequenom)
															{
															$output_text->insert('end', "No PED/FAM file\n");
															die "No PED/FAM file: $!\n";
															}
												$output_text->insert('end', "$sequenom opened\n"); #log
												print "$sequenom opened\n";
												
												
												my($base,$dir,$ext)=fileparse($sequenom,'\..*');
												#------------------------------------------------
												my $mycom;
													if($ext eq ".ped")
													{
													my $mymap="$dir$base.map";
														if(-e $mymap)
														{
														$mycom="$plink --file $dir$base";
														}
														else
														{
														die "$mymap does not exist!\n";
														}
													}
													elsif($ext eq ".fam")
													{
													my $mybed="$dir$base.bed";
													my $mybim="$dir$base.bim";
														if(-e $mybed && (-e $mybim))
														{
														$mycom="$plink --bfile $dir$base";
														}
														else
														{
														die "$mybed and/or $mybim does not exist!\n";
														}
													}
												#-------------------------------------------------
												
												my $outname=$output_name->get('0.0', 'end');
												chomp $outname;
												
												$output_text->insert('end', "Formatting...\n"); #log
												print "Formatting...\n";
												
												my $i=0; #number of individuals
												if($pht != 21 && $pht != 22)
												{
													my $fakePht="fakePht.txt";
													$fakePht="$dir$fakePht";
													open(f1, $sequenom);
													open(f2, ">$fakePht");
													while(<f1>)
													{
													my @arr=split(/\s+/, $_);
													print f2 "$arr[0] $arr[1] $pht\n";
													$i++;
													}
													close f1;
													close f2;
													
													$output_text->insert('end', "Change All Subjects Affection Status to: $pht\n1=>control  2=>case  0, -9=>missing\n"); #log
													print "Change All Subjects Affection Status to: $pht\n1=>control  2=>case  0, -9=>missing\n";
													
													my $runcom="$mycom --pheno $fakePht --$out_format --out $dir$outname";
													my $runcomOut=qx/$runcom/;
															
													$output_text->insert('end', "$runcomOut\n");
													
													# unlink $fakePht;
													
													$output_text->insert('end', "$i individuals converted.\nDone."); #log
													print "Done.\n";
												}
												elsif($pht == 21)
												{
												my $alt1file=$alt1->get('0.0', 'end');
												print "Specify an alternate phenotype using $alt1file";
												$output_text->insert('end', "Specify an alternate phenotype using $alt1file");
												chomp $alt1file;
												my $runcom2="$mycom --pheno $alt1file --$out_format --out $dir$outname";
												my $runcomOut2=qx/$runcom2/;
												$output_text->insert('end', "$runcomOut2\n");
												$output_text->insert('end', "Done.\n"); #log
												print "Done.\n";
												}
												elsif($pht == 22)
												{
												my $alt2file=$alt2->get('0.0', 'end');
												chomp $alt2file;
												my $alt3pht=$alt3->get('0.0', 'end');
												chomp $alt3pht;
													if(! $alt3pht)
													{
													$output_text->insert('end', "please specify the alternate phenotype name or phenotype column\n");
													die "please specify the alternate phenotype name or phenotype column\n";
													}
												print "Specify an alternate phenotype using $alt2file, the phenotype $alt3pht (phenotype name or column) is the one to be used\n";
												$output_text->insert('end', "Specify an alternate phenotype using $alt2file, the phenotype $alt3pht (phenotype name or column) is the one to be used\n");
												open(f999,$alt2file);
												my $temp9=<f999>;
												close f999;
													if($temp9=~/^FID/)
													{
													my $runcom3="$mycom --pheno $alt2file --pheno-name $alt3pht --$out_format --out $dir$outname";
													my $runcomOut3=qx/$runcom3/;
													$output_text->insert('end', "$runcomOut3\n");
													}
													else
													{
													my $runcom4="$mycom --pheno $alt2file --mpheno $alt3pht --$out_format --out $dir$outname";
													my $runcomOut4=qx/$runcom4/;
													$output_text->insert('end', "$runcomOut4\n");
													$output_text->insert('end', "Done.\n"); #log
													print "Done.\n";
													}
												}
													
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
}
1;
