#TwitiPlugin
#SignaturePlugin was the base for this
#
package TWiki::Plugins::TwitiPlugin;

# Always use strict to enforce variable scoping
use strict;

# $VERSION is referred to by TWiki, and is the only global variable that
# *must* exist in this package
use vars qw( $VERSION $RELEASE $debug $pluginName );

use Net::Twitter::Lite;
# This should always be $Rev: 0$ so that TWiki can determine the checked-in
# status of the plugin. It is used by the build automation tools, so
# you should leave it alone.
$VERSION = '$Rev: 0$';

# This is a free-form string you can use to "name" your own plugin version.
# It is *not* used by the build automation tools, but is reported as part
# of the version number in PLUGINDESCRIPTIONS.
$RELEASE = 'eh?';

# Name of this Plugin, only used in this module
$pluginName = 'TwitiPlugin';

sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;

    if( $TWiki::Plugins::VERSION < 1.1 ) {
        TWiki::Func::writeWarning( "This version of $pluginName works only with TWiki 4 and greater." );
        return 0;
    }

    # Get plugin debug flag
    $debug = TWiki::Func::getPreferencesFlag( "\U$pluginName\E_DEBUG" );
    #TWiki::Func::setSessionValue('TwitiUser', 'TwitiArthur');
    #TWiki::Func::setSessionValue('TwitiPass', 'arthur');
    

    # Plugin correctly initialized
    TWiki::Func::writeDebug( "- TWiki::Plugins::${pluginName}::initPlugin( $web.$topic ) is OK" ) if $debug;
    return 1;

}

sub preRenderingHandler
{
### my ( $text ) = @_;   # do not uncomment, use $_[0], $_[1] instead

    &TWiki::Func::writeDebug( "- $pluginName::preRenderingHandler" ) if $debug;

    # This handler is called by getRenderedVersion just before the line loop
    # Only bother with this plugin if viewing (i.e. not searching, etc)
    
	return unless ($0 =~ m/view|viewauth|render/o);
    $_[0] =~ s/%TWITI%/&handleTwiti/geo;
    $_[0] =~ s/%TWITILOGIN%/&handleTwitiLogin/geo;
	
	#TWiki::Func::registerTagHandler( 'TWEET', \&TWiki::Plugins::TwitiPlugin::Twiti::handleTweeting );

}

sub handleTwiti 
{
	my $session = $TWiki::Plugins::SESSION;
	my $query = $session->{cgiQuery};
	return unless ( $query );

	my $cnt = $query->param( 'nr' );

	my $webName = $session->{webName};
	my $topic = $session->{topicName};
	my $user = $session->{user};
	return $user;
	
	require TWiki::Plugins::TwitiPlugin::twitiFileAccess;
	if(TWiki::Plugins::TwitiPlugin::twitiFileAccess::currentUserTwitter($user) eq "")
	{
		require TWiki::Plugins::TwitiPlugin::Twiti;
		return TWiki::Plugins::TwitiPlugin::Twiti::twitiLogin(); 
	}

	if($topic eq 'TwitiPlugin')
	{  
		require TWiki::Plugins::TwitiPlugin::Twiti;
		return TWiki::Plugins::TwitiPlugin::Twiti::twitiPage($session);  
	}
	else
	{
		require TWiki::Plugins::TwitiPlugin::Twiti;
		return TWiki::Plugins::TwitiPlugin::Twiti::twitiMain($session);
	}
}

sub handleTwitiLogin 
{
	return "fuk u";
}

1;
