package TWiki::Plugins::TwitiPlugin::Twiti;

# Always use strict to enforce variable scoping
use strict;
use Error;
use Net::Twitter::Lite;

# checkError
# Parses an error code from a Twitter error
# Takes 2 arguments:
#   1st is the error structure: usually $@ is sent
#   2nd is a 1 or 0:
#      1 will add html formatting to the error message (Used on the main page and the more page)
#      0 will not add the html formatting (Used on the error page for an error from tweeting)
sub checkError
{
	my $err  = shift;
	my $html = shift;
	my $errorCode = $err->code();
	my $error;
	
	if( $errorCode == 200 ) { $error = 0; }
	elsif( $errorCode == 400 ) { $error = "Twiti Error 400: Bad Request"; }
	elsif( $errorCode == 401 ) { $error = "Twiti Error 401: Not Authorized"; }
	elsif( $errorCode == 403 ) { $error = "Twiti Error 403: Forbidden"; }
	elsif( $errorCode == 406 ) { $error = "Twiti Error 406: Not Acceptable (Bad Search?)"; }
	elsif( $errorCode == 500 ) { $error = "Twiti Error 500: Internal Server Error (Something Broked!)"; }
	elsif( $errorCode == 502 ) { $error = "Twiti Error 502: Bad Gateway"; }
	elsif( $errorCode == 503 ) { $error = "Twiti Error 503: Service Unavailable"; }
	else { $error = "Something else happened!??! : Error Code -> $errorCode"; }
	
	if($html)
	{  return "<font color=red size=4><b> $error <br> Twitter Says: $err <br><br> </b></font>";  }
	else
	{  return "$error -- Twitter Says: $err";  }
}


sub UpdateLogin
{
#	my $session = shift;
my $session = $TWiki::Plugins::SESSION;
   	my $webName = $session->{webName};
   	my $topic = $session->{topicName};
	my $user = $session->{user};
	my $query = $session->{cgiQuery};
	return unless ( $query );
     
	my $userName = $query->param( 'twitiUser' );
	my $password = $query->param( 'twitiPass' );

	require TWiki::Plugins::TwitiPlugin::twitiFileAccess;
	TWiki::Plugins::TwitiPlugin::twitiFileAccess::StoreUsernameAndPassword($user, $userName, $password);
   
   	$session->redirect( TWiki::Func::getViewUrl( $webName, $topic ) );   
}
# setupNetTwitter & setupNetTwitterRT
# Returns 2 variables:
#   1st is the Net::Twitter structure
#   2nd is the username used
# 
# setupNetTwitterRT does the same thing, but for a retweet account
sub setupNetTwitter
{
my $session = $TWiki::Plugins::SESSION;
#	my $session = shift;
	my $user = $session->{user};

	require TWiki::Plugins::TwitiPlugin::twitiFileAccess;
	my ($twitiUser, $twitiPass) = TWiki::Plugins::TwitiPlugin::twitiFileAccess::currentUserTwitter($user);

	
	my $nt = Net::Twitter::Lite->new(username => $twitiUser, password => $twitiPass,);
	
	return ($nt, $twitiUser);
}

sub setupNetTwitterRT
{
	my $session = $TWiki::Plugins::SESSION;
	
	my $twitiUser = $TWiki::cfg{TwitiPlugin}{RetweetUsername};
	my $twitiPass = $TWiki::cfg{TwitiPlugin}{RetweetPassword};
	
	my $nt = Net::Twitter::Lite->new(username => $twitiUser, password => $twitiPass,);
	
	return ($nt, $twitiUser);
}

sub twitiLogin {
	my $session = $TWiki::Plugins::SESSION;
	my $imgPath = TWiki::Func::getPubUrlPath() . "/" . TWiki::Func::getTwikiWebname() . "/TwitiPlugin";
	
	my $output;
	
$output = "
<link rel=\"stylesheet\" href=\"$imgPath/twiti.css\" type=\"text/css\">
<table width=250 cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td width=250>
		<img src=\"$imgPath/loginTop.png\" width=250 height=6 border=0>
		</td>
	</tr>
</table>
<table width=250 cellpadding=5 cellspacing=0 border=0 background=\"$imgPath/loginBorder.png\">
<tr>
<td>
<center>
	<img src=\"$imgPath/twitiLogo200.png\">
	<br>
	<br>
	<form action=\"/twiti/bin/twitilogin\">
		<font class=\"smallBlueBold\">Username
		<input class=\"twikiInputField\" type=\"text\" name=\"twitiUser\" size=20 />
		Password
		<input class=\"twikiInputField\" type=\"password\" name=\"twitiPass\" size=20 />
		<br><br>
		<input type=\"submit\" class=\"TwikiSubmit\" value=\"LOGIN!\" />
		</font>
	</form>
	<br>
</center>
</td>
</tr>
</table>
<table width=250 cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td>
		<img src=\"$imgPath/loginBottom.png\" width=250 height=6 border=0>
		</td>
	</tr>
</table>";
	
	return $output;
}

