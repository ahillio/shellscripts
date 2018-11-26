# run me like >>
#	cat 1.csv | perl n.pl |more

use strict;
use warnings;

while (<>) {
	if (/
		^(.*)		# email
		\|		# bar
		(.*)		# last name
		,\s		# comma space
		(.*)		# first name, OPTIONAL
		$		# end
	/x){
	#if (/(.*?)|(.*), (.*)\s*$/){
		#print $_
		my ($email, $last, $first) = ($1,$2,$3);
		if ( $last =~ / / ){
			#print "last has space:\n";
			print "$email|$last\n";
		} else {
			#print "last no space:\n";
			print "$email|$first $last\n";
		}
	}
}
