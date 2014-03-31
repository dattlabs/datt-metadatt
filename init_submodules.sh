#!/bin/bash
git pull && git submodule init && git submodule update && git submodule status

set_upstream() {
  pushd $2
  git pull origin master
  git checkout master
  popd
}

export -f set_upstream
find ./containers/* -maxdepth 0 -type d | xargs -P 100 -n 1 bash -c 'set_upstream "$@"' _ {}
