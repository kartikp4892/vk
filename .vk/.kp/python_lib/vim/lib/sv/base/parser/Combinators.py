#!/usr/bin/env python

# TODO: Module, Program, Package, Property Combinator
try:
  import vim
  vim_detected = 1
except Exception:
  vim_detected = 0

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

import os
import imp
import sys, traceback
from sv.base.lexer.Lexer import Lexer
from sv.base.Singleton import Logger
from sv.base.lexer.SharedVars import *
from sv.base.parser.Tags import Tags
from sv.base.Decorators import *
from Utils import Buffer
import inspect

class Parser(object):
  """class: Parser"""

  m_logger = Logger()
  m_tags = Tags()

  def __vi_init__ (self, **kwargs):
    """def: __vi_init__"""
    if vim_detected == 0: return 0
    
    m_lexer = kwargs.get('m_lexer', None)
    # If lexer is not provided in the argument
    # create lexer with the current cursor position
    if not m_lexer:
      ln,cn = vim.current.window.cursor
      # TBD: 1. if other kwargs are provided pass to lexer, 2. do we need to start lexer on the column position ?
      #      As of now only lexer started at line position ignoring column position
      m_lexer = Lexer(start=ln, **kwargs)
      #m_lexer = Lexer(start=ln - 1, **kwargs)
      if not m_lexer.next_token() : return 0

    self.m_lexer = m_lexer
    self.fname = vim.current.buffer.name

  def __sh_init__ (self, **kwargs):
    """def: __sh_init__"""
    if vim_detected == 1: return 0
    m_lexer = kwargs.get('m_lexer', None)

    if not m_lexer:
      m_lexer = Lexer(**kwargs)
      if not m_lexer.next_token() : return 0

    self.m_lexer = m_lexer
    self.fname = m_lexer.fname

  def __init__(self, **kwargs):
    """Constructor: """
    self.__vi_init__(**kwargs)
    self.__sh_init__(**kwargs)

    self.start = None
    self.end = None

  def sh_expect_tag (self, exp_tag):
    """def: vi_expect_tag"""
    if vim_detected == 1: return 0
      
    m_token = self.m_lexer.m_token

    if m_token.tag == EOP:
      ACT = "END_OF_PARSING"
    else:
      ACT = m_token.text
      
    if m_token.tag != exp_tag:
      if m_token.start:
        ln = m_token.start[0]
        cn = m_token.start[1]
      else:
        ln = 0
        cn = 0
        
      errmsg = 'Expecting {exp} found "{act}" !!\n'.format(exp=exp_tag , act=ACT)
      errmsg += "# Error: {file}[{line}, {col}] : {linestr}".format(file=self.fname, line=ln, col=cn, linestr=self.m_lexer.m_token_gen.line)

      # print 'Expecting {exp} found "{act}" !!\n'.format(exp=exp_tag , act=m_token.text)

      debugsave = Parser.m_logger.debug
      Parser.m_logger.debug_mode(1)

      Parser.m_logger.append(errmsg)

      #frame,filename,line_number,function_name,lines,index = inspect.stack()[1]
      #sys.stderr.write('%s[%s]: In function %s\n' % (filename, line_number, function_name))

      traceback.print_stack(file=sys.stdout)
      raise Exception(errmsg)
      #sys.stderr.write('Expecting {exp} found "{act}" !!\n'.format(exp=exp_tag , act=ACT))
      #print errmsg

      # Exit on error
      #quit()

      Parser.m_logger.debug = debugsave
      return 0
    return 1

  def vi_expect_tag (self ,exp_tag):
    """def: vi_expect_tag"""
    if vim_detected == 0: return 0
      
    m_token = self.m_lexer.m_token

    if m_token.tag != exp_tag:
      errmsg = "# Error: {file}[{line}, {col}] : {linestr}".format(file=vim.current.buffer.name, line=m_token.start[0], col=m_token.start[1], linestr=vim.eval('getline("{line}")'.format(line=m_token.start[0])))

      print 'Expecting {exp} found "{act}" !!\n'.format(exp=exp_tag , act=m_token.text)

      debugsave = Parser.m_logger.debug
      Parser.m_logger.debug_mode(1)

      m_token.highlight('Error')
      Parser.m_logger.append(errmsg)

      vim.command('redraw!')

      frame,filename,line_number,function_name,lines,index = inspect.stack()[1]
      sys.stderr.write('%s[%s]: In function %s\n' % (filename, line_number, function_name))
      sys.stderr.write('Expecting {exp} found "{act}" !!\n'.format(exp=exp_tag , act=m_token.text))

      traceback.print_stack(file=sys.stdout)
      print errmsg
      vim.command('call input("Press Enter")')

      Parser.m_logger.debug = debugsave
      return 0
    return 1

  def expect_tag (self, exp_tag):
    """def: expect_tag"""
    if self.vi_expect_tag(exp_tag): return 1
    if self.sh_expect_tag(exp_tag): return 1
    return 0

  def is_tag (self, exp_tag):
    """def: is_tag"""
    m_token = self.m_lexer.m_token

    if m_token.tag != exp_tag:
      return 0
    return 1

  def vi_expect_kw (self, exp_kw):
    """def: expect_tag"""
    if vim_detected == 0: return 0

    m_token = self.m_lexer.m_token

    if m_token.text != exp_kw:
      errmsg = "# Error: {file}[{line}, {col}] : {linestr}".format(file=self.fname, line=m_token.start[0], col=m_token.start[1], linestr=self.m_lexer.line)
      print errmsg

      debugsave = Parser.m_logger.debug
      Parser.m_logger.debug_mode(1)

      m_token.highlight('Error')
      Parser.m_logger.append(errmsg)

      vim.command('redraw!')

      frame,filename,line_number,function_name,lines,index = inspect.stack()[1]
      sys.stderr.write('%s[%s]: In function %s\n' % (filename, line_number, function_name))
      sys.stderr.write('Expecting {exp} found {act}!!\n'.format(exp=exp_kw , act=m_token.text))

      traceback.print_stack(file=sys.stdout)
      vim.command('call input("Press Enter")')

      Parser.m_logger.debug = debugsave
      return 0
    return 1

  def sh_expect_kw (self, exp_kw):
    """def: expect_tag"""
    if vim_detected == 1: return 0
      
    m_token = self.m_lexer.m_token

    if m_token.text != exp_kw:
      errmsg = 'Expecting {exp} found {act}!!\n'.format(exp=exp_kw , act=m_token.text)
      errmsg += "# Error: {file}[{line}, {col}] : {linestr}".format(file=self.fname, line=m_token.start[0], col=m_token.start[1], linestr=self.m_lexer.m_token_gen.line)

      debugsave = Parser.m_logger.debug
      Parser.m_logger.debug_mode(1)

      Parser.m_logger.append(errmsg)

      #frame,filename,line_number,function_name,lines,index = inspect.stack()[1]
      #sys.stderr.write('%s[%s]: In function %s\n' % (filename, line_number, function_name))
      traceback.print_stack(file=sys.stdout)
      raise Exception(errmsg)
      #sys.stderr.write('Expecting {exp} found {act}!!\n'.format(exp=exp_kw , act=m_token.text))
      #print errmsg

      Parser.m_logger.debug = debugsave
      #quit()

      return 0
    return 1

  def expect_kw (self, exp_kw):
    """def: expect_kw"""
    if self.vi_expect_kw (exp_kw): return 1
    if self.sh_expect_kw (exp_kw): return 1
    return 0
    
  # The do_nothing decorator will make function not to perform any operation
  # @do_nothing # TODO: comment while debug
  # The view_hightlight_runtime decorator is useful in debug mode to see
  # the parsering at run time. Uncomment it to use this in debug
  @view_hightlight_runtime # TODO: comment after debug
  def highlight (self, group_name, **kwargs):
    """def: highlight"""
    if vim_detected == 0: return 0
      

    # Not in debug mode
    m_logger = Logger()
    if m_logger.debug == 0:
      return
      
    if not (self.start and self.end): return
      
    ln, cn = self.start
    matchidx = kwargs.get('matchidx', 1)
      
    vim.current.window.cursor = (ln, cn - 1)
    vim.command('{idx}match {group} "\\v%{start[0]}l%{start[1]}c\_.*\\v%{end[0]}l%{end[1]}c."'.format(idx=matchidx, group=group_name, start=self.start, end=self.end))
    vim.command('{0}'.format(self.start[0]))
    vim.command('normal zz')
    Parser.m_logger.set('%s ' % self)
    
  def is_datatype (self):
    """def: is_datatype"""
    return self.m_lexer.m_token.text in DATATYPE_KEYWORDS
  
  def lex_interface_datatype (self):
    """def: lex_interface_datatype"""
    
    lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer
    #-------------------------------------------------------------------------------
    # FIX: Interfaces are used in class as `virtual apb_if`. So this is considered as datatype
    if self.is_kw('virtual'):
      if not self.m_lexer.next_token(1) : return 0
    else:
      self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer
      return 0 # Restore lexer only if fails
    #-------------------------------------------------------------------------------

    if not self.m_lexer.next_token(1) : return 0
    return 1

  def lex_user_datatype (self):
    """def: lex_user_datatype
             Since userdatatypes sometimes contains multiple tags
             example: `pkg::datatype` or `virtual apb_if` or `int unsigned` or `bit signed [2:0]`
             This function lex all tags in datatypes (as self.m_lexer.next_token() lexes only one tag so it won't work)
    """
    
    # First try to lex virtual interface if found as datatype
    if self.lex_interface_datatype (): return 1
      
    #-------------------------------------------------------------------------------
    # FIX: Datatype can be defined in package and used as pkg::datatype
    #if self.m_lexer.is_match(r'<\w+\_s*::'):
    if self.is_pkg_name():
      pkgname = self.m_lexer.m_token.text # TODO: Anything to do with package name???
      if not self.m_lexer.next_token(1) : return 0
      self.expect_kw('::')
      if not self.m_lexer.next_token(1) : return 0
    #-------------------------------------------------------------------------------

    # Last token in user datatype
    if not self.m_lexer.next_token() : return 0

    return 1
    
  def is_pkg_name (self):
    """def: is_pkg_name"""
    
    if self.is_tag(IDENTIFIER):
      lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer

      if not self.m_lexer.next_token(1) : return 0
      if self.is_kw('::'):
        self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer
        return 1

      self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer

    return 0

  def is_interface_datatype (self):
    """def: is_interface_datatype"""
    lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer
    #-------------------------------------------------------------------------------
    # FIX: Interfaces are used in class as `virtual apb_if`. So this is considered as datatype
    if self.is_kw('virtual'):
      if not self.m_lexer.next_token(1) : return 0
    #-------------------------------------------------------------------------------

    is_udt = Parser.m_tags.is_interface_datatype(self.m_lexer.m_token.text)
    self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer
    return is_udt

  def is_user_datatype (self, clsname=""): # Optional clsname arg is provided to look for addition class local datatypes
    """def: is_user_datatype"""
    lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer

    # if self.m_lexer.m_token.tag != IDENTIFIER: return 0
      
    #-------------------------------------------------------------------------------
    # FIX: Datatype can be defined in package and used as pkg::datatype
    # if self.m_lexer.is_match(r'<\w+\_s*::'):
    if self.is_pkg_name():
      pkgname = self.m_lexer.m_token.text # TODO: Anything to do with package name???
      if not self.m_lexer.next_token(1) : return 0
      self.expect_kw('::')
      if not self.m_lexer.next_token(1) : return 0
    #-------------------------------------------------------------------------------

    is_udt = Parser.m_tags.is_user_datatype(self.m_lexer.m_token.text, clsname)

    if not is_udt:
      is_udt = self.is_interface_datatype ()

    self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer

    return is_udt
  
  def is_kw (self, text):
    """def: is_kw"""
    if self.m_lexer.m_token.text == text:
      return 1
    return 0

  def is_tag (self, tag):
    """def: is_kw"""
    if self.m_lexer.m_token.tag == tag:
      return 1
    return 0

  def is_prev_kw (self, text):
    """def: is_kw"""
    if self.m_lexer.m_prev_token and self.m_lexer.m_prev_token.text == text:
      return 1
    return 0

  def is_next_kw (self, text):
    """def: is_kw"""
    lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer
    if not self.m_lexer.next_token(1) : return 0
    
    if self.m_lexer.m_token and self.m_lexer.m_token.text == text:
      self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer
      return 1

    self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer
    return 0

  def skip_block (self, start_kw, end_kw):
    """def: skip_block"""
    if self.m_lexer.m_token.text == start_kw:
      # TODO: Return BlockContainer object.. see skip_block of `/home/kartik/.vk/.kp/python_lib/vim/lib/sv/debug/parser/Combinators.py`
      start = self.m_lexer.m_token.start

      if not self.m_lexer.next_token() : return 0

      while self.m_lexer.m_token.text != end_kw:
        # Skip sub blocks if any
        if self.skip_block('#(', ')') : continue
        if self.skip_block('[', ']') : continue
        if self.skip_block('(', ')') : continue
        if self.skip_block('{', '}') : continue

        if not self.m_lexer.next_token() : return 0

      if not self.m_lexer.next_token() : return 0

      self.skip_block(start_kw, end_kw) # Skip sibling blocks if any

      end = self.m_lexer.m_token.prev_end

      block_pos = (start, end)

      return block_pos

    return None

