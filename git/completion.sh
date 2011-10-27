# Uses git's autocompletion for inner commands. Assumes an install of git's
# bash `git-completion` script at $completion below (this is where Homebrew
# tosses it, at least).
# TODO Find good way to be system agnostic for finding git-completion
completion=/etc/bash_completion.d/git

# TODO currently errors on zsh because above refers to bash obviously
if test -f $completion
then
  source $completion
fi
