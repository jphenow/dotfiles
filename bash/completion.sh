# Uses git's autocompletion for inner commands. Assumes an install of git's
# bash `git-completion` script at $completion below (this is where Homebrew
# tosses it, at least).
# TODO Find good way to be system agnostic for finding git-completion
completion=/etc/bash_completion.d/git
completion2=/etc/bash_completion

# TODO currently errors on zsh because above refers to bash obviously
# Supressing errors for now - too annoying
if test -f $completion
then
  source $completion 2> /dev/null
elif test -f $completion2
then
  source $completion2 2> /dev/null
fi

hubcompletion=/usr/local/share/zsh/site-functions
if test -f $hubcompletion
then
  source $hubcompletion 2> /dev/null
fi
