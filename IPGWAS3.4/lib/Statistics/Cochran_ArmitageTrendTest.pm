package Statistics::Cochran_ArmitageTrendTest;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use File::Basename;
use Statistics::Distributions qw (chisqrprob);

sub Cochran_ArmitageTrendTestPcalculator
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

$gp_win->geometry("450x220");
$gp_win->title("Cochran-Armitage Trend Test P value Calculator");

$gp_win->resizable(0, 0);

my $model="add"; #default

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);
			
#2x3 frame
my $obs2x3_frame=$gp_win->LabFrame(-label=>"Cochran-Armitage Trend Test", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); 
		my $obs2x3_frame2=$obs2x3_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
		$obs2x3_frame2->Label(-text=>"                 ")->pack(-side=>'left');
		$obs2x3_frame2->Label(-text=>"class 1                                 ")->pack(-side=>'left');
		$obs2x3_frame2->Label(-text=>"class 2                                 ")->pack(-side=>'left');
		$obs2x3_frame2->Label(-text=>"class 3                       ")->pack(-side=>'left');
		my $obs2x3_frame3=$obs2x3_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
		$obs2x3_frame3->Label(-text=>"case          ")->pack(-side=>'left');
		my $T7=$obs2x3_frame3->Text(-height => 1, -width => 14)->pack(-side=>"left");
		$T7->delete('0.0','end');
		$obs2x3_frame3->Label(-text=>"          ")->pack(-side=>'left');
		my $T8=$obs2x3_frame3->Text(-height => 1, -width => 14)->pack(-side=>"left");
		$T8->delete('0.0','end');
		$obs2x3_frame3->Label(-text=>"          ")->pack(-side=>'left');
		my $T9=$obs2x3_frame3->Text(-height => 1, -width => 14)->pack(-side=>"left");
		$T9->delete('0.0','end');
		my $obs2x3_frame4=$obs2x3_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
		$obs2x3_frame4->Label(-text=>"control       ")->pack(-side=>'left');
		my $T10=$obs2x3_frame4->Text(-height => 1, -width => 14)->pack(-side=>"left");
		$T10->delete('0.0','end');
		$obs2x3_frame4->Label(-text=>"          ")->pack(-side=>'left');
		my $T11=$obs2x3_frame4->Text(-height => 1, -width => 14)->pack(-side=>"left");
		$T11->delete('0.0','end');	
		$obs2x3_frame4->Label(-text=>"          ")->pack(-side=>'left');
		my $T12=$obs2x3_frame4->Text(-height => 1, -width => 14)->pack(-side=>"left");
		$T12->delete('0.0','end');
###model option frame
my $opt_frame=$gp_win->LabFrame(-label=>"Model Options", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
		$opt_frame->Radiobutton(-text=>"Additive (Codominant)          ", -value=>"add", -variable=>\$model)->pack(-side => "left", -anchor=>'w');
		$opt_frame->Radiobutton(-text=>"Dominant                       ", -value=>"dom", -variable=>\$model)->pack(-side => "left", -anchor=>'w');
		$opt_frame->Radiobutton(-text=>"Recessive                      ", -value=>"rec", -variable=>\$model)->pack(-side => "left", -anchor=>'w');
#output name frame
my $out_frame=$gp_win->LabFrame(-label=>"Results", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
	$out_frame->Label(-text=>"chi-square")->pack(-side=>'left');
	my $T13=$out_frame->Text(-height => 1, -width => 12)->pack(-side=>"left");
	$T13->delete('0.0','end');
	$out_frame->Label(-text=>"degree of freedom")->pack(-side=>'left');
	my $T14=$out_frame->Text(-height => 1, -width => 5)->pack(-side=>"left");
	$T14->delete('0.0','end');
	$out_frame->Label(-text=>"p value")->pack(-side=>'left');
	my $T15=$out_frame->Text(-height => 1, -width => 17)->pack(-side=>"left");
	$T15->delete('0.0','end');		
			
#ok frame
my $ok_frame=$gp_win->Frame(-borderwidth=>2)->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => " Calculate ",-command =>sub{
							my ($chi_p, $chi_chis, $fd);
							my $r0=$T7->get('0.0', 'end');
							my $r1=$T8->get('0.0', 'end');
							my $r2=$T9->get('0.0', 'end');
							my $s0=$T10->get('0.0', 'end');
							my $s1=$T11->get('0.0', 'end');
							my $s2=$T12->get('0.0', 'end');
							chomp $r0;
							chomp $r1;
							chomp $r2;
							chomp $s0;
							chomp $s1;
							chomp $s2;
							
							my $R=$r0+$r1+$r2;
							my $n0=$r0+$s0;
							my $n1=$r1+$s1;
							my $n2=$r2+$s2;
							
							my $N=$n0+$n1+$n2;
							
							if($model eq "add")
							{
							$chi_chis=($N*($N*($r1+2*$r2)-$R*($n1+2*$n2))**2)/(($N-$R)*$R*($N*($n1+4*$n2)-($n1+2*$n2)**2));
							}
							elsif($model eq "dom")
							{
							$chi_chis=($N*($N*($r1+$r2)-$R*($n1+$n2))**2)/(($N-$R)*$R*$n0*($n1+$n2));
							}
							elsif($model eq "rec")
							{
							$chi_chis=($N*($N*($r0+$r1)-$R*($n1+$n0))**2)/(($N-$R)*$R*$n2*($n1+$n0));
							}
							
							$fd=1;
							$chi_p=chisqrprob($fd, $chi_chis);
							
							$T13->delete('0.0','end');
							$T14->delete('0.0','end');
							$T15->delete('0.0','end');
							
							$T13->insert('end', $chi_chis);
							$T14->insert('end', $fd);
							$T15->insert('end', $chi_p);
							
											  }
				  )->pack(-side => "left");
		$ok_frame->Label(-text=>"           ")->pack(-side=>'left');
		$ok_frame->Button(-text => "   Clear   ", -command=>sub{
														$T7->delete('0.0','end');
														$T8->delete('0.0','end');
														$T9->delete('0.0','end');
														$T10->delete('0.0','end');
														$T11->delete('0.0','end');
														$T12->delete('0.0','end');
														$T13->delete('0.0','end');
														$T14->delete('0.0','end');
														$T15->delete('0.0','end');
														 }
						 )->pack(-side=>"left");
		$ok_frame->Label(-text=>"           ")->pack(-side=>'left');
		$ok_frame->Button(-text => "   Close   ", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

1;
