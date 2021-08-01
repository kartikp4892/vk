#!/usr/bin/env python

import vim
import os, imp
import sqlite3

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod


LINEPARSER = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simviewer/LineParser.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
AST = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simparser/ast.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
UTILSBUF = import_('{kp_vim_home}/python_lib/vim/lib/Utils/Buffer.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
BUFFERS = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simviewer/Buffers.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
META = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/utils/metaclasses.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))

#-------------------------------------------------------------------------------
# Vim functions
List_vi = vim.Function('tlib#input#List')
match_vi = vim.Function('match')
matchend_vi = vim.Function('matchend')
matchstr_vi = vim.Function('matchstr')
#-------------------------------------------------------------------------------

# #-------------------------------------------------------------------------------
# # FIXME: META.Singleton is not working here but it's working in Buffer.py
# #        So copied code here in this file and same code is working in this file
# class Singleton(type):
#   """class: Singleton"""
#
#   _instances = {}
#
#   def __call__(cls, *args, **kwargs):
#     if cls not in cls._instances:
#       cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
#       cls._instances[cls].__init__(*args, **kwargs)
#     return cls._instances[cls]
# #
# #
# #
# # #-------------------------------------------------------------------------------

class Constraints(object):
  """class: Constraints"""

  cunn = sqlite3.connect(':memory:') # sqlite3 Connection
  cur = cunn.cursor() # sqlite3 cursor

  cur.execute('''CREATE TABLE token (
    token_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    viewer_name TEXT NOT NULL,
    severity TEXT NOT NULL DEFAULT "",
    file_ TEXT NOT NULL DEFAULT "",
    line TEXT NOT NULL DEFAULT "",
    time TEXT NOT NULL DEFAULT "",
    inst_path TEXT NOT NULL DEFAULT "",
    id_ TEXT NOT NULL DEFAULT "",

    CONSTRAINT unique_keys UNIQUE (viewer_name, severity, file_, line, time, inst_path, id_) ON CONFLICT IGNORE
  )''')

  cur.execute('''CREATE TABLE filter (
    filter_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    token_id INTEGER,
    value TEXT,
    text_or_regex TEXT, -- value is text or regex
    include_or_exclude TEXT, -- report matching value should be included or excluded

    CONSTRAINT unique_keys UNIQUE (token_id, value, text_or_regex, include_or_exclude) ON CONFLICT IGNORE

    FOREIGN KEY (token_id) REFERENCES token(token_id) ON DELETE CASCADE
  )''')

  cur.execute('''CREATE TABLE focus (
    focus_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    token_id INTEGER,
    value TEXT,

    CONSTRAINT unique_keys UNIQUE (token_id, value) ON CONFLICT IGNORE

    FOREIGN KEY (token_id) REFERENCES token(token_id) ON DELETE CASCADE
  )''')

  def __init__(self, **kwargs):
    self.buff_name = kwargs['buff_name'] # viewer buffer name in which constraint applied

  def add_token (self, m_report_token):
    """def: add_token"""
    # TODO: Generalize it to include token fields
    tokenkeys = ['file_', 'line', 'inst_path']
    placeholders = ['?' for t in tokenkeys]
    values = [getattr(m_report_token, t) for t in tokenkeys]

    tokenkeys = ['viewer_name'] + tokenkeys
    placeholders = ['?'] + placeholders
    values = [self.buff_name] + values

    Constraints.cur.execute('''INSERT INTO token ({0}) values ({1})'''.format(', '.join(tokenkeys), ', '.join(placeholders)), values)

  def remove_token (self, m_report_token):
    """def: remove_token"""
    # TODO: Generalize it to include token fields
    tokenkeys = ['file_', 'line', 'inst_path']
    placeholders = ['{0}=?'.format(t) for t in tokenkeys]
    values = [getattr(m_report_token, t) for t in tokenkeys]

    tokenkeys = ['viewer_name'] + tokenkeys
    placeholders = ['viewer_name=?'] + placeholders
    values = [self.buff_name] + values

    Constraints.cur.execute('''DELETE FROM token WHERE ({0})'''.format(' AND '.join(placeholders)), values)

  def get_tokens (self):
    """def: get_tokens"""
    Constraints.cur.execute('''SELECT * FROM token WHERE (viewer_name = ?)''', [self.buff_name])
    header = [member[0] for member in Constraints.cur.description]

    tokens = [dict(zip(header, row)) for row in Constraints.cur]
    tokens = [{k:v for k,v in token.iteritems() if v} for token in tokens]

    return tokens

  def add_filter (self, m_report_token, **kwargs):
    """def: add_filter"""
    # TODO: Generalize it to include token fields
    tokenkeys = ['file_', 'line', 'inst_path']
    placeholders = ['{0}=?'.format(t) for t in tokenkeys]
    values = [getattr(m_report_token, t) for t in tokenkeys]

    tokenkeys = ['viewer_name'] + tokenkeys
    placeholders = ['viewer_name=?'] + placeholders
    values = [self.buff_name] + values

    Constraints.cur.execute('''
      INSERT INTO filter (token_id, value, text_or_regex, include_or_exclude)
      SELECT token.token_id, ?, ?, ? FROM token WHERE ({0})

      '''.format(' AND '.join(placeholders)), [ kwargs['value'], kwargs['text_or_regex'], kwargs['include_or_exclude'] ] + values)

  def remove_filter (self, m_report_token): # TODO: Remove kwargs argument
    """def: remove_filter"""
    # TODO: Generalize it to include token fields
    tokenkeys = ['file_', 'line', 'inst_path']
    placeholders = ['{0}=?'.format(t) for t in tokenkeys]
    values = [getattr(m_report_token, t) for t in tokenkeys]

    tokenkeys = ['viewer_name'] + tokenkeys
    placeholders = ['viewer_name=?'] + placeholders
    values = [self.buff_name] + values

    Constraints.cur.execute('''
      SELECT f.* FROM filter as f INNER JOIN token as t ON t.token_id = f.token_id WHERE ({0})
      '''.format(' AND '.join(placeholders)), values)
    header = [member[0] for member in Constraints.cur.description]
    rows = self.cur.fetchall()

    def row2str (row):
      row_h = dict(zip(header, row))
      text = '{0} {1}{2} {3}'.format(row_h['filter_id'],
                                      '=' if (row_h['include_or_exclude'] == 'include') else '!',
                                      '=' if (row_h['text_or_regex'] == 'text') else '~',
                                      row_h['value'])
      return text

    inputlist = List_vi('m', 'Select filters to remove', [row2str(row) for row in rows])

    for text in inputlist:
      filter_id = next((dict(zip(header, row))['filter_id'] for row in rows if row2str(row) == text), None)
      if filter_id:
        Constraints.cur.execute(''' DELETE FROM filter WHERE (filter_id = ?)  ''', [filter_id])

  def clear_filters (self):
    """def: remove_filters"""
    Constraints.cur.execute(''' DELETE FROM filter ''')

  def get_filters (self, **kwargs): # column=value
    """def: get_filters
       Return the filters associated matches criteria provided in kwargs
    """

    if len(kwargs) == 0:
      Constraints.cur.execute('''SELECT * FROM filter''')
    else:
      keys = kwargs.keys()
      values = kwargs.values()
      phtxt = ' AND '.join(["{0}=?".format(x) for x in keys])
      expr = '({0})'.format(phtxt)

      Constraints.cur.execute('''SELECT * FROM filter where ({0})'''.format(expr), values)

    header = [member[0] for member in Constraints.cur.description]

    filters = [dict(zip(header, row)) for row in Constraints.cur]
    return filters

  def add_focus (self, m_report_token, **kwargs):
    """def: add_focus"""
    # TODO: Generalize it to include token fields
    tokenkeys = ['file_', 'line', 'inst_path']
    placeholders = ['{0}=?'.format(t) for t in tokenkeys]
    values = [getattr(m_report_token, t) for t in tokenkeys]

    tokenkeys = ['viewer_name'] + tokenkeys
    placeholders = ['viewer_name=?'] + placeholders
    values = [self.buff_name] + values

    Constraints.cur.execute('''
      INSERT INTO focus (token_id, value)
      SELECT token.token_id, ? FROM token WHERE ({0})

      '''.format(' AND '.join(placeholders)), [ kwargs['value'] ] + values)

  def remove_focus (self, m_report_token): # TODO: Remove kwargs argument
    """def: remove_focus"""
    # TODO: Generalize it to include token fields
    tokenkeys = ['file_', 'line', 'inst_path']
    placeholders = ['{0}=?'.format(t) for t in tokenkeys]
    values = [getattr(m_report_token, t) for t in tokenkeys]

    tokenkeys = ['viewer_name'] + tokenkeys
    placeholders = ['viewer_name=?'] + placeholders
    values = [self.buff_name] + values

    Constraints.cur.execute('''
      SELECT f.* FROM focus as f INNER JOIN token as t ON t.token_id = f.token_id WHERE ({0})
      '''.format(' AND '.join(placeholders)), values)
    header = [member[0] for member in Constraints.cur.description]
    rows = self.cur.fetchall()

    def row2str (row):
      row_h = dict(zip(header, row))
      text = '{0} == {1}'.format(row_h['focus_id'],
                                 row_h['value'])
      return text

    inputlist = List_vi('m', 'Select focus to remove', [row2str(row) for row in rows])

    for text in inputlist:
      focus_id = next((dict(zip(header, row))['focus_id'] for row in rows if row2str(row) == text), None)
      if focus_id:
        Constraints.cur.execute(''' DELETE FROM focus WHERE (focus_id = ?)  ''', [focus_id])

  def clear_focuses (self):
    """def: remove_focuses"""
    Constraints.cur.execute(''' DELETE FROM focus ''')

  def get_focuses (self, **kwargs): # column=value
    """def: get_focuses
       Return the focuses associated matches criteria provided in kwargs
    """

    if len(kwargs) == 0:
      Constraints.cur.execute('''SELECT * FROM focus''')
    else:
      keys = kwargs.keys()
      values = kwargs.values()
      phtxt = ' AND '.join(["{0}=?".format(x) for x in keys])
      expr = '({0})'.format(phtxt)

      Constraints.cur.execute('''SELECT * FROM focus where ({0})'''.format(expr), values)

    header = [member[0] for member in Constraints.cur.description]

    focuses = [dict(zip(header, row)) for row in Constraints.cur]
    return focuses


