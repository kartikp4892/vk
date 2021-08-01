#!/usr/bin/env python

try:
  import vim
  vim_detected = 1
except Exception:
  vim_detected = 0

import os, sys
import imp
from contextlib import closing
import sqlite3
from functools import partial

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod


LEXER = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simparser/Lexer.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
COMBINATORS = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simparser/Combinators.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
UTILS = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/utils/utils.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
LOGGER = import_('{kp_vim_home}/python_lib/vim/lib/sv/base/Singleton.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
TOKEN = import_('{kp_vim_home}/python_lib/vim/lib/sv/base/lexer/Token.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))

class uvm_report_ast_parser(COMBINATORS.Parser):
  """class: uvm_report_ast_parser"""

  def __init__(self, **kwargs):
    super(uvm_report_ast_parser, self).__init__(**kwargs)

  def funwrap (self, m_comb):
    """def: funwrap
       This is wrapper function which calls parse method of combinator and returns
       the object of combinator on sucess
    """
    if m_comb.parse(): return m_comb
    return None
    
  def parse (self):
    """def: parse"""
    m_bnf = [TOKEN.Or(
                        partial(self.funwrap, COMBINATORS.UVM_INFO(m_lexer=self.m_lexer)),
                        partial(self.funwrap, COMBINATORS.UVM_ERROR(m_lexer=self.m_lexer)),
                        partial(self.funwrap, COMBINATORS.UVM_WARNING(m_lexer=self.m_lexer)),
                        partial(self.funwrap, COMBINATORS.UVM_FATAL(m_lexer=self.m_lexer))
                     )]
    m_comb_gen = COMBINATORS.CombinatorGen(self.m_lexer)
    while True:
      if self.tryparse(partial(m_comb_gen.parse, *m_bnf)): 
        yield m_comb_gen.results
        continue

      self.m_lexer.skip_line()
      if not self.m_lexer.next_token(): break
        

#-------------------------------------------------------------------------------
# uvm_report_astdb
#-------------------------------------------------------------------------------
class uvm_report_astdb(object):
  """class: uvm_report_astdb"""

  def __init__(self, **kwargs):
    self.db_dir = '{0}/_sim'.format( kwargs['db_dir'] ) #
    # self.db_dir = '{0}/_sim'.format( kwargs.get('db_dir', os.getcwd()) ) # Previously db_dir was optional.. default dir was current dir
    self.db_name = '{0}/_ast.db'.format(self.db_dir)

    # Create db_dir if not exists
    UTILS.ensure_dir(self.db_dir)

    self.cunn = sqlite3.connect(self.db_name) # sqlite3 Connection 
    self.cur = self.cunn.cursor() # sqlite3 cursor

    # Fix: unicode string error 
    self.cunn.text_factory = str

    # WAL Mode enables concurrent Read/Write at the same time
    self.cur.execute('PRAGMA journal_mode=wal')
    # self.cur.execute('PRAGMA wal_autocheckpoint = 1')

  def close (self):
    """def: close
       Close the database connection when done
    """
    self.cur.close()
    self.cunn.commit()
    self.cunn.close()
    
  def hash_to_select_expr (self, **kwargs):
    """def: hash_to_select_expr"""
    if len(kwargs) == 0:
      raise Exception("Argument required!!!")

    # Ignore other keys not included in column of table
    filtered_dict = {k:v for k,v in kwargs.iteritems() if k in COMBINATORS.ReportToken.heading}

    keys = filtered_dict.keys()
    values = filtered_dict.values()
    phtxt = ' AND '.join(["{0}=?".format(x) for x in keys])
    expr = '({0})'.format(phtxt)
    return expr, values

    

#-------------------------------------------------------------------------------
# uvm_report_ast_writer
#-------------------------------------------------------------------------------
class uvm_report_ast_writer(uvm_report_astdb):
  """class: uvm_report_ast_writer"""

  def __init__ (self, **kwargs):
    """def: __init__"""
    super(uvm_report_ast_writer, self).__init__(**kwargs)
    self.logfile = kwargs.get('logfile', None)

  def ast_parse (self):
    """def: ast_parse"""
    if vim_detected:
      m_lexer = LEXER.Lexer()
    else:
      if self.logfile:
        fh = open(self.logfile, 'rb')
      else:
        print "Warning: Filename is not provided. Reading from stdin..."
        fh = sys.stdin

      m_lexer = LEXER.Lexer(filehandle=fh)

    m_lexer.next_token()

    m_uvm_report_ast_parser = uvm_report_ast_parser(m_lexer=m_lexer)

    for m_combinators in m_uvm_report_ast_parser.parse():
      yield m_combinators

  def write (self):
    """def: write"""
    phtxt = '(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)' # Placeholder in sql

    self.cur.execute('''DROP TABLE IF EXISTS sim''')
    self.cur.execute('''CREATE TABLE sim ({0})'''.format(','.join(COMBINATORS.ReportToken.heading)))

    pragma_threshold = 1000
    pragma_idx = 0

    for m_combinators in self.ast_parse():
      for m_combinator in m_combinators:
        m_report_token = m_combinator.m_report_token
        self.cur.execute('INSERT INTO sim values {0}'.format(phtxt), m_report_token.get_values())

        #-------------------------------------------------------------------------------
        # WAL Checkpoint every 1000 transaction
        pragma_idx += 1
        if pragma_idx >= pragma_threshold:
          self.cur.execute("PRAGMA wal_checkpoint=FULL")
          pragma_idx = 0
        #-------------------------------------------------------------------------------
            
#-------------------------------------------------------------------------------
# uvm_report_ast_reader
#-------------------------------------------------------------------------------
class uvm_report_ast_reader(uvm_report_astdb):
  """class: uvm_report_ast_reader"""

  def read (self, *args):
    """def: read
       Generator that yields the COMBINATORS.ReportToken object
       args => [{file_: file1, line: line1 ...etc }, {file: file2..etc}]
       returns all rows from matching any one of the args
    """
    if len(args) == 0:
      # self.cur.execute('SELECT * FROM sim') # TODO: Do we need to return all report when no argument provided
      raise Exception("No argument provided!!!")
    else:
      expr_all = []
      values_all = []
      for kwargs in args:
        expr, values = self.hash_to_select_expr(**kwargs)
        expr_all.append(expr)
        values_all.extend(values)

      statement = 'SELECT * FROM sim WHERE {0}'.format(' OR '.join(expr_all))
      # print statement , tuple(values_all)
      self.cur.execute(statement, values_all)

    for row in self.cur:
      m_report_token = COMBINATORS.ReportToken()
      m_report_token.set_values(row)
      # print m_report_token
      yield m_report_token

    
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

  #-------------------------------------------------------------------------------
  # AST WRITER CODE
  if len(files) == 0:
    m_astwr = uvm_report_ast_writer(db_dir='{0}/ktagssim'.format(os.environ['HOME'])) # Input from stdin
  else:
    m_astwr = uvm_report_ast_writer(logfile=files[0], db_dir='{0}/ktagssim'.format(os.environ['HOME'])) # Input from logfile

  m_astwr.write()
  m_astwr.close() # Must do it when done
  #-------------------------------------------------------------------------------

  #-------------------------------------------------------------------------------
  # AST READER CODE
  m_astrd = uvm_report_ast_reader(db_dir='{0}/ktagssim'.format(os.environ['HOME']))

  for row in m_astrd.read({'file_':"/home/kartikp/projects/bae_ace_fpgas/ace_fpgas/bae_ace_fpgas/trunk/IFCE_ACE_NM_COM3/../common/vip/ifdl/ifdl_monitor.sv", 'line':'76'},
                          {'file_':"/home/kartikp/projects/bae_ace_fpgas/ace_fpgas/bae_ace_fpgas/trunk/IFCE_ACE_NM_COM3/../common/vip/ifdl/ifdl_monitor.sv", 'line':'164'}):
                          
    print row

  #for row in m_astrd.read():
  #  print row

  m_astrd.close() # Must do it when done
  #-------------------------------------------------------------------------------




