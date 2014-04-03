#!/bin/bash

source ./scripts/helpers.bash

pull() {
  echo Pulling from git repository: $2
  run_in_dir $2 "git pull &>/dev/null"
}

export -f pull
map_over_container_dirs pull