#-------------------------------------------------------------------------------
# LoaderBase
#-------------------------------------------------------------------------------
class LoaderBase(object):
  """class: LoaderBase
     This class loads the filtered messages to the viewer buffer
  """

  def __init__(self, **kwargs):
    self.m_viewerbuf = kwargs['m_viewerbuf']
    self.db_dir = kwargs['db_dir']

    self.m_constraint = Constraints(buff_name=self.m_viewerbuf.buff.name)

  def parse_line (self):
    """def: parse_line
       This function parses current line and returns the ReportToken object
    """
    m_lineparser = LINEPARSER.LineParser()
    m_report_token = m_lineparser.parse()
    return m_report_token

  def _filter_pass (self, tokens, m_report_token):
    """def: _filter_pass
       Return value of token_id when m_report_token passed by filter else -1
       To filter m_report_token based on tokens if token values are not matching with m_report_token values
    """
    for token in tokens:
      token_h = {k:v for k,v in token.items() if hasattr(m_report_token, k)}
      rtoken_h = {k:getattr(m_report_token, k) for k in token_h.keys() if hasattr(m_report_token, k)}
      if token_h != rtoken_h:
        continue

      token_id = token['token_id']

      report_text = str(m_report_token)

      filters = self.m_constraint.get_filters(token_id=token_id, text_or_regex='text', include_or_exclude='include')
      for flt in filters:
        if flt['value'] not in report_text: return -1

      filters = self.m_constraint.get_filters(token_id=token_id, text_or_regex='text', include_or_exclude='exclude')
      for flt in filters:
        if flt['value'] in report_text: return -1

      filters = self.m_constraint.get_filters(token_id=token_id, text_or_regex='regex', include_or_exclude='include')
      for flt in filters:
        if match_vi(report_text, flt['value']) == -1: return -1

      filters = self.m_constraint.get_filters(token_id=token_id, text_or_regex='regex', include_or_exclude='exclude')
      for flt in filters:
        if match_vi(report_text, flt['value']) != -1: return -1

    return token_id

  def _focused_text (self, token_id, m_report_token):
    """def: _focused_text
       Return focused text. text other than focused text will not be visible in viewer buffer
    """
    focuses = self.m_constraint.get_focuses(token_id=token_id)
    info_txt = m_report_token.m_info.text
    for focus in focuses:
      m = 0
      matches = []
      while True:
        # m = match_vi(info_txt, focus['value'], m)
        # if m == -1: break

        matches += [matchstr_vi(info_txt, focus['value'], m)]
        m = matchend_vi(info_txt, focus['value'], m)

        if m == -1: break

      if matches: info_txt = ', '.join(matches)

    m_report_token.m_info.text = info_txt
    return str(m_report_token)
        

  def write (self):
    """def: write"""
    self.m_viewerbuf.init()
    # View window is empty if no report keys present
    tokens = self.m_constraint.get_tokens()

    if not tokens: return

    m_astrd = AST.uvm_report_ast_reader(db_dir=self.db_dir)

    # vim.command('let saveview = winsaveview()')

    savebuff = vim.current.buffer
    vim.current.buffer = self.m_viewerbuf.buff

    for m_report_token in m_astrd.read(*tokens):
      token_id = self._filter_pass(tokens, m_report_token)
      if token_id != -1:
        # text = str(m_report_token)

        text = self._focused_text(token_id, m_report_token)
          
        # Append result to the bufview window
        self.m_viewerbuf.append(text)

    vim.current.buffer = savebuff
    # vim.command('call winrestview(saveview)')

    m_astrd.close() # Must do it when done


