# Dotfiles

Personal configuration for Bash, Zsh, Git, Kitty, Neovim, Starship, and tmux.

## Installation

```sh
git clone git@github.com:SerhatBasesgioglu/dotfiles.git ~/repos/dotfiles
cd ~/repos/dotfiles
./install.sh
```

Set `DOTFILES_DIR` when the repository is cloned elsewhere:

```sh
DOTFILES_DIR="$PWD" ./install.sh
```

Existing configuration is moved to a timestamped `~/.dotfiles-backup-*` directory before links are created.

On macOS, the installer uses Homebrew to install the configured applications and command-line tools. On Linux, install the prerequisites with the system package manager first. Important commands include `git`, `nvim`, `tmux`, `rg`, `fd`, `fzf`, `lazygit`, `jq`, `starship`, `tree-sitter`, `shellcheck`, and `shfmt`.

## Tmux plugins

Tmux plugins are managed by TPM and intentionally ignored by Git. The installer clones TPM and installs the plugins declared in `tmux/tmux.conf`.

Inside tmux:

- `prefix + I` installs plugins.
- `prefix + U` updates plugins.

## Neovim

Neovim plugins are pinned in `nvim/lazy-lock.json`. Mason installs the configured language servers, debuggers, formatters, and linters when Neovim starts.

Useful checks:

```sh
XDG_CONFIG_HOME="$PWD" nvim --headless '+qa'
nvim '+checkhealth'
```

Some language tooling, such as the .NET SDK and project-specific runtimes, must still be installed separately.

## Validation

```sh
bash -n install.sh bash/.bashrc bash/bash_aliases
git diff --check
```
