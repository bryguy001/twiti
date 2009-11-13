package TWiki::Plugins::TwitiPlugin::Twiti;

# Always use strict to enforce variable scoping
use strict;
use Net::Twitter::Lite;

sub handleTwiti {
	my $imgPath = TWiki::Func::getPubUrlPath() . "/" . TWiki::Func::getTwikiWebname() . "/TwitiPlugin";
	
	my $twitiUser = "TwitiTestUser";
	my $twitiPass = "";

	my $nt = Net::Twitter::Lite->new(
		  username => $twitiUser,
		  password => $twitiPass,
	  );
	# $r = $nt->update($ARGV[0]);
	
	my $tweets; my $tableTop; my $tableBottom;
	
	my $userInfo = $nt->show_user($twitiUser);
	my $statuses = $nt->friends_timeline({ my $since_id => my $high_water, count=>5 });
	my $following = $nt->friends;
	my $followers = $nt->followers;
	
$tableTop = "
<link rel=\"stylesheet\" href=\"$imgPath/twiti.css\" type=\"text/css\">
<table width=718 cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td width=718>
		<img src=\"$imgPath/bordertop.png\" width=718 height=11 border=0>
		</td>
	</tr>
</table>
<table width=718 cellpadding=5 cellspacing=0 border=0 bgcolor=#5B9EBF>
	<tr>
		<td width=215 align=center valign=middle>
		<img src=\"$imgPath/twitiLogo200.png\">
		</td>
		<td valign=middle align=center width=50>
		$userInfo->{profile_image_url}
		</td>
		<td valign=middle width=225>
			<font class=twitiWhite>
			*$twitiUser* <br> $userInfo->{friends_count} following &nbsp; $userInfo->{followers_count} followers
			</font>
		</td>
		<td valign=middle>
			<font class=twitiWhite>$userInfo->{statuses_count} tweets <br><br>
			</font>
		</td>
	</tr>
</table>
<table width=718 cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td width=718>
		<img src=\"$imgPath/bordertop2.png\" width=718 height=22 border=0>
		</td>
	</tr>
</table>
<table width=718 cellpadding=5 cellspacing=0 border=0 background=\"$imgPath/border.png\">";

$tweets = "
	<tr>
		<td colspan=2>
			<font class=largeBlue>
			<b>Recent Tweets</b><br>
			</font>
		</td>
	</tr>";
	
	for my $status ( @$statuses ) 
	{
	  $tweets .= "\n<tr>
						<td align=center valign=middle width=50>
						$status->{user}{profile_image_url}
						</td>
						<td valign=top>
							<font class=tweet>
							<b>$status->{user}{screen_name}</b> &nbsp; $status->{text} <br> 
							</font>
							<font class=tweetInfo>
							$status->{created_at} from $status->{source}
							</font>
						</td>
					</tr>";
	}
	
$tableBottom = "
		</td>
	</tr>
</table>
<table width=718 cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td>
		<img src=\"$imgPath/borderbottom.png\" width=718 height=11 border=0>
		</td>
	</tr>
</table>
<form action=\"/twiti/bin/digitweet\"><input class=\"twikiInputField\" type=\"text\" name=\"tweet\" size=\"22\" />&nbsp;<input type=\"submit\" class=\"twikiSubmit\" value=\"Tweet\" /></form>";

	return ($tableTop . $tweets . $tableBottom);
}

sub tweet
{
  my $session = shift;
  $TWiki::Plugins::SESSION = $session;
  my $query = $session->{cgiQuery};
  return unless ( $query );

  my $cnt = $query->param( 'nr' );

  my $webName = $session->{webName};
  my $topic = $session->{topicName};
  my $user = $session->{user};


my $twitiUser = "TwitiTestUser";
my $twitiPass = "twitiiscool";
my $r;
my $nt = Net::Twitter::Lite->new(
         username => $twitiUser,
        password => $twitiPass
  );
$r = $nt->update("SToafdsfadsfameone else! clicked my Tweet button!!!");

TWiki::Func::redirectCgiQuery( $query, &TWiki::Func::getViewUrl( $webName, $topic ) );
}

#sub handleTweeting
#{
#	return "<form action=\"" . 
#      &TWiki::Func::getScriptUrl($session->{webName}, $session->{topicName}, 'digitweet') . 
#      "\" /><input type=\"hidden\" name=\"nr\" value=\"$cnt\" /><input type=\"submit\" value=\"$lbl\" /></form>";
#}
# sub handleSignature {
  # my ( $cnt, $attr ) = @_;
  # my $session = $TWiki::Plugins::SESSION;

  # $attr = new TWiki::Attrs($attr);
  # my $lbl = TWiki::Func::getPreferencesValue( "\U$TWiki::Plugins::SignaturePlugin::pluginName\E_SIGNATURELABEL" ) || 'Sign';

  # my $name = '';
  # $name = '_('.$attr->{name}.')_ &nbsp;' if $attr->{name};

  # return "<noautolink> $name </noautolink><form action=\"" . &TWiki::Func::getScriptUrl($session->{webName}, $session->{topicName}, 'digisign') . "\" /><input type=\"hidden\" name=\"nr\" value=\"$cnt\" /><input type=\"submit\" value=\"$lbl\" /></form>";

