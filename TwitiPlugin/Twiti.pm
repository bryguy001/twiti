package TWiki::Plugins::TwitiPlugin::Twiti;

# Always use strict to enforce variable scoping
use strict;
use Net::Twitter::Lite;

sub checkError
{
	my $err = shift;
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
	
	return "<font color=red size=4><b> $error <br> Twitter Says: $err <br><br> </b></font>";
}

sub setupNetTwitter
{
	my $twitiUser = "TwitiTestUser";
	my $twitiPass = "twitiiscoolOMGTHISISNOTRIGHT!";
	
	my $nt = Net::Twitter::Lite->new(username => $twitiUser, password => $twitiPass,);
	
	return ($nt, $twitiUser);
}

sub setupNetTwitterRT
{
	my $twitiUser = "TwitiRetweet";
	my $twitiPass = "twitiistheshit";
	
	my $nt = Net::Twitter::Lite->new(username => $twitiUser, password => $twitiPass,);
	
	return ($nt, $twitiUser);
}

sub twitiMain {
	my $session = $TWiki::Plugins::SESSION;
	my $imgPath = TWiki::Func::getPubUrlPath() . "/" . TWiki::Func::getTwikiWebname() . "/TwitiPlugin";
	my $moreURL = TWiki::Func::getScriptUrl('TWiki', 'TwitiPlugin', 'view');
	
	my ($nt, $twitiUser) = setupNetTwitter();

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
			my $error = checkError( $@ );
			return $error;
		} else{  return "Some Other Error?! : $@";  }
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

sub twitiPage
{
	my $imgPath = TWiki::Func::getPubUrlPath() . "/" . TWiki::Func::getTwikiWebname() . "/TwitiPlugin";

	my ($nt, $twitiUser) = setupNetTwitter();
	
	my ($userInfo, $statuses, $following, $followers);
	eval{
		$userInfo = $nt->show_user($twitiUser);
		$statuses = $nt->friends_timeline({ my $since_id => my $high_water });
		$following = $nt->friends;
		$followers = $nt->followers;
	};
	
	# Error handling block...put after any eval that is done on a Twitter function!
	if( $@ )
	{
		if( $@->isa('Net::Twitter::Lite::Error') )
		{  
			my $error = checkError( $@ );
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
			*$twitiUser* <br> $userInfo->{friends_count} following &nbsp; $userInfo->{followers_count} followers &nbsp; $userInfo->{statuses_count} tweets <br>
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
</table>";

	return ($tableTop . $tweets . $tableBottom);
}

sub tweet
{
	my $session = shift;
	
	$TWiki::Plugins::SESSION = $session;
	my $query = $session->{cgiQuery};
	return unless ( $query );
	
	my $webName = $session->{webName};
	my $topic = $session->{topicName};
	my $user = $session->{user};
	
	my ($nt, $twitiUser) = setupNetTwitter();
	my ($ntrt, $twitiRetweet) = setupNetTwitterRT();
	
	my $tweet = $query->param( 'tweet' );
	eval{
		my $r = $nt->update($tweet);
		$r = $ntrt->update($tweet);
	};
	
	# Error handling block...
	if( $@ )
	{
		if( $@->isa('Net::Twitter::Lite::Error') )
		{  
			my $error = checkError( $@ );
			warn $error;
			TWiki::Func::redirectCgiQuery($query, $error);
		} else{  warn "Some Other Error?! : $@";  TWiki::Func::redirectCgiQuery($query, $error);  }
	}
	   
	$session->redirect( TWiki::Func::getViewUrl( $webName, $topic ) );
}

sub tweetSave
{
	my $tweet = shift;

	my ($nt, $twitiUser) = setupNetTwitter();
	my ($ntrt, $twitiRetweet) = setupNetTwitterRT();
	
	eval{
		my $r = $nt->update($tweet);
		$r = $ntrt->update($tweet);
	};
	
	# Error handling block...
	if( $@ )
	{
		if( $@->isa('Net::Twitter::Lite::Error') )
		{  
			my $error = checkError( $@ );
			warn $error;
			TWiki::Func::redirectCgiQuery($query, $error);
		} else{  warn "Some Other Error?! : $@";  TWiki::Func::redirectCgiQuery($query, $error);  }
	}
}

1;
