#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/jphenow/dotfiles/master/script/install.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/jphenow/dotfiles/master/script/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/jphenow/dotfiles/master/script/install.sh
#   sh install.sh

set -e

# Default settings
ZSH=${ZSH:-~/.oh-my-zsh}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

error() {
	echo ${RED}"Error: $@"${RESET} >&2
}

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

install_dependencies() {
	if [[ "$OSTYPE" = darwin* ]] && git --version | grep -q msysgit; then
		command_exists brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
		command_exists zsh || brew install zsh
		command_exists git || brew install git
	else
		command_exists curl || sudo apt install -y curl
		command_exists zsh || sudo apt install -y zsh
		command_exists git || sudo apt install -y git
	fi

	if [ "$(echo $SHELL)" != "$(which zsh)" ]; then
		echo "Switch shell from $SHELL to $(which zsh)..."
		chsh -s $(which zsh)
	fi

	if [ -d "$HOME/.dotfiles" ]; then
		echo "${BOLD}~/.dotfiles${RESET} already exists, attempting to pull updates..."
		cd $HOME/.dotfiles
		git pull
	else
		git clone https://github.com/jphenow/dotfiles.git $HOME/.dotfiles
		cd $HOME/.dotfiles
	fi
	RUN_ZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_modules() {
	for INSTALL_SCRIPT in $(ls */install.sh)
	do
		bash $INSTALL_SCRIPT
	done
}

setup_dotfiles() {
	dir=$(pwd)
	for DOTFILE in $(ls -lrt -d -1 */*.symlink)
	do
		target_name="$HOME/$(echo $DOTFILE | sed 's/\.symlink//g' | sed 's/\//\/./')"
		source_name="$dir/$DOTFILE"
		echo "Linking $source_name to $target_name..."
		unset -e

		ln -s $source_name $target_name
		if [ $? -eq 1 ]; then
			echo "Backing up existing $target_name to $target_name.bak..."
			mv $target_name $target_name.bak
			set -e
			ln -s $source_name $target_name
		fi

		set -e
	done
}

main() {
	# Run as unattended if stdin is closed
	if [ ! -t 0 ]; then
		RUNZSH=no
		CHSH=no
	fi

	# Parse arguments
	while [ $# -gt 0 ]; do
		case $1 in
			--unattended) RUNZSH=no; CHSH=no ;;
			--skip-chsh) CHSH=no ;;
			--keep-zshrc) KEEP_ZSHRC=yes ;;
		esac
		shift
	done

	setup_color
	install_dependencies
	install_modules
	setup_dotfiles

	printf "$GREEN"
	reload!
}

main "$@"
