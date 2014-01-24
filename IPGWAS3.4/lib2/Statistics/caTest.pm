package Statistics::caTest;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;
use Statistics::Distributions qw (chisqrprob);

sub caTrendTest
{
my($output_text, $mw, $gp_win, $CATassoc)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";

my $ooo;
my $ok_frame;

my $model="best"; # default model "all"

$gp_win->geometry("500x240");
$gp_win->title("Cochran-Armitage Trend Test");

$gp_win->resizable(0, 0);


my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $in1_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in1_frame->Label(-text => ".ped File")->pack(-side => "left");
		my $T1=$in1_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
		my $browse_button1 = $in1_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['.ped files', '.ped'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
	my $in2_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in2_frame->Label(-text => ".map File")->pack(-side => "left");
		my $T2=$in2_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
		my $browse_button2 = $in2_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T2->delete('0.0', 'end');
																	$input_path2=$mw->getOpenFile(-filetypes=>[
																											['.map files', '.map'],
																											['All files', '*'],
																																					]);
																	$T2->insert('end', $input_path2);
																	}
													)->pack(-side => "left");												
#option frame
	my $opt_frame=$gp_win->LabFrame(-label=>"Model", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
		my $opt1_frame=$opt_frame->Frame(-borderwidth=>1)->pack(-side => "top");
			my $radio1=$opt1_frame->Radiobutton(-text=>"Bset              ", -value=>"best", -variable=>\$model)->pack(-side => "left", -anchor=>'w');	
			my $radio2=$opt1_frame->Radiobutton(-text=>"Dominant          ", -value=>"dom", -variable=>\$model)->pack(-side => "left", -anchor=>'w');
			my $radio3=$opt1_frame->Radiobutton(-text=>"Recessive         ", -value=>"rec", -variable=>\$model)->pack(-side => "left", -anchor=>'w');
			my $radio4=$opt1_frame->Radiobutton(-text=>"Additive          ", -value=>"add", -variable=>\$model)->pack(-side => "left", -anchor=>'w');						
#output name frame
	my $out_frame=$gp_win->LabFrame(-label=>"Output File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T6=$out_frame->Text(-height => 1, -width => 54)->pack(-side=>"left");
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
												my $log9="$outname.log";
												#----------------------------------------------------------------------------------
												system("$CATassoc --ped $ped --map $map --model $model --out $outname --log $log9");
												
												$output_text->insert('end', "Analysis finished.\n");
												#----------------------------------------------------------------------------------
												
												
												$output_text->insert('end', "Done.\n");
												print "Done.\n";
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

1;
