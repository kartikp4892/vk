#!/usr/bin/env python

import sys
import os
import re
import imp

THREAD_CONNECTED = 0
THREAD_CLIENT = None

DYNAMIC_USERDTS = set()

CLASSLOCAL_USERDT = {}
USER_DATATYPES = set()
USERDT_LOADED = {} # {file: 0/1}
INTERFACE_DATATYPES = set()

# This function only used for multithreading
def connect_threadmanager ():
  global THREAD_CONNECTED
  global THREAD_CLIENT
  
  # This contains userdefined datatypes dynamically added while creating svtags
  # used by /home/kartik/.vk/.kp/python_lib/vim/ctags/ThreadManager/manager.py 
  # This shared array is converted into AutoProxy object by the SyncManager 
  from ThreadManager import manager

  THREAD_CLIENT = manager.get_default_client()
  THREAD_CLIENT.connect()
  THREAD_CONNECTED = 1
  
#-------------------------------------------------------------------------------
# Get list of svtags directories
from Utils.env_vars import env2path
svtagsdirs = env2path('SVTAGSPATH')
#-------------------------------------------------------------------------------

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

def update_userdt ():
  """def: update_userdt
    return array user datatypes
  """

  for svtagsdir in svtagsdirs:
    dtfile = '{0}/userdt/_main.py'.format(svtagsdir)
    if USERDT_LOADED.get(dtfile, 0): continue

    try:
      USERDT = import_(dtfile)
      USER_DATATYPES.update(USERDT.CLASS_USERDT)
      USER_DATATYPES.update(USERDT.TYPEDEF_USERDT)
      INTERFACE_DATATYPES.update(USERDT.INTERFACE_USERDT)
      CLASSLOCAL_USERDT.update(USERDT.CLASSLOCAL_USERDT)
      USERDT_LOADED[dtfile] = 1
    except Exception as e:
      pass

  # || || datatypes = set()
  # || || for svtagsdir in svtagsdirs:
  # || ||   dtfile = '{0}/userdatatypes'.format(svtagsdir)
  # || ||   try:
  # || ||     with open(dtfile, 'r') as fh:
  # || ||       tags = fh.read().splitlines()
  # || ||   except Exception as e:
  # || ||     tags = []

  # || ||   datatypes.update(tags)

  # || || return datatypes

    # || SLOW || tags = vim.eval('taglist(\'.\')')
    # || SLOW || tags = (tag for tag in tags if tag['kind'] == 'class' or tag['kind'] == 'typedef')
    # || SLOW || if not tags: vim.error ('No user datatype found!!! Is tag file set properly??')
    # || SLOW || return tags

class Tags(object):
  """class: Tags"""

  def __init__(self):
    pass

  @classmethod
  def is_interface_datatype (cls, text):
    """def: is_interface_datatype"""
    # Update userdata if new user data tag files are generated
    update_userdt()

    dt = next((tag for tag in INTERFACE_DATATYPES if tag == text), None)
    if not dt: return 0
    return 1
      
    
  @classmethod
  def is_user_datatype (cls, text, clsname=""): # Optional clsname is provided to aditional search for datatypes local to the class
    """def: is_user_datatype"""

    # Update userdata if new user data tag files are generated
    update_userdt()

    # Note: If different scripts are running, userdefined datatypes will be loaded dynamically
    #       through the SyncManager server client communication. Otherwise it will be loaded in
    #       DYNAMIC_USERDTS 
    if THREAD_CONNECTED:
      user_datatypes = cls.user_datatypes.union(THREAD_CLIENT.userdts._getvalue())
      #user_datatypes = list(set(THREAD_CLIENT.userdts._getvalue() + cls.user_datatypes))
    else:
      user_datatypes = USER_DATATYPES
      #user_datatypes = list(set(DYNAMIC_USERDTS + cls.user_datatypes))

    dt = next((tag for tag in user_datatypes if tag == text), None)

    # If datatype not found look into the class local datatypes
    if not dt and clsname: # TODO: Add '*' in classname to make it flexible for datatype lookup to look into all classes???
      if clsname == '*': # Wildcard
        for key, val_l in CLASSLOCAL_USERDT.iteritems():
          dt = next((tag for tag in val_l if tag == text), None)
          if dt: break
      else:
        if clsname in CLASSLOCAL_USERDT:
          dt = next((tag for tag in CLASSLOCAL_USERDT[clsname] if tag == text), None)

    if dt == None: return 0

    return 1
    
  # || def is_user_datatype (self, text):
  # ||   """def: is_user_datatype"""

  # ||   # User datatype is either class name or typedef
  # ||   try:
  # ||     tags = vim.eval('taglist(\'\\v<{text}>\')'.format(text=text))
  # ||   except Exception as e:
  # ||     print 'taglist(\'\\v<{text}>\')'.format(text=text)
  # ||     vim.error(e)
  # ||     return 0

  # ||   tags = next((tag for tag in tags if tag['kind'] == 'class' or tag['kind'] == 'typedef'), None)

  # ||   if tags == None: return 0
  # ||     
  # ||   return 1

if __name__ == '__main__':
  m_tags = Tags()
  print m_tags.is_user_datatype('uvm_component')














