#!/bin/bash
echo "Checking Prereqs"
if perl -e "eval { use Net::Twitter::Lite }"; then 
echo "Net::Twitter found"
else
    echo "******************INSTALLING NET::TWITTER************************"
    read
    perl -MCPAN -e "install NET::Twitter::Lite"
    echo "******************FINISHED Net::Twitter**************************"
fi 
if perl -e "eval { use WWW::Shorten::TinyURL }"; then
    echo "WWW::Shorten::TinyURL found"
else
    echo "******************INSTALLING WWW::Shorten::TinyURL************************"
    perl -MCPAN -e "install WWW::Shorten::TinyURL"
    echo "******************FINISHED WWW::Shorten::TinyURL**************************"
fi

echo "Checking out source"
svn checkout https://twiti.googlecode.com/svn/trunk/ . --force
svn revert lib/TWiki/UI/Save.pm
svn revert templates/edit.pattern.tmpl

echo "Done! Don't forget to go to bin/configure to setup the Retweet Account"
