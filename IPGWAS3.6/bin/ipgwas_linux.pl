#!/usr/bin/perl -w
use strict;

use Tk;
use Tk::LabFrame;

use File::Basename;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use Archive::Extract;
use LWP::Simple;

my $convert_mach="$Bin/convert_mach.pl";
my $convert_mach2snptest="$Bin/convert_mach2snptest.pl";
my $CATassoc="$Bin/cat.pl";
my $Assoc="$Bin/assoc.pl";
my $smartplot="$Bin/smartplot.pl";
my $plink2machExe="$Bin/ped2mach.pl";
my $plink2imputeExe="$Bin/ped2impute.pl";
my $impute2plinkExe="$Bin/impute2tped.pl";

my $ver='3.4'; # version
###revised on 15 July 2012

my $mw = MainWindow->new;
$mw->geometry("610x400");
$mw->title("IPGWAS: Integrated Pipeline for Genome-wide Association Studies.");

$mw->resizable(0, 0);

my $main_menu = $mw->Menu();
$mw->configure(-menu => $main_menu);

#######################################################################################
use Plink::Recode;
use Plink::Flip;
use Plink::MergeFiles;
use Plink::WriteSNPList;
use Plink::UpdateInfo;
use Plink::ExRmIndivSNP;
use Plink::SumStats;
use Plink::Filters;
use Plink::IBSIBD;
use Plink::Association;
use QC::sexCheck;
use QC::missCheck;
use QC::lmissHis;
use QC::HWEQQplot;
use QC::relatednessPlots;
use QC::heterozygosity;
use QC::MissingVSheterozygosity;
use QC::LDprune;
use QC::identifyDiffCaseControl;
use Merge::diffStrandSNPs;
use Merge::AffymetrixCheckStrand;
use Merge::commonSNPs;
use Merge::CheckSNPsOrderChrPhy;
use Merge::extractChrPP;
use Convert::Eig2Assoc;
use Convert::Mach2Assoc;
use Convert::PEDMAP2PHASE;
use Convert::GWAMA;
use Convert::PEDMAP2BEAGLE;
use Convert::PEDMAP2MACH;
use Convert::PEDMAP2IMPUTE;
use Convert::IMPUTE2TPED;
use Plot::QQplot;
use Plot::ManhattanPlot;
use Plot::EIGplot;
use Statistics::caTest;
use Statistics::assocTest;
use Statistics::chiSquareTest;
use Statistics::Cochran_ArmitageTrendTest;
use Statistics::FisherExactTest;
use Pathway::SRT;
use Downloads::DownloadsExe;
use Downloads::DownloadResource;
use Manipulation::QCpht;
use Manipulation::subjectsFilter;
use Manipulation::chromosomeSplit;
use Manipulation::assocFilter;
#######################################################################################

#######################################################################################
### 							igwas--plink                                        ###
#######################################################################################
my $plink_menu = $main_menu->cascade(-label => "Plink", -underline => 0);
$plink_menu->separator;
###Data management tools----------------------------------------------------------------
my $dm=$plink_menu->cascade(-label=> 'Data Management', -underline =>0); 
	$dm->separator;
	$dm->command(-label =>'Recode', -underline=>0, -command =>\&Recode);
	$dm->separator;
	$dm->command(-label =>'Flip Strand', -underline=>0, -command=>\&Flip);
	$dm->separator;
	$dm->command(-label =>'Merge Two Filesets', -underline=>0, -command=>\&Merge2File);
	$dm->separator;
	$dm->command(-label =>'Merge Multiple Filesets', -underline=>0, -command=>\&MergeFilesets);
	$dm->separator;
	$dm->command(-label =>'Write SNP List Files', -underline=>0, -command=>\&WriteSNP);
	$dm->separator;
	$dm->command(-label =>'Update SNP information', -underline=>0, -command=>\&UpSNPinfo);
	$dm->separator;
	$dm->command(-label =>'Update Allele Information', -underline=>0, -command=>\&UpAlleleInfo);
	$dm->separator;
	$dm->command(-label =>'Update Individual Information', -underline=>0, -command=>\&UpIndivInfo);
	$dm->separator;
	$dm->command(-label =>'Extract a Subset of SNPs', -underline=>0, -command=>\&ExtractSNPs);
	$dm->separator;
	$dm->command(-label =>'Remove a Subset of SNPs', -underline=>0, -command=>\&RemoveSNPs);
	$dm->separator;
	$dm->command(-label =>'Extract a Subset of Individuals', -underline=>0, -command=>\&ExtractIndividuals);
	$dm->separator;
	$dm->command(-label =>'Remove a Subset of Individuals', -underline=>0, -command=>\&RemoveIndividuals);
	$dm->separator;
$plink_menu->separator;
###Summary statistics-----------------------------------------------------------------------
my $ss=$plink_menu->cascade(-label=> 'Summary Statistics', -underline =>0); 
	$ss->separator;
	$ss->command(-label =>'Missingness--Rate', -underline=>0, -command=>[\&SumStats0, "missing"]); 
	$ss->separator;
	$ss->command(-label =>'Missingness--Phenotype', -underline=>0, -command=>[\&SumStats1, "test-missing"]); 
	$ss->separator;
	$ss->command(-label =>'Missingness--Genotype', -underline=>0, -command=>[\&SumStats2, "test-mishap"]); 
	$ss->separator;
	$ss->command(-label =>'Hardy-Weinberg Equilibrium', -underline=>0, -command=>[\&SumStats3, "hardy"]);
	$ss->separator;
	$ss->command(-label =>'Allele Frequency', -underline=>0, -command=>[\&SumStats4, "freq"]);
	$ss->separator;
	$ss->command(-label =>'Mendel Errors', -underline=>0, -command=>[\&SumStats5, "mendel"]);
	$ss->separator;
	$ss->command(-label =>'Sex Check', -underline=>0, -command=>[\&SumStats6, "check-sex"]);
	$ss->separator;
	$ss->command(-label =>'Sex Impute', -underline=>0, -command=>\&ImputeSex);
	$ss->separator;
	$ss->command(-label =>'Linkage Disequilibrium Based SNP Pruning', -underline=>0, -command=>\&LDprune);
	$ss->separator;
$plink_menu->separator;
####filters-----------------------------------------------------------------------------------------------------
my $fs=$plink_menu->cascade(-label=> 'Filters', -underline =>0); 
	$fs->separator;
	$fs->command(-label =>'Individual Missingness', -underline=>0, -command=>[\&Filters0, "mind"]);
	$fs->separator;
	$fs->command(-label =>'Allele Frequency', -underline=>0, -command=>[\&Filters1, "maf"]);
	$fs->separator;
	$fs->command(-label =>'Marker Missingness', -underline=>0, -command=>[\&Filters2, "geno"]);
	$fs->separator;
	$fs->command(-label =>'Hardy-Weinberg Equilibrium', -underline=>0, -command=>[\&Filters3, "hwe"]);
	$fs->separator;
	$fs->command(-label =>'Mendel Error Rates', -underline=>0, -command=>[\&Filters4, "me"]);
	$fs->separator;
