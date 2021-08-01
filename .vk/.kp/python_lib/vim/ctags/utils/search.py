#!/usr/bin/env python

import vim
from utils import combinators
from utils.token import Token
import re

class SearchBase(object):
  """class: SearchBase"""

  escape_re = re.compile(r'([\\/])') # characters to escape
  space_re = re.compile(r'\s+')
  indent_re = re.compile(r'^\s+')

  def __init__(self):
    self.m_token = None
    self.window = vim.current.window
    self.buffer = vim.current.buffer

  def _get_cmd (self, start, end):
    """def: _get_cmd"""

    lines = vim.eval('getline({start},{end})'.format(start=start, end=end))
    lines = [SearchBase.escape_re.sub(r'\\\1', line) for line in lines]

    # Used all the lines in regex used for search tag
    cmd = '{text}'.format(text='\\n\\+'.join(lines))

    # || # only used start and end line in regex used for searching tag
    # || if len(lines) == 1:
    # ||   cmd = lines[0]
    # || else:
    # ||   cmd = '{startline}\(\({startline}\)\@!\_.\)\{{-\}}{endline}'.format(startline=lines[0],endline=lines[-1])

    cmd = SearchBase.indent_re.sub('\\s\\+', cmd)
    cmd = SearchBase.space_re.sub('\\_s\\+', cmd)
    # NOTE: tag was not properly generated for `/*local*/ extern function void Xadd_vregX(uvm_vreg vreg);`
    #       since /*local*/ is the comment and was removed by this script so currently the script is not
    #       generating proper tag for those kind of code. Removed `^` and `$` from the tag command
    #       as a workaround
    #cmd = '/^{text}$/;"'.format(text=cmd) 
    cmd = '/{text}/;"'.format(text=cmd) 

    return cmd
    
class ClassVars(SearchBase):
  """class: ClassVars"""

  regex_vi = r'\v^\s*%(<virtual>\_s*)?<class>'
  kind = 'clsvar'

  def __init__(self):
    super(ClassVars, self).__init__()
    self.m_tokens = []

  def search_next (self):
    """def: search_next"""
    ln = int(vim.eval("search('{regex}', 'W')".format(regex=ClassVars.regex_vi)))

    if ln != 0:
      self.m_tokens = [] # initialization

      # Skip macros (macros ends with \)
      if self.buffer[ln - 1][-1] == '\\':
        return 1
      
      m_cls_ast = combinators.TagClassAST()

      if m_cls_ast._parse():
        for name, list_m_clsvars in m_cls_ast.properties.iteritems():
          for m_clsvars in list_m_clsvars:
            cmd = self._get_cmd(m_clsvars.start[0], m_clsvars.end[0])
            filename = vim.eval('expand("%:p")')

            kwargs = {'class': m_cls_ast.name}
            m_token = Token(('Ctags'), name, cmd, self.__class__.kind, filename, **kwargs)
            self.m_tokens.append(m_token)
      return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      for m_token in self.m_tokens:
        yield m_token 
    
class Class(SearchBase):
  """class: Class"""

  regex = r'\v^\s*%(<virtual>\_s*)?<class>'
  kind = 'class'

  def __init__(self):
    super(Class, self).__init__()
    self.m_param_datatype = None

  def search_next (self):
    """def: search_next"""
    ln = int(vim.eval("search('{regex}', 'W')".format(regex=Class.regex)))

    if ln != 0:
      # Skip macros (macros ends with \)
      if self.buffer[ln - 1][-1] == '\\':
        return 1

      m_class = combinators.TagClass()

      if m_class._parse_header():
        # m_class.highlight('DiffAdd')

        cmd = self._get_cmd(m_class.start[0], m_class.end[0])
        filename = vim.eval('expand("%:p")')

        self.m_token = Token(('Ctags', 'UserDT', 'ClassTreeTags'), m_class.name, cmd, self.__class__.kind, filename, extends=m_class.extends)

        # Note: For parameterised class 
        # `class #(type REQ,RSP) driver;`
        #        Here REQ is the valid datatype for the class and can be used as a placeholder
        #        for a datatype. So this needs to be added in the list of userdatatypes
        if m_class.m_parameters:
          self.m_param_datatype = m_class.m_parameters

        else:
          self.m_param_datatype = None

        return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      yield self.m_token 

      # yield the parameter datatypes so that it can be added in the list of datatypes
      if self.m_param_datatype:
        for m_param in self.m_param_datatype.m_parameters:

          # Only add userdt token for parameters like `class #(type REQ,RSP) driver;`
          if m_param.datatype == 'type':
            kind ='type' 
            # Note: This is not a tag token. So `cmd`, `filename` fields are not required
            m_token = Token(('UserDT'), m_param.name, None, kind, None)
            yield m_token

          # Add tags for formal class parameters
          cmd = self._get_cmd(m_param.start[0], m_param.end[0])
          filename = vim.eval('expand("%:p")')
          m_token = Token(('Ctags'), m_param.name, cmd, 'fclsparam', filename)
          yield m_token
          
    

