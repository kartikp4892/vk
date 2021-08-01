#!/usr/bin/env python

from sv.base.parser import ast
from sv.base.parser import Combinators
from sv.base.lexer.SharedVars import *
import vim

class TagClassAST(ast.Class):
  """class: ClassVars"""

  def __init__(self, **kwargs):
    super(TagClassAST, self).__init__(**kwargs)
    

class TagTask(Combinators.ClassTask):
  """class: TagTask"""

  def __init__(self, **kwargs):
    super(TagTask, self).__init__(**kwargs)
    self.extern = 0
    self.virtual = 0
    self.static = 0

  def _parse (self):
    """def: _parse
       This function is used in svtags for generating tag file for sv
    """
    if self.is_kw('task'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(): return 0

      while self.m_lexer.m_token.text != '(' and self.m_lexer.m_token.text != ';': # Some tasks are with no arguments --> task abc;
        if self.m_lexer.m_token.text == '::':
          self.parent_class = self.m_lexer.m_prev_token.text

        if self.skip_block('#(', ')'): continue
        if self.skip_block('[', ']'): continue

        if not self.m_lexer.next_token() : return 0
          
      self.name = self.m_lexer.m_prev_token.text

      self.end = (vim.eval('search(\';\', "W")'), None)
      # || OR || self.skip_block('(', ')') # Arguments

      #if not self.is_tag (EOS): return 0
      #self.end = self.m_lexer.m_token.end
      return 1
    return 0


  def __call__ (self):
    """def: __call__"""
    start = None
    lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer

    while self.is_kw('extern') or self.is_kw('protected') or self.is_kw('local') or self.is_kw('virtual') or self.is_kw('pure') or self.is_kw('static'):
      if self.is_kw('extern'):
        self.extern = 1
        if not start:
          start = self.m_lexer.m_token.start

      if self.is_kw('protected') or self.is_kw('local'):
        self.visibility = self.m_lexer.m_token.text
        if not start:
          start = self.m_lexer.m_token.start
      
      if self.is_kw('virtual'):
        self.virtual = 1
        if not start:
          start = self.m_lexer.m_token.start
      
      if self.is_kw('pure'):
        self.pure = 1
        if not start:
          start = self.m_lexer.m_token.start

      if self.is_kw('static'):
        self.static = 1
        if not start:
          start = self.m_lexer.m_token.start

      if not self.m_lexer.next_token(): return 0

    ret = self._parse()

    if ret:
      lexer_pos_bkp = None
      if start:
        self.start = start
    else:
      if self.extern and not self.is_kw('task'): # Extern is only applicables to methods
        if not self.expect_tag ('FUNCTION/TASK'): return 0
      self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer
    
    return ret
    
    
class TagFunction(Combinators.ClassFunction):
  """class: FunctionBase"""

  def __init__(self, **kwargs):
    super(TagFunction, self).__init__(**kwargs)
    self.extern = 0
    self.virtual = 0
    self.static = 0

  def _parse (self):
    """def: _parse_header
       This function is used in svtags for generating tag file for sv
    """
    if self.is_kw('function'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(): return 0

      while self.m_lexer.m_token.text != '(' and self.m_lexer.m_token.text != ';': # Some functionas are with no arguments --> function void abc;
        if self.m_lexer.m_token.text == '::':
          self.parent_class = self.m_lexer.m_prev_token.text

        if self.skip_block('#(', ')'): continue
        if self.skip_block('[', ']'): continue

        if not self.m_lexer.next_token() : return 0
          
      self.name = self.m_lexer.m_prev_token.text

      self.end = (vim.eval('search(\';\', "W")'), None)
      # || OR || self.skip_block('(', ')') # Arguments

      # || OR || if not self.is_tag (EOS): return 0
      # || OR || self.end = self.m_lexer.m_token.end
      return 1
    return 0


  def __call__ (self):
    """def: __call__"""
    start = None
    lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer

    while self.is_kw('extern') or self.is_kw('protected') or self.is_kw('local') or self.is_kw('virtual') or self.is_kw('pure') or self.is_kw('static'):
      if self.is_kw('extern'):
        self.extern = 1
        if not start:
          start = self.m_lexer.m_token.start

      if self.is_kw('protected') or self.is_kw('local'):
        self.visibility = self.m_lexer.m_token.text
        if not start:
          start = self.m_lexer.m_token.start
      
      if self.is_kw('virtual'):
        self.virtual = 1
        if not start:
          start = self.m_lexer.m_token.start
      
      if self.is_kw('pure'):
        self.pure = 1
        if not start:
          start = self.m_lexer.m_token.start

      if self.is_kw('static'):
        self.static = 1
        if not start:
          start = self.m_lexer.m_token.start

      if not self.m_lexer.next_token(): return 0

    ret = self._parse()

    if ret:
      lexer_pos_bkp = None
      if start:
        self.start = start
    else:
      if self.extern and not self.is_kw('task'): # Extern is only applicables to methods
        if not self.expect_tag ('FUNCTION/TASK'): return 0
      self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer
    
    return ret
    
    
class TagClass(Combinators.Class):
  """class: TagClass"""

  def __init__(self, **kwargs):
    super(self.__class__, self).__init__(**kwargs)

class TagParameter(Combinators.Parameter):
  """class: TagParameter"""

  def __init__(self, **kwargs):
    super(self.__class__, self).__init__(**kwargs)

class TagConst(Combinators.Const):
  """class: TagConst"""

  def __init__(self, **kwargs):
    super(self.__class__, self).__init__(**kwargs)


class TagTypedef(Combinators.Parser):
  """class: TagTypedef"""

  def __init__(self, **kwargs):
    super(TagTypedef, self).__init__(**kwargs)
    name = None

  def __call__ (self):
    """def: __call__"""
    if self.is_kw('typedef'):
      self.start = self.m_lexer.m_token.start

      while not self.is_kw(';'):
	if self.skip_block('{', '}'): continue
	if self.skip_block('#(', ')'): continue

        if self.is_kw('['):
          self.name = self.m_lexer.m_prev_token.text
          if self.skip_block('[', ']'):
            continue

        self.name = self.m_lexer.m_token.text
        if not self.m_lexer.next_token(): return 0

      self.end = self.m_lexer.m_token.end
      return 1
    return 0

class TagEnumVal(Combinators.Parser):
  """class: TagEnumVal"""

  def __init__(self, **kwargs):
    super(TagEnumVal, self).__init__(**kwargs)
    self.tokens = [] # {start: start, value: value}

  def __call__ (self):
    """def: __call__"""

    # Optional typedef
    if self.is_kw('typedef'):
      if not self.m_lexer.next_token(): return 0

    if self.is_kw('enum'):
      # self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(): return 0

      #-------------------------------------------------------------------------------
      # Skip until start of enum values
      while not self.is_kw('{'):
        if not self.m_lexer.next_token(): return 0
      #-------------------------------------------------------------------------------

      if not self.expect_kw('{'): return 0
      if not self.m_lexer.next_token(): return 0

      while not self.is_kw('}'):
        self.expect_tag(IDENTIFIER)
        self.tokens.append({'start': self.m_lexer.m_token.start, 'value': self.m_lexer.m_token.text})

        if not self.m_lexer.next_token(): return 0

        # Skip default values
        if self.is_kw('='):
          while not (self.is_kw(',') or self.is_kw('}')):
            if not self.m_lexer.next_token(): return 0

        if not self.is_kw('}'): 
          if not self.expect_kw(','): return 0
          if not self.m_lexer.next_token(): return 0
          
      if not self.expect_kw('}'): return 0
      if not self.m_lexer.next_token(): return 0
      self.expect_tag(IDENTIFIER)

      self.end = self.m_lexer.m_token.end
      return 1
    return 0






