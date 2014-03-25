#!/bin/bash
git pull && git submodule init && git submodule update && git submodule status

for dir in `find ./containers/* -maxdepth 1 -type d`
do
  pushd $dir
  git pull origin master
  git checkout master
  popd
done
