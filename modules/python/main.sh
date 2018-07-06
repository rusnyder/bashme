#! /usr/bin/env bash

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
pyenv activate "${DEFAULT_PYENV_VIRTUALENV:-python2}"
