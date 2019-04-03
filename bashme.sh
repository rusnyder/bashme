#! /usr/bin/env bash

# Set to false to disable altogether
BASHME_ENABLE=${BASEHME_ENABLE:-true}

# Variables
BASHME_HOME="${BASHME_HOME:-$HOME/.bashme}"
BASHME_MODULES="${BASHME_MODULES:-$BASHME_HOME/modules}"
BASHME_BIN="${BASHME_BIN:-$BASHME_HOME/bin}"
BASHME_DEBUG=${BASHME_DEBUG:-false}

# Abort if bashme is disabled
if [[ "$BASHME_ENABLE" != true ]]; then
  return
fi

# Initialize the path within reason
export PATH="${BASHME_BIN}:/usr/local/bin:/usr/local/sbin:$PATH"

# Load all library files
LIB="${BASHME_HOME}/lib/*.sh"
for lib in $LIB; do
  if [[ "$BASHME_DEBUG" == true ]]; then
    echo "[BASHME] Loading lib: $lib" >/dev/stderr
  fi
  # shellcheck disable=SC1090
  . "$lib"
done

# Load all modules
_load_all_modules
