#!/usr/bin/env python

import os
class Logger(object):
  """class: Logger"""

  def __init__(self, outfile):
    self.outfile = outfile

    self.ensure_dir()
    logfh = open(self.outfile, 'w')
    logfh.close()

  def ensure_dir (self):
    """def: mkdir"""
    path, name = os.path.split(self.outfile)
    if not os.path.exists(path):
      os.makedirs(path)

  def write (self, text):
    """def: write"""
    str = "{text}\n".format(text=text)
    logfh = open(self.outfile, 'a')
    logfh.write(str)
    logfh.close()

  def __del__ (self):
    """def: __del__"""
    #self.logfh.close()
    pass




