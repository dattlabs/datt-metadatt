#!/usr/bin/env python -B

from optparse import OptionParser
import inspect
import json
import os

def get_port_mappings(container):
  script_dir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
  container_id = os.popen('cat %s/../containers/%s/host.id' % (script_dir, container)).read().strip()
  info = os.popen('docker inspect %s' % container_id).read().strip()

  parsed = json.loads(info)[0]
  return {k.split('/')[0]:v[0]['HostPort'] for k,v in parsed['NetworkSettings']['Ports'].items()}

def rpc_port(container):
  return get_port_mappings(container)['7373']

if __name__ == '__main__':
  from set_tag import set_tag, check_container_count

  parser = OptionParser(usage="usage: %prog container")
  (options, args) = parser.parse_args()

  if len(args) != 1: parser.print_help(); exit(1)

  container = args[0]
  check_container_count(container)

  set_tag(container, "ports", json.dumps(get_port_mappings(container)))
