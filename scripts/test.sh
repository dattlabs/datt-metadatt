#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DIR=`pwd`

trap 'docker kill `cat host.id` &>/dev/null' EXIT INT TERM HUP
make debug &>/dev/null &

until [[ -s host.id ]]; do :; done

pushd $SCRIPT_DIR > /dev/null
bundle exec rspec -I $SCRIPT_DIR -I $DIR/spec --default-path $DIR
popd > /dev/null
