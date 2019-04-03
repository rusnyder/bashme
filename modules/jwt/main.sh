#! /usr/bin/env bash

load_module ini
load_module workspace

#########################################################
#                       Constants                       #
#########################################################
_JWT_AUTH_ENDPOINT="api/auth_jwt"
_TOKEN_AUTH_ENDPOINT="api/auth_token"


#########################################################
#                   Private functions                   #
#########################################################

function _fetch_auth_token()
{
  local url="${1}"
  local endpoint="${2}"
  local username="${3}"
  local password="${4}"
  local creds="{\"username\": \"${username}\", \"password\": \"${password}\"}"
  local opts="--silent --insecure --fail --show-error"

  # Authenticate w/ username and password, then save the JWT token
  local resp
  # shellcheck disable=SC2086
  resp="$(curl $opts -XPOST "${url}/${endpoint}/" \
      --header "Content-Type: application/json" \
      --data "${creds}")"
  if ! echo "$resp" | jq --exit-status '.token != null' &> /dev/null; then
    echo "ERROR: Failed to create new Auth token" >/dev/stderr
    echo "  Params:                             " >/dev/stderr
    echo "    url:      $url                    " >/dev/stderr
    echo "    username: $username               " >/dev/stderr
    echo "    password: ********                " >/dev/stderr
    echo "  Response:                           " >/dev/stderr
    echo "    $resp                             " >/dev/stderr
    return
  fi

  # Return the raw JWT token from the response payload
  echo -n "$resp" | jq --raw-output '.token'
}
export -f _fetch_auth_token

function _join_by()
{
  local IFS="$1"; shift; echo "$*";
}
export -f _join_by

function _fetch_auth_token_for_profile()
{
  local endpoint="${1}"
  local profile="${2}"
  if [[ -z "${profile}" ]]; then
    echo "ERROR: No profile specified     " >/dev/stderr
    echo "                                " >/dev/stderr
    echo "  usage: _fetch_auth_token_for_profile <profile>  " >/dev/stderr
    return
  fi

  # Preserve current environment to reset to later
  local prev_username="$username"
  local prev_password="$password"
  local prev_url="$url"

  # load the default profile first, then the specified profile
  load_ini "${ARCEO_CREDENTIALS:-$HOME/.arceo/credentials}"
  if type cfg.section.default &>/dev/null; then
    cfg.section.default
  fi
  if ! type "cfg.section.$profile" &>/dev/null; then
    echo "Arceo profile '${profile}' not defined" >/dev/stderr
    return
  fi
  "cfg.section.$profile"

  # Verify that all necessary properties were loaded
  local missing
  if [[ -z "$url" ]]; then missing="${missing} url"; fi
  if [[ -z "$username" ]]; then missing="${missing} username"; fi
  if [[ -z "$password" ]]; then missing="${missing} password"; fi
  if [[ -n $missing ]]; then
    echo "Required fields undefined for profile '${profile}': [$(_join_by ',' "$missing")]" >/dev/stderr
    return
  fi

  # fetch the token
  jwt=$(_fetch_auth_token "$url" "$endpoint" "$username" "$password")

  # Reset the config vars and ini "cfg" functions
  url="${prev_url}"
  username="${prev_username}"
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
export -f _fetch_auth_token_for_profile


#########################################################
#                   Public functions                    #
#########################################################

# Returns a raw JWT token
function jwt()
{
  local profile="${1:-default}"
  _fetch_auth_token_for_profile "$_JWT_AUTH_ENDPOINT" "$profile"
}
export -f jwt

# Returns a formatted HTTP header for JWT-based auth (i.e. - Bearer auth)
function jwt_header()
{
  local profile="$1"
  local jwt
  jwt="$(jwt "${profile}")"
  if [[ -z "$jwt" ]]; then return; fi

  echo "Authorization: Bearer $jwt"
}
export -f jwt_header

function auth_token()
{
  local profile="${1:-default}"
  _fetch_auth_token_for_profile "$_TOKEN_AUTH_ENDPOINT" "$profile"
}
export -f auth_token

function auth_token_header()
{
  local profile="$1"
  local token
  token="$(auth_token "${profile}")"
  if [[ -z "$token" ]]; then return; fi

  echo "Authorization: Token $token"
}
export -f auth_token_header