$plink_menu->separator;
#####IBS/IBD estimation-------------------------------------------------------------------------------------
my $iie=$plink_menu->cascade(-label=> 'IBS/IBD estimation', -underline =>0); 
	$iie->separator;
	$iie->command(-label =>'Pairwise IBD Estimation', -underline=>0, -command=>\&IbsIbdPIE);
	$iie->separator;
	$iie->command(-label =>'Inbreeding Coefficients', -underline=>0, -command=>\&IbsIbdHet);
	$iie->separator;
	$iie->command(-label =>'Runs of Homozygosity', -underline=>0, -command=>\&RunHomozyg);
	$iie->separator;
$plink_menu->separator;
#####Association analysis------------------------------------------------------------------------------
my $aa=$plink_menu->cascade(-label=> 'Association Analysis', -underline =>0);
	$aa->separator;
	$aa->command(-label =>'Basic Case/Control Association Test', -underline=>0, -command=>\&BasicAssociation);
	$aa->separator;
	$aa->command(-label =>'Full Model Association Tests', -underline=>0, -command=>\&ModelAssociation);
	$aa->separator;
	$aa->command(-label =>'Basic Linear and Logistic Models', -underline=>0, -command=>\&BasicLinear);
	$aa->separator;
	$aa->command(-label =>'Covariates and Interactions', -underline=>0, -command=>\&CovarInteract);
	$aa->separator;
$plink_menu->separator;
############					**************************								################

#####################################################################################################################
####							                  igwas--quality control										  ###
#####################################################################################################################
my $qc_menu = $main_menu->cascade(-label => "QC", -underline => 0);
$qc_menu->separator;
###individual qc
	my $individualQC=$qc_menu->cascade(-label=> 'Individual QC', -underline =>0); # individual qc
		$individualQC->separator; ###
		my $GC=$individualQC->command(-label=> 'Gender Check', -underline =>0, -command=>\&GenderCheck); # Gender Check, plot F, identify PROBLEM individuals
		$individualQC->separator; ###
		my $MCHET=$individualQC->cascade(-label=> 'Missingness and/or Heterozygosity', -underline =>0); #missingness or heterozygosity
			$MCHET->separator; ###
			my $MC=$MCHET->command(-label=> 'Missingness Check', -underline =>0, -command=>\&MissingnessCheck); # Missingness Check, plot call rate
			$MCHET->separator; ###
			my $HET=$MCHET->cascade(-label=> 'Heterozygosity and Inbreeding', -underline =>0); # heterozygosity and inbreeding
				$HET->separator;##
				$HET->command(-label=> 'Histogram of Heterozygosity and Inbreeding Coefficient', -underline =>0, -command=>\&hetInbreed);
				$HET->separator;##
				$HET->command(-label=> 'Identify Individuals Departure from Expected Heterozygosity', -underline =>0, -command=>\&IdentiHetInbreed);
				$HET->separator;##
			$MCHET->separator; ###
			my $MC2HET=$MCHET->cascade(-label=> 'Heterozygosity versus Heterozygosity', -underline =>0); # heterozygosity and inbreeding
				$MC2HET->separator;
				$MC2HET->command(-label=> 'Individual Missingness versus Heterozygosity Plot', -underline =>0, -command=>\&miss2het); # Missingness vs Heterozygosity Plot
				$MC2HET->separator;
				$MC2HET->command(-label=> 'Identify Individuals with High Missing Rate and/or Extreme Heterozygosity', -underline =>0, -command=>\&identifymiss2het); # Missingness vs Heterozygosity Plot
				$MC2HET->separator;
			$MCHET->separator; ###
		$individualQC->separator;###
		my $LDprune=$individualQC->command(-label=> 'High LD Pruning', -underline =>0, -command=>\&LDprune4b36);
		$individualQC->separator;###
		my $CRC=$individualQC->cascade(-label=> 'Cryptic Relatedness Check', -underline =>0); # Cryptic Relatedness Check, plot, identify related individual pairs
			$CRC->separator;##
			my $CRCplot=$CRC->cascade(-label=> 'Cryptic Relatedness Plot', -underline =>0);
				$CRCplot->separator;
				$CRCplot->command(-label=> 'Mean-Variance of IBS', -underline =>0, -command=>\&RelatednessPlot);
				$CRCplot->separator;
				$CRCplot->command(-label=> 'Histogram of IBD', -underline =>0, -command=>\&RelatednessPlot2);
				$CRCplot->separator;
			$CRC->separator;##
			my $CRCidentify=$CRC->cascade(-label=> 'Identify Related Individuals', -underline =>0);
				$CRCidentify->separator;
				$CRCidentify->command(-label=> 'Mean-Variance of IBS Cutoff', -underline =>0, -command=>\&identiDeviIBS);
				$CRCidentify->separator;
				$CRCidentify->command(-label=> 'PI_HAT Cutoff', -underline =>0, -command=>\&identiDeviIBD);
				$CRCidentify->separator;
			$CRC->separator;##
		$individualQC->separator;###
$qc_menu->separator;
###snp qc
	my $snpQC=$qc_menu->cascade(-label=> 'SNP QC', -underline =>0); # SNP qc
		$snpQC->separator;###
			my $MC2=$snpQC->cascade(-label=> 'SNP Missingness Check', -underline =>0); #Missingness Check
				$MC2->separator;
				$MC2->command(-label=> 'Missingness Check', -underline =>0, -command=>\&MissingnessCheck); # Missingness Check, plot call rate
				$MC2->separator;
				$MC2->command(-label=> 'Histogram of SNP Missingness', -underline =>0, -command=>\&lmissHis); # Missingness Check, plot call rate, histogram
				$MC2->separator;
		$snpQC->separator;###
		my $HWE=$snpQC->command(-label=> 'Hardy-Weinberg Equilibrium', -underline =>0, -command=>\&hweQQplot); # Hardy-Weinberg Equilibrium Check, qq plot
		$snpQC->separator;###
		my $diffMissing=$snpQC->command(-label=> 'Different Missingness between Cases and Controls', -underline =>0, -command=>\&diffMissing); # DIFFERENT MISSING BATWEEN CASE AND CONTROL
		$snpQC->separator;###
$qc_menu->separator;
############					**************************								################


