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
  python - <<-EOF
	import configparser, json, sys
	config = configparser.ConfigParser(default_section='default')
	config.read('$HOME/.microsoft/credentials')
	as_dict = dict([(section, dict(config[section])) for section in config.sections() + [config.default_section]])
	sys.stdout.write(json.dumps(as_dict))
	EOF
}
export -f ini_to_json
