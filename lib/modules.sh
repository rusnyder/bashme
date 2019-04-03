#! /usr/bin/env bash

# Helper for coreutils functions (better OSX interop)
declare -a __ALIASED_COREUTILS
function require_coreutil()
{
  local cmd="$1"
  if hash "g${cmd}" &>/dev/null; then
    # shellcheck disable=SC2139
    alias "${cmd}=g${cmd}"
    __ALIASED_COREUTILS+=("$cmd")
  fi
} # require_coreutils

# Single-time import dependency resolution
declare -A __LOADED_MODULES
function is_module_loaded()
{
  local module="$1"
  [[ ${__LOADED_MODULES["$module"]} == true ]]
} # is_module_loaded

function load_module()
{
  local module="$1"
  # Load the module script only if not yet loaded
  local script="$BASHME_MODULES/${module}/main.sh"
  local secrets="$BASHME_MODULES/${module}/secrets"
  if ! [[ -f "$script" ]]; then
    log_error "Module '$module' did not contain main.sh! Skipping..."
    return
  fi
  if ! is_module_loaded "$module"; then
    # Time module loads for only for debug
    if [[ "$BASHME_DEBUG" != true ]]; then
      # shellcheck source=/dev/null
      . "$script"
      if [[ -f "$secrets" ]]; then
        # shellcheck source=/dev/null
        . "$secrets"
      fi
    else
      # Create a pipe for saving tier output without interfering
      # with output streams of module (can impact PS1, etc.)
      local fd="/tmp/fd-$module"
      # shellcheck disable=SC2064
      trap "rm -f $fd" EXIT SIGINT

      # Time script execution, recording results to pipe
      # shellcheck source=/dev/null
      { time . "$script" && if [[ -f "$secrets" ]]; then . "$secrets"; fi; } &>"$fd"
      duration="$(grep real "$fd" | cut -f2 | tr -d '\n')"
      rm -f "$fd"
      # Log the module load
      echo -e "$(colorize light_gray 'Loaded module')"\
              "$(colorize white "$module")\t"\
              "$(colorize cyan "[$duration]")"
    fi

    __LOADED_MODULES["$module"]=true
  fi
} # load_module

# Loads a script onto the active PATH via symlink
function load_bin()
{
  local module="$1"
  local path="${BASHME_MODULES}/${module}/$2"
  if ! [[ -f "$path" ]]; then
    log_error "Unable to locate script: $path"
    return
  fi
  local name link target
  name="${3:-$(basename "$path")}"
  link="${BASHME_BIN}/${name}"
  target="$(realpath --relative-to="${BASHME_BIN}" "$path")"
  if [[ -e "$link" ]]; then
    if ! [[ -L "$link" ]]; then
      log_error "Conflicting non-link file exists in BASHME_BIN ($link); skipping link creation for module: $module"
      return
    elif [[ "$(readlink "$link")" != "$target" ]]; then
      log_error "Conflicting link already exists, but for different target:"\
        "link[$link],"\
        "expected_target[$target]"\
        "actual_target[$(readlink "$link")]"
      return
    fi
  else
    pushd "${BASHME_BIN}" >/dev/null || return 1
    if ! ln -s "$target" "$link"; then
      log_error "Failed to create link: $link"
      return
    fi
    popd >/dev/null || return 1
  fi
} # load_bin

# Load all modules
function _load_all_modules()
{
  while IFS= read -r -d '' file
  do
    module="$(basename "$file")"
    # Set some common variables accessible in module scripts
    export MODULE_DIR="$BASHME_MODULES/${module}"

    # Load the module
    load_module "$module"

    # Unset the variables loaded for the modules
    unset MODULE_DIR
  done < <(find "$BASHME_MODULES" -mindepth 1 -maxdepth 1 -type d -print0)
} # _load_all_modules
