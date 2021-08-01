#!/usr/bin/env python

import vim
import imp
import os

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

combinator_path = '{kp_vim_home}/python_lib/vim/lib/sv/base/parser/Combinators.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
combinator = import_(combinator_path)

class Class(combinator.Class):
  """class: Class"""

  def __init__(self, **kwargs):
    """Constructor: """
    super(Class, self).__init__(**kwargs)

    
def get_class_syntax (clsname):
  """def: get_class_syntax
     This function returns the valid syntax of class type (ex: For parameterized class sytax will be `clsname #(.P1(...), .P2(...))`)
     1. Go to tag position
     2. Parse class header
     3. Return class syntax
     Returns class name provided in the argument if fails
  """

  # TODO?? : Need to optimize the way tag is checked?? First it checks tag exists or not then it will jump to the tag
  #          This required two times applying the tag command
  tagslist = vim.eval('taglist("^{clsname}$")'.format(clsname=clsname))
  if len(tagslist) == 0:
    return clsname

  first_tag = tagslist[0]
  vim.command('silent stag {0}'.format(clsname))
  m_class = Class()
  if not m_class._parse_header(): 
    vim.command('q')
    return clsname

  #vim.command('silent bd')
  vim.command('q')

  if not m_class.m_fclsparams:
    return clsname
  else:
    cls_syntax = '{clsname} #({param})'.format(clsname=clsname, param=', '.join(map(lambda x: '.{0}({1})'.format(x.name, vim.eval('common#mov_thru_user_mark#get_template("a", "{0}")'.format(x.name))), m_class.m_fclsparams.m_parameters)))
    return cls_syntax


if __name__ == "__main__":
  syntax = get_class_syntax('uvm_driver')
  print syntax 



