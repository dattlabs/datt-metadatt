#!/bin/bash

pull() {
  echo Pulling from git repository: $2
  pushd $2 &>/dev/null
  git pull &>/dev/null
  popd &>/dev/null
}

export -f pull

find ./containers -name datt-* -type d | xargs -P 100 -n 1 bash -c 'pull "$@"' _ {}
