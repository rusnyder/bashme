#! /usr/bin/env bash

export KUBECFG_HOME="${HOME}/.kube/config"

function _kubecfg_usage()
{
  echo <<- EOF

	Usage: kubecfg <command> [OPTIONS]

	Commands:
	  list      - List available kubectl configurations
	  get       - Get the active configuration
	  set <cfg> - Set the active configuration
	  help      - Display help and usage information

	EOF
} # _kubecfg_usage

function _kubecfg_profiles()
{
  ls "${HOME}/.kube/config" \
    | grep -E '\.yml$' \
    | sed -e 's/\.yml//'
} # _kubecfg_profiles

function _kubecfg_activate()
{
  local profile="$1"
  if [[ -z "$profile" ]]; then
    echo "ERROR: Profile must be provided to activate"
    return
  fi
  export KUBECFG_ACTIVE_PROFILE="$profile"
  export KUBECONFIG="${KUBECFG_HOME}/${profile}.yml"
} # _kubecfg_activate

function kubecfg()
{
  local cmd="${1:-help}"
  case "$cmd" in
    list)
      for profile in $(_kubecfg_profiles); do
        if [[ "$profile" == "$KUBECFG_ACTIVE_PROFILE" ]]; then
          echo "$profile (active)"
        else
          echo "$profile"
        fi
      done
      ;;
    set) _kubecfg_activate "$2";;
    *) _kubectl_usage;;
  esac
} # kubecfg

# Activate the default profile
kubecfg set default
