package Merge::AffymetrixCheckStrand;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use Archive::Extract;
use LWP::Simple;

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;

sub AffyCS
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("580x250");
$gp_win->title("Check Strand for SNPs");

$gp_win->resizable(0, 0);

my $r_option="snp6";
my $s_option="forward";
my $out_format="";
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
														my %mysnp;
														my $mymap;
														
														if($ext eq ".ped")
														{
														$mycom="$plink --file";
														$mymap="$dir$base.map";
														}
														elsif($ext eq ".bed")
														{
														$mycom="$plink --bfile";
														$mymap="$dir$base.bim";
														}
														#-----------------------
														my $resource;
														if ($r_option eq "snp6")
														{
														###check annotation
															if(!-e "$Bin/../resources/Affymatrix/affy6.strand")
															{
															& downloadAffy6($output_text);
															}
														###
														$resource="$Bin/../resources/Affymatrix/affy6.strand";
														}
														elsif($r_option eq "snp5")
														{
														###check annotation
															if(!-e "$Bin/../resources/Affymatrix/affy5.strand")
															{
															& downloadAffy5($output_text);
															}
														###
														$resource="$Bin/../resources/Affymatrix/affy5.strand";
														}
														else
														{
														###check annotation
															if(!-e "$Bin/../resources/Affymatrix/affy500k.strand")
															{
															& downloadAffy500k($output_text);
															}
														###
														$resource="$Bin/../resources/Affymatrix/affy500k.strand";
														}
														#----------------------------------
														open(f1, $resource); #all snp
														
														while(<f1>)
														{
														chomp;
														my @arr=split(/\s+/, $_);
															if($arr[2] ne "---")
															{
															$mysnp{$arr[1]}=$arr[2];
															}
														}
														close f1;
														
														#check strand
														my $sno1=0; # forward
														my $sno2=0; # reverse
														my $sno3=0; # no strand
														my $sno4=0; # total
														open(f1, ">$dir$outname.forward");
														open(f2, ">$dir$outname.reverse");
														open(f3, ">$dir$outname.nostrand");
														
														open(f4, $mymap);
														while(<f4>)
														{
														chomp;
														my @arr=split(/\s+/, $_);
															if(exists $mysnp{$arr[1]}) #strand info
															{
																if($mysnp{$arr[1]} eq "+")
																{
																print f1 "$arr[1]\n";
																$sno1++;
																}
																else
																{
																print f2 "$arr[1]\n";
																$sno2++;
																}
															}
															else #no strand info
															{
															print f3 "$arr[1]\n";
															$sno3++;
															}
														$sno4++;
														}
														close f1;
														close f2;
														close f3;
														close f4;
														
														print "Total $sno4 SNPs\n$sno1 SNPs with forward (+) strand\n$sno2 SNPs with reverse (-) strand\n$sno3 SNPs with no strand information, these SNPs will be removed\n";
														$output_text->insert('end',"Total $sno4 SNPs\n$sno1 SNPs with forward (+) strand\n$sno2 SNPs with reverse (-) strand\n$sno3 SNPs with no strand information, these SNPs will be removed\n");
														#----------------------------------------
														#remove
														my $snp_list_rm="$dir$outname.nostrand";
														
														if(-s $snp_list_rm)
														{
														$output_text->insert('end',"remove $sno3 SNPs...\n");
														print "remove $sno3 SNPs...\n";
														
														my $tempf="temp";
														
														my $runcom="$mycom $dir$base --exclude $snp_list_rm --make-bed --out $dir$tempf";
														my $runcomOut=qx/$runcom/;
														
														$output_text->insert('end', "$runcomOut\n");
														
														$base=$tempf;
														$mycom="$plink --bfile";
														}
														else
														{
														unlink $snp_list_rm;
														}
														
														#flip strand
														my $snp_list_flip;
														if($s_option eq "forward")
														{
														$snp_list_flip="$dir$outname.reverse";
																if(-s $snp_list_flip)
																{
																$output_text->insert('end',"Flip $sno2 SNPs...\n");
																print "Flip $sno2 SNPs...\n";
																
																my $runcom2="$mycom  $dir$base --flip $snp_list_flip --$out_format --out $dir$outname";
																my $runcomOut2=qx/$runcom2/;
														
																$output_text->insert('end', "$runcomOut2\n");
																}
																else
																{
																my $runcom3="$mycom  $dir$base --$out_format --out $dir$outname";
																my $runcomOut3=qx/$runcom3/;
														
																$output_text->insert('end', "$runcomOut3\n");
																
																$output_text->insert('end','All SNPs are already forward\n');
																print "All SNPs are already forward\n";
																unlink $snp_list_flip;
																}
														}
														elsif($s_option eq "reverse")
														{
														$snp_list_flip="$dir$outname.forward";
																if(-s $snp_list_flip)
																{
																$output_text->insert('end',"Flip $sno1 SNPs...\n");
																print "Flip $sno1 SNPs...\n";
																
																my $runcom4="$mycom  $dir$base --flip $snp_list_flip --$out_format --out $dir$outname";
																my $runcomOut4=qx/$runcom4/;
														
																$output_text->insert('end', "$runcomOut4\n");
																}
																else
																{
																my $runcom5="$mycom  $dir$base --$out_format --out $dir$outname";
																my $runcomOut5=qx/$runcom5/;
														
																$output_text->insert('end', "$runcomOut5\n");
																
																$output_text->insert('end',"All SNPs are already reverse\n");
																print "All SNPs are already forward\n";
																unlink $snp_list_flip;
																}
														}
														else
														{
														$output_text->insert('end', "Keep Strand.\n");
														
														my $runcom6="$mycom  $dir$base --$out_format --out $dir$outname";
														my $runcomOut6=qx/$runcom6/;
														
														$output_text->insert('end', "$runcomOut6\n");
														}
														
														#----------------------------------------
														if(-s $snp_list_rm)
														{
														unlink("$dir$base.bed");
														unlink("$dir$base.bim");
														unlink("$dir$base.fam");
														unlink("$dir$base.log");
														unlink("$dir$base.hh") if(-e "$dir$base.hh");
														}
													
														$output_text->insert('end', "Done.\n");
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
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
	my $annotation_frame=$option_frame->Frame()->pack(-side => "top", -anchor=>'w'); # annotation resource frame
		$annotation_frame->Label(-text=>'Annotation')->pack(-side => "left");
		$annotation_frame->Radiobutton(-text=> 'Mapping 500K', -value=>"snp500k", -variable=>\$r_option)->pack(-side => 'left');	
		$annotation_frame->Radiobutton(-text=> 'Genome-Wide SNP 5.0', -value=>"snp5", -variable=>\$r_option)->pack(-side => 'left');
		$annotation_frame->Radiobutton(-text=> 'Genome-Wide SNP 6.0', -value=>"snp6", -variable=>\$r_option)->pack(-side => 'left');
	my $strand_frame=$option_frame->Frame()->pack(-side => "top", -anchor=>'w'); # out put strand frame
		$strand_frame->Label(-text=>'Flip strand to             ')->pack(-side => "left");
		$strand_frame->Radiobutton(-text=> 'All forward       ', -value=>"forward", -variable=>\$s_option)->pack(-side => 'left');	
		$strand_frame->Radiobutton(-text=> 'All reverse       ', -value=>"reverse", -variable=>\$s_option)->pack(-side => 'left');
		$strand_frame->Radiobutton(-text=> 'No change                       ', -value=>"nochange", -variable=>\$s_option)->pack(-side => 'left');
}


