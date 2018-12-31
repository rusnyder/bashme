#!/usr/bin/env bash

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

function fetch_jwt()
{
  local url="${1}"
  local email="${2}"
  local password="${3}"
  local creds="{\"email\": \"${email}\", \"password\": \"${password}\"}"
  local opts="--silent --insecure --fail --show-error"

  # Authenticate w/ username and password, then save the session tokens (cookies)
  local cookies resp
  cookies="$(mktemp)"s
  # shellcheck disable=SC2064
  trap "rm '$cookies'" SIGINT EXIT
  # shellcheck disable=SC2086
  resp="$(curl $opts -XPOST "${url}/session/new" \
      --header "Content-Type:application/json" \
      --data "${creds}" \
      --cookie-jar "$cookies")"
  if ! echo "$resp" | jq '.' &> /dev/null; then
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
  local jwt
  # shellcheck disable=SC2086
  if ! jwt="$(curl $opts "${url}/api/1/fetch-jwt" --cookie @${cookies})"; then
    echo "Failed to create new jwt token" >/dev/stderr
    return
  fi
  echo "$jwt"
}
export -f fetch_jwt

function join_by()
{
  local IFS="$1"; shift; echo "$*";
}
export -f join_by

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
  if ! type "cfg.section.$profile" &>/dev/null; then
    echo "UEBA profile '${profile}' not defined" >/dev/stderr
    return
  fi
  "cfg.section.$profile"

  # Verify that all necessary properties were loaded
  local missing
  if [[ -z "$url" ]]; then missing="${missing} url"; fi
  if [[ -z "$email" ]]; then missing="${missing} email"; fi
  if [[ -z "$password" ]]; then missing="${missing} password"; fi
  if [[ -n $missing ]]; then
    echo "Required fields undefined for profile '${profile}': [$(join_by ',' "$missing")]" >/dev/stderr
    return
  fi

  # fetch the token
  jwt=$(fetch_jwt "$url" "$email" "$password")

  # Reset the config vars and ini "cfg" functions
  url="${prev_url}"
  email="${prev_email}"
  password="${prev_password}"
  declare -F            `# list functions`      \
    | cut -d' ' -f3     `# grab function name`  \
    | grep -E '^cfg'    `# select config vars`  \
    | while read -r fn; do `# unset each one`      \
        unset -f "$fn"
      done

  # Emit the token
  echo "${jwt}"
}
export -f jwt_profile

function jwt_header()
{
  local profile="${1}"
  local jwt
  jwt="$(jwt_profile "${profile}")"
  if [[ -z "$jwt" ]]; then return; fi

  echo "Authorization: Bearer $(echo "$jwt" | jq --raw-output '.jwt')"
}
export -f jwt_header

function grant_access()
{
  local user="$1"
  local env="$2"
  # Iterate over all IPs in the cluster
  # shellcheck disable=SC2086,SC2029
  for ip in $(ssh "jenkins-${env}.ro.internal" "cat /etc/hosts | grep '$env' | cut -d' ' -f1 | sort -u"); do
    if host="$(ssh -q -t ${ip} "hostname; sudo usermod -G wheel ${user}")"; then
      echo "[GRANTED]: $host"
    else
      echo "[FAILED]: $host"
    fi
  done
}

function create_user()
{
  local user="$1"
  local env="$2"
  local pubkey="$3"
  # Iterate over all IPs in the cluster
  # shellcheck disable=SC2086,SC2029
  for ip in $(ssh "jenkins-${env}.ro.internal" "cat /etc/hosts | grep '$env' | cut -d' ' -f1 | sort -u"); do
    # shellcheck disable=SC2086,SC2029
    if host="$(ssh -q -t "${ip}" "hostname; sudo useradd '${user}'; sudo su -c \"mkdir -p ~/.ssh && chmod 0700 ~/.ssh && echo '${pubkey}' > ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys\" - ${user}")"; then
      echo "[CREATED]: $host"
    else
      echo "[FAILED]: $host"
    fi
  done
}
