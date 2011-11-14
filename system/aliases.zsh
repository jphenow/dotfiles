# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
else
  alias ls='ls -F --color'
  alias l='ls -CF'
  alias ll='ls -lah'
  alias la='ls -A'
fi

alias grep='grep --colour=auto'
alias s='ls'
alias a='cd ..'
alias c='cd'
alias v='vim .'
alias vo='vim -o '
alias va='vo *'
alias ir='irb --noprompt --readline -r irb/completion'
alias irb='irb --readline -r irb/completion'
alias date_for_filename='date +%Y-%m-%d_%H-%M-%S'
