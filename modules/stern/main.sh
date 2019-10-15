#! /usr/bin/env bash

load_module bash
load_module homebrew

if hash stern &>/dev/null; then
  # shellcheck disable=SC1090
  source <(stern --completion=bash)
fi

