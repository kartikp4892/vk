#!/usr/bin/env python

## TODO: Multiprocessing to reduce the time for large number of files??

import sys, getopt
import os
import subprocess
#from glob import glob
#import re
#import threading
#from utils.ctags import Ctags
#from utils.user_datatypes import UserDT
#from ThreadManager.manager import get_default_server



def help ():
  text = """
  Usage: svtags.py <options> <files>
  Options:
    -d or --dir <outdirectory>: Specify output directory name
    -e or --exclude <direory> : Specify subdirectory name to be excluded in generating tags
    -E or --exclptrn <ptrn>   : The directories/files matching the pattern will be excluded
  """
  print text
  quit()

def ParseArgs (opt_h, args):
  files = []
  fileexts = ('.sv', '.svh', '.svi')

  """def: ParseArgs"""
  for arg in args:
    if os.path.isdir(arg):
      arg = os.path.abspath(arg)
      out, _ = subprocess.Popen('find {dir} -regextype sed -regex ".*\.sv[ih]\?"'.format(dir=arg), shell=True, stdout=subprocess.PIPE).communicate()
      files.extend(out.split('\n'))
      if files[-1] == '':
        files.pop()
    elif os.path.isfile(arg):
      if arg.endswith(fileexts):
        afile = os.path.abspath(arg)
        files.append(afile)
    else:
      print "Error: can't find file/dir {file} !!!".format(file=arg)
      help()

  files = list(set(files))
  return files

def ParseOpts (opts):
  opts_h = {}
  opts_h['exclude'] = []
  opts_h['exclptrn'] = []
  for opt, arg in opts:
    if opt == '-h':
      help()
    elif opt in ("-e", "--exclude"):
      exdir = '/{0}/'.format(arg)
      exdir = re.sub(r'//+', '/', exdir)
      opts_h['exclude'].append(exdir)
      #opts_h['exclude'].append(arg)
    elif opt in ("-E", "--exclptrn"):
      opts_h['exclptrn'].append(arg)

  opts_h ['exclude'] = list(set(opts_h ['exclude']))
  opts_h ['exclptrn'] = list(set(opts_h ['exclptrn']))

  return opts_h

def GetOptArg(argv):
  try:
    opts, args = getopt.getopt(argv,"hd:e:E:",["ofile="])
    if opts == [] and args == []:
      help()
  except getopt.GetoptError:
    help()

  opts_h = ParseOpts (opts)
  files = ParseArgs (opts_h, args)

  for exclude in opts_h ['exclude']:
    files = filter(lambda f: exclude not in f, files)
    
  for exclptrn in opts_h ['exclptrn']:
    files = filter(lambda f: not re.search(exclptrn, f), files)
    
  return opts_h, files  


if __name__ == "__main__":

  opts_h, files = GetOptArg(sys.argv[1:])
  print "Processing {0} files".format(len(files))

  command = """
  vim -N -u NONE -esn \
    +"redir >> /dev/stdout" \
    +"set runtimepath+=$KP_VIM_HOME" \
    -S $KP_VIM_HOME/sv/commands.vim \
    +"BufdoANUvmInfo" \
    +"echo '\n'" \
    +"redir END" \
    +"qa!" \
    {infiles}
  """.format(infiles=' '.join(files))

  os.system(command)

