#####################################################################################################################
####							                       Merge Common SNPs										  ###
#####################################################################################################################
my $MCS=$main_menu->cascade(-label=> 'Combine', -underline =>0); # Merge Common SNPs
	$MCS->separator;	
		my $rmbadSNP_menu=$MCS->command(-label=> 'Option 1: Remove Bad SNPs', -underline =>0, -command=>\&RmBadSNPs); #option 1: remove bad SNPs
	$MCS->separator;
		my $check_strand_menu=$MCS->cascade(-label=> 'Option 2: Check Strand', -underline =>0); #check strand information for SNP
		$check_strand_menu->separator;	
			$check_strand_menu->command(-label => "Affymetrix SNPs", -underline => 0, -command => \&AffyCS);
		$check_strand_menu->separator;
			$check_strand_menu->command(-label => "Identify & Extract Common SNPs", -underline => 0, -command => \&IdComSNPs);
		$check_strand_menu->separator;
	$MCS->separator;
		$MCS->command(-label => "Check SNPs Information", -underline => 0, -command => \&CheckOrderChrPhy); # check oredr, chr, phy
	$MCS->separator;
		$MCS->command(-label => "Extract Chromosome & Physical Position", -underline => 0, -command => \&extractChrPP);
	$MCS->separator;
############					**************************								################	

#####################################################################################################################
####							                          Manipulation								    		  ###
#####################################################################################################################
my $DMT=$main_menu->cascade(-label=> 'Manipulation', -underline =>0); # DATA  Manipulation Tools
	$DMT->separator;
	$DMT->command(-label => "Change Affection status", -underline => 0, -command => \&QCpht); #change affection status column, set phenotype as: -9 = missing, 0 = missing, 1 = unaffected, 2 = affected.
	$DMT->separator;
	$DMT->command(-label => "Subjects Filter", -underline => 0, -command => \&subjectsFilter);
	$DMT->separator;
	$DMT->command(-label => "Split Genotype data by Chromosome", -underline => 0, -command => \&chrSplit);
	$DMT->separator;
	$DMT->command(-label => "Association Result Filter", -underline => 0, -command => \&assocFilter);
	$DMT->separator;
#####################################################################################################################
####							                             Convert								    		  ###
#####################################################################################################################
my $convert=$main_menu->cascade(-label=> 'Convert', -underline =>0); # convert file format
	$convert->separator;
	my $eig=$convert->command(-label=> 'Eigenstrat(chi-square to p value)', -underline =>0, -command=>\&EigFormat2AssocFormat); #convert eigenstrat output to .assoc format 
	$convert->separator;
	my $mach=$convert->cascade(-label=> 'MACH', -underline =>0); #Convert MACH imputation results to standard PED and MAP files and SNPTEST files
		$mach->command(-label=> 'MACH2PLINK', -underline =>0, -command=>\&Mach2PedMap);
		$mach->separator;
		$mach->command(-label=> 'MACH2SNPTEST', -underline =>0, -command=>\&Mach2SNPTEST);
		$mach->separator;
		$mach->command(-label=> 'PLINK2MACH', -underline =>0, -command=>\&PedMap2Mach);
		$mach->separator;
	$convert->separator;
	my $impute=$convert->cascade(-label=> 'IMPUTE', -underline =>0); 
		$impute->command(-label=> 'PLINK2IMPUTE', -underline =>0, -command=>\&PedMap2Impute);
		$impute->separator;
		$impute->command(-label=> 'IMPUTE2PLINK', -underline =>0, -command=>\&Impute2TpedTfam);
		$impute->separator;
	$convert->separator;
	my $gwama=$convert->cascade(-label=> 'GWAMA', -underline =>0); #reformatting SNPTEST and PLINK output to GWAMA input format
		$gwama->command(-label=> 'PLINK2GWAMA', -underline =>0, -command=>\&plink2gwama);
		$gwama->separator;
		$gwama->command(-label=> 'SNPTEST2GWAMA', -underline =>0, -command=>\&snptest2gwama);
		$gwama->separator;
	$convert->separator;
	my $beagle=$convert->command(-label=> 'PLINK2BEAGLE', -underline =>0, -command=>\&pedmap2beagle); #convert ped/map to BEAGLE input file format 
	$convert->separator;
	my $phase=$convert->command(-label=> 'PLINK2PHASE', -underline =>0, -command=>\&pedmap2phase); #convert ped/map to PHASE input file format 
	$convert->separator;
#####################################################################################################################
####							                             Plot       										  ###
#####################################################################################################################
my $plot=$main_menu->cascade(-label=> 'Plot', -underline =>0); # convert file format
	$plot->separator;
	my $qq=$plot->command(-label=> 'Quantile-Quantile Plot', -underline =>0, -command=>\&qqPlot); 
	$plot->separator;
	my $man=$plot->command(-label=> 'Manhattan Plot', -underline =>0, -command=>\&manPlot); 
	$plot->separator;
	my $eigplot=$plot->command(-label=> 'Plot EIG', -underline =>0, -command=>\&eigPlot); 
	$plot->separator;
######################################################################################################################
####										  statistics														######
######################################################################################################################
my $stats=$main_menu->cascade(-label=> 'Statistics', -underline =>0);
$stats->separator;
	my $caTest=$stats->command(-label=> 'Cochran-Armitage Trend Test', -underline =>0, -command=>\&caTrendTest);
$stats->separator;
	my $assocTest=$stats->command(-label=> 'Association Test', -underline =>0, -command=>\&assocTests);
$stats->separator;
	my $pCalculator=$stats->cascade(-label=> 'P-Value Calculator', -underline =>0);
		$pCalculator->separator;
		my $chisquare2x2=$pCalculator->command(-label=> 'Chi-Square Test', -underline =>0, -command=>\&chiSquareTest);
		$pCalculator->separator;
		my $sta_caTT=$pCalculator->command(-label=> 'Cochran-Armitage Trend Test', -underline =>0, -command=>\&Cochran_ArmitageTrendTest);
		$pCalculator->separator;
		my $fisher=$pCalculator->command(-label=> 'Fisher\'s Exact Test', -underline =>0, -command=>\&FisherExactTest);
		$pCalculator->separator;
$stats->separator;
######################################################################################################################
####										  pathway analysis													######
######################################################################################################################
my $pathway=$main_menu->cascade(-label=> 'Pathway', -underline =>0);
$pathway->separator;
	my $srt=$pathway->command(-label=> 'SNP Ratio Test', -underline =>0, -command=>\&SRTest);
$pathway->separator;
######################################################################################################################
####										  Downloads  														######
######################################################################################################################
my $download=$main_menu->cascade(-label=> 'Download', -underline=>0);
		$download->separator;
			my $downAffy6=$download->command(-label=> 'Affymetrix 6.0 Strand', -underline =>0, -command=>\&downloadAffy6);
		$download->separator;
			my $downAffy5=$download->command(-label=> 'Affymetrix 5.0 Strand', -underline =>0, -command=>\&downloadAffy5);
		$download->separator;
			my $downAffy500k=$download->command(-label=> 'Affymetrix 500k Strand', -underline =>0, -command=>\&downloadAffy500k);
		$download->separator;
			my $downKEGG=$download->command(-label=> 'KEGG Pathway', -underline =>0, -command=>\&downloadKEGG);
		$download->separator;
######################################################################################################################
####										igwas --help														######
######################################################################################################################
my $help_menu = $main_menu->cascade(-label => "Help", -underline => 0);
$help_menu->separator;
	$help_menu->command(-label => "Version", -underline => 0, -command => sub{$mw->messageBox(-message => "Version: $ver", -type => "ok")});
