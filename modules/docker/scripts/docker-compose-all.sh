#!/usr/bin/env bash

args="$*"
files="$(find . -type f -name 'docker-compose*.yml' -maxdepth 1 | gsed -e 's:\(^\| \):\1-f :g' | paste -s -d' ' -)"

# shellcheck disable=SC2086
docker compose $files $args
