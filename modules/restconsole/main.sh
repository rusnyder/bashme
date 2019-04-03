#! /usr/bin/env bash
# shellcheck disable=SC2034

RESTCONSOLE_HOME="$HOME/.rest"

rest()
{
  local locator="$1"
  if ! [[ -d "$RESTCONSOLE_HOME" ]]; then
    mkdir -p "$RESTCONSOLE_HOME"
  fi
  if [[ -z "$locator" ]]; then
    vim "+cd $RESTCONSOLE_HOME" "+TemplateHere rest" "+set filetype=rest"
  else
    echo "Checking for ${RESTCONSOLE_HOME}/$locator"
    if [[ -f "${RESTCONSOLE_HOME}/$locator" ]]; then
      if ! [[ -e "${RESTCONSOLE_HOME}/${locator}.rest" ]]; then
        mv "${RESTCONSOLE_HOME}/${locator}" "${RESTCONSOLE_HOME}/${locator}.rest"
      else
        echo "ERROR: Malformed RestConsole home dir!  Naming conflict between: " >/dev/stderr
        echo "  - ${RESTCONSOLE_HOME}/${locator}" >/dev/stderr
        echo "  - ${RESTCONSOLE_HOME}/${locator}.rest" >/dev/stderr
        echo "Either delete one of the files, or merge them and leave only one of them remaining" >/dev/stderr
        return 1
      fi
    fi
    vim "${RESTCONSOLE_HOME}/${locator}.rest"
  fi
} # rest

_rest()
{
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local choices
  choices="$(/usr/bin/find "$RESTCONSOLE_HOME" \
    -mindepth 1 -maxdepth 1 -type f -exec basename {} \; \
    | sed -e 's/\.[^.]\{1,\}$//')"

  mapfile -t COMPREPLY < <(compgen -W "${choices}" -- "${cur}")
} # _rest (completion)

complete -F _rest rest
