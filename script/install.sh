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

	chsh -s $(which zsh)
	if [ -d "$HOME/.dotfiles" ]; then
		echo "${BOLD}~/.dotfiles${RESET} already exists, remove it or run update.sh"
		exit 1
	fi
	git clone https://github.com/jphenow/dotfiles.git $HOME/.dotfiles
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

setup_dotfiles() {
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
	setup_dotfiles

	printf "$GREEN"
	reload!
}

main "$@"
