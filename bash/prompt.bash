# Put your fun prompt configs in here
# Mine includes Goodness like:
#  * Colors
#  * Git branch name
git_color() {
  local R='\e[0;31m'
  local G='\e[0;32m'
  local C='\e[0;36m'
  if [[ $GITPROMPT == true ]]
  then
    st=$(/usr/bin/git status 2>/dev/null | tail -n 1)
    if [[ $st != "" ]]
    then
      if [[ $st == "nothing to commit (working directory clean)" ]]
      then
        echo -e "$G"
      else
        echo -e "$R"
      fi
    fi
  else
    echo -e "$C"
  fi
}

# TODO make easier for anyone to add to prompt
rvm_prompt(){
  local Y='\e[0;33m'
  if $(which rvm &> /dev/null)
  then
    echo -e "${Y}$(rvm tools identifier)"
  else
    echo ""
  fi
}

# This keeps the number of todos always available the right hand side of my
# command line. I filter it to only count those tagged as "+next", so it's more
# of a motivation to clear out the list.
# NOTE: I have changed todo.sh to todo - You may want to either do the same or
# Fix accordingly below
todonum(){
  if [[ $TODOPROMPT == true ]]
  then
    if $(which todo.sh &> /dev/null)
    then
      num=$(echo $(todo.sh ls +next | wc -l))
      let todos=num-2
      if [ $todos != 0 ]
      then
        echo "[$todos]"
      else
        echo ""
      fi
    else
      echo ""
    fi
  fi
}
git_ps1 ()
{
  __git_ps1 1>/dev/null 2>/dev/null
  err=$?
  if [ "$err" == "0" ]; then
    echo "$(__git_ps1)"
  else
    echo ""
  fi
}

trim() { echo $1; }
function prompt_color() {
  local DR='\e[1;31m'
  local D='\e[1;32m'
  if [[ ${EUID} == 0 ]] ; then
    echo -e "$DR"
  else
    echo -e "$D"
  fi
}
# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
# TODO Prompt config looks like ass - cleanup
function prompt() {

  # You want this here
  local use_color=false
  local nc='\e[0;0m'
  local M='\e[0;35m'
  local DG='\e[1;34m'
  local DR='\e[1;31m'
  local D='\e[1;32m'
  local safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
  local match_lhs=""

  [[ -f $DOT/colors/dir_colors   ]] && match_lhs="${match_lhs}$(<$DOT/colors/dir_colors)"

  [[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"

  [[ -z ${match_lhs}    ]] \
    && type -P dircolors >/dev/null \
    && match_lhs=$(dircolors --print-database)

  [[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

  if ${use_color} ; then
    # Enable colors for ls, etc.  Prefer $DOT/colors/dir_colors #64489
    if type -P dircolors >/dev/null ; then
      if [[ -f $DOT/colors/dir_colors ]] ; then
        eval $(dircolors -b $DOT/colors/dir_colors)
      elif [[ -f /etc/DIR_COLORS ]] ; then
        eval $(dircolors -b /etc/DIR_COLORS)
      fi
    fi
  fi

  local ps1='${debian_chroot:+($debian_chroot)}\u@\h'
  local git='\[$(git_color)\]$(__git_ps1 " (%s)" 2>/dev/null)'
  local dir='\w'
  local todo='$(todonum)'
  export PS1=$(echo '\n\[$(prompt_color)\]'"$ps1""$git" "\[$DG\]""$dir" "\[$M\]$todo\[$nc\]" "$(rvm_prompt)" "\[$nc\]" ' \n[\!]\$ ');

  alias ls='ls --color=auto'
  alias grep='grep --colour=auto'
}

prompt
