#!/usr/bin/env python

import vim
import re
from sv.base.parser import Combinators
from sv.base.Singleton import Logger
from sv.base.lexer.Lexer import Lexer

def fset_highlight (self, group_name, **kwargs):
  """def: fset_highlight"""
  if self.m_comments:
    self.m_comments.highlight(group_name, matchidx=1)

  super(self.__class__, self).highlight(group_name, matchidx=2)

def fset_call (self, m_comments):
  """def: fset_call"""

  self.m_comments = m_comments

  #-------------------------------------------------------------------------------
  # Issue: ClassVars returns success for below line
  #        `protected virtual interface abc_if.abc_driver m_vif;`
  #        where abc_driver is detected as class datatype so `abc_driver m_vif` is detected as class variables
  # Workaround: Store previous token and it will be checked in the ClassVars to check if end of previous token
  #             is in the same line as the ClassVars start token. If so don't add comment. Since the comment
  #             will be added everytime the script is executed
  self.m_prev_token = self.m_lexer.m_prev_token
  #-------------------------------------------------------------------------------

  return self._parse ()

def fset_str (self):
  """def: fset_str"""
  ret = ''
  if self.m_comments:
    ret += str(self.m_comments)
  ret += '\n'
  ret += super(self.__class__, self).__str__()
  return ret