class MethodBase(SearchBase):
  """class: MethodBase"""

  def __init__(self):
    super(MethodBase, self).__init__()
    # class_start_re = r'\v<class>\_s+\zs(<\w+>)'
    self.class_start_re = r'\v^\s*%(<virtual>\_s+)?<class>\_s+\zs(<\w+>)'
    self.class_end_re = r'\v^\s*<endclass>'

  def _get_current_class (self):
    """def: _get_current_class"""
    start_re = self.class_start_re
    end_re = self.class_end_re
    cursor_save = self.window.cursor
    ln = vim.eval("searchpair('{start}', '', '{end}', 'Wb')".format(start=start_re, end=end_re))
    ln = int(ln)

    if ln:
      classname = vim.eval('expand("<cword>")')
      self.window.cursor = cursor_save
      return classname
      
    # | SLOW | m_class = next((m_cls for m_cls in self.m_class.m_classes if m_cls.start[0] == ln), None)
    # | if ln:
    # |   m_class = combinators.TagClass()
    # |   if m_class:
    # |     return m_class.name

    return None

  def _get_other_info (self, m_method):
    """def: _get_other_info"""
    cls_name = None
    is_extern = None
    is_def = None
    is_imp = None
    if m_method.parent_class:
      cls_name = m_method.parent_class
      is_extern = 1
      is_imp = 1
    else:
      cls_name = self._get_current_class ()
      is_extern = m_method.extern
      if is_extern:
        is_def = 1

    return cls_name, is_extern, is_def, is_imp
    
class Function(MethodBase):
  """class: Function"""

  regex = r'\v^\s*%(<%(pure|extern|static|virtual|local|protected)>\_s*)*<function>'
  #regex = r'\v^\s*%(<extern>\_s*)?%(<static>\_s*)?%(<virtual>\_s*)?<function>'
  kind = 'function'

  def __init__(self):
    super(Function, self).__init__()

  def search_next (self):
    ln = int(vim.eval("search('{regex}', 'W')".format(regex=Function.regex)))

    if ln != 0:
      # Skip macros (macros ends with \)
      if self.buffer[ln - 1][-1] == '\\':
        return 1

      m_fun = combinators.TagFunction()

      if m_fun():
        # m_fun.highlight('DiffAdd')

        cmd = self._get_cmd(m_fun.start[0], m_fun.end[0])
        filename = vim.eval('expand("%:p")')

        cls_name, is_extern, is_def, is_imp = self._get_other_info(m_fun)
          
        kwargs = {'class': cls_name, 'is_extern': is_extern, 'is_imp': is_imp, 'is_def': is_def}
        self.m_token = Token(('Ctags'), m_fun.name, cmd, self.__class__.kind, filename, **kwargs)

        return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      yield self.m_token 
    
class Task(MethodBase):
  """class: Task"""

  regex = r'\v^\s*%(<%(pure|extern|static|virtual|local|protected)>\_s*)*<task>'
  #regex = r'\v^\s*%(<extern>\_s*)?%(<static>\_s*)?%(<virtual>\_s*)?<task>'
  kind = 'task'

  def __init__(self):
    super(Task, self).__init__()

  def search_next (self):
    ln = int(vim.eval("search('{regex}', 'W')".format(regex=Task.regex)))

    if ln != 0:
      # Skip macros (macros ends with \)
      if self.buffer[ln - 1][-1] == '\\':
        return 1

      m_task = combinators.TagTask()

      if m_task():
        # m_task.highlight('DiffAdd')

        cmd = self._get_cmd(m_task.start[0], m_task.end[0])
        filename = vim.eval('expand("%:p")')

        cls_name, is_extern, is_def, is_imp = self._get_other_info(m_task)
          
        kwargs = {'class': cls_name, 'is_extern': is_extern, 'is_imp': is_imp, 'is_def': is_def}
        self.m_token = Token(('Ctags'), m_task.name, cmd, self.__class__.kind, filename, **kwargs)

        return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      yield self.m_token 
    
class Macro(SearchBase):
  """class: Macro"""

  regex_vi = r'\v^\s*%(`define>\_s*)'
  regex = re.compile(r'`define\s+(\w+)')
  kind = 'macro'

  def __init__(self):
    super(Macro, self).__init__()

  def search_next (self):
    """def: search_next"""
    ln = int(vim.eval("search('{regex}', 'W')".format(regex=Macro.regex_vi)))

    if ln != 0:

      line_str = self.buffer[ln - 1]
      m_match = Macro.regex.search(line_str)
      name = m_match.group(1)
      name = '`{0}'.format(name)

      # || name = vim.eval('matchstr({line}, \'\\v`define \zs\w+\')')

      cmd = self._get_cmd(ln, ln)
      filename = vim.eval('expand("%:p")')
      self.m_token = Token(('Ctags'), name, cmd, self.__class__.kind, filename)

      return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      yield self.m_token 
    
