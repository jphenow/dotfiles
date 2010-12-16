# $Id: .cshrc,v 1.2 2000-11-09 04:55:14 sage Exp $
# Luis Francisco González <luisgh@debian.org> based on that of Vadik Vygonets
# Please check /usr/doc/tcsh/examples/cshrc to see other possible values.
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
