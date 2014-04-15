#!/bin/bash

# By default docker builds will use the current directory name before the `-` separator.
# By setting a DOCKERINDEX_LOCAL variable, the builds can be tagged with a specific name.

set -e

DIR=`pwd`
CONTAINER="${DIR##*/}"

INDEX_NAME=$(echo $CONTAINER | cut -d- -f 1)
DOCKERINDEX=${DOCKERINDEX_LOCAL:-"$INDEX_NAME/"}

docker build --rm -t=$DOCKERINDEX$CONTAINER:latest $DIR/.
