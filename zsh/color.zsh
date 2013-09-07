# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
  export TERM="xterm-256color"
  export CLICOLOR=1
  gdircolors -b $DOT/colors/dir_colors 2> /dev/null
fi
# Enable colors for ls, etc.  Prefer $DOT/colors/dir_colors #64489
if dircolors >/dev/null ; then
  if [[ -f $DOT/colors/dir_colors ]] ; then
    eval $(dircolors -b $DOT/colors/dir_colors)
  elif [[ -f /etc/DIR_COLORS ]] ; then
    eval $(dircolors -b /etc/DIR_COLORS)
  fi
fi
