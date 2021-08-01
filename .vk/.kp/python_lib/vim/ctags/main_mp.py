#!/usr/bin/env python

# Note: The script uses multithreading to parse sv files and generate tags

import sys, getopt
import os

#sys.path.append()

#from utils.ctags import Ctags
from utils.search import search_tags, search_typedef_tags, search_class_tags
from ThreadManager.manager import get_default_client
import vim

# /home/kartik/.vk/.kp/python_lib/vim/lib/sv/base/parser/Tags.py 
from sv.base.parser.Tags import connect_threadmanager

# || def GetOpt(argv):
# ||   outfile = None
# ||   infile = None
# ||   directory = None
# ||   try:
# ||     opts, args = getopt.getopt(argv,"hd:o:",["ofile="])
# ||     if opts == [] and args == []:
# ||       vim.command ('echoerr "Usage: test.py -f <outfile>"')
# ||   except getopt.GetoptError:
# ||     vim.command ('echoerr "Usage: test.py -f <outfile>"')
# ||     return None
# ||   for opt, arg in opts:
# ||     if opt == '-h':
# ||       vim.command ('echoerr "Usage: test.py -f <outfile>"')
# ||       return None
# ||     elif opt in ("-d", "--dir"):
# ||       directory = arg
# ||     elif opt in ("-t", "--tagfile"):
# ||       outfile = arg
# || 
# ||   return directory 

def bufdo_search_tags (funref):
  m_queue_client = get_default_client()
  m_queue_client.connect()
  connect_threadmanager()

  for b in vim.buffers:
    # If buffer without name
    vim.command ('silent b{buf}'.format(buf=b.number))
    if b.name == '':
      continue
    for m_token in funref():
      if m_token :
        #m_ctags.write(m_token)
        #m_queue_client.queue.put(str(m_token))
        m_queue_client.queue.put(m_token)

        if 'UserDT' in m_token._users:
          m_queue_client.userdts.add(m_token.name)

if __name__ == "__main__":

  #directory = GetOpt(sys.argv)
  #outfile = '{0}/tags'.format(directory)
  #m_ctags = Ctags(outfile)

  # Search typedef and class tags before all other tags to gather user datatypes
  bufdo_search_tags(search_typedef_tags)
  bufdo_search_tags(search_class_tags)
  bufdo_search_tags(search_tags)






