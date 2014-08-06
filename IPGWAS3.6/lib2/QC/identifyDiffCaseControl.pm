package QC::identifyDiffCaseControl;

use warnings;
use strict;

use File::Basename;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

sub identifyInforMissing
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("480x210");
$gp_win->title("Investigate Informative Missingness");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);
my $pval="p";

#input frame
my $input_frames=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $genome_frame=$input_frames->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top"); # genome input
		$genome_frame->Label(-text => ".missing File")->pack(-side => "left");
		my $T1=$genome_frame->Text(-height => 1, -width => 43)->pack(-side=>"left");
							$genome_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['.missing files', '.missing'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
	
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
my $opt1_frame=$option_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side => "top");
		$opt1_frame->Radiobutton(-text=>"p value cutoff:", -value=> "p", -variable=>\$pval)->pack(-side => "left", -anchor=>'w');	
		my $text1=$opt1_frame->Text(-height => 1, -width => 49)->pack(-side=>'left');
		$text1->delete('0.0','end');
		$text1->insert('end', '0.00001');
#output frame			
my $out_frame=$gp_win->LabFrame(-label=>"Output", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T3=$out_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end','diffmissSNPs.txt');
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $inpath=$T1->get('0.0', 'end');
												chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .missing file\n");
															die "No .missing file: $!\n";
															}
												$output_text->insert('end', "$inpath opened\n"); #log
												print "$inpath opened\n";
												
												my($base,$dir,$ext)=fileparse($inpath,'\..*');
												
												my $myp=$text1->get('0.0', 'end');
												$output_text->insert('end', "p value cutoff: $myp"); #log
												print "p value cutoff: $myp";
												chomp $myp;
												
												my $outpath=$T3->get('0.0', 'end');
												$output_text->insert('end', "output file: $outpath"); #log
												chomp $outpath;
												
												$outpath="$dir$outpath";
												##--------------------------------------------------------
												my $nn=0;
												open(f1, $inpath);
												open(f2, ">$outpath");
												<f1>;
												while(<f1>)
												{
												chomp;
												$_=~s/^\s+//;
												my @arr=split(/\s+/, $_);
													if($arr[4] =~/[0-9]/ && $arr[4] < $myp)
													{
													print f2 "$arr[1]\n";
													$nn++;
													}
												
												}
												close f1;
												close f2;
												
												if($nn)
												{
												print "writing $nn SNPs to $outpath\n";
												$output_text->insert('end', "writing $nn SNPs to $outpath\n"); #log
												}
												else
												{
												print "No SNPs with p value less than $myp\n";
												unlink $outpath;
												}
												
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		
}

1;
