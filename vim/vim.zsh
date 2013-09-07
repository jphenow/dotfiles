vimcmd="" &> /dev/null

if $(mvim &>/dev/null)
then
  vimcmd="mvim" &> /dev/null
else
  vimcmd="vim" &> /dev/null
fi

alias vim="$vimcmd -v -o"
alias vs="$vimcmd -v -S ~/.vim/Session.vim"
alias v="$vimcmd -v ."
alias va="$vimcmd -v -o *"
