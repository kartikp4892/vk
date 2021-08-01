#!/usr/bin/env python

from sv.base.parser import ast
from sv.base.parser import Combinators, UVMMacros
from sv.base.lexer.SharedVars import *

class TagClassAST(ast.Class):
  """class: ClassVars"""

  def __init__(self, **kwargs):
    super(TagClassAST, self).__init__(**kwargs)
    
class TagInterfaceAST(ast.Interface):
  """class: ClassVars"""

  def __init__(self, **kwargs):
    super(TagInterfaceAST, self).__init__(**kwargs)
    

class Parser(Combinators.Parser):
  """class: Parser"""

  def __init__(self, **kwargs):
    super(Parser, self).__init__(**kwargs)
    self.m_fclsparams = []

  def _parse_fclsparam (self):
    """def: _parse_fclsparam"""
    # Parameterized 
    if self.is_kw('#('):
      if not self.m_lexer.next_token(1) : return 0

      datatype = None
      while not self.is_kw(')'):
        name = None
        default = None
        packed_range = None

        start = self.m_lexer.m_token.start

        # Note: use of parameter keyword inside class parameter???
        #       The following code also works:
        #       `class cls#(parameter bit count);`
        if self.is_kw('parameter'): # Skip parameter keyword
          if not self.m_lexer.next_token(1) : return 0

        # Optional user datatype
        name = self.m_lexer.m_token.text
        if not self.lex_user_datatype() : return 0

        if self.is_kw('unsigned'): # FIXME: Use `unsigned` keyword to know the datatype
          if not self.m_lexer.next_token(1) : return 0

        packed_range = self.skip_block('[', ']')

        # If the current tag is IDENTIFIER then previous tag was datatype (just guessing..)
        if self.is_tag(IDENTIFIER): 
          if name: datatype = name # name is None if previous tag was not datatype 

          name = self.m_lexer.m_token.text
          if not self.m_lexer.next_token(1) : return 0

        # Optional default value
        if self.is_kw('='):
          if not self.m_lexer.next_token(1) : return 0
          default_start = self.m_lexer.m_token.start
          default_end = self.m_lexer.m_token.end

          while not (self.is_kw(',') or self.is_kw(')')):
            if self.skip_block('#(', ')'): continue # Parameterized class
            if self.skip_block('{', '}'): continue # array values
            default_end = self.m_lexer.m_token.end
            #end = self.m_lexer.m_token.end
            if not self.m_lexer.next_token(1) : return 0
          default = (default_start, default_end) # Give the start and end position of default 

        end = self.m_lexer.m_token.prev_end
        m_parameter = Combinators.FClsParam(datatype=datatype, packed_range=packed_range, name=name, default=default, start=start, end=end)
        self.m_fclsparams.append(m_parameter)

        if self.is_kw(','):
          if not self.m_lexer.next_token(1) : return 0
        else:
          if not self.expect_kw (')'): return 0
    
      if not self.m_lexer.next_token() : return 0
      return 1     
    return 0
      
    
class TagInterface(Parser):
  """class: TagInterface"""

  def __init__(self, **kwargs):
    super(TagInterface, self).__init__(**kwargs)
    self.name = None

  def __call__ (self):
    """def: __call__"""
    if self.is_kw('interface'):
      if self.is_prev_kw('virtual'): return 0 # virtual interface declaration
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0

      if self.is_kw('automatic'):
        if not self.m_lexer.next_token(1): return 0

      if not self.expect_tag(IDENTIFIER): return 0
      self.name = self.m_lexer.m_token.text
      self.end = self.m_lexer.m_token.end

      if not self.m_lexer.next_token(1): return 0
      self._parse_fclsparam()

      return 1
    return 0
        