class Interface(SearchBase):
  """class: Interface"""

  regex_vi = r'\v^\s*<interface>'
  regex = re.compile(r'^\s*interface\s+(?:automatic\s+)?(\w+)')
  kind = 'interface'

  def __init__(self):
    super(Interface, self).__init__()

  def search_next (self):
    """def: search_next"""
    ln = int(vim.eval("search('{regex}', 'W')".format(regex=Interface.regex_vi)))

    if ln != 0:

      line_str = self.buffer[ln - 1]
      m_match = Interface.regex.search(line_str)
      name = m_match.group(1)

      cmd = self._get_cmd(ln, ln)
      filename = vim.eval('expand("%:p")')
      self.m_token = Token(('Ctags', 'UserDT'), name, cmd, self.__class__.kind, filename)

      return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      yield self.m_token 
    
class Module(SearchBase):
  """class: Module"""

  regex_vi = r'\v^\s*<module>'
  regex = re.compile(r'^\s*module\s+(?:automatic\s+)?(\w+)')
  kind = 'module'

  def __init__(self):
    super(Module, self).__init__()

  def search_next (self):
    """def: search_next"""
    ln = int(vim.eval("search('{regex}', 'W')".format(regex=Module.regex_vi)))

    if ln != 0:

      line_str = self.buffer[ln - 1]
      m_match = Module.regex.search(line_str)
      name = m_match.group(1)

      cmd = self._get_cmd(ln, ln)
      filename = vim.eval('expand("%:p")')
      self.m_token = Token(('Ctags'), name, cmd, self.__class__.kind, filename)

      return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      yield self.m_token 
    
class Package(SearchBase):
  """class: Package"""

  regex_vi = r'\v^\s*<package>'
  regex = re.compile(r'^\s*package\s+(\w+)')
  kind = 'package'

  def __init__(self):
    super(Package, self).__init__()

  def search_next (self):
    """def: search_next"""
    ln = int(vim.eval("search('{regex}', 'W')".format(regex=Package.regex_vi)))

    if ln != 0:

      line_str = self.buffer[ln - 1]
      m_match = Package.regex.search(line_str)
      name = m_match.group(1)

      cmd = self._get_cmd(ln, ln)
      filename = vim.eval('expand("%:p")')
      self.m_token = Token(('Ctags'), name, cmd, self.__class__.kind, filename)

      return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      yield self.m_token 
    
class Typedef(SearchBase):
  """class: Typedef"""

  regex_vi = r'\v^\s*<typedef>'
  regex = None
  kind = 'typedef'

  def __init__(self):
    super(Typedef, self).__init__()

  def search_next (self):
    """def: search_next"""
    ln = int(vim.eval("search('{regex}', 'W')".format(regex=Typedef.regex_vi)))

    if ln != 0:

      m_typedef = combinators.TagTypedef()

      if m_typedef():
        cmd = self._get_cmd(m_typedef.start[0], m_typedef.end[0])
        name = m_typedef.name

        filename = vim.eval('expand("%:p")')
        self.m_token = Token(('Ctags', 'UserDT'), name, cmd, self.__class__.kind, filename)

        return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      yield self.m_token 
    
#-------------------------------------------------------------------------------
# Generate Tag For Enum Values:
#   `typedef enum {ONE, TWO} number_t;` or
#   `enum bit {OPEN, CLOSE} status;`
#       Tag will be generated for ONE, TWO, OPEN, CLOSE etc...
#-------------------------------------------------------------------------------
class EnumVal(SearchBase):
  """class: EnumVal"""

  regex_vi = r'\v(^\s*typedef\s*)?\zs<enum>'
  regex = None
  kind = 'enumvalue'

  def __init__(self):
    super(EnumVal, self).__init__()
    self.m_tokens = []

  def search_next (self):
    """def: search_next"""
    ln = int(vim.eval("search('{regex}', 'W')".format(regex=EnumVal.regex_vi)))

    if ln != 0:

      self.m_tokens = [] # initialization
      m_enumvals = combinators.TagEnumVal()

      if m_enumvals():
        if not m_enumvals.tokens: return 0
          
        for enumtoken in m_enumvals.tokens:

          cmd = self._get_cmd(enumtoken['start'][0], m_enumvals.end[0])
          name = enumtoken['value']

          filename = vim.eval('expand("%:p")')
          m_token = Token(('Ctags'), name, cmd, self.__class__.kind, filename)
          self.m_tokens.append(m_token)

        return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      for m_token in self.m_tokens:
        yield m_token 
    
