#! /usr/bin/env bash

alias docker-kill="docker stop \$(docker ps -a -q)"
alias docker-clean="docker rm \$(docker ps -a -q)"
alias docker-purge="docker rmi \$(docker images | grep '^<none>' | sed -e 's/ \\{1,\\}/ /g' | cut -d' ' -f 3)"
alias docker-nuke="docker-kill; docker-clean; docker-purge"
function __alias_val()
{
  alias $1 | cut -d'=' -f2- | sed -e "s/^'\(.*\)'$/\1/"
}
function __docker_cmd()
{
  echo "# To stop all running containers"
  __alias_val docker-kill
  echo
  echo "# To delete all containers"
  __alias_val docker-clean
  echo
  echo "# To remove all untagged images"
  __alias_val docker-purge
}
alias docker-cmd="__docker_cmd"