#-------------------------------------------------------------------------------
# Actual Parameter
class AClsParam(object):
  """class: AClsParam
     Actual class parameter
  """

  def __init__(self, **kwargs):
    """
    Constructor:
      value= Actual parameter value
      [posidx=] Formal parameter position index 
      [posname=] Formal parameter value

      Note: posidx= and posname= are optional but at least one must be provided.
    """
    self.value = kwargs['value']
    self.posidx = kwargs.get('posidx', None)
    self.posname = kwargs.get('posname', None)
    self.start = kwargs['start']
    self.end = kwargs['end']

    # Both can't be None
    if (self.posidx == None) and (self.posname == None):
      frame,filename,line_number,function_name,lines,index = inspect.stack()[1]
      sys.stderr.write('%s[%s]: In function %s\n' % (filename, line_number, function_name))
      sys.stderr.write('Parameter must be either by position or by value!!!\n')

  def __str__ (self):
    """def: __str__"""
    text = ''
    text += 'START=%0s ' % (self.start)

    if self.posidx:
      text += 'START=%0s %0s ==> %0s END=%0s' % (self.posidx , self.value)
    elif self.posname :
      text += 'START=%0s .%0s(%0s) END=%0s' % (self.posname , self.value)

    text += 'END=%0s ' % (self.end)

    return text
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Container
#-------------------------------------------------------------------------------
class Container(Parser):
  """class: Container
     This class retains all the text parsed by it using lexer.
  """

  def __init__(self, m_lexer):
    self.m_lexer = m_lexer
    start = self.m_lexer.m_token.start
    end = self.m_lexer.m_token.end
    text = self.m_lexer.m_token.text
    m_wspace = self.m_lexer.m_token.m_wspace
    m_text = TOKEN.Text(text, start, end, m_wspace)
    self.m_texts = [m_text]

  def append_token (self, m_token):
    """def: append_token"""
    if m_token:
      m_wspace = m_token.m_wspace

      m_text = TOKEN.Text(m_token.text, m_token.start, m_token.end)
      if m_wspace:
        self.m_texts.append(m_wspace)

      self.m_texts.append(m_text)
      return 1
    return 0

  def next_token (self):
    """def: next_token"""
    if not self.m_lexer.next_token() : return 0
    self.append_token(self.m_lexer.m_token)
    return 1

  def skip_line (self):
    """def: skip_line"""
    m_token = self.m_lexer.skip_line()
    self.append_token(m_token)
    return m_token

  def text_token (self):
    """def: text_token"""
    if len(self.m_texts) != 0:
      text = ''.join([m_text.text for m_text in self.m_texts])
      start = self.m_texts[0].start
      end = self.m_texts[-1].end
      return TOKEN.Text(text, start, end, self.m_texts[0].m_wspace)
    return None

  def skip_block (self, *args, **kwargs):
    """def: skip_block"""
    m_block = super(Container, self).skip_block(*args, **kwargs)
    if m_block:
      self.append_token(m_block.m_atext)
    return m_block

class BlockContainer(Container):
  """class: BlockContainer"""

  def itext_token (self):
    """def: text_token"""
    if len(self.m_texts) <= 2: return None
      
    text = ''.join([m_text.text for m_text in self.m_texts[1:-2]])
    start = self.m_texts[1].start
    end = self.m_texts[-2].end
    return TOKEN.Text(text, start, end, self.m_texts[1].m_wspace)

  def block_token (self):
    """def: block_token"""
    m_itext = self.itext_token()
    m_atext = self.text_token()
    return TOKEN.BlockToken(m_atext, m_itext)
    

#-------------------------------------------------------------------------------
# Actual parameters
class AClsParams(Parser):
  """class: AClsParams
     Actual class paramters
  """

  def __init__(self, m_lexer):
    super(AClsParams, self).__init__(m_lexer=m_lexer)
    self.m_parameters = []
    self.start = None
    self.end = None

  def text (self):
    """def: text"""
    txt = Buffer.getstr(self.m_lexer.buffer, self.start, self.end)
    return txt

  def _parse (self):
    """def: _parse_actual"""
    if self.is_kw('#('):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1) : return 0

      idx = 0
      while not self.is_kw(')'):
        value = None
        paramidx = None
        paramname = None

        start = self.m_lexer.m_token.start

        # `.FORMAL(ACTUAL)`
        if self.is_kw('.'):
          if not self.m_lexer.next_token(1) : return 0

          if not self.expect_tag(IDENTIFIER): return 0
          paramname = self.m_lexer.m_token.text
          if not self.m_lexer.next_token(1) : return 0

          if not self.expect_kw ('('): return 0 # Actual parameter value --> .formal(actual)
          if not self.m_lexer.next_token(1) : return 0

          while not self.is_kw(')'): # Actual parameter value --> .formal(actual)
            if self.skip_block('#(', ')') : continue
            if self.skip_block('(', ')') : continue
            if not self.m_lexer.next_token(1) : return 0

          if not self.m_lexer.next_token(1) : return 0
        else:
          paramidx = idx
          idx += 1
          
          while not (self.is_kw(',') or self.is_kw(')')):
	    if self.skip_block('#(', ')'): continue # Skip inner #( )
            if self.skip_block('(', ')'): continue # Skip inner ( )
            if not self.m_lexer.next_token(1) : return 0

        end = self.m_lexer.m_token.prev_end
        m_parameter = AClsParam(value=value, posidx=paramidx, posname=paramname, start=start, end=end)
        self.m_parameters.append(m_parameter)

        if self.is_kw(','):
          if not self.m_lexer.next_token(1) : return 0
        else:
          if not self.expect_kw (')'): return 0

      self.end = self.m_lexer.m_token.end
      if not self.m_lexer.next_token() : return 0
      return 1     
    return 0
    
  def __str__ (self):
    """def: __str__"""
    global INDENT

    INDENT += 2

    str = ''
    for m_param in self.m_parameters:
      str += '{str}'.format(str=m_param)

    INDENT -= 2

    return str
