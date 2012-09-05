# todo.sh: https://github.com/ginatrapani/todo.txt-cli
function to() { 
  if [ $# -eq 0 ]; then
    todo.sh ls
  else
    todo.sh $*
  fi
}

alias n="to ls +next"
