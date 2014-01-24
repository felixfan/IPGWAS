package Convert::GWAMA;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;

sub PLINK2GWAMA
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";

my $ooo;
my $ok_frame;

$gp_win->geometry("450x150");
$gp_win->title("Convert PLINK Output to GWAMA Input Format");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $in1_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in1_frame->Label(-text => ".assoc File")->pack(-side => "left");
		my $T1=$in1_frame->Text(-height => 1, -width => 48)->pack(-side=>"left");
		my $browse_button1 = $in1_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['.assoc files', '.assoc'],
																											['.logistic files', '.logistic'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
	my $in2_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in2_frame->Label(-text => ".frq File  ")->pack(-side => "left");
		my $T2=$in2_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
		my $browse_button2 = $in2_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T2->delete('0.0', 'end');
																	$input_path2=$mw->getOpenFile(-filetypes=>[
																											['.frq files', '.frq'],
																											['All files', '*'],
																																					]);
																	$T2->insert('end', $input_path2);
																	}
													)->pack(-side => "left");
								
#output name frame
	my $out_frame=$gp_win->LabFrame(-label=>"Output File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T6=$out_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
			$T6->delete('0.0','end');
			
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												
												my $inputassoc=$T1->get('0.0', 'end');
												chomp $inputassoc;
												if($inputassoc)
												{
												$output_text->insert('end', "$inputassoc opened\n"); #log
												print "$inputassoc opened\n";
												}
												else
												{
												$output_text->insert('end', "Please specify the input assocation file\n"); #log
												die "Please specify the input assocation file\n";
												}
												
												my $inputfrq=$T2->get('0.0', 'end');
												chomp $inputfrq;
												if($inputfrq)
												{
												$output_text->insert('end', "$inputfrq opened\n"); #log
												print "$inputfrq opened\n";
												}
												else
												{
												$output_text->insert('end', "Please specify the input allele frequency file\n"); #log
												die "Please specify the input allele frequency file\n";
												}
												
												my($base,$dir,$ext)=fileparse($inputassoc,'\..*');
												
												my $outputfile;
												my $outname=$T6->get('0.0', 'end');
												chomp $outname;
												if($outname)
												{
												$outputfile="$dir$outname";
												$output_text->insert('end', "output: $outputfile\n"); #log
												}
												else
												{
												$output_text->insert('end', "Please specify the output file name\n"); #log
												die "Please specify the output file name\n";
												}
												
												print "Running...\n";
																								
												open F1, "$inputassoc" or die "Cannot file PLINK assoc file. This must be first command line argument!\n";
												open F2, "$inputfrq" or die "Cannot file PLINK frq file. This must be second command line argument!\n";
												if ($outputfile eq ""){die "Please enter the outputfile name as third command line argument!\n";}
												open O, ">$outputfile" or die "Cannot open $outputfile for writing. Please check folder's access rights and disk quota!\n";
												my $i=0;
												my %snp_ref;
												my @snp_ea;
												my @snp_nea;
												my @snp_eaf;
												my @snp_n;
												
												while(<F2>)
												{
													chomp;
													my @data = split(/\s+/);
													if ($i>0)
													{
														$snp_ref{$data[2]}=$i;
														$snp_ea[$i] = $data[3];
														$snp_nea[$i] = $data[4];
														$snp_eaf[$i] = $data[5];
														$snp_n[$i] = $data[6]/2;	
													}
													$i++;
												}
												$i=0;
												
												my ($locSNP, $locBETA, $locSE, $locOR, $locCIL, $locCIU);
												while(<F1>)
												{
													chomp;
													my @data = split(/\s+/);
													
													if ($i==0) 		# header line 
													{
														$locSNP=$locBETA=$locSE=$locOR=$locCIL=$locCIU=-1;
														for (my $j=0;$j<scalar(@data);$j++)
														{
															if ($data[$j] eq "SNP"){$locSNP=$j;}
															if ($data[$j] eq "BETA"){$locBETA=$j;}
															if ($data[$j] eq "SE"){$locSE=$j;}
															if ($data[$j] eq "OR"){$locOR=$j;}
															if ($data[$j] eq "L95"){$locCIL=$j;}
															if ($data[$j] eq "U95"){$locCIU=$j;}
														}

														if ($locOR>-1)
														{
															print "Using OR with CI output.\n";
															print O "MARKER\tEA\tNEA\tOR\tOR_95L\tOR_95U\tN\tEAF\tSTRAND\n";
														}
														else
														{
															print "Using BETA with SE output.\n";
															print O "MARKER\tEA\tNEA\tBETA\tSE\tN\tEAF\tSTRAND\n";
														}


													}
													if ($i>0) #snp line
													{
														my $marker = $data[2];
														my $loc = $snp_ref{$marker};
														if ($loc>0)
														{
															my $ea = $snp_ea[$loc];
															my $nea = $snp_nea[$loc];
															my ($beta, $se, $or, $or_95l, $or_95u);
															if ($locBETA>-1){$beta = $data[$locBETA];}
															if ($locSE>-1){$se = $data[$locSE];}
															if ($locOR>-1){$or = $data[$locOR];}
															if ($locCIL>-1){$or_95l = $data[$locCIL];}
															if ($locCIU>-1){$or_95u = $data[$locCIU];}
															my $n = $snp_n[$loc];
															my $eaf = $snp_eaf[$loc];
															my $strand = "+";
															if ($locOR>-1){print O "$marker\t$ea\t$nea\t$or\t$or_95l\t$or_95u\t$n\t$eaf\t$strand\n";}
															else {print O "$marker\t$ea\t$nea\t$beta\t$se\t$n\t$eaf\t$strand\n";}
														}
												 }
												 $i++;
												}
												close O;	
												$output_text->insert('end', "Done.\n");
												print "Done.\n";
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}
##-----------------------
sub SNPTEST2GWAMA
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";

