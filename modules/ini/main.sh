#!/usr/bin/env bash

# Word splitting is intentional - disable shellcheck that asks for quoting
# shellcheck disable=SC2206
function load_ini () {
  local fixed_file IFS ini
  fixed_file="$(sed 's/ = /=/g' < "$1")"        # fix ' = ' to be '='
  IFS=$'\n' && ini=( $fixed_file )              # convert to line-array
  ini=( ${ini[*]//;*/} )                        # remove comments
  ini=( ${ini[*]/#[/\}$'\n'cfg.section.} )      # set section prefix
  ini=( ${ini[*]/%]/ \(} )                      # convert text2function (1)
  ini=( ${ini[*]/=/=\( } )                      # convert item to array
  ini=( ${ini[*]/%/ \)} )                       # close array parenthesis
  ini=( ${ini[*]/%\( \)/\(\) \{} )              # convert text2function (2)
  ini=( ${ini[*]/%\} \)/\}} )                   # remove extra parenthesis
  ini[0]=''                                     # remove first element
  ini[${#ini[*]} + 1]='}'                       # add the last brace
  # shellcheck disable=SC2116
  eval "$(echo "${ini[*]}")"                    # eval the result
}
export -f load_ini

function ini_to_json() {
  local ini_file="$1"
  if [ -z "$ini_file" ]; then
    echo "ERROR: No ini file specified" >/dev/stderr
    return 1
  fi
  python - <<-EOF
	import configparser, json, sys
	config = configparser.ConfigParser(default_section='default')
	config.read('${ini_file}')
	as_dict = dict([(section, dict(config[section])) for section in config.sections() + [config.default_section]])
	sys.stdout.write(json.dumps(as_dict))
	EOF
}
export -f ini_to_json

# usage: load_ini_section <ini_file> <section>
#
# Examples:
#   1. Loop through k/v pairs in ini section:
#
#     while read -r k v; do
#       echo "Key: $k, Value: $v"
#     done < <(load_ini_section '~/.some/file' 'my-section')
#
#   2. Assign ini section to associative array
#
#     declare -A ary
#     while read -r k v; do
#       ary["$k"]="$v"
#     done < <(load_ini_section '~/.some/file' 'my-section')
#     echo "Value for key 'abc': ${ary[abc]}"
function load_ini_section() {
  local ini_file="${1}"
  local section="${2:-default}"
  if ! json="$(ini_to_json "$ini_file" | jq -c ".${section}")"; then
    echo "ERROR: Failed to load section '$section' from ini_file '$ini_file'" >/dev/stderr
    return 1
  fi

  echo "$json" | jq -r 'to_entries | .[] | [.key, .value] | @tsv'
}
export -f load_ini_section
