# $Id: .cshrc,v 1.2 2000-11-09 04:55:14 sage Exp $
# Luis Francisco González <luisgh@debian.org> based on that of Vadik Vygonets
# Please check /usr/doc/tcsh/examples/cshrc to see other possible values.
# DO NOT REMOVE THE FOLLOWING TWO LINES!
set defaultsdir=~defaults
source ${defaultsdir}/linuxpaths
# source ${HOME}/linuxpaths
# # add your custom shell commands here
# # see 'man tcsh' for more info
if ( $?prompt ) then
  set autoexpand
  set autolist
  set cdpath = ( ~ )
  set pushdtohome

  set savehist=10000
  set histfile=~/.history

# Load aliases from ~/.alias
  if ( -e ~/.alias )	source ~/.alias

endif
