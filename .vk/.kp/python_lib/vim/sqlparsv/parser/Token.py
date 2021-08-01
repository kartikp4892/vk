#!/usr/bin/env python

try:
  import vim
  vim_detected = 1
except Exception:
  vim_detected = 0

from sv.base.lexer.SharedVars import INDENT, EOP
from sv.base.Singleton import Logger
from sv.base.Decorators import * # TODO: Comment after debug

class LineBoundary(object):
  """class: LineBoundary
     Simulate Enum type
     Start - Indicates first token of the line
     End - Indicates last token of the line
  """
  _, Start, End = range(3)

    
class TokenBase(object):
  """class: TokenBase"""
  pass
    

class Token(TokenBase):
  """class: Token"""

  prev_start = None
  prev_end = None
  start = None
  end = None

  def __init__(self, kw, tag, start, end, lineboundary):
    """Constructor:
       kw : keyword token
       start : start position (line, col)
       end   : end position (line, col)
    """

    # Preserve old position
    self._save_old_pos(start, end)

    self.text = kw
    self.tag = tag
    self.start = start
    self.end = end
    self.lineboundary = lineboundary

  def isnewline (self):
    """def: isnewline"""
    return (self.lineboundary == LineBoundary.Start)
    
  @classmethod
  def _save_old_pos (cls, start, end):
    """def: _save_old_pos"""
    cls.prev_start = cls.start
    cls.prev_end = cls.end
    cls.start = start
    cls.end = end

  def __str__ (self):
    """def: __str__"""

    text = "<Token kw={kw}, tag={tag}, lineboundary={lineboundary}, pos={start}, {end}, >\n".format(kw=self.text, tag=self.tag, start=self.start, end=self.end, lineboundary=self.lineboundary)
    return text

  def highlight (self, group_name, **kwargs):
    """def: highlight"""
    if vim_detected == 0: return
      
    matidx = kwargs.get('matidx', 1)

    # Not in debug mode
    m_logger = Logger()
    if m_logger.debug == 0:
      return
      
    if self.tag == EOP: return
      
    ln, cn = self.start
    vim.current.window.cursor = (ln, cn - 1)
    vim.command('{matidx}match {group} "\\v%{start[0]}l%{start[1]}c\_.*\\v%{end[0]}l%{end[1]}c."'.format(matidx=matidx,group=group_name, start=self.start, end=self.end))
    
class Text(Token):
  """class: Text"""

  def __init__(self, kw, start, end):
    tag = None
    lineboundary = None
    super(Text, self).__init__(kw, tag, start, end, lineboundary)
    

class Space(Text): pass

class BlockToken(TokenBase):
  """class: BlockToken"""

  def __init__(self, m_atext, m_itext): # m_atext = Text(...), m_itext = Text(...)
    """
        m_atext: Instance of inner text token
        m_itext: Instance of outer text token
    """
    self.m_atext = m_atext
    self.m_itext = m_itext

#-------------------------------------------------------------------------------
# GenToken
#-------------------------------------------------------------------------------
class GenToken(object):
  """class: GenToken
  """

  def __init__(self, *args):
    self.args = args

  def __str__ (self):
    """def: __str__"""
    text = '<GenToken: args={0}>'.format(self.args)
    return text

#-------------------------------------------------------------------------------
# Optional: keywords that are optional
#-------------------------------------------------------------------------------
class Optional(GenToken): pass

#-------------------------------------------------------------------------------
# Group: Keywords that needs to be captured in group
#-------------------------------------------------------------------------------
class Group(GenToken): pass

#-------------------------------------------------------------------------------
# Or: Alternative Tokens
#-------------------------------------------------------------------------------
class Or(GenToken): pass


