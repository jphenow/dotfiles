if $(command -v nvim >/dev/null 2>&1); then
  alias vim="nvim"
elif $(command -v mvim >/dev/null 2>&1); then
  alias vim="mvim -v -o"
else
  alias vim="vim -v -o"
fi

alias vl='vim $(!$)'
alias vs='vim -S ~/.vim/Session.vim'
alias v='vim .'
alias va='vim *'
