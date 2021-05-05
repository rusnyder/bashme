#! /usr/bin/env bash
# shellcheck disable=SC2068

# Experimental: Strip /usr/local/bin out of the PATH on M1
function unload_path()
{
  local path="$PATH"
  IFS=':'; for part in $@; do
    path="$(/bin/echo -n "$path" | tr ':' '\n' | /usr/bin/grep -xv "$part" | /usr/bin/paste -s -d: -)"
  done
  echo -n "$path"
}

if [[ "$(uname -m)" == 'arm64' ]]; then
  log_info "ARM64: Unloading /usr/local/bin from PATH"
  PATH="$(unload_path '/usr/local/bin')"
  export PATH
fi

# Ensure the Homebrew access token has been installed
if [[ -z "$HOMEBREW_GITHUB_API_TOKEN" ]]; then
  log_warn "No value has been set for HOMEBREW_GITHUB_API_TOKEN. For more info, see:\n" \
           "  * https://docs.brew.sh/Manpage#environment\n"                             \
           "  * https://github.com/settings/tokens\n"
fi
