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

# Load homebrew onto path first off (almost all modules depend on it)
for cmd in brew /usr/local/bin/brew /opt/homebrew/bin/brew; do
  if hash $cmd &>/dev/null; then
    BREW="$cmd"
  fi
done
if [ -z "$BREW" ]; then
  echo "Unable to locate Homebrew install; please install Homebrew first."
fi
BREW_PREFIX="$($BREW --prefix)"
export PATH="${BREW_PREFIX}/bin:${BREW_PREFIX}/sbin:$PATH"
unset BREW
export BREW_PREFIX

# Load bashme scripts onto the path
export PATH="${BASHME_BIN}:${PATH}"

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
