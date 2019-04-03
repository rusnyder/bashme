#! /usr/bin/env bash

function _is_git_submodule_loaded()
{
  local submodule="$1"
  [[ -d "${MODULE_DIR}/${submodule}/.git" ]]
} # is_module_loaded

function load_git_submodule()
{
  local submodule="$1"
  if ! _is_git_submodule_loaded "$submodule"; then
    # Time module loads for only for debug
    if [[ "$BASHME_DEBUG" == true ]]; then
      echo -e "$(colorize light_gray 'Loading git submodule')"\
              "$(colorize white "${MODULE_DIR}/${submodule}")"
    fi
    git -C "${BASHME_HOME}" submodule update --init -- "${MODULE_DIR}/${submodule}"
  fi
} # load_git_submodule
