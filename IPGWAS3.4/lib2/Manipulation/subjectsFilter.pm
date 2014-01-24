package Manipulation::subjectsFilter;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;
use File::Copy;

sub filtSubjects
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $ooo;
my $ok_frame;

my $pht=0;
my $sex=0;

$gp_win->geometry("560x300");
$gp_win->title("Filter on Affection Status and Sex");

$gp_win->resizable(0, 0);


my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

my $out_format;
my $output_name;

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $in1_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in1_frame->Label(-text => "ped/bed File")->pack(-side => "left");
		my $T1=$in1_frame->Text(-height => 1, -width => 56)->pack(-side=>"left");
		my $browse_button1 = $in1_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['ped files', '.ped'],
																											['bed files', '.bed'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
	my $pht_frame=$option_frame->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top", -anchor=>'w');	#pht
		my $pht1_frame=$pht_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $label2=$pht1_frame->Label(-text => "Filter on Affection Status")->pack(-side => "left");
		my $pht2_frame=$pht_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio4=$pht2_frame->Radiobutton(-text=>"Keep Control Only (--filter-cases)", -value=> 1, -variable=>\$pht)->pack(-side => "left");
			my $radio5=$pht2_frame->Radiobutton(-text=>"Keep Case Only (--filter-controls)", -value=> 2, -variable=>\$pht)->pack(-side => "left");
			my $radio7=$pht2_frame->Radiobutton(-text=>"No Filter", -value=> 0, -variable=>\$pht)->pack(-side => "left");
	my $sex_frame=$option_frame->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top", -anchor=>'w');	#sex
		my $sex1_frame=$sex_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $label22=$sex1_frame->Label(-text => "Filter on Gender Status")->pack(-side => "left");
		my $sex2_frame=$sex_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio42=$sex2_frame->Radiobutton(-text=>"Keep Male Only(--filter-males) ", -value=> 1, -variable=>\$sex)->pack(-side => "left");
			my $radio52=$sex2_frame->Radiobutton(-text=>"Keep Female Only(--filter-females) ", -value=> 2, -variable=>\$sex)->pack(-side => "left");
			my $radio72=$sex2_frame->Radiobutton(-text=>"No Filter ", -value=> 0, -variable=>\$sex)->pack(-side => "left");
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $sequenom=$T1->get('0.0', 'end');
												chomp $sequenom;
															if(! $sequenom)
															{
															$output_text->insert('end', "No PED/BED file\n");
															die "No PED/BED file: $!\n";
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
													elsif($ext eq ".bed")
													{
													my $mybed="$dir$base.fam";
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
												
												$output_text->insert('end', "Check Affection and Gender Status...\n"); #log
												print "Check Affection and Gender Status...\n";
												print "PLINK is running...\n";
												###log
												my $runcom2;
												my $runcomOut2;
													if($pht==0 && $sex==0)
													{
													$output_text->insert('end', "No filter was used.\n"); #log
													print "No filter was used.\n";
													}
													elsif($pht==0 && $sex==1)
													{
													$output_text->insert('end', "No Filter on Affection Status.\nKeep Male Only.\n"); #log
													print "No Filter on Affection Status.\nKeep Male Only.\n";
													$runcom2="$mycom --filter-males --$out_format --out $dir$outname";
													$runcomOut2=qx/$runcom2/;
													}
													elsif($pht==0 && $sex==2)
													{
													$output_text->insert('end', "No Filter on Affection Status.\nKeep Female Only.\n"); #log
													print "No Filter on Affection Status.\nKeep Female Only.\n";
													$runcom2="$mycom --filter-females --$out_format --out $dir$outname";
													$runcomOut2=qx/$runcom2/;
													}
													elsif($pht==1 && $sex==0)
													{
													$output_text->insert('end', "Keep Control Only.\nNo Filter on Gender Status.\n"); #log
													print "Keep Control Only.\nNo Filter on Gender Status.\n";
													$runcom2="$mycom --filter-controls --$out_format --out $dir$outname";
													$runcomOut2=qx/$runcom2/;
													}
													elsif($pht==1 && $sex==1)
													{
													$output_text->insert('end', "Keep Control Only.\nKeep Male Only.\n"); #log
													print "Keep Control Only.\nKeep Male Only.\n";
													$runcom2="$mycom --filter-controls --filter-males --$out_format --out $dir$outname";
													$runcomOut2=qx/$runcom2/;
													}
													elsif($pht==1 && $sex==2)
													{
													$output_text->insert('end', "Keep Control Only.\nKeep Female Only.\n"); #log
													print "Keep Control Only.\nKeep Female Only.\n";
													$runcom2="$mycom --filter-controls --filter-females --$out_format --out $dir$outname";
													$runcomOut2=qx/$runcom2/;
													}
													elsif($pht==2 && $sex==0)
													{
													$output_text->insert('end', "Keep Case Only.\nNo Filter on Gender Status.\n"); #log
													print "Keep Case Only.\nNo Filter on Gender Status.\n";
													$runcom2="$mycom --filter-cases --$out_format --out $dir$outname";
													$runcomOut2=qx/$runcom2/;
													}
													elsif($pht==2 && $sex==1)
													{
													$output_text->insert('end', "Keep Case Only\nKeep Male Only\n"); #log
													print "Keep Case Only.\nKeep Male Only.\n";
													$runcom2="$mycom --filter-cases --filter-males --$out_format --out $dir$outname";
													$runcomOut2=qx/$runcom2/;
													}
													elsif($pht==2 && $sex==2)
													{
													$output_text->insert('end', "Keep Case Only.\nKeep Female Only.\n"); #log
													print "Keep Case Only.\nKeep Female Only.\n";
													$runcom2="$mycom --filter-cases --filter-females --$out_format --out $dir$outname";
													$runcomOut2=qx/$runcom2/;
													}
												
												$output_text->insert('end', "$runcomOut2\n");
												
												print "Done.\n";												
												$output_text->insert('end', "Done.\n"); #log	
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
