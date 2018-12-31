#! /usr/bin/env bash

# Load pyenv, if necessary
if [ -z "$PYENV_ROOT" ]; then
  if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
  else
    echo "[ERROR] No PYENV_ROOT found, and unable to locate pyenv install" >/dev/stderr
    return
  fi
fi
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

# Skip virtualenv-init command, as it causes conflicts w/ init command
#if which pyenv-virtualenv-init > /dev/null; then
#  eval "$(pyenv virtualenv-init -)"
#fi

# Activate the default python interpreter
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
if ! pyenv activate --quiet "${DEFAULT_PYENV_VIRTUALENV:-python2}"; then
  echo "[ERROR] pyenv-virtualenv may not installed" >/dev/stderr
fi
