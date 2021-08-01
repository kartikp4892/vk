#!/usr/bin/env python

import sys, getopt
import os
import subprocess
import re
import shutil
 

prototype_dir = "{kp_home}/python_lib/shell/uvm/autogen/kpgen/base".format(kp_home=os.environ['KP_VIM_HOME'])
out_dir = "{pwd}".format(pwd=os.environ['PWD'])

def help ():
  text = """
  Usage: kpgen_uvm_base.py <options> 
  Options:
    -b or --base : base prototype name
  """
  print text
  quit()

def ParseOpts (opts):
  opts_h = {}
  opts_h['exclude'] = []
  opts_h['exclptrn'] = []
  for opt, arg in opts:
    if opt == '-h':
      help()
    elif opt in ("-b", "--base"):
      if not re.match('\w+$', arg):
        print "Please provide valid values for --base"
        help()
      opts_h['base'] = arg

  if 'base' not in opts_h:
    opts_h['base'] = 'base'

  return opts_h

def use_default ():
  yes = set(['yes','y', 'ye', ''])
  no = set(['no','n'])

  choice = raw_input('# No `--base` argument provided. Use default value `--base base`? [y/n] [yes]').lower()
  if choice in yes:
     return True
  elif choice in no:
     return False
  else:
     sys.stdout.write("Please respond with 'yes' or 'no'")

def GetOptArg(argv):
  try:
    opts, args = getopt.getopt(argv,"hb:",["base="])
    if opts == [] and args == []:
      if not use_default():
        help()
  except getopt.GetoptError:
    help()

  opts_h = ParseOpts (opts)

  return opts_h


def create_dir(directory):
  if os.path.exists(directory):
    print "Directory {directory} already exists!!!".format(directory=directory)
    quit()

  try:
    os.mkdir(directory)
  except OSError as e:
    print('Can not create directory. Error: %s' % e)

def process_base (opts_h):
  src_dir = prototype_dir
  dst_dir = "{out_dir}/{base}".format(out_dir=out_dir, base=opts_h['base'])

  create_dir(dst_dir)

  for filename in os.listdir(src_dir):
    if not filename.endswith(('.sv', '.svh', '.svi')):
      print "# Warning: Unknown file {0}".format(filename)
      continue
    print "Processing {0} file".format(filename)

    srcfile = "{src_dir}/{filename}".format(src_dir=src_dir, filename=filename)
    dstfile = "{dst_dir}/{filename}".format(dst_dir=dst_dir, filename=filename.replace('base_', '{base}_'.format(base=opts_h['base'])))

    with open(srcfile, 'r') as rfh, open(dstfile, 'w') as wfh:
      text = rfh.read()
      text = text.replace('base', opts_h['base'])
      text = text.replace('BASE', opts_h['base'].upper())
      wfh.write(text)

if __name__ == "__main__":

  opts_h = GetOptArg(sys.argv[1:])

  process_base (opts_h)



