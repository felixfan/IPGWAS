package QC::lmissHis;

use warnings;
use strict;

use GD::Graph::histogram;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;

sub SNPmissingHis
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;


$gp_win->geometry("420x150");
$gp_win->title("Histogram of SNP Missing Rate");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	$input_frame->Label(-text => ".lmiss File")->pack(-side => "left");
	my $T1=$input_frame->Text(-height => 1, -width => 44)->pack(-side=>"left");
	my $browse_button1 = $input_frame->Button(-text => 'Browse',
												-command => sub	{
																$T1->delete('0.0', 'end');
																$input_path=$mw->getOpenFile(-filetypes=>[
																										['.lmiss files', '.lmiss'],
																										['All files', '*'],
																																				]);
																$T1->insert('end', $input_path);
																}
												)->pack(-side => "left");
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
	my $size_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$size_frame->Label(-text=>"Width")->pack(-side=>'left');
		my $T2=$size_frame->Text(-height => 1, -width => 23)->pack(-side=>"left");
			$T2->delete('0.0','end');
			$T2->insert('end', '600');
		$size_frame->Label(-text=>"Height")->pack(-side=>'left');
		my $T3=$size_frame->Text(-height => 1, -width => 23)->pack(-side=>"left");
			$T3->delete('0.0','end');
			$T3->insert('end', '800');
	my $out_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T5=$out_frame->Text(-height => 1, -width => 46)->pack(-side=>"left");
			$T5->delete('0.0','end');
			$T5->insert('end', 'SNPmissingHis.png');
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
												$output_text->insert('end', "$inpath opend\n"); #log
												print "$inpath opend\n";
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
												print "Plotting...\n";
												#------------------------------
												
												open(f1, $inpath);
												my @miss;
												my $n=0; # SNP index
												
												<f1>; # first line
												while(<f1>) #read data
												{
												chomp;
												$_=~s/^\s+//;
												my @arr=split(/\s+/,$_);
												$miss[$n++]=$arr[4];
												}
												close f1;
												###------------------------------------------------
												###plot
												
												my $title="Histogram of SNP Missing Rate";
												my $xtitle="Missing Rate";
												my $ytitle="Number of SNPs";
												
												 my $graph = new GD::Graph::histogram($width,$height);
												   $graph->set( 
																x_label         => $xtitle,
																y_label         => $ytitle,
																title           => $title,
																x_labels_vertical => 1,
																bar_spacing     => 0,
																shadow_depth    => 1,
																shadowclr       => 'dred',
																transparent     => 0,
																histogram_type  => 'count', ##default count (also can be percentage)
																histogram_bins  => 50, ## default 50 bins
														) 
														or warn $graph->error;
														
														my $gd = $graph->plot(\@miss) or die $graph->error;
														# my $gd = $graph->plot(\@test) or die $graph->error;
														open(IMG, ">$outname") or die $!;
														binmode IMG;
														print IMG $gd->png;
														close IMG;
												
												############
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

}

1;
