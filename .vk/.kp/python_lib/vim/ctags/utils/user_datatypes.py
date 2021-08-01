#!/usr/bin/env python

from logger import Logger
import imp
try:
  import vim
  vim_detected = 1
except Exception as e:
  import os
  vim_detected = 0

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

class UserDT(object):
  """class: UserDT
     This class writes all the user defined types to a file. 
     This file will be processed by combinator to identify types
  """

  def __init__(self, outdir):
    self.outdir = outdir
    self.libdir = "{0}/_libs".format(outdir)
    self.userdt_tokens = {} # fname => {'class': [], 'typedef': [], 'interface': [], 'fclsparam': {}} # 'fclsparam': {clsname: [param_type1, param_type2]}

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
    if m_token and 'UserDT' in m_token._users:
      tagfname = self.get_out_fname (m_token.filename)
      if tagfname not in self.userdt_tokens:
        self.userdt_tokens[tagfname] = {'class': [], 'typedef': [], 'interface': [], 'module': [], 'fclsparam': {}}
        
      if m_token.kind == 'fclsparam':
        if m_token.kwargs['clsname'] not in self.userdt_tokens[tagfname]['fclsparam']:
          self.userdt_tokens[tagfname]['fclsparam'][m_token.kwargs['clsname']] = [] # FIXME: Use set() instead of list???

        self.userdt_tokens[tagfname]['fclsparam'][m_token.kwargs['clsname']].append(m_token.name)
      else:
        self.userdt_tokens[tagfname][m_token.kind].append(m_token.name)
        
      #self.m_logger.write(m_token.name)
      return 1
    return 0

  def merge_libs (self):
    """def: merge_libs"""
    userdt_tokens = {'class': set(), 'typedef': set(), 'interface': set(), 'module': set(), 'fclsparam': {}}

    if not os.path.isdir(self.libdir): return 0
      
    for filename in os.listdir(self.libdir):
      if filename.endswith('.py'):
        filename = "{0}/{1}".format(self.libdir, filename)
        MODULE = import_(filename)
        userdt_tokens['class'].update(MODULE.CLASS_USERDT)
        userdt_tokens['typedef'].update(MODULE.TYPEDEF_USERDT)
        userdt_tokens['fclsparam'].update(MODULE.CLASSLOCAL_USERDT)
        userdt_tokens['interface'].update(MODULE.INTERFACE_USERDT)
    
    m_logger = Logger('{0}/{1}'.format(self.outdir, '_main.py'))
    
    text = '#!/usr/bin/env python\n\n'

    text += 'CLASS_USERDT = {0!r}\n'.format(userdt_tokens['class'])
    text += 'TYPEDEF_USERDT = {0!r}\n'.format(userdt_tokens['typedef'])
    text += 'CLASSLOCAL_USERDT = {0!r}\n'.format(userdt_tokens['fclsparam'])
    text += 'INTERFACE_USERDT = {0!r}\n'.format(userdt_tokens['interface'])

    m_logger.write(text)
    #m_logger.logfh.close()

    del m_logger

  def write_logger (self):
    """def: write_logger"""
    for tagfname in self.userdt_tokens.iterkeys():
      m_logger = Logger(tagfname)
      text = '#!/usr/bin/env python\n\n'

      text += 'CLASS_USERDT = {0!r}\n'.format(self.userdt_tokens[tagfname]['class'])
      text += 'TYPEDEF_USERDT = {0!r}\n'.format(self.userdt_tokens[tagfname]['typedef'])
      text += 'CLASSLOCAL_USERDT = {0!r}\n'.format(self.userdt_tokens[tagfname]['fclsparam'])
      text += 'INTERFACE_USERDT = {0!r}\n'.format(self.userdt_tokens[tagfname]['interface'])
      m_logger.write(text)

      # m_logger.logfh.close()

      del m_logger

    del self.userdt_tokens # deallocate memory

  def done (self):
    """def: done"""
    self.write_logger()
    #self.merge_libs()



  

