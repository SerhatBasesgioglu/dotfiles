#!/bin/bash

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/repos/dotfiles}"

mkdir -p ~/.config

for dir in nvim git tmux; do
  ln -sfn "$DOTFILES_DIR/$dir" "$HOME/.config/$dir"
done


#Bash
ln -sfn "$DOTFILES_DIR"/bash/bash_aliases "$HOME"/.bash_aliases
ln -sfn "$DOTFILES_DIR"/bash/.bashrc "$HOME"/.bashrc
source ~/.bashrc
