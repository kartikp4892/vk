#!/usr/bin/env python

# /home/kartik/.vk/.kp/python_lib/vim/lib/sv/base/parser/Tags.py 
from sv.base.parser.Tags import DYNAMIC_USERDTS

import sys, getopt
import os

#sys.path.append()

from utils.tags_pool import TagsPool
from utils.search import search_tags, search_typedef_tags, search_class_tags
import vim

def GetOpt(argv):
  opts_h = {}
  try:
    opts, args = getopt.getopt(argv,"hd:o:",["ofile="])
    if opts == [] and args == []:
      print ('"Usage: test.py -d <outdir>"')
  except getopt.GetoptError:
    print ('echoerr "Usage: test.py -d <outdir>"')
    return None
  for opt, arg in opts:
    if opt == '-h':
      print ('echoerr "Usage: test.py -d <outdir>"')
      return None
    elif opt in ("-d", "--dir"):
      opts_h['dir'] = arg
    #elif opt in ("-t", "--tagfile"):
    #  opts_h['tagfile'] = arg

  return opts_h, args  

debug = 0
def print_debug (msg):
  if debug == 1:
    vim.command('redir >> /dev/stdout')
    print msg
    vim.command('redir END')

def bufdo_search_tags (funref):
  for b in vim.buffers:
    # If buffer without name
    vim.command ('silent b{buf}'.format(buf=b.number))
    if b.name == '':
      continue

    print_debug ("Processing file: {file}".format(file=b.name)) #DEBUG

    for m_token in funref():
      if m_token :
        m_tagspool.write(m_token)

        # If userdefined type token
        if 'UserDT' in m_token._users:
          DYNAMIC_USERDTS.add(m_token.name)

if __name__ == "__main__":

  opts_h, args = GetOpt(sys.argv)
  outdir = opts_h['dir']

  tagfile = '{0}/tags'.format(outdir)
  userdt_file = '{0}/userdatatypes'.format(outdir)
  class_tree_tags_file = '{0}/_class_tree.py'.format(outdir)

  m_tagspool = TagsPool(ctags_file=tagfile, userdt_file=userdt_file, class_tree_tags_file=class_tree_tags_file)

  bufdo_search_tags(search_typedef_tags)
  bufdo_search_tags(search_class_tags)
  bufdo_search_tags(search_tags)







