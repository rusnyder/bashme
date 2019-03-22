#! /usr/bin/env bash

# Load jenv, if installed
if hash jenv >/dev/null; then
  eval "$(jenv init -)"
fi

# Locate java home
if [ -f "/usr/libexec/java_home" ]; then
  JAVA_HOME="$(/usr/libexec/java_home)"
elif hash update-alternatives; then
  JAVA_HOME="$(update-alternatives --query java \
    | grep -E '^Best:' \
    | sed -e 's/^Best: \(.*\)\/bin\/java/\1/' \
  )"
else
  echo 'Unable to load JAVA_HOME' >/dev/stderr
fi

# Export JAVA_HOME if it was set
if [[ -n "$JAVA_HOME" ]]; then
  export JAVA_HOME
fi
