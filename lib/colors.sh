#! /usr/bin/env bash

# Colors
declare -A __colors=(
  [reset]='0'
  [black]='0;30'
  [red]='0;91' # Usually 0;31 - I prefer a brighter variant
  [green]='0;32'
  [brown]='0;33'
  [orange]='0;33'
  [blue]='0;34'
  [purple]='0;35'
  [cyan]='0;36'
  [light_gray]='0;37'
  [dark_gray]='1;30'
  [light_red]='1;31'
  [light_green]='1;32'
  [yellow]='1;33'
  [light_blue]='1;34'
  [light_purple]='1;35'
  [light_cyan]='1;36'
  [white]='1;37'
)

for color in "${!__colors[@]}"; do
  eval "__${color}=\"\\e[${__colors[$color]}m\""
  eval "__ps1_${color}=\"\\[\\e[${__colors[$color]}m\\]\""
done

function push()
{
  local array="$1"
  shift 1
  for value in $@; do
    if [[ -v $array[@] ]]; then
      eval "$array+=(\"$value\")"
    else
      eval "$array=(\"$value\")"
    fi
  done
}

function pop()
{
  local array="$1"
  if [[ -v $array[@] ]]; then
    index=($(eval "echo \${!$array[@]}"))
    eval "echo \${$array[\${index[@]: -1}]}"
    unset "$array[\${index[@]: -1}]"
  else
    return 1
  fi
}

function colorize()
{
  local color="$1"
  if ! [[ $color =~ ^__ ]]; then
    color="__$color"
  fi
  shift 1
  eval echo -en "\${$color}$@\${__reset}"
}

