# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`

# alias ls='ls -CF --color'
if command -v eza &> /dev/null; then
  alias ls='eza -F --group-directories-first --icons auto'
elif command -v gls &> /dev/null; then
  alias ls='gls -F --group-directories-first --color=auto'
  alias l='ls -CF'
  alias ll='ls -lh'
  alias la='ls -A'
fi

if command -v bat &> /dev/null; then
  alias cat='bat'
fi

# alias vim="vim -v -o"
# alias v="vim -v ."
# alias va="vim -v -o *"

alias ack='rg'
alias ag='rg'
alias grep='rg'
alias s='ls'
alias a='cd ..'
alias 'cd..'='cd ..'
alias c='cd'
# alias ir='irb --noprompt --readline -r irb/completion'
# alias irb='irb --readline -r irb/completion'
alias date_for_filename='date +%Y-%m-%d_%H-%M-%S'
alias js='python -mjson.tool'