#-------------------------------------------------------------------------------
# Comments
#-------------------------------------------------------------------------------
class Comments(Combinators.Comments):
  """class: Comments"""

  delimiter_vimre = r'\v^\s*\w+\zs\s*(:|:-|-)\s*'
  var_name_vimre = r'\v^\s*\w+(\s*\[.{-}\])*(\s+\w+)?(\s*\[.{-}\])*\zs\s*(:|:-|-)'

  property_re = re.compile(r'^\s*(?:variable|port|typedef|signal)(?:\s+name)?\s*[-:]', re.IGNORECASE)
  method_re = re.compile(r'^\s*(?:method|function|task)(?:\s+name)?\s*[-:]', re.IGNORECASE)
  arg_re = re.compile(r'^\s*(?:arguments?)\s*[-:]', re.IGNORECASE)
  param_re = re.compile(r'^\s*(?:parameters?)\s*[-:]', re.IGNORECASE)
  desc_optional_re = re.compile(r'^\s*(?:description\s*[-:])?', re.IGNORECASE) # comments with optional description tag
  others_re = re.compile(r'^\s*(?:\w+\s*[-:])', re.IGNORECASE) # For comments with optional description tag, this tag will be used to check if it's description.. example `// todo: ` shouldn't be a description
  todo_re = re.compile(r'^\s*(?:todo\s*[-:])', re.IGNORECASE) # For comments with optional description tag, this tag will be used to check if it's description.. example `// todo: ` shouldn't be a description
  desc_re = re.compile(r'^\s*(?:description\s*)[-:]', re.IGNORECASE) # comments with mandatary description tag
  rt_re = re.compile(r'^\s*(return)(\s+type)?\s*[-:]', re.IGNORECASE)
  dt_re = re.compile(r'^\s*(\w+\s*(?:\[.*?\])*)\s*', re.IGNORECASE)
  cls_re = re.compile(r'^\s*(?:class)(?:\s+name)?\s*[-:]', re.IGNORECASE)
  cls_parent_re = re.compile(r'^\s*(?:parent)\s*[-:]', re.IGNORECASE)
  interface_re = re.compile(r'^\s*(?:interface)(?:\s+name)?\s*[-:]', re.IGNORECASE)

  def __init__(self, **kwargs):
    super(Comments, self).__init__(**kwargs)
    # database keys:
    #    parent
    #    class
    #    interface
    #    description
    #    ret_type
    #    method
    #    others
    #    arguments
    #    parameters
    self.database = {}

  def _parse_cls_parent (self, lines):
    """def: _parse_cls_parent"""
    while lines:
      line = lines[0]

      # Skip the comment boundaries
      if Comments.comment_boundary_re.search(line):
        del lines[0]
        continue

      m = Comments.cls_parent_re.search(line)
      if m:
        indentlevel = m.end()
        indent = ' ' * indentlevel
        del lines[0]

        line = Comments.cls_parent_re.sub('', line)
        tmparr = vim.eval('split({str!r}, \'{ptrn}\')'.format(str=line.strip(), ptrn=Comments.delimiter_vimre))
        if len(tmparr) > 1:
          clsname, description = tmparr
          description = description.strip()
        else:
          clsname, description = line, ""
        clsname = clsname.strip()

        while lines:
          line = lines[0]
          if line.startswith(indent):
            del lines[0]
            description += '\n{0}'.format(line.strip())
          else:
            break
        self.database['parent'] = {'name': clsname, 'description': description}
        return 1
      else:
        return 0

  def _parse_cls (self, lines):
    """def: _parse_cls"""
    while lines:
      line = lines[0]

      # Skip the comment boundaries
      if Comments.comment_boundary_re.search(line):
        del lines[0]
        continue

      m = Comments.cls_re.search(line)
      if m:
        indentlevel = m.end()
        indent = ' ' * indentlevel
        del lines[0]

        line = Comments.cls_re.sub('', line)
        tmparr = vim.eval('split({str!r}, \'{ptrn}\')'.format(str=line.strip(), ptrn=Comments.delimiter_vimre))
        if len(tmparr) > 1:
          clsname, description = tmparr
          description = description.strip()
        else:
          clsname, description = line, ""
        clsname = clsname.strip()

        while lines:
          line = lines[0]
          if line.startswith(indent):
            del lines[0]
            description += '\n{0}'.format(line.strip())
          else:
            break
        self.database['class'] = {'name': clsname, 'description': description}
        return 1
      else:
        return 0
    return 0

  def _parse_desc (self, lines):
    """def: _parse_desc"""
    while lines:
      line = lines[0]

      # Skip the comment boundaries
      if Comments.comment_boundary_re.search(line):
        del lines[0]
        continue

      # If description tag `// description: ` is found this is a start of description.. Move all previous text into others key
      if Comments.desc_re.search(line):
        if self.database.get('description', None):
          if not self.database.get('others', None):
            self.database['others'] = ''
          self.database['others'] += '\n{0}'.format(self.database['description'])
          self.database['description'] = ''
      else:
        if Comments.others_re.search(line): return 0

      # Check for unformated description only if there was no previously description defined
      if Comments.desc_re.search(line) or not self.database.get('description', None) or self.database['description'] == '':
        m = Comments.desc_optional_re.search(line)
        if m:
          indentlevel = m.end()
          indent = ' ' * indentlevel
          del lines[0]

          description = Comments.desc_re.sub('', line)
          description = description.strip()

          while lines:
            line = lines[0]
            if Comments.desc_re.search(line):
              break
            elif line.startswith(indent):
              del lines[0]
              description += '\n{0}'.format(line.strip())
            else:
              break
          self.database['description'] = description
          return 1
      return 0
    return 0

  def _parse_ret_type (self, lines):
    """def: _parse_ret_type"""
    while lines:
      line = lines[0]
      #line = comment_start_re.sub('', line)

      # Skip the comment boundaries
      if Comments.comment_boundary_re.search(line):
        del lines[0]
        continue

      m = Comments.rt_re.search(line)
      if m:
        indentlevel = m.end()
        indent = ' ' * indentlevel
        del lines[0]

        line = Comments.rt_re.sub('', line)
        dt_m = Comments.dt_re.search(line)
        dt = None
        description = ""
        if dt_m:
          dt = dt_m.group(0)
          description = Comments.dt_re.sub('', line)
          dt = dt.strip()
          description = description.strip()
          if description.startswith('-'):
            description = description[1:]
            description = description.strip()

        while lines:
          line = lines[0]
          if line.startswith(indent):
            del lines[0]
            description += '\n{0}'.format(line.strip())
          else:
            break
        self.database['ret_type'] = {'ret_type': dt, 'description': description}
        return 1
      else:
        return 0
    return 0

  def _parse_args_params (self, lines, paramargs):
    """def: _parse_args_params
       @paramargs : paramters or arguments
    """
    if paramargs == 'parameters':
      paramargs_re = Comments.param_re
    else:
      paramargs_re = Comments.arg_re

    while lines:
      line = lines[0]
      #line = comment_start_re.sub('', line)

      # Skip the comment boundaries
      if Comments.comment_boundary_re.search(line):
        del lines[0]
        continue

      m = paramargs_re.search(line)
      if m:
        self.database[paramargs] = []

        indentlevel = m.end()
        indent = ' ' * indentlevel
        del lines[0]

        line = paramargs_re.sub('', line)
        tmparr = vim.eval('split({str!r}, \'{ptrn}\')'.format(str=line.strip(), ptrn=Comments.var_name_vimre))
        if len(tmparr) > 1:
          argname, description = tmparr
          description = description.strip()
        else:
          argname, description = line, ""
        argname = argname.strip()

        tmpptrn = r'\v\[.{-}\]'
        argname = vim.eval('substitute({0!r}, \'{1}\', "", "g")'.format(argname, tmpptrn))

        tmpptrn = r'\v^\s*\w+\s+\ze\w+'
        argname = vim.eval('substitute({0!r}, \'{1}\', "", "g")'.format(argname, tmpptrn))

        tmpptrn = r'\v(^\s+|\s+$)'
        argname = vim.eval('substitute({0!r}, \'{1}\', "", "g")'.format(argname, tmpptrn))

        self.database[paramargs].append({'name': argname, 'description': description})
        while lines:
          line = lines[0]
          if line.startswith(indent):
            del lines[0]

            tmparr = vim.eval('split({str!r}, \'{ptrn}\')'.format(str=line.strip(), ptrn=Comments.var_name_vimre))
            if len(tmparr) > 1:
              argname, description = tmparr
              description = description.strip()
            else:
              # || TBD: Currently only single line description is allowed || description += '\n{0}'.format(line.strip())
              argname, description = line, ""

            argname = argname.strip()

            tmpptrn = r'\v\[.{-}\]'
            argname = vim.eval('substitute({0!r}, \'{1}\', "", "g")'.format(argname, tmpptrn))

            tmpptrn = r'\v^\s*\w+\s+\ze\w+'
            argname = vim.eval('substitute({0!r}, \'{1}\', "", "g")'.format(argname, tmpptrn))

            tmpptrn = r'\v(^\s+|\s+$)'
            argname = vim.eval('substitute({0!r}, \'{1}\', "", "g")'.format(argname, tmpptrn))

            self.database[paramargs].append({'name': argname, 'description': description})
          else:
            break
        return 1
      else:
        return 0
    return 0

  def _parsemethod (self, lines):
    """def: _parsemethod"""
    while lines:
      line = lines[0]

      # Skip the comment boundaries
      if Comments.comment_boundary_re.search(line):
        del lines[0]
        continue

      m = Comments.method_re.search(line)
      if m:
        indentlevel = m.end()
        indent = ' ' * indentlevel
        del lines[0]

        line = Comments.method_re.sub('', line)
        tmparr = vim.eval('split({str!r}, \'{ptrn}\')'.format(str=line.strip(), ptrn=Comments.delimiter_vimre))
        if len(tmparr) > 1:
          methodname, description = tmparr
          description = description.strip()
        else:
          methodname, description = line, ""
        methodname = methodname.strip()

        while lines:
          line = lines[0]
          if line.startswith(indent):
            del lines[0]
            description += '\n{0}'.format(line.strip())
          else:
            break
        self.database['method'] = {'name': methodname, 'description': description}
        return 1
      else:
        return 0
    return 0

  def _parse_property (self, lines):
    """def: _parse_property"""
    while lines:
      line = lines[0]

      # Skip the comment boundaries
      if Comments.comment_boundary_re.search(line):
        del lines[0]
        continue

      m = Comments.property_re.search(line)
      if m:
        indentlevel = m.end()
        indent = ' ' * indentlevel
        del lines[0]

        line = Comments.property_re.sub('', line)
        tmparr = vim.eval('split({str!r}, \'{ptrn}\')'.format(str=line.strip(), ptrn=Comments.delimiter_vimre))
        if len(tmparr) > 1:
          property_name, description = tmparr
          description = description.strip()
        else:
          property_name, description = line, ""
        property_name = property_name.strip()

        while lines:
          line = lines[0]
          if line.startswith(indent):
            del lines[0]
            description += '\n{0}'.format(line.strip())
          else:
            break
        self.database['property'] = {'name': property_name, 'description': description}
        return 1
      else:
        return 0
    return 0

  def _parse_interface (self, lines):
    """def: _parse_interface"""
    while lines:
      line = lines[0]

      # Skip the comment boundaries
      if Comments.comment_boundary_re.search(line):
        del lines[0]
        continue

      m = Comments.interface_re.search(line)
      if m:
        indentlevel = m.end()
        indent = ' ' * indentlevel
        del lines[0]

        line = Comments.interface_re.sub('', line)
        tmparr = vim.eval('split({str!r}, \'{ptrn}\')'.format(str=line.strip(), ptrn=Comments.delimiter_vimre))
        if len(tmparr) > 1:
          interface_name, description = tmparr
          description = description.strip()
        else:
          interface_name, description = line, ""
        interface_name = interface_name.strip()

        while lines:
          line = lines[0]
          if line.startswith(indent):
            del lines[0]
            description += '\n{0}'.format(line.strip())
          else:
            break
        self.database['interface'] = {'name': interface_name, 'description': description}
        return 1
      else:
        return 0
    return 0


  def _parse_others (self, lines):
    """def: _parse_others"""
    description = ""
    ret = 0
    if lines:
      line = lines[0]
      del lines[0]

      # Skip the comment boundaries
      if Comments.comment_boundary_re.search(line): return 1

      m = Comments.todo_re.search(line) # if found any tag: example `// todo: `
      if m:
        # Note; This is a flag indicating the comment is todo comment so don't delete this
        self.database['todo_comment'] = 1
        return 1

      m = Comments.others_re.search(line) # if found any tag: example `// acidks: `
      if m:
        indentlevel = m.end()
        indent = ' ' * indentlevel
        text = line

        while lines:
          line = lines[0]
          if line.startswith(indent):
            del lines[0]
            text += '\n{0}'.format(line)
          else:
            break
        if not self.database.get('others', None) :
          self.database['others'] = '{text}'.format(text=text)
        else:
          self.database['others'] += '\n{text}'.format(text=text)
      else:
        if not self.database.get('others', None) :
          self.database['others'] = line
        else:
          self.database['others'] += '\n{0}'.format(line)

      return 1

    return 0

  def _parse (self):
    """def: _parse"""
    if not (self.start and self.end): return 0

    lines = vim.eval('getline({sln}, {eln})'.format(sln=self.start[0], eln=self.end[0]))

    # Don't return multiple line comments if comments is not at the start of line. example `int abc; // comment`
    if len(lines) == 1:
      if not Comments.comment_start_re.search(lines[0]) and not Comments.blk_comment_start_re.search(lines[0]): return 0
    else:
      if self.ctype == 'block':
        if not Comments.blk_comment_start_re.search(lines[0]): return 0
      else:
        if not Comments.comment_start_re.search(lines[0]): lines = lines[1:]
      # if not Comments.comment_start_re.search(lines[0]): lines = lines[1:]
        
    lines = map(lambda x: Comments.comment_start_re.sub('', x), lines)


    #Class.m_logger.set('OLD: %s' % str(lines))
    while lines:
      if self._parse_cls(lines): continue
      if self._parse_cls_parent(lines): continue
      if self._parsemethod(lines): continue
      if self._parse_property(lines): continue
      if self._parse_interface(lines): continue
      if self._parse_args_params(lines, 'arguments'): continue
      if self._parse_args_params(lines, 'parameters'): continue
      if self._parse_ret_type(lines): continue
      if self._parse_desc(lines): continue
      if self._parse_others(lines): continue
      break
    #Class.m_logger.set('OLD: %s' % str(self.database))
    return 1

  def __str__ (self):
    """def: __str__"""
    ret = super(Comments, self).__str__()
    ret += '\n{0}'.format(str(self.database))
    return ret

  # || def __call__ (self):
  # ||   """def: __call__"""
  # ||   super(Comments, self).__call__()
  # ||   return self._parse()


