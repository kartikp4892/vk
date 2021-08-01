#!/usr/bin/env python

import os
import imp
import re

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

combinator_path = '{kp_vim_home}/python_lib/shell/uvm/ctags/utils/combinators.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
COMBINATORS = import_(combinator_path)

autocombinator_path = '{kp_vim_home}/python_lib/shell/uvm/ctags/utils/auto_combinators.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
AUTO_COMBINATORS = import_(autocombinator_path)

lexer_path = '{kp_vim_home}/python_lib/vim/lib/sv/base/lexer/Lexer.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
LEXER = import_(lexer_path)

token_path = '{kp_vim_home}/python_lib/vim/ctags/utils/token.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
TOKEN = import_(token_path)

class SearchBase(object):
  """class: SearchBase"""

  escape_re = re.compile(r'([\\/])') # characters to escape
  space_re = re.compile(r'\s+')
  indent_re = re.compile(r'^\s+')

  def __init__(self, **kwargs):
    self.m_tokens = []
    self.m_lexer = kwargs['m_lexer']

  def _get_cmd (self, start, end):
    """def: _get_cmd"""

    lines = self.m_lexer.buffer[start - 1: end + 1]
    lines = [SearchBase.escape_re.sub(r'\\\1', line) for line in lines]

    # Used all the lines in regex used for search tag
    # || cmd = '{text}'.format(text='\\n\\+'.join(lines))

    # only used start and end line in regex used for searching tag
    if len(lines) == 1:
      cmd = lines[0]
    else:
      cmd = '{startline}\(\({startline}\)\@!\_.\)\{{-\}}{endline}'.format(startline=lines[0],endline=lines[-1])

    cmd = SearchBase.indent_re.sub('\\s\\+', cmd)
    cmd = SearchBase.space_re.sub('\\_s\\+', cmd)
    # NOTE: tag was not properly generated for `/*local*/ extern function void Xadd_vregX(uvm_vreg vreg);`
    #       since /*local*/ is the comment and was removed by this script so currently the script is not
    #       generating proper tag for those kind of code. Removed `^` and `$` from the tag command
    #       as a workaround
    #cmd = '/^{text}$/;"'.format(text=cmd) 
    cmd = '/{text}/;"'.format(text=cmd) 

    return cmd
    
  def tokens (self):
    """def: tokens
            Returns all list of tokens found in previous call of search_next
    """
    for m_token in self.m_tokens:
      yield m_token

class uvm_analysis_imp_decl(SearchBase):
  """class: uvm_analysis_imp_decl"""

  kind = 'class'

  def __init__(self, **kwargs):
    super(uvm_analysis_imp_decl, self).__init__(**kwargs)

  def search_next (self):
    m_uvm_analysis_imp_decl = COMBINATORS.Taguvm_analysis_imp_decl(m_lexer=self.m_lexer)

    if m_uvm_analysis_imp_decl():
      cmd = self._get_cmd(m_uvm_analysis_imp_decl.start[0], m_uvm_analysis_imp_decl.end[0])
      name = m_uvm_analysis_imp_decl.name

      filename = self.m_lexer.fname
      m_token = TOKEN.Token(('Ctags', 'UserDT'), name, cmd, self.__class__.kind, filename)
      self.m_tokens = [m_token]

      return 1
    return 0

class Typedef(SearchBase):
  """class: Typedef"""

  kind = 'typedef'

  def __init__(self, **kwargs):
    super(Typedef, self).__init__(**kwargs)

  def search_next (self):
    m_typedef = COMBINATORS.TagTypedef(m_lexer=self.m_lexer)

    if m_typedef():
      cmd = self._get_cmd(m_typedef.start[0], m_typedef.end[0])
      name = m_typedef.name

      filename = self.m_lexer.fname
      m_token = TOKEN.Token(('Ctags', 'UserDT'), name, cmd, self.__class__.kind, filename)
      self.m_tokens = [m_token]

      return 1
    return 0