class Const(SearchBase):
  """class: Const"""

  regex_vi = r'\v^\s*%(const>\_s*)'
  kind = 'const'

  def __init__(self):
    super(Const, self).__init__()
    self.m_tokens = []

  def search_next (self):
    """def: search_next"""
    ln = int(vim.eval("search('{regex}', 'W')".format(regex=Const.regex_vi)))

    if ln != 0:
      self.m_tokens = [] # initialization

      # Skip macros (macros ends with \)
      if self.buffer[ln - 1][-1] == '\\':
        return 1

      m_const = combinators.TagConst()

      if m_const._parse():
        # m_const.highlight('DiffAdd')

        cmd = self._get_cmd(m_const.start[0], m_const.end[0])
        filename = vim.eval('expand("%:p")')

        for m_var in m_const.m_variables:
          m_token = Token(('Ctags'), m_var.name, cmd, self.__class__.kind, filename)
          self.m_tokens.append(m_token)

      return 1

    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      for m_token in self.m_tokens:
        yield m_token 

class Parameter(SearchBase):
  """class: Parameter"""

  regex_vi = r'\v^\s*%(parameter>\_s*)'
  kind = 'parameter'

  def __init__(self):
    super(Parameter, self).__init__()
    self.m_tokens = []

  def search_next (self):
    """def: search_next"""
    ln = int(vim.eval("search('{regex}', 'W')".format(regex=Parameter.regex_vi)))

    if ln != 0:
      self.m_tokens = [] # initialization

      # Skip macros (macros ends with \)
      if self.buffer[ln - 1][-1] == '\\':
        return 1

      m_parameter = combinators.TagParameter()

      if m_parameter._parse():
        # m_parameter.highlight('DiffAdd')

        cmd = self._get_cmd(m_parameter.start[0], m_parameter.end[0])
        filename = vim.eval('expand("%:p")')

        for m_var in m_parameter.m_variables:
          m_token = Token(('Ctags'), m_var.name, cmd, self.__class__.kind, filename)
          self.m_tokens.append(m_token)

      return 1

    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      for m_token in self.m_tokens:
        yield m_token 

#-------------------------------------------------------------------------------
# Main Function
#-------------------------------------------------------------------------------
def pre_search ():
  start_line_cmt_re = '^\s*//'
  # NOTE: tag was not properly generated for `/*local*/ extern function void Xadd_vregX(uvm_vreg vreg);`
  #       since /*local*/ is the comment and was removed by this script so currently the script is not
  #       generating proper tag for those kind of code. Maybe need to remove only block comment at start and end of line
  block_cmt_re = r'\v\/\*\_.{-}\*\/' 
  # NOTE: Below is the regex for block comments only matches at start and end of line
  # block_cmt_re = r'\v^\s*\/\*%(%(\*\/)@!\_.){-}\*\/\s*$' 

  # Add empty line at start. This will avoid not matching the search pattern at first line
  vim.command('silent! call append(0, "")')

  vim.command('silent! %s!{search}!!ge'.format(search=block_cmt_re))
  vim.command('silent! g~{search}~d'.format(search=start_line_cmt_re))
  # line comment for `code statement; //comment`
  vim.command('silent! %s~//.*~~g')

  # Delete forward declaration of class --> ( typedef class abc; or typedef abc; )
  vim.command('silent! g~{search}~d'.format(search='\\v^\s*<typedef>\_s+<class>\_s+<\w+>\_s*;'))
  vim.command('silent! g~{search}~d'.format(search='\\v^\s*<typedef>\_s+<\w+>\_s*;'))

  # Redirect vim errors to stdout
  vim.command('redir>>/dev/stdout')

def post_search ():
  vim.command('redir END')
      
  # Restore comments
  vim.command('let @/ = ""')
  vim.command('silent edit!')

# Process typedef before all the tags to gather all the userdatatypes
# Fix: it will fix parser for `class X (user_type_t Y)` like code
def search_typedef_tags ():
  m_searches = [Interface(), Typedef()]
  
  pre_search()
  for m_search in m_searches:
    for m_token in m_search():
      yield m_token
  post_search()

# Process class before all other tags to gather all the userdatatype
def search_class_tags ():
  m_search = Class()
  
  pre_search()
  for m_token in m_search():
    yield m_token
  post_search()

def search_tags ():
  #m_search_all = [Typedef(), Class(), Function(), Task(), Parameter(), Const(), Macro(), Interface(), Module(), Package(), EnumVal()]
  #m_search_all = [Function(), Task(), Parameter(), Const(), Macro(), Interface(), Module(), Package(), EnumVal()]
  m_search_all = [Function(), Task(), Parameter(), Const(), Macro(), Module(), Package(), EnumVal(), ClassVars()]

  pre_search()
  for m_search in m_search_all:
    for m_token in m_search():
      yield m_token
  post_search()