###############################################################################################################################
########################						   sub download  		    							#######################	
###############################################################################################################################

###-----------------------------------
sub downloadAffy6
{
my ($output_text)=@_;
print "Download annotation file\nconnecting to web...";
$output_text->insert('end', "Download annotation file\nconnecting to web..."); #log
	my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/affy6.strand.tar.gz");
	if($headinfo[1])
	{
	print "Ok.\n";
	$output_text->insert('end', "Ok.\n"); #log
		if(-e "$Bin/../resources/Affymatrix/affy6.strand")
		{
		my $filesize = -s "$Bin/../resources/Affymatrix/affy6.strand.tar.gz";
		# my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/affy6.strand.tar.gz");
			if($filesize == $headinfo[1])
			{
			print "ipgwas/resources/Affymatrix/affy6.strand is already the newest one\nDone.\n";
			$output_text->insert('end', "ipgwas/resources/Affymatrix/affy6.strand is already the newest one\nDone.\n"); #log
			}
			else
			{
			unlink "$Bin/../resources/Affymatrix/affy6.strand";
			print "Downloading file...\n";
			
			my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/affy6.strand.tar.gz", "$Bin/../resources/Affymatrix/affy6.strand.tar.gz");
			print "Unziping file...\n";
			my $ar = Archive::Extract->new( archive => "$Bin/../resources/Affymatrix/affy6.strand.tar.gz");
			my $targetDir="$Bin/../resources/Affymatrix/";
			my $ok = $ar->extract( to => $targetDir) or die;
			# unlink "$Bin/../resources/Affymatrix/affy6.strand.tar.gz";
			print "Download finished.\n";
			$output_text->insert('end', "Downloading file...\n"); #log
			$output_text->insert('end', "Unziping file...\n"); #log
			$output_text->insert('end', "Download finished.\n"); #log
			}
		}
		else
		{
			print "Downloading file...\n";
			my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/affy6.strand.tar.gz", "$Bin/../resources/Affymatrix/affy6.strand.tar.gz");
			print "Unziping file...\n";
			my $ar = Archive::Extract->new( archive => "$Bin/../resources/Affymatrix/affy6.strand.tar.gz");
			my $targetDir="$Bin/../resources/Affymatrix/";
			my $ok = $ar->extract( to => $targetDir) or die;
			# unlink "$Bin/../resources/Affymatrix/affy6.strand.tar.gz";
			print "Download finished.\n";
			$output_text->insert('end', "Downloading file...\n"); #log
			$output_text->insert('end', "Unziping file...\n"); #log
			$output_text->insert('end', "Download finished.\n"); #log
		}
	}
	else
	{
	print "failed connection.\n";
	$output_text->insert('end', "failed connection.\n"); #log
	}
}
###-----------------------------------
sub downloadAffy5
{
my ($output_text)=@_;
print "Download annotation file\nconnecting to web...";
$output_text->insert('end', "Download annotation file\nconnecting to web..."); #log
	my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/affy5.strand.tar.gz");
	if($headinfo[1])
	{
	print "Ok.\n";
	$output_text->insert('end', "Ok.\n"); #log
		if(-e "$Bin/../resources/Affymatrix/affy5.strand")
		{
		my $filesize = -s "$Bin/../resources/Affymatrix/affy5.strand.tar.gz";
		# my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/affy5.strand.tar.gz");
			if($filesize == $headinfo[1])
			{
			print "ipgwas/resources/Affymatrix/affy5.strand is already the newest one\nDone.\n";
			$output_text->insert('end', "ipgwas/resources/Affymatrix/affy5.strand is already the newest one\nDone.\n"); #log
			}
			else
			{
			unlink "$Bin/../resources/Affymatrix/affy5.strand";
			print "Downloading file...\n";
			my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/affy5.strand.tar.gz", "$Bin/../resources/Affymatrix/affy5.strand.tar.gz");
			print "Unziping file...\n";
			my $ar = Archive::Extract->new( archive => "$Bin/../resources/Affymatrix/affy5.strand.tar.gz");
			my $targetDir="$Bin/../resources/Affymatrix/";
			my $ok = $ar->extract( to => $targetDir) or die;
			# unlink "$Bin/../resources/Affymatrix/affy5.strand.tar.gz";
			print "Download finished.\n";
			$output_text->insert('end', "Downloading file...\n"); #log
			$output_text->insert('end', "Unziping file...\n"); #log
			$output_text->insert('end', "Download finished.\n"); #log
			}
		}
		else
		{
			print "Downloading file...\n";
			my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/affy5.strand.tar.gz", "$Bin/../resources/Affymatrix/affy5.strand.tar.gz");
			print "Unziping file...\n";
			my $ar = Archive::Extract->new( archive => "$Bin/../resources/Affymatrix/affy5.strand.tar.gz");
			my $targetDir="$Bin/../resources/Affymatrix/";
			my $ok = $ar->extract( to => $targetDir) or die;
			# unlink "$Bin/../resources/Affymatrix/affy5.strand.tar.gz";
			print "Download finished.\n";
			$output_text->insert('end', "Downloading file...\n"); #log
			$output_text->insert('end', "Unziping file...\n"); #log
			$output_text->insert('end', "Download finished.\n"); #log
		}
	}
	else
	{
	print "failed connection.\n";
	$output_text->insert('end', "failed connection.\n"); #log
	}
}
###-----------------------------------
sub downloadAffy500k
{
my ($output_text)=@_;
print "Download annotation file\nconnecting to web...";
$output_text->insert('end', "Download annotation file\nconnecting to web..."); #log
	my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/affy500k.strand.tar.gz");
	if($headinfo[1])
	{
	print "Ok.\n";
	$output_text->insert('end', "Ok.\n"); #log
		if(-e "$Bin/../resources/Affymatrix/affy500k.strand")
		{
		my $filesize = -s "$Bin/../resources/Affymatrix/affy500k.strand.tar.gz";
		# my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/affy500k.strand.tar.gz");
			if($filesize == $headinfo[1])
			{
			print "ipgwas/resources/Affymatrix/affy500k.strand is already the newest one\nDone.\n";
			$output_text->insert('end', "ipgwas/resources/Affymatrix/affy6.strand is already the newest one\nDone.\n"); #log
			}
			else
			{
			unlink "$Bin/../resources/Affymatrix/affy500k.strand";
			print "Downloading file...\n";
			my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/affy500k.strand.tar.gz", "$Bin/../resources/Affymatrix/affy500k.strand.tar.gz");
			print "Unziping file...\n";
			my $ar = Archive::Extract->new( archive => "$Bin/../resources/Affymatrix/affy500k.strand.tar.gz");
			my $targetDir="$Bin/../resources/Affymatrix/";
			my $ok = $ar->extract( to => $targetDir) or die;
			# unlink "$Bin/../resources/Affymatrix/affy500k.strand.tar.gz";
			print "Download finished.\n";
			$output_text->insert('end', "Downloading file...\n"); #log
			$output_text->insert('end', "Unziping file...\n"); #log
			$output_text->insert('end', "Download finished.\n"); #log
			}
		}
		else
		{
			print "Downloading file...\n";
			my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/affy500k.strand.tar.gz", "$Bin/../resources/Affymatrix/affy500k.strand.tar.gz");
			print "Unziping file...\n";
			my $ar = Archive::Extract->new( archive => "$Bin/../resources/Affymatrix/affy500k.strand.tar.gz");
			my $targetDir="$Bin/../resources/Affymatrix/";
			my $ok = $ar->extract( to => $targetDir) or die;
			# unlink "$Bin/../resources/Affymatrix/affy500k.strand.tar.gz";
			print "Download finished.\n";
			$output_text->insert('end', "Downloading file...\n"); #log
			$output_text->insert('end', "Unziping file...\n"); #log
			$output_text->insert('end', "Download finished.\n"); #log
		}
	}
	else
	{
	print "failed connection.\n";
	$output_text->insert('end', "failed connection.\n"); #log
	}
}

1;
