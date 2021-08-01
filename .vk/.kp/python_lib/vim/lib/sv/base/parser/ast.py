#!/usr/bin/env python

import imp
import os

from sv.base.parser import Combinators as COMBINATORS
from sv.base.lexer import Lexer as LEXER
from sv.base import Singleton as LOGGER

# || combinators_path = '{kp_vim_home}/python_lib/vim/lib/sv/base/parser/Combinators.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
# || COMBINATORS = imp.load_source('Combinators', combinators_path)
# || 
# || logger_path = '{kp_vim_home}/python_lib/vim/lib/sv/base/Singleton.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
# || #Logger = imp.load_source('Logger', logger_path).Logger
# || LOGGER = imp.load_source('Singleton', logger_path)
# || 
# || lexer_path = '{kp_vim_home}/python_lib/vim/lib/sv/base/lexer/Lexer.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
# || #Lexer = imp.load_source('Lexer', lexer_path).Lexer
# || LEXER = imp.load_source('Lexer', lexer_path)

class Class(COMBINATORS.Class):
  """class: Class"""

  def __init__(self, **kwargs):
    """Constructor: """
    super(Class, self).__init__(**kwargs)
    self.typedefs = {} # {name => m_typedef}
    self.properties = {} # {name => m_clsvars}
    self.tasks = {} # {name => m_task}
    self.functions = {} # {name => m_function}
    self.extern_tasks = {} # {name => m_task}
    self.extern_functions = {} # {name => m_function}
    self.pure_tasks = {} # {name => m_task}
    self.pure_functions = {} # {name => m_function}
    self.parameters = {} # {name => m_parameter}
    self.consts = {} # {name => m_const}
    self.covergroups = {} # {name => m_cg}

  def _parse_cls_property (self):
    """def: _parse_cls_property"""
    m_clsvars = COMBINATORS.ClassVars(m_lexer=self.m_lexer, clsname=self.name)
    if not m_clsvars._parse(): return 0

    for m_var in m_clsvars.m_variables:
      name = m_var.name
      # var_dt = m_clsvars._get_type() 
      if name not in self.properties:
        self.properties[name] = [m_clsvars]
      else:
        self.properties[name] += [m_clsvars]

    m_clsvars.highlight('DiffAdd')

    return 1
  
  def _parse_typedef (self):
    """def: _parse_typedef"""
    m_typedef = COMBINATORS.Typedef(m_lexer=self.m_lexer, clsname=self.name)
    if not m_typedef._parse(): return 0

    for m_var in m_typedef.m_variables:
      name = m_var.name
      # var_dt = m_typedef._get_type() 
      if name not in self.typedefs:
        self.typedefs[name] = [m_typedef]
      else:
        self.typedefs[name] += [m_typedef]

    m_typedef.highlight('Error')
    #m_typedef.highlight('DiffAdd')

    return 1
  
  def _parse_parameter (self):
    """def: _parse_parameter"""
    m_parameter = COMBINATORS.Parameter(m_lexer=self.m_lexer, clsname=self.name)
    if not m_parameter._parse(): return 0

    for m_var in m_parameter.m_variables:
      name = m_var.name
      # var_dt = m_parameter._get_type() 
      if name not in self.parameters:
        self.parameters[name] = [m_parameter]
      else:
        self.parameters[name] += [m_parameter]

    m_parameter.highlight('Error')
    #m_parameter.highlight('DiffAdd')

    return 1
  
  def _parse_const (self):
    """def: _parse_const"""
    m_const = COMBINATORS.Const(m_lexer=self.m_lexer, clsname=self.name)
    if not m_const._parse(): return 0

    for m_var in m_const.m_variables:
      name = m_var.name
      # var_dt = m_const._get_type() 
      if name not in self.consts:
        self.consts[name] = [m_const]
      else:
        self.consts[name] += [m_const]

    m_const.highlight('Error')
    #m_const.highlight('DiffAdd')

    return 1
  
  def _parse_cls_function (self):
    """def: _parse_cls_function"""
    m_cls_fun = COMBINATORS.ClassFunction(m_lexer=self.m_lexer, clsname=self.name)

    if not m_cls_fun._parse_header(): return 0

    # Extern/pure function inside class only have header
    if m_cls_fun.extern:
      if m_cls_fun.name not in self.extern_functions:
        self.extern_functions[m_cls_fun.name] = [m_cls_fun]
      else:
        self.extern_functions[m_cls_fun.name] += [m_cls_fun]
    elif m_cls_fun.pure:
      if m_cls_fun.name not in self.pure_functions:
        self.pure_functions[m_cls_fun.name] = [m_cls_fun]
      else:
        self.pure_functions[m_cls_fun.name] += [m_cls_fun]
    else:
      while not m_cls_fun._parse_footer():
        if not self.m_lexer.next_token() : return 0

      m_cls_fun.highlight('DiffAdd')

      if m_cls_fun.name not in self.functions:
        self.functions[m_cls_fun.name] = [m_cls_fun]
      else:
        self.functions[m_cls_fun.name] += [m_cls_fun]
      
    return 1

  def _parse_cls_task (self):
    """def: _parse_cls_task"""
    m_cls_task = COMBINATORS.ClassTask(m_lexer=self.m_lexer, clsname=self.name)

    if not m_cls_task._parse_header(): return 0

    # Extern/pure function inside class only have header
    if m_cls_task.extern:
      if m_cls_task.name not in self.extern_tasks:
        self.extern_tasks[m_cls_task.name] = [m_cls_task]
      else:
        self.extern_tasks[m_cls_task.name] += [m_cls_task]
      
    elif m_cls_task.pure:
      if m_cls_task.name not in self.pure_tasks:
        self.pure_tasks[m_cls_task.name] = [m_cls_task]
      else:
        self.pure_tasks[m_cls_task.name] += [m_cls_task]
    else:
      while not m_cls_task._parse_footer():
        if not self.m_lexer.next_token() : return 0

      m_cls_task.highlight('DiffAdd')

      if m_cls_task.name not in self.tasks:
        self.tasks[m_cls_task.name] = [m_cls_task]
      else:
        self.tasks[m_cls_task.name] += [m_cls_task]
      
    return 1

  def _parse_covergroup (self):
    """def: _parse_covergroup"""
    m_cg = COMBINATORS.Covergroup(m_lexer=self.m_lexer, clsname=self.name)

    if not m_cg._parse_header(): return 0

    while not m_cg._parse_footer():
      if not self.m_lexer.next_token() : return 0

    if m_cg.name not in self.covergroups:
      self.covergroups[m_cg.name] = [m_cg]
    else:
      self.covergroups[m_cg.name] += [m_cg]

    return 1
    
  def _parse (self):
    """def: _parse"""
    if not super(Class, self)._parse_header(): return 0

    while not super(Class, self)._parse_footer():
      #self.m_lexer.highlight_token()

      m_comments = COMBINATORS.Comments(m_lexer=self.m_lexer)
      if m_comments(): continue

      if self._parse_cls_function(): continue
      if self._parse_cls_task(): continue
      if self._parse_typedef(): continue
      if self._parse_parameter(): continue
      if self._parse_const(): continue
      if self._parse_cls_property(): continue
      if self._parse_covergroup(): continue

      #if self.m_lexer.is_done(): return 0 # Check if all lines parsed
      if not self.m_lexer.next_token() : return 0

    return 1
      
