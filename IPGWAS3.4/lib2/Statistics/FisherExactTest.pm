package Statistics::FisherExactTest;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;

# use Text::NSP::Measures::2D::Fisher::twotailed;

use Text::NSP::Measures::2D::Fisher::twotailed;
use Text::NSP::Measures::2D::Fisher::left;
use Text::NSP::Measures::2D::Fisher::right;

sub FisherExactTestPcalculator
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

$gp_win->geometry("500x200");
$gp_win->title("Fisher's Exact Test P Value Calculator");

$gp_win->resizable(0, 0);

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#chi-square frame
#2x2 frame
my $obs2x2_frame=$gp_win->LabFrame(-label=>"2x2 Contingency Table", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); 
		my $obs2x2_frame2=$obs2x2_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
		# $obs2x2_frame2->Label(-text=>"          ")->pack(-side=>'left');
		$obs2x2_frame2->Label(-text=>"class 1                                            ")->pack(-side=>'left');
		# $obs2x2_frame2->Label(-text=>"                            ")->pack(-side=>'left');
		$obs2x2_frame2->Label(-text=>"class 2                ")->pack(-side=>'left');
		my $obs2x2_frame3=$obs2x2_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
		$obs2x2_frame3->Label(-text=>"case          ")->pack(-side=>'left');
		my $T3=$obs2x2_frame3->Text(-height => 1, -width => 25)->pack(-side=>"left");
		$T3->delete('0.0','end');
		$obs2x2_frame3->Label(-text=>"          ")->pack(-side=>'left');
		my $T4=$obs2x2_frame3->Text(-height => 1, -width => 25)->pack(-side=>"left");
		$T4->delete('0.0','end');
		my $obs2x2_frame4=$obs2x2_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
		$obs2x2_frame4->Label(-text=>"control       ")->pack(-side=>'left');
		my $T5=$obs2x2_frame4->Text(-height => 1, -width => 25)->pack(-side=>"left");
		$T5->delete('0.0','end');
		$obs2x2_frame4->Label(-text=>"          ")->pack(-side=>'left');
		my $T6=$obs2x2_frame4->Text(-height => 1, -width => 25)->pack(-side=>"left");
		$T6->delete('0.0','end');				
#output name frame
my $out_frame=$gp_win->LabFrame(-label=>"P value", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
	$out_frame->Label(-text=>"Two-tailed P")->pack(-side=>'left');
	my $T13=$out_frame->Text(-height => 1, -width => 12)->pack(-side=>"left");
	$T13->delete('0.0','end');
	$out_frame->Label(-text=>"Left-tailed")->pack(-side=>'left');
	my $T14=$out_frame->Text(-height => 1, -width => 12)->pack(-side=>"left");
	$T14->delete('0.0','end');
	$out_frame->Label(-text=>"Right-tailed")->pack(-side=>'left');
	my $T15=$out_frame->Text(-height => 1, -width => 12)->pack(-side=>"left");
	$T15->delete('0.0','end');		
			
#ok frame
my $ok_frame=$gp_win->Frame(-borderwidth=>2)->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => " Calculate ",-command =>sub{
							my $n11=$T3->get('0.0', 'end');
							my $n12=$T4->get('0.0', 'end');
							my $n21=$T5->get('0.0', 'end');
							my $n22=$T6->get('0.0', 'end');
							chomp $n11;
							chomp $n12;
							chomp $n21;
							chomp $n22;
							
							my $npp=$n11+$n12+$n21+$n22;
							my $np1=$n11+$n21;
							my $n1p=$n11+$n12;
							
							my $twotailed_value = Text::NSP::Measures::2D::Fisher::twotailed::calculateStatistic2( n11=>$n11,
                                      n1p=>$n1p,
                                      np1=>$np1,
                                      npp=>$npp);
							

							# if( ($errorCode = getErrorCode()))
							# {
							# die STDERR $errorCode." - ".getErrorMessage();
							# }
							
							my $left_value = Text::NSP::Measures::2D::Fisher::left::calculateStatisticL( n11=>$n11,
                                      n1p=>$n1p,
                                      np1=>$np1,
                                      npp=>$npp);
							# if( ($errorCode = getErrorCode()))
							# {
							# die STDERR $errorCode." - ".getErrorMessage();
							# }
							
							my $right_value = Text::NSP::Measures::2D::Fisher::right::calculateStatisticR( n11=>$n11,
                                      n1p=>$n1p,
                                      np1=>$np1,
                                      npp=>$npp);
							# if( ($errorCode = getErrorCode()))
							# {
							# die STDERR $errorCode." - ".getErrorMessage();
							# }
							
							$T13->delete('0.0','end');
							$T14->delete('0.0','end');
							$T15->delete('0.0','end');
														
							$T13->insert('end', $twotailed_value);
							$T14->insert('end', $left_value);
							$T15->insert('end', $right_value);
							
											  }
				  )->pack(-side => "left");
		$ok_frame->Label(-text=>"           ")->pack(-side=>'left');
		$ok_frame->Button(-text => "   Clear   ", -command=>sub{
														
														$T3->delete('0.0','end');
														$T4->delete('0.0','end');
														$T5->delete('0.0','end');
														$T6->delete('0.0','end');
														
														$T13->delete('0.0','end');
														$T14->delete('0.0','end');
														$T15->delete('0.0','end');
														 }
						 )->pack(-side=>"left");
		$ok_frame->Label(-text=>"           ")->pack(-side=>'left');
		$ok_frame->Button(-text => "   Close   ", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

1;
