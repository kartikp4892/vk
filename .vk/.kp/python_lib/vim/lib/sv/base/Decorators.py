#!/usr/bin/env python

from sv.base.lexer.SharedVars import *

# This decorator restores the position of the lexer if the arg function is failed
def save_lexer_on_fail (orig_fun):
  def new_fun (*args, **kwargs):
    self = args[0]
    pos_bkp = self.m_lexer.get_pos() # Save Lexer
    #self.save_lexer()
    ret = orig_fun (*args, **kwargs)
    if ret:
      #self.reset_save()
      pos_bkp = None
    else:
      #self.restore_lexer()
      self.m_lexer.set_pos(pos_bkp) # Restore Lexer
    return ret
  return new_fun
      

def skip_to_eos_on_fail (orig_fun):
  def new_fun (*args, **kwargs):
    self = args[0]
    token = self.m_lexer.m_token
    skip = self.is_user_datatype()

    ret = orig_fun (*args, **kwargs)
    if not ret and skip:
      while not self.is_tag(EOS):
        if not self.m_lexer.next_token() : return 0

      # || # Debug to see at what positions the lexer is skipping to EOS
      # || import vim
      # || import time
      # || token.highlight('DiffChange')
      # || vim.command('redraw!')
      # || time.sleep(3)
      self.m_lexer.next_token()

    return ret
  return new_fun


def hightlight_it (org_fun):
  def new_fun (*args, **kwargs):
    self = args[0]
    ret = org_fun(*args, **kwargs)
    self.highlight_token()

    return ret
  return new_fun
    
def do_nothing (org_fun):
  def new_fun (*args, **kwargs):
    pass
  return new_fun


# Comment one of the below decorator based on debug mode on/off
debug = 0

if debug:
  def view_hightlight_runtime (org_fun):
    def new_fun (*args, **kwargs):
      ret = org_fun(*args, **kwargs)

      import vim
      import time
      vim.command('redraw!')
      time.sleep(1)

      return ret
    return new_fun
else:
  def view_hightlight_runtime (org_fun):
    def new_fun (*args, **kwargs):
      pass
    return new_fun

