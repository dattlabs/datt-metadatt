#!/usr/bin/env bats

@test "Bash: No syntax errors in metabuild" {
  run bash -n metabuild.sh
  echo "output: "$output
  echo "status: "$status
  [ "$status" -eq 0 ]
# bash -n returns nothing if the syntax is correct
  [ "$output" = "" ]
}

@test "Bash: No syntax errors in metagit" {
  run bash -n metagit.sh
  echo "output: "$output
  echo "status: "$status
  [ "$status" -eq 0 ]
# bash -n returns nothing if the syntax is correct
  [ "$output" = "" ]
}

@test "Bash: No syntax errors in build.template" {
  run bash -n build.template
  echo "output: "$output
  echo "status: "$status
  [ "$status" -eq 0 ]
# bash -n returns nothing if the syntax is correct
  [ "$output" = "" ]
}
