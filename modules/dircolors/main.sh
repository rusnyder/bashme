#! /usr/bin/env bash

require_coreutil dircolors

# Available themes are listed in the submoduled repo:
#   https://github.com/seebi/dircolors-solarized.git
BASHME_DIRCOLORS_THEME='256dark'

# Load the dircolors submodule
load_git_submodule dircolors-solarized

# Load the dircolors - intentionally unquoted for proper eval
# shellcheck disable=SC2046
#eval $(dircolors "${MODULE_DIR}/dircolors-solarized/dircolors.${BASHME_DIRCOLORS_THEME}")
