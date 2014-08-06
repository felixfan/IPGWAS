package Statistics::chiSquareTest;

use warnings;
use strict;

use FindBin qw($Bin);
use lib "$Bin/../lib2";

use File::Basename;
use Statistics::Distributions qw (chisqrprob);

sub chiSquareTests
{
my($output_text, $mw, $gp_win)=@_;

$output_text->delete("0.0","end");         #log

$gp_win->geometry("500x450");
$gp_win->title("chi-Square Test P Value Calculator");

$gp_win->resizable(0, 0);

my $model="chi"; #default

my $gp_menu = $gp_win->Menu();
$gp_win->configure(-menu => $gp_menu);

#chi-square frame
my $chi_frame=$gp_win->LabFrame(-label=>"Calculate P-Value from chi-square and degree of freedom", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #input frame
	my $chi_frame1=$chi_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
		$chi_frame1->Radiobutton(-text=>"chi-square and degree of freedom                                                                 ", -value=>"chi", -variable=>\$model)->pack(-side => "left", -anchor=>'w');
	my $chi_frame2=$chi_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
		$chi_frame2->Label(-text=>"chi-square")->pack(-side=>'left');
		my $T1=$chi_frame2->Text(-height => 1, -width => 20)->pack(-side=>"left");
		$T1->delete('0.0','end');
		$chi_frame2->Label(-text=>"degree of freedom")->pack(-side=>'left');
		my $T2=$chi_frame2->Text(-height => 1, -width => 20)->pack(-side=>"left");
		$T2->delete('0.0','end');
#2x2 frame
my $obs2x2_frame=$gp_win->LabFrame(-label=>"2x2 Contingency Table", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
		my $obs2x2_frame1=$obs2x2_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
		$obs2x2_frame1->Radiobutton(-text=>"2x2 Contingency Table                                                                                  ", -value=>"e2x2", -variable=>\$model)->pack(-side => "left", -anchor=>'w');
		my $obs2x2_frame2=$obs2x2_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
		# $obs2x2_frame2->Label(-text=>"          ")->pack(-side=>'left');
		$obs2x2_frame2->Label(-text=>"class 1                                                ")->pack(-side=>'left');
		# $obs2x2_frame2->Label(-text=>"                       ")->pack(-side=>'left');
		$obs2x2_frame2->Label(-text=>"class 2                  ")->pack(-side=>'left');
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
#2x3 frame
my $obs2x3_frame=$gp_win->LabFrame(-label=>"2x3 Contingency Table", -labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #option frame
		my $obs2x3_frame1=$obs2x3_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
		$obs2x3_frame1->Radiobutton(-text=>"2x3 Contingency Table                                                                                   ", -value=>"e2x3", -variable=>\$model)->pack(-side => "left", -anchor=>'w');
		my $obs2x3_frame2=$obs2x3_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
		$obs2x3_frame2->Label(-text=>" ")->pack(-side=>'left');
		$obs2x3_frame2->Label(-text=>"class 1                            ")->pack(-side=>'left');
		$obs2x3_frame2->Label(-text=>"class 2                          ")->pack(-side=>'left');
		$obs2x3_frame2->Label(-text=>"class 3 ")->pack(-side=>'left');
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

#output name frame
my $out_frame=$gp_win->LabFrame(-label=>"Results",-labelside=>'acrosstop')->pack(-side=>"top", -anchor=>'w'); #output name frame
	my $out_frame1=$out_frame->Frame(-borderwidth=>2)->pack(-side=>"top");
	$out_frame1->Label(-text=>"chi-square")->pack(-side=>'left');
	my $T13=$out_frame1->Text(-height => 1, -width => 12)->pack(-side=>"left");
	$T13->delete('0.0','end');
	$out_frame1->Label(-text=>"degree of freedom")->pack(-side=>'left');
	my $T14=$out_frame1->Text(-height => 1, -width => 5)->pack(-side=>"left");
	$T14->delete('0.0','end');
	$out_frame1->Label(-text=>"p value")->pack(-side=>'left');
	my $T15=$out_frame1->Text(-height => 1, -width => 17)->pack(-side=>"left");
	$T15->delete('0.0','end');
	
my $out_frame2=$out_frame->Frame(-borderwidth=>2)->pack(-side=>"top", -anchor=>'w'); #output name frame 2
	$out_frame2->Label(-text=>"OR  ")->pack(-side=>'left');
	my $T93=$out_frame2->Text(-height => 1, -width => 8)->pack(-side=>"left");
	$T93->delete('0.0','end');
	$out_frame2->Label(-text=>"     SE  ")->pack(-side=>'left');
	my $T94=$out_frame2->Text(-height => 1, -width => 10)->pack(-side=>"left");
	$T94->delete('0.0','end');
	$out_frame2->Label(-text=>"     L95  ")->pack(-side=>'left');
	my $T95=$out_frame2->Text(-height => 1, -width => 10)->pack(-side=>"left");
	$T95->delete('0.0','end');
	$out_frame2->Label(-text=>"     U95  ")->pack(-side=>'left');
	my $T96=$out_frame2->Text(-height => 1, -width => 10)->pack(-side=>"left");
	$T96->delete('0.0','end');	
			
#ok frame
my $ok_frame=$gp_win->Frame(-borderwidth=>2)->pack(-side=>"top"); #ok frame
$ok_frame->Button(-text => " Calculate ",-command =>sub{
							my ($chi_p, $chi_chis, $fd);
							if($model eq "chi")
							{
							$chi_chis=$T1->get('0.0', 'end');
							chomp $chi_chis;
							$fd=$T2->get('0.0', 'end');
							chomp $fd;
							
							$chi_p=chisqrprob($fd, $chi_chis);
							
							$T13->delete('0.0','end');
							$T14->delete('0.0','end');
							$T15->delete('0.0','end');
							$T93->delete('0.0','end');
							$T94->delete('0.0','end');
							$T95->delete('0.0','end');
							$T96->delete('0.0','end');
							
							$T13->insert('end', $chi_chis);
							$T14->insert('end', $fd);
							$T15->insert('end', $chi_p);
							$T93->insert('0.0','na');
							$T94->insert('0.0','na');
							$T95->insert('0.0','na');
							$T96->insert('0.0','na');
							}
							elsif($model eq "e2x2")
							{
							my $a=$T3->get('0.0', 'end');
							my $b=$T4->get('0.0', 'end');
							my $c=$T5->get('0.0', 'end');
							my $d=$T6->get('0.0', 'end');
							chomp $a;
							chomp $b;
							chomp $c;
							chomp $d;
							my $n=$a+$b+$c+$d;
							
							$chi_chis=(($a*$d-$b*$c)**2)*$n/(($a+$b)*($c+$d)*($a+$c)*($b+$d));
							$fd=1;
							$chi_p=chisqrprob($fd, $chi_chis);
							my $OR=$a*$d/($b*$c);
							my $se=sqrt(1/$a+1/$b+1/$c+1/$d);
							my $logor=log($OR);
							my $logL95=$logor-1.96*$se; #ci: 90%-1.645, 95%-1.96, 98%-2.236 99%-2.576
							my $logU95=$logor+1.96*$se;
							my $L95=exp($logL95);
							my $U95=exp($logU95);
							
							$T13->delete('0.0','end');
							$T14->delete('0.0','end');
							$T15->delete('0.0','end');
							$T93->delete('0.0','end');
							$T94->delete('0.0','end');
							$T95->delete('0.0','end');
							$T96->delete('0.0','end');
							
							$T13->insert('end', $chi_chis);
							$T14->insert('end', $fd);
							$T15->insert('end', $chi_p);
							$T93->insert('0.0', $OR);
							$T94->insert('0.0', $se);
							$T95->insert('0.0', $L95);
							$T96->insert('0.0', $U95);
							}
							elsif($model eq "e2x3")
							{
							my $a=$T7->get('0.0', 'end');
							my $b=$T8->get('0.0', 'end');
							my $c=$T9->get('0.0', 'end');
							my $d=$T10->get('0.0', 'end');
							my $e=$T11->get('0.0', 'end');
							my $f=$T12->get('0.0', 'end');
							chomp $a;
							chomp $b;
							chomp $c;
							chomp $d;
							chomp $e;
							chomp $f;
							my $abc=$a+$b+$c;
							my $def=$d+$e+$f;
							my $ad=$a+$d;
							my $be=$b+$e;
							my $cf=$c+$f;
							my $n=$abc+$def;
							
							my $ea=$abc*$ad/$n;
							my $eb=$abc*$be/$n;
							my $ec=$abc*$cf/$n;
							my $ed=$def*$ad/$n;
							my $ee=$def*$be/$n;
							my $ef=$def*$cf/$n;
							
							$chi_chis=(($a-$ea)**2)/$ea + (($b-$eb)**2)/$eb + (($c-$ec)**2)/$ec + (($d-$ed)**2)/$ed + (($e-$ee)**2)/$ee + (($f-$ef)**2)/$ef;
							$fd=2;
							$chi_p=chisqrprob($fd, $chi_chis);
							
							$T13->delete('0.0','end');
							$T14->delete('0.0','end');
							$T15->delete('0.0','end');
							$T93->delete('0.0','end');
							$T94->delete('0.0','end');
							$T95->delete('0.0','end');
							$T96->delete('0.0','end');
														
							$T13->insert('end', $chi_chis);
							$T14->insert('end', $fd);
							$T15->insert('end', $chi_p);
							$T93->insert('0.0','na');
							$T94->insert('0.0','na');
							$T95->insert('0.0','na');
							$T96->insert('0.0','na');
							}
											  }
				  )->pack(-side => "left");
		$ok_frame->Label(-text=>"           ")->pack(-side=>'left');
		$ok_frame->Button(-text => "   Clear   ", -command=>sub{
														$T1->delete('0.0','end');
														$T2->delete('0.0','end');
														$T3->delete('0.0','end');
														$T4->delete('0.0','end');
														$T5->delete('0.0','end');
														$T6->delete('0.0','end');
														$T7->delete('0.0','end');
														$T8->delete('0.0','end');
														$T9->delete('0.0','end');
														$T10->delete('0.0','end');
														$T11->delete('0.0','end');
														$T12->delete('0.0','end');
														$T13->delete('0.0','end');
														$T14->delete('0.0','end');
														$T15->delete('0.0','end');
														$T93->delete('0.0','end');
														$T94->delete('0.0','end');
														$T95->delete('0.0','end');
														$T96->delete('0.0','end');
														 }
						 )->pack(-side=>"left");
		$ok_frame->Label(-text=>"           ")->pack(-side=>'left');
		$ok_frame->Button(-text => "   Close   ", -command=>[$gp_win => 'destroy'])->pack(-side=>"left");		

}

1;
