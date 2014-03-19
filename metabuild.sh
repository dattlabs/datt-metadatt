#!/bin/bash

# Make the script exit on any errors returned by individual commands.
#set -e

# Reset the environmental vars if they're already set.
unset DIR CURRENT_DIR

# Get the correct directory info to use in a bash script and store in variables. I'm using the most-updated way to achieve this.
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_DIR="${DIR##*/}"
echo "DIR: "$DIR

get_projname () {
  PROJNAME="datt"
    #TODO read env variable. or allow for user flag.  
    # # Get the user input.
    # printf "Enter the project name: " ; read -r title

    # # Remove the spaces from the title if necessary.
    # title=${title// /_}

    # # Convert uppercase to lowercase.
    # title=${title,,}
}

# For dev purposes, a nice helper function to clean out old test files.

clean_old () {
  for files in "build_test.sh" "build.sh"; do
    rm -v "$DIR/../$daproject/$files"
  done
}

generate_buildfile () {
  echo "[BUILDFILE] START"
  sed "s/METADATT_PROJNAME/$PROJNAME/g" "$DIR/build.template" > "$DIR/../$daproject/build"
}

generate_makefile () {
  echo "[MAKEFILE] START"
}

# Determine the project name. This will be the user name for the public docker index, or for a private index it will be the docker index location. For example `localhost:8888/`
get_projname

# Each subproject has utility scripts that can be generated from templates stored in the templates folder in this repo. I'm expecting that all subprojects are in the same directory. Meta-bash :-)

for daproject in $(ls $DIR/..); do
  if [[ "$daproject" != $CURRENT_DIR ]]; then
    #clean_old
    echo "[BUILD] $daproject build script"
    generate_buildfile
  fi
done


