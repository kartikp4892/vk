#!/usr/bin/env python

# FIXME: THIS SCRIPT IS DEAD... NOT BEING USED NOW

# TODO: Add additional intormation <key:value> in tag file: For example <class:BufdoCtags> in below line
#       set_out_file	/home/kartik/.vim/.kp/python_lib/vim/ctags/ctags.py	/^  def set_out_file (self):$/;"	m	class:BufdoCtags
#       HINT: Use searchpair() to get the class name of tag

import vim
import re
import sys, getopt

# add {{}} for {} in regex since {} is used for string.format purpose
# ({id}) --> regex to be replaced with tag name
TAG_ID_REGEX = '\w+'
CLASS_REGEX = '\\v^\s*%(<virtual>\_s*)?<class>\_s+({id})\_s*%(\_s*\#\(\_.{{-}}\)\_s*)?%(\_s<extends>\_s+\w+\_s*%(\_s*\#\(\_.{{-}}\)\_s*)?)?;'
FUNCTION_REGEX = '\\v^\s*%(<extern>\_s*)?%(<static>\_s*)?%(<virtual>\_s*)?<function>\_.{{-}}(<{id}>)\_s*%(%(#@<!\()|;)'
TASK_REGEX = '\\v^\s*%(<extern>\_s*)?%(<static>\_s*)?%(<virtual>\_s*)?<task>\_s*%(\w+\_s*::\_s*)?(<{id}>)\_s*[;(]'
TYPEDEF_REGEX = '\\v^\s*<typedef>\_[^;]*(<{id}>)\_s*[;]'
INTERFACE_REGEX = '\\v^\s*<interface>\_.{{-}}(<{id}>)\_s*%(%(#@<!\()|;)'
MODULE_REGEX = '\\v^\s*<module>\_.{{-}}(<{id}>)\_s*%(%(#@<!\()|;)'
PACKAGE_REGEX = '\\v^\s*<package>\_.{{-}}(<{id}>)\_s*[;]'
PROGRAM_REGEX = '\\v^\s*<program>\_.{{-}}(<{id}>)\_s*%(%(#@<!\()|;)'
MACRO_REGEX = '\\v^\s*`<define>\_s*(<{id}>)'
LINE_COMMENT_REGEX = '^\s*//'
BLOCK_COMMENT_REGEX = '\\v\/\*\_.{-}\*\/'

CLASS_KIND = 'class'
TYPEDEF_KIND = 'typedef'
FUN_KIND = 'function'
TASK_KIND = 'task'
REGEX_TOKEN_SV = [
 (TYPEDEF_REGEX, TYPEDEF_KIND, '{id}'),
 (CLASS_REGEX, CLASS_KIND, "{id}"),
 (FUNCTION_REGEX, FUN_KIND, "{id}"),
 (TASK_REGEX, TASK_KIND, '{id}'),
 (INTERFACE_REGEX, 'interface', "{id}"),
 (MODULE_REGEX, 'module', "{id}"),
 (PROGRAM_REGEX, 'program', "{id}"),
 (PACKAGE_REGEX, 'package', "{id}"),
 (MACRO_REGEX, 'macro', '`{id}'), # tag `id
]

escape_re = re.compile(r'([\\])') # characters to escape
space_re = re.compile(r'\s+')
indent_re = re.compile(r'^\s+')

# Decorator for creating user datatypes output file
# Search and comment this applied decorator to disable it
def dump_user_datatypes (org_fun):
  """def: dump_user_datatypes"""
  def new_fun (*args, **kwargs):
    """def: new_fun"""
    self = args[0] # First argument is object itself
    ret = org_fun(*args, **kwargs)
    if ret:
      if self.m_token.kind == CLASS_KIND or self.m_token.kind == TYPEDEF_KIND:
        self.tag_datatypes_fh.write("{name}\n".format(name=self.m_token.name))
    return ret
  return new_fun

def GetOpt(argv):
  outputfile = ""
  try:
    opts, args = getopt.getopt(argv,"hf:",["ofile="])
    if opts == [] and args == []:
      vim.command ('echoerr "Usage: test.py -f <outputfile>"')
  except getopt.GetoptError:
    vim.command ('echoerr "Usage: test.py -f <outputfile>"')
    return None
  for opt, arg in opts:
    if opt == '-h':
      vim.command ('echoerr "Usage: test.py -f <outputfile>"')
      return None
    elif opt in ("-f", "--ofile"):
      outputfile = arg
      return outputfile 
  return None

class Token(object):
  """class: Token"""

  def __init__(self, name, cmd, kind, filename, kwargs):
    """Constructor:"""
    self.name = name
    self.cmd = cmd
    self.kind = kind
    self.filename = filename
    self.kwargs = kwargs

  def __str__ (self):
    """def: __str__"""

    other = ''

    str = "{name}\t{file}\t{cmd}\t{kind}\t{other}".format(name=self.name, file=self.filename, cmd=self.cmd, kind=self.kind, other=self.kwargs)
    return str

