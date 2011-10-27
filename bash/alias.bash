# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

alias ls='ls -F --color'
alias l='ls'
alias s='ls'
alias a='cd ..'
alias c='cd'
alias v='vim .'
alias ir='irb --noprompt --readline -r irb/completion'
alias irb='irb --readline -r irb/completion'
alias acroread='acroread -openInNewWindow'
alias date_for_filename='date +%Y-%m-%d_%H-%M-%S'
shopt -s histappend
HISTFILESIZE=100000000
HISTSIZE=100000
PROMPT_COMMAND='history -a'
bind '"\t":menu-complete'
bind '"\C-f":history-search-backward'

# Important to some of us
set -o vi
export EDITOR=/usr/bin/vi
