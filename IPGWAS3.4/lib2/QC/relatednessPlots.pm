package QC::relatednessPlots;

use warnings;
use strict;

use Chart::Gnuplot;
# use GD::Graph::histogram;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;

sub RelatednessPlot
{
my($output_text, $mw, $gp_win, $gnuplot)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

my @datasets;

$gp_win->geometry("480x210");
$gp_win->title("Cryptic Relateness Plot (IBS)");

$gp_win->resizable(0, 0);


my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	$input_frame->Label(-text => ".genome File")->pack(-side => "left");
	my $T1=$input_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
	my $browse_button1 = $input_frame->Button(-text => 'Browse',
												-command => sub	{
																$T1->delete('0.0', 'end');
																$input_path=$mw->getOpenFile(-filetypes=>[
																										['Genome files', '.genome'],
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
			$T2->insert('end','Cryptic Relatedness Check');
	my $xlabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #X label frame
		$xlabel_frame->Label(-text=>"X label")->pack(-side=>'left');
		my $T3=$xlabel_frame->Text(-height => 1, -width => 60)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end','IBS Mean');
	my $ylabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #Y label frame
		$ylabel_frame->Label(-text=>"Y label")->pack(-side=>'left');
		my $T4=$ylabel_frame->Text(-height => 1, -width => 60)->pack(-side=>"left");
			$T4->delete('0.0','end');
			$T4->insert('end','IBS Variance');
	my $out_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T5=$out_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T5->delete('0.0','end');
			$T5->insert('end','RelatenessCheckPlot.png');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .genome file\n");
															die "No .genome file: $!\n";
															}
												$output_text->insert('end', "$inpath opened\n"); #log
												print "$inpath opened\n";
												
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
												
												$output_text->insert('end', "Calculate the mean-variance pairs...\n"); #log
												print "Calculate the mean-variance pairs...\n";   #####log
												#------------------------------
												open(f2, $inpath);
												my $i=0; #number of mean-var pairs
												my $j=1; #number of mean-var pairs file
												my $y1=10; #plot region
												my $y2=0;
												my $x1=20;
												my $x2=0;
												mkdir("../ipgwastemp")||die"can not creat the temp directory: $!\n";
												open(f1,">../ipgwastemp/$j.txt")||die"can not creat the temp file $j: $!\n";
												<f2>; #title line
												while(<f2>)  #calculate the mean-var pairs
												{
												my @arry=split(/\s+/,$_); #ibs0, ibs1, ib2: $arry[15], $arry[16], $arry[17]
												my @pro;
												$pro[0]=$arry[15]/($arry[15]+$arry[16]+$arry[17]);
												$pro[1]=$arry[16]/($arry[15]+$arry[16]+$arry[17]);
												$pro[2]=$arry[17]/($arry[15]+$arry[16]+$arry[17]);

												my $mean=$pro[1]+2*$pro[2];
												print f1 "$mean\t";
												$x1=($mean<$x1 ? $mean : $x1);
												$x2=($mean>$x2 ? $mean : $x2);

												my $var=($pro[1]+4*$pro[2])-$mean**2;
												print f1 "$var\n";
												$y1=($var<$y1 ? $var : $y1);
												$y2=($var>$y2 ? $var : $y2);

												$i++;
													if(!($i%100000))  #every file cotain 100000 mean-variance pairs
													{
													close f1;
													$j++;
													open(f1,">../ipgwastemp/$j.txt")||die"can not creat the temp file $j: $!\n";
													}
												}
												close f1;
												close f2;

												print "Done\nThere are total $i mean-variance pairs\n"; #####log
												$output_text->insert('end', "Done\nThere are total $i mean-variance pairs\n"); #log
												print "The Min mean is $x1 and the Max mean is $x2\n";   #####log
												$output_text->insert('end', "The Min mean is $x1 and the Max mean is $x2\n"); #log
												print "The Min varance is $y1 and the Max varance is $y2\n"; #####log
												$output_text->insert('end',"The Min varance is $y1 and the Max varance is $y2\n");
												print "Plot the data...\n"; #####log
												$output_text->insert('end',"Plot the data...\n");
												
												#The plot region
												$x1-=0.1;
												$x2+=0.1;
												$y1-=0.1;
												$y2+=0.1;

												# Create chart object and specify the properties of the chart
													my $chart = Chart::Gnuplot->new(
														gnuplot => $gnuplot,   # for Windows, the address of gnuplot
														terminal => 'png',     # output format
														output => $outname,     # output name
														title  => $mytitle,
														xlabel => $myx,
														ylabel => $myy,
														xrange => [$x1, $x2],
														yrange => [$y1, $y2],
														imagesize => "1260, 689",
													);

												# Create dataset object and specify the properties of the dataset
												for(my $n=0;$n<$j;$n++)
												{
												my $t=$n+1;
													$datasets[$n] = Chart::Gnuplot::DataSet->new(
													datafile => "../ipgwastemp/$t.txt",
													style => "points", 
													color => "black",
													pointsize => "0.25",
													pointtype => "3", # *
													);
												}
													
												# Plot the data set on the chart
													$chart->plot2d(@datasets);
												# remove temp dir & temp file
												# print "Done\nDelete the temp files...\n";  #####log

												#delete temp files
												for(my $n=0;$n<$j;$n++)
												{
												my $t=$n+1;
												unlink("../ipgwastemp/$t.txt");
												}

												# print "Done\nDelete the temp dir...\n";  #####log

												#delete temp dir
												rmdir("../ipgwastemp");
												
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

##--------------------
sub identiDeviIBS
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("480x260");
$gp_win->title("Identify Closely Related Individual Pairs(by IBS)");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

my ($mean, $var)=(0,0);
my $input_path2;
#input frame
my $input_frames=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $genome_frame=$input_frames->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top"); # genome input
		$genome_frame->Label(-text => ".genome File")->pack(-side => "left");
		my $T1=$genome_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button1 = $genome_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['Genome files', '.genome'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
	my $imiss_frame=$input_frames->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top"); # imiss input
		$imiss_frame->Label(-text => ".imiss File")->pack(-side => "left");
		my $T2=$imiss_frame->Text(-height => 1, -width => 49)->pack(-side=>"left");
		my $browse_button2 = $imiss_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T2->delete('0.0', 'end');
																	$input_path2=$mw->getOpenFile(-filetypes=>[
																											['.imiss files', '.imiss'],
																											['All files', '*'],
																																					]);
																	$T2->insert('end', $input_path2);
																	}
													)->pack(-side => "left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
my $opt1_frame=$option_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
		my $cb1=$opt1_frame->Checkbutton(-text=>"mean cutoff:", -variable=>\$mean)->pack(-side => "left", -anchor=>'w');	
		my $text1=$opt1_frame->Text(-height => 1, -width => 53)->pack(-side=>'left');
		$text1->delete('0.0','end');
		
my $opt2_frame=$option_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
		my $cb2=$opt2_frame->Checkbutton(-text=>"variance cutoff:", -variable=>\$var)->pack(-side => "left", -anchor=>'w');
		my $text2=$opt2_frame->Text(-height => 1, -width => 51)->pack(-side=>'left');
		$text2->delete('0.0','end');
		
#output frame			
my $out_frame=$gp_win->LabFrame(-label=>"Output", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T3=$out_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end','closeRelatedPairs');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .genome file\n");
															die "No .genome file: $!\n";
															}
												$output_text->insert('end', "$inpath opened\n"); #log
												print "$inpath opened\n";
												
												my $inpath2=$T2->get('0.0', 'end');
												chomp $inpath2;
															if(! $inpath2)
															{
															$output_text->insert('end', "No .imiss file\n");
															die "No .imiss file: $!\n";
															}
												$output_text->insert('end', "$inpath2 opened\n"); #log
												print "$inpath2 opened\n";
												
												my($base,$dir,$ext)=fileparse($inpath,'\..*');
												
												my $mymean=$text1->get('0.0', 'end');
												$output_text->insert('end', "mean cutoff: $mymean"); #log
												chomp $mymean;
																							
												my $myvar=$text2->get('0.0', 'end');
												$output_text->insert('end', "variance cutoff: $myvar"); #log
												chomp $myvar;
												
												my $outpath=$T3->get('0.0', 'end');
												$output_text->insert('end', "output file: $outpath"); #log
												chomp $outpath;
												my $outlog="$dir$outpath.log";
												$outpath="$dir$outpath.txt";
												open(f9, ">$outlog");
												#------------------------------
												my %imiss;
												open(f1, $inpath2);
												<f1>;
												while(<f1>)
												{
												chomp;
												my @arr=split(/\s+/, $_);
												my $temp="$arr[1]$arr[2]";
												$imiss{$temp}=$arr[6];
												}
												close f1;
												#------------------------------
												open(f1, $inpath);
												open(f2, ">$outpath");
												print "\n\nFID1\tIID1\tFID2\tIID2\tMean\tVariance\n"; #log
												print f9 "\n\nFID1\tIID1\tFID2\tIID2\tMean\tVariance\n"; #log
												$output_text->insert('end', "\n\nFID1\tIID1\tFID2\tIID2\tMean\tVariance\n"); #log
												#----------------------------------
												my %individual;
												my $itemp;
												#---------------------------------
												<f1>; #title line
												while(<f1>)  #calculate the mean-var pairs
												{
												my @arry=split(/\s+/,$_); #ibs0, ibs1, ib2: $arry[15], $arry[16], $arry[17]
												my @pro;
												$pro[0]=$arry[15]/($arry[15]+$arry[16]+$arry[17]);
												$pro[1]=$arry[16]/($arry[15]+$arry[16]+$arry[17]);
												$pro[2]=$arry[17]/($arry[15]+$arry[16]+$arry[17]);

												my $means=$pro[1]+2*$pro[2];
											
												my $vars=($pro[1]+4*$pro[2])-$means**2;
												
												my $temp1="$arry[1]$arry[2]";
												my $temp2="$arry[3]$arry[4]";
												###############################################
													if($mean==1 && $var==1)
													{
														if($means > $mymean && $vars < $myvar)
														{
														print "$arry[1]\t$arry[2]\t$arry[3]\t$arry[4]\t$means\t$vars\n";             #log
														print f9 "$arry[1]\t$arry[2]\t$arry[3]\t$arry[4]\t$means\t$vars\n";             #log
														$output_text->insert('end', "$arry[1]\t$arry[2]\t$arry[3]\t$arry[4]\t$means\t$vars\n"); #log
															if($imiss{$temp1} > $imiss{$temp2})
															{
															# print f2 "$arry[1] $arry[2]\n";
																$itemp="$arry[1] $arry[2]";
																if(exists $individual{$itemp})
																{
																$individual{$itemp}++;
																}
																else
																{
																$individual{$itemp}=1;
																}
															#------------------------------------------
															print "$arry[1]\t$arry[2]\t should be removed\n\n";             #log
															print f9 "$arry[1]\t$arry[2]\t should be removed\n\n";             #log
															$output_text->insert('end', "$arry[1]\t$arry[2]\t should be removed\n\n"); #log
															}
															else
															{
															# print f2 "$arry[3] $arry[4]\n";
																$itemp="$arry[3] $arry[4]";
																if(exists $individual{$itemp})
																{
																$individual{$itemp}++;
																}
																else
																{
																$individual{$itemp}=1;
																}
															#------------------------------------------
															print "$arry[3]\t$arry[4]\t should be removed\n\n";             #log
															print f9 "$arry[3]\t$arry[4]\t should be removed\n\n";             #log
															$output_text->insert('end', "$arry[3]\t$arry[4]\t should be removed\n\n"); #log
															}
														}
													}
													elsif($mean==1 && $var==0)
													{
														if($means > $mymean)
														{
														print "$arry[1]\t$arry[2]\t$arry[3]\t$arry[4]\t$means\t$vars\n";             #log
														print f9 "$arry[1]\t$arry[2]\t$arry[3]\t$arry[4]\t$means\t$vars\n";             #log
														$output_text->insert('end', "$arry[1]\t$arry[2]\t$arry[3]\t$arry[4]\t$means\t$vars\n"); #log
															if($imiss{$temp1} > $imiss{$temp2})
															{
															# print f2 "$arry[1] $arry[2]\n";
																$itemp="$arry[1] $arry[2]";
																if(exists $individual{$itemp})
																{
																$individual{$itemp}++;
																}
																else
																{
																$individual{$itemp}=1;
																}
															#------------------------------------------
															print "$arry[1]\t$arry[2]\t should be removed\n\n";             #log
															print f9 "$arry[1]\t$arry[2]\t should be removed\n\n";             #log
															$output_text->insert('end', "$arry[1]\t$arry[2]\t should be removed\n\n"); #log
															}
															else
															{
															# print f2 "$arry[3] $arry[4]\n";
																$itemp="$arry[3] $arry[4]";
																if(exists $individual{$itemp})
																{
																$individual{$itemp}++;
																}
																else
																{
																$individual{$itemp}=1;
																}
															#------------------------------------------
															print "$arry[3]\t$arry[4]\t should be removed\n\n";             #log
															print f9 "$arry[3]\t$arry[4]\t should be removed\n\n";             #log
															$output_text->insert('end', "$arry[3]\t$arry[4]\t should be removed\n\n"); #log
															}
														}
													}
													elsif($mean==0 && $var==1)
													{
														if($vars < $myvar)
														{
														print "$arry[1]\t$arry[2]\t$arry[3]\t$arry[4]\t$means\t$vars\n";             #log
														print f9 "$arry[1]\t$arry[2]\t$arry[3]\t$arry[4]\t$means\t$vars\n";             #log
														$output_text->insert('end', "$arry[1]\t$arry[2]\t$arry[3]\t$arry[4]\t$means\t$vars\n"); #log
															if($imiss{$temp1} > $imiss{$temp2})
															{
															# print f2 "$arry[1] $arry[2]\n";
																$itemp="$arry[1] $arry[2]";
																if(exists $individual{$itemp})
																{
																$individual{$itemp}++;
																}
																else
																{
																$individual{$itemp}=1;
																}
															#------------------------------------------
															print "$arry[1]\t$arry[2]\t should be removed\n\n";             #log
															print f9 "$arry[1]\t$arry[2]\t should be removed\n\n";             #log
															$output_text->insert('end', "$arry[1]\t$arry[2]\t should be removed\n\n"); #log
															}
															else
															{
															# print f2 "$arry[3] $arry[4]\n";
																$itemp="$arry[3] $arry[4]";
																if(exists $individual{$itemp})
																{
																$individual{$itemp}++;
																}
																else
																{
																$individual{$itemp}=1;
																}
															#------------------------------------------
															print "$arry[3]\t$arry[4]\t should be removed\n\n";             #log
															print f9 "$arry[3]\t$arry[4]\t should be removed\n\n";             #log
															$output_text->insert('end', "$arry[3]\t$arry[4]\t should be removed\n\n"); #log
															}
														}
													}
													else
													{
													$output_text->insert('end', "please set the cutoff values\n"); #log
													die "please set the cutoff values\n";
													}
												}
												close f1;
												
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
##----------------------
sub identiDeviIBD
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("480x230");
$gp_win->title("Identify Closely Related Individual Pairs (by PI_HAT)");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

my $input_path2;
#input frame
my $input_frames=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $genome_frame=$input_frames->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top"); # genome input
		$genome_frame->Label(-text => ".genome File")->pack(-side => "left");
		my $T1=$genome_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button1 = $genome_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['Genome files', '.genome'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
	my $imiss_frame=$input_frames->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top"); # imiss input
		$imiss_frame->Label(-text => ".imiss File")->pack(-side => "left");
		my $T2=$imiss_frame->Text(-height => 1, -width => 49)->pack(-side=>"left");
		my $browse_button2 = $imiss_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T2->delete('0.0', 'end');
																	$input_path2=$mw->getOpenFile(-filetypes=>[
																											['.imiss files', '.imiss'],
																											['All files', '*'],
																																					]);
																	$T2->insert('end', $input_path2);
																	}
													)->pack(-side => "left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
my $opt1_frame=$option_frame->Frame()->pack(-side => "top");
		$opt1_frame->Label(-text=>"PI_HAT cutoff:")->pack(-side => "left", -anchor=>'w');	
		my $text1=$opt1_frame->Text(-height => 1, -width => 27)->pack(-side=>'left');
		$text1->delete('0.0','end');
		$text1->insert('end','0.1875');
		$opt1_frame->Label(-text => '(e.g. 0.5, 0.25, 0.1875, 0.125)')->pack(-side => "left");
		
#output frame			
my $out_frame=$gp_win->LabFrame(-label=>"Output", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T3=$out_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end','closeRelatedPairsPI_HAT');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .genome file\n");
															die "No .genome file: $!\n";
															}
												$output_text->insert('end', "$inpath opened\n"); #log
												print "$inpath opened\n";
												
												my $inpath2=$T2->get('0.0', 'end');
												chomp $inpath2;
															if(! $inpath2)
															{
															$output_text->insert('end', "No .imiss file\n");
															die "No .imiss file: $!\n";
															}
												$output_text->insert('end', "$inpath2 opened\n"); #log
												print "$inpath2 opened\n";
												
												my($base,$dir,$ext)=fileparse($inpath,'\..*');
												
												my $mymean=$text1->get('0.0', 'end');
												$output_text->insert('end', "PI_HAT cutoff: $mymean"); #log
												chomp $mymean;
																							
												my $outpath=$T3->get('0.0', 'end');
												$output_text->insert('end', "output file: $outpath"); #log
												chomp $outpath;
												my $outlog="$dir$outpath.log";
												$outpath="$dir$outpath.txt";
												open(f9, ">$outlog");
												#------------------------------
												my %imiss;
												open(f1, $inpath2);
												<f1>;
												while(<f1>)
												{
												chomp;
												my @arr=split(/\s+/, $_);
												my $temp="$arr[1]$arr[2]";
												$imiss{$temp}=$arr[6];
												}
												close f1;
												#------------------------------
												open(f1, $inpath);
												open(f2, ">$outpath");
												print "\n\nFID1\tIID1\tFID2\tIID2\tPI_HAT\n"; #log
												print f9 "\n\nFID1\tIID1\tFID2\tIID2\tPI_HAT\n"; #log
												$output_text->insert('end', "\n\nFID1\tIID1\tFID2\tIID2\tPI_HAT\n"); #log
												#----------------------------------
												my %individual;
												my $itemp;
												#---------------------------------
												<f1>; #title line
												while(<f1>)  
												{
												my @arry=split(/\s+/,$_); #PI_HAT: $arry[10]
												
												my $temp1="$arry[1]$arry[2]";
												my $temp2="$arry[3]$arry[4]";
												
													if($arry[10] > $mymean)
													{
														print "$arry[1]\t$arry[2]\t$arry[3]\t$arry[4]\t$arry[10]\n";             #log
														print f9 "$arry[1]\t$arry[2]\t$arry[3]\t$arry[4]\t$arry[10]\n";             #log
														$output_text->insert('end', "$arry[1]\t$arry[2]\t$arry[3]\t$arry[4]\t$arry[10]\n"); #log
																if($imiss{$temp1} > $imiss{$temp2})
																{
																$itemp="$arry[1] $arry[2]";
																	if(exists $individual{$itemp})  ##repeat delete
																	{
																	$individual{$itemp}++;
																	}
																	else
																	{
																	$individual{$itemp}=1;
																	}
																print "$arry[1]\t$arry[2]\t should be removed\n\n";             #log
																print f9 "$arry[1]\t$arry[2]\t should be removed\n\n";             #log
																$output_text->insert('end', "$arry[1]\t$arry[2]\t should be removed\n\n"); #log
																}
																else
																{
																$itemp="$arry[3] $arry[4]";
																	if(exists $individual{$itemp})
																	{
																	$individual{$itemp}++;
																	}
																	else
																	{
																	$individual{$itemp}=1;
																	}
																print "$arry[3]\t$arry[4]\t should be removed\n\n";             #log
																print f9 "$arry[3]\t$arry[4]\t should be removed\n\n";             #log
																$output_text->insert('end', "$arry[3]\t$arry[4]\t should be removed\n\n"); #log
																}
													}
												}
												close f1;
												
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
##---------------------------------------------------------------------
sub RelatednessPlot2
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("480x230");
$gp_win->title("Cryptic Relateness Plot (IBD)");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	$input_frame->Label(-text => ".genome File")->pack(-side => "left");
	my $T1=$input_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
	my $browse_button1 = $input_frame->Button(-text => 'Browse',
												-command => sub	{
																$T1->delete('0.0', 'end');
																$input_path=$mw->getOpenFile(-filetypes=>[
																										['.genome files', '.genome'],
																										['All files', '*'],
																																				]);
																$T1->insert('end', $input_path);
																}
												)->pack(-side => "left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Plot options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
	my $size_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$size_frame->Label(-text=>"Width ")->pack(-side=>'left');
		my $t5=$size_frame->Text(-height => 1, -width => 27)->pack(-side=>"left");
			$t5->delete('0.0','end');
			$t5->insert('end', '800');
		$size_frame->Label(-text=>" Height ")->pack(-side=>'left');
		my $t6=$size_frame->Text(-height => 1, -width => 26)->pack(-side=>"left");
			$t6->delete('0.0','end');
			$t6->insert('end', '600');
	my $title_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #title frame
		$title_frame->Label(-text=>"Tile     ")->pack(-side=>'left');
		my $T2=$title_frame->Text(-height => 1, -width => 60)->pack(-side=>"left");
			$T2->delete('0.0','end');
			$T2->insert('end','Histogram of pairwise IBD estimates');
	my $xlabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #X label frame
		$xlabel_frame->Label(-text=>"X label")->pack(-side=>'left');
		my $T3=$xlabel_frame->Text(-height => 1, -width => 60)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end','Pairwise estimated IBD');
	my $ylabel_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #Y label frame
		$ylabel_frame->Label(-text=>"Y label")->pack(-side=>'left');
		my $T4=$ylabel_frame->Text(-height => 1, -width => 60)->pack(-side=>"left");
			$T4->delete('0.0','end');
			$T4->insert('end','Count');
	my $out_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T5=$out_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T5->delete('0.0','end');
			$T5->insert('end','RelatenessCheckPlot.png');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .genome file\n");
															die "No .genome file: $!\n";
															}
																								
												$output_text->insert('end', "$inpath opened\n"); #log
												print "$inpath opened\n";
												
												my($base,$dir,$ext)=fileparse($inpath,'\..*');
																							
												#----------------------------------------
												#plot
												print "plotting...\n";
												my $width=$t5->get('0.0', 'end');
												$output_text->insert('end', "Width: $width"); #log
												chomp $width;
												
												my $height=$t6->get('0.0', 'end');
												$output_text->insert('end', "Height: $height"); #log
												chomp $height;
												
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
												
												open(f1, $inpath);
												my @data;
												my $n=0;
												
												<f1>; # first line
												while(<f1>) #read data
												{
												chomp;
												$_=~s/^\s+//;
												my @arr=split(/\s+/,$_);
												$data[$n++]=$arr[9];
												}
												close f1;
												#--------------------------------
												###plot
												
												 my $graph = new GD::Graph::histogram($width,$height);
												   $graph->set( 
																x_label         => $myx,
																y_label         => $myy,
																title           => $mytitle,
																x_labels_vertical => 1,
																bar_spacing     => 0,
																shadow_depth    => 1,
																shadowclr       => 'dred',
																transparent     => 0,
																histogram_type  => 'count', ##default count (also can be percentage)
																histogram_bins  => 50, ## default 50 bins
														) 
														or warn $graph->error;
														
														my $gd = $graph->plot(\@data) or die $graph->error;
														# my $gd = $graph->plot(\@test) or die $graph->error;
														open(IMG, ">$outname") or die $!;
														binmode IMG;
														print IMG $gd->png;
														close IMG;
																	
												#------------------------------
												
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}
##--------------------
1;
