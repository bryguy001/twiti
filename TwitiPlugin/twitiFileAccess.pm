#! /usr/bin/perl

# first param is the username/filename
sub retrieveTwitterJunk
{
  my $filename = $_[0].".twiti";
  $text = Twiki::Func::readFile($filename);
  @textArray = split('\n',$text);
  return @textArray;  
}

# returns twiiter information based on current Twiki user
sub currentUserTwitter
{
  return retrieveTwitterJunk(%username.".twiti");
}

change here