$help_menu->separator;
$help_menu->command(-label => "Manual", -underline => 0, -command => \&Manual);
$help_menu->separator;
$help_menu->command(-label => "Home Page", -underline => 0, -command => \&homepage);
$help_menu->separator;
#########################							*****************								####################


######################################################################################################################
####										igwas --log														 	######
######################################################################################################################
my $log_frame = $mw->LabFrame(-label=>"Log Viewer", -labelside=>'acrosstop')->pack(-side => "top");
my $output_frame = $log_frame->Frame()->pack(-side => "top");
my $output_scroll = $output_frame->Scrollbar();
my $output_text = $output_frame->Text(-yscrollcommand => ['set', $output_scroll]);
#########################							*****************								####################

$output_scroll->configure(-command => ['yview', $output_text]);
$output_scroll->pack(-side => "right", -expand => "no", -fill => "y");
$output_text->pack();

###Download executable Plink & Gnuplot
Downloads::DownloadsExe::downloadPlinkLinux($output_text);
Downloads::DownloadsExe::downloadGnuplotLinux($output_text);

my $plink="$Bin/plink_linux";
my $gnuplot="$Bin/gnuplot_linux";

MainLoop;
###********************************************************************************************************************###

### sub manual
sub Manual
{
system("evince $Bin/../manual/IPGWAS_Manual.pdf");
}

sub homepage
{
system("xdg-open http://sourceforge.net/projects/ipgwas/");
}

###############################################################################################################################
########################						sub Plink												#######################	
###############################################################################################################################

###-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
###Data management
my ($gp_win_plink_dm_1, $gp_win_plink_dm_2, $gp_win_plink_dm_3, $gp_win_plink_dm_4, $gp_win_plink_dm_5);
my ($gp_win_plink_dm_6, $gp_win_plink_dm_7, $gp_win_plink_dm_8, $gp_win_plink_dm_9, $gp_win_plink_dm_10);
my ($gp_win_plink_dm_11, $gp_win_plink_dm_12);
###-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

###----------
sub Recode
{
	if(! Exists ($gp_win_plink_dm_1))
	{
	$gp_win_plink_dm_1 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_dm_1->deiconify();
	$gp_win_plink_dm_1->raise();
	}
Plink::Recode::RecodeBHS($output_text, $mw, $gp_win_plink_dm_1, $plink);
}
###----------
sub Flip
{
if(! Exists ($gp_win_plink_dm_2))
	{
	$gp_win_plink_dm_2 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_dm_2->deiconify();
	$gp_win_plink_dm_2->raise();
	}
Plink::Flip::FlipStrand($output_text, $mw, $gp_win_plink_dm_2, $plink);
}
###---------
sub Merge2File
{
if(! Exists ($gp_win_plink_dm_3))
	{
	$gp_win_plink_dm_3 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_dm_3->deiconify();
	$gp_win_plink_dm_3->raise();
	}
Plink::MergeFiles::Merge2File($output_text, $mw, $gp_win_plink_dm_3, $plink);
}
###---------
sub MergeFilesets
{
if(! Exists ($gp_win_plink_dm_4))
	{
	$gp_win_plink_dm_4 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_dm_4->deiconify();
	$gp_win_plink_dm_4->raise();
	}
Plink::MergeFiles::MergeMultipleFilesets($output_text, $mw, $gp_win_plink_dm_4, $plink);
}
###---------
sub WriteSNP
{
if(! Exists ($gp_win_plink_dm_5))
	{
	$gp_win_plink_dm_5 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_dm_5->deiconify();
	$gp_win_plink_dm_5->raise();
	}
Plink::WriteSNPList::WriteSNPs($output_text, $mw, $gp_win_plink_dm_5, $plink);
}
###---------
sub UpSNPinfo
{
if(! Exists ($gp_win_plink_dm_6))
	{
	$gp_win_plink_dm_6 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_dm_6->deiconify();
	$gp_win_plink_dm_6->raise();
	}
Plink::UpdateInfo::UpSNPinfo($output_text, $mw, $gp_win_plink_dm_6, $plink);
}
###---------
sub UpAlleleInfo
{
if(! Exists ($gp_win_plink_dm_7))
	{
	$gp_win_plink_dm_7 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_dm_7->deiconify();
	$gp_win_plink_dm_7->raise();
	}
Plink::UpdateInfo::UpAlleleInfo($output_text, $mw, $gp_win_plink_dm_7, $plink);
}
###---------
sub UpIndivInfo
{
if(! Exists ($gp_win_plink_dm_8))
	{
	$gp_win_plink_dm_8 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_dm_8->deiconify();
	$gp_win_plink_dm_8->raise();
	}
Plink::UpdateInfo::UpIndivInfo($output_text, $mw, $gp_win_plink_dm_8, $plink);
}
###---------
sub ExtractSNPs
{
if(! Exists ($gp_win_plink_dm_12))
	{
	$gp_win_plink_dm_12 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_dm_12->deiconify();
	$gp_win_plink_dm_12->raise();
	}
Plink::ExRmIndivSNP::ExtractSubsetSNPs($output_text, $mw, $gp_win_plink_dm_12, $plink);
}
###---------
sub RemoveSNPs
{
if(! Exists ($gp_win_plink_dm_9))
	{
	$gp_win_plink_dm_9 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_dm_9->deiconify();
	$gp_win_plink_dm_9->raise();
	}
Plink::ExRmIndivSNP::ExIndivRmIndivSNP($output_text, $mw, $gp_win_plink_dm_9, "exclude", $plink);
}
###---------
sub ExtractIndividuals
{
if(! Exists ($gp_win_plink_dm_10))
	{
	$gp_win_plink_dm_10 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_dm_10->deiconify();
	$gp_win_plink_dm_10->raise();
	}
Plink::ExRmIndivSNP::ExIndivRmIndivSNP($output_text, $mw, $gp_win_plink_dm_10, "keep", $plink);
}
###---------
sub RemoveIndividuals
{
if(! Exists ($gp_win_plink_dm_11))
	{
	$gp_win_plink_dm_11 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_dm_11->deiconify();
	$gp_win_plink_dm_11->raise();
	}
Plink::ExRmIndivSNP::ExIndivRmIndivSNP($output_text, $mw, $gp_win_plink_dm_11, "remove", $plink);
}
###---------

###-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
###Summary statistics
my ($gp_win_plink_ss_1, $gp_win_plink_ss_2, $gp_win_plink_ss_3, $gp_win_plink_ss_4, $gp_win_plink_ss_5);
my ($gp_win_plink_ss_6, $gp_win_plink_ss_7, $gp_win_plink_ss_8, $gp_win_plink_ss_9);
###-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

