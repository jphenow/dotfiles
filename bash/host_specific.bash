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
  export PATH=/opt/java-jdk:$PATH

  # Added this because for some reason default location at school
  # is our physical path, but $HOME dir is the logical path which
  # all screws up our prompt. This unobstrussively fixes this.
  if [[ "$(pwd -P)" == "/net"$HOME && "$(pwd -L)" != $HOME ]]; then
    cd
  fi
  if [[ "$XAUTHORITY" =~ "root" ]]; then
    export TODOPROMPT=false
  fi
fi
