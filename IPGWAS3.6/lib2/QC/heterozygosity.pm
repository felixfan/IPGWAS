package QC::heterozygosity;

use warnings;
use strict;

# use GD::Graph::histogram;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;

sub hetInbreeding
{
my($output_text, $mw, $gp_win, $gnuplot)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;
my $option="F";

$gp_win->geometry("480x200");
$gp_win->title("Heterozygosity and Inbreeding");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	$input_frame->Label(-text => ".het File")->pack(-side => "left");
	my $T1=$input_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
	my $browse_button1 = $input_frame->Button(-text => 'Browse',
												-command => sub	{
																$T1->delete('0.0', 'end');
																$input_path=$mw->getOpenFile(-filetypes=>[
																										['.het files', '.het'],
																										['All files', '*'],
																																				]);
																$T1->insert('end', $input_path);
																}
												)->pack(-side => "left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
	my $opt_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		my $radio1=$opt_frame->Radiobutton(-text=>"Inbreeding coefficient estimate F", -value=>"F", -variable=>\$option)->pack(-side => "left", -anchor=>'w');
		my $radio2=$opt_frame->Radiobutton(-text=>"Heterozygosity H", -value=>"H", -variable=>\$option)->pack(-side => "left", -anchor=>'w');
	my $size_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$size_frame->Label(-text=>"Width")->pack(-side=>'left');
		my $T2=$size_frame->Text(-height => 1, -width => 27)->pack(-side=>"left");
			$T2->delete('0.0','end');
			$T2->insert('end', '600');
		$size_frame->Label(-text=>"Height")->pack(-side=>'left');
		my $T3=$size_frame->Text(-height => 1, -width => 26)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end', '800');
	my $out_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T5=$out_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T5->delete('0.0','end');
			$T5->insert('end', 'hetInbreeding.png');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .het file\n");
															die "No .het file: $!\n";
															}
												$output_text->insert('end', "$inpath opend\n"); #log
												my($base,$dir,$ext)=fileparse($inpath,'\..*');
												
												my $width=$T2->get('0.0', 'end');
												chomp $width;
												
												my $height=$T3->get('0.0', 'end');
												chomp $height;
												
												my $outname=$T5->get('0.0', 'end');
												chomp $outname;
												if($outname=~/.png$/)
												{
												$outname="$dir$outname";
												}
												else
												{
												$outname="$dir$outname.png";
												}
												
												$output_text->insert('end', "output: $outname\n"); #log
												$output_text->insert('end', "Plotting...\n"); #log
												#------------------------------
												
												open(f1, $inpath);
												my @f;
												my @h;
												my $n=0;
												
												my $dmin=99999999;
												my $dmax=-99999999;
												my $nx=0;
												my $int=50; #default 50 histo
												
												<f1>; # first line
												while(<f1>) #read data
												{
												chomp;
												$_=~s/^\s+//;
												my @arr=split(/\s+/,$_);
													if($option eq "F")
													{
													$f[$n]=$arr[5];
														if($f[$n] <= $dmin)
														{
														$dmin=$f[$n];
														}
														elsif($f[$n] >= $dmax)
														{
														$dmax=$f[$n];
														}
													}
													else
													{
													$h[$n]=($arr[4]-$arr[2])/$arr[4];
														if($h[$n] <= $dmin)
														{
														$dmin=$h[$n];
														}
														elsif($h[$n] >= $dmax)
														{
														$dmax=$h[$n];
														}
													}
												$n++; # individual index
												}
												close f1;
												
												$nx=$n;
												my $jmax=($dmax-$dmin)/$int;
												
												my @cmin;
												my @cmax;
												my @cmid;

												for(my $j=0; $j<=$int; $j++)
												{
												$cmin[$j]=$dmin+$j*$jmax;
												$cmax[$j]=$cmin[$j]+$jmax;
												$cmid[$j]=($cmin[$j]+$cmax[$j])/2;
												}
												
												my $title;
												my $xtitle;
												my @data;
												
												if($option eq "F")
												{
												$title="Histogram of F";
												$xtitle="F";
												@data=@f;
												}
												else
												{
												$title="Histogram of H";
												$xtitle="H";
												@data=@h;
												}
												########
												my @z; #data to plot
												
												for(my $x=0;$x<$int;$x++)
												{
												$z[$x]=0;
												}

												for(my $p=0; $p<$nx; $p++)
												{
													for(my $q=0; $q<=$int; $q++)
													{
														if($data[$p]>=$cmin[$q] && $data[$p]<$cmax[$q])
														{
														$z[$q]++;
														last;
														}
													}
												}
												########
												my $mydata="het_data.txt"; # default data file name
												$mydata="$dir$mydata";
												open(f00, ">$mydata");
												
												for(my $x=0;$x<=$int;$x++)
												{
												print f00 "$cmid[$x] $z[$x]\n";
												}
												close f00;
												
												####gnuplot file
												my $gnuplotfile="het_gnuplot.txt";
												$gnuplotfile="$dir$gnuplotfile";
												open(f0, ">$gnuplotfile");
												print f0 'set terminal png medium size '.$width.', '.$height;
												print f0 "\n";
												print f0 'set output "'.$outname.'"';
												print f0 "\n";
												print f0 'set title "'.$title.'"';
												print f0 "\n";
												print f0 'set boxwidth 0.75 relative';
												print f0 "\n";
												print f0 'set style data histograms';
												print f0 "\n";
												print f0 'set style histogram cluster gap 0';
												print f0 "\n";
												print f0 'set style fill solid 1.00 border -1';
												print f0 "\n";
												print f0 'set xtic rotate by -90 scale 0';
												print f0 "\n";
												print f0 'set ylabel "Count"';
												print f0 "\n";
												print f0 'set xlabel "'.$xtitle.'"';
												print f0 "\n";
												print f0 'set xtics (';
												
												$cmid[0]=int(1000*$cmid[0])/1000; #default 3
												print f0 '"'.$cmid[0].'"'." 1";
												for(my $t=1; $t<=$int; $t++)
												{
												my $s=$t+1;
												$cmid[$t]=int(1000*$cmid[$t])/1000; #default 3
												print f0 ', "'.$cmid[$t].'"'." ".$s;
												}
												print f0 ")\n";

												print f0 'plot "'.$mydata.'" using 2 t ""';
												print f0 "\n";
												close f0;
												###########
												system("$gnuplot $gnuplotfile");
												############
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

}
#--------------------------------------
sub identiDeviHF
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("480x225");
$gp_win->title("Identify Individuals Departure from Expected Heterozygosity");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