my $ooo;
my $ok_frame;

my $n0=0;
my $maf0=0;
my $mac0=0;
my $proper0=0;
my $option="OR";

$gp_win->geometry("450x280");
$gp_win->title("Convert SNPTEST Outputs to GWAMA Input File");

$gp_win->resizable(0, 0);


my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $in1_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in1_frame->Label(-text => ".assoc File")->pack(-side => "left");
		my $T1=$in1_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button1 = $in1_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['.assoc files', '.assoc'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");											
#option frame
	my $opt_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
		my $opt0_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
			$opt0_frame->Radiobutton(-text=>"Case-Control(--OR)                                   ", -value=>"OR", -variable=>\$option)->pack(-side => "left", -anchor=>'w');
			$opt0_frame->Radiobutton(-text=>"Quantitative traits(--SE)                            ", -value=>"SE", -variable=>\$option)->pack(-side => "left", -anchor=>'w');
		my $opt1_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
			my $cb1=$opt1_frame->Checkbutton(-text=>"--N", -variable=>\$n0)->pack(-side => "left", -anchor=>'w');	
				my $text1=$opt1_frame->Text(-height => 1, -width => 57)->pack(-side=>'left');
		my $opt2_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
			my $cb2=$opt2_frame->Checkbutton(-text=>"--MAF", -variable=>\$maf0)->pack(-side => "left", -anchor=>'w');
				my $text2=$opt2_frame->Text(-height => 1, -width => 55)->pack(-side=>'left');
		my $opt3_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
			my $cb3=$opt3_frame->Checkbutton(-text=>"--MAC", -variable=>\$mac0)->pack(-side => "left", -anchor=>'w');
				my $text3=$opt3_frame->Text(-height => 1, -width => 55)->pack(-side=>'left');
		my $opt4_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
			my $cb4=$opt4_frame->Checkbutton(-text=>"--PROPER", -variable=>\$proper0)->pack(-side => "left", -anchor=>'w');
				my $text4=$opt4_frame->Text(-height => 1, -width => 52)->pack(-side=>'left');			
#output name frame
	my $out_frame=$gp_win->LabFrame(-label=>"Output File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T6=$out_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
			$T6->delete('0.0','end');
			
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inputfile=$T1->get('0.0', 'end');
												chomp $inputfile;
												if($inputfile)
												{
												$output_text->insert('end', "$inputfile opened\n"); #log
												print "$inputfile opened\n";
												}
												else
												{
												$output_text->insert('end', "Please specify the input file\n"); #log
												die "Please specify the input file\n";
												}
												
												
												my($base,$dir,$ext)=fileparse($inputfile,'\..*');
												
												my $outputfile;
												my $outname=$T6->get('0.0', 'end');
												chomp $outname;
												if($outname)
												{
												$outputfile="$dir$outname";
												$output_text->insert('end', "output: $outputfile"); #log
												}
												else
												{
												$output_text->insert('end', "Please specify the output file name\n"); #log
												die "Please specify the output file name\n";
												}
												
												my $scheme = $option;
												
												my $N=$text1->get('0.0', 'end');
												chomp $N;
												my $MAF=$text1->get('0.0', 'end');
												chomp $MAF;
												my $MAC=$text1->get('0.0', 'end');
												chomp $MAC;
												my $PROPER=$text1->get('0.0', 'end');
												chomp $PROPER;
												
												print "Running...\n";
												
												my $cMAF=0;
												my $cMAC=0;
												my $cN=0;
												my $cPROPER=0;
												
												
												if ($n0==1 && $N>0){print "N cut-off $N\n"; $cN=$N; $output_text->insert('end', "N cut-off $N\n");}
												if ($mac0==1 && $MAC>0){print "MAC cut-off $MAC\n"; $cMAC=$MAC; $output_text->insert('end', "MAC cut-off $MAC\n");}
												if ($maf0==1 && $MAF>0){print "MAF cut-off $MAF\n"; $cMAF=$MAF; $output_text->insert('end', "MAF cut-off $MAF\n");}
												if ($proper0==1 && $PROPER>0){print "PROPERINFO cut-off $PROPER\n"; $cPROPER=$PROPER; $output_text->insert('end', "PROPERINFO cut-off $PROPER\n");}
												
												open F, "$inputfile" or die "Cannot file SNPTEST file. This must be first command line argument!\n";
												if ($outputfile eq ""){die "Please enter the outputfile name as second command line argument!\n";}
												open O, ">$outputfile" or die "Cannot open $outputfile for writing. Please check folder's access rights and disk quota!\n";
												if ($scheme eq "OR")
												{
													print "Using OR with CI output.\n";
													print O "MARKER\tEA\tNEA\tOR\tOR_95L\tOR_95U\tN\tEAF\tSTRAND\tIMPUTED\n";
												}
												else 
												{
													print "Using BETA with SE output.\n";
													print O "MARKER\tEA\tNEA\tBETA\tSE\tN\tEAF\tSTRAND\tIMPUTED\n";
												}
												my $i=0;
												my ($locAA, $locAB, $locBB);
												while(<F>)
												{
													chomp;
													my @data = split(/\s/);
													if ($i==0)	#header line
													{
														$locAA=$locAB=$locBB=0;
														for (my $j=0;$j<scalar(@data); $j++)
														{
															if ($data[$j] eq "all_AA"){$locAA=$j;}
															if ($data[$j] eq "all_AB"){$locAB=$j;}
															if ($data[$j] eq "all_BB"){$locBB=$j;}
														}
													}
													else		#snp line
													{
														my $marker = $data[1];
														my $ea = $data[4];
														my $nea = $data[3];
														my $beta = $data[scalar(@data)-2];
														my $se = $data[scalar(@data)-1];
														my $proper = $data[scalar(@data)-3];
														my $or = exp($beta);
														my $or_95l = exp($beta - 1.96* $se);
														my $or_95u = exp($beta + 1.96* $se);
														my $n = $data[$locAA]+$data[$locAB]+$data[$locBB];
														my $eaf;
														if (($data[$locAA]+$data[$locAB]+$data[$locBB])>0){$eaf = ((2*$data[$locBB])+$data[$locAB])/(2*($data[$locAA]+$data[$locAB]+$data[$locBB]));}
														else {$eaf =0;}
														my $maf;
														if ($eaf>0.5){$maf = 1-$eaf;}
														else {$maf=$eaf;}
														my $strand = "+";
														my $imp;
														if ($data[0] eq "---"){$imp=1;}else{$imp=0;}
														
														if ($cMAF > $maf || $cMAC>$maf*$n || $cN>$n || $cPROPER>$proper)
														{
														}
														else
														{
															if ($scheme eq "OR"){print O "$marker\t$ea\t$nea\t$or\t$or_95l\t$or_95u\t$n\t$eaf\t$strand\t$imp\n";}
															else {print O "$marker\t$ea\t$nea\t$beta\t$se\t$n\t$eaf\t$strand\t$imp\n";}
														}
													}
													$i++;
												}
												close O;
												$output_text->insert('end', "Done.\n");
												print "Done.\n";
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}
1;