#-------------------------------------------------------------------------------
# CombinatorsMetaClass: Metaclass for Comments Combinators
#-------------------------------------------------------------------------------
class CombinatorsMetaClass(type):
  """class: CombinatorsMetaClass"""

  def __init__(cls, name, parents, dict):
    """def: __init__"""

    super(CombinatorsMetaClass, cls).__init__(name, parents, dict)

    # create class methods dynamically
    setattr(cls, 'highlight', fset_highlight)
    setattr(cls, '__call__', fset_call)
    setattr(cls, '__str__', fset_str)

  def __call__(cls, *args, **kwargs):
    """def: __call__"""

    cls_inst = super(CombinatorsMetaClass, cls).__call__(*args, **kwargs)
    cls_inst.m_comments = None

    return cls_inst

# TODO: Refer ClassFunction and update Covergroup
class Covergroup(Combinators.Covergroup):
  """class: Covergroup"""

  __metaclass__ = CombinatorsMetaClass

  def _parse (self):
    """def: _parse"""

    if self._parse_header():
      # Skip until end of task
      while not self.is_kw('endgroup'):
        if not self.m_lexer.next_token() : return 0
      return 1

    return 0

    


#-------------------------------------------------------------------------------
# Interface
#-------------------------------------------------------------------------------
class Interface(Combinators.Interface):
  """class: Interface"""

  __metaclass__ = CombinatorsMetaClass

  def __init__(self, **kwargs):
    super(Interface, self).__init__(**kwargs)
    self.m_intfvars = []

  def _parse (self):
    """def: _parse
       Overrite function from base Interface to parse only header instead of complete Interface
    """
    if self._parse_header():
      while not self.is_kw('endinterface'):
        m_comments = Comments(m_lexer=self.m_lexer)
        if not m_comments():
          m_comments = None

        # Skip functions: Note here use of Combinators.ClassFunction
        m_fun = Combinators.ClassFunction(m_lexer=self.m_lexer)
        if m_fun():
          m_fun.highlight('DiffAdd')
          continue

        # Skip tasks: Note here use of Combinators.ClassTask
        m_task = Combinators.ClassTask(m_lexer=self.m_lexer)
        if m_task():
          m_task.highlight('DiffAdd')
          continue

        # Skip property: Note here use of Combinators.ClassTask
        m_property = Combinators.Property(m_lexer=self.m_lexer)
        if m_property():
          m_property.highlight('DiffAdd')
          continue

        # Parse signals
        m_intfvar = ClassVars(headername='Signal  ', m_lexer=self.m_lexer) # TBD: Extra two spaces are to align the `Signal` header with `Variable` header
        if m_intfvar(m_comments):
          #self.m_intfvars.append(m_intfvar) # TODO: Uncomment if need to set comments for interface variables. self.m_intfvars is processed in cleanup.py
          continue

        # m_comments() has already advanced lexer so don't advance it
        if not m_comments:
          if not self.m_lexer.next_token(): break

      return 1
    return 0

  def _get_new_database (self, old_database):
    """def: _get_new_database"""
    database = {}
    database['interface'] = {'name': self.name, 'description': old_database.get('class', {}).get('description', '')}

    database['description'] = old_database.get('description', '')
    database['others'] = old_database.get('others', '')
    return database

  def set_comment (self):
    """def: set_comment"""
    self._set_new_comment()

  def _set_new_comment (self):
    """def: _set_new_comment"""
    if self.m_comments:
      old_database = self.m_comments.database
    else:
      old_database = {}
    new_database = self._get_new_database(old_database)

    Logger().append('OLD: %s' % str(old_database))
    Logger().append('NEW: %s' % str(new_database))

    text = ''

    intf = new_database['interface']
    name = intf['name']
    desc = ''
    if intf['description'] != '':
      desc = '- {0}'.format(intf['description'])
      desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))

    text += 'Interface      : {name} {desc}\n'.format(name=intf['name'], desc=desc)

    desc = new_database['description']
    desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))
    text += 'Description    : {desc}'.format(desc=desc)

    indent = ' ' * int(vim.eval('indent(nextnonblank({0}))'.format(self.start[0])))

    lines = text.split('\n')
    lines = map(lambda x: '{0}// {1}'.format(indent, x), lines)
    header = '{0}//-------------------------------------------------------------------------------'.format(indent)

    lines = [header] + lines + [header]

    #-------------------------------------------------------------------------------
    # Unknow parsing
    unknown = new_database.get('others', None)
    if unknown:
      unknown = unknown.replace('\n', '\n{indent}'.format(indent=' ' * 17))
      unknownstr = '__TBD__   : {desc}'.format(desc=unknown)
      unknownlines = unknownstr.split('\n')
      unknownlines = map(lambda x: '{0}// {1}'.format(indent, x), unknownlines)
      unknownlines = [header] + unknownlines + [header]
      lines = unknownlines + lines
    #-------------------------------------------------------------------------------

    #Class.m_logger.set('%s' % '\n'.join(lines))

    b = vim.current.buffer

    if self.m_comments:
      # Don't delete todo comment
      if old_database.get('todo_comment', None):
        b.append([''] + lines, self.start[0] - 1)
      else:
        b[self.m_comments.start[0] - 1:self.m_comments.end[0]] = lines
    else:
      b.append(lines, self.start[0] - 1)


