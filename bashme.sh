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

# Load all library files
LIB="${BASHME_HOME}/lib/*.sh"
for lib in $LIB; do
  if [[ "$BASHME_DEBUG" == true ]]; then
    echo "[BASHME] Loading lib: $lib" >/dev/stderr
  fi
  # shellcheck disable=SC1090
  . "$lib"
done

# Load bashme scripts onto the path
export PATH="${BASHME_BIN}:${PATH}"

# Load homebrew onto path first off (almost all modules depend on it)
case "$(uname -m)" in
  # M1 Mac running native (ARM) terminal
  arm64) BREW=/opt/homebrew/bin/brew ;;
  # Intel Mac or M1 Mac running Rosetta terminal
  x86_64) BREW=/usr/local/bin/brew ;;
esac
if ! hash $BREW &>/dev/null; then
  echo "Unable to locate Homebrew install; please install Homebrew first."
fi

BREW_PREFIX="$($BREW --prefix)"
export PATH="${BREW_PREFIX}/bin:${BREW_PREFIX}/sbin:$PATH"
unset BREW
export BREW_PREFIX

# Load all modules
_load_all_modules
