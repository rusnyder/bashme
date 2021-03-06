#! /usr/bin/env bash

alias docker-kill="docker ps -aq | xargs docker stop"
alias docker-clean="docker ps -aq | xargs docker rm; docker volume prune -f; docker network prune -f"
alias docker-purge="docker images | grep '^<none>' | sed -e 's/ \\{1,\\}/ /g' | cut -d' ' -f 3 | xargs docker rmi"
alias docker-nuke="docker-kill; docker-clean; docker-purge"

function __alias_val()
{
  alias "$1" | cut -d'=' -f2- | sed -e "s/^'\(.*\)'$/\1/"
} # __alias_val

function __docker_cmd()
{
  echo "# To stop all running containers"
  __alias_val docker-kill
  echo
  echo "# To delete all containers, volumes, and networks"
  __alias_val docker-clean
  echo
  echo "# To remove all untagged images"
  __alias_val docker-purge
} # __docker_cmd

alias docker-cmd="__docker_cmd"

## [OPTIONAL] Set the default docker platform to use x86 containers on M1 mac
#if [ "$(uname -m)" = "arm64" ]; then
#export DOCKER_DEFAULT_PLATFORM="linux/amd64"
#fi

# Docker Compose

## dca: Runs `docker-compsoe` using all the docker-compose.yml files in the current directory
load_bin docker scripts/docker-compose-all.sh dca
