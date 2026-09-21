#
# ~/.zshrc
#

# If not running interactively, don't do anything
[[ -o interactive ]] || return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases

setopt PROMPT_CR
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

dev() {
  "$HOME/repos/devcontainer/run.sh" "$@"
}

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="/opt/homebrew/bin:$PATH"

#export HTTP_PROXY="http://proxy.vakifbank.com.tr:80"
#export HTTPS_PROXY="http://proxy.vakifbank.com.tr:80"
#export NO_PROXY="*.local,localhost,169.254/16,.vakifbank.intra,.vakif.extra,.vakifbank.com.tr,10.231.28.17,127.0.0.1"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Corporate MITM proxy CA trust (vakifbank)
if [[ -f "$HOME/.vakif-ca-bundle.pem" ]]; then
  export NODE_EXTRA_CA_CERTS="$HOME/.vakif-ca-bundle.pem"
fi

export PATH="$HOME/.local/bin:$PATH"

# >>> oh-my-opencode-slim background subagents >>>
export OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true
export OPENCODE_ENABLE_EXA=1
# <<< oh-my-opencode-slim background subagents <<<
oc() {
  local target first origin_pane opencode_cmd
  local -a oc_args

  (( $# )) || {
    command opencode
    return
  }

  if [[ "$1" != -* ]]; then
    first="$1"
    if [[ -d "$first" ]]; then
      target="$first"
      shift
    elif [[ -d "$HOME/repos/$first" ]]; then
      target="$HOME/repos/$first"
      shift
    fi
  fi

  target="${target:-$PWD}"

  if [[ ! -d "$target" ]]; then
    print -u2 -- "oc: target is not a directory: $target"
    return 1
  fi

  target="$(cd "$target" 2>/dev/null && pwd -P)" || {
    print -u2 -- "oc: cannot resolve directory: $target"
    return 1
  }

  oc_args=("$@")
  opencode_cmd="opencode"
  if (( ${#oc_args[@]} )); then
    opencode_cmd+=" ${(j: :)${(q)oc_args}}"
  fi

  if tmux has-session 2>/dev/null; then
    origin_pane="$(tmux display-message -p '#{pane_id}')"
    tmux split-window -h -c "$target" "nvim"
    tmux send-keys -t "$origin_pane" "cd -- ${(q)target} && $opencode_cmd" Enter
  else
    tmux new-session -d -c "$target" "nvim"
    tmux split-window -h -c "$target" "$opencode_cmd"
    tmux attach-session
  fi
}

_oc() {
  if (( CURRENT == 2 )) && [[ "${words[CURRENT]}" != -* ]]; then
    _path_files -W "$HOME/repos" -/
  else
    _files -/
  fi
}
compdef _oc oc

oct() {
  local tmpdir
  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/oc-XXXXXX")"
  if tmux has-session 2>/dev/null; then
    tmux split-window -h -c "$tmpdir" "nvim"
    tmux select-pane -t 0
    tmux send-keys -t 0 "opencode $tmpdir" Enter
  else
    tmux new-session -d -c "$tmpdir" "nvim"
    tmux split-window -h -c "$tmpdir" "opencode $tmpdir"
    tmux attach-session
  fi
}

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
