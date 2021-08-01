#!/usr/bin/env python

#import re
try:
  import vim
  vim_detected = 1
except Exception:
  vim_detected = 0

import os
import sys, traceback
import imp
# cStringIO is faster then StringIO
from cStringIO import StringIO

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

TOKEN = import_('{kp_vim_home}/python_lib/vim/lib/sv/base/lexer/Token.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
LOGGER = import_('{kp_vim_home}/python_lib/vim/lib/sv/base/Singleton.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
SHAREDVARS = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simparser/SharedVars.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))

import itertools

#-------------------------------------------------------------------------------
# FileBuffer
#-------------------------------------------------------------------------------
class FileBuffer(object):
  """class: FileBuffer"""

  def __init__(self, filehandle):
    self.fh = filehandle
    self.offsets = []
    self.offset = 0

  # || def __iter__ (self):
  # ||   """def: __iter__"""
  # ||   if self.offset == 0:
  # ||     self.offsets = []
  # ||     self.fh.seek(0) # Set the pointer to start
  # ||     while True:
  # ||       self.offsets.append(0)

  # ||       line = self.fh.readline()
  # ||       if not line: break
  # ||         
  # ||       self.offset += len(line)
  # ||       line = SHAREDVARS.newline_re.sub('', line)
  # ||       yield line

  def readline (self):
    """def: readline"""
    self.offsets.append(self.offset)

    line = self.fh.readline()
    self.offset += len(line)

    # line = SHAREDVARS.newline_re.sub('', line)

    return line

  # This function returns the lengh of processed lines by file pointer
  # This don't return the total lines in the file
  def __len__ (self):
    """def: __len__"""
    return len(self.offsets)
    
  def __getitem__ (self, key):
    """def: __getitem__"""
    if isinstance(key, slice):
      # return [self[i] for i in xrange(*key.indices(key.stop))]
      return [self[i] for i in xrange(*key.indices(len(self)))]
    elif isinstance(key, int):
      if key < 0: # Handle negative indices
        key += len(self)
      if key < 0 or key >= len(self):
        raise IndexError, "The index %d is out of range!!" % key
      
      offset = self.fh.tell() # Save the file pointer

      self.fh.seek(self.offsets[key]) # Set the pointer to line passed in the argument
      line = self.fh.readline() # Read the line from the line number passed in the argument
      line = SHAREDVARS.newline_re.sub('', line)

      self.fh.seek(offset) # Restore the file pointer

      return line
    else:
      raise TypeError, "Invalid argument type!!!"
    
  def __del__ (self):
    """def: __del__"""
    self.fh.close()




