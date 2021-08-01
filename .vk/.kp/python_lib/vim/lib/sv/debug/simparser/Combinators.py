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
import sys
from collections import namedtuple
from functools import partial

LEXER = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simparser/Lexer.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
TOKEN = import_('{kp_vim_home}/python_lib/vim/lib/sv/base/lexer/Token.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
LOGGER = import_('{kp_vim_home}/python_lib/vim/lib/sv/base/Singleton.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
SHAREDVARS = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simparser/SharedVars.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))

from Utils import Buffer
#import inspect

class Parser(object):
  """class: Parser"""

  m_logger = LOGGER.Logger()

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
      m_lexer = LEXER.Lexer(start=ln - 1, **kwargs)
      if not m_lexer.next_token() : return 0

    self.m_lexer = m_lexer
    self.fname = vim.current.buffer.name

  def __sh_init__ (self, **kwargs):
    """def: __sh_init__"""
    if vim_detected == 1: return 0
    m_lexer = kwargs.get('m_lexer', None)

    if not m_lexer:
      m_lexer = LEXER.Lexer(**kwargs)
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

    if m_token.tag != exp_tag:
      if m_token.start:
        ln = m_token.start[0]
        cn = m_token.start[1]
      else:
        ln = 0
        cn = 0
        
      errmsg = "# Error: {file}[{line}, {col}] : {linestr}".format(file=self.fname, line=ln, col=cn, linestr=self.m_lexer.line)
      errmsg += 'Expecting {exp} found "{act}" !!\n'.format(exp=exp_tag , act=m_token.text)

      # print 'Expecting {exp} found "{act}" !!\n'.format(exp=exp_tag , act=m_token.text)

      debugsave = Parser.m_logger.debug
      Parser.m_logger.debug_mode(1)

      Parser.m_logger.append(errmsg)

      #frame,filename,line_number,function_name,lines,index = inspect.stack()[1]
      #sys.stderr.write('%s[%s]: In function %s\n' % (filename, line_number, function_name))

      raise Exception (errmsg)

      # Exit on error
      quit()

      Parser.m_logger.debug = debugsave
      return 0
    return 1

  def vi_expect_tag (self ,exp_tag):
    """def: vi_expect_tag"""
    if vim_detected == 0: return 0
      
    m_token = self.m_lexer.m_token

    if m_token.tag != exp_tag:
      errmsg = "# Error: {0}".format(self.get_trace())

      errmsg += 'Expecting {exp} found "{act}" !!\n'.format(exp=exp_tag , act=m_token.text)

      debugsave = Parser.m_logger.debug
      Parser.m_logger.debug_mode(1)

      m_token.highlight('Error')
      Parser.m_logger.append(errmsg)

      vim.command('redraw!')

      # traceback.print_stack(file=sys.stdout)
      raise Exception(errmsg)
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

  def get_trace (self):
    """def: get_trace"""
    m_token = self.m_lexer.m_token
    msg = "{file}[{line}, {col}] : {linestr}".format(file=self.fname, line=m_token.start[0], col=m_token.start[1], linestr=self.m_lexer.m_token_gen.line)
    return msg
    
  def vi_expect_kw (self, exp_kw):
    """def: expect_tag"""
    if vim_detected == 0: return 0

    m_token = self.m_lexer.m_token

    if m_token.text != exp_kw:
      errmsg = "# Error: {0}".format(self.get_trace())
      print errmsg

      debugsave = Parser.m_logger.debug
      Parser.m_logger.debug_mode(1)

      m_token.highlight('Error')
      Parser.m_logger.append(errmsg)

      vim.command('redraw!')

      #frame,filename,line_number,function_name,lines,index = inspect.stack()[1]
      #sys.stderr.write('%s[%s]: In function %s\n' % (filename, line_number, function_name))
      #sys.stderr.write('Expecting {exp} found {act}!!\n'.format(exp=exp_kw , act=m_token.text))

      vim.command('call input("Press Enter")')

      Parser.m_logger.debug = debugsave
      return 0
    return 1

  def sh_expect_kw (self, exp_kw):
    """def: expect_tag"""
    if vim_detected == 1: return 0
      
    m_token = self.m_lexer.m_token

    if m_token.text != exp_kw:
      errmsg = "# Error: {0}".format(self.get_trace())
      errmsg += 'Expecting {exp} found {act}!!\n'.format(exp=exp_kw , act=m_token.text)

      debugsave = Parser.m_logger.debug
      Parser.m_logger.debug_mode(1)

      Parser.m_logger.append(errmsg)

      #frame,filename,line_number,function_name,lines,index = inspect.stack()[1]
      #sys.stderr.write('%s[%s]: In function %s\n' % (filename, line_number, function_name))
      # sys.stderr.write('Expecting {exp} found {act}!!\n'.format(exp=exp_kw , act=m_token.text))
      raise Exception( errmsg )

      Parser.m_logger.debug = debugsave
      quit()

      return 0
    return 1

  def expect_kw (self, exp_kw):
    """def: expect_kw"""
    if self.vi_expect_kw (exp_kw): return 1
    if self.sh_expect_kw (exp_kw): return 1
    return 0
    
  def highlight (self, group_name, **kwargs):
    """def: highlight"""
    if vim_detected == 0: return 0
      

    # Not in debug mode
    m_logger = LOGGER.Logger()
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
    
  # Is start of line in log file (column 1)
  def is_sol (self):
    """def: is_sol"""
    if self.is_tag(SHAREDVARS.EOP): return 0
      
    if self.m_lexer.m_token.start[1] == 1 : return 1
    return 0
        
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

  # || def skip_line (self):
  # ||   """def: skip_line"""
  # ||   text = ''
  # ||   prev_token = None
  # ||   while not self.m_lexer.m_token.isnewline:
  # ||     if prev_token:
  # ||       spaces = ' ' * (self.m_lexer.m_token.start[1] - prev_token.end[1] - 1)
  # ||       text += '{0}{1}'.format(spaces, self.m_lexer.m_token.text)
  # ||     else:
  # ||       text += self.m_lexer.m_token.text 

  # ||     prev_token = self.m_lexer.m_token
  # ||     if not self.m_lexer.next_token() : return None
  # ||     
  # ||   return text

  def skip_iblock (self, start_kw, end_kw):
    """def: skip_iblock
       Examples: (<text to be skipped>), [<text to be skipped>], {<text to be skipped>}
    """
    if self.m_lexer.m_prev_token.text == start_kw:
      m_container = Container(self.m_lexer)

      #m_container.append_token(self.m_lexer.m_token)
      # if not m_container.next_token() : return 0

      while self.m_lexer.m_token.text != end_kw:
        # Skip sub blocks if any

        # if m_container.skip_block('#(', ')'): continue

        if m_container.skip_block('[', ']'): continue

        if m_container.skip_block('(', ')'): continue

        if m_container.skip_block('{', '}'): continue

        m_container.append_token(self.m_lexer.m_token)
        if not self.m_lexer.next_token() : return 0

      m_container.skip_block(start_kw, end_kw) # Skip sibling blocks if any

      #m_container.pop_back()
      return m_container.text_token()

    return None

  def skip_block (self, start_kw, end_kw):
    """def: skip_block"""
    if self.m_lexer.m_token.text == start_kw:
      m_container = Container(self.m_lexer)

      m_container.append_token(self.m_lexer.m_token)
      #if not m_container.next_token() : return 0
      if not self.m_lexer.next_token() : return 0

      while self.m_lexer.m_token.text != end_kw:
        # Skip sub blocks if any

        # if m_container.skip_block('#(', ')'): continue

        if m_container.skip_block('[', ']'): continue

        if m_container.skip_block('(', ')'): continue

        if m_container.skip_block('{', '}'): continue

        m_container.append_token(self.m_lexer.m_token)
        if not self.m_lexer.next_token() : return 0

      m_container.append_token(self.m_lexer.m_token)
      if not self.m_lexer.next_token() : return 0

      m_container.skip_block(start_kw, end_kw) # Skip sibling blocks if any

      return m_container.text_token()

    return None

  def lookhead (self, fun):
    """def: lookhead
       This takes parser function as argument and checks whether it is successfull
       without moving the lexer position
    """
    lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer

    try:
      ret = fun()
    except Exception:
      ret = 0

    self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer
    return ret

    
  def tryparse (self, fun):
    """def: tryparse
       This function saves the lexer and try to parse the function. Restore lexer
       on fail
    """
    lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer
    try:
      if not fun():
        self.m_lexer.set_pos(lexer_pos_bkp) # Restore Lexer
        return 0
    except Exception:
      return 0
    return 1
    