###----------
sub SumStats0
{
	if(! Exists ($gp_win_plink_ss_1))
	{
	$gp_win_plink_ss_1 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_ss_1->deiconify();
	$gp_win_plink_ss_1->raise();
	}
my ($option)=@_;
Plink::SumStats::SummaryStatistics($output_text, $mw, $gp_win_plink_ss_1, $option, $plink);
}
###----------
sub SumStats1
{
	if(! Exists ($gp_win_plink_ss_2))
	{
	$gp_win_plink_ss_2 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_ss_2->deiconify();
	$gp_win_plink_ss_2->raise();
	}
my ($option)=@_;
Plink::SumStats::SummaryStatistics($output_text, $mw, $gp_win_plink_ss_2, $option, $plink);
}
###----------
sub SumStats2
{
	if(! Exists ($gp_win_plink_ss_3))
	{
	$gp_win_plink_ss_3 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_ss_3->deiconify();
	$gp_win_plink_ss_3->raise();
	}
my ($option)=@_;
Plink::SumStats::SummaryStatistics($output_text, $mw, $gp_win_plink_ss_3, $option, $plink);
}
###----------
sub SumStats3
{
	if(! Exists ($gp_win_plink_ss_4))
	{
	$gp_win_plink_ss_4 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_ss_4->deiconify();
	$gp_win_plink_ss_4->raise();
	}
my ($option)=@_;
Plink::SumStats::SummaryStatistics($output_text, $mw, $gp_win_plink_ss_4, $option, $plink);
}
###----------
sub SumStats4
{
	if(! Exists ($gp_win_plink_ss_5))
	{
	$gp_win_plink_ss_5 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_ss_5->deiconify();
	$gp_win_plink_ss_5->raise();
	}
my ($option)=@_;
Plink::SumStats::SummaryStatistics($output_text, $mw, $gp_win_plink_ss_5, $option, $plink);
}
###----------
sub SumStats5
{
	if(! Exists ($gp_win_plink_ss_6))
	{
	$gp_win_plink_ss_6 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_ss_6->deiconify();
	$gp_win_plink_ss_6->raise();
	}
my ($option)=@_;
Plink::SumStats::SummaryStatistics($output_text, $mw, $gp_win_plink_ss_6, $option, $plink);
}
###----------
sub SumStats6
{
	if(! Exists ($gp_win_plink_ss_7))
	{
	$gp_win_plink_ss_7 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_ss_7->deiconify();
	$gp_win_plink_ss_7->raise();
	}
my ($option)=@_;
Plink::SumStats::SummaryStatistics($output_text, $mw, $gp_win_plink_ss_7, $option, $plink);
}
###----------
sub ImputeSex
{
	if(! Exists ($gp_win_plink_ss_8))
	{
	$gp_win_plink_ss_8 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_ss_8->deiconify();
	$gp_win_plink_ss_8->raise();
	}
Plink::SumStats::ImputeSex($output_text, $mw, $gp_win_plink_ss_8, $plink);
}
###----------
sub LDprune
{
	if(! Exists ($gp_win_plink_ss_9))
	{
	$gp_win_plink_ss_9 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_ss_9->deiconify();
	$gp_win_plink_ss_9->raise();
	}
Plink::SumStats::LDprune($output_text, $mw, $gp_win_plink_ss_9, $plink);
}
###----------

###--------------------------------------------------------------------------------------------------------------------------------------------------
###Filters
my ($gp_win_plink_fs_1, $gp_win_plink_fs_2, $gp_win_plink_fs_3, $gp_win_plink_fs_4, $gp_win_plink_fs_5);
###--------------------------------------------------------------------------------------------------------------------------------------------------

###----------
sub Filters0
{
	if(! Exists ($gp_win_plink_fs_1))
	{
	$gp_win_plink_fs_1 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_fs_1->deiconify();
	$gp_win_plink_fs_1->raise();
	}
Plink::Filters::FiltersThresholds($output_text, $mw, $gp_win_plink_fs_1, "mind", $plink);
}
###----------
sub Filters1
{
	if(! Exists ($gp_win_plink_fs_2))
	{
	$gp_win_plink_fs_2 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_fs_2->deiconify();
	$gp_win_plink_fs_2->raise();
	}
Plink::Filters::FiltersThresholds($output_text, $mw, $gp_win_plink_fs_2, "maf", $plink);
}
###----------
sub Filters2
{
	if(! Exists ($gp_win_plink_fs_3))
	{
	$gp_win_plink_fs_3 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_fs_3->deiconify();
	$gp_win_plink_fs_3->raise();
	}
Plink::Filters::FiltersThresholds($output_text, $mw, $gp_win_plink_fs_3, "geno", $plink);
}
###----------
sub Filters3
{
	if(! Exists ($gp_win_plink_fs_4))
	{
	$gp_win_plink_fs_4 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_fs_4->deiconify();
	$gp_win_plink_fs_4->raise();
	}
Plink::Filters::FiltersThresholds($output_text, $mw, $gp_win_plink_fs_4, "hwe", $plink);
}
###----------
sub Filters4
{
	if(! Exists ($gp_win_plink_fs_5))
	{
	$gp_win_plink_fs_5 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_fs_5->deiconify();
	$gp_win_plink_fs_5->raise();
	}
Plink::Filters::FiltersThresholds($output_text, $mw, $gp_win_plink_fs_5, "me", $plink);
}
###----------

###--------------------------------------------------------------------------------------------------------------------------------------------------
###IBS/IBD
my ($gp_win_plink_ibd_1, $gp_win_plink_ibd_2, $gp_win_plink_ibd_3);
###--------------------------------------------------------------------------------------------------------------------------------------------------

###----------
sub RunHomozyg
{
	if(! Exists ($gp_win_plink_ibd_1))
	{
	$gp_win_plink_ibd_1 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_ibd_1->deiconify();
	$gp_win_plink_ibd_1->raise();
	}
Plink::IBSIBD::IbsIbdHomozyg($output_text, $mw, $gp_win_plink_ibd_1, $plink);
}
###----------
sub IbsIbdPIE
{
	if(! Exists ($gp_win_plink_ibd_2))
	{
	$gp_win_plink_ibd_2 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_ibd_2->deiconify();
	$gp_win_plink_ibd_2->raise();
	}
Plink::IBSIBD::IbsIbdPIE($output_text, $mw, $gp_win_plink_ibd_2, $plink);
}
###----------
sub IbsIbdHet
{
	if(! Exists ($gp_win_plink_ibd_3))
	{
	$gp_win_plink_ibd_3 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_ibd_3->deiconify();
	$gp_win_plink_ibd_3->raise();
	}
Plink::IBSIBD::IbsIbdHet($output_text, $mw, $gp_win_plink_ibd_3, $plink);
}
###----------

###---------------------------------------------------------------------------------------------------------------------------------------------------
###Association
my ($gp_win_plink_aa_1, $gp_win_plink_aa_2, $gp_win_plink_aa_3, $gp_win_plink_aa_4); 
###---------------------------------------------------------------------------------------------------------------------------------------------------

