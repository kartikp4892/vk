#!/usr/bin/env python

# Note: This script is same as tag2syntax except it runs through command line instead of inside vim
# TODO: Fix the script such that only desire output printed also in case of error

import imp
import os
import sys, getopt

env_vars_path = '{kp_vim_home}/python_lib/vim/lib/Utils/env_vars.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
envutils = imp.load_source('env_vars', env_vars_path)

def help ():
  text = """
  Usage: tag2syntax_prg.py <options>
  Options:
    -c or --clsname : Get syntax for specified class name
  """
  print text
  quit()

def ParseOpts (opts):
  opts_h = {}
  opts_h['exclude'] = []
  opts_h['exclptrn'] = []
  for opt, arg in opts:
    if opt == '-h':
      print ('Usage: svtags.py -d <outdir>')
      return None
    elif opt in ("-c", "--clsname"):
      opts_h['clsname'] = arg

  if 'clsname' not in opts_h:
      help()

  return opts_h

def GetOptArg(argv):
  try:
    opts, args = getopt.getopt(argv,"hc:",["clsname="])
    if opts == [] and args == []:
      help()
  except getopt.GetoptError:
    help()

  opts_h = ParseOpts (opts)

  return opts_h

def get_class_syntax (clsname):
  """def: get_class_syntax
     This function returns the valid syntax of class type (ex: For parameterized class sytax will be `clsname #(.P1(...), .P2(...))`)
     1. Go to tag position
     2. Parse class header
     3. Return class syntax
     Returns class name provided in the argument if fails
  """

  #cmd = """gvim -N -Rnc  \
  cmd = """gvim -N -u NONE -Resnc \
     "set tags={svtags}"\
    +"set runtimepath={kp_vim_home},{vim_home}"\
    +"py import imp,os"\
    +"py tag2syntax = imp.load_source('tag2syntax', '{kp_vim_home}/python_lib/vim/lib/Utils/tag2syntax.py')" \
    +"py cls_syntax = tag2syntax.get_class_syntax('{clsname}')" \
    +"redir! >> /dev/stdout" \
    +"py print cls_syntax" \
    +"redir END" \
    +"qa!"
    """.format(vim_home=os.environ['VIM_HOME'], kp_vim_home=os.environ['KP_VIM_HOME'], clsname=clsname, svtags=','.join(map(lambda x: "{0}/**/tags".format(x), envutils.env2path('SVTAGSPATH'))))
  os.system(cmd)

if __name__ == "__main__":
  opts_h = GetOptArg(sys.argv[1:])

  if 'clsname' in opts_h:
    get_class_syntax(opts_h['clsname'])




