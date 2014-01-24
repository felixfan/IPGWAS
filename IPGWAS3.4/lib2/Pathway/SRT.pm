package Pathway::SRT;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;
use Plink::SBinput;
use Plink::SBoutput;
use Downloads::DownloadResource;

sub SNPRatioTest
{
my($output_text, $mw, $gp_win, $plink)=@_;

$output_text->delete("0.0","end");         #log

my $input_path="";
my $output_name="";
my $ooo;
my $ok_frame;

$gp_win->geometry("500x310");
$gp_win->title("SNP Ratio Test");

$gp_win->resizable(0, 0);

my $mod="topn";
my $kegg="default";
my ($T1, $T2, $T3);

#input_frame
my $ttt=Plink::SBinput::InputFrame($gp_win);
$input_path=Plink::SBinput::InputContentFam($mw, $ttt);
										  
#sub ok button
$ok_frame = $gp_win->Frame(-borderwidth=>2, -relief=> "groove")->pack(-side => "top"); # button frame
	$ok_frame->Button(-text => "OK",-command =>sub{
														###INPUT
														my $inpath=$input_path->get('0.0', 'end');
															chomp $inpath;
															if(! $inpath)
															{
															$output_text->insert('end', "No .fam file\n");
															die "No .fam file: $!\n";
															}
														
														my($base,$dir,$ext)=fileparse($inpath,'\..*');
															if(! -e "$dir$base.bed")
															{
															$output_text->insert('end', "No .bed file\n");
															die "No .bed file: $!\n";
															}
															if(! -e "$dir$base.bim")
															{
															$output_text->insert('end', "No .bim file\n");
															die "No .bim file: $!\n";
															}
														### number of Alt phts
														my $alt_n=$T2->get('0.0', 'end');
														chomp $alt_n;
															if(! $alt_n)
															{
															$output_text->insert('end', "Please specify the number of alternative phenotypes\n");
															die "Please specify the number of alternative phenotypes: $!\n";
															}
															elsif($alt_n < 1000)
															{
															$output_text->insert('end', "WARNING!\tYou specified [$alt_n\] alternative phenotypes to generate.\nThis is quite low. You should really specify at least 1000\n\n");
															}
											
														### p cutoff
														my $p_cut=$T3->get('0.0', 'end');
														chomp $p_cut;
															if(! $p_cut || $p_cut <=0 || $p_cut >=1)
															{
															$output_text->insert('end', "Please specify the p-value threshold\n");
															die "Please specify the p-value threshold: $!\n";
															}
															else
															{
															$output_text->insert('end', "You specified $p_cut as the p-value threshold\n\n");
															}
														### pathway
														my $resource;
														
														if($kegg eq "default")
														{
															if(!-e "$Bin/../resources/SRT/KEGG_2_snp_b129.txt")
															{
															Downloads::DownloadResource::downloadKEGG($output_text);
															}
															$resource="$Bin/../resources/SRT/KEGG_2_snp_b129.txt";
															$output_text->insert('end', "You specified KEGG as the pathway dataset\n\n");
														}
														else
														{
															$resource=$T1->get('0.0', 'end');
															chomp $resource;
															if(! $resource)
															{
															$output_text->insert('end', "Please specify the pathway dataset\n");
															die "Please specify the pathway dataset: $!\n";
															}
															$output_text->insert('end', "You specified $resource as the pathway dataset\n\n");
														}
														
														### outname
														my $outname=$output_name->get('0.0', 'end');
														chomp $outname;
															if(! $outname)
															{
															$output_text->insert('end', "Please specify the output name\n");
															die "Please specify the output name: $!\n";
															}
														### STEP 1: prepare alternative phenotypes
														$output_text->insert('end', "Prepare alternative phenotypes...\n\n");
														system("perl $Bin/make_alt_pheno.pl $inpath $alt_n");
														### STEP 2: generate a ¡°.assoc¡± file for the original dataset
														$output_text->insert('end', "Do association test for the original dataset...\n\n");
														system("$plink --bfile $dir$base --assoc --out $dir$outname.original");
														### STEP 3: run alternative phenotype simulations
														$output_text->insert('end', "Run alternative phenotype simulations...\n\n");
														system("$plink --bfile $dir$base --pheno $dir$base.fam.altpheno.$alt_n.txt --all-pheno --assoc --out $dir$outname");
														### STEP 4: parse out the SNP and p-value from all simulations and original data
														$output_text->insert('end', "parse out the SNP and p-value from all simulations and original data...\n\n");
														system("perl $Bin/parse_assoc_files.pl $dir");
														################### 
														if($mod eq "topn") ### method 1: top n
														{
														$output_text->insert('end', "SNP ratio test method: top n snps\n\n");
														### STEP 5: get the numbers of SNPs that pass your threshold of interest
														$output_text->insert('end', "get the numbers of SNPs that pass your threshold of interest...\n\n");
														
														my $count=0;
														open (IN, "$dir$outname.original.assoc.forSRT");
														while (<IN>) {
															if ($_ !~ /^SNP/) {
																my @split = split(/\s+/, $_);
																my $p = $split[1];
																if ($p <= $p_cut ) {
																	$count++;
																}
															}	
														}
														print "$count significant SNPs\n\n";
														$output_text->insert('end', "$count significant SNPs\n\n");
														
														### STEP 6: apply the SRT to the original GWAS dataset
														$output_text->insert('end', "apply the SRT to the original GWAS dataset...\n\n");
														system("perl $Bin/run_SRT_on_ORIGINAL.pl $p_cut $dir$outname.original.assoc.forSRT $resource");
														
														### STEP 7: apply the SRT to all simulations
														$output_text->insert('end', "apply the SRT to all simulations\n\n");
														system("perl $Bin/run_SRT_on_SIMS.pl $count $resource $dir");
														}
														else ### method 2: p cutoff
														{
														$output_text->insert('end', "SNP ratio test method: p-value cut-off\n\n");
														### STEP 4,5,6 ALTERNATIVE
														### apply the SRT to the original GWAS dataset and to all simulations
														$output_text->insert('end', "apply the SRT to the original GWAS dataset and to all simulations\n\n");
														system("perl $Bin/run_SRT_on_ALL.pl $p_cut $resource $dir");
														}
														##################### 
														### STEP 8: calculate an empirical p-value for the statistically significant enrichment of GWAS associated SNPs within each KEGG pathway
														$output_text->insert('end', "calculate an empirical p-value for the statistically significant enrichment of GWAS associated SNPs within each KEGG pathway\n\n");
														system("perl $Bin/get_SRT_p_value.pl $dir$outname.original.assoc.forSRT.p$p_cut.ratios $p_cut");
														
														### STEP 9: delete files generated before
														$output_text->insert('end', "delete files generated before\n\n");
														system("perl $Bin/cleanup.pl $dir");
														
														$output_text->insert('end', "Done.\n");
														print "Done.\n";
												}
						)->pack(-side => "left");
		$ok_frame->Button(-text => "Close", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");	

#output_frame
$ooo=Plink::SBoutput::outputFrame($gp_win, $ok_frame);
my $out_format_frame=$ooo->Frame()->pack(-side=>"top", -anchor=>'w');
$output_name=Plink::SBoutput::outputName($ooo);

#option_frame
my $option_frame=$gp_win->LabFrame(-label=>"Options", -labelside=>'acrosstop')->pack(-side => "top", -before=>$ooo, -anchor=>'w'); #option frame
	my $mod_frame=$option_frame->Frame()->pack(-side => "top", -anchor=>'w'); # model frame
		$mod_frame->Label(-text=>'SNP Ratio Test Methods:')->pack(-side => "left");
		$mod_frame->Radiobutton(-text=>"Top N SNPs", -value=> "topn", -variable=>\$mod)->pack(-side => "left");
		$mod_frame->Radiobutton(-text=>"P-value Cut-off", -value=> "pcut", -variable=>\$mod)->pack(-side => "left");
	my $alt_frame=$option_frame->Frame()->pack(-side => "top", -anchor=>'w'); # alternative phenotypes frame
		$alt_frame->Label(-text=>'number of alternative phenotypes')->pack(-side => "left");
		$T2=$alt_frame->Text(-height => 1, -width => 45)->pack(-side=>"left");
	my $p_frame=$option_frame->Frame()->pack(-side => "top", -anchor=>'w'); # p cutoff frame
		$p_frame->Label(-text=>'p-value threshold')->pack(-side => "left");
		$T3=$p_frame->Text(-height => 1, -width => 55)->pack(-side=>"left");
	my $path_frame=$option_frame->Frame()->pack(-side => "top", -anchor=>'w'); # default pathway data frame
		$path_frame->Radiobutton(-text=>"Default pathway dataset (KEGG)", -value=> "default", -variable=>\$kegg)->pack(-side => "left");
	my $alt_path_frame=$option_frame->Frame()->pack(-side => "top", -anchor=>'w'); # alternative pathway data frame
		$alt_path_frame->Radiobutton(-text=>"Alternative", -value=> "alt", -variable=>\$kegg)->pack(-side => "left");
		$T1=$alt_path_frame->Text(-height => 1, -width => 45)->pack(-side=>"left");
		$alt_path_frame->Button(-text => 'Browse',
													-command => sub	{
																	$T1->delete('0.0', 'end');
																	$input_path=$mw->getOpenFile(-filetypes=>[
																											['txt files', '.txt'],
																											['All files', '*'],
																																					]);
																	$T1->insert('end', $input_path);
																	}
													)->pack(-side => "left");
		
}

1;
