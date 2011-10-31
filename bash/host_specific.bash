# If you have a silly school like me that has a default
# rc file for a different shell then:
#  * copy their default
#  * make it work for your shell
#  * Do something like below where I
#    - check that I'm at a school computer by checking hostname
#    - source the file that you based on the school's rc

if [[ "$HOSTNAME" =~ "csbsju" ]]; then
	source $HOME/linuxpaths 2> /dev/null
	export GITPROMPT=false
	export TODOPROMPT=false
	export HOME=/net$HOME #Symlink from /net screws with prompt pathing
fi
