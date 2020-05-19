#!/usr/bin/env bash

mkdir -p ~/.config/nvim/
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
if [ -f ~/.config/nvim/init.vim ]; then
  mv ~/.config/nvim/init.vim ~/.config/nvim/init.vim.bak
  echo "Found ~/.config/nvim/init.vim already exists. creating ~/.config/nvim/init.vim.bak so you can double check contents"
fi
pip3 install --user neovim
ln -s "${pwd}/init.vim" ~/.config/nvim/init.vim
echo "open vim and run: PlugInstall and UpdateRemotePlugins"
