#!/usr/bin/env python

try:
  import vim
  vim_detected = 1
except Exception:
  vim_detected = 0

import sys

def inpos (pos, start, end):
  """def: inpos
     Check if a position is inside a range of positions
     pos - (line, col) 
     start - (line, col)
     end - (line, col)
  """
  # Linenumber is within range
  if (start[0] < pos[0] < end[0]): return 1
    
  # Any one or all of the line numbers same
  if (start[0] <= pos[0] <= end[0]):
    # Column is within range
    if (start[1] <= pos[1] <= end[1]): return 1
  
  return 0
    
# start = [ln, cn] position
# end = [ln, cn] position
# Get the visual selected text in current buffer
def getvisualtxt (): # VI Only
  start = map(int, vim.eval('''getpos("'<")''')[1:3])
  end = map(int, vim.eval('''getpos("'>")''')[1:3])
  txt = getstr(vim.current.buffer, start, end)
  return txt

# buffer - python vim buffer
# start = [ln, cn] position
# end = [ln, cn] position
def getstr (buffer, start, end):
  """def: getstr"""
  sln, scn = start
  eln, ecn = end

  lines = buffer[sln - 1: eln]
  lines[-1] = lines[-1][:ecn]
  lines[0] = lines[0][scn - 1:]

  return '\n'.join(lines)

# Select the range in visual mode (VIM Only)
def selectrange (start, end):
  if vim_detected == 0: return 0
    
  startpos = (start[0],start[1] - 1)
  endpos = (end[0],end[1] - 1)

  vim.current.window.cursor = startpos
  vim.command('normal v')
  vim.current.window.cursor = endpos

# start = [ln, cn] position
# end = [ln, cn] position
def replace_str (start, end, text):
  if vim_detected == 0: return 0 # TODO: Do we need to implement this function for shell also???
    
  sln, scn = start
  eln, ecn = end

  import inspect
  frame,filename,line_number,function_name,lines,index = inspect.stack()[1]

  if sln > eln:
    sys.stderr.write('%s[%s]: In function %s\n' % (filename, line_number, function_name))
    sys.stderr.write('Invalid range {0} to {1}!!!'.format(str(start), str(end)))
    return 0

  if sln == eln:
    if scn > ecn:
      sys.stderr.write('%s[%s]: In function %s\n' % (filename, line_number, function_name))
      sys.stderr.write('Invalid range {0} to {1}!!!'.format(str(start), str(end)))
      return 0

  #lines = vim.eval('getline({0},{1})'.format(sln,eln))
  lines = vim.current.buffer[sln - 1: eln]

  newlines = text.split('\n')
  newlines[0] = lines[0][:scn - 1] + newlines[0]
  newlines[-1] = newlines[-1] + lines[-1][ecn:]

  vim.current.buffer[sln - 1:eln] = newlines
  return 1

  #selectrange (start, end)
  #vim.command('normal d'.format(text=text))
  #vim.current.window.cursor = start
  #vim.command('let @" = {text!r}'.format(text=text))


if __name__ == '__main__':
  #print '<%s>' % getstr([57,24], [57,29])
  #print '<%s>' % getstr([1,1], [1,3])
  #print '<%s>' % getstr([1,1], [2,2])
  #selectrange ((1,2), (2,3))
  replace_str ((2,1), (1,2), '<replaced\ntext>')



  
