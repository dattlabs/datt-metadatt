#!/bin/bash
git pull && git submodule init && git submodule update && git submodule status

set_upstream() {
  pushd $2
  git pull origin master
  git checkout master
  popd
}

export -f set_upstream

if [ -z "$1" ]
then
  dirs=`find ./containers/* -maxdepth 0 -type d`
else
  dirs=$1
fi

echo "$dirs" | xargs -P 100 -n 1 bash -c 'set_upstream "$@"' _ {}
