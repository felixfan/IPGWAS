package QC::missCheck;

use warnings;
use strict;

use Chart::Gnuplot;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;

sub MissingnessCheck
{
my($output_text, $mw, $gp_win, $gnuplot)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("420x310");
$gp_win->title("Call Rate Plot");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $input1_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$input1_frame->Label(-text => ".lmiss File")->pack(-side => "left");
		my $T1=$input1_frame->Text(-height => 1, -width => 45)->pack(-side=>"left");
		my $browse_button1 = $input1_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['.lmiss', '.lmiss'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
	my $input2_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$input2_frame->Label(-text => ".imiss File")->pack(-side => "left");
		my $T11=$input2_frame->Text(-height => 1, -width => 45)->pack(-side=>"left");
		my $browse_button2 = $input2_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T11->delete('0.0', 'end');
																	$input_path2=$mw->getOpenFile(-filetypes=>[
																											['.imiss', '.imiss'],
																											['All files', '*'],
																																					]);
																	$T11->insert('end', $input_path2);
																	}
													)->pack(-side => "left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"SNPs plot options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
	my $title_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #title frame
		$title_frame->Label(-text=>"Tile     ")->pack(-side=>'left');
		my $T2=$title_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T2->delete('0.0','end');
			$T2->insert('end', 'Ordered SNPs Call Rate');
	my $xlabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #X label frame
		$xlabel_frame->Label(-text=>"X label")->pack(-side=>'left');
		my $T3=$xlabel_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end','Quantile');
	my $ylabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #Y label frame
		$ylabel_frame->Label(-text=>"Y label")->pack(-side=>'left');
		my $T4=$ylabel_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T4->delete('0.0','end');
			$T4->insert('end','Call Rate');
			
my $option_frame2=$gp_win->LabFrame(-label=>"Individuals plot options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
	my $title_frame2=$option_frame2->Frame()->pack(-side=>"top", -anchor=>'w'); #title frame
		$title_frame2->Label(-text=>"Tile     ")->pack(-side=>'left');
		my $T22=$title_frame2->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T22->delete('0.0','end');
			$T22->insert('end', 'Ordered Individuals Call Rate');
	my $xlabel_frame2=$option_frame2->Frame()->pack(-side=>"top", -anchor=>'w'); #X label frame
		$xlabel_frame2->Label(-text=>"X label")->pack(-side=>'left');
		my $T33=$xlabel_frame2->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T33->delete('0.0','end');
			$T33->insert('end','Quantile');
	my $ylabel_frame2=$option_frame2->Frame()->pack(-side=>"top", -anchor=>'w'); #Y label frame
		$ylabel_frame2->Label(-text=>"Y label")->pack(-side=>'left');
		my $T44=$ylabel_frame2->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T44->delete('0.0','end');
			$T44->insert('end','Call Rate');

my $out_frame=$gp_win->LabFrame(-label=>"Output File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T5=$out_frame->Text(-height => 1, -width => 46)->pack(-side=>"left");
			$T5->delete('0.0','end');
			$T5->insert('end','Missingness.png');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .lmiss file\n");
															die "No .lmiss file: $!\n";
															}
												$output_text->insert('end', "$inpath opened\n"); #log
												print "$inpath opened\n";
												
												my $inpath2=$T11->get('0.0', 'end');
												chomp $inpath2;
															if(! $inpath2)
															{
															$output_text->insert('end', "No .imiss file\n");
															die "No .imiss file: $!\n";
															}
												$output_text->insert('end', "$inpath2 opened\n"); #log
												print "$inpath2 opened\n";
												
												my($base,$dir,$ext)=fileparse($inpath,'\..*');
												
												my $outname=$T5->get('0.0', 'end');
												$output_text->insert('end', "output: $dir$outname"); #log
												chomp $outname;
												$outname="$dir$outname";
												
												$output_text->insert('end', "\nSNPs Plot:\n"); ###log
												
												my $mytitle=$T2->get('0.0', 'end');
												$output_text->insert('end', "Plot Title: $mytitle"); #log
												chomp $mytitle;
												
												my $myx=$T3->get('0.0', 'end');
												$output_text->insert('end', "Plot X label: $myx"); #log
												chomp $myx;
												
												my $myy=$T4->get('0.0', 'end');
												$output_text->insert('end', "Plot Y label: $myy"); #log
												chomp $myy;
												
												$output_text->insert('end', "\nIndividuals Plot:\n"); ###log
												
												my $mytitle2=$T22->get('0.0', 'end');
												$output_text->insert('end', "Plot Title: $mytitle2"); #log
												chomp $mytitle2;
												
												my $myx2=$T33->get('0.0', 'end');
												$output_text->insert('end', "Plot X label: $myx2"); #log
												chomp $myx2;
												
												my $myy2=$T44->get('0.0', 'end');
												$output_text->insert('end', "Plot Y label: $myy2"); #log
												chomp $myy2;
												
												$output_text->insert('end', "Plotting...\n"); #log
												print "\nPlotting...\n";
												#------------------------------
												open(f1, $inpath);
												my @sex;
												my @ind;
												my $n=0;
												
												<f1>; # first line
												while(<f1>) # lmiss check
												{
												chomp;
												$_=~s/^\s+//;
												my @arry=split(/\s+/,$_);
												$sex[$n]=1-$arry[4]; # y

												$ind[$n]=$n+1; # x
												$n++;
												}
												close f1;

												@sex=sort{$a<=>$b}@sex; #sort
												$n-=1;
												for(my $i=0; $i<$#ind; $i++)
												{
												$ind[$i]/=$n;
												}
												#----------------------------------
												open(f1, $inpath2);
												my @sex2;
												my @ind2;
												my $n2=0;
												

												<f1>; # first line
												while(<f1>) # lmiss check
												{
												chomp;
												$_=~s/^\s+//;
												my @arry=split(/\s+/,$_);
												$sex2[$n2]=1-$arry[5]; # y
												$ind2[$n2]=$n2+1; # x
												$n2++;
												}
												close f1;
												
												@sex2=sort{$a<=>$b}@sex2; #sort
												$n2-=1;
												for(my $i=0; $i<=$#ind2; $i++)
												{
												$ind2[$i]/=$n2;
												}
												#-------------------------------
												# Create chart object and specify the properties of the chart
												my $misschart=Chart::Gnuplot->new(
														gnuplot => $gnuplot,   # for Windows, the address of gnuplot
														terminal => 'png',
														output => $outname,     # output name
														imagesize => "1260, 689",
													);
												# Create chart object and specify the properties of the chart
													my $chart = Chart::Gnuplot->new(
														title  => $mytitle,
														xlabel => $myx,
														ylabel => $myy,
														xrange => [-0.1, 1.1],
														yrange => [-0.1, 1.1],
														imagesize => "640, 480",
														grid=>{
															type  => 'dash',
															color => "gray",
															# xlines => "off"
															}
													);

												# Create dataset object and specify the properties of the dataset
													my $dataSet = Chart::Gnuplot::DataSet->new(
														xdata => \@ind,
														ydata => \@sex,
														# style => "dots", # .
														style => "points",
														color => "black",
														pointsize => "0.25",
														pointtype => "3",   #1 +, 2 x, 3 *, 0 ., 4, 5, 6 o, 14
													);
													
												$chart->add2d($dataSet); #add but not plot####
												#---------------------------------------------------------------------------------
												# Create chart object and specify the properties of the chart
													my $chart2 = Chart::Gnuplot->new(
														title  => $mytitle2,
														xlabel => $myx2,
														ylabel => $myy2,
														xrange => [-0.1, 1.1],
														imagesize => "640, 480",
														grid=>{
															type  => 'dash',
															color => "gray",
															# xlines => "off"
															}
														);

												# Create dataset object and specify the properties of the dataset
													my $dataSet2 = Chart::Gnuplot::DataSet->new(
														xdata => \@ind2,
														ydata => \@sex2,
														# style => "dots", # .
														style => "points",
														color => "black",
														pointsize => "0.25",
														pointtype => "3",   #1 +, 2 x, 3 *, 0 ., 4, 5, 6 o, 14
													);
												$chart2->add2d($dataSet2); #add but not plot####
												#---------------------------------------------------------------------------------
												
												 # Place the Chart::Gnuplot objects in matrix to indicate their locations
												$misschart->multiplot(
																		[
																			[$chart2, $chart]
																		]
																	);
												
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

}
1;
