package TWiki::Plugins::TwitiPlugin::twitiFileAccess;

#use Crypt::Simple passphrase => 'twiti';

# returns twiiter information based on Twiki username
# passed as a parameter
sub currentUserTwitter
{
  my $filename = TWiki::Func::getWorkArea('TwitiPlugin') . "/" . $_[0].".twiti";
  $text = TWiki::Func::readFile($filename);
  @textArray = split(/,/,$text);
  #$textArray[1] = decrypt($textArray[1]);
  return @textArray;  
}

#first param is the username/filename
#second param is Twitter username
#third param is the Twitter password
sub StoreUsernameAndPassword
{
  my $filename = TWiki::Func::getWorkArea('TwitiPlugin') . "/" . $_[0] . ".twiti";
  my $storestring = $_[1] . "," . $_[2];#encrypt($_[2]);
  TWiki::Func::saveFile($filename, $storestring);
}
                                
1;
