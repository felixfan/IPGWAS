package Downloads::DownloadResource;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use LWP::Simple;

sub downloadKEGG
{
my ($output_text)=@_;
print "Download KEGG pathway file\nconnecting to web...";
$output_text->insert('end', "Download KEGG pathway file\nconnecting to web..."); #log
	my @headinfo = LWP::Simple::head("http://nchc.dl.sourceforge.net/project/ipgwas/resources/KEGG_2_snp_b129.txt.tar.gz");
	if($headinfo[1])
	{
	print "Ok.\n";
	$output_text->insert('end', "Ok.\n"); #log
		if(-e "$Bin/../resources/SRT/KEGG_2_snp_b129.txt")
		{
		my $filesize = -s "$Bin/../resources/SRT/KEGG_2_snp_b129.txt.tar.gz";
			if($filesize == $headinfo[1])
			{
			print "ipgwas/resources/SRT/KEGG_2_snp_b129.txt is already the newest one\nDone.\n";
			$output_text->insert('end', "ipgwas/resources/SRT/KEGG_2_snp_b129.txt is already the newest one\nDone.\n"); #log
			}
			else
			{
			unlink "$Bin/../resources/SRT/KEGG_2_snp_b129.txt";
			print "Downloading file...\n";
			
			my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/KEGG_2_snp_b129.txt.tar.gz", "$Bin/../resources/SRT/KEGG_2_snp_b129.txt.tar.gz");
			print "Unziping file...\n";
			my $gzfile="$Bin/../resources/SRT/KEGG_2_snp_b129.txt.tar.gz";
			my $targetDir="$Bin/../resources/SRT/";
			system("$Bin/extract.pl $gzfile $targetDir");
			print "Download finished.\n";
			$output_text->insert('end', "Downloading file...\n"); #log
			$output_text->insert('end', "Unziping file...\n"); #log
			$output_text->insert('end', "Download finished.\n"); #log
			}
		}
		else
		{
			print "Downloading file...\n";
			
			my $downfile=getstore("http://nchc.dl.sourceforge.net/project/ipgwas/resources/KEGG_2_snp_b129.txt.tar.gz", "$Bin/../resources/SRT/KEGG_2_snp_b129.txt.tar.gz");
			print "Unziping file...\n";
			my $gzfile="$Bin/../resources/SRT/KEGG_2_snp_b129.txt.tar.gz";
			my $targetDir="$Bin/../resources/SRT/";
			system("$Bin/extract.pl $gzfile $targetDir");
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


1;
