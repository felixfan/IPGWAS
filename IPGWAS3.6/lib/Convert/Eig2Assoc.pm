package Convert::Eig2Assoc;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;
use Statistics::Distributions qw (chisqrprob);

sub EigFormat2AssocFormat
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";
my $ooo;
my $ok_frame;

$gp_win->geometry("450x150");
$gp_win->title("Convert Eigenstrat Output");

$gp_win->resizable(0, 0);


my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $in1_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in1_frame->Label(-text => ".chisq File")->pack(-side => "left");
		my $T1=$in1_frame->Text(-height => 1, -width => 48)->pack(-side=>"left");
		my $browse_button1 = $in1_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['.chisq files', '.chisq'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
	my $in2_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in2_frame->Label(-text => ".snp File   ")->pack(-side => "left");
		my $T2=$in2_frame->Text(-height => 1, -width => 48)->pack(-side=>"left");
		my $browse_button2 = $in2_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T2->delete('0.0', 'end');
																	$input_path2=$mw->getOpenFile(-filetypes=>[
																											['.snp files', '.snp'],
																											['All files', '*'],
																																					]);
																	$T2->insert('end', $input_path2);
																	}
													)->pack(-side => "left");
#output name frame
	my $out_frame=$gp_win->LabFrame(-label=>"Output File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T3=$out_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
			$T3->delete('0.0','end');
			# $T3->insert('end','test-eig.assoc');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $eigen=$T1->get('0.0', 'end');
												chomp $eigen;
												$output_text->insert('end', "$eigen opened\n"); #log
												print "$eigen opened\n";
												
												my $snpFile=$T2->get('0.0', 'end');
												chomp $snpFile;
												$output_text->insert('end', "$snpFile opened\n"); #log
												print "$snpFile opened\n";
												
												my($base,$dir,$ext)=fileparse($eigen,'\..*');
												
												my $outname=$T3->get('0.0', 'end');
												$output_text->insert('end', "output: $dir$outname"); #log
												chomp $outname;
												$outname="$dir$outname.assoc";
																							
												$output_text->insert('end', "Formatting...\n"); #log
												print "Formatting...\n";
												#------------------------------
												open(EIGEN, $eigen) || die ("cannot open $eigen: $!\n");
												open(SNP, $snpFile) || die ("cannot open $snpFile: $!\n");
												open(OUTEIGEN, ">$outname") || die ("cannot write new file $outname: $!\n");

												# print header
												print OUTEIGEN "CHR\tSNP\tBP\tA1\tA2\tArmitage_CHISQ\tArmitage_P\tEIGENSTRAT_CHISQ\tEIGENSTRAT_P\n";
												
												#A1: reference allele
												#A2: variant allele
												
												my $count = 0;
												while (<EIGEN>){	
													chomp $_;
													next if (!$_ || /-/ || /eigenstrat/i );
													
													# process statistics
													my ($b4, $after) = split(/\s+/, $_);
													my $b4P = $b4 ne "NA" ? chisqrprob(1, $b4) : "NA";
													my $afterP = $after ne "NA" ? chisqrprob(1, $after) : "NA";
													
													# processing marker info.
													my $snpLine = <SNP>;
													chomp($snpLine);
													if (!$snpLine){
														print "Error, .snp file is SHORTER than .chisq file! Check file consistency.\n";
														exit;
													}
													my ($snp, $chr, $null, $pos, $a1, $a2) = split(" ", $snpLine);
													
													print OUTEIGEN "$chr\t$snp\t$pos\t$a1\t$a2\t$b4\t$b4P\t$after\t$afterP\n";
													$count++;
												}

												my $snpLine = <SNP>;
												if (defined($snpLine)){
													print "Error, snp file is LONGER than results file! Check file consistency.\n";
													exit;
												}

												# check of snpLine is null

												close EIGEN;
												close SNP;
												close OUTEIGEN;

												print "$count markers coverted.\n";
												print "Done.\n";												
												$output_text->insert('end', "$count markers coverted.\nDone.\n"); #log	
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}
1;