class Class(SearchBase):
  """class: Class"""

  kind = 'class'

  def __init__(self, **kwargs):
    super(Class, self).__init__(**kwargs)

  def search_next (self):
    m_cls = COMBINATORS.TagClass(m_lexer=self.m_lexer)

    if m_cls():
      cmd = self._get_cmd(m_cls.start[0], m_cls.end[0])
      name = m_cls.name

      filename = self.m_lexer.fname
      m_token = TOKEN.Token(('Ctags', 'UserDT', 'ClassTreeTags'), name, cmd, self.__class__.kind, filename, extends=m_cls.extends)
      self.m_tokens = [m_token]

      #-------------------------------------------------------------------------------
      # Auto Tags (Atags)
      # Tag #extends#<class_name>
      # This is the tag where child of the class is defined.
      tagname = '#{0}#{1}'.format('extends', m_cls.extends)
      m_token = TOKEN.Token(('Atags'), tagname, cmd, 'class_extends', filename)
      self.m_tokens.append(m_token)
      #-------------------------------------------------------------------------------

      for m_fclsparam in m_cls.m_fclsparams:
        if m_fclsparam.datatype == 'type': # parameterized data types are local to the class
          name = m_fclsparam.name
          m_token = TOKEN.Token(('UserDT'), name, None, 'fclsparam', filename, clsname=m_cls.name)
          self.m_tokens.append(m_token)
        
        # Note: Don't add tokens that don't contain UserDT tag in this class.. This class is parsed at first to collect datatypes
        #       If token that don't contain UserDT is detected.. The datatype parsing will be done and datatype file will be created...
        #       leaving rest of the datatype not to be included in the list
      return 1
    return 0

class Parameter(SearchBase):
  """class: Parameter"""

  regex_vi = r'\v^\s*%(parameter>\_s*)'
  kind = 'parameter'

  def __init__(self, **kwargs):
    super(Parameter, self).__init__(**kwargs)

  def search_next (self):
    """def: search_next"""

    m_parameter = COMBINATORS.TagParameter(m_lexer=self.m_lexer)

    if m_parameter._parse():
      self.m_tokens = [] # initialization

      # m_parameter.highlight('DiffAdd')

      cmd = self._get_cmd(m_parameter.start[0], m_parameter.end[0])
      filename = self.m_lexer.fname

      for m_var in m_parameter.m_variables:
        m_token = TOKEN.Token(('Ctags'), m_var.name, cmd, self.__class__.kind, filename)
        self.m_tokens.append(m_token)

      return 1

    return 0

class Const(SearchBase):
  """class: Const"""

  kind = 'const'

  def __init__(self, **kwargs):
    super(Const, self).__init__(**kwargs)

  def search_next (self):
    """def: search_next"""

    m_const = COMBINATORS.TagConst(m_lexer=self.m_lexer)

    if m_const._parse():
      self.m_tokens = [] # initialization
      # m_const.highlight('DiffAdd')

      cmd = self._get_cmd(m_const.start[0], m_const.end[0])
      filename = self.m_lexer.fname

      for m_var in m_const.m_variables:
        m_token = TOKEN.Token(('Ctags'), m_var.name, cmd, self.__class__.kind, filename)
        self.m_tokens.append(m_token)

      return 1

    return 0

#-------------------------------------------------------------------------------
# Generate Tag For Enum Values:
#   `typedef enum {ONE, TWO} number_t;` or
#   `enum bit {OPEN, CLOSE} status;`
#       Tag will be generated for ONE, TWO, OPEN, CLOSE etc...
#-------------------------------------------------------------------------------
class EnumVal(SearchBase):
  """class: EnumVal"""

  kind = 'enumvalue'

  def __init__(self, **kwargs):
    super(EnumVal, self).__init__(**kwargs)
    self.m_tokens = []

  def search_next (self):
    """def: search_next"""
    m_enumvals = COMBINATORS.TagEnumVal(m_lexer=self.m_lexer)

    if m_enumvals():
      self.m_tokens = [] # initialization
      if not m_enumvals.tokens: return 0
        
      filename = self.m_lexer.fname

      # Add enum values to token list
      for enumtoken in m_enumvals.tokens:

        cmd = self._get_cmd(enumtoken['start'][0], m_enumvals.end[0])
        name = enumtoken['value']

        m_token = TOKEN.Token(('Ctags'), name, cmd, self.__class__.kind, filename)
        self.m_tokens.append(m_token)

      # Add enum variable name to token list
      if m_enumvals.enum_var:
        cmd = self._get_cmd(m_enumvals.start[0], m_enumvals.end[0])
        name = m_enumvals.enum_var
        m_token = TOKEN.Token(('Ctags'), name, cmd, 'var', filename)
        self.m_tokens.append(m_token)
        
      return 1
    return 0

