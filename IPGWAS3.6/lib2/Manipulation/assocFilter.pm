package Manipulation::assocFilter;

use warnings;
use strict;

use Chart::Gnuplot;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;


sub assocFilters
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

my $option="p";

$gp_win->geometry("560x380");
$gp_win->title("Association Result Filter");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $inframe1=$input_frame->Frame()->pack(-side => "top");
		$inframe1->Label(-text => ".assoc File          ")->pack(-side => "left");
		my $T1=$inframe1->Text(-height => 1, -width => 52)->pack(-side=>"left");
		$inframe1->Button(-text => 'Browse',
							-command => sub	{
											$T1->delete('0.0', 'end');
											$input_path=$mw->getOpenFile(-filetypes=>[
																						['Association files', '.assoc'],
																						['All files', '*'],
																					]);
											$T1->insert('end', $input_path);
											}
						)->pack(-side => "left");
my $chr_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$chr_frame->Label(-text=>"Chromosome:      ")->pack(-side=>'left');
		my $T99=$chr_frame->Text(-height => 1, -width => 63)->pack(-side=>"left");
		$T99->delete('0.0','end');
		$T99->insert('end','CHR');
my $bp_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$bp_frame->Label(-text=>"Physical position:")->pack(-side=>'left');
		my $T98=$bp_frame->Text(-height => 1, -width => 63)->pack(-side=>"left");
		$T98->delete('0.0','end');
		$T98->insert('end','BP');
