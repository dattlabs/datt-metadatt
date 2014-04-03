#!/bin/bash

DIR=`pwd`
CURRENT_DIR="${DIR##*/}"

# The docker index server can be set to a local index, or by default it will
# use the current directory name before the `-` separator.
#    for example: datt-nginx will use the `datt` index account.

INDEX_NAME=$(echo $CURRENT_DIR | cut -d- -f 1)
DOCKERINDEX=${DOCKERINDEX_LOCAL:-"$INDEX_NAME/"}

DENV=`test $# -gt 0 && echo "--env=$*" || echo ''`
docker run -P -i -t --rm -w "/files" $DENV --hostname $CURRENT_DIR $DOCKERINDEX$CURRENT_DIR bash -c "supervisord; /bin/bash"
