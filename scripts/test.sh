#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DIR=`pwd`

trap 'docker kill `cat host.id 2>/dev/null` &>/dev/null' EXIT INT TERM HUP
../../scripts/run.sh RUN_DEBUG=1 &

until [[ -s host.id ]]; do sleep 0.1; done

containerID=`cat host.id`
portOut=`docker port $containerID 13337`
hostAndPort=(${portOut//:/ })
while :; do
  ../../scripts/telnet.sh ${hostAndPort[0]} ${hostAndPort[1]} bogus &>/dev/null
  [[ $? -ne 0 ]] || break
  sleep 0.25
done

pushd $SCRIPT_DIR > /dev/null
bundle exec rspec -I $SCRIPT_DIR -I $DIR/spec --default-path $DIR
popd > /dev/null
