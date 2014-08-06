package Convert::IMPUTE2TPED;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;

sub impute2tpedtfam
{
my($output_text, $mw, $gp_win, $impute2tped)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";

my $ooo;
my $ok_frame;


$gp_win->geometry("450x220");
$gp_win->title("Convert IMPUTE2 Output to tped/tfam File");

$gp_win->resizable(0, 0);


my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $in1_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in1_frame->Label(-text => ".gen File")->pack(-side => "left");
		my $T1=$in1_frame->Text(-height => 1, -width => 49)->pack(-side=>"left");
		my $browse_button1 = $in1_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['.gen files', '.gen'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
	my $in2_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in2_frame->Label(-text => ".sample File")->pack(-side => "left");
		my $T2=$in2_frame->Text(-height => 1, -width => 47)->pack(-side=>"left");
		my $browse_button2 = $in2_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T2->delete('0.0', 'end');
																	$input_path2=$mw->getOpenFile(-filetypes=>[
																											['.sample files', '.sample'],
																											['All files', '*'],
																																					]);
																	$T2->insert('end', $input_path2);
																	}
													)->pack(-side => "left");												
#option frame
	my $opt_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
		my $opt1_frame=$opt_frame->Frame(-borderwidth=>1)->pack(-side => "top");
			$opt1_frame->Label(-text => "--chr (1 - 22)   ")->pack(-side => "left");
			my $T3=$opt1_frame->Text(-height => 1, -width => 52)->pack(-side=>"left");
			$T3->delete('0.0','end');
		my $opt2_frame=$opt_frame->Frame(-borderwidth=>1)->pack(-side => "top");
			$opt2_frame->Label(-text => "--threshold (0-1)")->pack(-side => "left");
			my $T4=$opt2_frame->Text(-height => 1, -width => 51)->pack(-side=>"left");
			$T4->delete('0.0','end');
			$T4->insert('end', '0.9');
			
#output name frame
	my $out_frame=$gp_win->LabFrame(-label=>"Output File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T6=$out_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
			$T6->delete('0.0','end');
			
#ok frame
$ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => "OK",-command =>sub{
												my $ped=$T1->get('0.0', 'end');
												chomp $ped;
												$output_text->insert('end', "$ped opened\n"); #log
												print "$ped opened\n";
												
												my $map=$T2->get('0.0', 'end');
												chomp $map;
												$output_text->insert('end', "$map opened\n"); #log
												print "$map opened\n";
												
												my($base,$dir,$ext)=fileparse($ped,'\..*');
												
												my $outname=$T6->get('0.0', 'end');
												$output_text->insert('end', "output: $dir$outname"); #log
												chomp $outname;
												$outname="$dir$outname";
												
												#------------------------------
												my $chr=$T3->get('0.0', 'end');
												chomp $chr;
												if($chr>23 || $chr<1)
												{
												$output_text->insert('end', "warning: you specified chromosome as $chr\n"); #log
												}
												$output_text->insert('end', "chromosome: $chr\n"); #log
												#------------------------------
												my $threshold=$T4->get('0.0', 'end');
												chomp $threshold;
												if($threshold >1 || $threshold<0.5)
												{
												$output_text->insert('end', "warning: you specified threshold as $threshold\n"); #log
												$output_text->insert('end', "the default threshold 0.9 will be used\n"); #log
												$threshold=0.9;
												}
												$output_text->insert('end', "threshold: $threshold\n"); #log
												#-------------------------------
												system("$impute2tped --gen $ped --sample $map --chr $chr --threshold $threshold --out $outname");
												
												$output_text->insert('end', "Done.\n");
												print "Done.\n";
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

1;
