#!/bin/bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/repos/dotfiles}"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { printf '%b✓ %s%b\n' "$GREEN" "$1" "$NC"; }
warn()  { printf '%b⚠ %s%b\n' "$YELLOW" "$1" "$NC"; }
error() { printf '%b✗ %s%b\n' "$RED" "$1" "$NC"; }
step()  { printf '\n%b▸ %s%b\n' "$BLUE" "$1" "$NC"; }

OS="$(uname -s)"
ARCH="$(uname -m)"

if ! command -v git &>/dev/null; then
  error "git is required to install these dotfiles"
  exit 1
fi

link_file() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local current relative
    current=$(readlink "$dst" 2>/dev/null || echo "")
    if [ "$current" = "$src" ]; then
      info "Already linked: $dst"
      return
    fi
    warn "Backing up: $dst → $BACKUP_DIR/"
    relative="${dst#"$HOME"/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
    mv -- "$dst" "$BACKUP_DIR/$relative"
  fi
  ln -sfn "$src" "$dst"
  info "Linked: $dst → $src"
}

# ──────────────────────────────────────────────
# 1. Symlink configs
# ──────────────────────────────────────────────
step "Symlinking configs"

mkdir -p "$HOME/.config"

for dir in kitty nvim git tmux; do
  if [ -d "$DOTFILES_DIR/$dir" ]; then
    link_file "$DOTFILES_DIR/$dir" "$HOME/.config/$dir"
  fi
done

if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
  link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
fi

if [ -d "$DOTFILES_DIR/opencode" ]; then
  link_file "$DOTFILES_DIR/opencode" "$HOME/.config/opencode"
fi

if [ -f "$DOTFILES_DIR/bash/bash_aliases" ]; then
  link_file "$DOTFILES_DIR/bash/bash_aliases" "$HOME/.bash_aliases"
fi

if [ -f "$DOTFILES_DIR/bash/.bashrc" ]; then
  link_file "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
fi

if [ -f "$DOTFILES_DIR/zsh/zsh_aliases" ]; then
  link_file "$DOTFILES_DIR/zsh/zsh_aliases" "$HOME/.zsh_aliases"
fi

if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
  link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
fi

# ──────────────────────────────────────────────
# 2. Homebrew
# ──────────────────────────────────────────────
if [ "$OS" = "Darwin" ]; then
  step "Homebrew"

  if ! command -v brew &>/dev/null; then
    warn "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ "$ARCH" = "arm64" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    info "Homebrew installed"
  else
    info "Homebrew already installed"
  fi

  BREW_PACKAGES=(
    neovim
    tmux
    git
    ripgrep
    fd
    fzf
    lazygit
    bat
    eza
    zoxide
    jq
    gh
    starship
    tree-sitter
    shellcheck
    shfmt
  )

  BREW_CASKS=(
    kitty
    font-jetbrains-mono-nerd-font
  )

  step "Installing CLI tools"
  for pkg in "${BREW_PACKAGES[@]}"; do
    if brew list "$pkg" &>/dev/null 2>&1; then
      info "Already installed: $pkg"
    else
      brew install "$pkg"
      info "Installed: $pkg"
    fi
  done

  step "Installing casks & fonts"
  for cask in "${BREW_CASKS[@]}"; do
    if brew list --cask "$cask" &>/dev/null 2>&1; then
      info "Already installed: $cask"
    else
      brew install --cask "$cask"
      info "Installed: $cask"
    fi
  done

  brew cleanup
  info "Brew cleanup done"
fi

# ──────────────────────────────────────────────
# 3. Tmux plugins (TPM)
# ──────────────────────────────────────────────
step "Tmux plugins"

TPM_DIR="$HOME/.config/tmux/plugins/tpm"
mkdir -p "$(dirname "$TPM_DIR")"
if [ ! -x "$TPM_DIR/tpm" ]; then
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  info "TPM cloned"
else
  info "TPM already installed"
fi

# Install TPM plugins headlessly
if "$TPM_DIR/bin/install_plugins" &>/dev/null; then
  info "Tmux plugins installed"
else
  warn "Tmux plugin installation failed; run $TPM_DIR/bin/install_plugins manually"
fi

# ──────────────────────────────────────────────
# 4. macOS settings
# ──────────────────────────────────────────────
if [ "$OS" = "Darwin" ]; then
  step "macOS defaults"

  # Show hidden files in Finder
  defaults write com.apple.finder AppleShowAllFiles -bool true
  # Show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  # Avoid creating .DS_Store on network/removeable volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  killall Finder &>/dev/null || true
  info "macOS defaults applied"
fi

# ──────────────────────────────────────────────
# Done
# ──────────────────────────────────────────────
printf '\n%b✔ All done!%b\n' "$GREEN" "$NC"
if [ -d "$BACKUP_DIR" ]; then
  warn "Backups saved to: $BACKUP_DIR"
fi
echo "Restart your shell to load the new configuration."
