#!/usr/bin/env python

import os

def ensure_dir (dir_):
  """def: mkdir"""
  if not os.path.exists(dir_):
    os.makedirs(dir_)






