#!/usr/bin/env python

from sys import argv, exit
from optparse import OptionParser
from shutil import copyfile
import itertools
import subprocess
import glob
import os

isContainerPath = lambda p: os.path.isfile("%s/Dockerfile" % p)

def single(lst):
  if not len(lst) == 1:
    raise RuntimeError("'single' expects a list containing one item but got %s items" % len(lst))
  return lst[0]

trimstart = lambda s, subs: s[len(subs):] if s.startswith(subs) else s
trimend   = lambda s, subs: s[:-len(subs)] if s.endswith(subs) else s
trim      = lambda s, subs: trimstart(trimend(s, subs), subs)

def getParentImageName(targetPath):
  if not isContainerPath(targetPath): return None
  try:
    dockerfileName = '%s/Dockerfile' % targetPath
    with open(dockerfileName) as f:
      fromLine = single(filter(lambda s: s.startswith('FROM'), [s.strip() for s in f.readlines()]))
      return trim(trim(fromLine, ":latest"), "FROM").strip()
  except Exception as e:
    print("Malformed file: %s\n\t%s" % (dockerfileName, e.message)); exit(1)

isDattImage           = lambda img: img.startswith("datt/datt-")
containerPathToTarget = lambda cp:  trimstart(cp, "./containers/datt-")
imageNameToTarget     = lambda img: trimstart(img, "datt/datt-")

fst = lambda x: x[0]
snd = lambda x: x[1]

def getMakefileEntry(target, labelLine, cmd):
  return (target, "%s\n\t%s\n" % (labelLine, cmd))

def getDefaultMakefileEntry(target, labelLine, containerPath):
  return getMakefileEntry(target, labelLine, "pushd %s > /dev/null;make build;popd > /dev/null" % containerPath)

def getContainerMakefileEntry(containerPath, parentImageName):
  parent = imageNameToTarget(parentImageName)
  target = containerPathToTarget(containerPath)
  labelLine = "%s:%s" % (target, " %s" % parent if isDattImage(parentImageName) else "")
  return getDefaultMakefileEntry(target, labelLine, containerPath)

if __name__ == "__main__":
  parser = OptionParser(usage="usage: %prog [options] [build_target]")
  parser.add_option("--skip-pull",
                    action="store_true", default = False,
                    help="skip pulling from remote git container repos")

  (options, args) = parser.parse_args()
  target = args[0] if len(args) >= 1 else None
  if len(args) > 1: parser.print_help(); exit(1)

  metaDattRoot = os.path.dirname(os.path.realpath(__file__))
  containersRoot = "%s/containers" % metaDattRoot

  getContainerPaths = lambda: glob.glob("%s/datt-*" % containersRoot)
  containerPaths = getContainerPaths()

  if len(containerPaths) == 0:
    print('Found no containers in ./containers. Calling ./init.sh.')
    subprocess.call(['./init.sh'], stderr=open(os.devnull, 'w'), stdout=open(os.devnull, 'w'))
    containerPaths = getContainerPaths()

  for path in containerPaths:
    if not os.path.exists("%s/.git" % path) or not isContainerPath(path):
      print 'Initializing sub-module: %s' % os.path.relpath(path)
      subprocess.call(['./init.sh', path], stderr=open(os.devnull, 'w'), stdout=open(os.devnull, 'w'))

  if not options.skip_pull:
    subprocess.call(['./pull.sh'])

  dependencies = map(lambda p: ("./containers%s" % trimstart(p, containersRoot), getParentImageName(p)), containerPaths)

  getTargets = lambda t: [getContainerMakefileEntry(fst(t), snd(t))]
  targets = list(itertools.chain(*map(getTargets, dependencies)))

  allTargets = ' '.join(map(fst, targets))

  shellLine = 'SHELL := /bin/bash'
  phonyLine = "\n.PHONY: all test %s\n" % allTargets
  allLine   = "all: test %s\n" % allTargets
  testLines = "test:\n\tbats ./tests/*\n"
  targetEntries = map(snd, targets)

  allSections = [shellLine, phonyLine, allLine, testLines] + targetEntries

  print('Writing ./Makefile')
  with open('Makefile', 'w') as f:
    f.write("%s\n" % '\n'.join(allSections))

  buildLine = "build:\n\t../../scripts/build.sh"
  testLine  = "test:\n\t../../scripts/test.sh"
  runLine   = "run:\n\t../../scripts/run.sh"
  debugLine = "debug:\n\t../../scripts/run.sh RUN_DEBUG=1"
  sections = [shellLine, "\n.PHONY: build run test\n", buildLine, testLine, runLine, debugLine]
  for path in containerPaths:
    print('Writing %s/Makefile' % os.path.relpath(path))
    with open('%s/Makefile' % path, 'w') as f:
      f.write("%s\n" % '\n'.join(sections))
    filesPath = '%s/files' % path
    print('Copying test_server.js to %s' % os.path.relpath(filesPath))
    if not os.path.exists(filesPath): os.makedirs(filesPath)
    copyfile('./test_server/test_server.js', '%s/test_server.js' % filesPath)

  if target:
    splitted = target.split(":")
    if len(splitted) > 2: raise RuntimeError("only one level of nesting is currently supported for target tasks.")
    (task, args) = (splitted[1], {'cwd': "./containers/datt-%s" % splitted[0]}) if len(splitted) is 2 else (splitted[0], {})
    subprocess.call(['make', task], **args)
