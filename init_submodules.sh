#!/bin/bash
git pull > /dev/null && \
  git submodule init > /dev/null && \
  git submodule update > /dev/null && \
  git submodule status > /dev/null

set_upstream() {
  echo Syncing and setting upstream for $2
  pushd $2 > /dev/null
  git pull origin master &> /dev/null
  git checkout master &> /dev/null
  popd > /dev/null
}

export -f set_upstream

if [ -z "$1" ]
then
  dirs=`find ./containers/* -maxdepth 0 -type d`
else
  dirs=$1
fi

echo "$dirs" | xargs -P 100 -n 1 bash -c 'set_upstream "$@"' _ {}
