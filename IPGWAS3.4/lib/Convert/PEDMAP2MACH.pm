package Convert::PEDMAP2MACH;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;

sub pedmap2mach
{
my($output_text, $mw, $gp_win, $ped2mach)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";

my $ooo;
my $ok_frame;

my $num ||= 0; #default
my $sep ||=0;
my $miss ||=0;


$gp_win->geometry("450x250");
$gp_win->title("Convert PED/MAP to MACH Input Files");

$gp_win->resizable(0, 0);


my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#input frame
my $input_frame=$gp_win->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $in1_frame=$input_frame->Frame()->pack(-side=>"top", -anchor=>'w');
		$in1_frame->Label(-text => ".ped File")->pack(-side => "left");
		my $T1=$in1_frame->Text(-height => 1, -width => 49)->pack(-side=>"left");
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
		my $T2=$in2_frame->Text(-height => 1, -width => 49)->pack(-side=>"left");
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
	my $opt_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
		my $opt1_frame=$opt_frame->Frame(-borderwidth=>1)->pack(-side => "top");
			my $cb1=$opt1_frame->Checkbutton(-text=>"--numerically coded alleles                                                                                               ", -variable=>\$num)->pack(-side => "top", -anchor=>'w');	
			my $cb2=$opt1_frame->Checkbutton(-text=>"--sep                   ", -variable=>\$sep)->pack(-side => "top", -anchor=>'w');	
			my $cb3=$opt1_frame->Checkbutton(-text=>"--miss                   ", -variable=>\$miss)->pack(-side => "top", -anchor=>'w');				
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
												$num=$num==1?"yes":"no";
												$sep=$sep==1?"yes":"no";
												$miss=$miss==1?"yes":"no";
												#------------------------------
												
												system("$ped2mach --ped $ped --map $map --num $num --sep $sep --miss $miss --out $outname");
												
												$output_text->insert('end', "Done.\n");
												print "Done.\n";
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

1;
