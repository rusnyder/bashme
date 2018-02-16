#! /usr/bin/env bash

load_module git

# Functions

build_ps1() {
  # Colors
  local grey="\[\e[0;39m\]"
  local red="\[\e[0;91m\]"
  local cyan="\[\e[0;36m\]"
  local green="\[\e[0;32m\]"
  local gold="\[\e[0;33m\]"

  # Text
  local timestamp="${gold}[\D{%F %T}]"
  local dir="${cyan}\w"
  local git="${green}\$(parse_git_branch)"
  local prompt="${grey}→ "

  echo "\n${timestamp} ${dir} ${git}\n${prompt}"
}

# Variables

export PS1="$(build_ps1)"
