package Plink::Flip;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

sub FlipStrand
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $out_format="";
my $ooo;
my $ok_frame;

$gp_win->geometry("450x230");
$gp_win->title("Flip DNA strand for SNPs");

$gp_win->resizable(0, 0);

my $snp_list;

#input_frame
my $ttt=Plink::SBinput::InputFrame($gp_win);
$input_path=Plink::SBinput::InputContent($mw, $ttt);
										  
#sub ok button
$ok_frame = $gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side => "top"); # button frame
	$ok_frame->Button(-text => "OK",-command =>sub{
														my $inpath=$input_path->get('0.0', 'end');
															chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No PED/BED file\n");
															die "No PED/BED file: $!\n";
															}
														chomp $snp_list;
															if(! $snp_list)
															{
															$output_text->insert('end', "No SNP lists file\n");
															die "No SNP lists file: $!\n";
															}
														my $outname=$output_name->get('0.0', 'end');
														chomp $outname;
														
														my($base,$dir,$ext)=fileparse($inpath,'\..*');
														
														my $mycom;
														
														if($ext eq ".ped")
														{
														$mycom="--file $dir$base";
														}
														elsif($ext eq ".bed")
														{
														$mycom="--bfile $dir$base";
														}
														$output_text->insert('end', "Command used:\nplink $mycom --flip $snp_list --$out_format --out $dir$outname\n");
														
														print "Running...\n";
														
														my $runcom="$plink $mycom --flip $snp_list --$out_format --out $dir$outname";
														my $runcomOut=qx/$runcom/;
														
														$output_text->insert('end', "$runcomOut\nDone.\n");
														print "Done.\n";
												}
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

#output_frame
$ooo=Plink::SBoutput::outputFrame($gp_win, $ok_frame);
my $out_format_frame=$ooo->Frame()->pack(-side=>"top", -anchor=>'w');
	$out_format_frame->Label(-text=>"Output Format:")->pack(-side=>"left");
	$out_format="make-bed";
	$out_format_frame->Radiobutton(-text=>"Standard(--recode)", -value=>"recode",
									-variable=>\$out_format)->pack(-side => "left", -anchor=>"w");
	$out_format_frame->Radiobutton(-text=>"Binary(--make-bed)", -value=>"make-bed",
									-variable=>\$out_format)->pack(-side => "left", -anchor=>"w");
	$out_format_frame->Radiobutton(-text=>"Haploview(--recodeHV)", -value=>"recodeHV",
									-variable=>\$out_format)->pack(-side => "left", -anchor=>"w");
$output_name=Plink::SBoutput::outputName($ooo);
#option_frame
my $option_frame=$gp_win->LabFrame(-label=>"Option", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
		my $opt_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $option="flip";
			my $radio5=$opt_frame1->Radiobutton(-text=>"Flip DNA strand for SNPs (--flip)", -value=>"flip", -variable=>\$option)->pack(-side => "top");
		my $list_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $label1=$list_frame1->Label(-text => "SNPs List File")->pack(-side=>"left", -anchor=>'nw');
			my $text1=$list_frame1->Text(-height => 1, -width => 46)->pack(-side=>"left", -anchor=>'nw');
					$text1->delete('0.0','end');
			my $list_button1 = $list_frame1->Button(-text => 'Browse',
														-command => sub{
																		$text1->delete('0.0', 'end');
																		$snp_list=$mw->getOpenFile(-filetypes=>[
																													['TXT files', '.txt'],
																													['All files', '*'],
																												]);
																		$text1->insert('end', $snp_list);
																		print "$snp_list opened.\n";
																	}		   
													)->pack(-side => "left");
}
1;