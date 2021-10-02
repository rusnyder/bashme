#! /usr/bin/env bash

# Read AWS config file (support advanced AWS auth schemes)
export AWS_SDK_LOAD_CONFIG=1

# Enable bash completion
complete -C "${BREW_PREFIX}"/bin/terraform terraform

# Load bin scripts onto path
#export PATH="${MODULE_DIR}/bin:${PATH}"

# Aliases
alias tf="terraform"