class MethodBase(SearchBase):
  """class: MethodBase"""

  def __init__(self, **kwargs):
    super(MethodBase, self).__init__(**kwargs)
    # class_start_re = r'\v<class>\_s+\zs(<\w+>)'
    self.class_start_re = r'\v^\s*%(<virtual>\_s+)?<class>\_s+\zs(<\w+>)'
    self.class_end_re = r'\v^\s*<endclass>'

  def _get_other_info (self, m_method):
    """def: _get_other_info"""
    cls_name = None
    is_extern = None
    is_def = None
    is_imp = None
    if m_method.clsname:
      cls_name = m_method.clsname
      is_extern = 1
      is_imp = 1

    return cls_name, is_extern, is_def, is_imp
    
class Function(MethodBase):
  """class: Function"""

  kind = 'function'

  def __init__(self, **kwargs):
    super(Function, self).__init__(**kwargs)

  def search_next (self):
    m_fun = COMBINATORS.TagFunction(m_lexer=self.m_lexer)

    if m_fun():
      # m_fun.highlight('DiffAdd')

      cmd = self._get_cmd(m_fun.start[0], m_fun.end[0])
      filename = self.m_lexer.fname

      cls_name, is_extern, is_def, is_imp = self._get_other_info(m_fun)
        
      kwargs = {'class': cls_name, 'is_extern': is_extern, 'is_imp': is_imp, 'is_def': is_def}
      m_token = TOKEN.Token(('Ctags'), m_fun.name, cmd, self.__class__.kind, filename, **kwargs)
      self.m_tokens = [m_token]

      return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      yield self.m_token 
    
class Task(MethodBase):
  """class: Task"""

  kind = 'task'

  def __init__(self, **kwargs):
    super(Task, self).__init__(**kwargs)

  def search_next (self):
    m_task = COMBINATORS.TagTask(m_lexer=self.m_lexer)

    if m_task():
      # m_task.highlight('DiffAdd')

      cmd = self._get_cmd(m_task.start[0], m_task.end[0])
      filename = self.m_lexer.fname

      cls_name, is_extern, is_def, is_imp = self._get_other_info(m_task)
        
      kwargs = {'class': cls_name, 'is_extern': is_extern, 'is_imp': is_imp, 'is_def': is_def}
      m_token = TOKEN.Token(('Ctags'), m_task.name, cmd, self.__class__.kind, filename, **kwargs)
      self.m_tokens = [m_token]

      return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    self.window.cursor = (1,1)
    while self.search_next():
      yield self.m_token 
    
class Macro(SearchBase):
  """class: Macro"""

  kind = 'macro'

  def __init__(self, **kwargs):
    super(Macro, self).__init__(**kwargs)

  def search_next (self):
    """def: search_next"""
    m_macro = COMBINATORS.TagMacro(m_lexer=self.m_lexer)

    if m_macro():
      # m_macro.highlight('DiffAdd')

      name = m_macro.name
      name = '`{0}'.format(name)

      # || name = vim.eval('matchstr({line}, \'\\v`define \zs\w+\')')

      cmd = self._get_cmd(m_macro.start[0], m_macro.start[0])
      filename = self.m_lexer.fname
      m_token = TOKEN.Token(('Ctags'), name, cmd, self.__class__.kind, filename)
      self.m_tokens = [m_token]

      return 1
    return 0

