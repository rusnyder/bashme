#!/usr/bin/env bash

# Ensure homebrew-installed vim is available
if hash "${BREW_PREFIX}/bin/vim" &>/dev/null; then
  # Alias 'vi' to 'vim' to use homebrew-installed vim always
  alias vi='vim'
else
  log_warn "Missing homebrew installation: vim; defaulting to system vi"
fi
