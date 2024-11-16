# enable color support of ls and also add handy aliases
# Caused echo'd commands before executing on vscode terminal
# if [ "$TERM" != "dumb" ]; then
#   #export TERM="xterm-256color"
#   export TERM="screen-256color"
#   export CLICOLOR=1
#   gdircolors -b $DOT/colors/dir_colors &> /dev/null
# fi

# Enable colors for ls, etc.  Prefer $DOT/colors/dir_colors #64489
# if whence dircolors > /dev/null ; then
#   if [[ -f $DOT/colors/dir_colors ]] ; then
#     eval $(dircolors -b $DOT/colors/dir_colors) &> /dev/null
#   elif [[ -f /etc/DIR_COLORS ]] ; then
#     eval $(dircolors -b /etc/DIR_COLORS) &> /dev/null
#   fi
# else
#   export CLICOLOR=1
#   export LS_COLORS='no=00;37:fi=00:di=00;33:ln=04;36:pi=40;33:so=01;35:bd=40;33;01:'
#   zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
#   zstyle ':completion:*:default' list-colors '' &> /dev/null
# fi

# https://blog.smittytone.net/2020/06/14/give-macos-terminal-a-better-ls/
# This sets directories (di) to cyan, links (ln) to yellow and executables (ex) to purple. The style value in each case is zero, which means ‘no style’. Change it, for example, to 1 for bold, or 5 for flashing, though you probably won‘t want to keep it that way. The complete list of styles is:
# 0 — no style
# 1 — bold
# 4 — underlined
# 5 — flashing text
# 7 — reverse (background colour on foreground colour)
# The foreground colours are:
# 31— red
# 32 — green
# 33 — orange
# 34 — blue
# 35 — purple
# 36 — cyan
# 37 — grey
# 90 — dark grey
# 91 — light red
# 92 — light green
# 93 — yellow
# 94 — light blue
# 95 — light purple
# 96 — turquoise
# And the backgrounds are:
# 40 — black
# 41 — red
# 42 — green
# 43 — orange
# 44 — blue
# 45 — purple
# 46 — cyan
# 47 — grey
# 100 — dark grey
# 101 — light red
# 102 — light green
# 103 — yellow
# 104 — light blue
# 105 — light purple
# 106 — turquoise
# All the colour options have defaults, most of which I left unchanged — I only altered the most commonly listed entities. The list of entities you can change is:
# di — directory
# fi — file
# ln — link
# pi — FIFO (ie. a named pipe)
# so — socket
# bd — buffered block
# cd — unbuffered character
# or — link pointing to a non-existent file, ie. an orphan
# mi — link pointing to a non-existent file when you use ls -l
# ex — executable
# To list the defaults, enter:
# gdircolors --print-database
# As you’ll notice if you run the above command, a final tweak you can perform is to colour files by their extension. For example, to colour .md files white, you’d add:
# :*.md=0;37:
# to your LS_COLORS. The scope for customisation is colossal, and the key here is to experiment and find the colours you prefer and which are clear against whatever window-background colour (and opacity) you’ve set Terminal to display.
# needs brew install coreutils
# export LS_COLORS="$LS_COLORS:di=0;36:ln=0;93:ex=0;35:"

# alias ls='gls -F --group-directories-first --color=auto'
