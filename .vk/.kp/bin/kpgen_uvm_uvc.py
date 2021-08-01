#!/usr/bin/env python

import sys, getopt
import os
import subprocess
import re
import shutil
 

prototype_dir = "{kp_home}/python_lib/shell/uvm/autogen/kpgen/prototype_uvc".format(kp_home=os.environ['KP_VIM_HOME'])
out_dir = "{pwd}".format(pwd=os.environ['PWD'])

def help ():
  text = """
  Usage: kpgen_uvm_uvc.py <options> 
  Options:
    -b or --uvc : uvc prototype name
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
    elif opt in ("-u", "--uvc"):
      if not re.match('\w+$', arg):
        print "Please provide valid values for --uvc"
        help()
      opts_h['uvc'] = arg

  if 'uvc' not in opts_h:
    print "No `--uvc argument provided!!!"
    quit()

  return opts_h

def GetOptArg(argv):
  try:
    opts, args = getopt.getopt(argv,"hu:",["uvc="])
    if opts == [] and args == []:
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

def process_uvc (opts_h):
  src_dir = prototype_dir
  dst_dir = "{out_dir}/{uvc}".format(out_dir=out_dir, uvc=opts_h['uvc'])

  create_dir(dst_dir)

  for filename in os.listdir(src_dir):
    if not filename.endswith(('.sv', '.svh', '.svi')):
      print "# Warning: Unknown file {0}".format(filename)
      continue

    srcfile = "{src_dir}/{filename}".format(src_dir=src_dir, filename=filename)
    dstfile = "{dst_dir}/{filename}".format(dst_dir=dst_dir, filename=filename.replace('prototype_', '{uvc}_'.format(uvc=opts_h['uvc'])))

    print "Processing {0} file".format(dstfile)

    with open(srcfile, 'r') as rfh, open(dstfile, 'w') as wfh:
      text = rfh.read()
      text = text.replace('prototype', opts_h['uvc'])
      text = text.replace('PROTOTYPE', opts_h['uvc'].upper())
      wfh.write(text)

if __name__ == "__main__":

  opts_h = GetOptArg(sys.argv[1:])

  process_uvc (opts_h)



