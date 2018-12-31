#! /usr/bin/env bash

# ES development aliases
function __escurl()
{
  local host="$1"
  shift 1
  # shellcheck disable=SC2068
  curl --insecure --user elastic:changeme "https://$host" $@
}
alias escurl='__escurl'
