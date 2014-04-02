#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR=`pwd`

pushd $SCRIPT_DIR > /dev/null
bundle exec rspec -I $SCRIPT_DIR -I $DIR/spec --default-path $DIR
popd > /dev/null
