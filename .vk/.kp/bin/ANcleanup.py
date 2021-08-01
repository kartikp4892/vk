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
    -v or --verbosity <l/m/h>: Run the script with l - Low verbosity, m - Medium verbosity, h - High verbosity
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
  if not files:
    sys.stderr.write('Error: No input files provided in the argument')
    help()
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
    elif opt in ("-v", "--verbosity"):
      if arg not in ('l', 'm', 'h'):
        sys.stderr.write('Error: Unknown argument -v {arg}'.format(arg=arg))
        help()
      opts_h['verbosity'] = arg

  opts_h ['exclude'] = list(set(opts_h ['exclude']))
  opts_h ['exclptrn'] = list(set(opts_h ['exclptrn']))

  return opts_h

def GetOptArg(argv):
  try:
    opts, args = getopt.getopt(argv,"hv:e:E:",["ofile="])
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

  svcleanup_commands = ""
  if opts_h.get('verbosity', None):

    # If verbosity is high include add below command in code cleanup
    #   SVIndentCleanUp
    #   SVCodeComment all
    #   SVEndLabel all
    if opts_h['verbosity'] == 'h': # High
      svcleanup_commands = """ +"bufdo set shiftwidth=2" +"BufdoSVcleanup" """ # shiftwidth is used in indentation 
    
  command = """
  vim -N -u NONE -esn \
    +"redir >> /dev/stdout" \
    +"set runtimepath+=$KP_VIM_HOME" \
    -S $KP_VIM_HOME/sv/commands.vim \
    +"BufdoANcleanup" \
    {commands} \
    +"echo '\n'" \
    +"redir END" \
    +"qa!" \
    {infiles}
  """.format(infiles=' '.join(files), commands=svcleanup_commands)

  #print command
  os.system(command)


  # Check for __TBD__ which script couldn't recognize
  out, _ = subprocess.Popen('grep -rl "__TBD__" {files}'.format(files=' '.join(files)), shell=True, stdout=subprocess.PIPE).communicate()

  if out != '':
    tbd_files = out.split('\n')

    message = """
    ################################################################################
    # Please work on __TBD__ in below file(s)
    {files}
    ################################################################################
    """.format(files=out)
    print message

    os.system('gvim -n +"nmap <F5> :SearchInBuffer \'__TBD__\'<CR>" +"match Error \'__TBD__\'" +"source $KP_VIM_HOME/source_scripts.vim" {files}'.format(files=' '.join(tbd_files)))
  