#-------------------------------------------------------------------------------
# Container
#-------------------------------------------------------------------------------
class Container(Parser):
  """class: Container
     This class retains all the text parsed by it using lexer.
  """

  def __init__(self, m_lexer):
    self.m_lexer = m_lexer
    # start = self.m_lexer.m_token.start
    # end = self.m_lexer.m_token.end
    # text = self.m_lexer.m_token.text
    # m_wspace = self.m_lexer.m_token.m_wspace
    # m_text = TOKEN.Text(text, start, end, m_wspace)
    self.m_texts = []

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
    if not self.m_lexer.skip_line(): return None
    self.append_token(self.m_lexer.m_token)
    return self.m_lexer.m_token

  # Text token after removing spaces at the beginning
  def trimed_text_token (self): 
    """def: trimed_text_token"""
    while self.m_texts and type(self.m_texts[0]) == TOKEN.Space:
      self.m_texts.pop(0)

    while self.m_texts and type(self.m_texts[-1]) == TOKEN.Space:
      self.m_texts.pop()

    m_text = self.text_token()
    if not m_text: return None
      
    return m_text

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
    m_text = super(Container, self).skip_block(*args, **kwargs)
    if m_text:
      self.append_token(m_text)
    return m_text

  def pop_back (self):
    """def: pop_back"""
    self.m_texts.pop()
    if type(self.m_texts[-1]) == TOKEN.Space:
      self.m_texts.pop()
    