my $HF="";

#input frame
my $input_frames=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $genome_frame=$input_frames->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top"); # genome input
		$genome_frame->Label(-text => ".het File")->pack(-side => "left");
		my $T1=$genome_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button1 = $genome_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['.het files', '.het'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
my $opt1_frame=$option_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
		my $cb1=$opt1_frame->Radiobutton(-text=>"F cutoff", -value=>"F", -variable=>\$HF)->pack(-side => "left", -anchor=>'w');
		$opt1_frame->Label(-text=>"Min:")->pack(-side=>'left');
		my $text1=$opt1_frame->Text(-height => 1, -width => 24)->pack(-side=>'left');
		$text1->delete('0.0','end');
		$opt1_frame->Label(-text=>"Max:")->pack(-side=>'left');
		my $text11=$opt1_frame->Text(-height => 1, -width => 23)->pack(-side=>'left');
		$text11->delete('0.0','end');
		
my $opt2_frame=$option_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
		my $cb2=$opt2_frame->Radiobutton(-text=>"H cutoff", -value=>"H", -variable=>\$HF)->pack(-side => "left", -anchor=>'w');
		$opt2_frame->Label(-text=>"Min:")->pack(-side=>'left');
		my $text2=$opt2_frame->Text(-height => 1, -width => 24)->pack(-side=>'left');
		$text2->delete('0.0','end');
		$opt2_frame->Label(-text=>"Max:")->pack(-side=>'left');
		my $text22=$opt2_frame->Text(-height => 1, -width => 23)->pack(-side=>'left');
		$text22->delete('0.0','end');
#output frame			
my $out_frame=$gp_win->LabFrame(-label=>"Output", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T3=$out_frame->Text(-height => 1, -width => 53)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end','DepartIndividuals');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .het file\n");
															die "No .het file: $!\n";
															}
												$output_text->insert('end', "$inpath opened\n"); #log
												print "$inpath opened\n";
												
												my($base,$dir,$ext)=fileparse($inpath,'\..*');
												
												my $minF=$text1->get('0.0', 'end');
												my $maxF=$text11->get('0.0', 'end');
												chomp $minF;
												chomp $maxF;
												
												$output_text->insert('end', "F cutoff:\nmin: $minF max: $maxF\n"); #log
																							
												my $minH=$text2->get('0.0', 'end');
												my $maxH=$text22->get('0.0', 'end');
												chomp $minH;
												chomp $maxH;
												
												$output_text->insert('end', "H cutoff:\nmin: $minH max: $maxH\n"); #log
												
												my $outpath=$T3->get('0.0', 'end');
												
												chomp $outpath;
												
												if($outpath =~/.txt$/)
												{
												$outpath="$dir$outpath";
												}
												else
												{
												$outpath="$dir$outpath.txt";
												}
												
												$output_text->insert('end', "output file: $outpath\n"); #log
												open(f8, ">$outpath");
												
												#------------------------------
												my %Fv;
												my %Hv;
												my $nnn=0;
												open(f1, $inpath);
												<f1>;
												while(<f1>)
												{
												chomp;
												my @arr=split(/\s+/, $_);
												my $id="$arr[1] $arr[2]";
												$Fv{$id}=$arr[6];
												$Hv{$id}=($arr[5]-$arr[3])/$arr[5];
												}
												close f1;
												#------------------------------
												if($HF eq "F")
												{
													if($minF && $maxF)
													{
														foreach my $key (keys %Fv)
														{
															if($Fv{$key} >= $maxF || $Fv{$key} <= $minF)
															{
															print f8 "$key\n";
															$nnn++;
															}
														}
													}
													elsif($minF)
													{
														foreach my $key (keys %Fv)
														{
															if($Fv{$key} <= $minF)
															{
															print f8 "$key\n";
															$nnn++;
															}
														}
													}
													elsif($maxF)
													{
														foreach my $key (keys %Fv)
														{
															if($Fv{$key} >= $maxF)
															{
															print f8 "$key\n";
															$nnn++;
															}
														}
													}
													else
													{
													die "Please specify the min and/or max cutoff of F\n";
													}
												}
												elsif($HF eq "H")
												{
													if($minH && $maxH)
													{
														foreach my $key (keys %Hv)
														{
															if($Hv{$key} >= $maxH || $Hv{$key} <= $minH)
															{
															print f8 "$key\n";
															$nnn++;
															}
														}
													}
													elsif($minH)
													{
														foreach my $key (keys %Hv)
														{
															if($Hv{$key} <= $minH)
															{
															print f8 "$key\n";
															$nnn++;
															}
														}
													}
													elsif($maxH)
													{
														foreach my $key (keys %Hv)
														{
															if($Hv{$key} >= $maxH)
															{
															print f8 "$key\n";
															$nnn++;
															}
														}
													}
													else
													{
													die "Please specify the min and/or max cutoff of H\n";
													}
												}
												else
												{
												die "Please select F and/or H as cutoff.\n";
												}
												###############################################
													
												close f8;
												
												$output_text->insert('end', "There are $nnn individuals should be removed\nDone.\n"); #log	
												print "There are $nnn individuals should be removed\nDone.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}
1;
