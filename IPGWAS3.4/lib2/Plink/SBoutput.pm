package Plink::SBoutput;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use Tk::LabFrame;

###---------
sub outputFrame
{
my ($inFrame, $beforeFrame)=@_;

#$inFrame -> parent frame of input frame
#$beforeFrame -> output frame pack before this frame

my $output_frame=$inFrame->LabFrame(-label=>"Output File", -labelside=>'acrosstop')->pack(-side => "top", -before=> $beforeFrame, -anchor=>'w'); #output frame
return $output_frame;
}

###---------
# sub outputFormat
# {
# my ($inFrame)=@_; 
# my $out_format;
# my $out_format_frame=$inFrame->Frame()->pack(-side=>"top", -anchor=>'w');
	# $out_format_frame->Label(-text=>"Output Format:")->pack(-side=>"left");
	# $out_format_frame->Radiobutton(-text=>"Standard(--recode)", -value=>"recode", -variable=>\$out_format)->pack(-side => "left", -anchor=>"w");
	# $out_format_frame->Radiobutton(-text=>"Binary(--make-bed)", -value=>"make-bed", -variable=>\$out_format)->pack(-side => "left", -anchor=>"w");
	# $out_format_frame->Radiobutton(-text=>"Haploview(--recodeHV)", -value=>"recodeHV", -variable=>\$out_format)->pack(-side => "left", -anchor=>"w");
# return $out_format;
# }

###---------
sub outputName
{
my ($inFrame)=@_; 
my $out_name;
#$inFrame -> parent frame of input frame
my $out_name_frame=$inFrame->Frame()->pack(-side=>"top", -anchor=>'w');
	$out_name_frame->Label(-text=>"Output File Name:	")->pack(-side=>"left");
	$out_name=$out_name_frame->Text(-height => 1, -width => 62)->pack(-side=>"left");
	$out_name->delete('0.0','end');
return $out_name;
}

1;
