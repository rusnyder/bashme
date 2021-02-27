#! /usr/bin/env bash

#   Source all installed bash-completion scripts
#   ------------------------------------------------------------

# Enable only specific system-level completions, which cana
# get _very_ expensive when loading all
if [ -d /usr/share/bash-completion ]; then
  # Load whatever modules we want (explicitly - there's a LOT of them)
  MODULES=(
    git
  )
  for mod in "${MODULES[@]}"; do
    # shellcheck source=/dev/null
    source "/usr/share/bash-completion/completions/${mod}"
  done
  unset MODULES
fi

# Load the rest of the bash completions
for completions in \
    /etc/bash_completion \
    ${BREW_PREFIX}/etc/bash_completion \
    ; do
  # shellcheck source=/dev/null
  [ -f $completions ] && . $completions
done