# twitiMain
# Returns the HTML code used for the main %TWITI% tag
sub twitiMain {

	#my $session = shift;
	my $session = $TWiki::Plugins::SESSION;
	my $imgPath = TWiki::Func::getPubUrlPath() . "/" . TWiki::Func::getTwikiWebname() . "/TwitiPlugin";
	my $moreURL = TWiki::Func::getScriptUrl('TWiki', 'TwitiPlugin', 'view');
	
	my ($nt, $twitiUser) = setupNetTwitter($session);

	my ($userInfo, $statuses, $following, $followers);
	eval{ 
		$userInfo = $nt->show_user($twitiUser);
		$statuses = $nt->friends_timeline({ my $since_id => my $high_water, count=>5 });
		$following = $nt->friends;
		$followers = $nt->followers;
	};
	
	# Error handling block...put after any eval that is done on a Twitter function!
	if( $@ )
	{
		if( $@->isa('Net::Twitter::Lite::Error') )
		{  
			my $error = checkError( $@, 1 );
			return $error . "USERNAME HERE:" .$twitiUser;
		} else{  return "Some Other Error?! : $@ $twitiUser";  }
	}

	my ($tweets, $tableTop, $tableBottom);
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
			<a href=\"http://www.twitter.com/$twitiUser\"><b>$twitiUser</b></a> <br> <a href=\"http://www.twitter.com/$twitiUser/following\">$userInfo->{friends_count} following</a> &nbsp; <a href=\"http://www.twitter.com/$twitiUser/followers\">$userInfo->{followers_count} followers</a>
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
			<center><form action=\"/twiti/bin/digitweet\"><input class=\"twikiInputField\" type=\"text\" name=\"tweet\" size=\"40\" />&nbsp;<input type=\"submit\" class=\"twikiSubmit\" value=\"Tweet\" /></form></center>
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
							<a href=\"http://www.twitter.com/$status->{user}{screen_name}\"><b>$status->{user}{screen_name}</b></a> &nbsp; $status->{text} <br> 
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
	<tr>
		<td>
			<font class=mediumBlue>
				<a href=\"$moreURL\">More</href>
			</font>
		</td>
	</tr>
</table>
<table width=718 cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td>
		<img src=\"$imgPath/borderbottom.png\" width=718 height=11 border=0>
		</td>
	</tr>
</table>";

	return ($tableTop . $tweets . $tableBottom);
}

# twitiPage
# Returns the HTML code for the %TWITI% tag when used on the TwitiPlugin page (being used as the More page)
sub twitiPage
{
        my $session = $TWiki::Plugins::SESSION;
#	my $session = shift;
	my $imgPath = TWiki::Func::getPubUrlPath() . "/" . TWiki::Func::getTwikiWebname() . "/TwitiPlugin";

	my ($nt, $twitiUser) = setupNetTwitter($session);
	
	my ($userInfo, $statuses, $following, $followers);
	eval{
		$userInfo = $nt->show_user($twitiUser);
		$statuses = $nt->friends_timeline({ my $since_id => my $high_water, count=>50 });
		$following = $nt->friends;
		$followers = $nt->followers;
	};
	
	# Error handling block...put after any eval that is done on a Twitter function!
	if( $@ )
	{
		if( $@->isa('Net::Twitter::Lite::Error') )
		{  
			my $error = checkError( $@, 1 );
			return $error;
		} else{  return "Some Other Error?! : $@";  }
	}
	
	my ($tweets, $tableTop, $tableBottom);
$tableTop = "
<table cellpadding=5 cellspacing=1 border=0>
	<tr>
		<td valign=middle width=225>
			<img src=\"$imgPath/twitiLogo200.png\">
		</td>
		<td valign=middle width=50>
			$userInfo->{profile_image_url}
		</td>
		<td>
			<a href=\"http://www.twitter.com/$twitiUser\"><b>$twitiUser</b></a> <br> <a href=\"http://www.twitter.com/$twitiUser/following\">$userInfo->{friends_count} following</a> &nbsp; <a href=\"http://www.twitter.com/$twitiUser/followers\">$userInfo->{followers_count} followers</a> &nbsp; $userInfo->{statuses_count} tweets <br>
		</td>
	</tr>
</table>
---
<table cellpadding=5 cellspacing=0 border=0>
	<tr>
		<td colspan=2>
			<font class=largeBlue>
			<form action=\"/twiti/bin/digitweet\"><input class=\"twikiInputField\" type=\"text\" name=\"tweet\" size=\"100\" />&nbsp;<input type=\"submit\" class=\"twikiSubmit\" value=\"Tweet\" /></form>
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
							<a href=\"http://www.twitter.com/$status->{user}{screen_name}\"><b>$status->{user}{screen_name}</b></a> &nbsp; $status->{text} <br> 
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
</table>";

	return ($tableTop . $tweets . $tableBottom);
}

