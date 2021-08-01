#!/usr/bin/env python

from logger import Logger
try:
  import vim
  vim_detected = 1
except Exception as e:
  import os
  vim_detected = 0

class Atags(object):
  """class: Atags"""

  def __init__(self, **kwargs):
    self.outdir = kwargs['outdir']
    self.files = kwargs['files']
    self.libdir = "{0}/_auto".format(self.outdir)
    self.m_loggers = {} # fname => m_logger
    self.header = '!_TAG_FILE_SORTED	1	/0=unsorted, 1=sorted, 2=foldcase/'

    self.init_tag_files()

  # TODO: Add this in common package . THis is used in atags, ctags and timestamp file both
  def get_out_fname (self, svfname):
    """def: get_out_fname"""
    dirname = os.path.basename(svfname)
    dirname = '_'.join(dirname.rsplit('.', 1))

    fname = '{0}/{1}.tags'.format(self.libdir, dirname)
    return fname


  def write (self, m_token):
    """def: write"""

    # Only write in tag file if its tag token.
    # See: $KP_VIM_HOME/python_lib/vim/ctags/utils/search.py ==> `Class`
    if m_token and 'Atags' in m_token._users:
      tagfname = self.get_out_fname(m_token.filename)
      if tagfname not in self.m_loggers:
        print "Error: unknown file {0}".format(tagfname)
        quit()

      self.m_loggers[tagfname].write(m_token)

  def init_tag_files (self):
    """def: init_tag_files"""
    for fname in self.files:
      tagfname = self.get_out_fname(fname)
      self.m_loggers[tagfname] = Logger(tagfname)
      # self.m_loggers[tagfname].write(self.header)

  def merge_libs (self):
    """def: merge_libs"""

    tags = []
    for filename in os.listdir(self.libdir):
      if filename.endswith('.tags'):
        filename = "{0}/{1}".format(self.libdir, filename)
        with open(filename) as fh:
          lines = fh.readlines()
          tags += lines

    tags.sort()
    tagfname = '{0}/_merged/_auto/tags'.format(self.outdir)
    m_logger = Logger(tagfname)
    m_logger.write(self.header)
    text = ''.join(tags)
    m_logger.write(text)

  def done (self):
    """def: done"""
    # self.merge_libs()

    for fname, m_logger in self.m_loggers.iteritems():
      #m_logger.logfh.close()
      del m_logger

    #del self.m_loggers

    # for fname, m_logger in self.m_loggers.iteritems():
    #   del m_logger

      # Redirect vim errors to stdout
      # self.sort(fname)