my $p_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$p_frame->Label(-text=>"P value:              ")->pack(-side=>'left');
		my $T97=$p_frame->Text(-height => 1, -width => 63)->pack(-side=>"left");
		$T97->delete('0.0','end');
		$T97->insert('end','P');
		
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
	my $p1_frame=$option_frame->LabFrame(-label=>"")->pack(-side=>"top", -anchor=>'w'); #only p frame
		$p1_frame->Radiobutton(-text=>"by P Value:", -value=>"p", -variable=>\$option)->pack(-side => "left");
		$p1_frame->Label(-text=>"P Value Less Than:")->pack(-side=>'left');
		my $T001=$p1_frame->Text(-height => 1, -width => 13)->pack(-side=>"left");
		$T001->delete('0.0','end');
		$T001->insert('end','1');
		$p1_frame->Label(-text=>"& P Value More Than:")->pack(-side=>'left');
		my $T002=$p1_frame->Text(-height => 1, -width => 13)->pack(-side=>"left");
		$T002->delete('0.0','end');
		$T002->insert('end','0');
	my $pbp_frame=$option_frame->LabFrame(-label=>"")->pack(-side=>"top", -anchor=>'w'); #p & bp frame
		$pbp_frame->Radiobutton(-text=>"Remove Singleton Significant SNP", -value=>"pbp", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
		$pbp_frame->Label(-text=>"P Value Less Than:")->pack(-side=>'left');
		my $T003=$pbp_frame->Text(-height => 1, -width => 12)->pack(-side=>"left");
		$T003->delete('0.0','end');
		$T003->insert('end','0.00001');
		$pbp_frame->Label(-text=>"within +/-(kb)")->pack(-side=>'left');
		my $T004=$pbp_frame->Text(-height => 1, -width => 8)->pack(-side=>"left");
		$T004->delete('0.0','end');
		$T004->insert('end','200');
		$pbp_frame->Label(-text=>"P Value Less Than:")->pack(-side=>'left');
		my $T005=$pbp_frame->Text(-height => 1, -width => 10)->pack(-side=>"left");
		$T005->delete('0.0','end');
		$T005->insert('end','0.001');
	### out
	my $out_frame=$gp_win->LabFrame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name    ")->pack(-side=>'left');
		my $T5=$out_frame->Text(-height => 1, -width => 60)->pack(-side=>"left");
			$T5->delete('0.0','end');
			$T5->insert('end','');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .assoc file\n");
															die "No .assoc file: $!\n";
															}
												$output_text->insert('end', "$inpath opened\n"); #log
												print "$inpath opened\n";
												
												my($base,$dir,$ext)=fileparse($inpath,'\..*');
												
												my $outname=$T5->get('0.0', 'end');
												$output_text->insert('end', "output: $dir$outname"); #log
												chomp $outname;
												$outname="$dir$outname";
												
												
												###------------------------------
												$output_text->insert('end', "Reading data from: [$inpath]\n"); #log
												print "Reading data from: [$inpath]\n";
												
												my $chrname=$T99->get('0.0','end');
												chomp $chrname;
												my $chrcol=0;
												
												my $bpname=$T98->get('0.0','end');
												chomp $bpname;
												my $bpcol=0;
												
												my $pname=$T97->get('0.0','end');
												chomp $pname;
												my $pcol=0;
												
												my ($pmin, $pmax, $plen);
												
												if($option eq "p")
												{
												$pmin=$T001->get('0.0','end');
												$pmax=$T002->get('0.0','end');
												chomp $pmin;
												chomp $pmax;
												print "Only output SNPs with p value less than $pmin and more than $pmax\n";
												$output_text->insert('end', "Only output SNPs with p value less than $pmin and more than $pmax\n"); #log
												print "writing results to \[$outname\]\n";
												$output_text->insert('end', "writing results to \[$outname\]\n"); #log
													open(f0, ">$outname");
													
													open(f1, $inpath);
													
													while(<f1>)
													{
													chomp;
													$_=~s/^\s+//;
														if($_=~/$chrname/)
														{
														$_=~s/^\s+//;
														my @arr=split(/\s+/,$_);
														my $pflag=0;
														my $chrflag=0;
														my $bpflag=0;
															for(my $i=0; $i<=$#arr; $i++)
															{
																if($arr[$i] eq $pname)
																{
																$pcol=$i;
																$pflag=1;
																}
																if($arr[$i] eq $chrname)
																{
																$chrcol=$i;
																$chrflag=1;
																}
																if($arr[$i] eq $bpname)
																{
																$bpcol=$i;
																$bpflag=1;
																}
															}
															###check name
															
															if($pflag==0)
															{
															die "please specify the column name of P value\n";
															}
															if($chrflag==0)
															{
															die "please specify the column name of chromosome\n";
															}
															if($bpflag==0)
															{
															die "please specify the column name of physical position\n";
															}
														print f0 "$_\n";
														}
														else
														{
														$_=~s/^\s+//;
														my @arr=split(/\s+/, $_);
															
															if($arr[$pcol]=~/[0-9]/ && $arr[$pcol]<$pmin && $arr[$pcol]>$pmax)
															{
															print f0 "$_\n";
															}
														}
													}
													close f1;
													close f0;
												}
												else
												{
												$pmin=$T003->get('0.0','end');
												$pmax=$T005->get('0.0','end');
												$plen=$T004->get('0.0','end');
												chomp $pmin;
												chomp $pmax;
												chomp $plen;
												$plen*=1000;
												print "Singleton significant SNPs will be removed\n";
												print "Singleton significant SNPs was defined as:\n";
												print "P value less than $pmin, but there are no SNPs with p value less than $pmax within $plen bp\n";
												print "writing results to \[$outname\]\n";
												$output_text->insert('end', "Singleton significant SNPs will be removed\nSingleton significant SNPs was defined as:\nP value less than $pmin, but there are no SNPs with p value less than $pmax within $plen bp\nwriting results to \[$outname\]\n"); #log
												my %pinfo;
													open(f1, $inpath);
													open(f0, ">$outname");
													while(<f1>)
													{
													chomp;
													$_=~s/^\s+//;
														if($_=~/$chrname/)
														{
														$_=~s/^\s+//;
														my @arr=split(/\s+/,$_);
														my $pflag=0;
														my $chrflag=0;
														my $bpflag=0;
															for(my $i=0; $i<=$#arr; $i++)
															{
																if($arr[$i] eq $pname)
																{
																$pcol=$i;
																$pflag=1;
																}
																if($arr[$i] eq $chrname)
																{
																$chrcol=$i;
																$chrflag=1;
																}
																if($arr[$i] eq $bpname)
																{
																$bpcol=$i;
																$bpflag=1;
																}
															}
															###check name
															
															if($pflag==0)
															{
															die "please specify the column name of P value\n";
															}
															if($chrflag==0)
															{
															die "please specify the column name of chromosome\n";
															}
															if($bpflag==0)
															{
															die "please specify the column name of physical position\n";
															}
														
														}
														else
														{
														$_=~s/^\s+//;
														my @arr=split(/\s+/, $_);
														$pinfo{$arr[$chrcol]}{$arr[$bpcol]}=$arr[$pcol];
														}
													}
													close f1;
													
													open(f1, $inpath);
													while(<f1>)
													{
													chomp;
													$_=~s/^\s+//;
														if($_!~/^$chrname/)
														{
														my @arr=split(/\s+/, $_);
															if($arr[$pcol] =~/NA/)
															{
															;
															}
															elsif($arr[$pcol] < $pmin)
															{
															my $flag=0;
															my $min=$arr[$bpcol]-$plen;
															my $max=$arr[$bpcol]+$plen;
																foreach my $bp (sort keys %{$pinfo{$arr[$chrcol]}})
																{
																	if($pinfo{$arr[$chrcol]}{$bp} !~/NA/ && $pinfo{$arr[$chrcol]}{$bp} < $pmax && $bp > $min && $bp < $max && $bp != $arr[$bpcol])
																	{
																	$flag=1;
																	last;
																	}
																}
																
																if($flag==1)
																{
																$flag=0;
																print f0 "$_\n";
																}
															}
															else
															{
															print f0 "$_\n";
															}
														}
														else
														{
														print f0 "$_\n";
														}
													}
													close f1;	
													close f0;
												}
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

1;
