package Plink::MergeFiles;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

sub Merge2File
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";
my $output_name="";
my $out_format="";
my $ooo;
my $ok_frame;

$gp_win->geometry("560x200");
$gp_win->title("Merge Two Filesets");

$gp_win->resizable(0, 0);

#input_frame
my $ttt=Plink::SBinput::InputFrame($gp_win);
$input_path=Plink::SBinput::InputContent($mw, $ttt);
$input_path2=Plink::SBinput::InputContent($mw, $ttt);
										  
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
															
														my $inpath2=$input_path2->get('0.0', 'end');
															chomp $inpath2;
															if(! $inpath2)
															{
															$output_text->insert('end', "No second PED/BED file\n");
															die "No second PED/BED file: $!\n";
															}
														
														my $outname=$output_name->get('0.0', 'end');
														chomp $outname;
														
														my($base,$dir,$ext)=fileparse($inpath,'\..*');
														my($base2,$dir2,$ext2)=fileparse($inpath2,'\..*');
														
														my $mycom;
														#-------
														if($ext eq ".ped")
														{
														$mycom="--file $dir$base";
														}
														elsif($ext eq ".bed")
														{
														$mycom="--bfile $dir$base";
														}
														#----
														if($ext2 eq ".ped")
														{
														my $myped2="$dir2$base2.ped";
														my $mymap2="$dir2$base2.map";
														$mycom.=" --merge $myped2 $mymap2";
														}
														elsif($ext2 eq ".bed")
														{
														my $mybed2="$dir2$base2.bed";
														my $mybim2="$dir2$base2.bim";
														my $myfam2="$dir2$base2.fam";
														$mycom.=" --bmerge $mybed2 $mybim2 $myfam2";
														}
														#----
														$output_text->insert('end', "Command used:\nplink $mycom --$out_format --out $dir$outname\n");
														print "Running...\n";
														
														my $runcom="$plink $mycom --$out_format --out $dir$outname";
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
}

###---------
sub MergeMultipleFilesets
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $out_format="";
my $ooo;
my $ok_frame;

$gp_win->geometry("560x240");
$gp_win->title("Merge Multiple Filesets");

$gp_win->resizable(0, 0);

my $file_list;

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
														chomp $file_list;
															if(! $file_list)
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
														$output_text->insert('end', "Command used:\nplink $mycom --merge-list $file_list --$out_format --out $dir$outname\n");
														print "Running...\n";
														
														my $runcom="$plink $mycom --merge-list $file_list --$out_format --out $dir$outname";
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
			my $option="merge-list";
			my $radio5=$opt_frame1->Radiobutton(-text=>"Merge Multiple Filesets (--merge-list)", -value=>"merge-list", -variable=>\$option)->pack(-side => "top");
		my $list_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $label1=$list_frame1->Label(-text => "List of Files")->pack(-side=>"left", -anchor=>'nw');
			my $text1=$list_frame1->Text(-height => 1, -width => 56)->pack(-side=>"left", -anchor=>'nw');
					$text1->delete('0.0','end');
			my $list_button1 = $list_frame1->Button(-text => 'Browse',
														-command => sub{
																		$text1->delete('0.0', 'end');
																		$file_list=$mw->getOpenFile(-filetypes=>[
																													['TXT files', '.txt'],
																													['All files', '*'],
																												]);
																		$text1->insert('end', $file_list);
																		print "$file_list opened.\n";
																	}		   
													)->pack(-side => "left");
}

1;