#-------------------------------------------------------------------------------
# LoaderReport
#-------------------------------------------------------------------------------
class LoaderReport(LoaderBase):
  """class: LoaderReport"""

  def add_report (self):
    """def: add_report
       Add current report in current line
    """
    m_report_token = self.parse_line()

    if not m_report_token : return

    self.m_constraint.add_token(m_report_token)

    # Write filtered reports to viewerbuf
    # self.write()

  def remove_report (self):
    """def: remove_report
       Remove current report in current line
    """
    m_report_token = self.parse_line()

    if not m_report_token : return

    self.m_constraint.remove_token(m_report_token)

    # Write filtered reports to viewerbuf
    # self.write()

  def add_filter (self, **kwargs):
    """def: add_filter"""
    # Get the visual selected (using v,V..) text
    # text = UTILSBUF.getvisualtxt ()

    m_report_token = self.parse_line()

    if not m_report_token : return

    self.m_constraint.add_filter(m_report_token, **kwargs)

    self.write()

  def remove_filter (self):
    """def: remove_filter"""

    m_report_token = self.parse_line()

    if not m_report_token : return

    self.m_constraint.remove_filter(m_report_token)

    self.write()

  def clear_filters (self):
    """def: clear_filters"""
    self.m_constraint.clear_filters()

    self.write()

  def add_focus (self, **kwargs):
    """def: add_focus"""
    # Get the visual selected (using v,V..) text
    # text = UTILSBUF.getvisualtxt ()

    m_report_token = self.parse_line()

    if not m_report_token : return

    self.m_constraint.add_focus(m_report_token, **kwargs)

    self.write()

  def remove_focus (self):
    """def: remove_focus"""

    m_report_token = self.parse_line()

    if not m_report_token : return

    self.m_constraint.remove_focus(m_report_token)

    self.write()

  def clear_focuses (self):
    """def: clear_focuses"""
    self.m_constraint.clear_focuses()

    self.write()


if __name__ == "__main__":
  # Check if $BASE_DIR exists. The databse will be in base directory if exists
  # otherwise in the $HOME directory
  if 'BASE_DIR' in os.environ:
    db_dir = os.path.abspath('{0}/.ktagssim'.format(os.environ['BASE_DIR']))
  else:
    db_dir = os.path.abspath('{0}/.ktagssim'.format(os.environ['HOME']))

  m_loader_report = LoaderReport(db_dir=db_dir)
  m_loader_filter = LoaderFilter(db_dir=db_dir)

  #m_loader_toggler = LoaderToggler(db_dir='../simparser/')

  vim.command('''nmap <M-a> :py m_loader_report.add_report()<CR>''')
  vim.command('''nmap <M-d> :py m_loader_report.remove_report()<CR>''')
  vim.command('''nmap <M-t> :py m_viewer.toggle_buffer()<CR>''')
  # vim.command('''nmap <M-g> :py m_loader_toggler.toggle()<CR>''')






