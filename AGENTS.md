# Repository Guide

## Layout
- `nvim/` is the Neovim config and is symlinked to `~/.config/nvim` by `install.sh`.
- `tmux/` is the tmux config and plugin checkout area.
- `git/` is symlinked to `~/.config/git`.
- `bash/` contains shell dotfiles linked into `$HOME`.

## Working Notes
- Expect a dirty worktree. Do not revert unrelated changes.
- Prefer small, targeted edits over broad refactors.
- Keep personal-machine assumptions explicit when changing paths in the dotfiles.
- When editing Neovim config, check both `nvim/init.lua` and active plugin specs under `nvim/lua/plugins/`.
- Files under `nvim/lua/plugins/archive/` are not part of the active `lazy.nvim` import path unless moved back under `nvim/lua/plugins/`.

## Validation
- There is no single top-level test suite.
- For Neovim changes, prefer validating with `nvim --headless` when available and by checking plugin/config entrypoints for stale references.
- Keep install-path changes aligned with `install.sh` symlink behavior.
