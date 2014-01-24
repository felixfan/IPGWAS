package QC::sexCheck;

use warnings;
use strict;

use Chart::Gnuplot;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;

sub GenderCheck
{
my($output_text, $mw, $gp_win, $gnuplot)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("480x210");
$gp_win->title("Sex Check");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	$input_frame->Label(-text => ".sexcheck File")->pack(-side => "left");
	my $T1=$input_frame->Text(-height => 1, -width => 43)->pack(-side=>"left");
	my $browse_button1 = $input_frame->Button(-text => 'Browse',
												-command => sub	{
																$T1->delete('0.0', 'end');
																$input_path=$mw->getOpenFile(-filetypes=>[
																										['SexCheck files', '.sexcheck'],
																										['All files', '*'],
																																				]);
																$T1->insert('end', $input_path);
																}
												)->pack(-side => "left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
	my $title_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #title frame
		$title_frame->Label(-text=>"Tile     ")->pack(-side=>'left');
		my $T2=$title_frame->Text(-height => 1, -width => 60)->pack(-side=>"left");
			$T2->delete('0.0','end');
			$T2->insert('end','Sex Check');
	my $xlabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #X label frame
		$xlabel_frame->Label(-text=>"X label")->pack(-side=>'left');
		my $T3=$xlabel_frame->Text(-height => 1, -width => 60)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end','Individuals index');
	my $ylabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #Y label frame
		$ylabel_frame->Label(-text=>"Y label")->pack(-side=>'left');
		my $T4=$ylabel_frame->Text(-height => 1, -width => 60)->pack(-side=>"left");
			$T4->delete('0.0','end');
			$T4->insert('end','F: The actual X chromosome inbreeding (homozygosity) estimate');
	my $out_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T5=$out_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T5->delete('0.0','end');
			$T5->insert('end','SexCheckPlot.png');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .sexcheck file\n");
															die "No .sexcheck file: $!\n";
															}
												$output_text->insert('end', "$inpath opend\n"); #log
												my($base,$dir,$ext)=fileparse($inpath,'\..*');
												
												my $outname=$T5->get('0.0', 'end');
												$output_text->insert('end', "output: $dir$outname"); #log
												chomp $outname;
												$outname="$dir$outname";
												
												my $mytitle=$T2->get('0.0', 'end');
												$output_text->insert('end', "Plot Title: $mytitle"); #log
												chomp $mytitle;
												
												my $myx=$T3->get('0.0', 'end');
												$output_text->insert('end', "Plot X label: $myx"); #log
												chomp $myx;
												
												my $myy=$T4->get('0.0', 'end');
												$output_text->insert('end', "Plot Y label: $myy"); #log
												chomp $myy;
												
												$output_text->insert('end', "Plotting...\n"); #log
												#------------------------------
												my $mismatch="misMatchSexIndividuals.txt";
												$mismatch="$dir$mismatch";
												open(OUT, ">$mismatch");
												
												open(f1, $inpath);
												my @sexm; #y1
												my @indm; #x1
												
												my @sexf; #y2
												my @indf; #x2
												
												my $n=0; # total individual
												my $m=0; #problem individual
												my $y1=10;
												my $y2=-10;
												
												my $indexm=0;
												my $indexf=0;
												
												<f1>; # first line
												while(<f1>) # sex check
												{
												chomp;
												$_=~s/^\s+//;
												my @arry=split(/\s+/,$_);
													if($arry[2]==1)
													{
													$sexm[$indexm]=$arry[5];
													$indm[$indexm]=$n+1;
													$indexm++;
													}
													elsif($arry[2]==2)
													{
													$sexf[$indexf]=$arry[5];
													$indf[$indexf]=$n+1;
													$indexf++;
													}
													else
													{
													die "Sex as determined in pedigree file (1=male, 2=female) is not 1 or 2\n";
													}
												$n++; # individual index
											
												$y1=($arry[5] < $y1 ? $arry[5] : $y1);
												$y2=($arry[5] > $y2 ? $arry[5] : $y2);
												
												# identify Problem individuals
													if($arry[4] eq "PROBLEM")
													{
													$m++;
													print OUT "$arry[0]\t$arry[1]\n"; #print out FID IID
													}
												}
												close f1;
												close OUT;

												#The plot region
												$y1-=0.2;
												$y2+=0.2;

												# Create chart object and specify the properties of the chart
													my $chart = Chart::Gnuplot->new(
														gnuplot => $gnuplot,   # for Windows, the address of gnuplot
														terminal => 'png',
														output => $outname,     # output name
														title  => $mytitle,
														xlabel => $myx,
														ylabel => $myy,
														yrange => [$y1, $y2],
														imagesize => "1260, 689",
														legend => {
															position => "bottom outside below",  # left, right, top, bottom, outside, and below
															align => "left"   #left right
														}
													);

												# Create dataset object and specify the properties of the dataset
													my $dataSet1 = Chart::Gnuplot::DataSet->new(
														xdata => \@indm,
														ydata => \@sexm,
														# style => "dots", # .
														style => "points",
														color => "red",
														pointsize => "0.25",
														pointtype => "3",   #1 +, 2 x, 3 *, 0 ., 4, 5, 6 o, 14
														title => "Male"
													);
												
													my $dataSet2 = Chart::Gnuplot::DataSet->new(
														xdata => \@indf,
														ydata => \@sexf,
														style => "points",
														color => "blue",
														pointsize => "0.25",
														pointtype => "3",   #1 +, 2 x, 3 *, 0 ., 4, 5, 6 o, 14
														title => "Female"
													);

												# Plot the data set on the chart

												$chart->plot2d($dataSet1, $dataSet2);
												
												$output_text->insert('end', "\nSave the sex check plot to: $outname\n"); #log
												print "\nSave the sex check plot to: $outname\n";
												
												# identify mismatch sex individuals
												$output_text->insert('end', "\nChecking gender mismatch individuals...\n"); #log
												print "\nChecking gender mismatch individuals...\n";
												
												print "Total individuals: $n\nGender mismatch individuals: $m\n";
												$output_text->insert('end', "Total individuals: $n\nGender mismatch individuals: $m\n"); #log
												
												if($m > 0)
												{
												print "The gender mismatch individuals were write to: $mismatch\n";
												$output_text->insert('end', "The gender mismatch individuals were write to: $mismatch\n"); #log
												}
												else
												{
												unlink $mismatch;
												}
												
												
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

}
1;
