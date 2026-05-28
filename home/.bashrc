#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

fastfetch
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$HOME/go/bin
export ANTHROPIC_API_KEY=""  # set manually
. "$HOME/.cargo/env"