#-------------------------------------------------------------------------------
# TokenGenerator
#-------------------------------------------------------------------------------
class TokenGenerator(object):
  """class: TokenGenerator"""

  m_logger = LOGGER.Logger()

  def __vi_init__ (self, **kwargs):
    """def: __vi_init__"""
    if vim_detected == 0: return 0

    start = kwargs.get('start', None)
    end = kwargs.get('end', None)

    # If text is provided lex text instead of current buffer
    text = kwargs.get('text', None)
    if text:
      self.buffer = text.split('\n')
      self.fname = '<string>'
      self.start = 0
      self.end = len(self.buffer) - 1
    else:
      self.buffer = vim.current.buffer
      self.window = vim.current.window
      self.fname = vim.current.buffer.name

      if not start:
        start = vim.current.range.start # start is index starting from 0

      if not end:
        end = vim.current.range.end # end is index starting from 0

      self.start = start
      self.end = end
      
    self.readline_gen = self._vi_readline()

  def __sh_init__ (self, **kwargs):
    """def: __sh_init__"""
    if vim_detected == 1: return 0

    # File name must be provided when script is running from linux shell
    filehandle = kwargs.get('filehandle', None)
    if filehandle:
      self.filehandle = filehandle
      self.fname = os.path.abspath(filehandle.name)
      self.buffer = FileBuffer(self.filehandle)

    else:
      # If text is provided lex text instead of current buffer
      text = kwargs.get('text', None)
      if not text:
        raise IndexError, "Argument `filehandle` or `text` not provided!!"
      self.filehandle = StringIO(text)
      self.buffer = FileBuffer(self.filehandle)
      self.fname = '<STRING>'

    self.start = kwargs.get('start', 0)
    self.readline_gen = self._sh_readline()

  def __init__(self, **kwargs):
    """ __init__:
        lut : Lookup Table
    """
    self.__sh_init__(**kwargs)
    self.__vi_init__(**kwargs)

    cptr = kwargs.get('cptr', 0)

    self.lptr = self.start

    self.cptr = cptr

    self.lut = kwargs.get('lut', SHAREDVARS.REGEX_TOKENS)

    self.line = None

    self.m_token = None
    self.m_prev_token = None
    self.paired_token = None

    self.m_lex_generator = self.lex()

  # || def get_pos (self):
  # ||   """def: get_pos"""
  # ||   m_token = self.m_token
  # ||   m_prev_token = self.m_prev_token

  # ||   self.m_lex_generator, m_lex_generator_bkp = itertools.tee(self.m_lex_generator)

  # ||   return (m_token, m_prev_token, m_lex_generator_bkp)
  # ||   
  # || def set_pos (self, pos): # pos ==> (m_token, m_prev_token, m_lex_generator_bkp)
  # ||   """def: set_pos"""
  # ||   (self.m_token, self.m_prev_token, self.m_lex_generator) = pos

  def is_done (self):
    """def: is_done"""
    if self.m_token.tag == SHAREDVARS.EOP: return 1
    return 0

  def _vi_readline (self):
    """def: _vi_readline"""
    while self.lptr <= self.end:
      line = self.buffer[self.lptr]
      yield line
      self.lptr += 1
      self.cptr = 0

  # || def _sh_readline_list (self):
  # ||   """def: _sh_readline_list"""
  # ||   for line in self.buffer:
  # ||     yield line 
  # ||     self.lptr += 1
  # ||     self.cptr = 0

  def _sh_readline_fh (self):
    """def: _sh_readline_fh"""
    while True:
      line = self.buffer.readline()
      if not line: break
      line = SHAREDVARS.newline_re.sub('', line)
      yield line
      self.lptr += 1
      self.cptr = 0
    
  def _sh_readline (self):
    """def: _sh_readline"""
    # || if type(self.buffer) == list:
    # ||   genfun = self._sh_readline_list()
    # || else:
    # ||   genfun = self._sh_readline_fh()

    genfun = self._sh_readline_fh()

    for line in genfun:
      yield line
        
    # || with open(self.fname) as fh:
    # ||   for line in fh:
    # ||     line = SHAREDVARS.newline_re.sub('', line)
    # ||     yield line 
    # ||     self.lptr += 1
    # ||     self.cptr = 0


  def readline (self):
    """def: readline"""
    try:
      # The next call will fail when parsing is done
      self.line = self.readline_gen.next()

      return 1
    except StopIteration as e:
      return 0

  # || def skip_line (self):
  # ||   """def: skip_line"""
  # ||   if self.cptr >= len(self.line): return None # Already at the end of line
  # ||   #if self.cptr >= len(self.line): self.readline()
  # ||   
  # ||   tag = None
  # ||   start = (self.lptr + 1, self.cptr)
  # ||   end = (self.lptr + 1, len(self.line))
  # ||   lineboundary = None
  # ||   m_wspace = self.m_token.m_wspace

  # ||   if self.cptr == 0:
  # ||     text = self.line
  # ||   else:
  # ||     #text = self.line[self.cptr - 1:]
  # ||     text = self.line[self.cptr:]

  # ||   self.cptr = len(self.line)

  # ||   self.m_prev_token = self.m_token
  # ||   self.m_token = TOKEN.Token(text, tag, start, end, lineboundary, m_wspace)

  # ||   return self.m_token
      
  def lex (self):
    """def: lex"""
    m_wspace = None
    while self.readline():
      lineboundary = TOKEN.LineBoundary.Start
      while self.cptr < len(self.line):
        match = None
        # If paired_token is not None it's in paired mode
        # We don't want to extract keywords within a block comment or string
        # So in paired mode yield character or mathing end paired token
        if self.paired_token:
          m_wspace = None
          start_token, end_token = self.paired_token
          regex , tag = end_token
          match = regex.match(self.line, self.cptr)
          if match:
            text = match.group(0)
            cptr_old = self.cptr
            self.cptr = match.end(0)
            if tag:
              start = (self.lptr + 1, cptr_old + 1)
              end = (self.lptr + 1, self.cptr)

              if self.cptr >= len(self.line.strip()):
                lineboundary = TOKEN.LineBoundary.End

              self.m_prev_token = self.m_token 
              self.m_token = TOKEN.Token(text, tag, start, end, lineboundary)
              lineboundary = None

              self.paired_token = None # End of pair mode
              yield (self.m_token, self.m_prev_token)
          else :
            text = self.line[self.cptr]
            start = end = (self.lptr + 1, self.cptr + 1)
            self.cptr += 1

            self.m_prev_token = self.m_token 

            # FIXME: Do we need to consider whitespace here as last token
            if tag:
              if self.cptr >= len(self.line.strip()):
                lineboundary = TOKEN.LineBoundary.End

            self.m_token = TOKEN.Token(text, tag, start, end, lineboundary)
            lineboundary = None

            yield (self.m_token, self.m_prev_token)
        else:
          for regex_token in self.lut:
            regex , tag = regex_token
            match = regex.match(self.line, self.cptr)
            if match:
              # || NOT REQUIRED IN LOG PARSING || if tag == BLOCK_COMMENT_START:
              # || NOT REQUIRED IN LOG PARSING ||   self.paired_token = PAIRED_BLOCK_COMMENT_TOKEN
              # || NOT REQUIRED IN LOG PARSING || elif tag == QUOTE_TOKEN:
              # || NOT REQUIRED IN LOG PARSING ||   self.paired_token = PAIRED_QUOTE_TOKEN
              # || NOT REQUIRED IN LOG PARSING || else:
              # || NOT REQUIRED IN LOG PARSING ||   self.paired_token = None

              text = match.group(0)
              cptr_old = self.cptr
              self.cptr = match.end(0)

              start = (self.lptr + 1, cptr_old + 1)
              end = (self.lptr + 1, self.cptr)

              if not tag:
                # || if lineboundary:
                # ||   text = "\n{0}".format(text)
                m_wspace = TOKEN.Space(text, start, end)
              elif lineboundary == TOKEN.LineBoundary.Start:
                stext = '\n{0}'.format(' ' * (start[1] - 1))
                sstart = (start[0], 1, )
                send = (end[0], 1, )
                m_wspace = TOKEN.Space(stext, sstart, send)

              if tag:
                if self.cptr >= len(self.line.strip()):
                  lineboundary = TOKEN.LineBoundary.End

                self.m_prev_token = self.m_token 
                self.m_token = TOKEN.Token(text, tag, start, end, lineboundary, m_wspace)
                lineboundary = None
                m_wspace = None

                yield (self.m_token, self.m_prev_token)
              break
          if not match:
            if vim_detected:
              vim.command('1match Error "\\v%{start[0]}l%{cptr}c."'.format(start=self.m_token.start, cptr=self.cptr + 1))
            sys.stderr.write('Illegal character: %s\n' % self.line[self.cptr])
            return
            #sys.exit(1)
            #vim.command('finish')

  # Check if pattern matches in current vim window at current token position
  def is_match (self, ptrn):
    """def: is_match"""
    if vim_detected == 0: return 0
      
    # Check if END OF PARSING
    if self.m_token.tag == SHAREDVARS.EOP: return 0
      
    pattern = r'\v%{ln}l%{cn}c{ptrn}'.format(ln=self.m_token.start[0], cn=self.m_token.start[1], ptrn=ptrn)
    match = int(vim.eval("search('{ptrn}')".format(ptrn=pattern)))
    
    return match != 0

  def highlight_token (self):
    """def: highlight_token"""
    # Not in debug mode
    m_logger = LOGGER.Logger()
    if m_logger.debug == 0:
      return
      
    if self.m_token != None and self.m_token.tag != SHAREDVARS.EOP:
      self.m_token.highlight('DiffChange')
      Lexer.m_logger.set("%s" % self.m_token)
    else:
      Lexer.m_logger.set("<None>")

    #vim.command('redraw!')

  def next_token (self):
    """def: next_token"""
    try:
      # The next call will fail when parsing is done
      (self.m_token, self.m_prev_token) = self.m_lex_generator.next() # return value is again assigned because of itertools.tee() only works on yield value

      return 1
    except StopIteration as e:
      # || VIM_ONLY || vim.command('echoerr {err}'.format(err=e))
      # sys.stderr.write(e)
      # traceback.print_exc(file=sys.stdout)

      if not self.m_token: return 0

      # When END OF PARSING, m_prev_token is the last token
      if self.m_token.tag != SHAREDVARS.EOP:
        self.m_prev_token = self.m_token
      self.m_token = TOKEN.Token(None, SHAREDVARS.EOP, None, None, None)
      return 0

  def next_token_debug (self):
    """def: next_token_debug"""
    if vim_detected == 0: return
      
    self.next_token()
    self.highlight_token()
    vim.command('nmap <buffer> N :py m_lexer.next_token_debug()<CR>')
  

  def __str__ (self):
    """def: __str__"""
    str = 'lptr={lptr}, cptr={cptr}, line={line}'.format(lptr=self.lptr, cptr=self.cptr, line=self.line)
    return str