class ClassAST(SearchBase):
  """class: ClassAST"""

  kind = 'clsvar'

  def __init__(self, **kwargs):
    super(ClassAST, self).__init__(**kwargs)
    self.m_tokens = []

  def search_next (self):
    """def: search_next"""
    self.m_tokens = [] # initialization

    m_cls_ast = COMBINATORS.TagClassAST(m_lexer=self.m_lexer)

    filename = self.m_lexer.fname
    if m_cls_ast._parse():
      # Class properties
      for name, list_m_clsvars in m_cls_ast.properties.iteritems():
        for m_clsvars in list_m_clsvars:
          cmd = self._get_cmd(m_clsvars.start[0], m_clsvars.end[0])

          kwargs = {'class': m_cls_ast.name}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'clsvar', filename, **kwargs)
          self.m_tokens.append(m_token)

          # Auto Tags (Atags)
          # Tag #handle#<class_name>
          # This is the tag where handle of the class is declared.
          cls_datatype = m_clsvars._get_type();
          tagname = '#{0}#{1}'.format('handle', cls_datatype)
          m_token = TOKEN.Token(('Atags'), tagname, cmd, 'class_inst', filename, **kwargs)
          self.m_tokens.append(m_token)

      # Class typedefs
      # Note: Tags for typedefs are generated in Typedef class. This logic only implements autotag (Atags) part.
      for name, list_m_typedef in m_cls_ast.typedefs.iteritems():
        for m_typedef in list_m_typedef:
          cmd = self._get_cmd(m_typedef.start[0], m_typedef.end[0])
          kwargs = {'class': m_cls_ast.name}

          # Auto Tags (Atags)
          # Tag #handle#<class_name>
          # This is the tag where handle of the class is declared.
          cls_datatype = m_typedef._get_type();
          tagname = '#{0}#{1}'.format('handle', cls_datatype)
          m_token = TOKEN.Token(('Atags'), tagname, cmd, 'class_typedef', filename, **kwargs)
          self.m_tokens.append(m_token)

      # Class parameters
      for name, m_list in m_cls_ast.parameters.iteritems():
        for m_parameter in m_list:
          cmd = self._get_cmd(m_parameter.start[0], m_parameter.end[0])

          kwargs = {'class': m_cls_ast.name}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'parameter', filename, **kwargs) # TODO : tag == clsparameter???
          self.m_tokens.append(m_token)

      # Class consts
      for name, m_list in m_cls_ast.consts.iteritems():
        for m_const in m_list:
          cmd = self._get_cmd(m_const.start[0], m_const.end[0])

          kwargs = {'class': m_cls_ast.name}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'const', filename, **kwargs) # TODO : tag == clsconst???
          self.m_tokens.append(m_token)

      # Class Function
      for name, m_list in m_cls_ast.functions.iteritems():
        for m_fun in m_list:
          cmd = self._get_cmd(m_fun.start[0], m_fun.end[0])
          kwargs = {'class': m_cls_ast.name}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'clsfun', filename, **kwargs)
          self.m_tokens.append(m_token)
        
      # Class Task
      for name, m_list in m_cls_ast.tasks.iteritems():
        for m_task in m_list:
          cmd = self._get_cmd(m_task.start[0], m_task.end[0])
          kwargs = {'class': m_cls_ast.name}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'clstask', filename, **kwargs)
          self.m_tokens.append(m_token)
        
      # Class Extern Function
      for name, m_list in m_cls_ast.extern_functions.iteritems():
        for m_fun in m_list:
          cmd = self._get_cmd(m_fun.start[0], m_fun.end[0])
          kwargs = {'class': m_cls_ast.name, 'is_extern': 1, 'is_imp': 0, 'is_def': 1}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'clsfun', filename, **kwargs)
          self.m_tokens.append(m_token)
        
      # Class Extern Task
      for name, m_list in m_cls_ast.extern_tasks.iteritems():
        for m_task in m_list:
          cmd = self._get_cmd(m_task.start[0], m_task.end[0])
          kwargs = {'class': m_cls_ast.name, 'is_extern': 1, 'is_imp': 0, 'is_def': 1}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'clstask', filename, **kwargs)
          self.m_tokens.append(m_token)
        
      # Class pure Function
      for name, m_list in m_cls_ast.pure_functions.iteritems():
        for m_fun in m_list:
          cmd = self._get_cmd(m_fun.start[0], m_fun.end[0])
          kwargs = {'class': m_cls_ast.name, 'is_pure': 1, 'is_imp': 0, 'is_def': 1}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'clsfun', filename, **kwargs)
          self.m_tokens.append(m_token)
        
      # Class pure Task
      for name, m_list in m_cls_ast.pure_tasks.iteritems():
        for m_task in m_list:
          cmd = self._get_cmd(m_task.start[0], m_task.end[0])
          kwargs = {'class': m_cls_ast.name, 'is_pure': 1, 'is_imp': 0, 'is_def': 1}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'clstask', filename, **kwargs)
          self.m_tokens.append(m_token)
        
      if m_cls_ast.m_fclsparams:
        for m_fclsparam in m_cls_ast.m_fclsparams.m_parameters:
          # Add tags for formal class parameters
          cmd = self._get_cmd(m_fclsparam.start[0], m_fclsparam.end[0])
          m_token = TOKEN.Token(('Ctags'), m_fclsparam.name, cmd, 'fclsparam', filename)
          self.m_tokens.append(m_token)

      return 1
    return 0

