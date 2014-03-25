#!/usr/bin/env python

from sys import argv, exit
from optparse import OptionParser
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

def getMakefileEntry(target, labelLine, containerPath, metaDattRoot, task):
  return (target, "%s\n\tpushd %s;%s/scripts/%s.sh;popd\n" % (labelLine, containerPath, metaDattRoot, task))

def getRunMakefileEntry(containerPath, metaDattRoot):
  target = containerPathToTarget(containerPath)
  return getMakefileEntry(target, "%s%%run: %s" % (target, target), containerPath, metaDattRoot, "run")

def getDefaultMakefileEntry(containerPath, parentImageName, metaDattRoot):
  parent = imageNameToTarget(parentImageName)
  target = containerPathToTarget(containerPath)
  labelLine = "%s:%s" % (target, " %s" % parent if isDattImage(parentImageName) else "")
  return getMakefileEntry(target, labelLine, containerPath, metaDattRoot, "build")

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

  getContainerPaths = lambda: filter(isContainerPath, glob.glob("%s/datt-*" % containersRoot))
  containerPaths = getContainerPaths()

  if len(containerPaths) == 0:
    print('Found no containers in ./containers. Calling ./init_submodules.sh.')
    subprocess.call(['./init_submodules.sh'], stderr=open(os.devnull, 'w'), stdout=open(os.devnull, 'w'))
    containerPaths = getContainerPaths()

  if not options.skip_pull:
    for path in containerPaths:
      print 'Pulling from git repository: %s' % path
      subprocess.call(['git', 'pull'], cwd=path, stdout=open(os.devnull, 'w'))

  dependencies = map(lambda p: ("./containers%s" % trimstart(p, containersRoot), getParentImageName(p)), containerPaths)

  getTargets = lambda t: [getDefaultMakefileEntry(fst(t), snd(t), metaDattRoot), getRunMakefileEntry(fst(t), metaDattRoot)]
  targets = list(itertools.chain(*map(getTargets, dependencies)))

  allTargets = ' '.join(map(fst, targets))
  phonyLine = "\n.PHONY: all test %s\n" % allTargets
  allLine = "all: test %s\n" % allTargets
  testLines = "test:\n\tbats ./tests/*\n"
  targetEntries = map(snd, targets)

  allSections = [phonyLine, allLine, testLines] + targetEntries

  print('Writing ./Makefile')
  with open('Makefile', 'w') as f:
    f.write("%s\n" % '\n'.join(allSections))

  if target: subprocess.call(['make', target.replace(':', '%')])