###----------
sub BasicAssociation
{
	if(! Exists ($gp_win_plink_aa_1))
	{
	$gp_win_plink_aa_1 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_aa_1->deiconify();
	$gp_win_plink_aa_1->raise();
	}
Plink::Association::BasicAllelicAssoci($output_text, $mw, $gp_win_plink_aa_1, $plink);
}
###----------
sub ModelAssociation
{
	if(! Exists ($gp_win_plink_aa_2))
	{
	$gp_win_plink_aa_2 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_aa_2->deiconify();
	$gp_win_plink_aa_2->raise();
	}
Plink::Association::GenotypicAssoci($output_text, $mw, $gp_win_plink_aa_2, $plink);
}
###-----------
sub BasicLinear
{
	if(! Exists ($gp_win_plink_aa_3))
	{
	$gp_win_plink_aa_3 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_aa_3->deiconify();
	$gp_win_plink_aa_3->raise();
	}
Plink::Association::BasicLinearLogistic($output_text, $mw, $gp_win_plink_aa_3, $plink);
}
###----------
sub CovarInteract
{
	if(! Exists ($gp_win_plink_aa_4))
	{
	$gp_win_plink_aa_4 = $mw->Toplevel;
	}
	else
	{
	$gp_win_plink_aa_4->deiconify();
	$gp_win_plink_aa_4->raise();
	}
Plink::Association::CovarInteract($output_text, $mw, $gp_win_plink_aa_4, $plink);
}
###----------

###############################################################################################################################
########################						sub QC   												#######################	
###############################################################################################################################

my ($gp_win_qc_gc, $gp_win_qc_mc, $gp_win_qc_hwe, $gp_win_qc_rp, $gp_win_qc_rp2, $gp_win_qc_ir, $gp_win_qc_irp, $gp_win_qc_het, $gp_win_qc_ihf);
my ($gp_win_qc_miss2het, $gp_win_qc_identifymiss2het, $gp_win_qc_LDprune, $gp_win_qc_lmissHis, $gp_win_qc_diffmiss);

###----------
sub GenderCheck
{
	if(! Exists ($gp_win_qc_gc))
	{
	$gp_win_qc_gc = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_gc->deiconify();
	$gp_win_qc_gc->raise();
	}
QC::sexCheck::GenderCheck($output_text, $mw, $gp_win_qc_gc, $gnuplot);
}
###----------
sub MissingnessCheck
{
	if(! Exists ($gp_win_qc_mc))
	{
	$gp_win_qc_mc = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_mc->deiconify();
	$gp_win_qc_mc->raise();
	}
QC::missCheck::MissingnessCheck($output_text, $mw, $gp_win_qc_mc, $gnuplot);
}
###----------
sub hetInbreed
{
	if(! Exists ($gp_win_qc_het))
	{
	$gp_win_qc_het = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_het->deiconify();
	$gp_win_qc_het->raise();
	}
QC::heterozygosity::hetInbreeding($output_text, $mw, $gp_win_qc_het, $gnuplot);
}
###----------
sub IdentiHetInbreed
{
	if(! Exists ($gp_win_qc_ihf))
	{
	$gp_win_qc_ihf = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_ihf->deiconify();
	$gp_win_qc_ihf->raise();
	}
QC::heterozygosity::identiDeviHF($output_text, $mw, $gp_win_qc_ihf);
}
###----------
sub hweQQplot
{
if(! Exists ($gp_win_qc_hwe))
	{
	$gp_win_qc_hwe = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_hwe->deiconify();
	$gp_win_qc_hwe->raise();
	}
QC::HWEQQplot::hweQQplot($output_text, $mw, $gp_win_qc_hwe, $gnuplot);
}
###----------
sub RelatednessPlot
{
if(! Exists ($gp_win_qc_rp))
	{
	$gp_win_qc_rp = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_rp->deiconify();
	$gp_win_qc_rp->raise();
	}
QC::relatednessPlots::RelatednessPlot($output_text, $mw, $gp_win_qc_rp, $gnuplot);
}
###----------
sub RelatednessPlot2
{
if(! Exists ($gp_win_qc_rp2))
	{
	$gp_win_qc_rp2 = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_rp2->deiconify();
	$gp_win_qc_rp2->raise();
	}
QC::relatednessPlots::RelatednessPlot2($output_text, $mw, $gp_win_qc_rp2);
}
###----------
sub identiDeviIBS
{
if(! Exists ($gp_win_qc_ir))
	{
	$gp_win_qc_ir = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_ir->deiconify();
	$gp_win_qc_ir->raise();
	}
QC::relatednessPlots::identiDeviIBS($output_text, $mw, $gp_win_qc_ir);
}
###----------
sub identiDeviIBD
{
if(! Exists ($gp_win_qc_irp))
	{
	$gp_win_qc_irp = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_irp->deiconify();
	$gp_win_qc_irp->raise();
	}
QC::relatednessPlots::identiDeviIBD($output_text, $mw, $gp_win_qc_irp);
}
###----------
sub miss2het
{
if(! Exists ($gp_win_qc_miss2het))
	{
	$gp_win_qc_miss2het = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_miss2het->deiconify();
	$gp_win_qc_miss2het->raise();
	}
QC::MissingVSheterozygosity::missingnessVSheterozygosityPlot($output_text, $mw, $gp_win_qc_miss2het, $gnuplot);
}
sub identifymiss2het
{
if(! Exists ($gp_win_qc_identifymiss2het))
	{
	$gp_win_qc_identifymiss2het = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_identifymiss2het->deiconify();
	$gp_win_qc_identifymiss2het->raise();
	}
QC::MissingVSheterozygosity::identiMissHet($output_text, $mw, $gp_win_qc_identifymiss2het);
}
###----------
sub LDprune4b36
{
if(! Exists ($gp_win_qc_LDprune))
	{
	$gp_win_qc_LDprune = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_LDprune->deiconify();
	$gp_win_qc_LDprune->raise();
	}
QC::LDprune::LDprune4b36($output_text, $mw, $gp_win_qc_LDprune, $plink);
}
###----------
sub lmissHis
{
if(! Exists ($gp_win_qc_lmissHis))
	{
	$gp_win_qc_lmissHis = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_lmissHis->deiconify();
	$gp_win_qc_lmissHis->raise();
	}
QC::lmissHis::SNPmissingHis($output_text, $mw, $gp_win_qc_lmissHis);
}
###----------
sub diffMissing
{
if(! Exists ($gp_win_qc_diffmiss))
	{
	$gp_win_qc_diffmiss = $mw->Toplevel;
	}
	else
	{
	$gp_win_qc_diffmiss->deiconify();
	$gp_win_qc_diffmiss->raise();
	}
QC::identifyDiffCaseControl::identifyInforMissing($output_text, $mw, $gp_win_qc_diffmiss);
}
###----------

