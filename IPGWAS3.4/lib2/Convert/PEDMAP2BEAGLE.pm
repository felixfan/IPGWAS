package Convert::PEDMAP2BEAGLE;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;

sub pedmap2beagle
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $input_path2="";

my $ooo;
my $ok_frame;

$gp_win->geometry("500x240");
$gp_win->title("Convert PED/MAP to BEAGLE Input File");

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
	my $opt_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
		my $opt1_frame=$opt_frame->Frame(-borderwidth=>1)->pack(-side => "top");
			$opt1_frame->Label(-text=>"Disease Name:")->pack(-side => "left");
			my $T9=$opt1_frame->Text(-height => 1, -width => 55)->pack(-side=>"left");
			$T9->delete('0.0','end');
#output name frame
	my $out_frame=$gp_win->LabFrame(-label=>"Output File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
		$out_frame->Label(-text=>"Output File Name")->pack(-side=>'left');
		my $T6=$out_frame->Text(-height => 1, -width => 55)->pack(-side=>"left");
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
												
												my $trait=$T9->get('0.0', 'end');
												chomp $trait;
												if(! $trait)
												{
												$output_text->insert('end', "Please specify the name of disease\n"); #log
												die"Please specify the name of disease\n";
												}
													
												#------------------------------
												print "Running...\n";
												
												my @snp;
												my $i=0;

												open(f1, $map) || die "Can not open map file: $!\n";
												while(<f1>)
												{
												my @arr=split(/\s+/, $_);
												$snp[$i++]=$arr[1];
												}
												close f1;

												my $id="I id"; #first line
												my $aff="A $trait"; #second line
												my %geno; #third-last line, marker genotypes

												open(f1, $ped) || die "Can not open ped file: $!\n";   ####use IID only
												while(<f1>)
												{
												chomp;
												my @arr=split(/\s+/, $_);
												$id.=" $arr[1] $arr[1]";
												$aff.=" $arr[5] $arr[5]";
												my $k=0;
													for(my $j=6; $j<=$#arr; $j+=2)
													{
													my $t=$j+1;
														if(exists $geno{$snp[$k]})
														{
														$geno{$snp[$k]}.=" $arr[$j] $arr[$t]";
														}
														else
														{
														$geno{$snp[$k]}.="M $snp[$k] $arr[$j] $arr[$t]";
														}
													$k++;
													}
													
													if($k != $i)
													{
													die "The number of markers in map file does not match that in ped file\n";
													}
												}
												close f1;
												
												open(f99, ">$outname");
												print f99 "$id\n";
												print f99 "$aff\n";
												for(my $n=0;$n<=$#snp; $n++)
												{
												print f99 "$geno{$snp[$n]}\n";
												}
												close f99;
												
												$output_text->insert('end', "Done.\n");
												print "Done.\n";
											  }
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

1;
