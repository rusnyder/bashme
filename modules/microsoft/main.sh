#! /usr/bin/env bash

load_module ini
load_module workspace

#########################################################
#                       Constants                       #
#########################################################
_MICROSOFT_BASE_URL="https://login.microsoftonline.com"
_MICROSOFT_OAUTH2_TOKEN_ENDPOINT="oauth2/v2.0/token"


#########################################################
#                   Private functions                   #
#########################################################

function _fetch_microsoft_oauth2_token()
{
  local client_id="${1}"
  local client_secret="${2}"
  local domain="${3:-common}"
  local url="${_MICROSOFT_BASE_URL}/${domain}/${_MICROSOFT_OAUTH2_TOKEN_ENDPOINT}"
  local opts="--silent --insecure"
  local scope="https://graph.microsoft.com/.default"
  local grant_type="client_credentials"

  # Authenticate w/ username and password, then save the JWT token
  local resp
  # shellcheck disable=SC2086
  resp="$(curl $opts -XPOST "${url}" \
      --header "Content-Type: application/x-www-form-urlencoded" \
      --data-urlencode "scope=${scope}" \
      --data-urlencode "client_id=${client_id}" \
      --data-urlencode "client_secret=${client_secret}" \
      --data-urlencode "grant_type=${grant_type}")"
  if ! echo "$resp" | jq --exit-status '.access_token != null' &> /dev/null; then
    echo "ERROR: Failed to create new Microsoft OAuth2.0 token" >/dev/stderr
    echo "  Params:"                                            >/dev/stderr
    echo "    url:           $url"                              >/dev/stderr
    echo "    scope:         $scope"                            >/dev/stderr
    echo "    client_id:     $client_id"                        >/dev/stderr
    echo "    client_secret: ********"                          >/dev/stderr
    echo "  Response:"                                          >/dev/stderr
    echo "    $resp"                                            >/dev/stderr
    return
  fi

  # Return the raw JWT token from the response payload
  echo -n "$resp" | jq --raw-output '.access_token'
}
export -f _fetch_microsoft_oauth2_token

function _fetch_microsoft_oauth2_token_for_profile()
{
  local profile="${1}"
  local domain="${2}"
  if [[ -z "${profile}" ]]; then
    echo "ERROR: No profile specified                                   " >/dev/stderr
    echo "                                                              " >/dev/stderr
    echo "  usage: _fetch_microsoft_oauth2_token_for_profile <profile>  " >/dev/stderr
    return
  fi

  # load the default profile first, then the specified profile
  if ! config="$(ini_to_json "${MICROSOFT_CREDENTIALS:-$HOME/.microsoft/credentials}" \
      | jq --exit-status ".${profile}")"; then
    echo "Microsoft application profile '${profile}' not defined" >/dev/stderr
    return
  fi

  # Extract values from config
  local client_id client_secret
  client_id="$(echo "$config" | jq --raw-output '.client_id')"
  client_secret="$(echo "$config" | jq --raw-output '.client_secret')"

  # Verify that all necessary properties were loaded
  local missing
  if [[ -z "$client_id" ]]; then missing="${missing} client_id"; fi
  if [[ -z "$client_secret" ]]; then missing="${missing} client_secret"; fi
  if [[ -n $missing ]]; then
    echo "Required fields undefined for profile '${profile}': [$(join_by ',' "$missing")]" >/dev/stderr
    return
  fi

  # fetch the token
  token=$(_fetch_microsoft_oauth2_token "$client_id" "$client_secret" "$domain")

  # Emit the token
  echo "${token}"
}
export -f _fetch_microsoft_oauth2_token_for_profile


#########################################################
#                   Public functions                    #
#########################################################

# Returns a raw JWT token
function microsoft_oauth2_token()
{
  local profile="${1:-default}"
  local domain="${2:-common}"
  _fetch_microsoft_oauth2_token_for_profile "$profile" "$domain"
}
export -f microsoft_oauth2_token

function microsoft_oauth2_token_header()
{
  local profile="$1"
  local domain="${2}"
  local token
  token="$(microsoft_oauth2_token "${profile}" "${domain}")"
  if [[ -z "$token" ]]; then return; fi

  echo "Authorization: Bearer $token"
}
export -f microsoft_oauth2_token_header
