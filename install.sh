#!/bin/bash

read -p "This operation will override the current app configurations, do you want to continue? (y/n):" -n 1 -r
echo


if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 1
fi

echo "Defining config directories"
DOTFILES_DIR=./.config/
W11_CONFIG_DIR=/mnt/c/Users/serhat/.config/
WSL_CONFIG_DIR=/home/serhat/.config/
echo "Done"



echo "Copying W11 configs..."
cp -r "$DOTFILES_DIR/"* "$W11_CONFIG_DIR"
echo "Done"


echo "Copying WSL configs..."
cp -r "$DOTFILES_DIR/"* "$WSL_CONFIG_DIR"
echo "Done"

