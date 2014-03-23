#!/bin/bash

unset DIR CURRENT_DIR

# Get the correct directory info to use in a bash script and store in variables. I'm using the most-updated way to achieve this.
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_DIR="${DIR##*/}"

for daproject in $(ls $DIR/..); do
  if [[ "$daproject" != $CURRENT_DIR ]]; then
    echo "[GIT] $daproject check"
    pushd $DIR/../$daproject
    if [ $(git status | grep 'build' | wc -m) -ne 0 ]; then
      git add build; git commit -m 'meta-updated build. '; git push
    fi

# If the run.sh or run-debug.sh commands have been modified, then commit and push those changes
    if [ $(git status | grep -E '(run.sh|run-debug.sh)' | wc -m) -ne 0 ]; then
      git add run.sh run-debug.sh; git commit -m 'meta-updated run and run-debug commands. '; git push
    fi
    popd
  fi
done
