#
# ~/.zshrc
#

# If not running interactively, don't do anything
[[ -o interactive ]] || return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

source ~/.zsh_aliases

eval "$(starship init zsh)"

dev() {
  "$HOME/repos/devcontainer/run.sh" "$@"
}
