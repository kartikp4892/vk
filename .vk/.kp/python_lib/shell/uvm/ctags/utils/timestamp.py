#!/usr/bin/env python

import os
import imp
def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

logger_path = '{kp_vim_home}/python_lib/vim/ctags/utils/logger.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
LOGGER = import_(logger_path)

class Timestamp(object):
  """class: Timestamp"""

  def __init__(self, **kwargs):
    self.outdir = kwargs['outdir']
    self.tstamp_file = '{0}/_info'.format(self.outdir)

  # After tag files are generated. this function is called which creates a reference file which will be used
  # next time the tags are generated. All the files to be included in tag search will be compared with this
  # timestamp to check if file was modified after reference file was created. Only new/updated files will be
  # process, skipping other for which the tags already process last time
  def set (self):
    """def: set"""
    m_info_logger = LOGGER.Logger(self.tstamp_file)
    m_info_logger.write('')
    del m_info_logger
    
  # TODO: Add this in common package . THis is used in ctags and timestamp file both
  def get_tags_fname (self, svfname):
    """def: get_tags_fname"""
    dirname = os.path.basename(svfname)
    dirname = '_'.join(dirname.rsplit('.', 1))

    fname = '{0}/tags/_libs/{1}.tags'.format(self.outdir, dirname)
    return fname

  def is_tagfile_exists (self, svfile):
    """def: is_tagfile_exists"""
    tagfile = self.get_tags_fname(svfile)
    if not os.path.isfile(tagfile): return 0
    return 1

  # return new/modified files with respect to tstamp_file
  def getmfiles (self, files):
    """def: getmfiles"""
    if not os.path.isfile(self.tstamp_file): return files
      
    mfiles = []
    tstamp = os.path.getmtime(self.tstamp_file)
    for fname in files:
      if not self.is_tagfile_exists(fname):
        mfiles.append(fname)
      else:
        filetime = os.path.getmtime(fname)
        if filetime >= tstamp:
          mfiles.append(fname)

    return mfiles

