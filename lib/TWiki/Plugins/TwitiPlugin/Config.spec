# ---+ TwitiPlugin
# This plugin integrates TWiki with users' Twitter accounts. User these
# settings to specify a 'retweet' Twitter account with will copy the 
# updates from Twiti users on this TWiki

# **BOOLEAN**
# Enable a retweet account. Requires information below.
$TWiki::cfg{TwitiPlugin}{RetweetEnabled} = '0';

# **STRING 20**
# Retweet account username. ACCOUNT MUST ALREADY EXIST!
$TWiki::cfg{TwitiPlugin}{RetweetUsername} = '';

# **PASSWORD 20**
# Retweet account password.
$TWiki::cfg{TwitiPlugin}{RetweetPassword} = '';




