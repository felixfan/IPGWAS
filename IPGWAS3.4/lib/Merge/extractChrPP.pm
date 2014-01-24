package Merge::extractChrPP;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

sub extractChromosomePysicalPosition
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";

my $ooo;
my $ok_frame;

$gp_win->geometry("450x150");
$gp_win->title("Extract Chromosome & Physical Position");

$gp_win->resizable(0, 0);

#input_frame
my $ttt=Plink::SBinput::InputFrame($gp_win);
$input_path=Plink::SBinput::InputContentBim($mw, $ttt);
										  
#sub ok button
$ok_frame = $gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side => "top"); # button frame
	$ok_frame->Button(-text => "OK",-command =>sub{
														my $inpath=$input_path->get('0.0', 'end');
															chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No bim file\n");
															die "No bim file: $!\n";
															}
														
														my($base,$dir,$ext)=fileparse($inpath,'\..*');
														
														my $outname=$output_name->get('0.0', 'end');
														chomp $outname;
														my $outnamechr="$dir$outname.chr.txt";
														my $outnamephy="$dir$outname.phy.txt";
														#----------------------
														open(f1, $inpath);
														open(f2, "> $outnamechr");
														open(f3, "> $outnamephy");
														while(<f1>)
														{
														my @arr=split(/\s+/, $_);
														print f2 "$arr[1] $arr[0]\n";
														print f3 "$arr[1] $arr[3]\n";
														}
														close f1;
														close f2;
														close f3;
												$output_text->insert('end', "write chromosome information to $outnamechr ...\n"); #log
												$output_text->insert('end', "write physical information to $outnamephy ...\n"); #log
												$output_text->insert('end', "Done.\n"); #log	
												print "write chromosome information to $outnamechr ...\nwrite physical information to $outnamephy ...\nDone.\n"; #####log
												}
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

#output_frame
$ooo=Plink::SBoutput::outputFrame($gp_win, $ok_frame);
$output_name=Plink::SBoutput::outputName($ooo);
}
1;

