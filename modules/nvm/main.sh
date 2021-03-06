#! /usr/bin/env bash

# Node Version Manager (nvm)

function nvm_start()
{
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1090
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  # shellcheck disable=SC1090
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

# Auto-load nvm for non-interactive shells
#case "$-" in
#*i*)  ;;
#*)	  nvm_start ;;
#esac
nvm_start
