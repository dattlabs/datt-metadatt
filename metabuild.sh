#!/bin/bash

# Make the script exit on any errors returned by individual commands.
set -e

# Show commands as they get executed
#set -x

# Reset the environmental vars if they're already set.
unset DIR CURRENT_DIR

# Get the correct directory info to use in a bash script and store in variables. I'm using the most-updated way to achieve this.
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_DIR="${DIR##*/}"

load_generators() {
  for dagenerator in $(ls $DIR/generators); do
    source $DIR/generators/$dagenerator
    echo "[LOADED]: generators/$dagenerator";
  done
}

get_projname() {
  PROJNAME="datt"
    # # Get the user input.
    # printf "Enter the project name: " ; read -r title

    # # Remove the spaces from the title if necessary.
    # title=${title// /_}

    # # Convert uppercase to lowercase.
    # title=${title,,}
}

# For dev purposes, a nice helper function to clean out old test files.

clean_old() {
  for files in "build_test.sh" "build.sh"; do
    rm -v "$DIR/../$daproject/$files"
  done
}

generator_run() {
# Determine the project name. This will be the user name for the public docker index, or for a private index it will be the docker index location. For example `localhost:8888/`
  get_projname

# Each subproject has utility scripts that can be generated from templates stored in the templates folder in this repo. I'm expecting that all subprojects are in the same directory. Meta-bash :-)

  for daproject in $(ls $DIR/..); do
    if [[ "$daproject" != $CURRENT_DIR ]]; then
      #clean_old
      # echo "[BUILD] $daproject build script"
      # $1
      # echo "passed: "$1
      case "$1" in
        "build.template")
          generate_buildfile
          ;;
        "Makefile.template")
          generate_makefile
          ;;
        *)
          echo "err. invalid name."
      esac
    fi
  done
}

usage() {
  echo "Usage: $0 {-b <templatename>}"
  echo ""
  echo "Examples:"
  echo "metabuild.sh -b build.template"
  echo "metabuild.sh -b Makefile.template"
  echo ""

  exit 1
}

# ------------ MAIN STUFF

# load the generators in the `generators` sub-folder
load_generators

# if no arguments are passed, display the help

if [ -z "${1}" ]; then
  usage
  exit 1
fi

# parse command-line options

while getopts ":a:b:h" o; do
  case "${o}" in
    a)
      echo "${o} was triggered, Parameter: ${OPTARG}" >&2
      ;;
    b)
      echo "-b was triggered, Parameter: ${OPTARG}"
      generator_run ${OPTARG}
      ;;
    \?)
      echo "Invalid option: -${OPTARG}"
      exit 1
      ;;
    :)
      echo "Option -${OPTARG} requires an argument."
      exit 1
      ;;
    *)
      usage
      ;;
  esac
done