# tweet
# Called when a user presses the Tweet button on the main page or More page
# Sends the Twitter update...will divert to an OopsException page if an error occurs in the Twitter update
sub tweet
{
#	my $session = shift;
	
#	$TWiki::Plugins::SESSION = $session;
	my $session =$TWiki::Plugins::SESSION;
	my $query = $session->{cgiQuery};
	return unless ( $query );
	
	my $webName = $session->{webName};
	my $topic = $session->{topicName};
	my $user = $session->{user};
	
	my ($nt, $twitiUser) = setupNetTwitter($session);
	
	# if retweet is enabled, setup the Net::Twitter for it
	my ($ntrt, $twitiRetweet);
	if( $TWiki::cfg{TwitiPlugin}{RetweetEnabled} )
	{
		($ntrt, $twitiRetweet) = setupNetTwitterRT($session);
	}
	
	my $tweet = $query->param( 'tweet' );
	eval{
		my $r = $nt->update($tweet);
		
		if( $TWiki::cfg{TwitiPlugin}{RetweetEnabled} )
		{
			$r = $ntrt->update( 'RT @' . $twitiUser . ' ' . $tweet);
		}
	};
	
	# Error handling block 2...This is only for tweet & tweetSave!!!!!
	if( $@ )
	{
		if( $@->isa('Net::Twitter::Lite::Error') )
		{  
			my $error = checkError( $@, 0 );
			warn $error;
			throw TWiki::OopsException( 'generic', web=>$webName, topic=>$topic, params=> [ 'Tweet problem...', 'Unable to send tweet', $error, '' ] );
		} else{  
			warn "Some Other Error?! : $@";  
			throw TWiki::OopsException( 'generic', web=>$webName, topic=>$topic, params=> [ 'Tweet problem...', 'Unable to send tweet', $@, '' ] );
		}
	}
	   
	$session->redirect( TWiki::Func::getViewUrl( $webName, $topic ) );
}

# tweetSave
# Called when a user presses the Tweet & Save button on an Edit page
# Sends the Twitter update...will divert to an OopsException page if an error occurs in the Twitter update
#   !!! If diverted, will not perform save...have no idea how you could still do save and divert to show error
sub tweetSave
{
	my $tweet = shift;
	
	my $session = $TWiki::Plugins::SESSION;
	my $webName = $session->{webName};
	my $topic = $session->{topicName};

	my ($nt, $twitiUser) = setupNetTwitter($session);
	my ($ntrt, $twitiRetweet) = setupNetTwitterRT($session);
	
	eval{
		my $r = $nt->update($tweet);
		$r = $ntrt->update($tweet);
	};
	
	# Error handling block 2...This is only for tweet & tweetSave!!!!!
	if( $@ )
	{
		if( $@->isa('Net::Twitter::Lite::Error') )
		{  
			my $error = checkError( $@, 0 );
			warn $error;
			throw TWiki::OopsException( 'generic', web=>$webName, topic=>$topic, params=> [ 'Tweet problem...', 'Unable to send tweet', $error, "Your page update was not saved, press back and perform a normal save or you will lose your update!" ] );
		} else{  
			warn "Some Other Error?! : $@";  
			throw TWiki::OopsException( 'generic', web=>$webName, topic=>$topic, params=> [ 'Tweet problem...', 'Unable to send tweet', $@, "Your page update was not saved, press back and perform a normal save or you will lose your update!" ] );
		}
	}
}
sub logout 
{
    my $session = $TWiki::Plugins::SESSION;
    my $user = $session->{user};
    my $filename = TWiki::Func::getWorkArea('TwitiPlugin') . "/" . $user . ".twiti";
    my $storestring = $_[1] . "," . $_[2];
    TWiki::Func::saveFile($filename, "");
    $session->redirect( TWiki::Func::getViewUrl( $session->{webName}, $session->{topicName} ) );
}

1;
