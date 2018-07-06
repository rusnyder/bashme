#! /usr/bin/env bash

# Internal functions

function __git_alias()
{
  local bash_alias="$1"
  local git_command="$2"

  alias ${bash_alias}="git ${git_command}"
  __git_complete ${bash_alias} "_git_$(echo "$git_command" | cut -d' ' -f1)"
}

# Aliases
__git_alias gs status
__git_alias gco checkout
__git_alias gu pull
__git_alias glog glog
__git_alias gfix "diff --name-only | uniq | xargs $EDITOR -"

# Functions
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Variables
export PATH="/usr/local/git/bin:$PATH"
