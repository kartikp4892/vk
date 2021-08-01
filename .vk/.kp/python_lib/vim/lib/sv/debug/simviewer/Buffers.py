#!/usr/bin/env python

import vim
import imp, os

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod


META = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/utils/metaclasses.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
SYNTAX = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simviewer/Syntax.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))

UseScratch = vim.Function('tlib#scratch#UseScratch')
bufnr = vim.Function('bufnr')

class Buffer(object):
  """class: Buffer"""

  def __init__(self):
    self.buff = None

  def activate (self):
    """def: activate"""
    vim.current.buffer = self.buff
    
  def is_active (self):
    """def: is_active"""
    return vim.current.buffer == self.buff
      
class ViewerBuf(Buffer):
  """class: ViewerBuf"""

  # __metaclass__ = META.Singleton

  def __init__(self, **kwargs):
    name = kwargs.get('name', 'Viewer')

    self.buff_id = UseScratch({'scratch':name})
    self.buff = vim.buffers[self.buff_id]

    # Syntax Highlight for the buffer
    SYNTAX.syntax()

    self.hide()
    
  def hide (self):
    """def: hide"""
    
    vim.command('quit') # Close the viewer window but it will be there in buffer list
  
  def init (self):
    """def: init"""
    savebuff = vim.current.buffer
    vim.current.buffer = self.buff
    self.buff[:] = None # Delete the whole buffer
    vim.current.buffer = savebuff

  def append (self, text):
    """def: append"""
    lines = text.split('\n')

    # Append result to the bufview window
    self.buff.append(lines)


class LogBuf(Buffer):
  """class: LogBuf"""

  __metaclass__ = META.Singleton

  def __init__(self):
    self.buff = vim.current.buffer
    self.buff_id = vim.current.buffer.number




