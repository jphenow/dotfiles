# ZSH Theme - Preview: http://gyazo.com/8becc8a7ed5ab54a0262a470555c3eed.png
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

local user_host='%{$terminfo[bold]$fg[green]%}%n@%m%{$reset_color%}'
local current_dir='%{$terminfo[bold]$fg[blue]%} %~%{$reset_color%}'
local rvm_ruby='%{$fg[red]%}‹$(rvm-prompt i v g)›%{$reset_color%}'
#local git_branch='$(git_prompt_info)%{$reset_color%}'
local right_time='[%{$fg[green]%} %t %{$reset_color%}]'
local git_branch='[ $(git_prompt_status)%{$reset_color%}$(git_prompt_info)%{$reset_color%} ]'

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

PROMPT="╭─${user_host} %{$fg[blue]%}in%{$reset_color%} ${current_dir} %{$fg[blue]%}using%{$reset_color%} ${rvm_ruby} %{$fg[blue]%}on%{$reset_color%} ${git_branch}
╰─%B$%b "
RPROMPT="${right_time} ${return_code}"

#ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
#ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"