#-------------------------------------------------------------------------------
# Class
#-------------------------------------------------------------------------------
class Class(Combinators.Class):
  """class: Class"""

  __metaclass__ = CombinatorsMetaClass

  def _parse (self):
    """def: _parse
       Overrite function from base class to parse only header instead of complete class
    """
    if self._parse_header():
      return 1
    return 0

  def _get_new_database (self, old_database):
    """def: _get_new_database"""
    database = {}
    database['class'] = {'name': self.name, 'description': old_database.get('class', {}).get('description', '')}
    database['parent'] = {'name': self.extends, 'description': old_database.get('class', {}).get('description', '')}

    if self.m_fclsparams:
      database['parameters'] = []
      for m_arg in self.m_fclsparams.m_parameters:
        description = next((p['description'] for p in old_database.get('parameters', []) if p['name'] == m_arg.name), '')
        database['parameters'].append({'name': m_arg.str(), 'description': description})

    database['description'] = old_database.get('description', '')
    database['others'] = old_database.get('others', '')
    return database

  def set_comment (self):
    """def: set_comment"""
    self._set_new_comment()

  def _set_new_comment (self):
    """def: _set_new_comment"""
    if self.m_comments:
      old_database = self.m_comments.database
    else:
      old_database = {}
    new_database = self._get_new_database(old_database)

    # || DEBUG ||  Class.m_logger.set('OLD: %s' % str(old_database))
    # || DEBUG ||  Class.m_logger.append('NEW: %s' % str(new_database))

    text = ''

    cls = new_database['class']
    name = cls['name']
    desc = ''
    if cls['description'] != '':
      desc = '- {0}'.format(cls['description'])
      desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))

    text += 'Class          : {name} {desc}\n'.format(name=cls['name'], desc=desc)

    parent = new_database['parent']
    name = parent['name']
    desc = ''
    if parent['description'] != '':
      desc = '- {0}'.format(parent['description'])
      desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))

    text += 'Parent         : {name} {desc}\n'.format(name=parent['name'], desc=desc)

    if new_database.get('parameters', None):
      parameters = new_database['parameters']
      start = 1
      for parameter in parameters:
        name = parameter['name']
        desc = ''
        if parameter['description'] != '':
          desc = '- {0}'.format(parameter['description'])
          desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))

        if start == 1:
          start = 0
          text += 'Parameters     : {name} {desc}\n'.format(name=parameter['name'], desc=desc)
        else:
          text += '                 {name} {desc}\n'.format(name=parameter['name'], desc=desc)

    desc = new_database['description']
    desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))
    text += 'Description    : {desc}'.format(desc=desc)

    indent = ' ' * int(vim.eval('indent(nextnonblank({0}))'.format(self.start[0])))

    lines = text.split('\n')
    lines = map(lambda x: '{0}// {1}'.format(indent, x), lines)
    header = '{0}//-------------------------------------------------------------------------------'.format(indent)

    lines = [header] + lines + [header]

    #-------------------------------------------------------------------------------
    # Unknow parsing
    unknown = new_database.get('others', None)
    if unknown:
      unknown = unknown.replace('\n', '\n{indent}'.format(indent=' ' * 17))
      unknownstr = '__TBD__   : {desc}'.format(desc=unknown)
      unknownlines = unknownstr.split('\n')
      unknownlines = map(lambda x: '{0}// {1}'.format(indent, x), unknownlines)
      unknownlines = [header] + unknownlines + [header]
      lines = unknownlines + lines
    #-------------------------------------------------------------------------------

    #Class.m_logger.set('%s' % '\n'.join(lines))

    b = vim.current.buffer

    if self.m_comments:
      #b[self.m_comments.start[0] - 1:self.m_comments.end[0]] = lines
      # Don't delete todo comment
      if old_database.get('todo_comment', None):
        b.append([''] + lines, self.start[0] - 1)
      else:
        b[self.m_comments.start[0] - 1:self.m_comments.end[0]] = lines
    else:
      b.append(lines, self.start[0] - 1)


