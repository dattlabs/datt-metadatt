#!/bin/bash

generate_buildfile() {
  sed "s/METADATT_PROJNAME/$PROJNAME/g" "$DIR/build.template" > "$DIR/../$daproject/build"
  # make the build script executable...
  chmod +x "$DIR/../$daproject/build"
  echo "[OK] $daproject/build created"
}
