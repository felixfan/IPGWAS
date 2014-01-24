package QC::MissingVSheterozygosity;

use warnings;
use strict;

use Chart::Gnuplot;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;

sub missingnessVSheterozygosityPlot
{
my($output_text, $mw, $gp_win, $gnuplot)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("480x310");
$gp_win->title("Missingness versus Heterozygosity Plot");

$gp_win->resizable(0, 0);

my $size="default";

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $input1_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$input1_frame->Label(-text => ".imiss File")->pack(-side => "left");
		my $T1=$input1_frame->Text(-height => 1, -width => 45)->pack(-side=>"left");
		my $browse_button1 = $input1_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['.imiss', '.imiss'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
	my $input2_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$input2_frame->Label(-text => ".het File")->pack(-side => "left");
		my $T11=$input2_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button2 = $input2_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T11->delete('0.0', 'end');
																	$input_path2=$mw->getOpenFile(-filetypes=>[
																											['.het', '.het'],
																											['All files', '*'],
																																					]);
																	$T11->insert('end', $input_path2);
																	}
													)->pack(-side => "left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Plot options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
	my $title_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #title frame
		$title_frame->Label(-text=>"Tile     ")->pack(-side=>'left');
		my $T2=$title_frame->Text(-height => 1, -width => 58)->pack(-side=>"left");
			$T2->delete('0.0','end');
			$T2->insert('end', '');
	my $xlabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #X label frame
		$xlabel_frame->Label(-text=>"X label")->pack(-side=>'left');
		my $T3=$xlabel_frame->Text(-height => 1, -width => 58)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end','Genotypes missing rate');
	my $ylabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #Y label frame
		$ylabel_frame->Label(-text=>"Y label")->pack(-side=>'left');
		my $T4=$ylabel_frame->Text(-height => 1, -width => 58)->pack(-side=>"left");
			$T4->delete('0.0','end');
			$T4->insert('end','Heterozygosity rate');
	my $size_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #size frame
		$size_frame->Label(-text=>"Size:")->pack(-side => "left");
		$size_frame->Radiobutton(-text=>"Default       ", -value=>'default', -variable=>\$size)->pack(-side => "left");
		$size_frame->Radiobutton(-text=>"Custom", -value=>'custom', -variable=>\$size)->pack(-side => "left");
		$size_frame->Label(-text=>"Length:")->pack(-side=>'left');
		my $T77=$size_frame->Text(-height => 1, -width => 10)->pack(-side=>"left");
		$size_frame->Label(-text=>"Height:")->pack(-side=>'left');
		my $T88=$size_frame->Text(-height => 1, -width => 10)->pack(-side=>"left");
my $out_frame=$gp_win->LabFrame(-label=>"Output File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T5=$out_frame->Text(-height => 1, -width => 49)->pack(-side=>"left");
			$T5->delete('0.0','end');
			$T5->insert('end','MissingVersusHet.png');

#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .lmiss file\n");
															die "No .imiss file: $!\n";
															}
												$output_text->insert('end', "$inpath opened\n"); #log
												print "$inpath opened\n";
												
												my $inpath2=$T11->get('0.0', 'end');
												chomp $inpath2;
															if(! $inpath2)
															{
															$output_text->insert('end', "No .het file\n");
															die "No .het file: $!\n";
															}
												$output_text->insert('end', "$inpath2 opened\n"); #log
												print "$inpath2 opened\n";
												
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
												
												#size
												my $sizeX=0;
												my $sizeY=0;
												if($size eq "default")
												{
												$sizeX=1260;
												$sizeY=689;
												}
												else
												{
												$sizeX=$T77->get('0.0', 'end');
												$sizeY=$T88->get('0.0', 'end');
												chomp $sizeX;
												chomp $sizeY;
													if(!$sizeX || !$sizeY)
													{
													die"Please specify the Length and/or the Height\n";
													}
												}
												
												$output_text->insert('end', "Plotting...\n"); #log
												print "\nPlotting...\n";
												#------------------------------
												my @ind;
												my @het;
												open(f1, $inpath);
												my $n1=0;
												my ($min1, $min2, $max1, $max2)=(1, 1, 0, 0);
												my $n2=0;
												<f1>;
												while(<f1>)
												{
												chomp;
												$_=~s/^\s+//;
												my @arr=split(/\s+/, $_);
												$ind[$n1]=$arr[5];
												$min1 = ($min1 > $ind[$n1]) ? $ind[$n1] : $min1;
												$max1 = ($max1 < $ind[$n1]) ? $ind[$n1] : $max1;
												$n1++;
												}
												close f1;
												#---------------------------------
												open(f1, $inpath2);
												<f1>;
												while(<f1>)
												{
												chomp;
												$_=~s/^\s+//;
												my @arr=split(/\s+/, $_);
												$het[$n2]=($arr[4]-$arr[2])/$arr[4];
												$min2 = ($min2 > $het[$n2]) ? $het[$n2] : $min2;
												$max2 = ($max2 < $het[$n2]) ? $het[$n2] : $max2;
												$n2++;
												}
												close f1;
												
												#check
												if($n1 != $n2)
												{
												die "There are different number of individuals in .imiss and .het files!\n$n1 vs $n2\n";
												}
												
												$min1-=0.1;
												$min2-=0.1;
												$max1+=0.1;
												$max2+=0.1;
												#-------------------------------
												
												# Create chart object and specify the properties of the chart
													my $chart = Chart::Gnuplot->new(
														gnuplot => $gnuplot,   # for Windows, the address of gnuplot
														terminal => 'png',
														output => $outname,     # output name
														title  => $mytitle,
														xlabel => $myx,
														ylabel => $myy,
														xrange => [$min1, $max1],
														yrange => [$min2, $max2],
														imagesize => "$sizeX, $sizeY",
													);

												# Create dataset object and specify the properties of the dataset
													my $dataSet = Chart::Gnuplot::DataSet->new(
														xdata => \@ind,
														ydata => \@het,
														# style => "dots", # .
														style => "points",
														color => "black",
														pointsize => "0.25",
														pointtype => "3",   #1 +, 2 x, 3 *, 0 ., 4, 5, 6 o, 14
													);
													
												
												$chart->plot2d($dataSet);
												#---------------------------------------------------------------------------------
												
												
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

}
#####################
sub identiMissHet
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("480x270");
$gp_win->title("Identify Individuals with High Missing Rate and/or Extreme Heterozygosity");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