class Ctags(object):
  """class: Ctags"""

  def __init__(self, tag_fh, tag_datatypes_fh):
    """Constructor:"""
    self.buffer = vim.current.buffer
    self.window = vim.current.window
    self.m_token = None
    self.tag_fh = tag_fh
    self.tag_datatypes_fh = tag_datatypes_fh

  def _remaining_tagstr (self, text, kind):
    """def: _remaining_tagstr"""
    str = ''
    if kind == CLASS_KIND:
      extends = vim.eval('matchstr({text!r}, \'\\v<extends>\_s+\zs\w+\')'.format(text=text))
      if extends != '':
        str += 'extends:{extends}\t'.format(extends=extends)
    elif kind == FUN_KIND or kind == TASK_KIND:
      classname = vim.eval('matchstr({text!r}, \'\\v<\w+>\ze\_s*::\')'.format(text=text))
      if classname != "":
        str += 'class:{classname}\tis_extern:1\timp=1\t'.format(classname=classname)
        return str

      class_start_re = r'\v<class>\_s+\zs(<\w+>)'
      # class_start_re = r'\v^\s*%(<virtual>\_s+)?<class>\_s+\zs(<\w+>)'
      class_end_re = r'\v^\s*<endclass>'
      ln,cn = vim.eval("searchpairpos('{start}', '', '{end}', 'Wbn')".format(start=class_start_re, end=class_end_re))
      ln = int(ln)
      cn = int(cn)
      if ln != 0:
        cursor_save = self.window.cursor
        self.window.cursor = (ln,cn)
        classname = vim.eval('expand("<cword>")')
        self.window.cursor = cursor_save

        str += 'class:{classname}\t'.format(classname=classname)
    
      if vim.eval('matchstr({text!r}, \'\\v<extern>\')'.format(text=text)) != "":
        str += 'is_extern:1\tdef=1\t'

    return str
    
  @dump_user_datatypes
  def _search (self, regex_token):
    """def: _search"""
    regex_placeholder, kind, tag_placeholder = regex_token
    regex = regex_placeholder.format(id=TAG_ID_REGEX)

    start = int(vim.eval("search('{regex}', 'W')".format(regex=regex)))
    if start != 0:
      end = int(vim.eval("search('{regex}', 'We')".format(regex=regex)))

      # Python buffer starts from 0
      # start = start
      # end = end

      lines = vim.eval('getline({start},{end})'.format(start=start, end=end))
      text = "\n".join(lines)
      matchlist = vim.eval("matchlist('{text}', '{regex}')".format(text=text.replace("'", "''"), regex=regex))
      tag = matchlist[1]
      tag = tag_placeholder.format(id=tag)

      remaining_tagstr = self._remaining_tagstr (text, kind) # This might be slow.. if not needed comment this line and uncomment below line
      # || remaining_tagstr = ''

      lines = [escape_re.sub(r'\\\1', line) for line in lines]
      cmd = '{text}'.format(text='\\n\\+'.join(lines))
      cmd = indent_re.sub('\\s\\+', cmd)
      cmd = space_re.sub('\\_s\\+', cmd)
      cmd = '/^{text}$/;"'.format(text=cmd)

      # || PATTERN STYPE 2 || cmd = regex_placeholder.format(id=tag)
      # || PATTERN STYPE 2 || cmd = '/%s/;"' % cmd

      m_token = Token(tag, cmd, kind, vim.eval('expand("%:p")'), remaining_tagstr)
      self.m_token = m_token
      return 1
    self.m_token = None
    return 0
    
  def search (self):
    # Delete comments
    vim.command('silent %s!{search}!!ge'.format(search=BLOCK_COMMENT_REGEX))
    vim.command('silent g~{search}~d'.format(search=LINE_COMMENT_REGEX))

    # Delete forward declaration of class --> ( typedef class abc; or typedef abc; )
    vim.command('silent g~{search}~d'.format(search='\\v^\s*<typedef>\_s+<class>\_s+<\w+>\_s*;'))
    vim.command('silent g~{search}~d'.format(search='\\v^\s*<typedef>\_s+<\w+>\_s*;'))

    """def: search"""
    for regex_token in REGEX_TOKEN_SV:
      self.window.cursor = (1,1)
      while self._search(regex_token):
        self.tag_fh.write("{token}\n".format(token=self.m_token))
    # Restore comments
    vim.command('let @/ = ""')
    vim.command('silent edit!')


class BufdoCtags(object):
  """class: BufdoCtags"""

  def __init__(self, outputfile, output_datatypes_file):
    self.outputfile = outputfile
    self.output_datatypes_file = output_datatypes_file
    self.tag_fh = None
    self.tag_datatypes_fh = None

  def open_fh (self):
    """def: open_fh"""
    self.tag_fh = open(self.outputfile, 'w')
    self.tag_fh.write("!_TAG_FILE_SORTED	0	/0=unsorted, 1=sorted, 2=foldcase/\n")

    self.tag_datatypes_fh = open(self.output_datatypes_file, 'w')
    
  def close_fh (self):
    """def: close_fh"""
    self.tag_fh.close()

    self.tag_datatypes_fh.close()
    

  def search (self):
    """def: search"""
    m_bufdo_ctags.open_fh()

    for b in vim.buffers:
      # If buffer without name
      vim.command ('silent b{buf}'.format(buf=b.number))
      if b.name == '':
        continue
      m_ctags = Ctags(self.tag_fh, self.tag_datatypes_fh)
      m_ctags.search()

    m_bufdo_ctags.close_fh()


if __name__ == "__main__":

  outputfile = GetOpt(sys.argv)
  if outputfile == None:
    outputfile = 'tags'
  output_datatypes_file = '{tagfile}_datatypes'.format(tagfile=outputfile)

  m_bufdo_ctags = BufdoCtags(outputfile, output_datatypes_file)

  m_bufdo_ctags.search()


  







