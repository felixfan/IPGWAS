package Plink::UpdateInfo;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

###---------
sub UpIndivInfo
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $out_format="";
my $ooo;
my $ok_frame;

$gp_win->geometry("450x300");
$gp_win->title("Update Individuals Iinformation");

$gp_win->resizable(0, 0);

my $snp_list;
my $option="update-ids";

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
														$mycom="--file $dir$base --$option $snp_list";
														}
														elsif($ext eq ".bed")
														{
														$mycom="--bfile $dir$base --$option $snp_list";
														}
														
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
#option_frame
my $option_frame=$gp_win->LabFrame(-label=>"Option", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
		my $opt_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio5=$opt_frame1->Radiobutton(-text=>"Update FID/IID (--update-ids)", -value=>"update-ids", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
			my $radio6=$opt_frame1->Radiobutton(-text=>"Update Sex (--update-sex)", -value=>"update-sex", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
			my $radio7=$opt_frame1->Radiobutton(-text=>"Update Parents (--update-parents)", -value=>"update-parents", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
		my $list_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $label1=$list_frame1->Label(-text => "Update Information File")->pack(-side=>"left", -anchor=>'nw');
			my $text1=$list_frame1->Text(-height => 1, -width => 40)->pack(-side=>"left", -anchor=>'nw');
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
sub UpSNPinfo
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $out_format="";
my $ooo;
my $ok_frame;

$gp_win->geometry("450x300");
$gp_win->title("Update SNPs Iinformation");

$gp_win->resizable(0, 0);

my $snp_list;
my $option="update-map";

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
														#------------
														if($option eq "update-map")
														{
														$mycom.=" --$option $snp_list";
														}
														else
														{
														$mycom.=" --update-map $snp_list --$option";
														}
														
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
#option_frame
my $option_frame=$gp_win->LabFrame(-label=>"Option", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
		my $opt_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio5=$opt_frame1->Radiobutton(-text=>"Update Physical Positions (--update-map)", -value=>"update-map", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
			my $radio6=$opt_frame1->Radiobutton(-text=>"Update Name/ID of SNPs (--update-name)", -value=>"update-name", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
			my $radio7=$opt_frame1->Radiobutton(-text=>"Update Chromosome of SNPs (--update-chr)", -value=>"update-chr", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
		my $list_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $label1=$list_frame1->Label(-text => "Update Information File")->pack(-side=>"left", -anchor=>'nw');
			my $text1=$list_frame1->Text(-height => 1, -width => 40)->pack(-side=>"left", -anchor=>'nw');
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

sub UpAlleleInfo
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $out_format="";
my $ooo;
my $ok_frame;

$gp_win->geometry("450x250");
$gp_win->title("Update Allele Iinformation");

$gp_win->resizable(0, 0);

my $snp_list;
my $option="update-alleles";

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
														$mycom="--file $dir$base --$option $snp_list";
														}
														elsif($ext eq ".bed")
														{
														$mycom="--bfile $dir$base --$option $snp_list";
														}
														#------------
														
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
#option_frame
my $option_frame=$gp_win->LabFrame(-label=>"Option", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
		my $opt_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio5=$opt_frame1->Radiobutton(-text=>"Update Allele Information (--update-alleles)", -value=>"update-alleles", -variable=>\$option)->pack(-side => "top", -anchor=>'w');
		my $list_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $label1=$list_frame1->Label(-text => "Update Information File")->pack(-side=>"left", -anchor=>'nw');
			my $text1=$list_frame1->Text(-height => 1, -width => 40)->pack(-side=>"left", -anchor=>'nw');
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