#!/usr/bin/env python

try:
  import vim
  vim_detected = 1
except Exception as e:
  vim_detected = 0

import re
from sv.base.parser import Combinators
from sv.base.parser import UVMMacros
from sv.base.Singleton import Logger
from sv.base.lexer.Lexer import Lexer

from Utils import Buffer

class function(Combinators.ClassFunction):
  """class: function"""

  endmethod = 'endfunction'

  def __init__(self, **kwargs):
    super(function, self).__init__(**kwargs)
    self.m_uvm_report_macros = []

  def _parse (self):
    """def: _parse"""

    if self._parse_header():
      # Skip until end of task
      while not self.is_kw('endfunction'):
        m_uvm_info = uvm_info(m_lexer=self.m_lexer, ID=self.name)
        if m_uvm_info._parse():
          self.m_uvm_report_macros.append(m_uvm_info)
          continue

        m_uvm_warning = uvm_warning(m_lexer=self.m_lexer, ID=self.name)
        if m_uvm_warning._parse():
          self.m_uvm_report_macros.append(m_uvm_warning)
          continue

        m_uvm_fatal = uvm_fatal(m_lexer=self.m_lexer, ID=self.name)
        if m_uvm_fatal._parse():
          self.m_uvm_report_macros.append(m_uvm_fatal)
          continue

        m_uvm_error = uvm_error(m_lexer=self.m_lexer, ID=self.name)
        if m_uvm_error._parse():
          self.m_uvm_report_macros.append(m_uvm_error)
          continue

        if not self.m_lexer.next_token() : return 0
      return 1

    return 0

class task(Combinators.ClassTask):
  """class: task"""

  def __init__(self, **kwargs):
    super(task, self).__init__(**kwargs)
    self.m_uvm_report_macros = []

  def _parse (self):
    """def: _parse"""

    if self._parse_header():
      # Skip until end of task
      while not self.is_kw('endtask'):
        m_uvm_info = uvm_info(m_lexer=self.m_lexer, ID=self.name)
        if m_uvm_info._parse():
          self.m_uvm_report_macros.append(m_uvm_info)
          continue

        m_uvm_warning = uvm_warning(m_lexer=self.m_lexer, ID=self.name)
        if m_uvm_warning._parse():
          self.m_uvm_report_macros.append(m_uvm_warning)
          continue

        m_uvm_fatal = uvm_fatal(m_lexer=self.m_lexer, ID=self.name)
        if m_uvm_fatal._parse():
          self.m_uvm_report_macros.append(m_uvm_fatal)
          continue

        m_uvm_error = uvm_error(m_lexer=self.m_lexer, ID=self.name)
        if m_uvm_error._parse():
          self.m_uvm_report_macros.append(m_uvm_error)
          continue

        if not self.m_lexer.next_token() : return 0
      return 1

    return 0


class uvm_macro_meta(type):
  """class: uvm_macro_meta"""

  def __call__(cls, *args, **kwargs):
    """def: __call__"""

    ID = kwargs.get('ID', None)
    if not ID:
      ID = 'get_full_name()'
    else:
      del kwargs['ID']

    clsinst = super(uvm_macro_meta, cls).__call__(*args, **kwargs)
    clsinst.ID = ID

    return clsinst
    
  def __init__(cls, name, parents, dict):
    """def: __init__"""

    super(uvm_macro_meta, cls).__init__(name, parents, dict)

    def replace_id (self):
      """def: replace_id"""
      # Id is the first argument of UVM_INFO
      start, end = self.args[0]
      Buffer.replace_str(start, end, '"{0}"'.format(self.ID))
      # Buffer.replace_str(start, end, '"{0}"'.format(self.ID))

    setattr(cls, 'replace_id', replace_id)
    

class uvm_info(UVMMacros.uvm_info):
  """class: uvm_info"""

  __metaclass__ = uvm_macro_meta

    
class uvm_warning(UVMMacros.uvm_warning):
  """class: uvm_warning"""

  __metaclass__ = uvm_macro_meta
    
class uvm_fatal(UVMMacros.uvm_fatal):
  """class: uvm_info"""

  __metaclass__ = uvm_macro_meta

    
class uvm_error(UVMMacros.uvm_error):
  """class: uvm_warning"""

  __metaclass__ = uvm_macro_meta
    

if __name__ == "__main__":
  m_logger = Logger()
  m_logger.debug_mode(0)

  if vim_detected:
    m_lexer = Lexer()
  else:
    m_lexer = Lexer(fname='temp.sv') # FIXME
  m_lexer.next_token()

  m_uvm_report_macros = []

  while 1:
    
    m_fun = function(m_lexer=m_lexer)
    if m_fun():
      m_fun.highlight('DiffAdd')
      m_uvm_report_macros += m_fun.m_uvm_report_macros
      continue

    m_task = task(m_lexer=m_lexer)
    if m_task():
      m_task.highlight('DiffAdd')
      m_uvm_report_macros += m_task.m_uvm_report_macros
      continue

    if not m_lexer.next_token(): break


  m_uvm_report_macros.reverse()
  for m_uvm_report_macro in m_uvm_report_macros:
    m_uvm_report_macro.replace_id()






