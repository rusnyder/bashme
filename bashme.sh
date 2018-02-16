#! /usr/bin/env bash

# Variables
BASHME_HOME="${BASHME_HOME:-$HOME/.bashme}"
BASHME_MODULES="${BASHME_MODULES:-$BASHME_HOME/modules}"
BASHME_DEBUG=${BASHME_DEBUG:-false}

# Initialize the path within reason
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Load all library files
LIB="${BASHME_HOME}/lib/*.sh"
for lib in $LIB; do
  . "$lib"
done

# Load all modules
_load_all_modules
