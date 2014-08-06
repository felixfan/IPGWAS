package Plink::SBinput;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use Tk::LabFrame;

use File::Basename;

###---------
sub InputFrame
{
my ($inFrame)=@_; 

#$inFrame -> parent frame of input frame

#input_frame
my $input_frame=$inFrame->LabFrame(-label=>"Input File", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
return $input_frame;
}

###---------
sub InputContent  ###ped/bed
{
my ($mw, $inFrame)=@_; # $mw ->main windows, $inFrame -> parent frame of input frame
my $input_path="";
my $dir;
my $base;
my $ext;
											
my $ped_frame=$inFrame->Frame()->pack(-side=>"top", -anchor=>'w'); #input-ped frame
	$ped_frame->Label(-text => "ped/bed File ")->pack(-side => "left");
	my $T=$ped_frame->Text(-height => 1, -width => 56)->pack(-side=>"left");
	$ped_frame->Button(-text => 'Browse',
						-command => sub	{
										$T->delete('0.0', 'end');
										$input_path=$mw->getOpenFile(-filetypes=>[
																					['BED files', '.bed'],
																					['PED files', '.ped'],
																					['All files', '*'],
																				]);
										$T->insert('end', $input_path);
										print "$input_path opened\n";
										($base,$dir,$ext)=fileparse($input_path,'\..*');
											if($ext=~/ped/i)
											{
												###map
												if(-e "$dir$base.map")
												{
												print "$dir$base.map opened\n";
												}
												else
												{
												die"Can not open $dir$base.map: $!\n";
												}
											}
											elsif($ext=~/bed/i)
											{
												###bim
												if(-e "$dir$base.bim")
												{
												print "$dir$base.bim opened\n";
												}
												else
												{
												die"Can not open $dir$base.bim: $!\n";
												}
												###fam
												if(-e "$dir$base.fam")
												{
												print "$dir$base.fam opened\n";
												}
												else
												{
												die"Can not open $dir$base.fam: $!\n";
												}
											}
										}
					)->pack(-side => "left");
	return $T;	
}

###---------
sub InputContentBim
{
my ($mw, $inFrame)=@_; # $mw ->main windows, $inFrame -> parent frame of input frame
my $input_path="";
my $dir;
my $base;
my $ext;
											
my $ped_frame=$inFrame->Frame()->pack(-side=>"top", -anchor=>'w'); #input-ped frame
	$ped_frame->Label(-text => "bim File ")->pack(-side => "left");
	my $T=$ped_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
	$ped_frame->Button(-text => 'Browse',
						-command => sub	{
										$T->delete('0.0', 'end');
										$input_path=$mw->getOpenFile(-filetypes=>[
																					['bim files', '.bim'],
																					['All files', '*'],
																				]);
										$T->insert('end', $input_path);
										print "$input_path opened\n";
										}
					)->pack(-side => "left");
	return $T;
}
###---------

sub InputContentFam
{
my ($mw, $inFrame)=@_; # $mw ->main windows, $inFrame -> parent frame of input frame
my $input_path="";
my $dir;
my $base;
my $ext;
											
my $ped_frame=$inFrame->Frame()->pack(-side=>"top", -anchor=>'w'); #input-ped frame
	$ped_frame->Label(-text => "fam File ")->pack(-side => "left");
	my $T=$ped_frame->Text(-height => 1, -width => 50)->pack(-side=>"left");
	$ped_frame->Button(-text => 'Browse',
						-command => sub	{
										$T->delete('0.0', 'end');
										$input_path=$mw->getOpenFile(-filetypes=>[
																					['fam files', '.fam'],
																					['All files', '*'],
																				]);
										$T->insert('end', $input_path);
										print "$input_path opened\n";
										}
					)->pack(-side => "left");
	return $T;
}
###---------
1;