# || class BlockContainer(Container):
# ||   """class: BlockContainer"""
# || 
# ||   def itext_token (self):
# ||     """def: text_token"""
# ||     if len(self.m_texts) <= 2: return None
# ||       
# ||     text = ''.join([m_text.text for m_text in self.m_texts[1:-2]])
# ||     start = self.m_texts[1].start
# ||     end = self.m_texts[-2].end
# ||     return TOKEN.Text(text, start, end, self.m_texts[1].m_wspace)
# || 
# ||   def block_token (self):
# ||     """def: block_token"""
# ||     m_itext = self.itext_token()
# ||     m_atext = self.text_token()
# ||     return TOKEN.BlockToken(m_atext, m_itext)
    
#-------------------------------------------------------------------------------
# KeywordsGen
#-------------------------------------------------------------------------------
class KeywordsGen(Parser):
  """class: KeywordsGen:
     This class generates list of keywords (KW, TAG from SharedVars) from a given
     text
  """

  def __init__(self, text, *args):
    self.m_lexer = LEXER.Lexer(text=text, lut=SHAREDVARS.AUTOGEN_TOKENS)
    self.__args = args
    self.keywords = []
    self._parse()

  def _parse (self):
    """def: _parse"""
    while self.m_lexer.next_token():
      if self.is_tag(SHAREDVARS.PLACEHOLDER):
          match = SHAREDVARS.PLACEHOLDER_RE.search(self.m_lexer.m_token.text)
          if match:
            idx = int(match.group(1))
            self.keywords.append(self.__args[idx])
          else:
            raise ValueError('Unkown keyword {0}'.format(self.m_lexer.m_token.text))
            
      else:
        self.keywords.append(SHAREDVARS.KW(self.m_lexer.m_token.text))

    return 1

  def __str__ (self):
    """def: __str__"""
    text = ', '.join([str(kw) for kw in self.keywords])
    return text
        
