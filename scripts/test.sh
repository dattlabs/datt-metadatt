#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR=`pwd`

pushd $SCRIPT_DIR > /dev/null
bundle exec rspec --default-path $DIR
popd > /dev/null
