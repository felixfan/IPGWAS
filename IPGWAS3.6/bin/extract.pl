#!/usr/bin/perl -w
use strict;

use Archive::Extract;  

my ($file, $dir)=@ARGV;

### build an Archive::Extract object ###   
 
my $ae = Archive::Extract->new( archive => $file );
   
### extract to dir ###    
 
my $ok = $ae->extract( to => $dir ) or die $ae->error;   
