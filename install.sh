#!/bin/bash

DOTFILES_DIR=~/repos/dotfiles/
W11_CONFIG_DIR=/mnt/c/Users/serhat/
WSL_CONFIG_DIR=/home/serhat/


#Neovim
ln -sfn "$DOTFILES_DIR"/nvim "$WSL_CONFIG_DIR"/.config/

#Git
ln -sfn "$DOTFILES_DIR"/git "$WSL_CONFIG_DIR"/.config/

#Wezterm
ln -sfn "$DOTFILES_DIR"/wezterm "$WSL_CONFIG_DIR"/.config/
cp -r "$DOTFILES_DIR"/wezterm "$W11_CONFIG_DIR"/.config/

#Tmux
ln -sfn "$DOTFILES_DIR"/tmux "$WSL_CONFIG_DIR"/.config/

#Bash
ln -sfn "$DOTFILES_DIR"/bash/bash_aliases "$WSL_CONFIG_DIR"/.bash_aliases
source ~/.bashrc
