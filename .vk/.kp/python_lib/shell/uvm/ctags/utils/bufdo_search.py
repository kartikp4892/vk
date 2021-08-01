#!/usr/bin/env python

import os
import imp

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

search_path = '{kp_vim_home}/python_lib/shell/uvm/ctags/utils/search.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
Search = import_(search_path)

tagspool_path = '{kp_vim_home}/python_lib/vim/ctags/utils/tags_pool.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
TAGSPOOL = import_(tagspool_path)

class BufdoSearch(object):
  """class: BufdoSearch"""

  def __init__(self, **kwargs):
    self.files = kwargs['files']
    self.outdir = kwargs['outdir']

    self.tagdir = '{0}/tags'.format(self.outdir)
    self.userdt_dir = '{0}/userdt'.format(self.outdir)
    self.clstree_dir = '{0}/clstree'.format(self.outdir)

    # TODO: TagsPool can be moved in Search module processing each individual file instead of processing all the files together.
    #       But there can be multiple files for which tag file will be same. 
    #       For example: `file.svh` or `file.sv` or `abc/file.sv` or `def/file.sv`
    #       The above files will result in same tag file: tags/file/tags
    #       Processing individual file at a time will override tags files processed previously
    self.m_tagspool = TAGSPOOL.TagsPool(files=self.files, ctagsdir=self.tagdir, userdt_dir=self.userdt_dir, clstree_dir=self.clstree_dir)

    self.m_searches = []
    # || # BAD: Causing error of so many file handles open.. Workaournd is to open one file at a time
    # || for fname in self.files:
    # ||   m_search = Search.Search(fname=fname)
    # ||   self.m_searches.append(m_search)

  def datatypes (self):
    """def: datatypes"""
    for fname in self.files:
      m_search = Search.Search(fname=fname)
      for m_token in m_search.datatypes():
        self.m_tagspool.write(m_token)

    # || for m_search in self.m_searches:
    # ||   for m_token in m_search.datatypes():
    # ||     self.m_tagspool.write(m_token)

    # m_tagspool.merge_userdt() need to be called after all userdt are processed
    # This will be done one level up that is parent of BufdoSearch
    self.m_tagspool.done_userdt()
        
  def tags (self):
    """def: tags"""
    for fname in self.files:
      m_search = Search.Search(fname=fname)
      for m_token in m_search.tags():
        self.m_tagspool.write(m_token)

    # || for m_search in self.m_searches:
    # ||   for m_token in m_search.tags():
    # ||     self.m_tagspool.write(m_token)

    # m_tagspool.merge_tags() need to be called after all tags are processed
    # This will be done one level up that is parent of BufdoSearch
    self.m_tagspool.done_tags()

if __name__ == '__main__':
  files = ['temp.sv']
  m_bufdosearch = BufdoSearch(files=files)
  for m_token in m_bufdosearch.datatypes():
    print m_token