# }

# sub sign {
  # my $session = shift;
  # $TWiki::Plugins::SESSION = $session;
  # my $query = $session->{cgiQuery};
  # return unless ( $query );

  # my $cnt = $query->param( 'nr' );

  # my $webName = $session->{webName};
  # my $topic = $session->{topicName};
  # my $user = $session->{user};

  # return unless ( &doEnableEdit ($webName, $topic, $user, $query, 'editTableRow') );

  # my ( $meta, $text ) = &TWiki::Func::readTopic( $webName, $topic );
  # $text =~ s/%SIGNATURE(?:{(.*)})?%/&replaceSignature($cnt--, $user, $1)/geo;

  # my $error = &TWiki::Func::saveTopicText( $webName, $topic, $text, 1 );
  # TWiki::Func::setTopicEditLock( $webName, $topic, 0 );  # unlock Topic
  # if( $error ) {
    # TWiki::Func::redirectCgiQuery( $query, $error );
    # return 0;
  # } else {
    # and finally display topic
    # TWiki::Func::redirectCgiQuery( $query, &TWiki::Func::getViewUrl( $webName, $topic ) );
  # }
  
# }

# sub replaceSignature {
  # my ( $dont, $user, $attr ) = @_;

  # return ( ($attr)?"%SIGNATURE{$attr}%":'%SIGNATURE%' ) if $dont;

  # $attr = new TWiki::Attrs($attr);

  # my $wikiUser = TWiki::Func::getWikiUserName($user);
  # my $session = $TWiki::Plugins::SESSION;
  # unless ( ! $attr->{name} || $TWiki::Plugins::SESSION->{users}->isInList($user, $attr->{name}) ) {
    # TWiki::Func::setTopicEditLock( $session->{webName}, $session->{topicName}, 0 );  # unlock Topic
    # throw TWiki::OopsException( 'generic',
				# web => $session->{webName},
				# topic => $session->{topicName},
				# params => [ 'Attention', $wikiUser.' is not permitted to sign here.',  'Please go back in your browser and sign at the correct spot.', ' ' ] );
    # exit;
  # }

  # my $fmt = $attr->{format} || TWiki::Func::getPreferencesValue( "\U$TWiki::Plugins::SignaturePlugin::pluginName\E_SIGNATUREFORMAT" ) || '$wikiusername - $date';

  # my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
  # my ($d, $m, $y) = (localtime)[3, 4, 5];
  # $y += 1900;
  # my $ourDate = sprintf('%02d %s %d', $d, $months[$m], $y);
  # my $login = TWiki::Func::wikiToUserName($wikiUser);
  # my $wikiName = TWiki::Func::userToWikiName($login, 1);

  # $fmt =~ s/\$quot/\"/go;
  # $fmt =~ s/\$wikiusername/$wikiUser/geo;
  # $fmt =~ s/\$wikiname/$wikiName/geo;
  # $fmt =~ s/\$username/$login/geo;
  # $fmt =~ s/\$date/$ourDate/geo;

  # return $fmt;

# }

# sub doEnableEdit
# {
    # my ( $theWeb, $theTopic, $user, $query ) = @_;

    # if( ! &TWiki::Func::checkAccessPermission( "change", $user, "", $theTopic, $theWeb ) ) {
        # user does not have permission to change the topic
        # throw TWiki::OopsException( 'accessdenied',
                                    # def => 'topic_access',
                                    # web => $_[2],
                                    # topic => $_[1],
				    # params => [ 'Edit topic', 'You are not permitted to edit this topic' ] );
	# return 0;
    # }

    # SMELL: Update for TWiki 4.1 =checkTopicEditLock=
    # my( $oopsUrl, $lockUser ) = &TWiki::Func::checkTopicEditLock( $theWeb, $theTopic, 'edit' );
    # if( $lockUser && ! ( $lockUser eq TWiki::Func::getCanonicalUserID($user) ) ) {
      # warn user that other person is editing this topic
      # &TWiki::Func::redirectCgiQuery( $query, $oopsUrl );
      # return 0;
    # }
    # TWiki::Func::setTopicEditLock( $theWeb, $theTopic, 1 );

    # return 1;

# }

1;
