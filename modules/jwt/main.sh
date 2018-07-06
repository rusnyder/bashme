#! /usr/bin/env bash

load_module workspace

# Create an alias for JWT token generation
alias jwtgen="npm run --silent --prefix=\"$REDOWL_WORKSPACE/the-ui/server\" jwtgen -- --cwd=\$(pwd)"
function __jwtheader()
{
  local jwtenv="${1:-master}"
  local entitlement="${2}"
  local cmd="jwtgen generate --algorithm ES512 --pemfile $HOME/workspace/certs/jwt/${jwtenv}/priv.pem --email redowl@redowl.com"
  if [[ -n "$entitlement" ]]; then
    cmd="${cmd} --entitlement ${entitlement}"
  fi
  echo -n "Authorization: Bearer $(eval "$cmd")"
}
alias jwtheader="__jwtheader"
