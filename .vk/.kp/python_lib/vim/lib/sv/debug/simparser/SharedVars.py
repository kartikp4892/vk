#!/usr/bin/env python
import re

IDENTIFIER = 'IDENTIFIER'
NUMBER='NUMBER'
FILE='FILE'
EOP = 'EOP' # END OF PARSERING
KEYWORD = 'KEYWORD'
PLACEHOLDER = 'PLACEHOLDER'

space_re = re.compile('\s+')
newline_re = re.compile('\n')
PLACEHOLDER_RE = re.compile('{(\d+)}')

END_BLOCKS = {
  '[': ']', 
  '{': '}',
  '(': ')',
}

REGEX_TOKENS = [
  (re.compile(r'[ \t\n]+'), None), # Skip spaces
  (re.compile(r'/?\w+/[^\t\n ]+\.(?:sv[hi]?|v|vhd)\b'), FILE), # code files
  (re.compile(r'[0-9]*\'b[0-1_]+'), NUMBER), # BINARY
  (re.compile(r'[0-9]*\'h[0-9A-Fa-f_]+'), NUMBER), # HEX
  (re.compile(r'[0-9]*\'d[0-9_]+'), NUMBER), # DECIMAL
  (re.compile(r'[0-9][0-9_]*'), NUMBER),
  (re.compile(r'[A-Za-z0-9_]+'), IDENTIFIER),

  # Two charactors tokens
  (re.compile(re.escape('**')), KEYWORD),

  # If don't match any of above pattern just match single char
  (re.compile(r'[^a-zA-Z0-9]'), KEYWORD),
]

AUTOGEN_TOKENS = [
  # Placeholder regex
  (re.compile(r'{\d+}'), PLACEHOLDER),
]
AUTOGEN_TOKENS.extend(REGEX_TOKENS)

class _Keyword(object):
  """class: _Keyword"""

  def __init__(self, text):
    self.text = text

  def __str__ (self):
    """def: __str__"""
    return self.text

class TAG(_Keyword):
  """class: TAG"""

  def __str__ (self):
    """def: __str__"""
    text = "TAG('{0}')".format(self.text)
    return text

class KW(_Keyword):
  """class: KW"""
  def __str__ (self):
    """def: __str__"""
    text = "KW('{0}')".format(self.text)
    return text

# || class PAIR(object):
# ||   """class: PAIR"""
# || 
# ||   def __init__(self, start_kw, end_kw):
# ||     self.start_kw = start_kw
# ||     self.end_kw = end_kw


