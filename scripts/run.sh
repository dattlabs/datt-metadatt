#!/bin/bash

DIR=`pwd`
CONTAINER="${DIR##*/}"

# The docker index server can be set to a local index, or by default it will
# use the current directory name before the `-` separator.
#    for example: datt-nginx will use the `datt` index account.

INDEX_NAME=$(echo $CONTAINER | cut -d- -f 1)
DOCKERINDEX=${DOCKERINDEX_LOCAL:-"$INDEX_NAME/"}

DENV=`test $# -gt 0 && echo "--env=$*" || echo ''`

[[ -e $DIR/host.id ]] && { echo "Container already running."; exit 1; }

trap 'rm -f $DIR/host.id' EXIT INT TERM HUP

VOLUMES=`test -n "$VOLUMES" && echo "-v $VOLUMES" || echo ''`
INPUT_FILE=${INPUT_FILE:-/dev/stdin}
OUTPUT_FILE=${OUTPUT_FILE:-/dev/stdout}
TTY=`test "$INPUT_FILE" = "/dev/stdin" && echo "-t" || echo ''`

# PASS RUN_CMD into the script to override the default CMD found in the Dockerfile.
# RUN_CMD="/files/start.sh"

docker run $TTY -a stdout -a stdin --cidfile=$DIR/host.id $VOLUMES -P -i --rm -w "/files" \
  $DENV --hostname $CONTAINER $DOCKERINDEX$CONTAINER ${RUN_CMD:""} < "$INPUT_FILE" > "$OUTPUT_FILE"
