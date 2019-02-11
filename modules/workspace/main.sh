#! /usr/bin/env bash

require_coreutil sed

#   wa:     Cd's into redowl workspace, optionally into the project specified
#   Examples:
#     wa
#     wa ansible/roles
#   --------------------------------------------------------------------
export ARCEO_WORKSPACE="$HOME/workspace/code/arceo-labs"
wa () { cd "$ARCEO_WORKSPACE/$1" || return; }
_wa() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local choices
  choices="$(/usr/bin/find "$ARCEO_WORKSPACE" -mindepth 1 -maxdepth 1 -type d | xargs basename)"

  COMPREPLY=( $(compgen -W "$choices" -- "$cur") )
}
complete -F _wa wa