#-------------------------------------------------------------------------------
  
#-------------------------------------------------------------------------------
# Formal Paramter
class FClsParam(object):
  """class: FClsParam
    Formal class parameter
  """

  def __init__(self, **kwargs):
    """
      Constructor:
        datatype= datatype of parameter
        name= variable name
        default= default value
    """
    self.datatype = kwargs['datatype']
    self.packed_range = kwargs['packed_range']
    self.name = kwargs['name']
    self.default = kwargs.get('default', None)
    self.start = kwargs['start']
    self.end = kwargs['end']

  def str (self):
    """def: str"""
    text = '{dt} {name}'.format(dt=self.datatype, name=self.name)
    return text
    
  def __str__ (self):
    """def: __str__"""
    str = '{indent}<parameter datatype="{self.datatype}", name="{self.name}", default="{self.default}", start="{self.start}", end="{self.end}">\n'.format(indent=" " * INDENT, self=self)
    return str
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Formal Parameters
class FClsParams(Parser):
  """class: FClsParams
     Formal class parameters #(...)
  """

  def __init__(self, **kwargs):
    super(FClsParams, self).__init__(**kwargs)
    self.m_parameters = []
    self.clsname = kwargs.get('clsname', None)

  def __str__ (self):
    """def: __str__"""
    global INDENT

    INDENT += 2

    str = ''
    for m_param in self.m_parameters:
      str += '{str}'.format(str=m_param)

    INDENT -= 2

    return str
  
  def __call__ (self):
    """def: __call__"""
    # Parameterized 
    if self.is_kw('#('):
      self.start = self.m_lexer.m_token.start
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

        if self.is_datatype() or self.is_user_datatype(self.clsname):
          name = self.m_lexer.m_token.text
          if not self.lex_user_datatype() : return 0

          if self.is_kw('unsigned') or self.is_kw('signed'): # FIXME: Use `unsigned` keyword to know the datatype
            if not self.m_lexer.next_token(1) : return 0

          packed_range = self.skip_block('[', ']')

        # If the current tag is IDENTIFIER then previous tag was datatype (just guessing..)
        if self.is_tag(IDENTIFIER): 
          if name: datatype = name # name is None if previous tag was not datatype 

          name = self.m_lexer.m_token.text
          if not self.m_lexer.next_token(1) : return 0

        # || NEED IT??? || if not self.expect_tag (IDENTIFIER): return 0

        #end = self.m_lexer.m_token.end

        # Optional default value
        if self.is_kw('='):
          if not self.m_lexer.next_token(1) : return 0
          default_start = self.m_lexer.m_token.start
          default_end = self.m_lexer.m_token.end

          while not (self.is_kw(',') or self.is_kw(')')):
            if self.skip_block('#(', ')'): continue # Parameterized class
            if self.skip_block('{', '}'): continue # array values
            if self.skip_block('(', ')'): continue # Expression b/w ( and )
            default_end = self.m_lexer.m_token.end
            #end = self.m_lexer.m_token.end
            if not self.m_lexer.next_token(1) : return 0
          default = (default_start, default_end) # Give the start and end position of default 

        end = self.m_lexer.m_prev_token.end
        m_parameter = FClsParam(datatype=datatype, packed_range=packed_range, name=name, default=default, start=start, end=end)
        self.m_parameters.append(m_parameter)

        if self.is_kw(','):
          if not self.m_lexer.next_token(1) : return 0
        else:
          if not self.expect_kw (')'): return 0
    
      if not self.m_lexer.next_token() : return 0
      return 1     
    return 0
#-------------------------------------------------------------------------------
          
#-------------------------------------------------------------------------------
# Comment Parser
#-------------------------------------------------------------------------------
class Comments(Parser):
  """class: Comments
     Description: Parser to get all the continuous line comment or block comment
  """

  # Examples:
  #           // ###########################
  #           // ===========================
  #           //----------------------------
  comment_boundary_re = re.compile('^[ #=-]*[#=-]+[ #=-]*$')
  comment_start_re = re.compile('^\s*//')
  blk_comment_start_re = re.compile('^\s*/\*')

  def __init__(self, **kwargs):
    super(Comments, self).__init__(**kwargs)
    self.ctype = '' # block/line

  def __call__ (self):
    """def: __call__"""

    # Get all the continuous line comments which forms block comments
    if self.is_tag(LINE_COMMENT):
      self.start = self.m_lexer.m_token.start
      self.ctype = 'line'

      # Don't return multiple line comments if comments is not at the start of line. example `int abc; // comment`
      line_starts_with_comment = 0
      if self.m_lexer.m_token.isnewline():
        line_starts_with_comment = 1

      self.m_lexer.next_token()

      if not line_starts_with_comment:
        self.end = self.m_lexer.m_prev_token.end
        return 1

      while self.is_tag(LINE_COMMENT):
        # Consider line comment as a block comment only if it is a part of continuous line comments
        if self.m_lexer.m_prev_token.start[0] != self.m_lexer.m_token.start[0] - 1: break

        # END OF PARSING
        if not self.m_lexer.next_token() : break

        line = self.m_lexer.m_prev_token.text
        line = Comments.comment_start_re.sub('', line)
        # Consider line comment as a block comment only if there is no comment boundary --> generally block comments starts and ends with comment boundary
        if Comments.comment_boundary_re.search(line): break

      self.end = self.m_lexer.m_prev_token.end

      return 1
    # Get the block comments
    elif self.is_tag(BLOCK_COMMENT):
      self.start = self.m_lexer.m_token.start
      self.end = self.m_lexer.m_token.end
      self.ctype = 'block'
      if not self.m_lexer.next_token() : return 0
      return 1

    return 0

  def __str__ (self):
    """def: __str__"""
    str = '<comments start={0!r}, end={1!r}>'.format(self.start, self.end)
    return str

#-------------------------------------------------------------------------------
# Arguments parser used for module and interface
#-------------------------------------------------------------------------------
class ModuleArgs(Parser):
  """class: ModuleArgs"""

  def __init__(self, **kwargs):
    super(ModuleArgs, self).__init__(**kwargs)
    
  def _parse (self):
    """def: _parse"""
    if self.is_kw('('):
      self.start = self.m_lexer.m_prev_token.start
      if not self.m_lexer.next_token() : return 0
      while not self.is_kw(')'):
        if not self.m_lexer.next_token() : return 0
      self.end = self.m_lexer.m_token.end
      if not self.m_lexer.next_token() : return 0
      return 1
    return 0

#-------------------------------------------------------------------------------
# Interface Parser
#-------------------------------------------------------------------------------
class Interface(Parser):
  """class: Interface"""

  def __init__(self, **kwargs):
    super(Interface, self).__init__(**kwargs)
    self.name = ""
    self.automatic = ""
    self.m_fintfparams = None
    self.m_moduleargs = ModuleArgs(**kwargs)

  def _parse_footer (self):
    """def: _parse_footer"""
    if not self.is_kw('endinterface'): return 0

    if not self.m_lexer.next_token(): pass # Don't return 0 if this fails.. Since this may be the end of file also

    # Optional `endinterface : iftag`
    if self.is_kw(':'):
      if not self.m_lexer.next_token() : return 0

      if not self.expect_tag (IDENTIFIER): return 0
      if not self.m_lexer.next_token() : pass # Don't return 0 if this fails.. Since this may be the end of file also

    self.end = self.m_lexer.m_prev_token.end
    return 1
      
  def _parse_header (self):
    """def: _parse_header"""
    if self.is_kw('interface'):
      # Avoid `protected virtual interface abc_if.driver_mp m_vif;`
      if self.is_prev_kw('virtual'): return 0
      self.highlight('DiffChange')
        
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token() : return 0

      if self.is_kw('automatic'):
        self.automatic = 'automatic'
        if not self.m_lexer.next_token() : return 0

      # expect interface name
      if not self.expect_tag (IDENTIFIER): return 0
      self.name = self.m_lexer.m_token.text
      if not self.m_lexer.next_token() : return 0

      # Optional formal parameters
      m_fclsparams = FClsParams(m_lexer=self.m_lexer, clsname=self.name)
      if m_fclsparams():
         self.m_fintfparams = m_fclsparams

      # ABOVE IS THE ALTERNATE ## #------------------------------------------------------------
      # ABOVE IS THE ALTERNATE ## # <NEED TO TEST> FIX???: Handle parameterized interface --> interface apb_if #(parameter int BUS_WIDTH = 10)
      # ABOVE IS THE ALTERNATE ## block_pos = self.skip_block('#(', ')')
      # ABOVE IS THE ALTERNATE ## if block_pos:
      # ABOVE IS THE ALTERNATE ##   pass
      # ABOVE IS THE ALTERNATE ## #------------------------------------------------------------

      self.m_moduleargs._parse()
      if not self.expect_tag (EOS): return 0
      self.end = self.m_lexer.m_token.end

      self.m_lexer.next_token()

      return 1
    return 0
    
  def __call__ (self):
    """def: __call__"""
    return self._parse()

  def _parse (self):
    """def: _parse"""
    #Logger().buffer.name = 'ClassInterface' # Debug
    Logger().set('ClassInterface') # Debug

    if self._parse_header():
      return 1 # TODO: Complete fun parsing
    return 0
    
