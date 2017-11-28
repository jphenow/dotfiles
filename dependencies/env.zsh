if [ -z "$VSCODE_PID" ] ;then
  export EDITOR='vim'
else
  export EDITOR='code --wait'
fi
export PATH=".:bin:/usr/local/bin:/usr/local/sbin:$HOME/.sfs:$DOT/bin:/usr/texbin:$PATH"
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"
export NODE_PATH="/usr/local/lib/node_modules:$NODE_PATH"
