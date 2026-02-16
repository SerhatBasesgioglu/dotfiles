#!/bin/bash

DOTFILES_DIR=~/repos/dotfiles


#Neovim
ln -sfn "$DOTFILES_DIR"/nvim "$HOME"/.config/

#Git
ln -sfn "$DOTFILES_DIR"/git "$HOME"/.config/

#Tmux
ln -sfn "$DOTFILES_DIR"/tmux "$HOME"/.config/

#Bash
ln -sfn "$DOTFILES_DIR"/bash/bash_aliases "$HOME"/.bash_aliases
ln -sfn "$DOTFILES_DIR"/bash/.bashrc "$HOME"/.bashrc
source ~/.bashrc
