# Claude Code loads project skills only from .claude/skills between the start
# directory and the repo root, so a workspace folder holding several repos
# (e.g. ~/workspace/acme/.claude/skills) is never seen from inside one of them.

# claude [args]: runs Claude Code with --add-dir for every directory above the
# current repo (below ~) that has .claude/skills, and for ~/.claude/local, a
# private, untracked home for skills that must not go in the public dotfiles.
# The =value form keeps --add-dir from swallowing a prompt or subcommand.
command -v claude >/dev/null 2>&1 && claude() {
	local -a dirs
	local dir
	dir=$(git rev-parse --show-toplevel 2>/dev/null) || dir=$PWD
	dir=${dir:h}
	while [[ $dir == $HOME/* ]]; do
		[[ -d $dir/.claude/skills ]] && dirs+=(--add-dir="$dir")
		dir=${dir:h}
	done
	[[ -d $HOME/.claude/local/.claude/skills ]] && dirs+=(--add-dir="$HOME/.claude/local")
	command claude "${dirs[@]}" "$@"
}
