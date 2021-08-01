#!/usr/bin/env python

import vim
import os, imp

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod


LEXER = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simparser/Lexer.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
COMBINATORS = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simparser/Combinators.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
# AST = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simparser/ast.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
# UTILS = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/utils/utils.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
# LOGGER = import_('{kp_vim_home}/python_lib/vim/lib/sv/base/Singleton.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
# TOKEN = import_('{kp_vim_home}/python_lib/vim/lib/sv/base/lexer/Token.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))

class LineParser(object):
  """class: LineParser"""

  def __init__(self):
    pass

  def goto_start (self):
    """def: goto_start
       Go to start of line where UVM_INFO.. etc started
    """
    vim.command('normal $')
    ln = int(vim.eval('''search('\\v# UVM_(INFO|ERROR|WARNING|FATAL)', 'bW')'''))
    return ln
      
  def parse (self):
    """def: parse"""
    ln = self.goto_start()
    if not ln: 
      # raise Exception("No report found in current line")
      print "No report found in current line"
      return None # Don't give error if can't find report

    # m_lexer = LEXER.Lexer()
    start = ln - 1
    end = len(vim.current.buffer) - 1
    m_lexer = LEXER.Lexer(start=start, end=end)
    m_lexer.next_token()

    # print m_lexer.m_token
    m_uvm_info = COMBINATORS.UVM_INFO(m_lexer=m_lexer)
    m_uvm_error = COMBINATORS.UVM_ERROR(m_lexer=m_lexer)
    m_uvm_warning = COMBINATORS.UVM_WARNING(m_lexer=m_lexer)
    m_uvm_fatal = COMBINATORS.UVM_FATAL(m_lexer=m_lexer)

    if m_uvm_info.parse_header(): return m_uvm_info.m_report_token
    elif m_uvm_error.parse_header(): return m_uvm_error.m_report_token
    elif m_uvm_warning.parse_header(): return m_uvm_warning.m_report_token
    elif m_uvm_fatal.parse_header(): return m_uvm_fatal.m_report_token
    else: raise Exception("Unable to process REPORT in current line")
      

if __name__ == '__main__':
  m_lineparser = LineParser()
  vim.command('''nmap <F5> :py print m_lineparser.parse() ''')



