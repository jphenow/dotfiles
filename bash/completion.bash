# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# TODO Add completion for dotfiles

# if the command-not-found package is installed, use it
# Honestly wasn't sure where to place
if [ -x /usr/lib/command-not-found ]; then
	function command_not_found_handle {
	# check because c-n-f could've been removed in the meantime
		if [ -x /usr/lib/command-not-found ]; then
			/usr/bin/python /usr/lib/command-not-found -- $1
			return $?
		else
		   return 127
		fi
	}
fi