class InterfaceAST(SearchBase):
  """class: InterfaceAST"""

  kind = 'intfvar'

  def __init__(self, **kwargs):
    super(InterfaceAST, self).__init__(**kwargs)
    self.m_tokens = []

  def search_next (self):
    """def: search_next"""
    self.m_tokens = [] # initialization

    m_intf_ast = COMBINATORS.TagInterfaceAST(m_lexer=self.m_lexer)

    filename = self.m_lexer.fname
    if m_intf_ast._parse():
      # Class properties
      for name, list_m_intfvars in m_intf_ast.properties.iteritems():
        for m_intfvars in list_m_intfvars:
          cmd = self._get_cmd(m_intfvars.start[0], m_intfvars.end[0])

          kwargs = {'interface': m_intf_ast.name}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'intfvar', filename, **kwargs)
          self.m_tokens.append(m_token)

          # Auto Tags (Atags)
          # Tag #handle#<class_name>
          # This is the tag where handle of the class is declared.
          intf_datatype = m_intfvars._get_type();
          tagname = '#{0}#{1}'.format('handle', intf_datatype)
          m_token = TOKEN.Token(('Atags'), tagname, cmd, 'class_inst', filename, **kwargs)
          self.m_tokens.append(m_token)

      # Class typedefs
      # Note: Tags for typedefs are generated in Typedef class. This logic only implements autotag (Atags) part.
      for name, list_m_typedef in m_intf_ast.typedefs.iteritems():
        for m_typedef in list_m_typedef:
          cmd = self._get_cmd(m_typedef.start[0], m_typedef.end[0])
          kwargs = {'interface': m_intf_ast.name}

          # Auto Tags (Atags)
          # Tag #handle#<class_name>
          # This is the tag where handle of the class is declared.
          intf_datatype = m_typedef._get_type();
          tagname = '#{0}#{1}'.format('handle', intf_datatype)
          m_token = TOKEN.Token(('Atags'), tagname, cmd, 'class_typedef', filename, **kwargs)
          self.m_tokens.append(m_token)

      # Class parameters
      for name, m_list in m_intf_ast.parameters.iteritems():
        for m_parameter in m_list:
          cmd = self._get_cmd(m_parameter.start[0], m_parameter.end[0])

          kwargs = {'interface': m_intf_ast.name}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'parameter', filename, **kwargs) # TODO : tag == intfparameter???
          self.m_tokens.append(m_token)

      # Class consts
      for name, m_list in m_intf_ast.consts.iteritems():
        for m_const in m_list:
          cmd = self._get_cmd(m_const.start[0], m_const.end[0])

          kwargs = {'interface': m_intf_ast.name}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'const', filename, **kwargs) # TODO : tag == intfconst???
          self.m_tokens.append(m_token)

      # Class Function
      for name, m_list in m_intf_ast.functions.iteritems():
        for m_fun in m_list:
          cmd = self._get_cmd(m_fun.start[0], m_fun.end[0])
          kwargs = {'interface': m_intf_ast.name}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'intffun', filename, **kwargs)
          self.m_tokens.append(m_token)
        
      # Class Task
      for name, m_list in m_intf_ast.tasks.iteritems():
        for m_task in m_list:
          cmd = self._get_cmd(m_task.start[0], m_task.end[0])
          kwargs = {'interface': m_intf_ast.name}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'intftask', filename, **kwargs)
          self.m_tokens.append(m_token)
        
      # Class Extern Function
      for name, m_list in m_intf_ast.extern_functions.iteritems():
        for m_fun in m_list:
          cmd = self._get_cmd(m_fun.start[0], m_fun.end[0])
          kwargs = {'interface': m_intf_ast.name, 'is_extern': 1, 'is_imp': 0, 'is_def': 1}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'intffun', filename, **kwargs)
          self.m_tokens.append(m_token)
        
      # Class Extern Task
      for name, m_list in m_intf_ast.extern_tasks.iteritems():
        for m_task in m_list:
          cmd = self._get_cmd(m_task.start[0], m_task.end[0])
          kwargs = {'interface': m_intf_ast.name, 'is_extern': 1, 'is_imp': 0, 'is_def': 1}
          m_token = TOKEN.Token(('Ctags'), name, cmd, 'intftask', filename, **kwargs)
          self.m_tokens.append(m_token)
        
      if m_intf_ast.m_fintfparams:
        for m_fintfparam in m_intf_ast.m_fintfparams.m_parameters:
          # Add tags for formal class parameters
          cmd = self._get_cmd(m_fintfparam.start[0], m_fintfparam.end[0])
          m_token = TOKEN.Token(('Ctags'), m_fintfparam.name, cmd, 'fintfparam', filename)
          self.m_tokens.append(m_token)

      return 1
    return 0

