# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
  export TERM="xterm-256color"
  export CLICOLOR=1
  gdircolors -b $DOT/dependencies/dir_colors &> /dev/null
fi
# Enable colors for ls, etc.  Prefer $DOT/dependencies/dir_colors #64489
if whence dircolors > /dev/null ; then
  if [[ -f $DOT/dependencies/dir_colors ]] ; then
    eval $(dircolors -b $DOT/dependencies/dir_colors) &> /dev/null
  elif [[ -f /etc/DIR_COLORS ]] ; then
    eval $(dircolors -b /etc/DIR_COLORS) &> /dev/null
  fi
else
  export CLICOLOR=1
  zstyle ':completion:*:default' list-colors '' &> /dev/null
fi
