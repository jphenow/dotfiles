# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
  export TERM="xterm-256color"
  export CLICOLOR=1
  #eval "`dircolors -b $DOT/colors/dir_colors`"
fi
