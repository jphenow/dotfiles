alias gl='git pull --prune'
alias glog="git log --oneline --decorate --graph"
alias gp='git push --set-upstream origin HEAD'
alias gd='git diff'
alias gs='git status -sb'
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gv="git status | grep both\ modified | awk '{print \$3}' | xargs vim -o"
alias g="git"
alias gm="git checkout master"

alias vgc='vim $(git cnf)'