#-------------------------------------------------------------------------------
# ClassFunction
#-------------------------------------------------------------------------------
class ClassFunction(Combinators.ClassFunction):
  """class: ClassFunction
     Overrite function from base class to parse only header instead of complete function
  """

  __metaclass__ = CombinatorsMetaClass

  def get_default_desc (self):
    """def: get_default_desc"""
    text = ''
    if self.name == 'new':
      text = 'Constructor for creating this class object'
    elif self.name == 'build_phase':
      text = 'This phase creates all the required objects'
    elif self.name == 'connect_phase':
      text = 'This phase establish the connections between different component'
    elif self.name == 'do_unpack':
      text = 'Method for unpacking the transaction'
    elif self.name == 'do_pack':
      text = 'Method for packing the transaction'
    elif self.name == 'do_print':
      text = 'Method for printing the transaction'
    elif self.name == 'do_compare':
      text = 'Method for comparing the transactions'
    elif self.name == 'post_randomize':
      text = 'This function is called after randomization'
    elif self.name == 'pre_randomize':
      text = 'This function is called before randomization'

    return text

  def _parse (self):
    """def: _parse"""

    if self._parse_header():
      # Skip until end of function
      if not self.pure:
        while not self.is_kw('endfunction'):
          if not self.m_lexer.next_token() : return 0
      return 1

    return 0

  def _get_new_database (self, old_database):
    """def: _get_new_database"""
    database = {}
    database['function'] = {'name': self.name, 'description': old_database.get('method', {}).get('description', '')}
    rt = old_database.get('ret_type', None)
    rtdesc = ''
    if rt:
      rtdesc = rt.get('description', '')
    if self.m_return_type :
      database['ret_type'] = {'ret_type': self.m_return_type.str(), 'description': rtdesc}

    if self.m_arguments:
      database['arguments'] = []
      for m_arg in self.m_arguments.m_arguments:
        description = next((p['description'] for p in old_database.get('arguments', []) if p['name'] == m_arg.name), '')
        database['arguments'].append({'name': m_arg.str(), 'description': description})
    database['description'] = old_database.get('description', '')
    return database

  def set_comment (self):
    """def: set_comment"""
    self._set_new_comment()

  def _set_new_comment (self):
    """def: _set_new_comment"""
    if self.m_comments:
      old_database = self.m_comments.database
    else:
      old_database = {}
    new_database = self._get_new_database(old_database)

    Class.m_logger.set('OLD: %s' % str(old_database))
    Class.m_logger.append('NEW: %s' % str(new_database))

    text = ''

    method = new_database['function']
    name = method['name']
    desc = ''
    if method['description'] != '':
      desc = '- {0}'.format(method['description'])
      desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))

    text += 'Function       : {name} {desc}\n'.format(name=method['name'], desc=desc)

    rt = new_database.get('ret_type', None)
    if rt:
      name = rt['ret_type']
      desc = ''
      if rt['description'] != '':
        desc = '- {0}'.format(rt['description'])
        desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))

      text += 'Return Type    : {name} {desc}\n'.format(name=name, desc=desc)

    if new_database.get('arguments', None):
      arguments = new_database['arguments']
      start = 1
      for arg in arguments:
        name = arg['name']
        desc = ''
        if arg['description'] != '':
          desc = '- {0}'.format(arg['description'])
          desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))

        if start == 1:
          start = 0
          text += 'Arguments      : {name} {desc}\n'.format(name=arg['name'], desc=desc)
        else:
          text += '                 {name} {desc}\n'.format(name=arg['name'], desc=desc)

    desc = new_database['description']
    if desc == '':
      desc = self.get_default_desc()
    desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))
    text += 'Description    : {desc}'.format(desc=desc)

    indent = ' ' * int(vim.eval('indent(nextnonblank({0}))'.format(self.start[0])))

    lines = text.split('\n')
    lines = map(lambda x: '{0}// {1}'.format(indent, x), lines)
    header = '{0}//-------------------------------------------------------------------------------'.format(indent)
    lines = [header] + lines + [header]

    #-------------------------------------------------------------------------------
    # Unknow parsing
    unknown = new_database.get('others', None)
    if unknown:
      unknown = unknown.replace('\n', '\n{indent}'.format(indent=' ' * 17))
      unknownstr = '__TBD__   : {desc}'.format(desc=unknown)
      unknownlines = unknownstr.split('\n')
      unknownlines = map(lambda x: '{0}// {1}'.format(indent, x), unknownlines)
      unknownlines = [header] + unknownlines + [header]
      lines = unknownlines + lines
    #-------------------------------------------------------------------------------

    b = vim.current.buffer

    if self.m_comments:
      # b[self.m_comments.start[0] - 1:self.m_comments.end[0]] = lines
      # Don't delete todo comment
      if old_database.get('todo_comment', None):
        b.append([''] + lines, self.start[0] - 1)
      else:
        b[self.m_comments.start[0] - 1:self.m_comments.end[0]] = lines
    else:
      b.append(lines, self.start[0] - 1)

