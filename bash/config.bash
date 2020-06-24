set -o vi
export EDITOR=/usr/bin/vim

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# History
shopt -s histappend
HISTFILESIZE=100000000
HISTSIZE=100000
PROMPT_COMMAND='history -a'

# Nice
#bind '"\C-s": menu-complete'
bind '"\C-f": history-search-backward'
