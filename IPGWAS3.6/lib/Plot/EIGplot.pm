package Plot::EIGplot;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;

sub ploteig
{
my($output_text, $mw, $gp_win, $gnuplot, $smartplot)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $option="png";

$gp_win->geometry("420x240");
$gp_win->title("EIG Plot");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $inframe1=$input_frame->Frame()->pack(-side => "top");
		$inframe1->Label(-text => ".evec File")->pack(-side => "left");
		my $T1=$inframe1->Text(-height => 1, -width => 44)->pack(-side=>"left");
		$inframe1->Button(-text => 'Browse',
							-command => sub	{
											$T1->delete('0.0', 'end');
											$input_path=$mw->getOpenFile(-filetypes=>[
																						['.evec files', '.evec'],
																						['All files', '*'],
																					]);
											$T1->insert('end', $input_path);
											}
						)->pack(-side => "left");
	
#option frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
	my $title_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #title frame
		$title_frame->Radiobutton(-text=>"Portable Network Graphics(png)", -value=>"png", -variable=>\$option)->pack(-side => "top", -anchor=>'w');	
		$title_frame->Radiobutton(-text=>"PostScript graphics language(ps)", -value=>"ps", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
		$title_frame->Radiobutton(-text=>"Graphics Interchange Format(gif)", -value=>"gif", -variable=>\$option)->pack(-side => "top", -anchor=>'w');	
		$title_frame->Radiobutton(-text=>"Encapsulated PostScript(eps)", -value=>"eps", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
		$title_frame->Radiobutton(-text=>"Joint Photographic Experts Group(jpeg)", -value=>"jpeg", -variable=>\$option)->pack(-side => "top", -anchor=>'w');	
		
	### out
	my $out_frame=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T5=$out_frame->Text(-height => 1, -width => 46)->pack(-side=>"left");
			$T5->delete('0.0','end');
			$T5->insert('end','eigplot.png');
#ok frame
my $ok_frame=$gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side=>"top"); #ok frame
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
												
												my $gfile="gnuplot.plot.txt";
												$gfile="$dir$gfile";
												
												###------------------------------
												$output_text->insert('end', "Reading data from: [$inpath]\n"); #log
												print "Reading data from: [$inpath]\n";
												
												system("perl $smartplot $inpath $gfile $gnuplot $option $outname $dir");
												
												$output_text->insert('end', "Done.\n"); #log	
												print "Done.\n"; #####log
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

1;
