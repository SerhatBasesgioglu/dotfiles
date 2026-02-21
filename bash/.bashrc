#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Enable colors
color_prompt=yes

if [ "$color_prompt" = yes ]; then
    PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi

PS1="\[\e]0;\u@\h: \w\a\]$PS1"


source ~/.bash_aliases


dev() {
  "$HOME/repos/devcontainer/run.sh" "$@"
}
