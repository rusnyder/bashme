#! /usr/bin/env bash

#   wa:     Cd's into redowl workspace, optionally into the project specified
#   Examples:
#     wa
#     wa ansible/roles
#   --------------------------------------------------------------------
REDOWL_WORKSPACE="$HOME/workspace/code/redowl"
wa () { cd "$REDOWL_WORKSPACE/$1"; }
_wa() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local dir="$(dirname "$cur")"
  local choices="$(/usr/bin/cd "$REDOWL_WORKSPACE"; /usr/bin/find "$dir" ! -path "$dir" -maxdepth 1 -type d | sed -e 's|^\./||' | grep -ve '/$')"

  COMPREPLY=( $(compgen -W "$choices" -- "$cur") )
}
complete -F _wa wa
