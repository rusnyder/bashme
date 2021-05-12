#! /usr/bin/env bash
# shellcheck disable=SC2034

load_module git

# Functions
parse_venv() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local project
    if [[ -f "${VIRTUAL_ENV}/.project" ]]; then
      # Pipenv - adds .project file w/ prettier name
      project="$(basename "$(cat "${VIRTUAL_ENV}/.project")")"
    else
      # All others - just use the venv directory name
      project="${VIRTUAL_ENV##*/}"
    fi
    echo -n " [venv: $project]"
  fi
}

build_ps1() {
  # Colors
  local grey="\[\e[0;39m\]"
  local red="\[\e[0;91m\]"
  local cyan="\[\e[0;36m\]"
  local green="\[\e[0;32m\]"
  local gold="\[\e[0;33m\]"

  # Text
  ARCH="$(uname -m)"
  local arch="${red}[$ARCH]"
  local timestamp="${gold}[\D{%F %T}]"
  local dir="${cyan}\w"
  local git="${green}\$(parse_git_branch)"
  local venv="${red}\$(parse_venv)"
  local prompt="${grey}→ "

  echo -e "\n${arch} ${timestamp} ${dir}${git}${venv}\n${prompt}"
}

# Variables

PS1="$(build_ps1)"
export PS1
