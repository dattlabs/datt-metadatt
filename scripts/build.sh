#!/bin/bash

set -e

DIR=`pwd`
CURRENT_DIR="${DIR##*/}"

# The docker index server can be set to a local index, or by default it will
# use the current directory name before the `-` separator.
#    for example: datt-nginx will use the `datt` index account.

INDEX_NAME=$(echo $CURRENT_DIR | cut -d- -f 1)
DOCKERINDEX=${DOCKERINDEX_LOCAL:-"$INDEX_NAME/"}

docker build --rm -t=$DOCKERINDEX$CURRENT_DIR:latest $DIR/.
