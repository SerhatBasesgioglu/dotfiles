# If not running interactively, don't do anything
[[ $- != *i* ]] && return

GREEN='\[\e[1;32m\]'
SOFT_RED='\[\e[38;5;210m\]'
HARD_RED='\[\e[1;31m\]'
BLUE='\[\e[1;34m\]'
CYAN='\[\e[0;36m\]'
RESET='\[\e[0m\]'

if [[ $(hostname) == "an"* || $(hostname) == "is"* ]]; then
    H_COLOR=$HARD_RED
  else
    H_COLOR=$GREEN
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Enable colors
color_prompt=yes

if [ "$color_prompt" = yes ]; then
  # Format: [serhat@anckpkbmlx02] ~/path $
  PS1="${CYAN}[${SOFT_RED}\u${RESET}@${H_COLOR}\h ${BLUE}\w${CYAN}]${RESET}\$ "
else
  PS1='\u@\h:\w\$ '
fi

# Keep the window title update
PS1="\[\e]0;\u@\h: \w\a\]$PS1"

[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

dev() {
  "$HOME/repos/devcontainer/run.sh" "$@"
}

#export HTTP_PROXY=http://proxy.vakifbank.com.tr:80
#export http_proxy=http://proxy.vakifbank.com.tr:80
#export HTTPS_PROXY=http://proxy.vakifbank.com.tr:80
#export https_proxy=http://proxy.vakifbank.com.tr:80
#export no_proxy="local,localhost,vakifbank.intra,vakif.extra,vakifbank.com.tr,svc,127.0.0.1,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"
#export NO_PROXY="local,localhost,vakifbank.intra,vakif.extra,vakifbank.com.tr,svc,127.0.0.1,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"

if [[ -f "$HOME/.vakif-ca-bundle.pem" ]]; then
  export NODE_EXTRA_CA_CERTS="$HOME/.vakif-ca-bundle.pem"
fi

export PATH="$HOME/.local/bin:$HOME/.opencode/bin:/opt/node/bin:/var/lib/rancher/rke2/bin:$PATH"

# Load Angular CLI autocompletion.
#source <(ng completion script)

alias k=kubectl
if command -v kubectl &>/dev/null; then
  source <(kubectl completion bash)
  complete -o default -F __start_kubectl k
fi