#-------------------------------------------------------------------------------
# TokensGen
#-------------------------------------------------------------------------------
class TokensGen(Parser):
  """class: TokensGen"""

  def __init__(self, m_lexer):
    """__init__:
       Legends:
         Or (*args)             : Any one of the keywords provided in the arguments
         Optional (text, *args) : Optional keywords to parse
         Group (text, *args)    : Matching keywords will be saved in groups
         isinstance(arg, TAG)   : arg is instance of SHAREDVARS.TAG
         isinstance(arg, KW)    : arg is instance of SHAREDVARS.KW
    """
    self.m_lexer = m_lexer
    self.init()

  def init (self):
    """def: init"""
    self.groups = []
    self.m_text = None
    
  def _parse_optional (self, arg):
    """def: _parse_optional"""
    m_tokensgen = TokensGen(self.m_lexer)
    if self.tryparse(partial(m_tokensgen.parse, *arg.args)):
      return m_tokensgen.m_text
    return None

  def _parse_group (self, arg):
    """def: _parse_group"""
    m_tokensgen = TokensGen(self.m_lexer)
    if m_tokensgen.parse(*arg.args):
      self.groups.append(m_tokensgen.m_text)
      return m_tokensgen.m_text
    return None

  def _parse_or (self, arg):
    """def: _parse_or"""
    for kw in arg.args:
      m_tokensgen = TokensGen(self.m_lexer)
      if self.tryparse(partial(m_tokensgen.parse, *arg.args)): 
        return m_tokensgen.m_text
    return None
      
  def _parse_callable (self, arg):
    """def: _parse_callable"""
    return arg()
    
  def _parse_genkeywords (self, arg):
    """def: _parse_genkeywords"""
    m_tokensgen = TokensGen(self.m_lexer)
    if m_tokensgen.parse(*arg.keywords): 
      self.groups.extend(m_tokensgen.groups)
      return m_tokensgen.m_text
    return None

  # TODO: Currently this function always returns 1,
  #       find out a way to return 0 on fail
  def parse (self, *args):
    """def: parse"""
    self.init()

    m_container = Container(self.m_lexer)
    for kw in args:
      if type(kw) == KeywordsGen:
        m_text = self._parse_genkeywords(kw)
        if not m_text: return 0

        m_container.append_token(m_text)
        continue
      elif type(kw) == TOKEN.Group:
        m_text = self._parse_group(kw)
        if not m_text: return 0

        m_container.append_token(m_text)
        continue
      elif type(kw) == TOKEN.Optional:
        m_text = self._parse_optional(kw)
        m_container.append_token(m_text)
        continue
      elif type(kw) == TOKEN.Or:
        m_text = self._parse_or(kw)
        if not m_text: return 0

        m_container.append_token(m_text)
        continue
      elif isinstance(kw, SHAREDVARS.TAG):
        if not self.is_tag(kw.text): return 0
        m_text = self.m_lexer.m_token
      elif isinstance(kw, SHAREDVARS.KW):
        if not self.is_kw(kw.text): return 0
        m_text = self.m_lexer.m_token
      elif callable(kw):
        m_text = self._parse_callable(kw)

        if type(m_text) == TOKEN.Text:
          m_container.append_token(m_text)
        elif type(m_text) == TOKEN.BlockToken:
          m_container.append_token(m_text.m_atext)
        else:
          raise Exception("Invalid type {0}".format(str(kw)))

        continue
      else:
        m_text = None
        #print "Warning: Unknown type {0}".format(str(kw))
        raise Exception("Unknown type {0}".format(str(kw)))

      m_container.append_token(m_text)
      self.m_lexer.next_token()

    # m_container.m_texts.pop()
    self.m_text = m_container.text_token()
    return 1

