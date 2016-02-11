# vim: set filetype=zsh :
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

local ruby_version=''
if which rbenv &> /dev/null; then
  ruby_version='$(rbenv version | sed -e "s/ (set.*$//")'
fi
local user_host='%{$terminfo[bold]$fg[green]%}%n@%m%{$reset_color%}'
local current_dir='%{$terminfo[bold]$fg[blue]%} %~%{$reset_color%}'

_git_repo_name() {
  gittopdir=$(git rev-parse --git-dir 2> /dev/null)
  if [[ "foo$gittopdir" == "foo.git" ]]; then
    echo `basename $(pwd)`
  elif [[ "foo$gittopdir" != "foo" ]]; then
    echo `dirname $gittopdir | xargs basename`
  fi
}

_todonum(){ #statements
  #if [[ $TODOPROMPT == true ]]
  #then
    if $(which todo.sh &> /dev/null)
    then
      git_repo_name="$(_git_repo_name)"
      if [ ! -z "$git_repo_name" ]; then
        query="+$git_repo_name"
        let num=$(echo $(todo.sh ls $query | wc -l))
        let todos=num-2
        if [ $todos != 0 ]
        then
          echo "$fg[yellow][$todos]$reset_color"
        fi
      fi
    fi
  #fi
}
local todonum='$(_todonum)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[magenta]%}?"

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✹"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ═"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭"

_git_section() {
  git_branch="$(git_prompt_info)%{$reset_color%}"
  if [ ! -z "$(git_prompt_info)" ]; then
    echo " $fg[blue]on$reset_color $git_branch"
  fi
}
local git_section='$(_git_section)'

PROMPT="╭─${user_host} ${current_dir} {$fg[red]${ruby_version}$reset_color}${git_section}${todonum}
╰─%B$%b "
RPROMPT="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[yellow]%}› %{$reset_color%}"
