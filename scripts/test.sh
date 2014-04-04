#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DIR=`pwd`

node $SCRIPT_DIR/wait.js &
wait_pid=$!
echo $wait_pid

trap 'docker kill `cat host.id` &>/dev/null' EXIT INT TERM HUP
make debug &>/dev/null &

until [[ -s host.id ]]; do :; done
wait $wait_pid

pushd $SCRIPT_DIR > /dev/null
bundle exec rspec -I $SCRIPT_DIR -I $DIR/spec --default-path $DIR
popd > /dev/null
