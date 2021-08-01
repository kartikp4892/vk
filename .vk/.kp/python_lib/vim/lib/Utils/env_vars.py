#!/usr/bin/env python
import os
import sys
import re

def env2path (envvar):
  try:
    ENVVAR = os.environ[envvar]
  except Exception as e:
    return []

  envpaths = []
  for path in ENVVAR.split(':'):
    try:
      path = re.sub(r'\$(\w+)', lambda x: os.environ[str(x.group(1))], path)
      path = os.path.abspath(path)
      envpaths.append(path)
    except Exception:
      print sys.exc_info()
  return envpaths




