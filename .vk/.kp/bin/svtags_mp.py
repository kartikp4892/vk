#!/usr/bin/env python

import os
import imp
import sys, getopt
import subprocess
import re
def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

#tags_agent_path = '{kp_vim_home}/python_lib/shell/uvm/ctags/utils/tags_agent_mp1.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
tags_agent_path = '{kp_vim_home}/python_lib/shell/uvm/ctags/utils/tags_agent_mp.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
TAGS_AGENT_PATH = import_(tags_agent_path)

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
  fileexts = ('.sv', '.svh', '.svi', '.v')

  """def: ParseArgs"""
  for arg in args:
    if os.path.isdir(arg):
      arg = os.path.abspath(arg)
      out, _ = subprocess.Popen('find {dir} -regextype sed -regex ".*\.sv[ih]\?\|.*\.v"'.format(dir=arg), shell=True, stdout=subprocess.PIPE).communicate()
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
      print ('Usage: svtags.py -d <outdir>')
      return None
    elif opt in ("-d", "--dir"):
      opts_h['dir'] = os.path.abspath(arg)
    elif opt in ("-e", "--exclude"):
      exdir = '/{0}/'.format(arg)
      exdir = re.sub(r'//+', '/', exdir)
      opts_h['exclude'].append(exdir)
      #opts_h['exclude'].append(arg)
    elif opt in ("-E", "--exclptrn"):
      opts_h['exclptrn'].append(arg)

  if 'dir' not in opts_h:
    directory = os.path.abspath('./svtags')
    if os.path.isfile(directory):
      print "Error: directory {file} is file!!".format(file=directory)
      help()
    opts_h['dir'] = directory

  if not os.path.isdir(opts_h['dir']):
    os.system('mkdir -p {dir}'.format(dir=opts_h['dir']))

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
  print "Parsing total {0} files".format(len(files))
  m_tags_agent = TAGS_AGENT_PATH.TagsAgent(files=files, outdir=opts_h['dir'])

  m_tags_agent.run()
  print "Results are generated in {0}".format(opts_h['dir'])








