#! /usr/bin/env bash

# This function creates monthly backups of the bash history file.
#
# And to search whole history use:
# grep xyz -h --color ~/.bash_history.*
#
function rotate_history()
{
  local keep=200
  local bash_hist="$HOME/.bash_history"
  local backup="${bash_hist}.$(date +%Y-%m)"

  if [ -s "$bash_hist" -a "$bash_hist" -nt "$backup" ]; then
    # history file is newer then backup
    if [[ -f $backup ]]; then
      # there is already a backup
      cp -f $bash_hist $backup
    else
      # create new backup, leave last few commands and reinitialize
      mv -f $bash_hist $backup
      tail -n$keep $backup > $bash_hist
      history -r
    fi
  fi
}

#   Configure the bash history, making it larger and global
#   from this: https://sanctum.geek.nz/arabesque/better-bash-history/
#   ------------------------------------------------------------
shopt -s histappend                     # append to .bash_history, don't overwrite
shopt -s cmdhist                        # store multi-line commands as one in history
export HISTFILESIZE=1000000             # increase max size of history file
export HISTSIZE=1000000                 # increase max line cound of history file
export HISTCONTROL=ignoreboth           # ignore dupes and lines starting w/ spaces
export HISTIGNORE='ls:ll:bg:fg:history' # ignore common commands w/ no use
export HISTTIMEFORMAT='%F %T '          # add timestamps to the history
export PROMPT_COMMAND='history -a ; $PROMPT_COMMAND'
                                        # append commands to history immediately

# With environment configured, invoke the rotator (only rotates when necessary)
rotate_history
