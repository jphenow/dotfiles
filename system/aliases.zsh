# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`

if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias l="gls -F --color"
  alias ll="gls -Fl --color"
  alias la='gls -lAH --color'
else
  alias ls='ls --color -FCG'
  alias l='ls -CF'
  alias ll='ls -lh'
  alias la='ls -A'
fi

vimcmd=""

if $(command -v mvim >/dev/null 2>&1)
then
  vimcmd="mvim"
else
  vimcmd="vim"
fi

alias vim="$vimcmd -v -o"
alias v="$vimcmd -v ."
alias va="$vimcmd -v -o *"

alias grep='grep --colour=auto'
alias s='ls'
alias a='cd ..'
alias c='cd'
alias ir='irb --noprompt --readline -r irb/completion'
alias irb='irb --readline -r irb/completion'
alias date_for_filename='date +%Y-%m-%d_%H-%M-%S'
alias js='python -mjson.tool'
