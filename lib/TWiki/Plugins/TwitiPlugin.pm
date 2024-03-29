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
	
	TWiki::Func::registerTagHandler( 'TWITI', \&TWiki::Plugins::TwitiPlugin::handleTwiti );

}

sub handleTwiti 
{	
	my $session = $TWiki::Plugins::SESSION;
	my $attr = $_[1];
	my $query = $session->{cgiQuery};
	return unless ( $query );

	my $webName = $session->{webName};
	my $topic = $session->{topicName};
	my $user = $session->{user};
	
	require TWiki::Plugins::TwitiPlugin::twitiFileAccess;
	require TWiki::Plugins::TwitiPlugin::Twiti;
	
	if($user eq "BaseUserMapping_666")
	{  return "<font size=4 color=red><b>Please log into TWiki to use the Twiti plugin!</b></font>";  }
	
	if(TWiki::Plugins::TwitiPlugin::twitiFileAccess::currentUserTwitter($user) == 0)
	{
		return TWiki::Plugins::TwitiPlugin::Twiti::twitiLogin(); 
	}
	else
	{
		if($attr->{thispage} eq "1")
		{
			return TWiki::Plugins::TwitiPlugin::Twiti::twitiPageSpecific($session);
		}
		elsif($topic eq 'TwitiPlugin')
		{  
			return TWiki::Plugins::TwitiPlugin::Twiti::twitiPage($session);  
		}
		else
		{
			return TWiki::Plugins::TwitiPlugin::Twiti::twitiMain($session);
		}
	}
}

1;
