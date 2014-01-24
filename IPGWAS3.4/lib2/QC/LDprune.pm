package QC::LDprune;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

sub LDprune4b36
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $out_format="";
my $ooo;
my $ok_frame;

$gp_win->geometry("550x240");
$gp_win->title("High LD Pruning");

$gp_win->resizable(0, 0);

my ($text11, $text12, $text13);
my $option="indep-pairwise";
my $exclude=1;
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
														
														my($base,$dir,$ext)=fileparse($inpath,'\..*');
														
														my $mycom;
														my $mycom1;
														my $mapfile="";
														
														if($ext eq ".ped")
														{
														$mycom="--file $dir$base";
														$mapfile="$dir$base.map";
														}
														elsif($ext eq ".bed")
														{
														$mycom="--bfile $dir$base";
														$mapfile="$dir$base.bim";
														}
														#-------------------------
														my %chr;
														for(my $i=1; $i <24; $i++) #chr 1-23
														{
														$chr{$i}=0;
														}
														
														my @minldregion;
														my @maxldregion;
														
														if($exclude ==1)
														{
														###read region
														$output_text->insert('end', "Identify SNPs in high LD regions...\n");
														print "Identify SNPs in high LD regions...\n";
														
														my $resource="$Bin/../resources/highLDregions/highLDregions4bim_b36.txt";
															open(f1, $resource);
															my $chrindex=0;
															while(<f1>)
															{
															chomp;
															my @arr=split(/\s+/, $_);
																if($chr{$arr[0]})
																{
																$chrindex++;
																$chr{$arr[0]}++;
																$minldregion[$arr[0]][$chrindex]=$arr[1];
																$maxldregion[$arr[0]][$chrindex]=$arr[2];
																}
																else
																{
																$chrindex=0;
																$chr{$arr[0]}++;
																$minldregion[$arr[0]][$chrindex]=$arr[1];
																$maxldregion[$arr[0]][$chrindex]=$arr[2];
																}
															}
															close f1;
														###find SNPs
														open(f1, $mapfile);
														open(f2, ">$dir$base.highLDsnp");
														while(<f1>)
														{
														chomp;
														my @arr=split(/\s+/, $_);
															if($chr{$arr[0]})
															{
																for(my $i=0; $i < $chr{$arr[0]}; $i++)
																{
																	if($arr[3] >=$minldregion[$arr[0]][$i] && $arr[3] <=$maxldregion[$arr[0]][$i])
																	{
																	print f2 "$arr[1]\n";
																	}
																}
															}
															elsif($arr[0]=~/X/i) ###chr x=> X/x but not 23
															{
																for(my $i=0; $i < $chr{23}; $i++)
																{
																	if($arr[3] >=$minldregion[23][$i] && $arr[3] <=$maxldregion[23][$i])
																	{
																	print f2 "$arr[1]\n";
																	}
																}
															}
														}
														close f1;
														close f2;
														
														$mycom1="$mycom --exclude $dir$base.highLDsnp";
														}
														
														#-------------------------
														my $t11=$text11->get('0.0', 'end');
														my $t12=$text12->get('0.0', 'end');
														my $t13=$text13->get('0.0', 'end');
														chomp $t11;
														chomp $t12;
														chomp $t13;
														$mycom1.=" --$option $t11 $t12 $t13";
														
														print "Pruning data...\n";
														my $mytempname="LDprune";
														$output_text->insert('end', "Pruning data...\nCommand used:\nplink $mycom1 --out $dir$mytempname\n");
														
														my $runcom="$plink $mycom1 --out $dir$mytempname";
														my $runcomOut=qx/$runcom/;
														
														$output_text->insert('end', "$runcomOut\n");
														
														print "Extracting the thinned SNPs...\n";
														$output_text->insert('end', "Extracting the thinned SNPs...\nCommand used:\nplink $mycom --extract $dir$mytempname.prune.in --make-bed --out $dir$outname\n");
														
														my $runcom2="$plink $mycom --extract $dir$mytempname.prune.in --make-bed --out $dir$outname";
														my $runcomOut2=qx/$runcom2/;
														
														$output_text->insert('end', "$runcomOut2\nDone.\n");
														print "Done.\n";
														
												}
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

#output_frame
$ooo=Plink::SBoutput::outputFrame($gp_win, $ok_frame);
$output_name=Plink::SBoutput::outputName($ooo);

#option_frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
		my $opt_frame1=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			$opt_frame1->Checkbutton(-text=>"Exclude SNPs in High LD Regions", -variable=>\$exclude)->pack(-side => "left", -anchor=>'w');	
		my $opt_frame2=$option_frame->Frame()->pack(-side=>"top", -anchor=>'w');
			my $radio6=$opt_frame2->Radiobutton(-text=>"Based on Pairwise Genotypic Correlation(--indep-pairwise)        ",
												-value=>"indep-pairwise", -variable=>\$option)->pack(-side => "left");
				$text11=$opt_frame2->Text(-height => 1, -width => 5)->pack(-side=>'left');
				$text11->insert('end', '50');
				$text12=$opt_frame2->Text(-height => 1, -width => 5)->pack(-side=>'left');
				$text12->insert('end', '5');
				$text13=$opt_frame2->Text(-height => 1, -width => 5)->pack(-side=>'left');
				$text13->insert('end', '0.2');
}



1;
