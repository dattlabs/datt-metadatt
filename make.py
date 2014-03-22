#!/usr/bin/env python

from sys import argv, exit
from subprocess import call
import glob
import os

isContainerPath = lambda p: os.path.isfile("%s/Dockerfile" % p)

def single(lst):
  if not len(lst) == 1:
    raise RuntimeError('single expects a list containing one item: %s' % lst)
  return lst[0]

trimstart = lambda s, subs: s[len(subs):] if s.startswith(subs) else s
trimend   = lambda s, subs: s[:-len(subs)] if s.endswith(subs) else s
trim      = lambda s, subs: trimstart(trimend(s, subs), subs)

def getParentImageName(targetPath):
  if not isContainerPath(targetPath): return None
  with open('%s/Dockerfile' % targetPath) as f:
    fromLine = single(filter(lambda s: s.startswith('FROM'), [s.strip() for s in f.readlines()]))
    return trim(trim(fromLine, ":latest"), "FROM").strip()

isDattImage           = lambda img: img.startswith("datt/datt-")
containerPathToTarget = lambda cp:  trimstart(cp, "../datt-")
imageNameToTarget     = lambda img: trimstart(img, "datt/datt-")

fst = lambda x: x[0]
snd = lambda x: x[1]

def getMakefileEntry(containerPath, parentImageName):
  target = containerPathToTarget(containerPath)
  parent = imageNameToTarget(parentImageName)
  labelLine = "%s:%s" % (target, " %s" % parent if isDattImage(parentImageName) else "")
  return (target, "%s\n\t%s/build\n" % (labelLine, containerPath))

if __name__ == "__main__":
  target = None
  if len(argv) == 2:
    target = argv[1]
  elif len(argv) > 2:
    print('Usage: make.py [build_target]')

  metaDattRoot = os.path.dirname(os.path.realpath(__file__))
  dattRoot = os.path.abspath(os.path.join(metaDattRoot, os.pardir))

  paths = set(glob.glob("%s/datt-*" % dattRoot)) - set(glob.glob(metaDattRoot))
  containerPaths = filter(isContainerPath, paths)

  dependencies = map(lambda p: ("..%s" % trimstart(p, dattRoot), getParentImageName(p)), containerPaths)

  targets = [getMakefileEntry(fst(t), snd(t)) for t in dependencies]

  allTargets = ' '.join(map(fst, targets))
  phonyLine = "\n.PHONY: all test %s\n" % allTargets
  allLine = "all: test %s\n" % allTargets
  testLines = "test:\n\tbats ./tests/*\n"
  targetEntries = map(snd, targets)

  allSections = [phonyLine, allLine, testLines] + targetEntries

  with open('Makefile', 'w') as f:
    f.write("%s\n" % '\n'.join(allSections))

  if target: call(['make', target])
