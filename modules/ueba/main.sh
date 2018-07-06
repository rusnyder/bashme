#!/usr/bin/env bash

function load_ini () {
    local fixed_file=$(cat $1 | sed 's/ = /=/g')  # fix ' = ' to be '='
    local IFS=$'\n' && ini=( $fixed_file )        # convert to line-array
    local ini=( ${ini[*]//;*/} )                  # remove comments
    ini=( ${ini[*]/#[/\}$'\n'cfg.section.} )      # set section prefix
    ini=( ${ini[*]/%]/ \(} )                      # convert text2function (1)
    ini=( ${ini[*]/=/=\( } )                      # convert item to array
    ini=( ${ini[*]/%/ \)} )                       # close array parenthesis
    ini=( ${ini[*]/%\( \)/\(\) \{} )              # convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} )                   # remove extra parenthesis
    ini[0]=''                                     # remove first element
    ini[${#ini[*]} + 1]='}'                       # add the last brace
    eval "$(echo "${ini[*]}")"                    # eval the result
}

function fetch_jwt()
{
  local url="${1}"
  local email="${2}"
  local password="${3}"
  local creds="{\"email\": \"${email}\", \"password\": \"${password}\"}"
  local opts="--silent --insecure --fail --show-error"

  # Authenticate w/ username and password, then save the session tokens (cookies)
  local cookies="$(mktemp)"
  trap "rm '$cookies'" SIGINT EXIT
  local resp="$(curl $opts -XPOST "${url}/session/new" \
      --header "Content-Type:application/json" \
      --data "${creds}" \
      --cookie-jar "$cookies")"
  if ! $(echo "$resp" | jq '.' &> /dev/null); then
    echo "ERROR: Failed to create new session token " >/dev/stderr
    echo "  Params:                                 " >/dev/stderr
    echo "    url:      $url                        " >/dev/stderr
    echo "    email:    $email                      " >/dev/stderr
    echo "    password: ********                    " >/dev/stderr
    echo "    password: $password                   " >/dev/stderr
    echo "  Response:                               " >/dev/stderr
    echo "    $resp                                 " >/dev/stderr
    return
  fi

  # Fetch the jwt token using the session tokens to authenticate
  if ! local jwt="$(curl $opts "${url}/api/1/fetch-jwt" --cookie @${cookies})"; then
    echo "Failed to create new jwt token" >/dev/stderr
    return
  fi
  echo "$jwt"
}

function join_by()
{
  local IFS="$1"; shift; echo "$*";
}

function jwt_profile()
{
  local profile="${1}"
  if [[ -z "${profile}" ]]; then
    echo "ERROR: No profile specified     " >/dev/stderr
    echo "                                " >/dev/stderr
    echo "  usage: jwt_profile <profile>  " >/dev/stderr
    return
  fi

  # Preserve current environment to reset to later
  local prev_email="$email"
  local prev_password="$password"
  local prev_url="$url"

  # load the default profile first, then the specified profile
  load_ini "${UEBA_CREDENTIALS:-$HOME/.ueba/credentials}"
  if type cfg.section.default &>/dev/null; then
    cfg.section.default
  fi
  if ! type cfg.section.$profile &>/dev/null; then
    echo "UEBA profile '${profile}' not defined" >/dev/stderr
    return
  fi
  cfg.section.$profile

  # Verify that all necessary properties were loaded
  missing=""
  if [[ -z "$url" ]]; then missing="${missing} url"; fi
  if [[ -z "$email" ]]; then missing="${missing} email"; fi
  if [[ -z "$password" ]]; then missing="${missing} password"; fi
  if [[ -n $missing ]]; then
    echo "Required fields undefined for profile '${profile}': [$(join_by ',' $missing)]" >/dev/stderr
    return
  fi

  # fetch the token
  jwt=$(fetch_jwt "$url" "$email" "$password")

  # Reset the config vars and ini "cfg" functions
  url="${prev_url}"
  email="${prev_email}"
  password="${prev_password}"
  while read fn; do
    unset -f $fn
  done < <(declare -F | cut -d' ' -f3 | grep -E '^cfg')

  # Emit the token
  echo "${jwt}"
}

function jwt_header()
{
  local profile="${1}"
  local jwt="$(jwt_profile "${profile}")"
  if [[ -z "$jwt" ]]; then return; fi

  echo "Authorization: Bearer $(echo "$jwt" | jq --raw-output '.jwt')"
}
