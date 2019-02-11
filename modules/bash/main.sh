#! /usr/bin/env bash

require_coreutil ls

# Aliases

alias cp='cp -iv'                           # Preferred 'cp' implementation
alias mv='mv -iv'                           # Preferred 'mv' implementation
alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
alias ll='ls -FGlAhp --color=auto'          # Preferred 'ls' implementation
alias less='less -RSc'                      # Preferred 'less' implementation
cd() { builtin cd "$@" && ll; }             # Always list directory contents upon 'cd'
alias tailf='tail -f'
alias sudoedit='sudo vim'

# Tell parallel to shut the hell up
alias parallel='parallel --no-notice'

# Linux-specific aliases
if [[ $(uname -s) =~ Linux* ]]; then
  alias xc='xclip -selection clipboard'
  alias xv='xclip -o'
fi

#   Set default blocksize for ls, df, du
#   from this: http://hints.macworld.com/comment.php?mode=view&cid=24491
#   ------------------------------------------------------------
export BLOCKSIZE=1k

# Enable colors in command line tools by default
export CLICOLOR=true
