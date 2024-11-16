# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`

alias l='ls -CF'
alias ll='ls -lh'
alias la='ls -A'

# alias vim="vim -v -o"
alias v="vim -v ."
alias va="vim -v -o *"

alias grep='grep --colour=auto'
alias s='ls'
alias a='cd ..'
alias c='cd'
alias ir='irb --noprompt --readline -r irb/completion'
alias irb='irb --readline -r irb/completion'
alias date_for_filename='date +%Y-%m-%d_%H-%M-%S'
alias js='python -mjson.tool'