#-------------------------------------------------------------------------------
# ClassTask
#-------------------------------------------------------------------------------
class ClassTask(Combinators.ClassTask):
  """class: ClassTask
     Overrite function from base class to parse only header instead of complete task
  """

  __metaclass__ = CombinatorsMetaClass

  def _parse (self):
    """def: _parse"""
    if self._parse_header():

      if not self.pure:
        # Skip until end of task
        while not self.is_kw('endtask'):
          if not self.m_lexer.next_token() : return 0
      return 1
    return 0

  def get_default_desc (self):
    """def: get_default_desc"""
    text = ''
    if self.name == 'run_phase':
      text = 'In this phase the TB execution starts'
    elif self.name == 'body':
      text = 'This task executes the sequence to generate transaction'
    elif self.name == 'pre_body':
      text = 'This task is call before body task is started'
    elif self.name == 'post_body':
      text = 'This task is call after body task is completed'

    return text

  def _get_new_database (self, old_database):
    """def: _get_new_database"""
    database = {}
    database['method'] = {'name': self.name, 'description': old_database.get('method', {}).get('description', '')}
    rt = old_database.get('ret_type', None)
    if rt:
      rtdesc = rt.get('description', '')
      if self.m_return_type :
        database['ret_type'] = {'ret_type': self.m_return_type.str(), 'description': rtdesc}

    if self.m_arguments:
      database['arguments'] = []
      for m_arg in self.m_arguments.m_arguments:
        description = next((p['description'] for p in old_database.get('arguments', []) if p['name'] == m_arg.name), '')
        database['arguments'].append({'name': m_arg.str(), 'description': description})
    database['description'] = old_database.get('description', '')
    return database

  def set_comment (self):
    """def: set_comment"""
    self._set_new_comment()

  def _set_new_comment (self):
    """def: _set_new_comment"""
    if self.m_comments:
      old_database = self.m_comments.database
    else:
      old_database = {}

    new_database = self._get_new_database(old_database)

    # || DEBUG || Class.m_logger.set('OLD: %s' % str(old_database))
    # || DEBUG || Class.m_logger.append('NEW: %s' % str(new_database))

    text = ''

    method = new_database['method']
    name = method['name']
    desc = ''
    if method['description'] != '':
      desc = '- {0}'.format(method['description'])
      desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))

    text += 'Task           : {name} {desc}\n'.format(name=method['name'], desc=desc)

    rt = new_database.get('ret_type', None)
    if rt:
      name = rt['ret_type']
      desc = ''
      if rt['description'] != '':
        desc = '- {0}'.format(rt['description'])
        desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))

      text += 'Return Type    : {name} {desc}\n'.format(name=name, desc=desc)

    if new_database['arguments']:
      arguments = new_database['arguments']
      start = 1
      for arg in arguments:
        name = arg['name']
        desc = ''
        if arg['description'] != '':
          desc = '- {0}'.format(arg['description'])
          desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))

        if start == 1:
          start = 0
          text += 'Arguments      : {name} {desc}\n'.format(name=arg['name'], desc=desc)
        else:
          text += '                 {name} {desc}\n'.format(name=arg['name'], desc=desc)

    desc = new_database['description']
    if desc == '':
      desc = self.get_default_desc()
    desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))
    text += 'Description    : {desc}'.format(desc=desc)
    lines = text.split('\n')
    indent = ' ' * int(vim.eval('indent(nextnonblank({0}))'.format(self.start[0])))
    lines = map(lambda x: '{0}// {1}'.format(indent, x), lines)
    header = '{0}//-------------------------------------------------------------------------------'.format(indent)
    lines = [header] + lines + [header]

    #-------------------------------------------------------------------------------
    # Unknow parsing
    unknown = new_database.get('others', None)
    if unknown:
      unknown = unknown.replace('\n', '\n{indent}'.format(indent=' ' * 17))
      unknownstr = '__TBD__   : {desc}'.format(desc=unknown)
      unknownlines = unknownstr.split('\n')
      unknownlines = map(lambda x: '{0}// {1}'.format(indent, x), unknownlines)
      unknownlines = [header] + unknownlines + [header]
      lines = unknownlines + lines
    #-------------------------------------------------------------------------------

    b = vim.current.buffer

    if self.m_comments:
      #b[self.m_comments.start[0] - 1:self.m_comments.end[0]] = lines
      # Don't delete todo comment
      if old_database.get('todo_comment', None):
        b.append([''] + lines, self.start[0] - 1)
      else:
        b[self.m_comments.start[0] - 1:self.m_comments.end[0]] = lines
    else:
      b.append(lines, self.start[0] - 1)

