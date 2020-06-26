# enable color support of ls and also add handy aliases
# Caused echo'd commands before executing on vscode terminal
# if [ "$TERM" != "dumb" ]; then
#   #export TERM="xterm-256color"
#   export TERM="screen-256color"
#   export CLICOLOR=1
#   gdircolors -b $DOT/colors/dir_colors &> /dev/null
# fi

# Enable colors for ls, etc.  Prefer $DOT/colors/dir_colors #64489
if whence dircolors > /dev/null ; then
  if [[ -f $DOT/colors/dir_colors ]] ; then
    eval $(dircolors -b $DOT/colors/dir_colors) &> /dev/null
  elif [[ -f /etc/DIR_COLORS ]] ; then
    eval $(dircolors -b /etc/DIR_COLORS) &> /dev/null
  fi
else
  export CLICOLOR=1
  zstyle ':completion:*:default' list-colors '' &> /dev/null
fi
