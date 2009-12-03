#!/usr/bin/perl -w
use Cwd qw(abs_path);
use File::Basename;

my $lib_path;

BEGIN {
    my $script = abs_path($0);
    chdir( dirname($script) );
    $lib_path = dirname($script) . '/../lib';
}
use lib $lib_path;
use Net::Twitter::Lite;
use Test::More tests => 2;
use TWiki::Plugins::TwitiPlugin::Twiti qw(checkError);

my ($nt, $rtuser) = setupNetTwitterRT;
my $localnt = Net::Twitter::Lite->new(username => "TwitiRetweet", password => "");
ok($rtuser eq "TwitiRetweet");
ok (is($nt,$localnt));
#ok(is (,(,"TwitiRetweet")));


#ok(checkError(Net::Twitter::Lite::Error->new(http_response => 400),1),"<font color=red size=4><b> Twiti Error 400: Bad Request <br> Twitter Says: 400 <br><br> </b></font>");
#ok(checkError(401,1) == "<font color=red size=4><b> Twiti Error 401: Not Authorized <br> Twitter Says: 401 <br><br> </b></font>");