#-------------------------------------------------------------------------------
# CombinatorGen
#-------------------------------------------------------------------------------
class CombinatorGen(Parser):
  """class: CombinatorGen"""

  def __init__(self, m_lexer):
    """__init__:
       Legends:
         Or (*args)             : Any one of the keywords provided in the arguments
         Optional (text, *args) : Optional keywords to parse
         Group (text, *args)    : Matching keywords will be saved in groups
         isinstance(arg, TAG)   : arg is instance of SHAREDVARS.TAG
         isinstance(arg, KW)    : arg is instance of SHAREDVARS.KW
    """
    self.m_lexer = m_lexer
    super(CombinatorGen, self).__init__(m_lexer=m_lexer)
    self.init()

  def init (self):
    """def: init"""
    self.results = []
    
  def _parse_optional (self, arg):
    """def: _parse_optional"""
    m_comb_gen = CombinatorGen(self.m_lexer)
    if self.tryparse(partial(m_comb_gen.parse, *arg.args)):
      self.results.extend(m_comb_gen.results)
      return 1
    return 0

  def _parse_or (self, arg):
    """def: _parse_or"""
    for kw in arg.args:
      m_comb_gen = CombinatorGen(self.m_lexer)
      if self.tryparse(partial(m_comb_gen.parse, kw)): 
        self.results.extend(m_comb_gen.results)
        return 1
    return 0
      
  def _parse_callable (self, arg):
    """def: _parse_callable"""
    m_result = arg()
    if not m_result: return 0
      
    self.results.append(m_result)
    return 1
    
  def parse (self, *args):
    """def: parse"""
    self.init()

    for kw in args:
      if type(kw) == TOKEN.Optional:
        if self._parse_optional(kw): continue

      elif type(kw) == TOKEN.Or:
        if self._parse_or(kw): continue

      elif callable(kw):
        if self._parse_callable(kw): continue

      else:
        raise Exception("Unknown type {0}".format(str(kw)))

      raise Exception("Can't parse {0} @ {1}".format(type(kw), self.get_trace()))
      #self.m_lexer.next_token()
      return 0

    return 1