#-------------------------------------------------------------------------------
# Class Parser
#-------------------------------------------------------------------------------
class Class(Parser):
  """class: Class"""

  def __init__(self, **kwargs):
    """Constructor: """
    super(Class, self).__init__(**kwargs)
    self.virtual = ""
    self.name = ""
    self.extends = ""
    self.m_fclsparams = None
    self.m_extends_aparams = None

  def _parse_footer (self):
    """def: _parse_footer"""
    if not self.is_kw('endclass'): return 0

    if not self.m_lexer.next_token(): pass # Don't return 0 if this fails.. Since this may be the end of file also

    # Optional `endclass : clstag`
    if self.is_kw(':'):
      if not self.m_lexer.next_token() : return 0

      if not self.expect_tag (IDENTIFIER): return 0
      if not self.m_lexer.next_token() : pass # Don't return 0 if this fails.. Since this may be the end of file also

    self.end = self.m_lexer.m_prev_token.end
    return 1
      
  def _parse_header (self):
    """def: _parse_header
      Parse class header
    """

    # If virtual class
    if self.is_kw('virtual'):
      lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer

      if not self.m_lexer.next_token() : return 0
      if not self.is_kw('class'):
        self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer
        return 0

      self.virtual = 'virtual'

      lexer_pos_bkp = None

    # keyword is 'class'
    if self.is_kw('class'):
      # check if this is forward declaration of class: `typedef class abc;`
      if self.is_prev_kw('typedef'): return 0

      if self.is_prev_kw ('virtual'):
        self.start = self.m_lexer.m_prev_token.start
      else:
        self.start = self.m_lexer.m_token.start

      if not self.m_lexer.next_token() : return 0

      # class name identifier
      if not self.expect_tag (IDENTIFIER): return 0
      self.name = self.m_lexer.m_token.text
      if not self.m_lexer.next_token(): return 0

      # Optional formal parameters
      m_fclsparams = FClsParams(m_lexer=self.m_lexer, clsname=self.name)
      if m_fclsparams():
         self.m_fclsparams = m_fclsparams

      # keyword is 'extends' 
      if self.is_kw('extends'):
        if not self.m_lexer.next_token(): return 0
        if not self.expect_tag (IDENTIFIER): return 0
        self.extends = self.m_lexer.m_token.text

        if not self.m_lexer.next_token(): return 0

        # [optional scope resolution for package class] extends pkg::base_class
        if self.is_kw('::'):
          if not self.m_lexer.next_token(): return 0
          if not self.expect_tag (IDENTIFIER): return 0
          self.extends += "::{0}".format(self.m_lexer.m_token.text)
          if not self.m_lexer.next_token(): return 0

        # Optional Actual parameters `#(...)`
        m_actparams = AClsParams(self.m_lexer)
        if m_actparams._parse():
          self.m_extends_aparams = m_actparams

        #------------------------------------------------------------
        # Note: Not sure why but the following statement is also valid.
        #       `class arinc429_mcp_buffer extends imb_transaction();`
        #       That is extended class is being used as function or task call.
        #       Skipt that braces
        block_pos = self.skip_block('(', ')')
        if block_pos:
          pass
        #------------------------------------------------------------

      # End Of Statement
      if not self.expect_tag (EOS): return 0
      self.end = self.m_lexer.m_token.end

      self.m_lexer.next_token()

      return 1

  def __call__ (self):
    """def: __call__"""
    return self._parse()

  def _parse (self):
    """def: _parse"""
    if self._parse_header():
      return 1 # TODO: Complete fun parsing
    return 0
    
  def __str__ (self):
    """def: __str__"""
    str = "{indent}<class virtual='{virtual}' name='{name}' extends='{extends}'>\n".format(indent=" " * INDENT,virtual=self.virtual, name=self.name, extends=self.extends)
    if self.m_fclsparams != None:
      str += "{indent}{param}".format(indent=" " * INDENT, param=self.m_fclsparams )
    if self.m_extends_aparams != None:
      str += "{indent}  @extends {param}".format(indent=" " * INDENT, param=self.m_extends_aparams )

    #str += "{indent}  <start=\"{start[0]}, {start[1]}\">".format(indent=" " * INDENT, start=self.start )
    #str += "{indent}  <end=\"{end[0]}, {end[1]}\">\n".format(indent=" " * INDENT, end=self.end )
    str += "{indent}</class>".format(indent=" " * INDENT)
    return str
    

# Datatype token
class Datatype(object):
  """class: Datatype"""

  def __init__(self, **kwargs):
    self.enum = kwargs.get('enum', None)
    self.enum_range = kwargs.get('enum_range', None)
    self.datatype = kwargs['datatype']
    self.signing = kwargs.get('signing', None)
    self.m_acls_params = kwargs.get('m_acls_params', None)
    self.packed = kwargs.get('packed', None)
    self.start = kwargs['start']
    self.end = kwargs['end']

  def _get_type (self):
    """def: _get_type"""
    vartype = ''
    if self.enum: vartype += '{0} '.format(self.enum)
    if self.datatype: vartype += '{0} '.format(self.datatype)
    if self.signing: vartype += '{0} '.format(self.signing)
    if self.m_acls_params: vartype += '{0} '.format(self.m_acls_params.text())
    # --> if self.packed: vartype += '{0} '.format(Buffer.getstr(self.m_lexer.buffer, *packed))
    # --> if self.enum_range: vartype += '{0} '.format(Buffer.getstr(self.m_lexer.buffer, *enum_range))
    
    # || # TODO: Add logic to return return type unique... Hint: Returning object or hash will be easy to generate unique key (instead of using string)
    # || return vartype

    # WARN: This function is used in python_lib/shell/uvm/ctags/utils/search.py file. Modification in the return datatype may affected the functionality in that file.
    return self.datatype # vartype or datatype???

  def str (self):
    """def: str"""
    text = ""
    if self.enum: text += ' {0}'.format(self.enum)
    if self.datatype: text += ' {0}'.format(self.datatype)
    if self.packed: text += ' {0}'.format(Buffer.getstr(vim.current.buffer, *self.packed))
    if self.enum_range: text += ' {0}'.format(Buffer.getstr(vim.current.buffer, *self.enum_range))
    if self.m_acls_params: text += ' {0}'.format(self.m_acls_params.text())
    text = text.strip()
    return text
    
  def __str__ (self):
    """def: __str__"""
    text = None
    if self.m_acls_params:
      text = self.m_acls_params.text()

    str = '{indent}<datatype enum="{self.enum}", enum_range="{self.enum_range}", datatype="{self.datatype}", parameter="{text}", packed="{self.packed}", start="{self.start}", end="{self.end}" >\n'.format(indent=" " * INDENT, self=self, text=text)
    return str

# Variable token
class Variable(Datatype):
  """class: Variable"""

  def __init__(self, **kwargs):
    """ Constructor: """
    super(Variable, self).__init__(**kwargs)
    self.name = kwargs['name']
    self.unpacked = kwargs.get('unpacked', None)
    self.default = kwargs.get('default', None)

  def str (self):
    """def: str"""
    text = super(Variable, self).str()
    if self.name:
      text += " {0}".format(self.name)
    return text
    
  def __str__ (self):
    """def: __str__"""
    if self.m_acls_params:
      acls_param_str = self.m_acls_params.text()
    else:
      acls_param_str = None

    str = '{indent}<variable enum="{self.enum}", enum_range="{self.enum_range}", datatype="{self.datatype}", parameter="{acls_param_str}", packed="{self.packed}", name="{self.name}", unpacked="{self.unpacked}", start="{self.start}", end="{self.end}", default="{self.default}">\n'.format(indent=" " * INDENT, self=self, acls_param_str=acls_param_str)
    return str

class Argument(Variable):
  """class: Argument"""

  def __init__(self, **kwargs):
    """ Constructor: """
    super(Argument, self).__init__(**kwargs)
    self.direction = kwargs.get('direction', None)
    self.ref = kwargs.get('ref', None)

  def __str__ (self):
    """def: __str__"""

    if self.m_acls_params:
      acls_params_text = self.m_acls_params.text
    else:
      acls_params_text = None
    str = '{indent}<argument ref="{self.ref}" direction="{self.direction}" enum="{self.enum}", enum_range="{self.enum_range}", datatype="{self.datatype}", parameter="{acls_params_text}", packed="{self.packed}", name="{self.name}", unpacked="{self.unpacked}", start="{self.start}", end="{self.end}", default="{self.default}">\n'.format(indent=" " * INDENT, self=self, acls_params_text=acls_params_text)
    return str