#-------------------------------------------------------------------------------
# Caution: The start and end line numbers starts from 0.. its the index of
#          the line numbers not line number itself. Actual line numbers will
#          be incremented value of index
#-------------------------------------------------------------------------------
class Lexer(object):
  """class: Lexer"""

  m_logger = LOGGER.Logger()

  def __init__(self, **kwargs):
    self.m_token_gen = TokenGenerator(**kwargs)
    self.fname = self.m_token_gen.fname
    self.buffer = self.m_token_gen.buffer
    self.m_token = None
    self.m_prev_token = None
    self.m_lex_generator = self.lex()

  def skip_line (self):
    """def: skip_line"""
    # Already at the end of line
    # Known Issue: If current token is the last token in line
    #              skip_line will not return anything
    if self.m_token.lineboundary == TOKEN.LineBoundary.End: return 0
      
    m_prev_token = self.m_token

    m_tokens = [self.m_token]
    while self.m_token.lineboundary != TOKEN.LineBoundary.End:
      if not self.next_token(): return 0
      if self.m_token.m_wspace:
        m_tokens.append(self.m_token.m_wspace)
      m_tokens.append(self.m_token)

    text = ''.join([m_text.text for m_text in m_tokens])
    start = m_tokens[0].start
    end = m_tokens[-1].end

    self.m_token = TOKEN.Text(text, start, end, m_tokens[0].m_wspace)
    self.m_prev_token = m_prev_token
    return 1
    
  # || def skip_line (self):
  # ||   """def: skip_line"""
  # ||   m_skip = self.m_token_gen.skip_line()
  # ||   if not m_skip: return None
  # ||     
  # ||   start = self.m_token.start
  # ||   end = m_skip.end
  # ||   text = '{0}{1}'.format(self.m_token.text, m_skip.text)
  # ||   m_wspace = self.m_token.m_wspace
  # ||   m_text = TOKEN.Text(text, start, end, m_wspace)
  # ||   self.m_token = self.m_token_gen.m_token
  # ||   self.m_prev_token = self.m_token_gen.m_prev_token
  # ||   return m_text
    
  def get_pos (self):
    """def: get_pos"""
    m_token = self.m_token
    m_prev_token = self.m_prev_token

    self.m_lex_generator, m_lex_generator_bkp = itertools.tee(self.m_lex_generator)

    return (m_token, m_prev_token, m_lex_generator_bkp)
    
  def set_pos (self, pos): # pos ==> (m_token, m_prev_token, m_lex_generator_bkp)
    """def: set_pos"""
    (self.m_token, self.m_prev_token, self.m_lex_generator) = pos

  def is_done (self):
    """def: is_done"""
    if self.m_token.tag == SHAREDVARS.EOP: return 1
    return 0

  # || def _lex_pair (self, start_kw, end_kw, tag_name):
  # ||   """def: _lex_pair"""
  # ||   if self.m_token.text == start_kw:
  # ||     if not self.m_token_gen.next_token(): return 0
  # ||     while self.m_token_gen.m_token.text != end_kw:
  # ||       self.m_token += self.m_token_gen.m_token
  # ||       if not self.m_token_gen.next_token(): return 0

  # ||     self.m_token += self.m_token_gen.m_token
  # ||     self.m_token.tag = tag_name
  # ||     return 1
  # ||   return 0

  def lex (self):
    """def: lex"""
    while True:
      self.m_prev_token = self.m_token
      if not self.m_token_gen.next_token() : break

      self.m_token = self.m_token_gen.m_token

      # || NOT REQUIRED IN LOG PARSING || if self._lex_defines() or self._lex_quote() or self._lex_line_comment() or self._lex_blk_comment(): 
      # || NOT REQUIRED IN LOG PARSING ||   yield (self.m_token, self.m_prev_token)
      # || NOT REQUIRED IN LOG PARSING ||   continue

      yield (self.m_token, self.m_prev_token)
        
  # Check if pattern matches in current vim window at current token position
  def is_match (self, ptrn):
    """def: is_match"""
    return self.m_token_gen.is_match(ptrn)

  def highlight_token (self):
    """def: highlight_token"""
    self.m_token_gen.highlight_token()

  def next_token (self, skip_comment=0):
    """def: next_token"""
    try:
      # The next call will fail when parsing is done
      (self.m_token, self.m_prev_token) = self.m_lex_generator.next() # return value is again assigned because of itertools.tee() only works on yield value
      if skip_comment:
        if self.m_token.tag == BLOCK_COMMENT or self.m_token.tag == LINE_COMMENT:
          self.next_token(skip_comment)

      return 1
    except StopIteration as e:
      # || VIM_ONLY || vim.command('echoerr {err}'.format(err=e))
      # sys.stderr.write(e)
      # traceback.print_exc(file=sys.stdout)

      if not self.m_token: return 0

      # When END OF PARSING, m_prev_token is the last token
      if self.m_token.tag != SHAREDVARS.EOP:
        self.m_prev_token = self.m_token
      self.m_token = TOKEN.Token(None, SHAREDVARS.EOP, None, None, None)
      return 0

    return ret

  def next_token_debug (self):
    """def: next_token_debug"""
    self.m_token_gen.next_token_debug()
      
  def __str__ (self):
    """def: __str__"""
    str = str(self.m_token_gen)
    return str

if __name__ == "__main__":
  def ParseArgs (args):
    files = []
    fileexts = ('.log')

    """def: ParseArgs"""
    for arg in args:
      if os.path.isfile(arg):
        if arg.endswith(fileexts):
          afile = os.path.abspath(arg)
          files.append(afile)
      else:
        print "Error: can't find file {file} !!!".format(file=arg)
        quit()

    files = list(set(files))
    return files

  m_logger = LOGGER.Logger()
  m_logger.debug_mode(0)

  files = ParseArgs(sys.argv[1:])

  if vim_detected:
    m_lexer = Lexer()
  else:
    filehandle = open(files[0], 'rb')
    m_lexer = Lexer(filehandle=filehandle)

  while m_lexer.next_token():
    print m_lexer.m_token
    m_logger.append ("%s" % str(m_lexer.m_token))

  # m_lexer.next_token_debug()

  # FIX: this is required to avoid error which running the script again second time
  # del m_lexer

  # for m_token in m_lexer.lex():
  #   m_logger.append ("%s" % str(m_token))
  #   m_lexer.highlight_token() # Debug