#-------------------------------------------------------------------------------
# SvError Parser
#-------------------------------------------------------------------------------
class SvError(Parser):
  """class: SvError"""

  File = namedtuple("File", "filename linenum")

  def __init__(self, **kwargs):
    """Constructor: """
    super(SvError, self).__init__(**kwargs)
    self.trace = [] # List File struct contains filename and linenum
    # self.fname = None
    # self.ln = None
    # self.error_code = None
    self.m_info = None
    self.m_text = None

  def is_start (self):
    """def: is_start"""
    if self.is_sol():
      #m_genkw = KeywordsGen('# ** {0}:'.format(self.__class__.__name__))
      m_genkw = KeywordsGen('# ** Error:')
      m_tokensgen = TokensGen(self.m_lexer)
      if not self.lookhead(partial(m_tokensgen.parse, m_genkw)): return 0
      return 1
    return 0

  def _error1 (self):
    """def: _error1"""
    # If start of line
    if self.is_sol():
      # lexer_pos_bkp = self.m_lexer.get_pos() # Save Lexer

      m_container = Container(self.m_lexer)

      targs = ('** Error: ** while parsing file included at {0}({1})', TOKEN.Group (SHAREDVARS.TAG(SHAREDVARS.FILE)), TOKEN.Group (SHAREDVARS.TAG(SHAREDVARS.NUMBER)), )
      m_genkw = KeywordsGen(*targs)

      m_tokensgen = TokensGen(self.m_lexer)
      while self.tryparse(partial(m_tokensgen.parse, m_genkw)): 
        self.trace.append(SvError.File(filename=m_tokensgen.groups[0], linenum=m_tokensgen.groups[1]))
        m_container.append_token(m_tokensgen.m_text)

        targs = ('** while parsing file included at {0}({1})', TOKEN.Group (SHAREDVARS.TAG(SHAREDVARS.FILE)), TOKEN.Group (SHAREDVARS.TAG(SHAREDVARS.NUMBER)), )
        m_genkw = KeywordsGen(*targs)


      targs = ('** at {0}({1})', TOKEN.Group (SHAREDVARS.TAG(SHAREDVARS.FILE)), TOKEN.Group (SHAREDVARS.TAG(SHAREDVARS.NUMBER)), )
      m_genkw = KeywordsGen(*targs)
      if not self.tryparse(partial(m_tokensgen.parse, m_genkw)): return 0
        
      self.trace.append(SvError.File(filename=m_tokensgen.groups[0], linenum=m_tokensgen.groups[1]))
      m_container.append_token(m_tokensgen.m_text)
      m_container.append_token(self.m_lexer.m_token)

      #m_container.next_token()
      self.m_lexer.next_token()

      m_text = m_container.skip_line()
      m_info_containor = Container(self.m_lexer)
      m_info_containor.append_token(m_text)

      self.m_lexer.next_token()

      while not self.is_sol():
        m_text = m_container.skip_line()
        m_info_containor.append_token(m_text)
        self.m_lexer.next_token()

      self.m_text = m_container.trimed_text_token()
      self.m_info = m_info_containor.trimed_text_token()

      # lexer_pos_bkp = None

      return 1
    return 0

  def _parse (self):
    """def: _parse
    """
    if not self._error1(): return 0 # TODO: Add for other error types
    
    return 1

  def __call__ (self):
    """def: __call__"""
    return self._parse()

  def __str__ (self):
    """def: __str__"""
    text = "{0}\n".format(str(self.m_text.text))
    text += '{0}\n'.format(str(self.trace))
    text += '{0}\n'.format(str(self.m_info.text))
    # text = "{0}({1}): {2}\n".format(self.fname, self.ln, self.text)
    return text
    
#-------------------------------------------------------------------------------
# SvWarning
#-------------------------------------------------------------------------------
class SvWarning(Parser):
  """class: SvWarning"""

  def __init__(self, **kwargs):
    """Constructor: """
    super(SvWarning, self).__init__(**kwargs)
    
  def is_start (self):
    """def: is_start"""
    if self.is_sol():
      #m_genkw = KeywordsGen('# ** {0}:'.format(self.__class__.__name__))
      m_genkw = KeywordsGen('# ** Warning:')
      m_tokensgen = TokensGen(self.m_lexer)
      if not self.lookhead(partial(m_tokensgen.parse, m_genkw)): return 0
      return 1
    return 0