class VariablesBase(Parser):
  """class: VariablesBase"""

  def __init__(self, **kwargs):
    """Constructor: """
    super(VariablesBase, self).__init__(**kwargs)
    self.clsname = kwargs.get('clsname', None)

  def _parse_default (self):
    """def: _parse_default"""
    # Optional default value
    if self.is_kw('='):
      if not self.m_lexer.next_token(1) : return 0
      default_start = self.m_lexer.m_token.start
      default_end = self.m_lexer.m_token.end

      while not (self.is_kw(',') or self.is_kw(')') or self.is_kw(';')):
        if self.skip_block('#(', ')'): continue # Parameterized class
        if self.skip_block('{', '}'): continue # array values
        if self.skip_block('(', ')'): continue # default values is assigned by function call

        if not self.m_lexer.next_token() : return 0

      default_end = self.m_lexer.m_prev_token.end
      default = (default_start, default_end) # Give the start and end position of default 

      return default

    return None

    
  def _parse_datatype (self):
    """def: _parse_datatype"""
    start = self.m_lexer.m_token.start

    enum = None
    datatype = None
    signing = None
    m_acls_params = None
    packed = None
    enum_range = None
    end = None

    if self.is_kw('enum'):
      enum = self.m_lexer.m_token.text
      if not self.m_lexer.next_token(1): return 0
    
    if not self.is_tag(SPECIAL_KEYWORD) and (self.is_datatype() or self.is_user_datatype(self.clsname)):
      datatype = self.m_lexer.m_token.text
      if not self.lex_user_datatype(): return 0 # Note: lex_user_datatype instead of m_lexer.next_token

    #-------------------------------------------------------------------------------
    # FIX: If datatype is not specified in method argument, default datatype is bit.
    #      Example: `function bit myfun(bit signed [3:0] in, output [STAGE_OUT_FULL_WD-1:0] out);`
    #                ..............................................|
    if datatype == None :
      datatype = 'bit';
      
    if self.is_kw('unsigned') or self.is_kw('signed') :
      signing = self.m_lexer.m_token.text
      if not self.m_lexer.next_token(1): return 0
    #-------------------------------------------------------------------------------

    if enum == None and datatype == None :
      return None
      
    m_acls_params = AClsParams(self.m_lexer)
    if not m_acls_params._parse():
      m_acls_params = None

    block_pos = self.skip_block('[', ']')
    if block_pos: # packed range of variable
      packed = block_pos

    if enum:
      block_pos = self.skip_block('{', '}') # Enum range
      if block_pos:
        enum_range = block_pos

    end = self.m_lexer.m_token.prev_end
    ret_tuple = (start, enum, datatype, signing, m_acls_params, packed, enum_range, end)
    return ret_tuple


