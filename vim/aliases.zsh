if $(command -v nvim >/dev/null 2>&1); then
  vimcmd="nvim"
elif $(command -v mvim >/dev/null 2>&1); then
  vimcmd="mvim"
else
  vimcmd="vim"
fi

alias vim="$vimcmd -v -o"
alias vl='vim $(!$)'
alias vs='vim -S ~/.vim/Session.vim'
alias v='vim .'
alias va='vim *'