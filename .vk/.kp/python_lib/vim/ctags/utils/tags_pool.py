#!/usr/bin/env python

from utils.ctags import Ctags
from utils.atags import Atags
from utils.user_datatypes import UserDT
from utils.class_tree_tags import ClassTreeTags

class TagsPool(object):
  """class: TagsPool"""

  def __init__(self, **kwargs):
    self.files = kwargs['files']
    self.m_ctags = None
    self.m_atags = None
    self.m_userdt = None
    self.m_clstree = None

    if 'ctagsdir' in kwargs:
      self.m_ctags = Ctags(files=self.files, outdir=kwargs['ctagsdir'])
      self.m_atags = Atags(files=self.files, outdir=kwargs['ctagsdir'])

    if 'userdt_dir' in kwargs:
      self.m_userdt = UserDT(kwargs['userdt_dir'])

    if 'clstree_dir' in kwargs:
      self.m_clstree = ClassTreeTags(kwargs['clstree_dir'])

  def write (self, m_token):
    """def: write"""
    if self.m_ctags: self.m_ctags.write(m_token)
    if self.m_atags: self.m_atags.write(m_token)
    if self.m_clstree: self.m_clstree.write(m_token)
    if self.m_userdt: self.m_userdt.write(m_token)

    
#   def write_userdt_done (self):
#     """def: write_userdt_done"""
#     self.m_userdt = None

  def done_userdt (self):
    """def: done_userdt"""
    # All the userdatatypes are processed at first.. write userdatatypes to tag files
    if self.m_userdt: 
      self.m_userdt.done()
      self.m_userdt = None # Free memory contains all the userdt tokens, else processing will be much slow
    
  def done_tags (self):
    """def: done_tags"""

    #if self.m_userdt: self.m_userdt.done()
    if self.m_ctags: self.m_ctags.done()
    if self.m_atags: self.m_atags.done()
    if self.m_clstree: self.m_clstree.done()

  def merge_userdt (self):
    """def: merge_userdt"""
    if self.m_userdt: self.m_userdt.merge_libs()

  def merge_tags (self):
    """def: merge_tags"""
    if self.m_clstree: self.m_clstree.merge_libs()
    if self.m_ctags: self.m_ctags.merge_libs()
    if self.m_atags: self.m_atags.merge_libs()
    