#-------------------------------------------------------------------------------
# ClassVars
#-------------------------------------------------------------------------------
class ClassVars(Combinators.ClassVars):
  """class: ClassVars"""

  __metaclass__ = CombinatorsMetaClass

  def __init__(self, **kwargs):
    super(ClassVars, self).__init__(**kwargs)
    self.headername = kwargs.get('headername', 'Variable')

  port_re = re.compile(r'^uvm_\w+(?:port|export|imp|fifo)')

  def get_default_desc (self):
    """def: get_default_desc"""
    text = ''

    # TODO: To be implemented default description for uvm ports

    return text

  def _get_new_database (self, old_database):
    """def: _get_new_database"""
    database = {}
    database['variables'] = []

    for m_var in self.m_variables:
      database['variables'].append({
        'name': m_var.name,
        'datatype' : m_var.datatype,
        'description': old_database.get('property', {}).get('description', '')})

    database['description'] = old_database.get('description', '')
    database['others'] = old_database.get('others', '')
    return database

  def set_comment (self):
    """def: set_comment"""
    # Fix: Check if previous token was not in the same line
    #      otherwise the new comment will be added everytime script is executed
    #      without replacing the old comment
    if not self.m_prev_token or self.m_prev_token.end[0] != self.start[0]:
      self._set_new_comment()

  def _set_new_comment (self):
    """def: _set_new_comment"""
    if self.m_comments:
      old_database = self.m_comments.database
    else:
      old_database = {}

    new_database = self._get_new_database(old_database)

    # TODO: for `typedef class xyz_scoreboard;` ClassVars is executed. Workaround is done to skip setting unwanted comments
    if not new_database: return 0
      
    # || DEBUG || Class.m_logger.set('OLD: %s' % str(old_database))
    # || DEBUG || Class.m_logger.append('NEW: %s' % str(new_database))

    text = ''

    # || UNCOMMENT IF NEEDED || if new_database['variables']:
    # || UNCOMMENT IF NEEDED ||   dt = new_database['variables'][0]['datatype']
    # || UNCOMMENT IF NEEDED ||   names = map(lambda x: x['name'], new_database['variables'])
    # || UNCOMMENT IF NEEDED ||   desc = new_database['variables'][0].get('description', '')
    # || UNCOMMENT IF NEEDED ||   if desc != '':
    # || UNCOMMENT IF NEEDED ||     desc = '- {0}'.format(desc)
    # || UNCOMMENT IF NEEDED ||   if ClassVars.port_re.search(dt):
    # || UNCOMMENT IF NEEDED ||     text += 'Port           : {name} {desc}\n'.format(name=', '.join(names), desc=desc)
    # || UNCOMMENT IF NEEDED ||   else:
    # || UNCOMMENT IF NEEDED ||     text += '{varheader}       : {name} {desc}\n'.format(varheader=self.headername, name=', '.join(names), desc=desc)

    desc = new_database['description']
    if desc == '':
      desc = self.get_default_desc()
    # || UNCOMMENT IF NEEDED || desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))
    text += '{desc}'.format(desc=desc)
    # || UNCOMMENT IF NEEDED || text += 'Description    : {desc}'.format(desc=desc)


    indent = ' ' * int(vim.eval('indent(nextnonblank({0}))'.format(self.start[0])))

    #-------------------------------------------------------------------------------
    # Don't add `// ` if no text or no description available
    lines = []
    if text != '':
      lines = text.split('\n')
      lines = map(lambda x: '{0}// {1}'.format(indent, x), lines)
    #-------------------------------------------------------------------------------

    header = '{0}//-------------------------------------------------------------------------------'.format(indent)
    #lines = [header] + lines + [header]

    #-------------------------------------------------------------------------------
    # Unknow parsing
    unknown = new_database.get('others', None)
    if unknown:
      unknown = unknown.replace('\n', '\n{indent}'.format(indent=' ' * 17))
      unknownstr = '__TBD__   : {desc}'.format(desc=unknown)
      unknownlines = unknownstr.split('\n')
      unknownlines = map(lambda x: '{0}// {1}'.format(indent, x), unknownlines)
      unknownlines = [header] + unknownlines + [header]
      lines = unknownlines + lines
    #-------------------------------------------------------------------------------

    b = vim.current.buffer

    #-------------------------------------------------------------------------------
    # Blank line between two variable declaration
    if self.m_comments:
      if b[self.m_comments.start[0] - 2].strip() != '':
        lines = [''] + lines
    else:
      if b[self.start[0] - 2].strip() != '':
        lines = [''] + lines
    #-------------------------------------------------------------------------------

    if self.m_comments:
      #b[self.m_comments.start[0] - 1:self.m_comments.end[0]] = lines
      # Don't delete todo comment
      if old_database.get('todo_comment', None):
        b.append([''] + lines, self.start[0] - 1)
      else:
        b[self.m_comments.start[0] - 1:self.m_comments.end[0]] = lines
    else:
      b.append(lines, self.start[0] - 1)

