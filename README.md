# Jon Phenow's dotfiles

## install

TODO

```bash
brew install tmux
brew install visual-studio-code
brew install slack
brew install --cask tailscale
brew install 1password-cli
brew install reattach-to-user-namespace
brew install nvim
brew install zsh
brew install direnv
brew install coreutils # gnu tools
brew install grc # colorize commands
brew install asdf

brew install fd # find replacement
brew install ripgrep # grep replacement
brew install bat # cat replacement
brew install eza # ls replacement
brew install jq # json parser
brew install git # git-lfs
brew install procs # ps replacement
brew install sd # sed replacement
brew install dust # disk usage
brew install tokei # code stats
brew install hyperfine # benchmarking
brew install bottom # top replacement (btm)
brew install bandwhich # network usage
brew install grex # regex generator
brew install delta # diff viewer

git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3

# https://starship.rs/
brew install starship
starship preset pure-preset -o ~/.config/starship.toml

# install docker from docker.com

curl -L https://nixos.org/nix/install | sh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.dotfiles/zsh/plugins/zsh-autosuggestions
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# reload shell

# iterm2 color is tweaked from https://www.iterm2material.design/
# otherwise check out https://iterm2colorschemes.com/

chsh -s $(which zsh)
```

### iTerm

* Load profile from this folder
* Load KeyMap from this folder

## Other useful day-to-day tools

* [k9s](https://k9scli.io/)
* allow key-repeating on vscode https://vimforvscode.com/enable-key-repeat-vim
* magic shell history: https://atuin.sh/docs/advanced-install

# Inspo

* https://zaiste.net/posts/shell-commands-rust/
