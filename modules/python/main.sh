#! /usr/bin/env bash

load_module postgres

# Ensure certain gcc flags are set to build appropriately
CPATH="$(xcrun --show-sdk-path)/usr/include/"
export CPATH
for lib in openssl zlib sqlite bzip2 xz libffi ncurses tcl-tk icu4c; do
  if [ -e "${BREW_PREFIX}/opt/${lib}" ]; then
    export CFLAGS="$CFLAGS -I${BREW_PREFIX}/opt/${lib}/include"
    export LDFLAGS="$LDFLAGS -L${BREW_PREFIX}/opt/${lib}/lib"
  fi
done
export CPPFLAGS="$CFLAGS"
DYLD_FALLBACK_LIBRARY_PATH="$(pg_config --libdir)/:$DYLD_FALLBACK_LIBRARY_PATH"
export DYLD_FALLBACK_LIBRARY_PATH

# Ensure OpenBLAS install is identified for Numpy (if installed)
if [ -d "${BREW_PREFIX}/opt/openblas" ]; then
  export OPENBLAS="${BREW_PREFIX}/opt/openblas"
fi

# NOTE: This relies entirely on pyenv for python version management.
#       If pyenv has not been installed, this will fail fast
if ! hash pyenv &> /dev/null; then
  echo "[ERROR]: pyenv is not installed, so python version will not be configured"
  return
fi

# Ensure pyenv is installed
if ! hash pyenv &>/dev/null; then
  log_error "Unable to locate pyenv install"
fi

# Use different pyenv and poetry roots for M1 ARM to maintain separate python installs
ARCH="$(uname -m)"
case "$ARCH" in
  arm64)
    export PYENV_ROOT="$HOME/.pyenv-$ARCH"
    export POETRY_CACHE_DIR="$HOME/Library/Caches/pypoetry-$ARCH"
    ;;
  x86_64)
    # Allow default poetry path
    export PYENV_ROOT="$HOME/.pyenv"
    ;;
  *)
    log_error "Unsupported arch '$ARCH'; skipping pyenv/poetry setup"
    ;;
esac
export PATH="$PYENV_ROOT/bin:$PATH"

# Init the pyenv-virtualenv manager
export WORKON_HOME="$HOME/.ve"
export PROJECT_HOME="$HOME/workspace/code"
for dir in "${WORKON_HOME}" "${PROJECT_HOME}"; do
  if [[ ! -e "${dir}" ]]; then
    mkdir -p "${dir}"
  fi
done
eval "$(pyenv init -)"

# Pyenv alias, for installing new python versions
alias pyinstall='CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv install -v'

# Setup some poetry aliases
function _poetry_env() {
  # if POETRY_DONT_LOAD_ENV is *not* set, then load .env if it exists
  if [[ -z "$POETRY_DONT_LOAD_ENV" && -f .env ]]; then
    echo 'Loading .env environment variables…'
    # shellcheck disable=SC2046
    export $(grep -v '^#' .env | tr -d ' ' | xargs)
    command poetry "$@"
    # shellcheck disable=SC2046
    unset $(grep -v '^#' .env | sed -E 's/(.*)=.*/\1/' | xargs)
  else
    command poetry "$@"
  fi
}
alias pshell='_poetry_env run'
alias pshell='_poetry_env shell'

# Skip virtualenv-init command, as it causes conflicts w/ init command
if pyenv commands | grep virtualenv-init > /dev/null; then
  eval "$(pyenv virtualenv-init -)"
fi

# Activate the default python interpreter
#export PYENV_VIRTUALENV_DISABLE_PROMPT=1
#if ! pyenv activate --quiet "${DEFAULT_PYENV_VIRTUALENV:-python2}"; then
#  echo "[ERROR] pyenv-virtualenv may not installed" >/dev/stderr
#fi

# Apache Airflow has a GPL-licensed dependency that we need to skip
export SLUGIFY_USES_TEXT_UNIDECODE=yes

# Disable virtualenv from modify the shell prompt (see ps1 module for handling of PS1)
export VIRTUAL_ENV_DISABLE_PROMPT=1
