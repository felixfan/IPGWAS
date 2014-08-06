package Convert::PEDMAP2PHASE;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;

sub pedmap2phase
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";

my $ooo;
my $ok_frame;

my $cc ||= 0; #default no case-control status

$gp_win->geometry("450x200");
$gp_win->title("Convert PED/MAP to PHASE Input File");

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
			my $cb1=$opt1_frame->Checkbutton(-text=>"--Case-Control Status                                                                                                           ", -variable=>\$cc)->pack(-side => "left", -anchor=>'w');											
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
												
												if($cc == 1)
												{
												print "You select to specify the case-ontrol status of each individual\nuse the -c flag when running PHASE\n";
												$output_text->insert('end', "You select to specify the case-ontrol status of each individual\nuse the -c flag when running PHASE\n");
												}
														
												#------------------------------
												
												my @location;
												my ($numSNPs, $numIndiv)=(0,0);
												
												open(f0, ">$outname");
												
												open(f1, $ped);
												while(<f1>)
												{
												$numIndiv++;
												}
												close f1;

												open(f1, $map);
												while(<f1>)
												{
												chomp;
												my @arr=split(/\s+/, $_);
												$location[$numSNPs++]=$arr[3];
												}
												close f1;

												#####print out title info
												print f0 "$numIndiv\n";
												print f0 "$numSNPs\n";
												
												print "Number of individuals: $numIndiv\n";
												print "Number of SNPs: $numSNPs\n";
												$output_text->insert('end', "Number of individuals: $numIndiv\n");
												$output_text->insert('end', "Number of SNPs: $numSNPs\n");
												
												print f0 "P";
												foreach my $key (@location)
												{
												print f0 " $key";
												}
												print f0 "\n";

												print f0 "S";
												for(my $i=0; $i<$#location; $i++)
												{
												print f0 " S";
												}
												print f0 "\n";

												#####print out genotype
												my $indNo=1;
												open(f1, $ped);
												while(<f1>)
												{
												chomp;
												my @ar=split(/\s/, $_);
													if($cc == 1) # case control status. control=>0, case=>1
													{
														if($ar[5]==1)
														{
														$ar[5]=0;
														}
														elsif($ar[5]==2)
														{
														$ar[5]=1;
														}
														else
														{
														die "The phenotype of individual $ar[0] $ar[1] is $ar[5] but not 1 or 2\n";
														}
													print f0 "$ar[5] $ar[0]._.$ar[1]\n"; #default individual ID = "FID._.IID"
													}
													else
													{
													print f0 "$ar[0]._.$ar[1]\n"; #default individual ID = "FID._.IID"
													}
													###first line
													$ar[6]= $ar[6] eq "0" ? "?" : $ar[6]; #code missing data as ?
													print f0 "$ar[6]";
													for(my $i=8; $i<=$#ar; $i+=2)
													{
													$ar[$i]= $ar[$i] eq "0" ? "?" : $ar[$i]; #code missing data as ?
													print f0 " $ar[$i]";
													}
													print f0 "\n";
													###second line
													$ar[7]= $ar[7] eq "0" ? "?" : $ar[7]; #code missing data as ?
													print f0 "$ar[7]";
													for(my $i=9; $i<=$#ar; $i+=2)
													{
													$ar[$i]= $ar[$i] eq "0" ? "?" : $ar[$i]; #code missing data as ?
													print f0 " $ar[$i]";
													}
													print f0 "\n";
												$indNo++;
												}
												close f1;
												
												$output_text->insert('end', "Done.\n");
												print "Done.\n";
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

1;