#-------------------------------------------------------------------------------
# Typedef
#-------------------------------------------------------------------------------
class Typedef(Combinators.Typedef):
  """class: Typedef"""

  __metaclass__ = CombinatorsMetaClass

  def get_default_desc (self):
    """def: get_default_desc"""
    text = ''

    # TODO: To be implemented default description for enum typedef ????

    return text

  def _get_new_database (self, old_database):
    """def: _get_new_database"""
    database = {}
    # TODO: Variables can be declared all together.. example `bit a,b,c;`
    #       But typedef is declared one at a time.. But still below code works so i haven't
    #       changed the below logic which is copied from variables
    database['typedefs'] = []
    for m_var in self.m_variables:
      database['typedefs'].append({
        'name': m_var.name,
        'datatype' : m_var.datatype,
        'description': old_database.get('property', {}).get('description', '')})

    database['description'] = old_database.get('description', '')
    database['others'] = old_database.get('others', '')
    return database

  def set_comment (self):
    """def: set_comment"""
    self._set_new_comment()

  def _set_new_comment (self):
    """def: _set_new_comment"""
    if self.m_comments:
      old_database = self.m_comments.database
    else:
      old_database = {}

    new_database = self._get_new_database(old_database)

    # || DEBUG || Class.m_logger.set('OLD: %s' % str(old_database))
    # || DEBUG || Class.m_logger.append('NEW: %s' % str(new_database))

    text = ''

    # || UNCOMMENT IF NEEDED || if new_database['typedefs']:
    # || UNCOMMENT IF NEEDED ||   dt = new_database['typedefs'][0]['datatype']
    # || UNCOMMENT IF NEEDED ||   names = map(lambda x: x['name'], new_database['typedefs'])
    # || UNCOMMENT IF NEEDED ||   desc = new_database['typedefs'][0].get('description', '')
    # || UNCOMMENT IF NEEDED ||   if desc != '':
    # || UNCOMMENT IF NEEDED ||     desc = '- {0}'.format(desc)
    # || UNCOMMENT IF NEEDED ||   text += 'Typedef        : {name} {desc}\n'.format(name=', '.join(names), desc=desc)

    desc = new_database['description']
    if desc == '':
      desc = self.get_default_desc()
    # || UNCOMMENT IF NEEDED || desc = desc.replace('\n', '\n{indent}'.format(indent=' ' * 17))
    text += '{desc}'.format(desc=desc)
    # || UNCOMMENT IF NEEDED || text += 'Description    : {desc}'.format(desc=desc)

    indent = ' ' * int(vim.eval('indent(nextnonblank({0}))'.format(self.start[0])))

    #-------------------------------------------------------------------------------
    # Don't add `// ` if no text or no description available
    lines = []
    if text != '': 
      lines = text.split('\n')
      lines = map(lambda x: '{0}// {1}'.format(indent, x), lines)
    #-------------------------------------------------------------------------------

    header = '{0}//-------------------------------------------------------------------------------'.format(indent)
    #lines = [header] + lines + [header]

    #-------------------------------------------------------------------------------
    # Unknow parsing
    unknown = new_database.get('others', None)
    if unknown:
      unknown = unknown.replace('\n', '\n{indent}'.format(indent=' ' * 17))
      unknownstr = '__TBD__   : {desc}'.format(desc=unknown)
      unknownlines = unknownstr.split('\n')
      unknownlines = map(lambda x: '{0}// {1}'.format(indent, x), unknownlines)
      unknownlines = [header] + unknownlines + [header]
      lines = unknownlines + lines
    #-------------------------------------------------------------------------------

    b = vim.current.buffer

    #-------------------------------------------------------------------------------
    # Blank line between two variable declaration
    if self.m_comments:
      if b[self.m_comments.start[0] - 2].strip() != '':
        lines = [''] + lines
    else:
      if b[self.start[0] - 2].strip() != '':
        lines = [''] + lines
    #-------------------------------------------------------------------------------

    if self.m_comments:
      #b[self.m_comments.start[0] - 1:self.m_comments.end[0]] = lines
      # Don't delete todo comment
      if old_database.get('todo_comment', None):
        b.append([''] + lines, self.start[0] - 1)
      else:
        b[self.m_comments.start[0] - 1:self.m_comments.end[0]] = lines
    else:
      b.append(lines, self.start[0] - 1)


################################################################################
# MAIN
################################################################################
if __name__ == "__main__":
  m_logger = Logger()
  m_logger.debug_mode(1)

  m_lexer = Lexer()
  m_lexer.next_token()

  m_combinators = []

  while 1:

    m_comments = Comments(m_lexer=m_lexer)
    if not m_comments(): # Note: Must use m_comments._parse with m_comments()
      m_comments = None
    else:
      if not m_comments._parse():
        continue

    m_class = Class(m_lexer=m_lexer)
    if m_class(m_comments):
      m_class.highlight('DiffAdd')
      m_combinators.append(m_class)
      continue

    m_cov = Covergroup(m_lexer=m_lexer) # TODO: Add comments for Covergroup???
    if m_cov._parse():
      continue

    m_fun = ClassFunction(m_lexer=m_lexer)
    if m_fun(m_comments):
      m_fun.highlight('DiffAdd')
      m_combinators.append(m_fun)
      continue

    m_task = ClassTask(m_lexer=m_lexer)
    if m_task(m_comments):
      m_task.highlight('DiffAdd')
      m_combinators.append(m_task)
      continue

    m_clsvars = ClassVars(m_lexer=m_lexer)
    if m_clsvars(m_comments):
      m_clsvars.highlight('DiffAdd')
      m_combinators.append(m_clsvars)
      continue

    m_typedef = Typedef(m_lexer=m_lexer)
    if m_typedef(m_comments):
      m_typedef.highlight('DiffAdd')
      continue

    if not m_lexer.next_token(): break
    #m_lexer.highlight_token()

  m_combinators.reverse()
  for m_combinator in m_combinators:
    m_combinator.set_comment()













