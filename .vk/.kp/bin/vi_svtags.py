#!/usr/bin/env python

# Note: This is multithreading version of svtags.sh.
#       TODO: File svtags_mp.py is reduntant and outdated so needs to be removed

import sys, getopt
from glob import glob
import os
import re
import subprocess
import threading
from utils.tags_pool import TagsPool
from ThreadManager.manager import get_default_server

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

class CtagsTread(threading.Thread):
  """class: CtagsTread"""
  def __init__(self, m_semaphore, infiles):
    threading.Thread.__init__(self)
    self.infiles = infiles
    self.m_semaphore = m_semaphore
    #self.event = threading.Event()

  def run (self):
    """def: run"""
    #self.event.clear()
    self.m_semaphore.acquire()

    #main_mp_script = 'main_mp.py' # This generates typdef tags also
    main_mp_script = 'main_search_tags_mp.py' # This excludes typedef tags

    os.system('vim -N -u NONE -Resn +"pyfile $KP_VIM_HOME/python_lib/vim/ctags/{main_mp}" +"qa!" {infiles}'.format(main_mp=main_mp_script, infiles=' '.join(self.infiles)))
    # || DEBUG || os.system('vim -N -u NONE -Resn +"redir! >> /dev/stdout" +"pyfile $KP_VIM_HOME/python_lib/vim/ctags/{main_mp}" +"redir END" +"qa!" {infiles}'.format(main_mp=main_mp_script, infiles=' '.join(self.infiles)))
    # || DEBUG || os.system('gvim -N -Rnc +"redir! >> /dev/stdout" +"pyfile $KP_VIM_HOME/python_lib/vim/ctags/{main_mp}" +"redir END" {infiles}'.format(main_mp=main_mp_script, infiles=' '.join(self.infiles)))

    #subprocess.check_call(['vi' , '-N', '-u', 'NONE', '-Resnc', "pyfile {kp_vim_home}/python_lib/vim/ctags/main_mp.py".format(kp_vim_home=os.environ['KP_VIM_HOME']), '+"qa!"', self.infiles[0]])
    #subprocess.check_call(['gvim' '-Rnc', "pyfile {kp_vim_home}/python_lib/vim/ctags/main_mp.py".format(kp_vim_home=os.environ['KP_VIM_HOME']), self.infiles[0]])
    self.m_semaphore.release()
    #self.event.set()

class QueueThread(threading.Thread):
  """class: QueueThread"""

  done = 0

  def __init__(self, outdir):
    threading.Thread.__init__(self)
    self.tagfile = '{0}/tags'.format(outdir)
    self.userdt_file = '{0}/userdatatypes'.format(outdir)
    self.class_tree_tags_file = '{0}/_class_tree.py'.format(outdir)

    self.m_tagspool = TagsPool(ctags_file=self.tagfile, userdt_file=self.userdt_file, class_tree_tags_file=self.class_tree_tags_file)

  def run (self):
    """def: run"""
    while not QueueThread.done:
      if not m_queue_server.queue.empty():
        m_token = m_queue_server.queue.get()

        self.m_tagspool.write(m_token)


def split_array(alist, maximum=10):
  length = len(alist)
  idx = 0
  rlist = []
  while idx < length:
    if length < idx + maximum:
      rlist.append(alist[idx: length])
    else:
      rlist.append(alist[idx: idx + maximum])

    idx += maximum

  return rlist

if __name__ == "__main__":

  opts_h, files = GetOptArg(sys.argv[1:])

  m_queue_server = get_default_server()
  m_queue_server.start()
  #| try:
  #|   m_queue_server.start()
  #| except Exception as e:
  #|   print "Error: {0}".format(e)
  #| finally:
  #|   m_queue_server.shutdown()

  #-------------------------------------------------------------------------------
  # QueueThread: Start polling queue and write the tokens once received
  #              This tread runs forever until QueueThread.done is set
  m_queuethread = QueueThread(opts_h['dir'])
  m_queuethread.start()
  #-------------------------------------------------------------------------------

  m_threads = []
  m_semaphore = threading.BoundedSemaphore(10) # Max number of threads to be run

  # || NON_THREAD|| subprocess.call('vim -N -u NONE -Resnc "pyfile $KP_VIM_HOME/python_lib/vim/ctags/__main__.py" +"qa!" {infiles}'.format(infiles=' '.join(files)), shell=True) 

  # || SINGLE_THREAD|| m_thread = CtagsTread(m_semaphore, files)
  # || SINGLE_THREAD|| m_thread.start()
  # || SINGLE_THREAD|| m_threads.append(m_thread)

  print "parsing total {0} files...".format(len(files))

  # Note: Generate tags for typedef first to collect all the userdefined datattypes.
  #       This would fix the error due to parser don't recognize the type for later use
  os.system('vim -N -u NONE -Resn +"pyfile $KP_VIM_HOME/python_lib/vim/ctags/main_search_typedef_tags_mp.py" +"qa!" {infiles}'.format(infiles=' '.join(files)))
  # || DEBUG || os.system('vim -N -u NONE -Resn +"redir! >> /dev/stdout" +"pyfile $KP_VIM_HOME/python_lib/vim/ctags/main_search_typedef_tags_mp.py" +"redir END" +"qa!" {infiles}'.format(infiles=' '.join(files)))

  for fnames in split_array(files, 50): # maximum number of files processed in single thread
    m_thread = CtagsTread(m_semaphore, fnames)
    m_thread.start()
    m_threads.append(m_thread)

  # Wait for threads to be completed
  for t in m_threads:
    t.join()
    # || INCOMPLETE TAGS RESULT IN TAG FILE || done = t.event.wait(timeout=60.0)
    # || INCOMPLETE TAGS RESULT IN TAG FILE || if not done :
    # || INCOMPLETE TAGS RESULT IN TAG FILE ||   print "Error: While processing files {file} !! Thread is still running...".format(file=t.infiles)

  # || DEBUG || raw_input("Press any key to kill server".center(50, "-"))

  print "Results are generated in {dir}".format(dir=opts_h['dir'])
  QueueThread.done = 1
  m_queue_server.shutdown()











