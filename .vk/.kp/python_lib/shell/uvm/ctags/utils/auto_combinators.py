#!/usr/bin/env python

import os
import imp

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

combinators_path = '{kp_vim_home}/python_lib/vim/lib/sv/base/parser/Combinators.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
COMBINATORS = import_(combinators_path)

sharedvars_path = '{kp_vim_home}/python_lib/vim/lib/sv/base/lexer/SharedVars.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
SHAREDVARS = import_(sharedvars_path)

class TagInclude(COMBINATORS.Parser):
  """class: TagInclude"""

  def __init__(self, **kwargs):
    super(TagInclude, self).__init__(**kwargs)
    self.fname = None

  def tag_name (self):
    """def: tag_name"""
    
    name = os.path.basename(self.fname)
    # name = '_'.join(name.rsplit('.', 1)) # Remove extension

    return name

  def __call__ (self):
    """def: __call__"""
    if self.is_kw('`include') or self.is_kw('include'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0

      if not self.is_tag(SHAREDVARS.STRING): return 0
      #if not self.expect_tag(SHAREDVARS.STRING): return 0 # BUG: Fails for == `include `PUTINQUOTES(`MYOTHERFILE) ==

      self.fname = eval(self.m_lexer.m_token.text)
      self.end = self.m_lexer.m_token.end

      self.m_lexer.next_token()
      return 1
    return 0


class TagImport(COMBINATORS.Parser):
  """class: TagImport"""

  def __init__(self, **kwargs):
    super(TagImport, self).__init__(**kwargs)
    self.pkgname = None

  def tag_name (self):
    """def: tag_name"""
    
    name = self.pkgname
    # name = os.path.basename(self.fname)
    # name = '_'.join(name.rsplit('.', 1)) # Remove extension

    return name

  def __call__ (self):
    """def: __call__"""
    if self.is_kw('import') :
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0

      if not self.is_tag(SHAREDVARS.STRING): return 0
      #if not self.expect_tag(SHAREDVARS.STRING): return 0 # BUG: Fails for == `include `PUTINQUOTES(`MYOTHERFILE) ==

      self.pkgname = eval(self.m_lexer.m_token.text)
      self.end = self.m_lexer.m_token.end

      self.m_lexer.next_token()
      return 1
    return 0








