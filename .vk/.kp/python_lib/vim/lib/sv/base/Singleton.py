#!/usr/bin/env python

try:
  import vim
  vim_detected = 1
except Exception:
  vim_detected = 0

import os

class Singleton(type):
  """class: Singleton"""

  _instances = {}

  def __call__(cls, *args, **kwargs):
    if cls not in cls._instances:
      cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
      cls._instances[cls].__init__(*args, **kwargs)
    return cls._instances[cls]


class Logger(object):
  """class: Logger"""
  __metaclass__ = Singleton

  def __sh_init__ (self, **kwargs):
    """def: __sh_init__"""
    if vim_detected == 1: return 0

    # File name must be provided when script is running from linux shell
    fname = kwargs.get('fname', None)
    if not fname:
      fname = "{home}/debug.log".format(home=os.environ['HOME'])

    self.fh = open(fname, 'w')

  def __init__ (self, **kwargs):
    """Constructor"""
    self.debug = 0
    self.buffer = None
    self.__sh_init__(**kwargs)

  def vi_debug_mode (self):
    """def: vi_debug_mode"""
    if vim_detected == 0: return 0
      
    if self.debug == 1:
      win_save = vim.current.window
      if self.buffer:
        self.buffer[:] = None # Delete the whole buffer
      else:
        self.buffer = vim.buffers[int(vim.eval('tlib#scratch#UseScratch()'))]

      vim.current.window = win_save

  def debug_mode (self, val):
    """def: debug_mode"""
    self.debug = val
    self.vi_debug_mode()

  def vi_append (self, text):
    """def: vi_append"""
    if vim_detected == 0: return 0
    if self.debug:
      lines = text.split("\n")
      self.buffer.append(lines)

  def sh_append (self, text):
    """def: sh_append"""
    if vim_detected == 1: return 0
    if self.debug:
      self.fh.write(text)

  def append (self, text):
    """def: append"""
    self.vi_append(text)
    self.sh_append(text)

  def vi_set (self, text):
    """def: vi_set"""
    if vim_detected == 0: return 0

    if self.debug:
      lines = text.split("\n")
      self.buffer[:] = None
      self.buffer.append(lines)

  def set (self, text):
    """def: set"""
    self.vi_set(text)
    self.sh_append(text)

  def __del__ (self):
    """def: __del__"""
    self.fh.close()