#-------------------------------------------------------------------------------
# UVM Reports
#-------------------------------------------------------------------------------
class ReportToken(object):
  """class: ReportToken"""

  heading = 'severity file_ line time inst_path id_ startline startcol endline endcol info'.split()

  def __init__(self, **kwargs):
    self.severity = kwargs.get('severity', None)
    self.file_     = kwargs.get('file_', None)
    self.line      = kwargs.get('line', None)
    self.time      = kwargs.get('time', None)
    self.inst_path = kwargs.get('inst_path', None)
    self.id_       = kwargs.get('id_', None)
    self.start    = kwargs.get('start', None)
    self.end    = kwargs.get('end', None)
    self.m_info = kwargs.get('m_info', None)
    self.m_text = kwargs.get('m_text', None)

  def get_values (self):
    """def: get_values"""
    m_info_text = None
    if self.m_info:
      m_info_text = self.m_info.text

    # TODO: Only text was stored for Text() objects
    return (self.severity, self.file_, self.line, self.time, self.inst_path, self.id_, self.start[0], self.start[1], self.end[0], self.end[1], m_info_text, )

  def set_values (self, values):
    """def: set_values"""
    severity, file_, line, time, inst_path, id_, startline, startcol, endline, endcol, info = values
    self.severity, self.file_, self.line, self.time, self.inst_path, self.id_ = severity, file_, line, time, inst_path, id_

    self.start = (startline, startcol, )
    self.end = (endline, endcol, )
    self.m_info = TOKEN.Text(info, None, None) # TODO: Only text was stored for Text() object
    
  def update (self, **kwargs):
    """def: update
       Update the attributes
    """
    if 'severity'  in kwargs: self.severity  = kwargs['severity']
    if 'file_'     in kwargs: self.file_     = kwargs['file_']
    if 'line'      in kwargs: self.line      = kwargs['line']
    if 'time'      in kwargs: self.time      = kwargs['time']
    if 'inst_path' in kwargs: self.inst_path = kwargs['inst_path']
    if 'id_'       in kwargs: self.id_       = kwargs['id_']
    if 'start'     in kwargs: self.start     = kwargs['start']
    if 'end'       in kwargs: self.end       = kwargs['end']
    if 'm_info'    in kwargs: self.m_info    = kwargs['m_info']
    if 'm_text'    in kwargs: self.m_text    = kwargs['m_text']
    

  def __str__ (self):
    """def: __str__"""

    # With line number of log file at start
    # text = "# {0}: {1} {2}({3}) @ {4}: {5} [{6}] {7}".format(self.start[0], self.severity, os.path.basename(self.file_), self.line, self.time, self.inst_path, self.id_, self.m_info.text)
    if self.m_info:
      info_txt = self.m_info.text
    else:
      info_txt = None
      
    text = "# {0} {1}({2}) @ {3}: {4} [{5}] {6}".format(self.severity, self.file_, self.line, self.time, self.inst_path, self.id_, info_txt)
    return text

    
class uvm_reporter(Parser):
  """class: uvm_reporter"""

  def __init__(self, **kwargs):
    """Constructor: """
    super(uvm_reporter, self).__init__(**kwargs)
    self.m_report_token = None
    self.m_text = None
    
  def is_start (self):
    """def: is_start"""
    if self.is_sol():
      m_genkw = KeywordsGen('# {0}'.format(self.__class__.__name__))
      m_tokensgen = TokensGen(self.m_lexer)
      if not self.lookhead(partial(m_tokensgen.parse, m_genkw)): return 0
      return 1
    return 0
    
  def parse_header (self):
    """def: parse_header
       Below is defined as header
       UVM_INFO test.sv(1421) @ 4501700000: uvm_test_top.env [ID]
    """
    start = self.m_lexer.m_token.start
    m_container = Container(self.m_lexer)

    m_genkw = KeywordsGen('# %s {0}({1}) @ {2}: {3} [{4}]' % self.__class__.__name__, 
                          TOKEN.Group (SHAREDVARS.TAG(SHAREDVARS.FILE)),
                          TOKEN.Group (SHAREDVARS.TAG(SHAREDVARS.NUMBER)),
                          TOKEN.Group (SHAREDVARS.TAG(SHAREDVARS.NUMBER)),
                          TOKEN.Group (self.parse_inst_path),
                          TOKEN.Group (partial(self.skip_iblock, '[', ']')))

    m_tokensgen = TokensGen(self.m_lexer)
    if not self.tryparse(partial(m_tokensgen.parse, m_genkw)): 
      self.m_report_token = None
      return 0

    m_container.append_token(m_tokensgen.m_text)
    end = m_tokensgen.m_text.end

    file_, line, time, inst_path, id_ = [x.text.strip() for x in m_tokensgen.groups]
    self.m_report_token = ReportToken(severity=self.__class__.__name__, file_=file_, line=line, time=time, inst_path=inst_path, id_=id_, start=start, end=end, m_info=None, m_text=m_container.text_token())

    return 1

  def parse (self):
    """def: parse"""
    if self.is_start():
      if self.parse_header():
        m_container = Container(self.m_lexer)
        m_container.append_token(self.m_report_token.m_text)

        m_info_containor = Container(self.m_lexer)
        m_info_containor.skip_line()

        self.m_lexer.next_token()

        while True:
          # m_reports = [UVM_INFO(m_lexer=self.m_lexer), UVM_ERROR(m_lexer=self.m_lexer), UVM_WARNING(m_lexer=self.m_lexer), UVM_FATAL(m_lexer=self.m_lexer)]
          # Below includes the sv errors and warnings.. but it becomes bit slow. Need a workaround
          m_reports = [UVM_INFO(m_lexer=self.m_lexer), UVM_ERROR(m_lexer=self.m_lexer), UVM_WARNING(m_lexer=self.m_lexer), UVM_FATAL(m_lexer=self.m_lexer), SvError(m_lexer=self.m_lexer), SvWarning(m_lexer=self.m_lexer)]

          for m_uvm_report in m_reports:
            if m_uvm_report.is_start() or self.is_tag(SHAREDVARS.EOP): break

          else:
            m_info_containor.skip_line()
            self.m_lexer.next_token()
            continue
          break
          
        end = self.m_lexer.m_prev_token.end

        m_container.append_token(m_info_containor.text_token())

        m_info = m_info_containor.trimed_text_token()
        self.m_text = m_container.trimed_text_token()
        self.m_report_token.update(end=end, m_info=m_info, m_text=self.m_text)

        return 1
    return 0

  def __str__ (self):
    """def: __str__"""

    return str(self.m_report_token)

  
  def parse_inst_path (self):
    """def: parse_inst_path"""
    m_container = Container(self.m_lexer)
    m_container.append_token(self.m_lexer.m_token)
    while True:
      m_container.next_token()
      # FIXME: Do we need space in instance path???
      if self.m_lexer.m_token.m_wspace: break
        
    m_container.pop_back()
    m_text = m_container.text_token()
    return m_text