###############################################################################################################################
########################						sub merge common SNPs									#######################	
###############################################################################################################################
my($gp_win_mcs_irb, $gp_win_mcs_affy, $gp_win_mcs_cs, $gp_win_mcs_cocp, $gp_win_mcs_chr);
###----------
sub RmBadSNPs
{
if(! Exists ($gp_win_mcs_irb))
	{
	$gp_win_mcs_irb = $mw->Toplevel;
	}
	else
	{
	$gp_win_mcs_irb->deiconify();
	$gp_win_mcs_irb->raise();
	}
Merge::diffStrandSNPs::IdentifyDiffStrandSNPs($output_text, $mw, $gp_win_mcs_irb, $plink);
}
###----------
sub AffyCS
{
if(! Exists ($gp_win_mcs_affy))
	{
	$gp_win_mcs_affy = $mw->Toplevel;
	}
	else
	{
	$gp_win_mcs_affy->deiconify();
	$gp_win_mcs_affy->raise();
	}
Merge::AffymetrixCheckStrand::AffyCS($output_text, $mw, $gp_win_mcs_affy, $plink);
}
###----------
sub IdComSNPs
{
if(! Exists ($gp_win_mcs_cs))
	{
	$gp_win_mcs_cs = $mw->Toplevel;
	}
	else
	{
	$gp_win_mcs_cs->deiconify();
	$gp_win_mcs_cs->raise();
	}
Merge::commonSNPs::IdentifyExtractCommonSNPs($output_text, $mw, $gp_win_mcs_cs, $plink);
}
###----------
sub CheckOrderChrPhy
{
if(! Exists ($gp_win_mcs_cocp))
	{
	$gp_win_mcs_cocp = $mw->Toplevel;
	}
	else
	{
	$gp_win_mcs_cocp->deiconify();
	$gp_win_mcs_cocp->raise();
	}
Merge::CheckSNPsOrderChrPhy::CheckSNPsOrderChrPhyPos($output_text, $mw, $gp_win_mcs_cocp, $plink);
}
###----------
sub extractChrPP
{
if(! Exists ($gp_win_mcs_chr))
	{
	$gp_win_mcs_chr = $mw->Toplevel;
	}
	else
	{
	$gp_win_mcs_chr->deiconify();
	$gp_win_mcs_chr->raise();
	}
Merge::extractChrPP::extractChromosomePysicalPosition($output_text, $mw, $gp_win_mcs_chr);
}
###----------

my ($gp_win_dmt_pht, $gp_win_dmt_sf, $gp_win_dmt_cs, $gp_win_dmt_af);
sub QCpht
{
if(! Exists ($gp_win_dmt_pht))
	{
	$gp_win_dmt_pht = $mw->Toplevel;
	}
	else
	{
	$gp_win_dmt_pht->deiconify();
	$gp_win_dmt_pht->raise();
	}
Manipulation::QCpht::Setpht($output_text, $mw, $gp_win_dmt_pht, $plink);
}
###----------
sub subjectsFilter
{
if(! Exists ($gp_win_dmt_sf))
	{
	$gp_win_dmt_sf = $mw->Toplevel;
	}
	else
	{
	$gp_win_dmt_sf->deiconify();
	$gp_win_dmt_sf->raise();
	}
Manipulation::subjectsFilter::filtSubjects($output_text, $mw, $gp_win_dmt_sf, $plink);
}
###----------
sub chrSplit
{
if(! Exists ($gp_win_dmt_cs))
	{
	$gp_win_dmt_cs = $mw->Toplevel;
	}
	else
	{
	$gp_win_dmt_cs->deiconify();
	$gp_win_dmt_cs->raise();
	}
Manipulation::chromosomeSplit::Splitchr($output_text, $mw, $gp_win_dmt_cs, $plink);
}
###----------
sub assocFilter
{
if(! Exists ($gp_win_dmt_af))
	{
	$gp_win_dmt_af = $mw->Toplevel;
	}
	else
	{
	$gp_win_dmt_af->deiconify();
	$gp_win_dmt_af->raise();
	}
Manipulation::assocFilter::assocFilters($output_text, $mw, $gp_win_dmt_af);
}
###----------

###############################################################################################################################
########################						         sub convert									#######################	
###############################################################################################################################
my ($gp_win_con_eig, $gp_win_con_mach2pedmap, $gp_win_con_mach2snptest, $gp_win_con_phase, $gp_win_con_plink2gwama, $gp_win_con_snptest2gwama);
my ($gp_win_con_beagle, $gp_win_con_plink2mach, $gp_win_con_plink2impute, $gp_win_con_impute2plink);
###----------
sub EigFormat2AssocFormat
{
if(! Exists ($gp_win_con_eig))
	{
	$gp_win_con_eig = $mw->Toplevel;
	}
	else
	{
	$gp_win_con_eig->deiconify();
	$gp_win_con_eig->raise();
	}
Convert::Eig2Assoc::EigFormat2AssocFormat($output_text, $mw, $gp_win_con_eig);
}
###----------
sub Mach2PedMap
{
if(! Exists ($gp_win_con_mach2pedmap))
	{
	$gp_win_con_mach2pedmap = $mw->Toplevel;
	}
	else
	{
	$gp_win_con_mach2pedmap->deiconify();
	$gp_win_con_mach2pedmap->raise();
	}
Convert::Mach2Assoc::Mach2PedMap($output_text, $mw, $gp_win_con_mach2pedmap, $convert_mach);
}
###----------
sub Mach2SNPTEST
{
if(! Exists ($gp_win_con_mach2snptest))
	{
	$gp_win_con_mach2snptest = $mw->Toplevel;
	}
	else
	{
	$gp_win_con_mach2snptest->deiconify();
	$gp_win_con_mach2snptest->raise();
	}
Convert::Mach2Assoc::Mach2SNPTEST($output_text, $mw, $gp_win_con_mach2snptest, $convert_mach2snptest);
}
###----------
sub pedmap2phase
{
if(! Exists ($gp_win_con_phase))
	{
	$gp_win_con_phase = $mw->Toplevel;
	}
	else
	{
	$gp_win_con_phase->deiconify();
	$gp_win_con_phase->raise();
	}
Convert::PEDMAP2PHASE::pedmap2phase($output_text, $mw, $gp_win_con_phase);
}
###----------
sub plink2gwama
{
if(! Exists ($gp_win_con_plink2gwama))
	{
	$gp_win_con_plink2gwama = $mw->Toplevel;
	}
	else
	{
	$gp_win_con_plink2gwama->deiconify();
	$gp_win_con_plink2gwama->raise();
	}
Convert::GWAMA::PLINK2GWAMA($output_text, $mw, $gp_win_con_plink2gwama);
}
###----------
sub snptest2gwama
{
if(! Exists ($gp_win_con_snptest2gwama))
	{
	$gp_win_con_snptest2gwama = $mw->Toplevel;
	}
	else
	{
	$gp_win_con_snptest2gwama->deiconify();
	$gp_win_con_snptest2gwama->raise();
	}
Convert::GWAMA::SNPTEST2GWAMA($output_text, $mw, $gp_win_con_snptest2gwama);
}
###----------
sub pedmap2beagle
{
if(! Exists ($gp_win_con_beagle))
	{
	$gp_win_con_beagle = $mw->Toplevel;
	}
	else
	{
	$gp_win_con_beagle->deiconify();
	$gp_win_con_beagle->raise();
	}
Convert::PEDMAP2BEAGLE::pedmap2beagle($output_text, $mw, $gp_win_con_beagle);
}
###----------
sub PedMap2Mach
{
if(! Exists ($gp_win_con_plink2mach))
	{
	$gp_win_con_plink2mach = $mw->Toplevel;
	}
	else
	{
	$gp_win_con_plink2mach->deiconify();
	$gp_win_con_plink2mach->raise();
	}
Convert::PEDMAP2MACH::pedmap2mach($output_text, $mw, $gp_win_con_plink2mach, $plink2machExe);
}
###----------
sub PedMap2Impute
{
if(! Exists ($gp_win_con_plink2impute))
	{
	$gp_win_con_plink2impute = $mw->Toplevel;
	}
	else
	{
	$gp_win_con_plink2impute->deiconify();
	$gp_win_con_plink2impute->raise();
	}
Convert::PEDMAP2IMPUTE::pedmap2impute($output_text, $mw, $gp_win_con_plink2impute, $plink2imputeExe);
}
###----------
sub Impute2TpedTfam
{
if(! Exists ($gp_win_con_impute2plink))
	{
	$gp_win_con_impute2plink = $mw->Toplevel;
	}
	else
	{
	$gp_win_con_impute2plink->deiconify();
	$gp_win_con_impute2plink->raise();
	}
Convert::IMPUTE2TPED::impute2tpedtfam($output_text, $mw, $gp_win_con_impute2plink, $impute2plinkExe);
}
###----------
###############################################################################################################################
########################						           sub plot		    							#######################	
###############################################################################################################################
my ($gp_win_plot_qq, $gp_win_plot_man, $gp_win_plot_eig);
sub qqPlot
{
if(! Exists ($gp_win_plot_qq))
	{
	$gp_win_plot_qq = $mw->Toplevel;
	}
	else
	{
	$gp_win_plot_qq->deiconify();
	$gp_win_plot_qq->raise();
	}
Plot::QQplot::qqPlot($output_text, $mw, $gp_win_plot_qq, $gnuplot);
}
###-----------------------------------
sub manPlot
{
if(! Exists ($gp_win_plot_man))
	{
	$gp_win_plot_man = $mw->Toplevel;
	}
	else
	{
	$gp_win_plot_man->deiconify();
	$gp_win_plot_man->raise();
	}
Plot::ManhattanPlot::AssocManhattanPlot($output_text, $mw, $gp_win_plot_man, $gnuplot);
}
###-----------------------------------
sub eigPlot
{
if(! Exists ($gp_win_plot_eig))
	{
	$gp_win_plot_eig = $mw->Toplevel;
	}
	else
	{
	$gp_win_plot_eig->deiconify();
	$gp_win_plot_eig->raise();
	}
Plot::EIGplot::ploteig($output_text, $mw, $gp_win_plot_eig, $gnuplot, $smartplot);
}

