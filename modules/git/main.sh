#! /usr/bin/env bash

load_module completion

# Internal functions

function __git_alias()
{
  local bash_alias="$1"
  local git_command="$2"

  # shellcheck disable=SC2139
  alias "${bash_alias}=git ${git_command}"
  __git_complete "${bash_alias}" "_git_$(echo "$git_command" | cut -d' ' -f1)"
}

# Aliases
__git_alias gs status
__git_alias gco checkout
__git_alias gu pull
__git_alias glog glog
__git_alias gfix "diff --name-only | uniq | xargs $EDITOR -"

# Functions
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Shows you the largest objects in your repo's pack file.
# Written for osx.
#
# @see https://stubbisms.wordpress.com/2009/07/10/git-script-to-show-largest-pack-objects-and-trim-your-waist-line/
# @author Antony Stubbs
git_find_lobs() {
  local objects allObjects size compressedSize sha other
  # set the internal field spereator to line break, so that we can iterate easily over the verify-pack output
  #IFS=$'\n';

  # list all objects including their size, sort by size, take top 10
  objects=$(git verify-pack -v .git/objects/pack/pack-*.idx | grep -v chain | sort -k3nr | head)
  echo "All sizes are in kB's. The pack column is the size of the object, compressed, inside the pack file."

  allObjects=$(git rev-list --all --objects)
  echo -e "size,pack,SHA,location\n$(echo "$objects" | while read -r y; do
    # extract the size in bytes
    size=$(( $(echo "$y" | cut -f 4 -d ' ')/1024 ))
    # extract the compressed size in bytes
    compressedSize=$(( $(echo "$y" | cut -f 5 -d ' ')/1024 ))
    # extract the SHA
    sha=$(echo "$y" | cut -f 1 -d ' ')
    # find the objects location in the repository tree
    other=$(echo "${allObjects}" | grep "$sha")
    #lineBreak=$(echo -e "\n")
    echo "${size},${compressedSize},${other}"
  done)" | column -t -s ', '
}
export -f git_find_lobs

# Variables
export PATH="${BREW_PREFIX}/git/bin:$PATH"
