# From http://dotfiles.org/~_why/.zshrc
# Sets the window title nicely no matter where you are
#function title() {
#  # escape '%' chars in $1, make nonprintables visible
#  a=${(V)1//\%/\%\%}
#
#  # Truncate command, and join lines.
#  a=$(print -Pn "%40>...>$a" | tr -d "\n")
#
#  case $TERM in
#  screen)
#    print -Pn "\ek$a:$3\e\\" # screen title (in ^A")
#    ;;
#  xterm*|rxvt)
#    print -Pn "\e]2;$2\a" # plain xterm title ($3 for pwd)
#    ;;
#  esac
#}

# Above disabled for now, no time to figure out why that one
# wasn't working. This was yoinked from oh-my-zsh
function title {
  if [[ "$TERM" == screen* ]]; then
    print -Pn "\ek$1:q\e\\" #set screen hardstatus, usually truncated at 20 chars
  elif [[ "$TERM" == xterm* ]] || [[ $TERM == rxvt* ]] || [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    print -Pn "\e]2;$2:q\a" #set window name
    print -Pn "\e]1;$1:q\a" #set icon (=tab) name (will override window name on broken terminal)
  fi
}
