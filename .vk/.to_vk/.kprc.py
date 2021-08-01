#!/usr/bin/env python

if __name__ == "__main__":
  import vim
  import os

  #vim.command('so {home}/.vk/ftdetect/filetype.vim'.format(home=os.environ['HOME']))
  vim.command('so {home}/.vk/ftdetect/filetype.vim'.format(home=os.environ['VIMSHARE']))
  
  
