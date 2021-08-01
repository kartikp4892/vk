#!/usr/bin/env python

from logger import Logger
import os
import imp

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

class ClassTreeTags(object):
  """class: Ctags
     This class writes all sv class tree to a file. 
     This file will be used to list all the base classes to which the class should extend
  """

  def __init__(self, outdir):
    self.outdir = outdir
    self.libdir = "{0}/_libs".format(outdir)
    #self.directory = os.path.dirname(os.path.realpath(outfile))
    #self.m_logger = Logger(outfile)
    self.class_db = {} # filename => {class => parent_class}

  # Convert sv file name into py filename
  def get_out_fname (self, svfname):
    """def: get_out_fname"""
    fname = os.path.basename(svfname)
    fname = fname.rsplit('.', 1)[0]
    fname += '.py'

    fname = '{0}/{1}'.format(self.libdir, fname)

    return fname

  def write (self, m_token):
    """def: write"""
    # Userdatatype is either class or typedef
    # If userdefined type token
    if m_token and 'ClassTreeTags' in m_token._users:
      tagfname = self.get_out_fname (m_token.filename)

      if tagfname not in self.class_db :
        self.class_db [tagfname] = {}

      self.class_db [tagfname][m_token.name] = m_token.kwargs.get('extends', None)
      #self.m_logger.write(m_token.name)
      return 1
    return 0

  def generate_libs (self):
    """def: generate_libs"""
    #self.add_python_init_package()

    for tagfname in self.class_db.iterkeys():
      m_logger = Logger(tagfname)
      text = '#!/usr/bin/env python\n\n'

      text += 'CLASS_DB = {0!r}\n'.format(self.class_db [tagfname])
      m_logger.write(text)
      #m_logger.logfh.close()
      del m_logger

    del self.class_db # deallowcate memory once done

  def merge_libs (self):
    """def: merge_libs"""
    classdb = {}

    if not os.path.isdir(self.libdir): return 0

    for filename in os.listdir(self.libdir):
      if filename.endswith('.py'):
        filename = "{0}/{1}".format(self.libdir, filename)
        MODULE = import_(filename)
        classdb.update(MODULE.CLASS_DB)
    
    self.generate_classtree(classdb)
    
  # This function will return all the descendants 
  # of a class passed in the argument
  def get_descendants (_class, tree={}):
    if _class not in tree:
      return []

    if len(tree[_class]) == 0:
      return tree[_class]
    else:
      childs = [] + tree[_class]
      for _subcls in tree[_class]:
        childs.extend(get_descendants (_subcls, tree))
      return childs

  # ||def add_python_init_package (self):
  # ||  filename = "{0}/__init__.py".format(self.libdir)
  # ||  if not os.path.isfile(filename):
  # ||    m_init_logger = Logger(filename)
  # ||    m_init_logger.write('') # empty package file __init__.py

  def generate_classtree (self, class_db):
    tree = {} # {base_class => [child_class1, child_class2, ...]}
    for key, val in class_db.iteritems():
      if val:
        if val not in tree:
          tree[val] = []

        tree[val] = tree[val] + [key]

    text = """#!/usr/bin/env python

classbase = {clsbase!r}
classtree = {tree!r}

# This function will return all the descendants 
# of a class passed in the argument
def get_descendants (_class, tree=classtree):
  if _class not in tree:
    return []

  if len(tree[_class]) == 0:
    return tree[_class]
  else:
    childs = [] + tree[_class]
    for _subcls in tree[_class]:
      childs.extend(get_descendants (_subcls, tree))
    return childs

# This function will return True if keyword is class name
# classbase = (cls_name => base_cls_name)
def is_cls (kw, classbase=classbase):
  if kw not in classbase:
    return 0

  return 1

""".format(tree=tree, clsbase=class_db)

    m_logger = Logger('{0}/{1}'.format(self.outdir, '_main.py'))
    
    m_logger.write(text)

  def done (self):
    """def: done"""
    self.generate_libs()

    # self.merge_libs ()
    
  # def __del__ (self):
  #   """def: __del__"""
  #   #self.add_python_init_package()
  #   self.merge_libs ()

  #   #del self.m_logger



