package TWiki::Plugins::TwitiPlugin::twitiFileAccess;

#use Crypt::Simple passphrase => 'twiti';

# first param is the username/filename
sub retrieveTwitterJunk
{
  my $filename = $_[0].".twiti";
  $text = TWiki::Func::readFile($filename);
  @textArray = split('\n',$text);
  #$textArray[1] = decrypt($textArray[1]);
  return @textArray;  
}

# returns twiiter information based on current Twiki user
sub currentUserTwitter
{
  return retrieveTwitterJunk(%username.".twiti");
}

#first param is the username/filename
#second param is Twitter username
#third param is the Twitter password
sub StoreUsernameAndPassword
{
  my $filename = $_[0] . ".twiti";
  my $storestring = $store . '\n' . $_[1];
  $storestring = $store . '\n' . $_[2];#encrypt($_[2]);
  TWiki::Func::saveFile($filename, $storestring);
}
                                
1;
