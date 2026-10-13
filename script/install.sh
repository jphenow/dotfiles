#!/usr/bin/env bash
#
# This script should be run via curl:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/jphenow/dotfiles/main/script/install.sh)"
# or from a checkout:
#   ~/.dotfiles/script/install.sh
#
# Safe to re-run: installs only what's missing and backs up (never deletes)
# anything it would replace.
#
# Flags:
#   --skip-chsh   don't change the login shell to zsh
#   --unattended  same as --skip-chsh (also implied when stdin isn't a terminal)

set -e

DOTFILES="$HOME/.dotfiles"
ZSH=${ZSH:-$HOME/.oh-my-zsh}

# command_exists NAME: true when NAME is on PATH.
command_exists() {
	command -v "$@" >/dev/null 2>&1
}

# setup_color: sets color variables when stdout is a terminal, blanks otherwise.
setup_color() {
	if [ -t 1 ]; then
		GREEN=$(printf '\033[32m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		GREEN=""
		BOLD=""
		RESET=""
	fi
}

# install_dependencies: installs the few tools the dotfiles need to bootstrap
# (Homebrew on macOS, apt on Debian/Ubuntu; other systems are skipped),
# clones or updates ~/.dotfiles, oh-my-zsh and zsh-autosuggestions.
install_dependencies() {
	if [ "$(uname -s)" = "Darwin" ]; then
		if ! command_exists brew; then
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		fi
		# A fresh Homebrew isn't on PATH yet in this shell
		for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
			[ -x "$brew_bin" ] && eval "$("$brew_bin" shellenv)" && break
		done
		command_exists zsh || brew install zsh
		command_exists git || brew install git
		command_exists reattach-to-user-namespace || brew install reattach-to-user-namespace
		command_exists ag || brew install the_silver_searcher
		command_exists fpp || brew install fpp # https://facebook.github.io/PathPicker/
		command_exists urlview || brew install urlview # https://packages.debian.org/stable/misc/urlview
	elif command_exists apt-get; then
		command_exists curl || sudo apt-get install -y curl
		command_exists zsh || sudo apt-get install -y zsh
		command_exists git || sudo apt-get install -y git
	else
		echo "No brew or apt-get; make sure curl, git and zsh are installed."
	fi

	if [ "$CHSH" != "no" ] && [ "$SHELL" != "$(command -v zsh)" ]; then
		echo "Switch shell from $SHELL to $(command -v zsh)..."
		chsh -s "$(command -v zsh)"
	fi

	if [ -d "$DOTFILES" ]; then
		echo "${BOLD}~/.dotfiles${RESET} already exists, attempting to pull updates..."
		git -C "$DOTFILES" pull --ff-only || echo "Couldn't fast-forward ~/.dotfiles; leaving it as is."
	else
		git clone https://github.com/jphenow/dotfiles.git "$DOTFILES"
	fi

	if [ ! -d "$ZSH" ]; then
		# Our zshrc gets symlinked below, and chsh is handled above
		RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
			sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi

	if [ ! -d "$DOTFILES/zsh/plugins/zsh-autosuggestions" ]; then
		git clone https://github.com/zsh-users/zsh-autosuggestions "$DOTFILES/zsh/plugins/zsh-autosuggestions"
	fi
}

# install_modules: runs any <topic>/install.sh other than this script.
install_modules() {
	for INSTALL_SCRIPT in "$DOTFILES"/*/install.sh; do
		[ -f "$INSTALL_SCRIPT" ] || continue
		[ "$INSTALL_SCRIPT" = "$DOTFILES/script/install.sh" ] && continue
		bash "$INSTALL_SCRIPT"
	done
}

# link_file SOURCE TARGET: symlinks TARGET to SOURCE, moving anything already
# at TARGET to TARGET.bak first. No-op if the link is already in place.
link_file() {
	local source_name=$1 target_name=$2
	if [ -L "$target_name" ] && [ "$(readlink "$target_name")" = "$source_name" ]; then
		return
	fi
	if [ -e "$target_name" ] || [ -L "$target_name" ]; then
		echo "Backing up existing $target_name to $target_name.bak..."
		mv "$target_name" "$target_name.bak"
	fi
	echo "Linking $source_name to $target_name..."
	ln -s "$source_name" "$target_name"
}

# setup_dotfiles: links each <topic>/<name>.symlink file to ~/.<name>. A
# .symlink directory (e.g. ssh.symlink) becomes a real ~/.<name> directory
# with only its git-tracked files linked in, so private keys and other local
# files stay out of the repo's working tree. An older whole-directory link
# is left alone.
setup_dotfiles() {
	local dotfile target_name tracked
	for dotfile in "$DOTFILES"/*/*.symlink; do
		target_name="$HOME/.$(basename "$dotfile" .symlink)"
		if [ ! -d "$dotfile" ]; then
			link_file "$dotfile" "$target_name"
		elif [ -L "$target_name" ] && [ "$(readlink "$target_name")" = "$dotfile" ]; then
			echo "$target_name links to the whole $dotfile directory; leaving it as is."
		else
			if [ -L "$target_name" ] || { [ -e "$target_name" ] && [ ! -d "$target_name" ]; }; then
				mv "$target_name" "$target_name.bak"
			fi
			[ -d "$target_name" ] || mkdir -m 700 "$target_name"
			git -C "$DOTFILES" ls-files -- "${dotfile#"$DOTFILES"/}" | while read -r tracked; do
				link_file "$DOTFILES/$tracked" "$target_name/$(basename "$tracked")"
			done
		fi
	done
}

# main [flags]: parses flags (see top of file) and runs each install step.
main() {
	# Run as unattended if stdin is closed
	if [ ! -t 0 ]; then
		CHSH=no
	fi

	while [ $# -gt 0 ]; do
		case $1 in
			--unattended|--skip-chsh) CHSH=no ;;
		esac
		shift
	done

	setup_color
	install_dependencies
	install_modules
	setup_dotfiles

	printf "%s" "$GREEN"
	echo "TODO"
	echo "  * cp ~/.dotfiles/git/gitconfig.symlink.example ~/.gitconfig"
	echo "  * vim ~/.gitconfig"
	echo "  * optional tools: see ~/.dotfiles/README.md"
	echo "Please open a new terminal!"
	printf "%s" "$RESET"
}

main "$@"
