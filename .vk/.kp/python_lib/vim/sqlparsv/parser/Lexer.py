#!/usr/bin/env python

from __future__ import absolute_import

#import re
try:
  import vim
  vim_detected = 1
except Exception:
  vim_detected = 0

import os
import sys, traceback

from .Token import Token
from ..utils.Singleton import Logger
from .SharedVars import *
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
  # ||       line = newline_re.sub('', line)
  # ||       yield line

  def readline (self):
    """def: readline"""
    self.offsets.append(self.offset)

    line = self.fh.readline()
    self.offset += len(line)

    # line = newline_re.sub('', line)

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
      line = newline_re.sub('', line)

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

  m_logger = Logger()

  def __vi_init__ (self, **kwargs):
    """def: __vi_init__"""
    if vim_detected == 0: return 0

    start = kwargs.get('start', None)
    end = kwargs.get('end', None)

    if not (start or end):
      self.start = vim.current.range.start
      self.end = vim.current.range.end

    else:
      self.start = kwargs.get('start', 0)
      self.end = kwargs.get('end', len(vim.current.buffer) - 1)
      
    self.buffer = vim.current.buffer
    self.window = vim.current.window
    self.readline_gen = self._vi_readline()
    self.fname = vim.current.buffer.name

  def __sh_init__ (self, **kwargs):
    """def: __sh_init__"""
    if vim_detected == 1: return 0

    # File name must be provided when script is running from linux shell
    filehandle = kwargs.get('filehandle', None)
    if not filehandle:
      raise IndexError, "Argument `filehandle` not provided!!"

    self.filehandle = filehandle
    self.fname = os.path.abspath(filehandle.name)
    self.buffer = FileBuffer(self.filehandle)

    self.start = kwargs.get('start', 0)
    self.readline_gen = self._sh_readline()

  def __init__(self, **kwargs):
    self.__sh_init__(**kwargs)
    self.__vi_init__(**kwargs)

    cptr = kwargs.get('cptr', 0)

    self.lptr = self.start

    self.cptr = cptr

    self.line = None

    self.m_token = None
    self.m_prev_token = None
    self.paired_token = None

    self.m_lex_generator = self.lex()

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
    if self.m_token.tag == EOP: return 1
    return 0

  def _vi_readline (self):
    """def: _vi_readline"""

    for line in self.buffer[self.start: self.end + 1]:
      yield line 
      self.lptr += 1
      self.cptr = 0

  def _sh_readline (self):
    """def: _sh_readline"""
    while True:
      line = self.buffer.readline()
      if not line: break
      line = newline_re.sub('', line)
      yield line
      self.lptr += 1
      self.cptr = 0
        
    # || with open(self.fname) as fh:
    # ||   for line in fh:
    # ||     line = newline_re.sub('', line)
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

  def skip_line (self):
    """def: skip_line"""
    if self.cptr >= len(self.line): return '' # Already at the end of line
    #if self.cptr >= len(self.line): self.readline()
    
    tag = None
    start = (self.lptr + 1, self.cptr)
    end = (self.lptr + 1, len(self.line))
    isnewline = None

    if self.cptr == 0:
      text = self.line
    else:
      text = self.line[self.cptr - 1:]

    self.cptr = len(self.line)

    m_token = Token(text, tag, start, end, isnewline)

    return m_token
      
  def lex (self):
    """def: lex"""
    while self.readline():
      isnewline = True
      while self.cptr < len(self.line):
        match = None
        # If paired_token is not None it's in paired mode
        # We don't want to extract keywords within a block comment or string
        # So in paired mode yield character or mathing end paired token
        if self.paired_token:
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

              self.m_prev_token = self.m_token 
              self.m_token = Token(text, tag, start, end, isnewline)
              isnewline = False

              self.paired_token = None # End of pair mode
              yield (self.m_token, self.m_prev_token)
          else :
            text = self.line[self.cptr]
            start = end = (self.lptr + 1, self.cptr + 1)
            self.cptr += 1

            self.m_prev_token = self.m_token 
            self.m_token = Token(text, tag, start, end, isnewline)
            isnewline = False

            yield (self.m_token, self.m_prev_token)
        else:
          for regex_token in REGEX_TOKENS:
            regex , tag = regex_token
            match = regex.match(self.line, self.cptr)
            if match:
              if tag == BLOCK_COMMENT_START:
                self.paired_token = PAIRED_BLOCK_COMMENT_TOKEN
              elif tag == QUOTE_TOKEN:
                self.paired_token = PAIRED_QUOTE_TOKEN
              else:
                self.paired_token = None

              text = match.group(0)
              cptr_old = self.cptr
              self.cptr = match.end(0)

              start = (self.lptr + 1, cptr_old + 1)
              end = (self.lptr + 1, self.cptr)

              if tag:
                # Check if IDENTIFIER text is reserve keyword
                if tag == IDENTIFIER:
                  text, tag = next((kw for kw in KEYWORD_TOKENS if kw[0] == text), (text, tag)) # next(.., default)

                # In UVM library somewhere in code #( parameter is #<SPACE>(
                if tag == PARAMETER_START:
                  text = space_re.sub('', text)


                self.m_prev_token = self.m_token 
                self.m_token = Token(text, tag, start, end, isnewline)
                isnewline = False

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
    if self.m_token.tag == EOP: return 0
      
    pattern = r'\v%{ln}l%{cn}c{ptrn}'.format(ln=self.m_token.start[0], cn=self.m_token.start[1], ptrn=ptrn)
    match = int(vim.eval("search('{ptrn}')".format(ptrn=pattern)))
    
    return match != 0

  # The view_hightlight_runtime decorator is useful in debug mode to see
  # the parsering at run time. Uncomment it to use this in debug
  @view_hightlight_runtime # TODO: comment after debug

  # The do_nothing decorator will make function not to perform any operation
  # @do_nothing # TODO: comment after debug
  def highlight_token (self):
    """def: highlight_token"""
    # Not in debug mode
    m_logger = Logger()
    if m_logger.debug == 0:
      return
      
    if self.m_token != None and self.m_token.tag != EOP:
      self.m_token.highlight('DiffChange')
      Lexer.m_logger.set("%s" % self.m_token)
    else:
      Lexer.m_logger.set("<None>")

    #vim.command('redraw!')

  # @hightlight_it # TODO: Comment after debug
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
      if self.m_token.tag != EOP:
        self.m_prev_token = self.m_token
      self.m_token = Token(None, EOP, None, None, None)
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

  m_logger = Logger()

  def __init__(self, **kwargs):
    self.m_token_gen = TokenGenerator(**kwargs)
    self.fname = self.m_token_gen.fname
    self.buffer = self.m_token_gen.buffer
    self.m_token = None
    self.m_prev_token = None
    self.m_lex_generator = self.lex()

  def skip_line (self):
    """def: skip_line"""
    return self.m_token_gen.skip_line()
    
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
    if self.m_token.tag == EOP: return 1
    return 0

  def _lex_line_comment (self):
    """def: _lex_line_comment"""
    if self.m_token.tag == LINE_COMMENT:
      start = self.m_token.start
      end = (self.m_token_gen.lptr + 1, len(self.m_token_gen.line))
      tag = LINE_COMMENT
      text = self.m_token_gen.line[start[1] - 1:]
      isnewline = self.m_token_gen.m_token.isnewline()
      self.m_token = Token(text, tag, start, end, isnewline)
      self.m_token_gen.skip_line()
      return 1
    return 0

  def _lex_pair (self, start_kw, end_kw, tag_name):
    """def: _lex_pair"""
    if self.m_token.text == start_kw:
      if not self.m_token_gen.next_token(): return 0
      while self.m_token_gen.m_token.text != end_kw:
        self.m_token += self.m_token_gen.m_token
        if not self.m_token_gen.next_token(): return 0

      self.m_token += self.m_token_gen.m_token
      self.m_token.tag = tag_name
      return 1
    return 0

  def _lex_blk_comment (self):
    """def: _lex_blk_comment"""
    return self._lex_pair('/*', '*/', BLOCK_COMMENT)

  def _lex_quote (self):
    """def: _lex_quote"""
    return self._lex_pair('"', '"', STRING)

  def _lex_defines (self):
    """def: _lex_defines"""
    if self.m_token.text == '`define':
      start = self.m_token.start
      isnewline = self.m_token.isnewline()
      text = ''
      tag = DEFINE
      if self.m_token_gen.line [-1] != '\\':
        text += "{0}\n".format(self.m_token_gen.line)

      else:
        while len(self.m_token_gen.line) != 0 and self.m_token_gen.line [-1] == '\\':
          self.m_token_gen.skip_line()
          self.m_token_gen.readline()
          text += "{0}\n".format(self.m_token_gen.line)

      end = (self.m_token_gen.lptr + 1, len(self.m_token_gen.line))
      self.m_token_gen.skip_line()

      self.m_token = Token(text, tag, start, end, isnewline)
      return 1
    return 0

  def lex (self):
    """def: lex"""
    while True:
      self.m_prev_token = self.m_token
      if not self.m_token_gen.next_token() : break

      self.m_token = self.m_token_gen.m_token

      if self._lex_defines() or self._lex_quote() or self._lex_line_comment() or self._lex_blk_comment(): 
        yield (self.m_token, self.m_prev_token)
        continue

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
      if self.m_token.tag != EOP:
        self.m_prev_token = self.m_token
      self.m_token = Token(None, EOP, None, None, None)
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
    fileexts = ('.sv', '.svh', '.svi', '.v')

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

  m_logger = Logger()
  m_logger.debug_mode(0)

  files = ParseArgs(sys.argv[1:])

  if vim_detected:
    m_lexer = Lexer()
  else:
    fh = open(files[0], 'rb')
    m_lexer = Lexer(filehandle=fh)

  while m_lexer.next_token():
    print m_lexer.m_token
    m_logger.append ("%s" % str(m_lexer.m_token))

  # m_lexer.next_token_debug()

  # FIX: this is required to avoid error which running the script again second time
  # del m_lexer

  # for m_token in m_lexer.lex():
  #   m_logger.append ("%s" % str(m_token))
  #   m_lexer.highlight_token() # Debug