my ($miss, $het)=(0,0);

my $input_path2;
#input frame
my $input_frames=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $genome_frame=$input_frames->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top"); # genome input
		$genome_frame->Label(-text => ".imiss File")->pack(-side => "left");
		my $T1=$genome_frame->Text(-height => 1, -width => 45)->pack(-side=>"left");
		my $browse_button1 = $genome_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['.miss files', '.imiss'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
	my $imiss_frame=$input_frames->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top"); # imiss input
		$imiss_frame->Label(-text => ".het File")->pack(-side => "left");
		my $T2=$imiss_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button2 = $imiss_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T2->delete('0.0', 'end');
																	$input_path2=$mw->getOpenFile(-filetypes=>[
																											['.het files', '.het'],
																											['All files', '*'],
																																					]);
																	$T2->insert('end', $input_path2);
																	}
													)->pack(-side => "left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
my $opt1_frame=$option_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
		my $cb1=$opt1_frame->Checkbutton(-text=>"missing rate cutoff:", -variable=>\$miss)->pack(-side => "left", -anchor=>'w');	
		my $text1=$opt1_frame->Text(-height => 1, -width => 46)->pack(-side=>'left');
		$text1->delete('0.0','end');
		
my $opt2_frame=$option_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
		my $cb2=$opt2_frame->Checkbutton(-text=>"heterozygosity cutoff:", -variable=>\$het)->pack(-side => "left", -anchor=>'w');
		$opt2_frame->Label(-text=>"minimum cutoff")->pack(-side => "left", -anchor=>'w');
		my $text2=$opt2_frame->Text(-height => 1, -width => 6)->pack(-side=>'left');
		$text2->delete('0.0','end');
		$opt2_frame->Label(-text=>"maximum cutoff")->pack(-side => "left", -anchor=>'w');
		my $text3=$opt2_frame->Text(-height => 1, -width => 8)->pack(-side=>'left');
		$text3->delete('0.0','end');
		
#output frame			
my $out_frame=$gp_win->LabFrame(-label=>"Output", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T3=$out_frame->Text(-height => 1, -width => 49)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end','rmIndividuals');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .imiss file\n");
															die "No .imiss file: $!\n";
															}
												$output_text->insert('end', "$inpath opened\n"); #log
												print "$inpath opened\n";
												
												my $inpath2=$T2->get('0.0', 'end');
												chomp $inpath2;
															if(! $inpath2)
															{
															$output_text->insert('end', "No .het file\n");
															die "No .het file: $!\n";
															}
												$output_text->insert('end', "$inpath2 opened\n"); #log
												print "$inpath2 opened\n";
												
												my($base,$dir,$ext)=fileparse($inpath,'\..*');
												
												my $mymiss=$text1->get('0.0', 'end');
												chomp $mymiss;
												my $myminhet=$text2->get('0.0', 'end');
												chomp $myminhet;
												my $mymaxhet=$text3->get('0.0', 'end');
												chomp $mymaxhet;
												
												#default do not remove any individuals
												$mymiss ||= 100;
												$myminhet ||= -100;
												$mymaxhet ||=100;
												#test
												print "$mymiss\n$myminhet\n$mymaxhet\n";
												
												my $outpath=$T3->get('0.0', 'end');
												$output_text->insert('end', "output file: $outpath"); #log
												chomp $outpath;
												my $outlog="$dir$outpath.log";
												$outpath="$dir$outpath.txt";
												open(f9, ">$outlog");
												
												
												#------------------------------
												my %individual;
												#----------------------------------
													if($miss==1 && $het==1)
													{
													$output_text->insert('end', "missing rate cutoff: $mymiss\n"); #log
													$output_text->insert('end', "minimum heterozygosity cutoff: $myminhet\n"); #log
													$output_text->insert('end', "maximum heterozygosity cutoff: $mymaxhet\n"); #log
													print "FID\tIID\tMissingRate\n"; #log
													print f9 "FID\tIID\tMissingRate\n"; #log
													$output_text->insert('end', "FID\tIID\tMissingRate\n"); #log
														open(f1, $inpath);
														<f1>; #title line
														while(<f1>) 
														{
														chomp;
														my @arry=split(/\s+/,$_); 
															if($arry[6] > $mymiss)
															{
															print "$arry[1]\t$arry[2]\t$arry[6]\t should be removed\n";             #log
															print f9 "$arry[1]\t$arry[2]\t$arry[6]\t should be removed\n";             #log
															$output_text->insert('end', "$arry[1]\t$arry[2]\t$arry[6]\t should be removed\n"); #log
															my $temp1="$arry[1] $arry[2]";
															$individual{$temp1}=1;
															}
														}
														close f1;
													print "FID\tIID\tHeterozygosity\n"; #log
													print f9 "FID\tIID\tHeterozygosity\n"; #log
													$output_text->insert('end', "FID\tIID\tHeterozygosity\n"); #log
														open(f1, $inpath2);
														<f1>; #title line
														while(<f1>) 
														{
														chomp;
														my @arry=split(/\s+/,$_); 
														my $myyhet=($arry[5]-$arry[3])/$arry[5];
															if($myyhet > $mymaxhet || $myyhet < $myminhet)
															{
															print "$arry[1]\t$arry[2]\t$myyhet\t should be removed\n";             #log
															print f9 "$arry[1]\t$arry[2]\t$myyhet\t should be removed\n";             #log
															$output_text->insert('end', "$arry[1]\t$arry[2]\t$myyhet\t should be removed\n"); #log
															my $temp2="$arry[1] $arry[2]";
															$individual{$temp2}=1;
															}
														}
														close f1;
													}
													elsif($miss==1 && $het==0)
													{
													$output_text->insert('end', "missing rate cutoff: $mymiss\n"); #log
												
													print "FID\tIID\tMissingRate\n"; #log
													print f9 "FID\tIID\tMissingRate\n"; #log
													$output_text->insert('end', "FID\tIID\tMissingRate\n"); #log
														open(f1, $inpath);
														<f1>; #title line
														while(<f1>) 
														{
														chomp;
														my @arry=split(/\s+/,$_); 
															if($arry[6] > $mymiss)
															{
															print "$arry[1]\t$arry[2]\t$arry[6]\t should be removed\n";             #log
															print f9 "$arry[1]\t$arry[2]\t$arry[6]\t should be removed\n";             #log
															$output_text->insert('end', "$arry[1]\t$arry[2]\t$arry[6]\t should be removed\n"); #log
															my $temp1="$arry[1] $arry[2]";
															$individual{$temp1}=1;
															}
														}
														close f1;
													}
													elsif($miss==0 && $het==1)
													{
													$output_text->insert('end', "minimum heterozygosity cutoff: $myminhet\n"); #log
													$output_text->insert('end', "maximum heterozygosity cutoff: $mymaxhet\n"); #log
													print "FID\tIID\tHeterozygosity\n"; #log
													print f9 "FID\tIID\tHeterozygosity\n"; #log
													$output_text->insert('end', "FID\tIID\tHeterozygosity\n"); #log
														open(f1, $inpath2);
														<f1>; #title line
														while(<f1>) 
														{
														chomp;
														my @arry=split(/\s+/,$_); 
														my $myyhet=($arry[5]-$arry[3])/$arry[5];
															if($myyhet > $mymaxhet || $myyhet < $myminhet)
															{
															print "$arry[1]\t$arry[2]\t$myyhet\t should be removed\n";             #log
															print f9 "$arry[1]\t$arry[2]\t$myyhet\t should be removed\n";             #log
															$output_text->insert('end', "$arry[1]\t$arry[2]\t$myyhet\t should be removed\n"); #log
															my $temp2="$arry[1] $arry[2]";
															$individual{$temp2}=1;
															}
														}
														close f1;
													}
													else
													{
													$output_text->insert('end', "please set the cutoff values\n"); #log
													die "please set the cutoff values\n";
													}
																								
												open(f2, ">$outpath");
												my $nnn=0;
												foreach my $key(keys %individual)
												{
												print f2 "$key\n";
												$nnn++;
												}
												close f2;
												
												
												if($nnn==0)
												{
												unlink $outpath;
												print f9 "No individual should be removed.\n";
												print "No individual should be removed.\n";
												$output_text->insert('end', "No individual should be removed.\n"); #log
												}
												else
												{
												print "Write individuals FID and IID to: $outpath\n";
												$output_text->insert('end', "Write individuals FID and IID to: $outpath\n"); #log
												}
												
												close f9;
												
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

1;
