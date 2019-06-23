#! /usr/bin/env bash

# Ensure the Homebrew access token has been installed
if [[ -z "$HOMEBREW_GITHUB_API_TOKEN" ]]; then
  log_warn "No value has been set for HOMEBREW_GITHUB_API_TOKEN. For more info, see:\n" \
           "  * https://docs.brew.sh/Manpage#environment\n"                             \
           "  * https://github.com/settings/tokens\n"
fi
