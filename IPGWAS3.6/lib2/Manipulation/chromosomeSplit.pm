package Manipulation::chromosomeSplit;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;
use File::Copy;

sub Splitchr
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $ooo;
my $ok_frame;

my $chr="all";

$gp_win->geometry("560x250");
$gp_win->title("Split Gwas Data by Chromosome");

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
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); 
	my $opt1_frame=$option_frame->Frame(-borderwidth=>2)->pack(-side=>"top", -anchor=>'w');	
		my $radio1=$opt1_frame->Radiobutton(-text=>"Output all chromosomes", -value=> "all", -variable=>\$chr)->pack(-side => "left");
	my $opt2_frame=$option_frame->Frame(-borderwidth=>2)->pack(-side=>"top", -anchor=>'w');	
		my $radio2=$opt2_frame->Radiobutton(-text=>"Only output assigned chromosomes", -value=> "some", -variable=>\$chr)->pack(-side => "left");
		my $T2=$opt2_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
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
												
												my $command="$plink";
												if($ext=~/ped/i)
												{
												$command.=" --file";
												}
												else
												{
												$command.=" --bfile";
												}
												
												my $outname=$output_name->get('0.0', 'end');
												chomp $outname;
												$outname.="_chr";
												#------------------------------------------------
												print "Plink is running...";
												if($chr eq "all")
												{
													for(my $i=1; $i<23; $i++)
													{
													# system("$command $dir$base --chr $i --$out_format --out $dir$outname$i");
													my $runcom="$command $dir$base --chr $i --$out_format --out $dir$outname$i";
													my $runcomOut=qx/$runcom/;
													$output_text->insert('end', "$runcomOut\n");
													}
												}
												else
												{
													my $chrNo=$T2->get('0.0', 'end');
													chomp $chrNo;
													if(! $chrNo)
													{
													$output_text->insert('end', "Please specify the chromosome you want output\n");
													die "Please specify the chromosome you want output\n";
													}
													
													my @arr=split(/\,/, $chrNo);
													foreach my $chrname(@arr)
													{
													# system("$command $dir$base --chr $chrname --$out_format --out $dir$outname$chrname");
													my $runcom="$command $dir$base --chr $chrname --$out_format --out $dir$outname$chrname";
													my $runcomOut=qx/$runcom/;
													$output_text->insert('end', "$runcomOut\n");
													}
												}
												print "\nDone.\n";												
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