class Interface(SearchBase):
  """class: Interface"""

  kind = 'interface'

  def __init__(self, **kwargs):
    super(Interface, self).__init__(**kwargs)

  def search_next (self):
    """def: search_next"""
    self.m_tokens = [] # initialization

    m_if = COMBINATORS.TagInterface(m_lexer=self.m_lexer)

    if m_if():
      name = m_if.name

      cmd = self._get_cmd(m_if.start[0], m_if.end[0])
      filename = self.m_lexer.fname
      m_token = TOKEN.Token(('Ctags', 'UserDT'), name, cmd, self.__class__.kind, filename)
      self.m_tokens = [m_token]

      return 1
    return 0

class Module(SearchBase):
  """class: Module"""

  kind = 'module'

  def __init__(self, **kwargs):
    super(Module, self).__init__(**kwargs)

  def search_next (self):
    """def: search_next"""
    self.m_tokens = [] # initialization

    m_module = COMBINATORS.TagModule(m_lexer=self.m_lexer)

    if m_module():
      name = m_module.name

      cmd = self._get_cmd(m_module.start[0], m_module.end[0])
      filename = self.m_lexer.fname
      m_token = TOKEN.Token(('Ctags', 'UserDT'), name, cmd, self.__class__.kind, filename)
      self.m_tokens = [m_token]

      return 1
    return 0

class Package(SearchBase):
  """class: Package"""

  kind = 'package'

  def __init__(self, **kwargs):
    super(Package, self).__init__(**kwargs)

  def search_next (self):
    """def: search_next"""
    self.m_tokens = [] # initialization

    m_pkg = COMBINATORS.TagPackage(m_lexer=self.m_lexer)

    if m_pkg():
      name = m_pkg.name

      cmd = self._get_cmd(m_pkg.start[0], m_pkg.end[0])
      filename = self.m_lexer.fname
      m_token = TOKEN.Token(('Ctags',), name, cmd, self.__class__.kind, filename)
      self.m_tokens = [m_token]

      return 1
    return 0


