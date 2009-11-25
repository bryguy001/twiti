package TWiki::Plugins::TwitiPlugin::Twiti;

# Always use strict to enforce variable scoping
use strict;
use Net::Twitter::Lite;

sub checkError
{
	my $errorCode = shift;
	my $error;
	
	if( $errorCode == 200 ) { $error = 0; }
	elsif( $errorCode == 400 ) { $error = "Twitter Error 400: Bad Request"; }
	elsif( $errorCode == 401 ) { $error = "Twitter Error 401: Not Authorized...Invalid User/Pass"; return $error; }
	elsif( $errorCode == 403 ) { $error = "Twitter Error 403: Forbidden"; }
	elsif( $errorCode == 406 ) { $error = "Twitter Error 406: Not Acceptable (Bad Search?)"; }
	elsif( $errorCode == 500 ) { $error = "Twitter Error 500: Internal Server Error (Something Broked!)"; }
	elsif( $errorCode == 502 ) { $error = "Twitter Error 502: Bad Gateway...Twitter is down!"; }
	elsif( $errorCode == 503 ) { $error = "Twitter Error 503: Service Unavailable...Twitter is up, but overloaded or somethin...come back later!"; }
	else { $error = "Something else happened!??! : Error Code -> $errorCode"; }
	
	return $error;
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
	
	if( my $error = $@ )
	{
		if( $error->isa('Net::Twitter::Lite::Error') )
		{  
			$error = checkError( $error->code() );
			return "$error <br> Twitter Says: $@->error";
		}
		else{  return "Error?! : $@";  }
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

	my ($nt, $twitiUser, $error) = setupNetTwitter();
	if( $error != 0 ) {  return $error;  }
	
	my $tweets; my $tableTop; my $tableBottom;
	
	my $userInfo = $nt->show_user($twitiUser);
	my $statuses = $nt->friends_timeline({ my $since_id => my $high_water });
	my $following = $nt->friends;
	my $followers = $nt->followers;

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
	
	my $update = $query->param( 'tweet' );
	
	my ($nt, $twitiUser, $error) = setupNetTwitter();
	if( $error != 0 ) {  warn $error;  }
	
	my ($ntrt, $twitiRetweet, $error) = setupNetTwitterRT();
	if( $error != 0 ) {  warn $error;  }
	
	my $r = $nt->update($update);
	   $r = $ntrt->update($update);
	
	$session->redirect( TWiki::Func::getViewUrl( $webName, $topic ) );
}

sub tweetSave
{
	my $tweet = shift;

	my ($nt, $twitiUser, $error) = setupNetTwitter();
	if( $error != 0 ) {  warn $error;  }
	
	my ($ntrt, $twitiRetweet, $error) = setupNetTwitterRT();
	if( $error != 0 ) {  warn $error;  }
	
	my $r = $nt->update($tweet);
	   $r = $ntrt->update($tweet);
}

1;
