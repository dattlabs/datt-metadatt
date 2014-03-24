#!/bin/bash

unset DIR

# Get the correct directory info to use in a bash script and store in variables. I'm using the most-updated way to achieve this.
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $DIR

for daproject in $(ls $DIR/containers/); do
  echo "[GIT] $daproject check"
  pushd $DIR/containers/$daproject 1>/dev/null
  if [ $(git status | grep 'build' | wc -m) -ne 0 ]; then
    git add build; git commit -m 'meta-updated build. '; git push
  fi

  # If the run.sh or run-debug.sh commands have been modified, then commit and push those changes
  if [ $(git status | grep -E '(run.sh|run-debug.sh)' | wc -m) -ne 0 ]; then
    git add run.sh run-debug.sh; git commit -m 'meta-updated run and run-debug commands. '; git push
  fi
  popd 1>/dev/null
done
