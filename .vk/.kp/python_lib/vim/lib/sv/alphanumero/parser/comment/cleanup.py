#!/usr/bin/env python

from sv.alphanumero.parser.comment.Combinators import *

if __name__ == "__main__":
  m_logger = Logger()
  m_logger.debug_mode(0)

  m_lexer = Lexer()
  m_lexer.next_token()

  m_combinators = []

  while 1:
    
    m_comments = Comments(m_lexer=m_lexer)
    if m_comments(): # Note: Must use m_comments._parse with m_comments()
      m_comments.highlight('DiffAdd')

      if not m_comments._parse():
        continue
    else:
      m_comments = None

    m_typedef = Typedef(m_lexer=m_lexer)
    if m_typedef(m_comments):
      m_typedef.highlight('DiffAdd')
      m_combinators.append(m_typedef)
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

    m_intf = Interface(m_lexer=m_lexer)
    if m_intf(m_comments):
      m_intf.highlight('DiffAdd')
      m_combinators.append(m_intf)
      m_combinators.extend(m_intf.m_intfvars)
      continue

    # m_comments() has already advanced lexer so don't advance it
    if not m_comments:
      if not m_lexer.next_token(): break
    #m_lexer.highlight_token()

  m_combinators.reverse()
  for m_combinator in m_combinators:
    m_combinator.set_comment()

  # FIXED: this is required to avoid error while running the script again second time
  del m_lexer


