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

from multiprocessing import Queue, Process

m_queue = Queue()

class TheadTagsAgent(object):
  """class: tags_agent"""

  def __init__(self, **kwargs):
    self.m_bufdo_search = BUFDOSEARCH.BufdoSearch(**kwargs)

  def run (self):
    """def: run"""
    for m_token in self.m_bufdo_search.datatypes():
      m_queue.put(m_token)
    
class ProcessTags(object):
  """class: ProcessTags"""

  done = 0

  def __init__(self, **kwargs):
    self.outdir = kwargs['outdir']

    tagfile = '{0}/tags'.format(self.outdir)
    userdt_file = '{0}/userdt/_our_userdt.py'.format(self.outdir)
    class_tree_tags_file = '{0}/_class_tree.py'.format(self.outdir)

    self.m_tagspool = TAGSPOOL.TagsPool(ctags_file=tagfile, userdt_file=userdt_file, class_tree_tags_file=class_tree_tags_file)

  def run (self):
    """def: run"""
    while not ProcessTags.done:
      if not m_queue.empty():
        m_token = m_queue.get()
        self.m_tagspool.write(m_token)
      else:
        pass

class TagsAgent(object):
  """class: TagsAgent"""

  def __init__(self, **kwargs):
    self.files = kwargs['files']
    self.outdir = kwargs['outdir']

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

  def run (self):
    """def: run"""
    m_threads = []
    for fnames in self.split_array(self.files, 2): # maximum number of threads
      m_tagsagent = TheadTagsAgent(files=fnames)
      m_thread = Process(target=m_tagsagent.run)
      m_thread.start()
      m_threads.append(m_thread)

    # Wait for threads to be completed
    print "Running {0} threads.. Waiting for complete".format(len(m_threads))
    for t in m_threads:
      t.join()

    m_process_tags = ProcessTags(outdir=self.outdir)
    m_process_queue = Process(target=m_process_tags.run)
    m_process_queue.start()

    print "Waiting for processing all token"
    # Wait until queue is empty
    while not m_queue.empty():
      pass

    print "All tokens are processed"
    ProcessTags.done = 1
    m_process_queue.join()
    

if __name__ == '__main__':
  m_tags_agent = TagsAgent(files=['temp.sv'], outdir='{0}/svtags'.format(os.environ['HOME']))

  m_tags_agent.run()