class TagModule(Parser):
  """class: TagModule"""

  def __init__(self, **kwargs):
    super(TagModule, self).__init__(**kwargs)
    self.name = None

  def __call__ (self):
    """def: __call__"""
    if self.is_kw('module'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0

      if self.is_kw('automatic'):
        if not self.m_lexer.next_token(1): return 0

      if not self.expect_tag(IDENTIFIER): return 0
      self.name = self.m_lexer.m_token.text
      self.end = self.m_lexer.m_token.end
      return 1
    return 0
        
class TagPackage(Parser):
  """class: TagPackage"""

  def __init__(self, **kwargs):
    super(TagPackage, self).__init__(**kwargs)
    self.name = None

  def __call__ (self):
    """def: __call__"""
    if self.is_kw('package'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0

      if not self.expect_tag(IDENTIFIER): return 0
      self.name = self.m_lexer.m_token.text
      self.end = self.m_lexer.m_token.end
      return 1
    return 0
        
class TagTypedef(Parser):
  """class: TagTypedef"""

  def __init__(self, **kwargs):
    super(TagTypedef, self).__init__(**kwargs)
    self.name = None

  def __call__ (self):
    """def: __call__"""
    if self.is_kw('typedef'):
      self.start = self.m_lexer.m_token.start

      lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer
      if not self.m_lexer.next_token(1): return 0
      # Don't include forward declaration of class in tag list
      if self.is_kw('class'):
        self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer
        return 0

      while not self.is_kw(';'):
	if self.skip_block('{', '}'): continue
	if self.skip_block('#(', ')'): continue

        if self.is_kw('['):
          self.name = self.m_lexer.m_prev_token.text
          if self.skip_block('[', ']'):
            continue

        self.name = self.m_lexer.m_token.text
        if not self.m_lexer.next_token(1): return 0

      self.end = self.m_lexer.m_token.end
      return 1
    return 0

class TagClass(Parser):
  """class: TagClass"""

  def __init__(self, **kwargs):
    super(TagClass, self).__init__(**kwargs)
    self._init_vars ()

  def _init_vars (self):
    """def: _init_vars"""
    self.name = None
    self.extends = None
    self.m_fclsparams = []
    
  def __call__ (self):
    """def: __call__"""
    self._init_vars()

    if self.is_kw('class'):
      # Don't include forward class declaration
      if self.is_prev_kw('typedef'): return 0
        
      self.start = self.m_lexer.m_token.start

      if not self.m_lexer.next_token(1): return 0
      if not self.expect_tag(IDENTIFIER): return 0
      self.name = self.m_lexer.m_token.text
      if not self.m_lexer.next_token(1): return 0

      self._parse_fclsparam()

      if self.is_kw('extends'):
        if not self.m_lexer.next_token(1): return 0
        if not self.expect_tag(IDENTIFIER): return 0
        self.extends = self.m_lexer.m_token.text

      if not self.m_lexer.next_token(1): return 0

      self.skip_block('#(', ')')

      self.end = self.m_lexer.m_token.end
      return 1
    return 0


class TagParameter(Combinators.Parameter):
  """class: TagParameter"""

  def __init__(self, **kwargs):
    super(self.__class__, self).__init__(**kwargs)

class TagConst(Combinators.Const):
  """class: TagConst"""

  def __init__(self, **kwargs):
    super(self.__class__, self).__init__(**kwargs)

class TagMacro(Combinators.Macro):
  """class: TagParameter"""

  def __init__(self, **kwargs):
    super(self.__class__, self).__init__(**kwargs)


class TagEnumVal(Combinators.Parser):
  """class: TagEnumVal"""

  def __init__(self, **kwargs):
    super(TagEnumVal, self).__init__(**kwargs)
    self.tokens = [] # {start: start, value: value}
    self.typedef = None
    self.enum_var = None

  def __call__ (self):
    """def: __call__"""

    if self.is_kw('enum'):
      self.start = self.m_lexer.m_token.start
      # If previous token was typedef
      if self.is_prev_kw('typedef'):
        self.typedef = 'typedef'
        
      # self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0

      #-------------------------------------------------------------------------------
      # Skip until start of enum values
      while not self.is_kw('{'):
        if not self.m_lexer.next_token(1): return 0
      #-------------------------------------------------------------------------------

      if not self.expect_kw('{'): return 0
      if not self.m_lexer.next_token(1): return 0

      while not self.is_kw('}'):
        self.expect_tag(IDENTIFIER)
        self.tokens.append({'start': self.m_lexer.m_token.start, 'value': self.m_lexer.m_token.text})

        if not self.m_lexer.next_token(1): return 0

        # Skip default values
        if self.is_kw('='):
          while not (self.is_kw(',') or self.is_kw('}')):
            if not self.m_lexer.next_token(1): return 0

        if not self.is_kw('}'): 
          if not self.expect_kw(','): return 0
          if not self.m_lexer.next_token(1): return 0
          
      if not self.expect_kw('}'): return 0
      if not self.m_lexer.next_token(1): return 0
      self.expect_tag(IDENTIFIER)

      # If it's enum variable add var name to token 
      if not self.typedef:
        self.enum_var = self.m_lexer.m_token.text

      self.end = self.m_lexer.m_token.end
      return 1
    return 0

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
      if not self.m_lexer.next_token(1): return 0

      while self.m_lexer.m_token.text != '(' and self.m_lexer.m_token.text != ';': # Some tasks are with no arguments --> task abc;
        if self.m_lexer.m_token.text == '::':
          self.parent_class = self.m_lexer.m_prev_token.text

        if self.skip_block('#(', ')'): continue
        if self.skip_block('[', ']'): continue

        if not self.m_lexer.next_token(1) : return 0
          
      self.name = self.m_lexer.m_prev_token.text

      self.skip_block('(', ')') # Arguments

      if not self.expect_tag (EOS): return 0
      self.end = self.m_lexer.m_token.end
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

      if not self.m_lexer.next_token(1): return 0

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
      if not self.m_lexer.next_token(1): return 0

      while self.m_lexer.m_token.text != '(' and self.m_lexer.m_token.text != ';': # Some functionas are with no arguments --> function void abc;
        if self.m_lexer.m_token.text == '::':
          self.parent_class = self.m_lexer.m_prev_token.text

        if self.skip_block('#(', ')'): continue
        if self.skip_block('[', ']'): continue

        if not self.m_lexer.next_token(1) : return 0
          
      self.name = self.m_lexer.m_prev_token.text

      self.skip_block('(', ')') # Arguments

      if not self.expect_tag (EOS): return 0
      self.end = self.m_lexer.m_token.end
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

      if not self.m_lexer.next_token(1): return 0

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
    


#-------------------------------------------------------------------------------
# UVM
#-------------------------------------------------------------------------------
class Taguvm_analysis_imp_decl(UVMMacros.uvm_analysis_imp_decl):
  """class: uvm_analysis_imp_decl"""

  def __init__(self, **kwargs):
    super(self.__class__, self).__init__(**kwargs)


  def __call__ (self):
    """def: __call__"""
    return self._parse()