###********************************************************************************************************************###

###############################################################################################################################
########################						   sub statistics		    							#######################	
###############################################################################################################################
my($gp_win_stats_caTest, $gp_win_stats_chiTest, $gp_win_stat_caTTP, $gp_win_stat_fisher, $gp_win_stat_assocTest);
sub caTrendTest
{
if(! Exists ($gp_win_stats_caTest))
	{
	$gp_win_stats_caTest = $mw->Toplevel;
	}
	else
	{
	$gp_win_stats_caTest->deiconify();
	$gp_win_stats_caTest->raise();
	}
Statistics::caTest::caTrendTest($output_text, $mw, $gp_win_stats_caTest,$CATassoc);
}
###-----------------------------------
sub assocTests
{
if(! Exists ($gp_win_stat_assocTest))
	{
	$gp_win_stat_assocTest = $mw->Toplevel;
	}
	else
	{
	$gp_win_stat_assocTest->deiconify();
	$gp_win_stat_assocTest->raise();
	}
Statistics::assocTest::assocTests($output_text, $mw, $gp_win_stat_assocTest, $Assoc);
}
###-----------------------------------
sub chiSquareTest
{
if(! Exists ($gp_win_stats_chiTest))
	{
	$gp_win_stats_chiTest = $mw->Toplevel;
	}
	else
	{
	$gp_win_stats_chiTest->deiconify();
	$gp_win_stats_chiTest->raise();
	}
Statistics::chiSquareTest::chiSquareTests($output_text, $mw, $gp_win_stats_chiTest);
}
###-----------------------------------
sub Cochran_ArmitageTrendTest
{
if(! Exists ($gp_win_stat_caTTP))
	{
	$gp_win_stat_caTTP = $mw->Toplevel;
	}
	else
	{
	$gp_win_stat_caTTP->deiconify();
	$gp_win_stat_caTTP->raise();
	}
Statistics::Cochran_ArmitageTrendTest::Cochran_ArmitageTrendTestPcalculator($output_text, $mw, $gp_win_stat_caTTP);
}
###-----------------------------------
sub FisherExactTest
{
if(! Exists ($gp_win_stat_fisher))
	{
	$gp_win_stat_fisher = $mw->Toplevel;
	}
	else
	{
	$gp_win_stat_fisher->deiconify();
	$gp_win_stat_fisher->raise();
	}
Statistics::FisherExactTest::FisherExactTestPcalculator($output_text, $mw, $gp_win_stat_fisher);
}
###-----------------------------------

###############################################################################################################################
########################						   sub pathway  		    							#######################	
###############################################################################################################################
my ($gp_win_path_srt);
sub SRTest
{
if(! Exists ($gp_win_path_srt))
	{
	$gp_win_path_srt = $mw->Toplevel;
	}
	else
	{
	$gp_win_path_srt->deiconify();
	$gp_win_path_srt->raise();
	}
Pathway::SRT::SNPRatioTest($output_text, $mw, $gp_win_path_srt, $plink);
}
###-----------------------------------

###############################################################################################################################
########################						   sub download  		    							#######################	
###############################################################################################################################
###----------------------------------
sub downloadAffy6
{
Merge::AffymetrixCheckStrand::downloadAffy6($output_text);
}
###-----------------------------------
sub downloadAffy5
{
Merge::AffymetrixCheckStrand::downloadAffy5($output_text);
}
###----------------------------------
sub downloadAffy500k
{
Merge::AffymetrixCheckStrand::downloadAffy500k($output_text);
}
###----------------------------------
sub downloadKEGG
{
Downloads::DownloadResource::downloadKEGG($output_text);
}
###-----------------------------------
###-----------------------------------------------END----------------------------------------------------------###
##########*******************************************************************************************#############
__END__

@ Yanhui Fan 2010

Email: nolanfyh@gmail.com  nolanfan@hku.hk
Tel: 852 5399 2796

Department of Biochemistry
Faculty of Medicine
The University of Hong Kong
21 Sassoon Road, Pokfulam, Hong Kong
