#! /usr/bin/env bash

# Wrapper to make AWS login slightly less verbose
export ONELOGIN_USER="russell@redowl.com"
export AWS_SESSION_DURATION=21600
function aws-start-session()
{
  local env="${1:-default}"
  pyenv activate python3
  if ! onelogin-aws-login --profile "$env" --username "$ONELOGIN_USER" --duration-seconds $AWS_SESSION_DURATION; then
    : # just ignoring errors
  fi
  pyenv activate python2
}

function aws-lookup-stack()
{
  local stack="$1"
  local canary="ui-$stack"
  for profile in dev qa; do
    # Check if the instance exists in this profile
    if [[ -z "$(aws-lookup-ip -s -p "$profile" "$canary" 2>/dev/null)" ]]; then
      continue
    fi
    # If the instance is here, print the IPs of all instances in the stack
    aws-lookup-ip -p "$profile" "*-${stack}" \
      | jq --raw-output '.instances[] | [.Name, .PrivateIpAddress] | @tsv' \
      | sort
    # Quit out of the loop once we printed a bunch
    break
  done
}

function resolve()
{
  local instance_name="$1"
  # test_host() -> test_host(w/ .ro.internal) -> lookup_ipp(qa) -> lookup_ip(dev)
  if $(host "$instance_name" &>/dev/null); then
    local resolved="$instance_name"
  elif $(host "${instance_name}.ro.internal" &>/dev/null); then
    local resolved="${instance_name}.ro.internal"
  elif resp=$(aws-lookup-ip -s -p qa "$instance_name" 2>/dev/null); then
    local resolved="$(echo "$resp" | jq --raw-output '.PrivateIpAddress')"
  elif resp=$(aws-lookup-ip -s -p dev "$instance_name" 2>/dev/null); then
    local resolved="$(echo "$resp" | jq --raw-output '.PrivateIpAddress')"
  fi
  if [[ -z "$resolved" ]]; then
    echo "Failed to resolve instance: $instance_name"
    return 1
  fi
  echo -n "$resolved"
}