class Include(SearchBase):
  """class: Include"""

  kind = 'include'

  def __init__(self, **kwargs):
    super(Include, self).__init__(**kwargs)

  def search_next (self):
    """def: search_next"""
    self.m_tokens = [] # initialization

    m_include = AUTO_COMBINATORS.TagInclude(m_lexer=self.m_lexer)

    if m_include():
      name = m_include.tag_name()
      name = '#{0}#{1}'.format(self.__class__.kind, name)

      cmd = self._get_cmd(m_include.start[0], m_include.end[0])
      filename = self.m_lexer.fname
      m_token = TOKEN.Token(('Atags',), name, cmd, self.__class__.kind, filename)
      self.m_tokens = [m_token]

      return 1
    return 0

class Import(SearchBase):
  """class: Import"""

  kind = 'import'

  def __init__(self, **kwargs):
    super(Import, self).__init__(**kwargs)

  def search_next (self):
    """def: search_next"""
    self.m_tokens = [] # initialization

    m_import = AUTO_COMBINATORS.TagImport(m_lexer=self.m_lexer)

    if m_import():
      name = m_import.tag_name()
      name = '#{0}#{1}'.format(self.__class__.kind, name)

      cmd = self._get_cmd(m_import.start[0], m_import.end[0])
      filename = self.m_lexer.fname
      m_token = TOKEN.Token(('Atags',), name, cmd, self.__class__.kind, filename)
      self.m_tokens = [m_token]

      return 1
    return 0

#-------------------------------------------------------------------------------
# Search
#-------------------------------------------------------------------------------
class Search(object):
  """class: Search"""

  def __init__(self, **kwargs):
    self.fname = kwargs['fname']
    self.m_lexer = LEXER.Lexer(filehandle=open(self.fname, 'rb'))
    
  def save_lexer (self):
    """def: save_lexer"""
    self.lexer_pos_bkp = self.m_lexer.get_pos()

  def restore_lexer (self):
    """def: restore_lexer"""
    self.m_lexer.set_pos(self.lexer_pos_bkp) # Restore Lexer

  def datatypes (self):
    """def: datatypes"""
    self.save_lexer()

    m_tags = [Typedef(m_lexer=self.m_lexer), Class(m_lexer=self.m_lexer), Interface(m_lexer=self.m_lexer), uvm_analysis_imp_decl(m_lexer=self.m_lexer)]

    self.m_lexer.next_token()

    while 1:
      dt_found = 0
      for m_tag in m_tags:
        if m_tag.search_next():
          dt_found = 1
          break
          
      if dt_found == 1:
        for m_token in m_tag.tokens():
          yield m_token
        continue
        
      if not self.m_lexer.next_token(): break

    self.restore_lexer()

  def tags (self):
    """def: tags"""
    self.save_lexer()

    m_tags = [
              Macro(m_lexer=self.m_lexer),
              ClassAST(m_lexer=self.m_lexer), 
              InterfaceAST(m_lexer=self.m_lexer), 
              #Interface(m_lexer=self.m_lexer),
              Parameter(m_lexer=self.m_lexer), 
              Const(m_lexer=self.m_lexer),
              EnumVal(m_lexer=self.m_lexer),
              Function(m_lexer=self.m_lexer),
              Task(m_lexer=self.m_lexer),
              Module(m_lexer=self.m_lexer),
              Package(m_lexer=self.m_lexer),

              # Auto Tags (Atags)
              Include(m_lexer=self.m_lexer),
              Import(m_lexer=self.m_lexer), # FIXME: Import is not working
              ] # TODO: Add tag classes

    self.m_lexer.next_token()

    while 1:
      dt_found = 0
      for m_tag in m_tags:
        try: # Don't exit when encounter error. Need to extract as many tags as possible!!!
          if m_tag.search_next():
            dt_found = 1
            break
        except Exception as ex:
          dt_found = 1 # Not sure if I really need to do this
          print (ex)
          
      if dt_found == 1:
        for m_token in m_tag.tokens():
          yield m_token
        continue
        
      if not self.m_lexer.next_token(): break

    self.restore_lexer()

#def search_datatypes ():
#  m_search_all = [Typedef()]
#
#  for m_search in m_search_all:
#    for m_token in m_search():
#      yield m_token


