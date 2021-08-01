#!/usr/bin/env python

import sys, os, getopt
import imp

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod


AST = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simparser/ast.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))


def help ():
  text = """
  Usage: svtags.py [<options>] [<logfile>]
  Options:
    -d or --dir <outdirectory>: Specify db directory name. Default: $BASE_DIR or $HOME
  Example: svtags.py -d $BASE_DIR/.ktagssim temp.log
  If logfile name is not provided input is read from STDIN
  """
  print text
  quit()


def ParseArgs (args):
  files = []
  fileexts = ('.log',)

  """def: ParseArgs"""
  for arg in args:
    if os.path.isfile(arg):
      if arg.endswith(fileexts):
        afile = os.path.abspath(arg)
        files.append(afile)
    else:
      raise Exception("Error: can't find file {file} !!!".format(file=arg))
      # traceback.print_stack(file=sys.stdout)
      quit()

  files = list(set(files))
  return files

def ParseOpts (opts):
  opts_h = {}
  for opt, arg in opts:
    if opt == '-h':
      help()
    elif opt in ("-d", "--dir"):
      opts_h['dir'] = os.path.abspath(arg)
    else:
      raise Exception("Unknown option {0}".format(opt))

  if 'dir' not in opts_h:
    # Check if $BASE_DIR exists. The databse will be created in base directory if exists
    # otherwise in the $HOME directory
    if 'SIM_DB_DIR' in os.environ: 
      directory = os.environ['SIM_DB_DIR']
    elif 'BASE_DIR' in os.environ: 
      directory = os.path.abspath('{0}/.ktagssim'.format(os.environ['BASE_DIR']))
    else:
      directory = os.path.abspath('{0}/.ktagssim'.format(os.environ['HOME']))

    if os.path.isfile(directory):
      print "Error: directory {file} is file!!".format(file=directory)
      help()
    opts_h['dir'] = directory

  if not os.path.isdir(opts_h['dir']):
    os.system('mkdir -p {dir}'.format(dir=opts_h['dir']))

  return opts_h

def GetOptArg(argv):
  try:
    opts, args = getopt.getopt(argv,"hd:e:E:",["ofile="])
    # || if opts == [] and args == []:
    # ||   help()
  except getopt.GetoptError:
    help()

  opts_h = ParseOpts (opts)
  files = ParseArgs (args)

  return opts_h, files  

if __name__ == "__main__":
  opts_h, files = GetOptArg(sys.argv[1:])

  if len(files) == 0:
    m_astwr = AST.uvm_report_ast_writer(db_dir=opts_h['dir']) # Read from stdin
  else:
    m_astwr = AST.uvm_report_ast_writer(logfile=files[0], db_dir=opts_h['dir']) # Read from logfile

  m_astwr.write()
  m_astwr.close() # Must do it when done
  print "Results are generated in {0}".format(opts_h['dir'])
  