#-------------------------------------------------------------------------------
# Base calss for Variables
#-------------------------------------------------------------------------------
class Variables(VariablesBase):
  """class: Variables"""

  def __init__(self, **kwargs):
    """ Constructor: """
    super(Variables, self).__init__(**kwargs)
    self.m_variables = []

  # Datatype for the variables. All the variables declared in the same line are of same type
  # So return type of the first variables
  def _get_type (self):
    """def: _get_type"""
    if len(self.m_variables) == 0: return None
      
    return self.m_variables[0]._get_type()

  def __call__ (self):
    """def: __call__"""

    return self._parse()
    
  def _parse (self):
    """def: _parse"""
    if not self._parse_interface_handle ():
      if not self._parse_vars(): return 0
    return 1
    
    
  @save_lexer_on_fail
  def _parse_interface_handle (self):
    """def: _parse_interface_handle"""
    if self.is_kw('virtual'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0
      # Optional `interface` keyword
      if self.is_kw('interface'):
        if not self.m_lexer.next_token(1): return 0

      # Interface type
      if not self.is_interface_datatype(): return 0
      datatype = self.m_lexer.m_token.text
      if not self.m_lexer.next_token(1): return 0

      # FIX: Parameterized interface actual parameters passed --> vif #(10).modport m_vif
      parameters_pos = self.skip_block('#(', ')')
      if parameters_pos: # parameterized interface parameters
        pass
      
      if self.is_kw('.'):
        datatype += self.m_lexer.m_token.text
        if not self.m_lexer.next_token(1): return 0

        # Modport declaration
        if not self.expect_tag(IDENTIFIER): return 0
        datatype += self.m_lexer.m_token.text
        if not self.m_lexer.next_token(1): return 0
      
      while True:
        # Interface handle
        if not self.expect_tag(IDENTIFIER): return 0
        name = self.m_lexer.m_token.text
        if not self.m_lexer.next_token(1): return 0

        #-------------------------------------------------------------------------------
        # FIX: unpacked array of interface --> eadin_if m_vif[`FPGA1_TOTAL_NUM_ADB];
        block_pos = self.skip_block('[', ']')
        if block_pos: 
          unpacked = block_pos
        #-------------------------------------------------------------------------------

        self.end = self.m_lexer.m_token.end

        #m_variable = Variable(enum=enum, enum_range=enum_range, datatype=datatype, m_acls_params=m_acls_params, packed=packed, name=name, unpacked=unpacked, default=default, start=self.start, end=self.end)
        m_variable = Variable(datatype=datatype, name=name, start=self.start, end=self.end)
        self.m_variables.append(m_variable)

        if not self.is_kw(','):
          if not self.expect_kw(';'): return 0
          break
        if not self.m_lexer.next_token(1): return 0

      self.m_lexer.next_token()
      return 1
    return 0

  @save_lexer_on_fail
  # @skip_to_eos_on_fail
  def _parse_vars (self):
    """def: _parse"""
    if not self.is_tag(SPECIAL_KEYWORD) and (self.is_datatype() or self.is_user_datatype(self.clsname)):
      self.start = self.m_lexer.m_token.start
      start = self.m_lexer.m_token.start

      enum = None
      datatype = None
      m_acls_params = None
      packed = None
      enum_range = None

      ret_tuple = self._parse_datatype()
      if not ret_tuple:
        if not self.expect_tag ('DATATYPE'): return 0

      if ret_tuple:
        _, enum, datatype, signing, m_acls_params, packed, enum_range,_  = ret_tuple
        if start == None:
          start = ret_tuple[0]

      while not (self.is_kw(';')):
        name = None
        unpacked = None
        default = None

        if not self.is_tag (IDENTIFIER): return 0
        name = self.m_lexer.m_token.text
        if not self.m_lexer.next_token(1): return 0
        
        block_pos = self.skip_block('[', ']')
        if block_pos: # unpacked range of variable
          unpacked = block_pos
        
        default = self._parse_default()

        end = self.m_lexer.m_token.end
        #end = self.m_lexer.m_token.prev_end
        m_variable = Variable(enum=enum, enum_range=enum_range, datatype=datatype, m_acls_params=m_acls_params, packed=packed, name=name, unpacked=unpacked, default=default, start=start, end=end)
        self.m_variables.append(m_variable)

        if self.is_kw(','):
          if not self.m_lexer.next_token(1) : return 0
          start = self.m_lexer.m_token.start
        else:
          block_pos = self.skip_block('(', ')')
          if block_pos: # FIX: `axi_if m_axi_if();` ==> here '()' used in the interface instance
            unpacked = block_pos
          if not self.is_kw(')'): #FIX: `module FIFO (parameter WIDTH=5, parameter DEPTH=10)` ==> here after '10' ')' is expected
            if not self.expect_tag (EOS): return 0

      self.end = self.m_lexer.m_token.end

      if not self.is_kw(')'): #FIX: `module FIFO (parameter WIDTH=5, parameter DEPTH=10)` ==> here after '10' ')' is expected
        if not self.expect_tag (EOS): return 0

      self.m_lexer.next_token()

      return 1
    return 0

  def __str__ (self):
    """def: __str__"""
    global INDENT

    INDENT += 2

    str = ''
    for m_var in self.m_variables:
      str += '{str}'.format(str=m_var)

    INDENT -= 2

    return str
  
#-------------------------------------------------------------------------------
# Class Variables
#-------------------------------------------------------------------------------
class ClassVars(Variables):
  """class: ClassVars"""

  def __init__(self, **kwargs):
    """Constructor:"""
    super(ClassVars, self).__init__(**kwargs)
    self.rand = None
    # protected/public/local
    self.visibility = 'public' # default
    # Static variables
    self.static = None

  def __call__ (self):
    """def: __call__"""

    return self._parse()
    
  def is_cls_handle (self):
    """ is_cls_handle:
        Check if variable is class handle
    """

    #-------------------------------------------------------------------------------
    # Get list of svtags directories
    svtagsdirs = []
    envutil_path = '{kp_vim_home}/python_lib/vim/lib/Utils/env_vars.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
    envutil = import_(envutil_path)
    svtagsdirs.extend(envutil.env2path('SVTAGSPATH'))
    #-------------------------------------------------------------------------------

    # Check for class type from all the clstree/_main.py scripts in all svtags dir
    cls_found = 0
    for path in svtagsdirs:
      clstree_file = "{0}/clstree/_main.py".format(path)
      try:
        clstree = import_(clstree_file)
        cls_found = clstree.is_cls(self.datatype)
      except Exception as e:
        pass
      
      if cls_found: return 1
    
    return 0
        
  def _parse (self):
    """def: _parse"""
    start = None

    lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer

    if self.is_kw('static'):
      start = self.m_lexer.m_token.start
      self.static = 'static'
      if not self.m_lexer.next_token(1) : return 0

    if self.is_kw('rand'):
      if start == None:
        start = self.m_lexer.m_token.start
      self.rand = 'rand'
      if not self.m_lexer.next_token(1) : return 0

    if self.is_kw('local') or self.is_kw('protected') or self.is_kw('public'):
      if start == None:
        start = self.m_lexer.m_token.start

      self.visibility = self.m_lexer.m_token.text
      if not self.m_lexer.next_token(1) : return 0

    if self.rand:
      if not (self.is_datatype() or self.is_user_datatype(self.clsname)): 
        self.expect_tag('DATATYPE')

    ret = super(ClassVars, self)._parse()
    if ret == 1 and start != None:
      lexer_pos_bkp = None
      self.start = start
      self.m_variables[0].start = start

      #-------------------------------------------------------------------------------
      # Debug
      #Logger().buffer.name = 'ClassVars'
      Logger().set('ClassVars')
      #-------------------------------------------------------------------------------
    elif self.rand and ret == 0:
      self.expect_tag('VARIABLE')
      self.m_lexer.set_pos(lexer_pos_bkp)

    return ret

  def __str__ (self):
    """def: __str__"""

    global INDENT
    INDENT += 2
    str = '{indent}'.format(indent=" " * INDENT)
    INDENT -= 2

    if self.static:
      str += '@{static} '.format(static=self.static)

    if self.rand:
      str += '@{rand} '.format(rand=self.rand)

    str += '@{visibility} \n'.format(visibility=self.visibility)

    str += super(ClassVars, self).__str__()

    return str

class Typedef(ClassVars):
  """class: Typedef"""

  def __call__ (self):
    """def: __call__"""

    return self._parse()
    
  def _parse (self):
    """def: _parse"""
    if self.is_kw('typedef'):
      start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(): return 0
      
      ret = super(Typedef, self)._parse()
      if ret:
        self.start = start
        for var in self.m_variables:
          var.start = start

      return ret
    return 0

  def __str__ (self):
    """def: __str__"""
    
    global INDENT
    INDENT += 2
    str = '{indent}'.format(indent=" " * INDENT)
    INDENT -= 2

    str += '@{typedef} \n'
    str += super(ClassVars, self).__str__()
    return str


class Arguments(VariablesBase):
  """class: Arguments"""

  def __init__(self, **kwargs):
    """ Constructor: """
    super(Arguments, self).__init__(**kwargs)
    self.m_arguments = []

  def _parse_direction (self):
    """def: _parse_direction"""
    
    ret = None
    direction = None
    start = None

    if self.is_kw('ref'):
      ret = 'ref'
      start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(): return 0
      return (start, ret, None)

    if self.is_kw('input') or self.is_kw('output') or self.is_kw('inout'):
      direction = self.m_lexer.m_token.text
      start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(): return 0
      return (start, None, direction)

    return None

    
  def __call__ (self):
    """def: __call__"""

    ref = None
    const = None
    direction = None
    enum = None
    datatype = None
    m_acls_params = None
    packed = None
    enum_range = None

    if self.is_kw('('):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0

      #### arg_start = 1
      while not (self.is_kw(')')):
        name = None
        unpacked = None
        default = None
        start = None

        # Optional `const` keyword : `function automatic drive(const bit data[])`
        if self.is_kw('const'):
          self.const = 'const'
          if not self.m_lexer.next_token(1): return 0

        ret_tuple = self._parse_direction()
        if ret_tuple: 
          start, ref, direction = ret_tuple

        #### FIX: Datatype for argument of function/task are optional, default is bit.
        #### if arg_start:
        ####   arg_start = 0
        ####   if not (self.is_datatype() or self.is_user_datatype(self.clsname)): 
        ####     self.expect_tag('DATATYPE')

        ret_tuple = self._parse_datatype()
        if ret_tuple:
          _, enum, datatype, signing, m_acls_params, packed, enum_range,_ = ret_tuple
          if start == None:
            start = ret_tuple[0]
          
        if start == None:
          start = self.m_lexer.m_token.start

        if not self.expect_tag (IDENTIFIER): return 0
        name = self.m_lexer.m_token.text
        if not self.m_lexer.next_token(1): return 0
        
        unpacked = self.skip_block('[', ']')

        default = self._parse_default()

        end = self.m_lexer.m_token.prev_end
        m_argument = Argument(ref=ref, direction=direction, enum=enum, enum_range=enum_range, datatype=datatype, m_acls_params=m_acls_params, packed=packed, name=name, unpacked=unpacked, default=default, start=start, end=end)
        self.m_arguments.append(m_argument)

        if self.is_kw(','):
          if not self.m_lexer.next_token(1) : return 0
          start = self.m_lexer.m_token.start
        else:
          if not self.expect_kw (')'): return 0

      self.end = self.m_lexer.m_token.end
      if not self.expect_kw (')'): return 0
      self.m_lexer.next_token()

      return 1
    return 0
        
  def __str__ (self):
    """def: __str__"""
    global INDENT

    INDENT += 2

    str = '{indent}@start{start} @end{end}\n'.format(indent=" " * INDENT, start=self.start, end=self.end)
    for m_var in self.m_arguments:
      str += '{str}'.format(str=m_var)

    INDENT -= 2

    return str
  
class Function(Parser):
  """class: Function"""

  def __init__(self, **kwargs):
    """Constructor:"""
    super(Function, self).__init__(**kwargs)
    self.m_return_type = None
    self.clsname = None
    self.name = None
    self.automatic = None
    self.m_arguments = None

  def _parse_returntype (self):
    """def: _parse_returntype"""
    #-------------------------------------------------------------------------------
    # Return Type
    if not self.is_kw('void'):
      if not self.clsname: 
        clsname = '*'
      else:
        clsname = self.clsname
        
      # clsname is used to identify class local userdatatypes (parameterized type)
      # Currently wildcard "*" is used in clsname to search for datatype in all classes
      # instead of current class only. Maybe this logic updated in future. 
      # For extern functions the class name comes after return type which also may be local
      # class userdatatype. Not sure how to handle this if go with current class only instead
      # of wildcard. Example: `function TYPE clsname::funname(...);`
      m_var_base = VariablesBase(m_lexer=self.m_lexer, clsname=clsname) 

      ret_tuple = m_var_base._parse_datatype()
      if not ret_tuple:
        self.expect_tag ('RETURN_TYPE')
        return 0

      start, enum, datatype, signing, m_acls_params, packed, enum_range, end = ret_tuple
      self.m_return_type = Datatype(enum=enum, enum_range=enum_range, datatype=datatype, signing=signing, m_acls_params=m_acls_params, packed=packed, start=start, end=end)
    else:
      if not self.m_lexer.next_token(1): return 0
    #-------------------------------------------------------------------------------

  def _parse_extern_classname (self):
    """def: _parse_extern_classname"""
    lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer
    
    #-------------------------------------------------------------------------------
    # For Extern Function --> Class::Function()
    # if self.is_user_datatype(): # ==> This was failing with `function cls_name::new();`
    if self.is_tag(IDENTIFIER):
      clsname = self.m_lexer.m_token.text
      #if not self.lex_user_datatype(): return 0 # Note: lex_user_datatype instead of m_lexer.next_token
      if not self.m_lexer.next_token(1): return 0

      if not self.is_kw ('::'):
        self.m_lexer.set_pos(lexer_pos_bkp)
        return 0
      self.clsname = clsname
      if not self.m_lexer.next_token(1): return 0
    #-------------------------------------------------------------------------------
    
  def _parse_args (self):
    """def: _parse_args"""
    clsname = self.clsname
    if not clsname : clsname = '*'
      

    m_arguments = Arguments(m_lexer=self.m_lexer, clsname=clsname)
    if m_arguments():
      self.m_arguments = m_arguments

  def _parse_footer (self):
    """def: _parse_footer"""
    if not self.is_kw('endfunction'): return 0

    if not self.m_lexer.next_token(1) : pass # Don't return 0 if this fails.. Since this may be the end of file also

    # Optional `endfunction : fun_name`
    if self.is_kw(':'):
      if not self.m_lexer.next_token(1) : return 0

      if not self.is_kw('new') : # Note: `new` is keyword not identifier and `new` is also expected here.. 
        if not self.expect_tag (IDENTIFIER): return 0 
      if not self.m_lexer.next_token() : pass # Don't return 0 if this fails.. Since this may be the end of file also

    self.end = self.m_lexer.m_prev_token.end
    return 1
      
  def _parse_header (self):
    """def: _parse_header"""
    if self.is_kw('function'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0

      # Option `automatic` keyword
      if self.is_kw('automatic'):
        self.automatic = 'automatic'
        if not self.m_lexer.next_token(1): return 0

      self._parse_returntype()

      self._parse_extern_classname()

      if not self.expect_tag (IDENTIFIER): return 0
      self.name = self.m_lexer.m_token.text
      if not self.m_lexer.next_token(1): return 0

      self._parse_args()

      if not self.expect_tag (EOS): return 0
      self.end = self.m_lexer.m_token.end
      self.m_lexer.next_token()
      return 1
    return 0

      
  def __call__ (self):
    """def: __call__"""
    return self._parse()
    
  def _parse (self):
    """def: _parse"""
    if self._parse_header():
      return 1 # TODO: Complete fun parsing
    return 0
    
  def __str__ (self):
    """def: __str__"""
    str = "{indent}<function name='{name}' clsname='{clsname}'>\n".format(indent=" " * INDENT, name=self.name, clsname=self.clsname)
    if self.m_arguments != None:
      str += "\n{indent}{arg}\n".format(indent=" " * INDENT, arg=self.m_arguments)

    str += '\n{indent}  @ret'.format(indent=" " * INDENT)
    str += "{indent}  {ret}\n".format(indent=" " * INDENT, ret=self.m_return_type)
      
    str += "{indent}  <start=\"{start[0]}, {start[1]}\">".format(indent=" " * INDENT, start=self.start )
    str += "{indent}  <end=\"{end[0]}, {end[1]}\">\n".format(indent=" " * INDENT, end=self.end )
    str += "{indent}</function>".format(indent=" " * INDENT)
    return str

#-------------------------------------------------------------------------------
# Property
class Property(Parser):
  """class: Property"""

  def __init__(self, **kwargs):
    """Constructor:"""
    super(Property, self).__init__(**kwargs)
    self.name = None
    self.automatic = 'automatic'
    self.m_arguments = None

  def _parse_header (self):
    """def: _parse_header"""

    # Note: skip `TAG: assert property()`
    if self.is_kw('property') and not self.is_prev_kw('assert'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0

      if not self.expect_tag (IDENTIFIER): return 0
      self.name = self.m_lexer.m_token.text
      if not self.m_lexer.next_token(1): return 0

      m_arguments = Arguments(m_lexer=self.m_lexer)
      if m_arguments():
        self.m_arguments = m_arguments

      if not self.expect_tag (EOS): return 0
      self.end = self.m_lexer.m_token.end
      self.m_lexer.next_token()
      return 1
    return 0

      
  def __call__ (self):
    """def: __call__"""
    return self._parse ()
    
  def _parse (self):
    """def: _parse"""
    if self._parse_header():
      return 1 # TODO: Complete fun parsing
    return 0
    
  def __str__ (self):
    """def: __str__"""
    str = "{indent}<task name='{name}' >\n".format(indent=" " * INDENT, name=self.name )
    if self.m_arguments != None:
      str += "\n{indent}{arg}\n".format(indent=" " * INDENT, arg=self.m_arguments)

    str += "{indent}  <start=\"{start[0]}, {start[1]}\">".format(indent=" " * INDENT, start=self.start )
    str += "{indent}  <end=\"{end[0]}, {end[1]}\">\n".format(indent=" " * INDENT, end=self.end )
    str += "{indent}</task>".format(indent=" " * INDENT)
    return str

#-------------------------------------------------------------------------------

class Task(Parser):
  """class: Task"""

  def __init__(self, **kwargs):
    """Constructor:"""
    super(Task, self).__init__(**kwargs)
    self.clsname = None
    self.name = None
    self.automatic = 'automatic'
    self.m_arguments = None

  def _parse_extern_classname (self):
    """def: _parse_extern_classname"""
    lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer
    
    #-------------------------------------------------------------------------------
    # For Extern Function --> Class::Function()
    # if self.is_user_datatype(): # ==> This was failing with `function cls_name::new();`
    if self.is_tag(IDENTIFIER):
      clsname = self.m_lexer.m_token.text
      #if not self.lex_user_datatype(): return 0 # Note: lex_user_datatype instead of m_lexer.next_token
      if not self.m_lexer.next_token(1): return 0

      if not self.is_kw ('::'):
        self.m_lexer.set_pos(lexer_pos_bkp)
        return 0
      self.clsname = clsname
      if not self.m_lexer.next_token(1): return 0
    #-------------------------------------------------------------------------------
    
  def _parse_footer (self):
    """def: _parse_footer"""
    if not self.is_kw('endtask'): return 0

    if not self.m_lexer.next_token(1) : pass # Don't return 0 if this fails.. Since this may be the end of file also

    # Optional `endtask : task_name`
    if self.is_kw(':'):
      if not self.m_lexer.next_token(1) : return 0

      if not self.expect_tag (IDENTIFIER): return 0
      if not self.m_lexer.next_token() : pass # Don't return 0 if this fails.. Since this may be the end of file also

    self.end = self.m_lexer.m_prev_token.end
    return 1
      
  def _parse_header (self):
    """def: _parse_header"""
    if self.is_kw('task'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0

      # Option `automatic` keyword
      if self.is_kw('automatic'):
        self.automatic = 'automatic'
        if not self.m_lexer.next_token(1): return 0

      self._parse_extern_classname()
      # || #-------------------------------------------------------------------------------
      # || # For Extern Task --> Class::Task()
      # || if self.is_user_datatype():
      # ||   self.clsname = self.m_lexer.m_token.text
      # ||   if not self.lex_user_datatype(): return 0 # Note: lex_user_datatype instead of m_lexer.next_token

      # ||   if not self.expect_kw ('::'): return 0
      # ||   if not self.m_lexer.next_token(1): return 0
      # || #-------------------------------------------------------------------------------

      if not self.expect_tag (IDENTIFIER): return 0
      self.name = self.m_lexer.m_token.text
      if not self.m_lexer.next_token(1): return 0

      clsname = self.clsname
      # FIXME: clsname is used to search for datatypes local to the class. wildcard is passed to look into all the classes if clsname is not provided
      if not clsname: clsname = '*' 
        
      m_arguments = Arguments(m_lexer=self.m_lexer, clsname=clsname)
      if m_arguments():
        self.m_arguments = m_arguments

      if not self.expect_tag (EOS): return 0
      self.end = self.m_lexer.m_token.end
      self.m_lexer.next_token()
      return 1
    return 0

      
  def __call__ (self):
    """def: __call__"""
    return self._parse ()
    
  def _parse (self):
    """def: _parse"""
    if self._parse_header():
      return 1 # TODO: Complete fun parsing
    return 0
    
  def __str__ (self):
    """def: __str__"""
    str = "{indent}<task name='{name}' clsname='{clsname}'>\n".format(indent=" " * INDENT, name=self.name, clsname=self.clsname)
    if self.m_arguments != None:
      str += "\n{indent}{arg}\n".format(indent=" " * INDENT, arg=self.m_arguments)

    str += "{indent}  <start=\"{start[0]}, {start[1]}\">".format(indent=" " * INDENT, start=self.start )
    str += "{indent}  <end=\"{end[0]}, {end[1]}\">\n".format(indent=" " * INDENT, end=self.end )
    str += "{indent}</task>".format(indent=" " * INDENT)
    return str


class ClassFunction(Function):
  """class: ClassFunction"""

  def __init__(self, **kwargs):
    """Constructor:"""
    super(ClassFunction, self).__init__(**kwargs)
    self.pure = None
    self.virtual = None
    self.extern = None
    self.static = None
    self.visibility = None # private, protected or local

  def parse_fun_without_ret_type (self):
    """def: parse_fun_without_ret_type"""

    if self.is_kw('function'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0

      self._parse_extern_classname()

      if not self.is_kw('new'):
        if not self.expect_tag (IDENTIFIER): return 0
      self.name = self.m_lexer.m_token.text
      if not self.m_lexer.next_token(1): return 0

      self._parse_args()

      if not self.expect_tag (EOS): return 0
      self.end = self.m_lexer.m_token.end
      self.m_lexer.next_token()
      return 1
    return 0

  def is_fun_without_ret_type (self):
    """def: is_fun_without_ret_type"""
    lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer
    ret = 0
    if self.is_kw('function'):
      if not self.m_lexer.next_token(1): ret = 0
      if not self.is_tag(IDENTIFIER): ret = 0
      if not self.m_lexer.next_token(1): ret = 0
      if self.is_kw('::'):
        if not self.m_lexer.next_token(1): ret = 0
        if not self.is_tag(IDENTIFIER): ret = 0
        if not self.m_lexer.next_token(): ret = 0
      # FIX: ```function new;``` --> Here () are optional so EOS expected
      if self.is_kw('(') or self.is_tag(EOS): ret = 1
    else:
      ret = 0

    self.m_lexer.set_pos(lexer_pos_bkp)
    return ret
        

  def _parse_header (self):
    """def: _parse_header"""
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
      
      if self.is_kw('pure'):
        self.pure = 1
        if not start:
          start = self.m_lexer.m_token.start

      if self.is_kw('virtual'):
        self.virtual = 1
        if not start:
          start = self.m_lexer.m_token.start
      
      if self.is_kw('static'):
        self.static = 1
        if not start:
          start = self.m_lexer.m_token.start

      if not self.m_lexer.next_token(1): return 0

    # Function without return type.
    # example: `function new();` or `function display();`
    # if self.m_lexer.is_match(r'<function\_s+%(\w+\_s*::\_s*)?\w+\_s*\('):
    if self.is_fun_without_ret_type():
      ret = self.parse_fun_without_ret_type()
    else:
      ret = super(ClassFunction, self)._parse_header()

    if ret:
      lexer_pos_bkp = None
      if start:
        self.start = start
    else:
      if self.extern and not self.is_kw('task'): # Extern is only applicables to methods
        if not self.expect_tag ('FUNCTION/TASK'): return 0
      self.m_lexer.set_pos(lexer_pos_bkp)
    
    return ret
    
  def __call__ (self):
    """def: __call__"""
    return self._parse()

  def _parse (self):
    """def: _parse"""
    #Logger().buffer.name = 'ClassFunction' # Debug
    Logger().set('ClassFunction') # Debug

    if self._parse_header():
      return 1 # TODO: Complete fun parsing (Don't parse footer for pure methods)
    return 0
    
  def __str__ (self):
    """def: __str__"""
    str = ''
    if self.extern:
      str += '@extern '

    if self.visibility:
      str += '@visibility={visibility} '.format(visibility=self.visibility)

    if self.virtual:
      str += '@virtual={virtual} '.format(virtual=self.virtual)

    if self.static:
      str += '@static={static} '.format(static=self.static)

    str += '\n'

    str += super(ClassFunction, self).__str__()

    return str

class ClassTask(Task):
  """class: ClassTask"""

  def __init__(self, **kwargs):
    """Constructor:"""
    super(ClassTask, self).__init__(**kwargs)
    self.pure = None
    self.virtual = None
    self.extern = None
    self.static = None
    self.visibility = None # private, protected or local

  def _parse_header (self):
    """def: _parse_header"""
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
      
      if self.is_kw('pure'):
        self.pure = 1
        if not start:
          start = self.m_lexer.m_token.start

      if self.is_kw('virtual'):
        self.virtual = 1
        if not start:
          start = self.m_lexer.m_token.start
      
      if self.is_kw('static'):
        self.static = 1
        if not start:
          start = self.m_lexer.m_token.start

      if not self.m_lexer.next_token(1): return 0

    ret = super(ClassTask, self)._parse_header()

    if ret:
      lexer_pos_bkp = None
      if start:
        self.start = start
    else:

      if self.extern and not self.is_kw('task'): # Extern is only applicables to methods
        if not self.expect_tag ('FUNCTION/TASK'): return 0
      self.m_lexer.set_pos(lexer_pos_bkp)
    
    return ret
    
  def __call__ (self):
    """def: __call__"""
    return self._parse()

  def _parse (self):
    """def: _parse"""
    #Logger().buffer.name = 'ClassTask' # Debug
    Logger().set('ClassTask') # Debug

    if self._parse_header():
      return 1 # TODO: Complete fun parsing
    return 0
    
  def __str__ (self):
    """def: __str__"""
    str = ''
    if self.extern:
      str += '@extern '

    if self.visibility:
      str += '@{visibility} '.format(visibility=self.visibility)

    if self.virtual:
      str += '@{virtual} '.format(virtual=self.virtual)

    if self.static:
      str += '@{static} '.format(static=self.static)

    str += '\n'

    str += super(ClassTask, self).__str__()

    return str

class Parameter(Variables):
  """class: Parameter"""

  def __init__(self, **kwargs):
    """Constructor:"""
    super(Parameter, self).__init__(**kwargs)
    
  def _parse (self):
    """def: _parse"""
    if self.is_kw('parameter'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0

      ret = super(Parameter, self)._parse()

      # Parameter with datatype
      # example `parameter int WIDTH = 5;`
      if ret:
        for var in self.m_variables:
          var.start = self.start

      #-------------------------------------------------------------------------------
      # Not all parameter declaration will have datatype.
      # example: `parameter WIDTH = 5;`
      # example: `parameter [3:0] WIDTH = 5;`
      # TODO: Default parameter should be int???
      else:
        packed = None
        unpacked = None
        datatype = 'int' # Default datatype???

        if self.is_datatype():
          datatype = self.m_lexer.m_token.text
          if not self.m_lexer.next_token(1): return 0
          
        block_pos = self.skip_block('[', ']')
        if block_pos: # packed range of variable
          packed = block_pos

        if not self.expect_tag(IDENTIFIER): return 0
        name = self.m_lexer.m_token.text
        if not self.m_lexer.next_token(1): return 0
        
        block_pos = self.skip_block('[', ']')
        if block_pos: # unpacked range of variable
          unpacked = block_pos
        
        default = self._parse_default()

        self.end = self.m_lexer.m_token.end

        m_variable = Variable(datatype='int', name=name, unpacked=unpacked, default=default, start=self.start, end=self.end)

        self.m_variables.append(m_variable)
        #-------------------------------------------------------------------------------
      return 1


    return 0
    
class Const(Variables):
  """class: Const"""

  def __init__(self, **kwargs):
    """Constructor:"""
    super(Const, self).__init__(**kwargs)
    
  def _parse (self):
    """def: _parse"""
    if self.is_kw('const'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0
      
      ret = super(Const, self)._parse()
      # Const with datatype
      # example `parameter int WIDTH = 5;`
      if ret:
        for var in self.m_variables:
          var.start = self.start

      return ret

    return 0
    
class Macro(Parser):
  """class: Macro"""

  name_re = re.compile('\s*`define\s+(\w+)')

  def __init__(self, **kwargs):
    super(Macro, self).__init__(**kwargs)
    self.name = None
    self.text = None

  def _parse (self):
    """def: _parse"""
    if self.is_tag(DEFINE): # Macro `define... lexer returns all continue lines in `define
      match = Macro.name_re.match(self.m_lexer.m_token.text)
      self.m_lexer.next_token() # Don't return 0 on EOP
      if match:
        self.name = match.group(1)
        self.text = self.m_lexer.m_prev_token.text # m_prev_token since lexer has been advanced previously
        self.start = self.m_lexer.m_prev_token.start
        self.end = self.m_lexer.m_prev_token.end
        return 1
    return 0

  def __call__ (self):
    """def: __call__"""
    return self._parse()

#-------------------------------------------------------------------------------
# Covergroup
#-------------------------------------------------------------------------------
class Covergroup(Parser):
  """class: Covergroup"""

  def __init__(self, **kwargs):
    super(Covergroup, self).__init__(**kwargs)
    self.name = None
    self.args = None
    self.clsname = None
    
  def _parse_header (self):
    """def: _parse_header"""
    if self.is_kw('covergroup'):
      self.start = self.m_lexer.m_token.start
      if not self.m_lexer.next_token(1): return 0
      if not self.expect_tag(IDENTIFIER): return 0
      self.name = self.m_lexer.m_token.text
      if not self.m_lexer.next_token(1): return 0

      # `covergroup cvg @(event_e);`
      if self.is_kw('@'):
        if not self.m_lexer.next_token(1): return 0
        
      # `covergroup cvg with function sample();`
      if self.is_kw('with'):
        if not self.m_lexer.next_token(1): return 0

        if not self.expect_kw('function'): return 0
        if not self.m_lexer.next_token(1): return 0

        if not self.expect_tag(IDENTIFIER): return 0
        if not self.m_lexer.next_token(1): return 0

      # Optional argument
      self.args = self.skip_block('(', ')')

      while not self.is_kw(';'): # FIX: This while block is included because == covergroup cov2 @ m_protected_bit; == statement is also valid.
        if not self.m_lexer.next_token(1): return 0

      if not self.expect_kw(';'): return 0
      self.end = self.m_lexer.m_token.end

  def _parse_footer (self):
    """def: _parse_footer"""
    if not self.is_kw('endgroup'): return 0

    if not self.m_lexer.next_token(): pass # Don't return 0 if this fails.. Since this may be the end of file also

    # Optional `endgroup : cgtag`
    if self.is_kw(':'):
      if not self.m_lexer.next_token() : return 0

      if not self.expect_tag (IDENTIFIER): return 0
      if not self.m_lexer.next_token() : pass # Don't return 0 if this fails.. Since this may be the end of file also

    self.end = self.m_lexer.m_prev_token.end
    return 1

if __name__ == "__main__":
  def ParseArgs (args):
    files = []
    fileexts = ('.sv', '.svh', '.svi', '.v')

    """def: ParseArgs"""
    for arg in args:
      if os.path.isfile(arg):
        if arg.endswith(fileexts):
          afile = os.path.abspath(arg)
          files.append(afile)
      else:
        print "Error: can't find file {file} !!!".format(file=arg)
        traceback.print_stack(file=sys.stdout)
        quit()

    files = list(set(files))
    return files

  m_logger = Logger()
  m_logger.debug_mode(1)

  files = ParseArgs(sys.argv[1:])

  if vim_detected:
    m_lexer = Lexer()
  else:
    m_lexer = Lexer(filehandle=open(files[0], 'rb'))

  m_lexer.next_token()
  m_logger.append(str(m_lexer.m_token))

  while 1:
    
    m_comments = Comments(m_lexer=m_lexer)
    if m_comments():
      m_comments.highlight('DiffAdd')
      m_logger.append(str(m_comments))
      continue

    m_class = Class(m_lexer=m_lexer)
    if m_class._parse_header():
      m_class.highlight('DiffAdd')
      m_logger.append(str(m_class))
      continue

    m_typedef = Typedef(m_lexer=m_lexer)
    if m_typedef():
      m_typedef.highlight('DiffAdd')
      m_logger.append(str(m_typedef))
      continue

    #m_var = Variables(m_lexer)
    m_var = ClassVars(m_lexer=m_lexer)
    if m_var():
      m_var.highlight('DiffAdd')
      m_logger.append(str(m_var))
      continue

    # || m_arg = Arguments(m_lexer)
    # || if m_arg ():
    # ||   m_arg.highlight('DiffAdd')
    # ||   continue

    # || ################################### Non class function/task
    # || m_fun = Function(m_lexer)
    # || if m_fun():
    # ||   m_fun.highlight('DiffAdd')

    # || m_task = Task(m_lexer)
    # || if m_task():
    # ||   m_task.highlight('DiffAdd')

    m_fun = ClassFunction(m_lexer=m_lexer)
    if m_fun():
      m_fun.highlight('DiffAdd')
      m_logger.append(str(m_fun))
      continue

    m_task = ClassTask(m_lexer=m_lexer)
    if m_task():
      m_task.highlight('DiffAdd')
      m_logger.append(str(m_task))
      continue

    m_intf = Interface(m_lexer=m_lexer)
    if m_intf():
      m_intf.highlight('DiffAdd')
      m_logger.append(str(m_intf))
      continue

    m_macro = Macro(m_lexer=m_lexer)
    if m_macro._parse():
      m_macro.highlight('DiffAdd')
      m_logger.append(str(m_macro))
      continue

    if not m_lexer.next_token(): break




















