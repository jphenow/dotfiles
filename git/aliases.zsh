# Use `hub` as our git wrapper:
#   http://defunkt.github.com/hub/
#
# I use JRuby substantially, and we want to make sure hub is run using MRI
# regardless of which Ruby you're using or else the `git status` in your prompt
# will take seven thousand seconds to run `ls`.
#
# I'm hardcoding it to an installed rvm (using rvm's `rvm 1.8.7,ruby /hub/path`
# syntax is way too slow). It should work fine for those without rvm, though.
if [[ -s $HOME/.rvm/scripts/rvm ]]
then
  if $(which hub &> /dev/null) && [[ -s $HOME/.rvm/rubies/ruby-1.8.7-p334 ]]
  then
    alias git='$HOME/.rvm/rubies/ruby-1.8.7-p334/bin/ruby `which hub`'
  else
  fi
fi

# The rest of my fun git aliases
alias gl='git pull --prune'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gp='git push origin HEAD'
alias gd='git diff'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git branch'
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gv="git status | grep both\ modified | awk '{print \$3}' | xargs vim -o"
alias g="git"
alias gm="git checkout master"

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
