#!/usr/bin/env python

import os
import imp
def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

search_path = '{kp_vim_home}/python_lib/shell/uvm/ctags/utils/bufdo_search.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
BUFDOSEARCH = import_(search_path)

tstamp_path = '{kp_vim_home}/python_lib/shell/uvm/ctags/utils/timestamp.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
TIMESTAMP = import_(tstamp_path)

logger_path = '{kp_vim_home}/python_lib/vim/ctags/utils/logger.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
LOGGER = import_(logger_path)

tagspool_path = '{kp_vim_home}/python_lib/vim/ctags/utils/tags_pool.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
TAGSPOOL = import_(tagspool_path)

class TagsAgent(object):
  """class: tags_agent"""

  def __init__(self, **kwargs):
    self.m_tstamp = TIMESTAMP.Timestamp(**kwargs)

    # Get new/modifiles files out of all files
    mfiles = self.m_tstamp.getmfiles(kwargs['files'])

    self.files = mfiles
    self.outdir = kwargs['outdir']
    self.tagdir = '{0}/tags'.format(self.outdir)
    self.userdt_dir = '{0}/userdt'.format(self.outdir)
    self.clstree_dir = '{0}/clstree'.format(self.outdir)

    self.m_bufdo_search = BUFDOSEARCH.BufdoSearch(files=mfiles, outdir=kwargs['outdir'])

  def merge_userdt (self):
    """def: merge_userdt"""
    if len(self.files) != 0:
      # merge all processsed files
      m_tagspool = TAGSPOOL.TagsPool(files=[], ctagsdir=self.tagdir, userdt_dir=self.userdt_dir, clstree_dir=self.clstree_dir)
      m_tagspool.merge_userdt()
    
  def merge_tags (self):
    """def: merge_tags"""
    if len(self.files) != 0:
      # merge all processsed files
      m_tagspool = TAGSPOOL.TagsPool(files=[], ctagsdir=self.tagdir, userdt_dir=self.userdt_dir, clstree_dir=self.clstree_dir)
      m_tagspool.merge_tags()

    
  def run (self):
    """def: run"""
    self.m_bufdo_search.datatypes()
    self.merge_userdt()

    self.m_bufdo_search.tags()
    self.merge_tags()

    # Set current timestamp info for future tags parsing
    self.m_tstamp.set()

    # del self.m_bufdo_search.m_tagspool

if __name__ == '__main__':
  m_tags_agent = TagsAgent(files=['temp.sv'], outdir='{0}/svtags'.format(os.environ['HOME']))

  m_tags_agent.run()







