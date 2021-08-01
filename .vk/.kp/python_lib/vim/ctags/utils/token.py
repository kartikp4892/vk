#!/usr/bin/env python

class Token(object):
  """class: Token"""

  def __init__(self, _users, name, cmd, kind, filename, **kwargs):
    """Constructor:
       _users: List having valid users that will be using the token
               Example: _users=('Ctags','UserDT') 
    """
    self._users = _users
    self.name = name
    self.cmd = cmd
    self.kind = kind
    self.filename = filename
    self.kwargs = kwargs

  def __str__ (self):
    """def: __str__"""

    other = ''
    for key,val in self.kwargs.items():
      if val:
        other += '{key}:{val}\t'.format(key=key,val=val)

    str = "{name}\t{file}\t{cmd}\t{kind}\t{other}".format(name=self.name, file=self.filename, cmd=self.cmd, kind=self.kind, other=other)
    return str


