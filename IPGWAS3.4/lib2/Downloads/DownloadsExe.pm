package Downloads::DownloadsExe;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use Archive::Extract;
use LWP::Simple;

use File::Basename;

###############################################################################################################################
########################						   sub download  		    							#######################	
###############################################################################################################################

###-----------------------------------
sub downloadPlinkWin
{
my ($output_text)=@_;
	if(!-e "$Bin/plink.exe")
	{
	print "Download executable PLINK.\nconnecting to web...";
	$output_text->insert('end', "Download executale PLINK\nconnecting to web..."); #log
	my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/plink.exe.tar.gz");
		if($headinfo[1])
		{
		print "Ok.\n";
		$output_text->insert('end', "Ok.\n"); #log
		print "Downloading file...\n";
		my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/plink.exe.tar.gz", "$Bin/plink.exe.tar.gz");
		print "Unziping file...\n";
		my $ar = Archive::Extract->new( archive => "$Bin/plink.exe.tar.gz");
		my $targetDir="$Bin/";
		my $ok = $ar->extract( to => $targetDir) or die;
		unlink "$Bin/plink.exe.tar.gz";
		print "Download finished.\n";
		$output_text->insert('end', "Downloading file...\n"); #log
		$output_text->insert('end', "Unziping file...\n"); #log
		$output_text->insert('end', "Download finished.\n"); #log
		}
		else
		{
		print "failed connection.\nSome functions of IPGWAS will not be usable without PLINK\n";
		$output_text->insert('end', "failed connection.\nSome functions of IPGWAS will not be usable without PLINK\n"); #log
		}
	}
}
###-----------------------------------
sub downloadPlinkLinux
{
my ($output_text)=@_;
	if(!-e "$Bin/plink_linux")
	{
	print "Download executable PLINK.\nconnecting to web...";
	$output_text->insert('end', "Download executale PLINK\nconnecting to web..."); #log
	my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/plink_linux.tar.gz");
		if($headinfo[1])
		{
		print "Ok.\n";
		$output_text->insert('end', "Ok.\n"); #log
		print "Downloading file...\n";
		my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/plink_linux.tar.gz", "$Bin/plink_linux.tar.gz");
		print "Unziping file...\n";
		my $ar = Archive::Extract->new( archive => "$Bin/plink_linux.tar.gz");
		my $targetDir="$Bin/";
		my $ok = $ar->extract( to => $targetDir) or die;
		system("chmod +x $Bin/plink_linux");
		unlink "$Bin/plink_linux.tar.gz";
		print "Download finished.\n";
		$output_text->insert('end', "Downloading file...\n"); #log
		$output_text->insert('end', "Unziping file...\n"); #log
		$output_text->insert('end', "Download finished.\n"); #log
		}
		else
		{
		print "failed connection.\nSome functions of IPGWAS will not be usable without PLINK\n";
		$output_text->insert('end', "failed connection.\nSome functions of IPGWAS will not be usable without PLINK\n"); #log
		}
	}
}
###-----------------------------------
sub downloadPlinkMac
{
my ($output_text)=@_;
	if(!-e "$Bin/plink_mac")
	{
	print "Download executable PLINK.\nconnecting to web...";
	$output_text->insert('end', "Download executale PLINK\nconnecting to web..."); #log
	my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/plink_mac.tar.gz");
		if($headinfo[1])
		{
		print "Ok.\n";
		$output_text->insert('end', "Ok.\n"); #log
		print "Downloading file...\n";
		my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/plink_mac.tar.gz", "$Bin/plink_mac.tar.gz");
		print "Unziping file...\n";
		my $ar = Archive::Extract->new( archive => "$Bin/plink_mac.tar.gz");
		my $targetDir="$Bin/";
		my $ok = $ar->extract( to => $targetDir) or die;
		system("chmod +x $Bin/plink_mac");
		unlink "$Bin/plink_mac.tar.gz";
		print "Download finished.\n";
		$output_text->insert('end', "Downloading file...\n"); #log
		$output_text->insert('end', "Unziping file...\n"); #log
		$output_text->insert('end', "Download finished.\n"); #log
		}
		else
		{
		print "failed connection.\nSome functions of IPGWAS will not be usable without PLINK\n";
		$output_text->insert('end', "failed connection.\nSome functions of IPGWAS will not be usable without PLINK\n"); #log
		}
	}
}
###-----------------------------------
sub downloadGnuplotWin
{
my ($output_text)=@_;
	if(!-e "$Bin/wgnuplot.exe")
	{
	print "Download executable GNUPLOT.\nconnecting to web...";
	$output_text->insert('end', "Download executale GNUPLOT\nconnecting to web..."); #log
	my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/wgnuplot.exe.tar.gz");
		if($headinfo[1])
		{
		print "Ok.\n";
		$output_text->insert('end', "Ok.\n"); #log
		print "Downloading file...\n";
		my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/wgnuplot.exe.tar.gz", "$Bin/wgnuplot.exe.tar.gz");
		print "Unziping file...\n";
		my $ar = Archive::Extract->new( archive => "$Bin/wgnuplot.exe.tar.gz");
		my $targetDir="$Bin/";
		my $ok = $ar->extract( to => $targetDir) or die;
		unlink "$Bin/wgnuplot.exe.tar.gz";
		print "Download finished.\n";
		$output_text->insert('end', "Downloading file...\n"); #log
		$output_text->insert('end', "Unziping file...\n"); #log
		$output_text->insert('end', "Download finished.\n"); #log
		}
		else
		{
		print "failed connection.\nSome functions of IPGWAS will not be usable without Gnuplot\n";
		$output_text->insert('end', "failed connection.\nSome functions of IPGWAS will not be usable without Gnuplot\n"); #log
		}
	}
}
###-----------------------------------
sub downloadGnuplotLinux
{
my ($output_text)=@_;
	if(!-e "$Bin/gnuplot_linux")
	{
	print "Download executable GNUPLOT.\nconnecting to web...";
	$output_text->insert('end', "Download executale GNUPLOT\nconnecting to web..."); #log
	my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/gnuplot_linux.tar.gz");
		if($headinfo[1])
		{
		print "Ok.\n";
		$output_text->insert('end', "Ok.\n"); #log
		print "Downloading file...\n";
		my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/gnuplot_linux.tar.gz", "$Bin/gnuplot_linux.tar.gz");
		print "Unziping file...\n";
		my $ar = Archive::Extract->new( archive => "$Bin/gnuplot_linux.tar.gz");
		my $targetDir="$Bin/";
		my $ok = $ar->extract( to => $targetDir) or die;
		system("chmod +x $Bin/gnuplot_linux");
		unlink "$Bin/gnuplot_linux.tar.gz";
		print "Download finished.\n";
		$output_text->insert('end', "Downloading file...\n"); #log
		$output_text->insert('end', "Unziping file...\n"); #log
		$output_text->insert('end', "Download finished.\n"); #log
		}
		else
		{
		print "failed connection.\nSome functions of IPGWAS will not be usable without Gnuplot\n";
		$output_text->insert('end', "failed connection.\nSome functions of IPGWAS will not be usable without Gnuplot\n"); #log
		}
	}
}
###-----------------------------------
sub downloadGnuplotMac
{
my ($output_text)=@_;
	if(!-e "$Bin/gnuplot_mac")
	{
	print "Download executable GNUPLOT.\nconnecting to web...";
	$output_text->insert('end', "Download executale GNUPLOT\nconnecting to web..."); #log
	my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/gnuplot_mac.tar.gz");
		if($headinfo[1])
		{
		print "Ok.\n";
		$output_text->insert('end', "Ok.\n"); #log
		print "Downloading file...\n";
		my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/gnuplot_mac.tar.gz", "$Bin/gnuplot_mac.tar.gz");
		print "Unziping file...\n";
		my $ar = Archive::Extract->new( archive => "$Bin/gnuplot_mac.tar.gz");
		my $targetDir="$Bin/";
		my $ok = $ar->extract( to => $targetDir) or die;
		system("chmod +x $Bin/gnuplot_mac");
		unlink "$Bin/gnuplot_mac.tar.gz";
		print "Download finished.\n";
		$output_text->insert('end', "Downloading file...\n"); #log
		$output_text->insert('end', "Unziping file...\n"); #log
		$output_text->insert('end', "Download finished.\n"); #log
		}
		else
		{
		print "failed connection.\nSome functions of IPGWAS will not be usable without Gnuplot\n";
		$output_text->insert('end', "failed connection.\nSome functions of IPGWAS will not be usable without Gnuplot\n"); #log
		}
	}
}
###-----------------------------------


1;
