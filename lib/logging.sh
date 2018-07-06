#! /usr/bin/env bash

function _log()
{
  local color="$1"
  local level="$2"
  shift 2
  echo \
    "$(colorize "white" "(bashme)")" \
    "$(colorize "$color" "[$(echo "$level" | tr '[:lower:]' '[:upper:]')]")" \
    "$@" >/dev/stderr
} # _log

function log_info()
{
  _log green info "$@"
} # log_info

function log_warn()
{
  _log yellow warn "$@"
} # log_warn

function log_error()
{
  _log red error "$@"
} # log_error
