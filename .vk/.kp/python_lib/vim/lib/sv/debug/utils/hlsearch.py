#!/usr/bin/env python

import vim
import threading
import os, imp

matchadd = vim.Function('matchadd')
search = vim.Function('search')
match = vim.Function('match')
UseScratch = vim.Function('tlib#scratch#UseScratch')
clearmatches = vim.Function('clearmatches')
winsaveview = vim.Function('winsaveview')
winrestview = vim.Function('winrestview')

class hlsearch(object):
  """class: hlinput
     This class provides the input method
  """

  callbacks = []
  winsaveview = None

  def __init__ (self):
    """Constructor"""
    self.win = None
    self.hlwin = None

  def __init (self, **kwargs):
    """Constructor"""
    hlsearch.callbacks = kwargs['callbacks']
    self.win = vim.current.window

    scratch = kwargs.get('scratch', '__hlinput_{0}__'.format(self.win.buffer.number))
    UseScratch({'scratch': scratch})

    self.hlwin = vim.current.window
    self.__activate()
    self.__clear_hlbuf()
    self.__commands()

  def __commands (self):
    """def: __commands"""
    vim.options['updatetime'] = 500 # Update time for CursorHold event

    # Auto commands
    vim.command('augroup hlsearch')
    vim.command('autocmd! * <buffer>')
    vim.command('autocmd CursorHold,CursorMovedI,InsertEnter <buffer> py HLSEARCH.hlsearch._bufsearch(hlbuf_num={0}, buf_num={1})'.format(self.hlwin.number, self.win.number)) # TODO: Remove HLSEARCH. Added because Viewer.py is using import_ function to import the module
    vim.command('augroup END')

    # Mappings
    vim.command('nnoremap <buffer> <CR> :py HLSEARCH.hlsearch._input_cb(hlbuf_num={0}, buf_num={1})<CR>'.format(self.hlwin.number, self.win.number)) # Hit enter to accept input in normal mode
    vim.command('inoremap <buffer> <CR> <ESC>:py HLSEARCH.hlsearch._input_cb(hlbuf_num={0}, buf_num={1})<CR>'.format(self.hlwin.number, self.win.number)) # Hit enter to accept input in insert mode
    # || vim.command('nmap <silent> <buffer> <ESC> :q<CR>'.format(self.hlwin.number)) # Esc to cancel user input

  def __clear_hlbuf (self):
    """def: __clear_hlbuf"""
    savewin = vim.current.window
    vim.current.window = self.hlwin
    vim.current.buffer[:] = None # Delete the whole buffer
    vim.current.window = savewin

  def __activate (self):
    """def: __activate"""
    vim.current.window = self.hlwin

  @staticmethod
  def _bufsearch (**kwargs):
    """def: _bufsearch"""
    hlwin = vim.windows[kwargs['hlbuf_num'] - 1]
    win = vim.windows[kwargs['buf_num'] - 1]

    if not win: raise Exception('Not able to find buffer!!!')

    ptrn = hlwin.buffer[0]

    if ptrn.endswith(r'\z'): return # Giving error in vim when \z is inserted
      
    if match(ptrn, '^\s*$') != -1: return

    vim.current.window = win
    try:
      search(ptrn)
      clearmatches()
      matchadd('Search', ptrn,10,4)
      vim.command('redir END')
    except Exception:
      clearmatches() # Don't give error if invalid syntax in search pattern.

    vim.current.window = hlwin

  @staticmethod
  def _input_cb (**kwargs):
    """def: _input_cb"""
    hlwin = vim.windows[kwargs['hlbuf_num'] - 1]
    win = vim.windows[kwargs['buf_num'] - 1]
    line, col = hlwin.cursor
    ptrn = hlwin.buffer[line - 1]

    vim.command('q')
    clearmatches()

    # Don't process if empty string
    if not ptrn: return

    try:
      vim.command('/{0}'.format(ptrn))
    except Exception:
      pass

    winrestview(hlsearch.saveview)
    vim.current.window = win
    vim.command('redraw')

    for callback in hlsearch.callbacks:
      callback(value=ptrn)

  def input (self, **kwargs):
    """def: input
       This function will get the input synchournously from the user in scratch buffer.
       Once user will provide input callbacks functions will be called with the value as argument.
    """
    hlsearch.saveview = winsaveview()
    self.__init(**kwargs)
    self.__activate()
    self.__clear_hlbuf()

    # Load history in hlwindow
    if 'history' in kwargs:
      vim.current.buffer.append(kwargs['history'])




#def hlsearch (buf):
#  """ hlsearch : Get input from user """
#  getchar = vim.Function('getchar')
#  nr2char = vim.Function('nr2char')
#  escape = vim.Function('escape')
#  matchadd = vim.Function('matchadd')
#  search = vim.Function('search')
#
#  print ""
#  text = ''
#  while True:
#    nr = getchar()
#    char = nr2char(nr)
#    if nr == 13: break # <CR>
#
#    if int(vim.eval('"{nr}" == "\<BS>"'.format(nr=nr))):
#      text = text[0:-1]
#    else:
#      text += char
#
#    vim.command('call clearmatches()')
#    search(text)
#    matchadd('Visual', text,0,4)
#    #vim.command('''match Visual '{0}' '''.format(text))
#    vim.command('redraw')
#    print '''match Visual "{0}" '''.format(escape(text, '\\'))
#    #print text
#  print text



if __name__ == "__main__":
  def display (**kwargs):
    print kwargs

  from functools import partial
  hlsearch().input(partial(display, arg1="Arg1"))











