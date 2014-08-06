package Merge::QCpht;

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
my $ooo;
my $ok_frame;

my $pht=-9;

$gp_win->geometry("450x200");
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
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		my $pht1_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $label2=$pht1_frame->Label(-text => "Change All Subjects Affection status to:")->pack(-side => "left");
		my $pht2_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio4=$pht2_frame->Radiobutton(-text=>"Unaffected(1)         ", -value=> 1, -variable=>\$pht)->pack(-side => "left");
			my $radio5=$pht2_frame->Radiobutton(-text=>"Affected(2)         ", -value=> 2, -variable=>\$pht)->pack(-side => "left");
			my $radio6=$pht2_frame->Radiobutton(-text=>"Missing(-9)         ", -value=> -9, -variable=>\$pht)->pack(-side => "left");
			my $radio7=$pht2_frame->Radiobutton(-text=>"Missing(0)           ", -value=> 0, -variable=>\$pht)->pack(-side => "left");

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
												
												my $i=0;
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
