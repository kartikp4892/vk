#!/usr/bin/env python


from sv.base.parser.Combinators import Parser
import sys
from sv.base.Singleton import Logger
from sv.base.lexer.Lexer import Lexer
from sv.base.lexer.SharedVars import *

class uvm_base_parser(Parser):
  """class: uvm_base_parser"""
  pass
    

class uvm_report_macro_base(uvm_base_parser):
  """class: uvm_report_macro_base"""

  def __init__(self, **kwargs):
    super(uvm_report_macro_base, self).__init__(**kwargs)
    # Note: Child class to provide the value of num_args
    self.num_args = kwargs['num_args']
    self.args = []

  def _parse_arg (self):
    """def: _parse_arg"""
    # Not a start of argument
    self.m_lexer.m_token.highlight('DiffAdd')
    if not (self.m_lexer.m_prev_token.text != ',' or self.m_lexer.m_prev_token.text != '('): return None

    start = self.m_lexer.m_token.start
    while not (self.is_kw (',') or self.is_kw (')')):
      if self.skip_block('{', '}'): continue # Concatination of string in argument
      if self.skip_block('(', ')'): continue # skip parenthesis in function call
      if not self.m_lexer.next_token() : return None
      
    end = self.m_lexer.m_prev_token.end
    return (start, end)

  def _parse (self):
    """def: _parse"""
    if self.is_kw(self.__class__.report_macro_name):
    #if self.is_kw('`uvm_info'):
      self.m_lexer.m_token.highlight('DiffAdd')

      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token() : return 0
      self.m_lexer.m_token.highlight('DiffAdd')

      if not self.expect_kw ('('): return 0
      if not self.m_lexer.next_token() : return 0

      for idx in range(self.num_args):
        pos = self._parse_arg ()
        if not pos:
          self.expect_tag('MACRO_ARGUMENT')
          return 0
        self.args.append(pos)
        if idx == self.num_args - 1:
          if not self.expect_kw (')'): return 0
        else:
          if not self.expect_kw (','): return 0
        self.m_lexer.next_token()
      self.end = self.m_lexer.m_token.end
      return 1
    return 0


class uvm_info(uvm_report_macro_base):
  """class: uvm_info"""

  report_macro_name = '`uvm_info'

  def __init__(self, **kwargs):
    # `uvm_info marcro has 3 arguments `ID, MSG, VERBOSITY`
    kwargs['num_args'] = 3
    super(uvm_info, self).__init__(**kwargs)

class uvm_warning(uvm_report_macro_base):
  """class: uvm_info"""

  report_macro_name = '`uvm_warning'

  def __init__(self, **kwargs):
    # `uvm_warning marcro has 2 arguments `ID, MSG`
    kwargs['num_args'] = 2
    super(uvm_warning, self).__init__(**kwargs)

class uvm_fatal(uvm_report_macro_base):
  """class: uvm_info"""

  report_macro_name = '`uvm_fatal'

  def __init__(self, **kwargs):
    # `uvm_fatal marcro has 2 arguments `ID, MSG`
    kwargs['num_args'] = 2
    super(uvm_fatal, self).__init__(**kwargs)

class uvm_error(uvm_report_macro_base):
  """class: uvm_info"""

  report_macro_name = '`uvm_error'

  def __init__(self, **kwargs):
    # `uvm_error marcro has 2 arguments `ID, MSG`
    kwargs['num_args'] = 2
    super(uvm_error, self).__init__(**kwargs)

#-------------------------------------------------------------------------------
# UVM Utility Macros Starts From Here
#-------------------------------------------------------------------------------
class uvm_utility_macro_base(uvm_base_parser):
  """class: uvm_utility_macro_base"""
  pass
    
class uvm_component_utils(uvm_utility_macro_base):
  """class: uvm_component_utils"""

  def __init__(self, **kwargs):
    super(uvm_component_utils, self).__init__(**kwargs)
    
  # TODO: Add parsing function

#-------------------------------------------------------------------------------
# TLM Macros
#-------------------------------------------------------------------------------
class uvm_analysis_imp_decl(uvm_base_parser):
  """class: uvm_analysis_imp_decl"""

  macro_name = '`uvm_analysis_imp_decl'

  def __init__(self, **kwargs):
    super(uvm_analysis_imp_decl, self).__init__(**kwargs)
    self.name = ''

  def _parse (self):
    """def: _parse"""
    if self.is_kw('`uvm_analysis_imp_decl'):
      self.m_lexer.m_token.highlight('DiffAdd')

      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1) : return 0
      self.m_lexer.m_token.highlight('DiffAdd')

      if not self.expect_kw ('('): return 0
      if not self.m_lexer.next_token(1) : return 0

      if not self.expect_tag (IDENTIFIER): return 0
      self.name = 'uvm_analysis_imp{}'.format(self.m_lexer.m_token.text)

      if not self.m_lexer.next_token(1) : return 0
      if not self.expect_kw (')'): return 0

      self.m_lexer.next_token()

      self.end = self.m_lexer.m_token.end
      return 1
    return 0
  
    
#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
if __name__ == "__main__":
  m_logger = Logger()
  m_logger.debug_mode(1)

  m_lexer = Lexer()
  m_lexer.next_token()

  while 1:
    
    m_uvm_info = uvm_info(m_lexer=m_lexer)
    if m_uvm_info._parse():
      m_uvm_info.highlight('DiffAdd')
      continue

    m_uvm_warning = uvm_warning(m_lexer=m_lexer)
    if m_uvm_warning._parse():
      m_uvm_warning.highlight('DiffAdd')
      continue

    m_m_uvm_analysis_imp_decl = uvm_analysis_imp_decl(m_lexer=m_lexer)
    if m_m_uvm_analysis_imp_decl._parse():
      m_m_uvm_analysis_imp_decl.highlight('DiffAdd')

    if not m_lexer.next_token(): break



















