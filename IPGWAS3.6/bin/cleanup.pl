#!/usr/bin/perl

## CO'D 13/03/09
## This script will remove all ‘.forSRT’, ‘.ratios’ and ‘.assoc’ files in the current directory

### specify input
### revised on 16 Jul 2011
my($dir)=@ARGV;

print "\nDeleting .forSRT .ratios and .assoc files in the current directory...";
opendir(DIR, $dir);
@FILES= readdir(DIR); 
$files = 0;
while ($files < @FILES) {
	if (($FILES[$files] =~ /.forSRT$/) || ($FILES[$files] =~ /.ratios$/) || ($FILES[$files] =~ /.assoc$/) || ($FILES[$files] =~ /.log$/)) { 	
		unlink("$dir/$FILES[$files]");
		$del++;
	}
	$files++;
}

print "[ $del ] files deleted...DONE.\n\n";
	
	

