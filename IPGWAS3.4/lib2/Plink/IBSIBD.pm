package Plink::IBSIBD;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

sub IbsIbdPIE
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("560x260");
$gp_win->title("Pairwise IBD Estimation");

$gp_win->resizable(0, 0);

my ($full, $min, $max)=(1, 0, 0);
my $option="genome";
my ($text1, $text2);

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
														$mycom="--file $dir$base --$option";
														}
														elsif($ext eq ".bed")
														{
														$mycom="--bfile $dir$base --$option";
														}
														#----------------------
														if($full==1)
														{
														$mycom.=" --genome-full";
														}
														if($min==1)
														{
														my $mymin=$text1->get('0.0', 'end');
														chomp $mymin;
														$mycom.=" --min $mymin";
														}
														if($max==1)
														{
														my $mymax=$text2->get('0.0', 'end');
														chomp $mymax;
														$mycom.=" --max $mymax";
														}
														#-----------------------
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
		my $opt1_frame1=$option_frame->Frame()->pack(-side => "top", -anchor=>'w');
			my $radio1=$opt1_frame1->Radiobutton(-text=>"Create IBS Distance File(--genome)",
													-value=>"genome", -variable=>\$option)->pack(-side => "top", -anchor=>'w');	
			my $cb1=$opt1_frame1->Checkbutton(-text=>"Verbose Version (--genome-full)", -variable=>\$full)->pack(-side => "top", -anchor=>'w');
		my $opt1_frame2=$option_frame->Frame()->pack(-side => "top", -anchor=>'w');
			my $cb2=$opt1_frame2->Checkbutton(-text=>"Minimum Proportion IBD  (--min)  ", -variable=>\$min)->pack(-side => "left", -anchor=>'w');
			$text1=$opt1_frame2->Text(-height => 1, -width => 50)->pack(-side=>"left");
			$text1->insert('end', '0.05');
		my $opt1_frame3=$option_frame->Frame()->pack(-side => "top", -anchor=>'w');	
			my $cb3=$opt1_frame3->Checkbutton(-text=>"Maximum Proportion IBD  (--max)", -variable=>\$max)->pack(-side => "left", -anchor=>'w');
			$text2=$opt1_frame3->Text(-height => 1, -width => 50)->pack(-side=>"left");
			$text2->insert('end', '0.95');
}

###---------
sub IbsIbdHet
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("560x200");
$gp_win->title("Individual Heterozygosity");

$gp_win->resizable(0, 0);

my $option="het";
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
my $option_frame=$gp_win->LabFrame(-label=>"Option", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
		my $opt_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio5=$opt_frame1->Radiobutton(-text=>"Inbreeding Coefficients(--het)				                                          ",
												-value=>"het",
												-variable=>\$option)->pack(-side => "left");
}
###---------
sub IbsIbdHomozyg
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("560x350");
$gp_win->title("Runs of Homozygosity");

$gp_win->resizable(0, 0);

my ($group, $verbose, $match)=(0, 0, 0, 0);
my $option="homozyg";
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
														
														my $mycom;
														
														if($ext eq ".ped")
														{
														$mycom="--file $dir$base";
														}
														elsif($ext eq ".bed")
														{
														$mycom="--bfile $dir$base";
														}
														#--------------------------
																	if($option eq "homozyg")
																	{
																	$mycom.=" --$option";
																	}
																	elsif($option eq "homozyg-snp")
																	{
																	my $mysnp=$text1->get('0.0','end');
																	chomp $mysnp;
																	$mycom.=" --homozyg --$option $mysnp";
																	}
																	elsif($option eq "homozyg-kb")
																	{
																	my $mykb=$text2->get('0.0','end');
																	chomp $mykb;
																	$mycom.=" --homozyg --$option $mykb";
																	}
														#-----------------------------
																if($group ==1)
																{
																$mycom.=" --homozyg-group";
																}
																#---
																if($match==1)
																{
																my $mymatch=$text3->get('0.0','end');
																chomp $mymatch;
																$mycom.=" --homozyg-match $mymatch";
																}
																#---
																if($verbose==1)
																{
																$mycom.=" --homozyg-verbose";
																}
														#------------------------------
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
		my $opt1_frame1=$opt1_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top", -anchor=>'w');
			my $radio1=$opt1_frame1->Radiobutton(-text=>"Homozygous Run Length, Default (--homozyg)                                                             ", -value=>"homozyg", -variable=>\$option)->pack(-side => "left", -anchor=>'w');	
		my $opt1_frame2=$opt1_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top", -anchor=>'w');
			my $radio2=$opt1_frame2->Radiobutton(-text=>"Homozygous Run Length, SNPs (--homozyg-snp)", -value=>"homozyg-snp", -variable=>\$option)->pack(-side => "left", -anchor=>'w');
			$text1=$opt1_frame2->Text(-height => 1, -width => 31)->pack(-side=>"left");
			$text1->insert('end', '100');
		my $opt1_frame3=$opt1_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top", -anchor=>'w');
			my $radio3=$opt1_frame3->Radiobutton(-text=>"Homozygous Run Length, kb (--homozyg-kb)       ", -value=>"homozyg-kb", -variable=>\$option)->pack(-side => "left", -anchor=>'w');
			$text2=$opt1_frame3->Text(-height => 1, -width => 31)->pack(-side=>"left");
			$text2->insert('end', '1000');
my $opt2_frame=$gp_win->LabFrame(-label=>"Homozyg options", -labelside=>'acrosstop')->pack(-side => "top", -after=>$opt1_frame, -anchor=>'w');#option frame 2
		my $opt2_frame1=$opt2_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top", -anchor=>'w');
			my $radio4=$opt2_frame1->Checkbutton(-text=>"Group Overlapping Segments(--homozyg-group)                                                           ", -variable=>\$group)->pack(-side => "left", -anchor=>'w');
		my $opt2_frame2=$opt2_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top", -anchor=>'w');
			my $radio5=$opt2_frame2->Checkbutton(-text=>"Threshold for Allelic Match(--homozyg-match)                          ", -variable=>\$match)->pack(-side => "left");
			$text3=$opt2_frame2->Text(-height => 1, -width => 29)->pack(-side=>"left");
			$text3->insert('end', '0.99');
		my $opt2_frame3=$opt2_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top", -anchor=>'w');
			my $radio6=$opt2_frame3->Checkbutton(-text=>"Verbose Segment Listing(--homozyg-verbose)                                                              ", -variable=>\$verbose)->pack(-side => "left", -anchor=>'w');	

}
1;
