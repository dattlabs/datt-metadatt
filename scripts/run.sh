#!/bin/bash

DIR=`pwd`
CURRENT_DIR="${DIR##*/}"

# The docker index server can be set to a local index, or by default it will
# use the current directory name before the `-` separator.
#    for example: datt-nginx will use the `datt` index account.

INDEX_NAME=$(echo $CURRENT_DIR | cut -d- -f 1)
DOCKERINDEX=${DOCKERINDEX_LOCAL:-"$INDEX_NAME/"}

DENV=`test $# -gt 0 && echo "--env=$*" || echo ''`

trap 'rm -f $DIR/host.id' EXIT INT TERM HUP

VOLUMES=`test -n "$VOLUMES" && echo "-v $VOLUMES" || echo ''`
INPUT_FILE=${INPUT_FILE:-/dev/stdin}
OUTPUT_FILE=${OUTPUT_FILE:-/dev/stdout}
TTY=`test "$INPUT_FILE" = "/dev/stdin" && echo "-t" || echo ''`

RUN_CMD="/files/start.sh"

docker run --expose=13337 $TTY -a stdout -a stdin --cidfile=$DIR/host.id $VOLUMES -P -i --rm -w "/files" \
  $DENV --hostname $CURRENT_DIR $DOCKERINDEX$CURRENT_DIR $RUN_CMD < "$INPUT_FILE" > "$OUTPUT_FILE"
