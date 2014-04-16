#!/usr/bin/env python -B

from optparse import OptionParser
from set_ports import rpc_port
import os

def set_tag(container, key, value):
  print "Setting tag '%s' on container '%s' to '%s'" % (key, container, value)
  print os.popen('serf tags -set "%s"="%s" -rpc-addr=%s' % (key, value, '0.0.0.0:%s' % rpc_port(container)))

def check_container_count(container):
  output = os.popen('docker ps | grep %s' % container).read().strip()
  count = len(output.splitlines()) 
  if count != 1: raise RuntimeError('Must be exactly one container of this type running but found %s' % count)

if __name__ == "__main__":
  parser = OptionParser(usage="usage: %prog container tag_key tag_value")
  (options, args) = parser.parse_args()

  if len(args) != 3: parser.print_help(); exit(1)

  (container, tag, value) = (args[0], args[1], args[2])
  check_container_count(container)

  set_tag(container, tag, value)
