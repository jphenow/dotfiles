# General
# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`

alias reload!='. ~/.zshrc'
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

alias s='ls'
alias a='cd ..'
alias c='cd'

# Util
alias date_for_filename='date +%Y-%m-%d_%H-%M-%S'
alias js='python -mjson.tool'
alias grep='grep --colour=auto'
alias ack='ag'

# Nginx
alias stop_nginx='sudo /opt/nginx/sbin/nginx -s stop'
alias start_nginx='sudo /opt/nginx/sbin/nginx'

# Ruby/Rails projects
alias b='bundle exec'
alias br='bundle exec rake'
alias ir='pry'
alias irr='pry -r ./config/environment'
alias dn='touch tmp/debug.txt; powder restart'

# Vim
vimcmd=""

if $(command -v mvim >/dev/null 2>&1)
then
  vimcmd="mvim"
else
  vimcmd="vim"
fi
alias vim="$vimcmd -v -o"
alias v="$vimcmd -v ."

# SSH
# Remove the hosts that I don't want to keep around- in this case, only
# keep the first host. Like a boss.
alias hosts="head -2 ~/.ssh/known_hosts | tail -1 > ~/.ssh/known_hosts"
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# Git
alias g="git"
alias gl='git pull --prune'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gp='git push -u origin HEAD'
alias gd='git diff'
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gv="git status | grep both\ modified | awk '{print \$3}' | xargs vim -o"
alias prn="hub pull-request -b :production"
alias pr='hub pull-request'

alias vgc='vim $(git cnf)'

# Set terminal window name to current git repo or current directory
#git_repo() {
#  git remote -v | grep '(fetch)' | grep -o "\/[a-z,A-Z,\_,\-]*\." | cut -c 2- | grep -o ^[a-z,A-Z,\_,\-]*
#}
#
#cd() {
#  command cd "$@"
#  git remote >/dev/null 2>&1
#  if -n (($?)); then
#    echo -n -e "\033]0;`git_repo`\007"
#  fi
#}
