#! /usr/bin/env bash

# Put Helm 2 on path (can be removed once we upgarde to helm 3)
#export PATH="${BREW_PREFIX}/opt/helm@2/bin:$PATH"

# Load bash completion
# shellcheck disable=SC1090
if hash helm &>/dev/null; then
  source <(helm completion bash)
fi
