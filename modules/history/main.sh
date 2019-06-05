#! /usr/bin/env bash

shopt -s histappend                       # append new history items to .bash_history
shopt -s cmdhist                          # store multi-line commands as a single entry
shopt -s lithist                          # store multi-line commands newline-delimited
export HISTCONTROL=ignoreboth:erasedups   # leading space hides commands from history, remove dupes
export HISTFILESIZE=10000                 # increase history file size (default is 500)
export HISTSIZE=${HISTFILESIZE}           # increase history size (default is 500)
# ensure synchronization between Bash memory and history file
export PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"
export HISTTIMEFORMAT='%F %T '
