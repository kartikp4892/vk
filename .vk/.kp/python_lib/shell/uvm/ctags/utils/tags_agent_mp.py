#!/usr/bin/env python

import os
import imp
def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

search_path = '{kp_vim_home}/python_lib/shell/uvm/ctags/utils/bufdo_search.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
BUFDOSEARCH = import_(search_path)

tagspool_path = '{kp_vim_home}/python_lib/vim/ctags/utils/tags_pool.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
TAGSPOOL = import_(tagspool_path)

tstamp_path = '{kp_vim_home}/python_lib/shell/uvm/ctags/utils/timestamp.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
TIMESTAMP = import_(tstamp_path)

import threading
import Queue

#m_queue = Queue.Queue()
#m_queue_lock = threading.Lock()

class TheadTagsAgent(threading.Thread):
  """class: tags_agent"""

  def __init__(self, **kwargs):
    threading.Thread.__init__(self)
    self.fun = kwargs['fun']

  def run (self):
    """def: run"""

    self.fun()

# ||class ThreadProcessQueue(threading.Thread):
# ||  """class: ThreadProcessQueue"""
# ||
# ||  done = 0
# ||
# ||  def __init__(self, **kwargs):
# ||    threading.Thread.__init__(self)
# ||    self.outdir = kwargs['outdir']
# ||
# ||    # Get new/modifiles files out of all files
# ||    mfiles = self.m_tstamp.getmfiles(kwargs['files'])
# ||
# ||    self.m_bufdo_search = BUFDOSEARCH.BufdoSearch(files=mfiles)
# ||    self.outdir = kwargs['outdir']
# ||
# ||    tagdir = '{0}/tags'.format(self.outdir)
# ||    userdt_dir = '{0}/userdt'.format(self.outdir)
# ||    clstree_dir = '{0}/clstree'.format(self.outdir)
# ||
# ||    self.m_tagspool = TAGSPOOL.TagsPool(files=mfiles, ctagsdir=tagdir, userdt_dir=userdt_dir, clstree_dir=clstree_dir)
# ||
# ||  def run (self):
# ||    """def: run"""
# ||    while not ThreadProcessQueue.done:
# ||      #m_queue_lock.acquire()
# ||      if not m_queue.empty():
# ||        m_token = m_queue.get()
# ||        #m_queue_lock.release()
# ||        self.m_tagspool.write(m_token)
# ||      else:
# ||        #m_queue_lock.release()
# ||        pass

class TagsAgent(object):
  """class: TagsAgent"""

  def __init__(self, **kwargs):
    self.m_tstamp = TIMESTAMP.Timestamp(**kwargs)

    # Get new/modifiles files out of all files
    mfiles = self.m_tstamp.getmfiles(kwargs['files'])

    self.files = mfiles
    self.outdir = kwargs['outdir']
    self.tagdir = '{0}/tags'.format(self.outdir)
    self.userdt_dir = '{0}/userdt'.format(self.outdir)
    self.clstree_dir = '{0}/clstree'.format(self.outdir)

    self.m_bufdo_searches = []

    for fnames in self.split_array(self.files, 2): # maximum number of threads
      m_bufdo_search = BUFDOSEARCH.BufdoSearch(files=fnames, outdir=kwargs['outdir'])
      self.m_bufdo_searches.append(m_bufdo_search)

  def split_array(self, alist, maxthreads=4): # n+1 thread will be created
    length = len(alist)
    maximum = int(length/maxthreads)

    idx = 0
    rlist = []
    while idx < length:
      if length < idx + maximum:
        rlist.append(alist[idx: length])
      else:
        rlist.append(alist[idx: idx + maximum])

      idx += maximum

    return rlist

  def run_datatypes (self):
    """def: run_datatypes"""
    print "Processing datatypes"
    m_threads = []
    for m_bufdo_search in self.m_bufdo_searches:
      m_thread = TheadTagsAgent(fun=m_bufdo_search.datatypes)
      m_thread.start()
      m_threads.append(m_thread)

    for m_thread in m_threads:
      m_thread.join()

    self.merge_userdt()

  def run_tags (self):
    """def: run_tags"""
    print "Processing tags"
    m_threads = []
    for m_bufdo_search in self.m_bufdo_searches:
      m_thread = TheadTagsAgent(fun=m_bufdo_search.tags)
      m_thread.start()
      m_threads.append(m_thread)

    for m_thread in m_threads:
      m_thread.join()
    
    self.merge_tags()

  def merge_userdt (self):
    """def: merge_userdt"""
    if len(self.files) != 0:
      # merge all processsed files
      m_tagspool = TAGSPOOL.TagsPool(files=[], ctagsdir=self.tagdir, userdt_dir=self.userdt_dir, clstree_dir=self.clstree_dir)
      m_tagspool.merge_userdt()
    
  def merge_tags (self):
    """def: merge_tags"""
    if len(self.files) != 0:
      # merge all processsed files
      m_tagspool = TAGSPOOL.TagsPool(files=[], ctagsdir=self.tagdir, userdt_dir=self.userdt_dir, clstree_dir=self.clstree_dir)
      m_tagspool.merge_tags()

    
  def run (self):
    """def: run"""

    # First time runs with datatype
    self.run_datatypes()

    # Second time runs with tags
    self.run_tags()

    # Set current timestamp info for future tags parsing
    self.m_tstamp.set()

    # ||m_process_queue = ThreadProcessQueue(outdir=self.outdir)
    # ||m_process_queue.start()

    print "Done processing all token"
    # Wait until queue is empty
    # while not m_queue.empty():
    #   pass

    # print "All tokens are processed"
    # ThreadProcessQueue.done = 1
    # m_process_queue.join()


if __name__ == '__main__':
  m_tags_agent = TagsAgent(files=['temp.sv'], outdir='{0}/svtags'.format(os.environ['HOME']))

  m_tags_agent.run()