class Interface(COMBINATORS.Interface):
  """class: Interface"""

  def __init__(self, **kwargs):
    """Constructor: """
    super(Interface, self).__init__(**kwargs)
    self.typedefs = {} # {name => m_typedef}
    self.properties = {} # {name => m_clsvars}
    self.tasks = {} # {name => m_task}
    self.functions = {} # {name => m_function}
    self.extern_tasks = {} # {name => m_task}
    self.extern_functions = {} # {name => m_function}
    self.parameters = {} # {name => m_parameter}
    self.consts = {} # {name => m_const}
    self.covergroups = {} # {name => m_cg}

  def _parse_cls_property (self):
    """def: _parse_cls_property"""
    m_clsvars = COMBINATORS.ClassVars(m_lexer=self.m_lexer, clsname=self.name)
    if not m_clsvars._parse(): return 0

    for m_var in m_clsvars.m_variables:
      name = m_var.name
      # var_dt = m_clsvars._get_type() 
      if name not in self.properties:
        self.properties[name] = [m_clsvars]
      else:
        self.properties[name] += [m_clsvars]

    m_clsvars.highlight('DiffAdd')

    return 1
  
  def _parse_typedef (self):
    """def: _parse_typedef"""
    m_typedef = COMBINATORS.Typedef(m_lexer=self.m_lexer, clsname=self.name)
    if not m_typedef._parse(): return 0

    for m_var in m_typedef.m_variables:
      name = m_var.name
      # var_dt = m_typedef._get_type() 
      if name not in self.typedefs:
        self.typedefs[name] = [m_typedef]
      else:
        self.typedefs[name] += [m_typedef]

    m_typedef.highlight('Error')
    #m_typedef.highlight('DiffAdd')

    return 1
  
  def _parse_parameter (self):
    """def: _parse_parameter"""
    m_parameter = COMBINATORS.Parameter(m_lexer=self.m_lexer, clsname=self.name)
    if not m_parameter._parse(): return 0

    for m_var in m_parameter.m_variables:
      name = m_var.name
      # var_dt = m_parameter._get_type() 
      if name not in self.parameters:
        self.parameters[name] = [m_parameter]
      else:
        self.parameters[name] += [m_parameter]

    m_parameter.highlight('Error')
    #m_parameter.highlight('DiffAdd')

    return 1
  
  def _parse_const (self):
    """def: _parse_const"""
    m_const = COMBINATORS.Const(m_lexer=self.m_lexer, clsname=self.name)
    if not m_const._parse(): return 0

    for m_var in m_const.m_variables:
      name = m_var.name
      # var_dt = m_const._get_type() 
      if name not in self.consts:
        self.consts[name] = [m_const]
      else:
        self.consts[name] += [m_const]

    m_const.highlight('Error')
    #m_const.highlight('DiffAdd')

    return 1
  
  def _parse_cls_function (self):
    """def: _parse_cls_function"""
    m_cls_fun = COMBINATORS.ClassFunction(m_lexer=self.m_lexer, clsname=self.name)

    if not m_cls_fun._parse_header(): return 0

    # Extern/pure function inside class only have header
    if m_cls_fun.extern:
      if m_cls_fun.name not in self.extern_functions:
        self.extern_functions[m_cls_fun.name] = [m_cls_fun]
      else:
        self.extern_functions[m_cls_fun.name] += [m_cls_fun]
    elif m_cls_fun.pure:
      if m_cls_fun.name not in self.pure_functions:
        self.pure_functions[m_cls_fun.name] = [m_cls_fun]
      else:
        self.pure_functions[m_cls_fun.name] += [m_cls_fun]
    else:
      while not m_cls_fun._parse_footer():
        if not self.m_lexer.next_token() : return 0

      m_cls_fun.highlight('DiffAdd')

      if m_cls_fun.name not in self.functions:
        self.functions[m_cls_fun.name] = [m_cls_fun]
      else:
        self.functions[m_cls_fun.name] += [m_cls_fun]
      
    return 1

  def _parse_cls_task (self):
    """def: _parse_cls_task"""
    m_cls_task = COMBINATORS.ClassTask(m_lexer=self.m_lexer, clsname=self.name)

    if not m_cls_task._parse_header(): return 0

    # Extern/pure function inside class only have header
    if m_cls_task.extern:
      if m_cls_task.name not in self.extern_tasks:
        self.extern_tasks[m_cls_task.name] = [m_cls_task]
      else:
        self.extern_tasks[m_cls_task.name] += [m_cls_task]
      
    elif m_cls_task.pure:
      if m_cls_task.name not in self.pure_tasks:
        self.pure_tasks[m_cls_task.name] = [m_cls_task]
      else:
        self.pure_tasks[m_cls_task.name] += [m_cls_task]
    else:
      while not m_cls_task._parse_footer():
        if not self.m_lexer.next_token() : return 0

      m_cls_task.highlight('DiffAdd')

      if m_cls_task.name not in self.tasks:
        self.tasks[m_cls_task.name] = [m_cls_task]
      else:
        self.tasks[m_cls_task.name] += [m_cls_task]
      
    return 1

  def _parse_covergroup (self):
    """def: _parse_covergroup"""
    m_cg = COMBINATORS.Covergroup(m_lexer=self.m_lexer, clsname=self.name)

    if not m_cg._parse_header(): return 0

    while not m_cg._parse_footer():
      if not self.m_lexer.next_token() : return 0

    if m_cg.name not in self.covergroups:
      self.covergroups[m_cg.name] = [m_cg]
    else:
      self.covergroups[m_cg.name] += [m_cg]

    return 1
    
  def _parse (self):
    """def: _parse"""
    if not super(Interface, self)._parse_header(): return 0

    while not super(Interface, self)._parse_footer():
      #self.m_lexer.highlight_token()

      m_comments = COMBINATORS.Comments(m_lexer=self.m_lexer)
      if m_comments(): continue

      if self._parse_cls_function(): continue
      if self._parse_cls_task(): continue
      if self._parse_typedef(): continue
      if self._parse_parameter(): continue
      if self._parse_const(): continue
      if self._parse_cls_property(): continue
      if self._parse_covergroup(): continue

      #if self.m_lexer.is_done(): return 0 # Check if all lines parsed
      if not self.m_lexer.next_token() : return 0

    return 1
      
if __name__ == "__main__":
  m_logger = LOGGER.Logger()
  m_logger.debug_mode(1)

  m_lexer = LEXER.Lexer()
  m_lexer.next_token()

  while 1:
    
    m_comments = COMBINATORS.Comments(m_lexer=m_lexer)
    if m_comments():
      m_comments.highlight('DiffAdd')
      continue

    m_class = Class(m_lexer=m_lexer)
    if m_class._parse():
      m_class.highlight('DiffAdd')
      continue

    m_intf = Interface(m_lexer=m_lexer)
    if m_intf._parse():
      m_intf.highlight('DiffAdd')
      continue

    if not m_lexer.next_token(): break





  




