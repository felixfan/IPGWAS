package Plink::ExRmIndivSNP;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

sub ExIndivRmIndivSNP
{
my($output_text, $mw, $gp_win, $option, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $out_format="";
my $ooo;
my $ok_frame;

$gp_win->geometry("560x290");
$gp_win->title("Extract/Remove Individuals & Remove SNPs");

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
														$output_text->insert('end', "Command used:\nplink $mycom --$option $snp_list --$out_format --out $dir$outname\n");
														print "Running...\n";
														
														my $runcom="$plink $mycom --$option $snp_list --$out_format --out $dir$outname";
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
			$opt_frame1->Radiobutton(-text=>"Remove a Subset of SNPs (--exclude)", -value=>"exclude", -variable=>\$option)->pack(-side => "top");
		my $opt_frame2=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			$opt_frame2->Radiobutton(-text=>"Remove a Subset of Individuals (--remove)", -value=>"remove", -variable=>\$option)->pack(-side => "top");
		my $opt_frame3=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			$opt_frame3->Radiobutton(-text=>"Extract a Subset of Individuals (--keep)", -value=>"keep", -variable=>\$option)->pack(-side => "top");
		my $list_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $label1=$list_frame1->Label(-text => "SNPs/Individual List File")->pack(-side=>"left", -anchor=>'nw');
			my $text1=$list_frame1->Text(-height => 1, -width => 45)->pack(-side=>"left", -anchor=>'nw');
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
###---------
sub ExtractSubsetSNPs
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $out_format="";
my $ooo;
my $ok_frame;

$gp_win->geometry("560x370");
$gp_win->title("Extract a Subset of SNPs");

$gp_win->resizable(0, 0);

my $option="extract";
my $opt1_text;
my $snplist;
my ($text2, $text3, $text4, $text5, $text6, $text7, $text8, $text9);

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
														
														my $outname=$output_name->get('0.0', 'end');
														chomp $outname;
														
														chomp $snplist;
														
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
														#----------------------------
														my $runcom;
														my $runcomOut;
																if($option eq "extract")
																{
																print "SNPs list: $snplist\n";
																$output_text->insert('end', "command used:\nplink $mycom --extract $snplist --$out_format --out $outname\n");
																print "Running...\n";
														
																$runcom="$plink $mycom --extract $snplist --$out_format --out $dir$outname";
																$runcomOut=qx/$runcom/;
																}
																elsif($option eq "chr")
																{
																my $mychr=$text2->get('0.0', 'end');
																chomp $mychr;
																$output_text->insert('end', "command used:\nplink $mycom --chr $mychr --$out_format --out $outname\n");
																print "Running...\n";
														
																$runcom="$plink $mycom --chr $mychr --$out_format --out $dir$outname";
																$runcomOut=qx/$runcom/;
																}
																elsif($option eq "from-to")
																{
																my $myfrom=$text3->get('0.0','end');
																my $myto=$text4->get('0.0','end');
																chomp $myfrom;
																chomp $myto;
																$output_text->insert('end', "command used:\nplink $mycom --from $myfrom --to $myto --$out_format --out $outname\n");
																print "Running...\n";
														
																$runcom="$plink $mycom --from $myfrom --to $myto --$out_format --out $dir$outname";
																$runcomOut=qx/$runcom/;
																}
																elsif($option eq "snp-win")
																{
																my $mysnp=$text5->get('0.0','end');
																my $mywin=$text6->get('0.0','end');
																chomp $mysnp;
																chomp $mywin;
																$output_text->insert('end', "command used:\nplink $mycom --snp $mysnp --window $mywin --$out_format --out $outname\n");
																print "Running...\n";
														
																$runcom="$plink $mycom --snp $mysnp --window $mywin --$out_format --out $dir$outname";
																$runcomOut=qx/$runcom/;
																}
																elsif($option eq "from-kb")
																{
																my $mychr=$text7->get('0.0','end');
																my $myfrom=$text8->get('0.0','end');
																my $myto=$text9->get('0.0','end');
																chomp $mychr;
																chomp $myfrom;
																chomp $myto;
																$output_text->insert('end', "command used:\nplink $mycom --chr $mychr --from-kb $myfrom --to-kb $myto --$out_format --out $outname\n");
																print "Running...\n";
														
																$runcom="$plink $mycom --chr $mychr --from-kb $myfrom --to-kb $myto --$out_format --out $dir$outname";
																$runcomOut=qx/$runcom/;
																}
														#-----------------
														
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
my $opt_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
	my $opt1_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side=>"top", -anchor=>'w'); #--extract		
		my $radio_frame1=$opt1_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio5=$opt1_frame->Radiobutton(-text=>"Extract a Subset of SNPs: File-list Options (--extract)				", -value=>"extract", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
		my $list_frame1=$opt1_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $label1=$list_frame1->Label(-text => "SNPs List File")->pack(-side=>"left", -anchor=>'nw');
			my $text1=$list_frame1->Text(-height => 1, -width => 53)->pack(-side=>"left", -anchor=>'nw');
					$text1->delete('0.0','end');
			my $list_button1 = $list_frame1->Button(-text => 'Browse',
														-command => sub{
																		$text1->delete('0.0', 'end');
																		$snplist=$mw->getOpenFile(-filetypes=>[
																												['TXT files', '.txt'],
																												['All files', '*'],
																											]);
																		$text1->insert('end', $snplist);
																		}
																				   
													 )->pack(-side => "left");
	my $opt2_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side=>"top", -anchor=>'w', -anchor=>'w'); #--chr
		my $radio6=$opt2_frame->Radiobutton(-text=>"Based on a Single Chromosome (--chr)", -value=>"chr", -variable=>\$option)->pack(-side => "left");
		my $label2=$opt2_frame->Label(-text => "Chromosome:")->pack(-side=>'left');
			$text2=$opt2_frame->Text(-height => 1, -width => 27)->pack(-side=>"left");
			$text2->delete('0.0','end');
	my $opt3_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side=>"top", -anchor=>'w'); #--from --to
		my $radio7=$opt3_frame->Radiobutton(-text=>"Based on a Range of SNPs", -value=>"from-to", -variable=>\$option)->pack(-side => "left");
		my $label3=$opt3_frame->Label(-text => "--from")->pack(-side=>'left');
			$text3=$opt3_frame->Text(-height => 1, -width => 19)->pack(-side=>"left");
			$text3->delete('0.0','end');
		my $label4=$opt3_frame->Label(-text => "--to")->pack(-side=>'left');
			$text4=$opt3_frame->Text(-height => 1, -width => 19)->pack(-side=>"left");
			$text4->delete('0.0','end');
	my $opt4_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side=>"top", -anchor=>'w'); #--snp --window
		my $radio8=$opt4_frame->Radiobutton(-text=>"Based on Single SNP and Window", -value=>"snp-win", -variable=>\$option)->pack(-side => "left");
		my $label5=$opt4_frame->Label(-text => "--snp")->pack(-side=>'left');
			$text5=$opt4_frame->Text(-height => 1, -width => 13)->pack(-side=>"left");
			$text5->delete('0.0','end');
		my $label6=$opt4_frame->Label(-text => "--window(kb)")->pack(-side=>'left');
			$text6=$opt4_frame->Text(-height => 1, -width => 12)->pack(-side=>"left");
			$text6->delete('0.0','end');
	my $opt5_frame=$opt_frame->Frame(-borderwidth=>1, -relief=> "groove")->pack(-side=>"top", -anchor=>'w'); #--from-kb
		my $radio_frame2=$opt5_frame->Frame()->pack(-side=>'top', -anchor=>'w');
			my $radio9=$radio_frame2->Radiobutton(-text=>"Based on Physical Position			       		", -value=>"from-kb", -variable=>\$option)->pack(-side => "top");
		my $list_frame2=$opt5_frame->Frame()->pack(-side=>'top', -anchor=>'w');
			my $label7=$list_frame2->Label(-text => "--chr ")->pack(-side=>'left');
				$text7=$list_frame2->Text(-height => 1, -width => 17)->pack(-side=>"left");
				$text7->delete('0.0','end');
			my $label8=$list_frame2->Label(-text => "--from-kb")->pack(-side=>'left');
				$text8=$list_frame2->Text(-height => 1, -width => 18)->pack(-side=>"left");
				$text8->delete('0.0','end');
			my $label9=$list_frame2->Label(-text => "--to-kb")->pack(-side=>'left');
				$text9=$list_frame2->Text(-height => 1, -width => 18)->pack(-side=>"left");
				$text9->delete('0.0','end');

}

1;
