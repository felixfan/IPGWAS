package QC::HWEQQplot;

use warnings;
use strict;

use Chart::Gnuplot;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;

sub hweQQplot
{
my($output_text, $mw, $gp_win, $gnuplot)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("420x200");
$gp_win->title("HWE Quantile-Quantile plot");

$gp_win->resizable(0, 0);


my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	$input_frame->Label(-text => ".hwe File")->pack(-side => "left");
	my $T1=$input_frame->Text(-height => 1, -width => 44)->pack(-side=>"left");
	my $browse_button1 = $input_frame->Button(-text => 'Browse',
												-command => sub	{
																$T1->delete('0.0', 'end');
																$input_path=$mw->getOpenFile(-filetypes=>[
																										['.hwe files', '.hwe'],
																										['All files', '*'],
																																				]);
																$T1->insert('end', $input_path);
																}
												)->pack(-side => "left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
	my $title_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #title frame
		$title_frame->Label(-text=>"Tile     ")->pack(-side=>'left');
		my $T2=$title_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T2->delete('0.0','end');
			$T2->insert('end','HWE QQ plot for Control');
	my $xlabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #X label frame
		$xlabel_frame->Label(-text=>"X label")->pack(-side=>'left');
		my $T3=$xlabel_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end','-log10(Expected P value)');
	my $ylabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #Y label frame
		$ylabel_frame->Label(-text=>"Y label")->pack(-side=>'left');
		my $T4=$ylabel_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T4->delete('0.0','end');
			$T4->insert('end','-log10(Observer P value)');
	my $out_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T5=$out_frame->Text(-height => 1, -width => 46)->pack(-side=>"left");
			$T5->delete('0.0','end');
			$T5->insert('end','controlHWEQQplot.png');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .hwe file\n");
															die "No .hwe file: $!\n";
															}
												$output_text->insert('end', "$inpath opened\n"); #log
												print "$inpath opened\n";
												
												my($base,$dir,$ext)=fileparse($inpath,'\..*');
												
												my $outname=$T5->get('0.0', 'end');
												$output_text->insert('end', "output: $dir$outname"); #log
												print "output: $dir$outname";
												chomp $outname;
												$outname="$dir$outname";
												
												my $mytitle=$T2->get('0.0', 'end');
												$output_text->insert('end', "Plot Title: $mytitle"); #log
												print "Plot Title: $mytitle";
												chomp $mytitle;
												
												my $myx=$T3->get('0.0', 'end');
												$output_text->insert('end', "Plot X label: $myx"); #log
												print "Plot X label: $myx";
												chomp $myx;
												
												my $myy=$T4->get('0.0', 'end');
												$output_text->insert('end', "Plot Y label: $myy"); #log
												print "Plot Y label: $myy";
												chomp $myy;
												
												$output_text->insert('end', "Plotting...\n"); #log
												print "Plotting...\n";
												#------------------------------
												open(f1, $inpath);

												<f1>; #first line
												my $snpno=0;
												my @passo;  #p-value of association

												while(<f1>)
												{
													if($_=~/UNAFF/)
													{
													$_=~s/^\s+//;
													my @arr=split(/\s+/,$_);
														if($arr[8] ne "NA" && $arr[8] ne "1")
														{
														$passo[$snpno]=$arr[8];
														$snpno++;
														}
													}
												}

												my @p; #expected p-value 
												for(my $i=0;$i<$snpno;$i++)
												{
												$p[$i]=(($i+1)/($snpno+1));
												}

												@passo=sort{$a <=> $b}@passo; #sort
												# @p=sort{$a <=> $b}@p;

												for(my $i=0;$i<$snpno;$i++)
												{
												$p[$i]=-log($p[$i])/log(10);
												$passo[$i]=-log($passo[$i])/log(10);
												# $p[$i]=-log($p[$i]);
												# $passo[$i]=-log($passo[$i]);
												}

												# Create chart object and specify the properties of the chart
													my $chart = Chart::Gnuplot->new(
														gnuplot => $gnuplot,   # for Windows, the address of gnuplot
														terminal => 'png',     # output format
														output => $outname,     # output name
														xlabel => $myx,
														ylabel => $myy,
														title => $mytitle,
														imagesize => "1260, 689",
														# legend => {
															# position => "left top",  # left, right, top, bottom, outside, and below
															# align => "left"   #left right
														# }
													);

												# Create dataset object and specify the properties of the dataset
													my $dataSet1 = Chart::Gnuplot::DataSet->new(
														xdata => \@p,
														ydata => \@passo,
														style => "points",
														color => "red",
														pointsize => "0.25",
														pointtype => "3",   # *
														# title => "hwe"
													);
													my $dataSet2 = Chart::Gnuplot::DataSet->new(
														xdata => \@p,
														ydata => \@p,
														style => "lines",
														color => "black",
														# title => "NULL line"
													);

												# Plot the data set on the chart

													$chart->plot2d($dataSet1, $dataSet2);
												
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}
1;
