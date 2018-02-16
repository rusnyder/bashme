#! /usr/bin/env bash

# Single-time import dependency resolution
declare -A __LOADED_MODULES
function load_module()
{
  # Argument can be module name or script
  local module="$1"
  if [[ "$module" =~ ^$BASHME_MODULES/.*\.sh$ ]]; then
    module="$(basename "$module" | sed -e 's/\.sh$//')"
  fi
  # Load the module script only if not yet loaded
  local script="$BASHME_MODULES/${module}.sh"
  if [[ ${__LOADED_MODULES["$module"]} != true ]]; then
    # Time module loads for only for debug
    if [[ "$BASHME_DEBUG" != true ]]; then
      . "$script"
    else
      # Create a pipe for saving tier output without interfering
      # with output streams of module (can impact PS1, etc.)
      local fd="/tmp/fd-$module"
      trap "rm -f $fd" EXIT SIGINT

      # Time script execution, recording results to pipe
      { time . "$script" ; } 2>&1 &>$fd
      duration=$(cat $fd | grep real | cut -f2 | tr -d '\n')
      rm -f "$fd"
      # Log the module load
      echo -e "$(colorize light_gray 'Loaded module')"\
              "$(colorize white $module)\t"\
              "$(colorize cyan [$duration])"
    fi

    __LOADED_MODULES["$module"]=true
  fi
}

# Load all modules
function _load_all_modules()
{
  for module in $(find "$BASHME_MODULES" -type f -maxdepth 1 -name "*.sh"); do
    load_module $module
  done
}
