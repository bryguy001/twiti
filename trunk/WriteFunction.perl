#!/usr/bin/perl

#first param is the username/filename
#second param is Twitter username
#third param is the Twitter password
sub StoreUsernameAndPassword
{
	my $filename = $_[0] . ".twiti";
	my $storestring = $store . '\n' . $_[1];
	$storestring = $store . '\n' . $_[2];
	TWiki::Func::saveFile($filename, $storestring);
}