#!/usr/bin/env python

from sys import argv, exit
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

def getMakefileEntry(containerPath, parentImageName):
  target = containerPathToTarget(containerPath)
  parent = imageNameToTarget(parentImageName)
  labelLine = "%s:%s" % (target, " %s" % parent if isDattImage(parentImageName) else "")
  return (target, "%s\n\t%s/build\n" % (labelLine, containerPath))

if __name__ == "__main__":
  target = None
  if len(argv) == 2: target = argv[1]
  elif len(argv) > 2: print('Usage: make.py [build_target]'); exit(1)

  metaDattRoot = os.path.dirname(os.path.realpath(__file__))
  containersRoot = "%s/containers" % metaDattRoot

  paths = glob.glob("%s/datt-*" % containersRoot)
  containerPaths = filter(isContainerPath, paths)

  for path in containerPaths:
    print 'Pulling from git repository: %s' % path
    subprocess.call(['git', 'pull'], cwd=path, stdout=open(os.devnull, 'w'))

  dependencies = map(lambda p: ("./containers%s" % trimstart(p, containersRoot), getParentImageName(p)), containerPaths)

  targets = [getMakefileEntry(fst(t), snd(t)) for t in dependencies]

  allTargets = ' '.join(map(fst, targets))
  phonyLine = "\n.PHONY: all test %s\n" % allTargets
  allLine = "all: test %s\n" % allTargets
  testLines = "test:\n\tbats ./tests/*\n"
  targetEntries = map(snd, targets)

  allSections = [phonyLine, allLine, testLines] + targetEntries

  with open('Makefile', 'w') as f:
    f.write("%s\n" % '\n'.join(allSections))

  if target: subprocess.call(['make', target])