class UVM_INFO(uvm_reporter): pass
class UVM_ERROR(uvm_reporter): pass
class UVM_WARNING(uvm_reporter): pass
class UVM_FATAL(uvm_reporter): pass

if __name__ == "__main__":
  def ParseArgs (args):
    files = []
    fileexts = ('.log',)

    """def: ParseArgs"""
    for arg in args:
      if os.path.isfile(arg):
        if arg.endswith(fileexts):
          afile = os.path.abspath(arg)
          files.append(afile)
      else:
        raise Exception("Error: can't find file {file} !!!".format(file=arg))
        # traceback.print_stack(file=sys.stdout)
        quit()

    files = list(set(files))
    return files

  m_logger = LOGGER.Logger()
  m_logger.debug_mode(1)

  files = ParseArgs(sys.argv[1:])

  if vim_detected:
    m_lexer = LEXER.Lexer() # Opens lexer from current line
  else:
    fh = open(files[0], 'rb')
    m_lexer = LEXER.Lexer(filehandle=fh)

  m_lexer.next_token()
  m_logger.append(str(m_lexer.m_token))

  while 1:
    
    # || m_error = Error(m_lexer=m_lexer)
    # || if m_error._parse():
    # ||   print m_error
    # ||   m_error.highlight('DiffAdd')
    # ||   m_logger.append(str(m_error))
    # ||   continue

    m_uvm_info = UVM_INFO(m_lexer=m_lexer)
    if m_uvm_info.parse():
      print m_uvm_info
      m_uvm_info.highlight('DiffAdd')
      m_logger.append(str(m_uvm_info))
      continue

    m_uvm_error = UVM_ERROR(m_lexer=m_lexer)
    if m_uvm_error.parse():
      print m_uvm_error
      m_uvm_error.highlight('DiffAdd')
      m_logger.append(str(m_uvm_error))
      continue

    m_lexer.skip_line()
    if not m_lexer.next_token(): break



















