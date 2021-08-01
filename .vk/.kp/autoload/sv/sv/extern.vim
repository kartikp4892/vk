" ==============================================================================
" Class Class
" ==============================================================================
let s:class_cl = {'name': '', 'non_extern_methods_o': [], 'debug_o': ''}

" ------------------------------------------------------------------------------
" Function : add
" ------------------------------------------------------------------------------
function! s:class_cl.add(item) dict
  call add(self.non_extern_methods_o, a:item)
endfunction

"-------------------------------------------------------------------------------
" Function : print
"-------------------------------------------------------------------------------
function! s:class_cl.print() dict
  if (type(self.debug_o) == type(""))
    echoerr "debug_o not defined!!!"
    return
  endif

  call self.debug_o.debug_msg(repeat("=", 80))
  call self.debug_o.debug_msg("Class Name: " . self.name)

  for l:mothod_o in self.non_extern_methods_o
    call l:mothod_o.print()
  endfor
  call self.debug_o.debug_msg(repeat("=", 80))
endfunction

"-------------------------------------------------------------------------------
" Function : conv2extern
"-------------------------------------------------------------------------------
function! s:class_cl.conv2extern() dict

  for l:mothod_o in self.non_extern_methods_o
    call l:mothod_o.conv2extern(self.name)
  endfor
endfunction

"-------------------------------------------------------------------------------
" Function : update_extern
"-------------------------------------------------------------------------------
function! s:class_cl.update_extern() dict
  let l:offset = 0
  for l:mothod_o in self.non_extern_methods_o
    let l:mothod_o.extern_insert_point_str = self.extern_insert_point_str
    call l:mothod_o.update_lptr(l:offset)
    let l:offset += l:mothod_o.update_extern()
  endfor

  return l:offset
endfunction

"-------------------------------------------------------------------------------
" Function : update_lptr
"-------------------------------------------------------------------------------
function! s:class_cl.update_lptr(offset) dict
  for l:mothod_o in self.non_extern_methods_o
    call l:mothod_o.update_lptr(a:offset)
  endfor
endfunction

" ==============================================================================
" Class Methods
" ==============================================================================
let s:method_cl = {'type': '', 'comment': {'start': 0, 'end': 0}, 'decl': {'start': 0, 'end': 0, 'lines': []}, 'def': {'start': 0, 'end': 0, 'lines': []}, 'debug_o':0}

" ------------------------------------------------------------------------------
" Function : get_method_decl
" Declaration
" ------------------------------------------------------------------------------
function! s:method_cl.get_method_decl() dict
  let lines = getline(self.decl.start, self.decl.end)
  let self.decl.lines = lines
endfunction

" ------------------------------------------------------------------------------
" Function : get_method_def
" Definition
" ------------------------------------------------------------------------------
function! s:method_cl.get_method_def() dict
  let lines = getline(self.def.start, self.def.end)
  let self.def.lines = lines
endfunction

"-------------------------------------------------------------------------------
" Function : update_lptr
"-------------------------------------------------------------------------------
function! s:method_cl.update_lptr(offset) dict
  let self.comment.start += a:offset
  let self.comment.end += a:offset
  let self.decl.start += a:offset
  let self.decl.end += a:offset
  let self.def.start += a:offset
  let self.def.end += a:offset
endfunction

"-------------------------------------------------------------------------------
" Function : update_extern
"-------------------------------------------------------------------------------
function! s:method_cl.update_extern() dict
  exe 'silent' . self.def.start . ',' . self.def.end . 'delete'
  call append(self.def.start - 1, self.decl.lines)
  
  " Do Indentation Cleanup
  call sv#sv#indent_cleanup#cleanup_indent(self.decl.start, self.decl.end)

  let insertion_point = search(self.extern_insert_point_str, 'n')

  let lines = [""] + self.def.lines + [self.extern_insert_point_str]

  call append(insertion_point, lines)
  call sv#sv#indent_cleanup#cleanup_indent(insertion_point, insertion_point + len(lines))
  exe 'silent' . insertion_point . 'delete'

  let l:offset = (self.decl.end - self.decl.start) - (self.def.end - self.def.start)
  return l:offset

endfunction

"-------------------------------------------------------------------------------
" Function : set_comment
"-------------------------------------------------------------------------------
function! s:method_cl.set_comment(last_seen_comment) dict
  if (prevnonblank(self.def.start - 1) == a:last_seen_comment.end)
    let self.comment.start = a:last_seen_comment.start
    let self.comment.end = a:last_seen_comment.end
  else
    call self.debug_o.debug_msg("last comment start: " . a:last_seen_comment.start)
    call self.debug_o.debug_msg("last comment end: " . a:last_seen_comment.end)
    call self.debug_o.debug_msg("def start: " . self.def.start)
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : conv2extern
"-------------------------------------------------------------------------------
function! s:method_cl.conv2extern(class_name) dict
  if(len(self.def.lines) == 0)
    call self.get_method_def()
  endif

  if(len(self.decl.lines) == 0)
    call self.get_method_decl()
  endif

  let self.decl.lines[0] = substitute(self.decl.lines[0], '\v^(\s+)', '\1extern ', 'g')

  let def_lines_str = join(self.def.lines, "\n")

  if (self.type == 'function')
    if (def_lines_str =~ '\v<function\_s+new')
      let def_lines_str = substitute(def_lines_str,
                                   \ '\v(<function\_s+)(new)',
                                   \ '\1' . a:class_name . ' :: \2',
                                   \ 'g')
    else
      " \1 = function and spaces or newline;
      " \2 = return type and spaces or new line
      " \3 = function name
      let def_lines_str = substitute(def_lines_str,
                                   \ '\v%(%(<virtual|<static)\_s+)?(<function\_s+)(\w+\_s+)(\w+)',
                                   \ '\1\2' . a:class_name . ' :: \3',
                                   \ 'g')
    endif
    let self.def.lines = split(def_lines_str, "\n")
  elseif (self.type == 'task')
    " \1 = task and spaces or newline;
    " \2 = task name
    let def_lines_str = substitute(def_lines_str,
                                 \ '\v%(%(<virtual|<static)\_s+)?(<task\_s+)(\w+)',
                                 \ '\1' . a:class_name . ' :: \2',
                                 \ 'g')
    let self.def.lines = split(def_lines_str, "\n")
  else
    return 0
  endif

  let self.def.lines = getline(self.comment.start, self.comment.end) + self.def.lines

  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : print
"-------------------------------------------------------------------------------
function! s:method_cl.print() dict
  if (type(self.debug_o) == type(""))
    echoerr "debug_o not defined!!!"
    return
  endif

  call self.debug_o.debug_msg(repeat("-", 30) . 'Method Start' . repeat("-", 30))
  call self.debug_o.debug_msg("Method Type: " . self.type)
  call self.debug_o.debug_msg("Method decl start: " . self.decl.start)
  call self.debug_o.debug_msg("Method decl end: " . self.decl.end)
  call self.debug_o.debug_msg("Method def start: " . self.def.start)
  call self.debug_o.debug_msg("Method def end: " . self.def.end)
  call self.debug_o.debug_msg("Comment start: " . self.comment.start)
  call self.debug_o.debug_msg("Comment end: " . self.comment.end)

  call self.debug_o.debug_msg("decl:\n" . join(self.decl.lines, "\n") . "\n")
  call self.debug_o.debug_msg("def:\n" . join(self.def.lines, "\n") . "\n")

  call self.debug_o.debug_msg(repeat("-", 30) . 'Method End' . repeat("-", 30))

endfunction

" ==============================================================================
" Class Debug
" ==============================================================================
let s:debug_cl = {'debug_dir': $HOME, 'debug_file': '', 'debug': 0}
"-------------------------------------------------------------------------------
" Function : enable_debug
"-------------------------------------------------------------------------------
function! s:debug_cl.enable_debug(file) dict
  let self.debug = 1

  " Empty the debug file
  if (a:file != "")
    let self.debug_file = self.debug_dir . '/' . a:file
    exe 'redir! > ' . self.debug_file
    redir END
  else
    call self.debug_warning('Please provide valid filename')
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : disable_debug
"-------------------------------------------------------------------------------
function! s:debug_cl.disable_debug() dict
  let self.debug = 0
  let self.debug_file = ''
endfunction

"-------------------------------------------------------------------------------
" Function : debug_msg
"-------------------------------------------------------------------------------
function! s:debug_cl.debug_msg(msg) dict
  if (self.debug)
    if (self.debug_file != '')
      exe 'redir! >> ' . self.debug_file
      silent! echon a:msg . "\n"
      redir END
    endif
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : debug_warning
"-------------------------------------------------------------------------------
function! s:debug_cl.debug_warning(err_msg) dict
  echohl Error
  echomsg a:err_msg
  echohl None
endfunction

" ==============================================================================
" Class Keywords
" ==============================================================================
let s:keywords_cl = {'debug_o': "", 'extern_insert_point_str':0, 'last_seen_comment': {'start': 0, 'end': 0}, 'cline': 0, 'ckeyword': "", 'lptr': 0, 'cptr': -1, 'lastline': 0, 'classes_o': []}

"-------------------------------------------------------------------------------
" Function : add_class
"-------------------------------------------------------------------------------
function! s:keywords_cl.add_class(class_o)
  call add(self.classes_o, a:class_o)
endfunction

"-------------------------------------------------------------------------------
" Function : char
"-------------------------------------------------------------------------------
function! s:keywords_cl.char(offset) dict
  let idx = self.cptr + a:offset


  " return next line's first char
  if (idx >= strlen(self.cline))
    if (self.lptr >= self.lastline)
      " call self.debug_o.debug_warning("Lastline limit is reached!!!")
      return ""
    endif

    let lptr = self.lptr + 1
    while (lptr <= self.lastline) && (getline(lptr) =~ '^\s*$')
      let lptr += 1
    endwhile

    let line = getline(lptr)
    return line[a:offset - 1]

  " return previous line's last character
  elseif (idx < 0)
    if (self.lptr <= 1)
      " call self.debug_o.debug_warning("Lastline limit is reached!!!")
      return ""
    endif

    let lptr = self.lptr - 1
    while (lptr > 0) && (getline(lptr) =~ '^\s*$')
      let lptr -= 1
    endwhile

    let line = getline(lptr)
    return line[strlen(line) + a:offset]
  endif

  " return the offset character
  return self.cline[self.cptr + a:offset]
endfunction

"-------------------------------------------------------------------------------
" Function : move_lptr
"-------------------------------------------------------------------------------
function! s:keywords_cl.move_lptr(offset) dict
  if (a:offset > 0)
    let self.cptr = 0

    " Check if lastline is set properly
    if (self.lastline == 0)
      call self.debug_o.debug_warning('Lastline not set!!!')
      return 0
    endif

    while (self.lptr < self.lastline) && (getline(self.lptr + 1) =~ '^\s*$')
      let self.lptr += 1
    endwhile

    if (self.lptr < self.lastline)
      let self.lptr += 1
      let self.cline = getline(self.lptr)
      return 1
    else
      let self.lptr = self.lastline + 1
      let self.cline = ""
      return 0
    endif
  elseif (a:offset < 0)

    while (self.lptr > 1) && (getline(self.lptr - 1) =~ '^\s*$')
      let self.lptr -= 1
    endwhile

    if (self.lptr > 1)
      let self.lptr -= 1
      let self.cline = getline(self.lptr)
      let self.cptr = strlen(self.cline) - 1 " Fixme
      return 1
    else
      let self.lptr = 0
      let self.cptr = -1
      let self.cline = ""
      return 0
    endif
  endif

endfunction

"-------------------------------------------------------------------------------
" Function : move_cptr
" Recursive
"-------------------------------------------------------------------------------
function! s:keywords_cl.move_cptr(offset) dict
  let old_self = deepcopy(self)

"   if (a:offset > 0)
"   elseif (a:offset < 0)
"   endif

  if (a:offset > 0)
    let self.cptr += 1

    if (self.cptr >= strlen(self.cline))
      call self.move_lptr(1)
    endif
  elseif (a:offset < 0)
    let self.cptr -= 1

    if (self.cptr < 0)
      call self.move_lptr(-1)
    endif
  endif

  if (a:offset > 1)
    call self.move_cptr(a:offset - 1)
  endif

  if (a:offset < -1)
    call self.move_cptr(a:offset + 1)
  endif

  if (old_self.lptr == self.lptr)
    return 1
  else
    return 0
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : next
" Get next keyword and move the line and/or column pointer
"-------------------------------------------------------------------------------
function! s:keywords_cl.next_keyword() dict

  call self.debug_o.debug_msg("[next_keyword start]")
  call self.print()

  let next_keyword = ""

  let comment_ptrn = '\v^\/\*|^\*\/|^\/\/'
  if (strpart(self.cline, self.cptr, 2) =~ comment_ptrn)

    let next_keyword = strpart(self.cline, self.cptr, 2)
    call self.move_cptr(2)

  elseif (self.char(0) =~ '\v\s|\t')

    " call self.debug_o.debug_warning("if")
    while (self.char(0) =~ '\v\s|\t')
      let next_keyword .= self.char(0)
      if !self.move_cptr(1)
        break
      endif
    endwhile

  elseif (self.char(0) =~ '\w')

    while (self.char(0) =~ '\w')
      let next_keyword .= self.char(0)
      if !self.move_cptr(1)
        break
      endif
    endwhile

  else

    " call self.debug_o.debug_warning("else")
    let next_keyword .= self.char(0)
    call self.move_cptr(1)

  endif

  let self.ckeyword = next_keyword

  call self.print()
  call self.debug_o.debug_msg("[next_keyword end]")

  return next_keyword
endfunction

"-------------------------------------------------------------------------------
" Function : prev_keyword
" Get previous keyword and move the line and/or column pointer
"-------------------------------------------------------------------------------
function! s:keywords_cl.prev_keyword() dict

  call self.debug_o.debug_msg("[prev_keyword start]")

  for l:idx in range(2)
    call self.print()

    let comment_ptrn = '\v^\/\*|^\*\/|^\/\/'

    if (self.cptr == 0)
      let cline = getline(prevnonblank(self.lptr - 1))
      let cptr = strlen(cline)
    else
      let cline = self.cline
      let cptr = self.cptr
    endif
    call self.debug_o.debug_msg("PREV OUTSIDE " . strpart(cline, cptr - 2, 2) )

    if (strpart(cline, cptr - 2, 2) =~ comment_ptrn)

      let next_keyword = strpart(cline, cptr - 2, 2)

      call self.debug_o.debug_msg("PREV BEFORE ")
      call self.print()
      call self.move_cptr(-2)
      call self.debug_o.debug_msg("PREV AFTER ")
      call self.print()

      call self.debug_o.debug_msg("PREV INSIDE " . next_keyword)

    elseif (self.char(-1) =~ '\v\s|\t')

      while (self.char(-1) =~ '\v\s|\t')
        if !self.move_cptr(-1)
          break
        endif
      endwhile

    elseif (self.char(-1) =~ '\w')

      let cnt = 0
      while (self.char(-1) =~ '\w')
        if !self.move_cptr(-1) && cnt != 0
          call self.move_cptr(1)
          break
        endif
        let cnt += 1
      endwhile

    else

      call self.move_cptr(-1)

    endif
  endfor

  call self.print()
  call self.next_keyword()

  call self.debug_o.debug_msg("[prev_keyword end]")

  return self.ckeyword
endfunction

"-------------------------------------------------------------------------------
" Function : get_keyword
" Get keywords without moving the line and column pointers
"-------------------------------------------------------------------------------
function! s:keywords_cl.get_keyword(offset) dict
  " Save the current state of object before update
  let save_self = deepcopy(self)

  if (a:offset >= 0)
    let Fun_ptr = matchstr(string(self.next_keyword), '\d\+')
    let iteration = a:offset
  else
    let Fun_ptr = matchstr(string(self.prev_keyword), '\d\+')
    let iteration = -a:offset
  endif

  " Skip keywords until offset is reached
  for l:idx in range(iteration)
    call call(Fun_ptr, [], self)
  endfor

  let keyword = self.ckeyword

  let self.cline = save_self.cline
  let self.ckeyword = save_self.ckeyword
  let self.lptr = save_self.lptr
  let self.cptr = save_self.cptr

  return keyword
endfunction

"-------------------------------------------------------------------------------
" Function : print
"-------------------------------------------------------------------------------
function! s:keywords_cl.print() dict
  let str = ""
  let str .= "<lptr:>" . self.lptr
  let str .= " <cptr:>" . self.cptr
  let str .= " <keyword:>" . self.ckeyword
  let str .= " <char(0):>" . self.char(0)
  let str .= " <char(-1):>" . self.char(-1)
  let str .= " <char(-2):>" . self.char(-2)
  call self.debug_o.debug_msg(str)

endfunction

"-------------------------------------------------------------------------------
" Function : print_classes
"-------------------------------------------------------------------------------
function! s:keywords_cl.print_classes()
  for l:class_o in self.classes_o
    call l:class_o.print()
  endfor
endfunction

"-------------------------------------------------------------------------------
" Function : skip_double_quote
"-------------------------------------------------------------------------------
function! s:keywords_cl.skip_double_quote() dict
  if (self.ckeyword != '"')
    return 0
  endif

  call self.debug_o.debug_msg("[skip_double_quote start]: ")

  call self.next_keyword()
  while self.ckeyword != '"'
    call self.next_keyword()
  endwhile

  call self.debug_o.debug_msg("[skip_double_quote end]: ")

  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : skip_line_comment
"-------------------------------------------------------------------------------
function! s:keywords_cl.skip_line_comment() dict
  if (self.ckeyword != '//')
    return 0
  endif

"  " Note: pointer is incremented after assigning current keyword ckeyword
"  "       so here char(0) will point to the next character
"  if (self.char(0) != '/')
"    return 0
"  endif

  call self.debug_o.debug_msg("Line comment start: " . self.lptr)

  call self.prev_keyword()
  let self.last_seen_comment.start = self.lptr
  call self.next_keyword()

  while getline(self.lptr) =~ '\v^\s*\/\/'
    if !(self.move_lptr(1))
      break
    endif
  endwhile

  call self.prev_keyword()
  let self.last_seen_comment.end = self.lptr
  call self.next_keyword()

  call self.debug_o.debug_msg("Line comment end: " . self.lptr)

  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : skip_block_comment
"-------------------------------------------------------------------------------
function! s:keywords_cl.skip_block_comment() dict
  if (self.ckeyword != '/*')
    return 0
  endif

"   " Note: pointer is incremented after assigning current keyword ckeyword
"   "       so here char(0) will point to the next character
"   if (self.char(0) != '*')
"     return 0
"   endif

  call self.debug_o.debug_msg("Block comment start: " . self.lptr)

  call self.prev_keyword()
  let self.last_seen_comment.start = self.lptr
  call self.next_keyword()

  call self.next_keyword()
  while (self.ckeyword != '*/')
    call self.next_keyword()
  endwhile

  call self.prev_keyword()
  let self.last_seen_comment.end = self.lptr
  call self.next_keyword()

  call self.debug_o.debug_msg("Block comment end: " . self.lptr)

  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : skip_extern
"-------------------------------------------------------------------------------
function! s:keywords_cl.skip_extern() dict
  if !(self.ckeyword == 'extern' &&
     \ self.get_keyword(1) =~ '\v\s+' &&
     \ (self.get_keyword(2) =~ '\v^function$|^task$' ||
     \  (self.get_keyword(2) =~ '\v^static$|^virtual$' &&
     \   self.get_keyword(3) =~ '\v\s+' &&
     \   self.get_keyword(4) =~ '\v^function$|^task$')))
    return 0
  endif

  call self.debug_o.debug_msg("[skip_extern start]")

  call self.next_keyword()
  while (self.ckeyword != ';')
    call self.skip_double_quote()
    call self.next_keyword()
  endwhile

  call self.debug_o.debug_msg("[skip_extern end]")

  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : parse_method
"-------------------------------------------------------------------------------
function! s:keywords_cl.parse_method() dict
  if !(self.ckeyword =~ '\v^function$|^task$')
    return 0
  endif

  call self.debug_o.debug_msg("[parse_method start]")

  let method_o = deepcopy(s:method_cl)
  let method_o.debug_o = self.debug_o
  let method_o.type = self.ckeyword

  if (self.get_keyword(-1) =~ '\v^\s+$' && self.get_keyword(-2) =~ '\v^static$|^virtual$')
    call self.prev_keyword()
    call self.prev_keyword()
  endif

  let method_o.decl.start = self.lptr
  let method_o.def.start = self.lptr

  call method_o.set_comment(self.last_seen_comment)

  let is_decl = 0
  while !(self.ckeyword =~ '\v^endfunction$|^endtask$')
    call self.skip_double_quote()
    call self.skip_line_comment()
    call self.skip_block_comment()

    if (self.ckeyword == ';' && is_decl == 0)
      let is_decl = 1
      call self.prev_keyword()
      let method_o.decl.end = self.lptr
      call self.next_keyword()
    endif

    call self.next_keyword()
  endwhile
  call self.skip_double_quote()
  call self.skip_line_comment()
  call self.skip_block_comment()

  call self.prev_keyword()
  let method_o.def.end = self.lptr
  call self.next_keyword()

  call self.classes_o[-1].add(method_o)

  call self.debug_o.debug_msg("[parse_method end]")
endfunction

"-------------------------------------------------------------------------------
" Function : parse_class
"-------------------------------------------------------------------------------
function! s:keywords_cl.parse_class() dict
  if !(self.ckeyword == 'class' && self.get_keyword(1) =~ '\v\s+' && self.get_keyword(2) =~ '\v\w+')
    return 0
  endif

  call self.next_keyword()
  call self.skip_double_quote()
  call self.skip_line_comment()
  call self.skip_block_comment()

  call self.next_keyword()
  call self.skip_double_quote()
  call self.skip_line_comment()
  call self.skip_block_comment()

  call self.debug_o.debug_msg("[parse_class start]")
  call self.print()

  let class_o = deepcopy(s:class_cl)
  let class_o.debug_o = self.debug_o
  let class_o.name = self.ckeyword

  call self.add_class(class_o)

  while (self.ckeyword != 'endclass')
    call self.skip_double_quote()
    call self.skip_line_comment()
    call self.skip_block_comment()
    call self.skip_extern()

    call self.parse_method()

    call self.next_keyword()
  endwhile

  " --------------------------------------
  call self.prev_keyword()
  let self.extern_insert_point = self.lptr
  call self.next_keyword()
  " --------------------------------------

  call self.debug_o.debug_msg("[parse_class end]")
  call self.print()
endfunction

"-------------------------------------------------------------------------------
" Function : conv2extern
"-------------------------------------------------------------------------------
function! s:keywords_cl.conv2extern() dict
  for l:class_o in self.classes_o
    call l:class_o.conv2extern()
  endfor
endfunction

"-------------------------------------------------------------------------------
" Function : update_extern
"-------------------------------------------------------------------------------
function! s:keywords_cl.update_extern() dict
  let offset = 0
  for l:class_o in self.classes_o
    let l:class_o.extern_insert_point_str = self.extern_insert_point_str
    call l:class_o.update_lptr(l:offset)
    let l:offset += l:class_o.update_extern()
  endfor

  " Delete the insertion tag
  if (get(self, 'extern_insert_point') != 0)
    exe 'silent' . search(self.extern_insert_point_str, 'n') . 'delete'
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : parse_comment
"-------------------------------------------------------------------------------
function! s:keywords_cl.parse() dict
  call self.next_keyword()
  while self.ckeyword != ""
    call self.skip_double_quote()
    call self.skip_line_comment()
    call self.skip_block_comment()
    call self.parse_class()
    call self.next_keyword()

    call self.debug_o.debug_msg("<<<" . self.get_keyword(-1) . '<-->' . self.get_keyword(0) . '<-->' . self.get_keyword(1) . '>>>')
  endwhile

  let self.extern_insert_point_str = '###VIM_INSERT_EXTERN_METHODS_HERE###'
  if (get(self, 'extern_insert_point') != 0)
    call append (self.extern_insert_point, self.extern_insert_point_str) 
  endif

  call self.conv2extern()
  call self.update_extern() 
  call self.print_classes()
endfunction

" ==============================================================================
" Class Extern
" ==============================================================================
let s:extern_cl = {'debug_o': deepcopy(s:debug_cl)}

"-------------------------------------------------------------------------------
" Function : parse_lines
"-------------------------------------------------------------------------------
function! s:extern_cl.parse_lines(firstln, lastln) dict
  " FIXME: Uncomment below line in debug mode
  " call self.debug_o.enable_debug('debug.txt')
  let save_view = winsaveview()

  let keywords_o = deepcopy(s:keywords_cl)
  let keywords_o.lptr = a:firstln
  let keywords_o.cline = getline(a:firstln)
  let keywords_o.lastline = a:lastln
  let keywords_o.debug_o = self.debug_o
  call keywords_o.move_cptr(1)

  call keywords_o.parse()

  call winrestview(save_view)

endfunction


"-------------------------------------------------------------------------------
" Function : parse
"-------------------------------------------------------------------------------
function! sv#sv#extern#parse() range
  let extern_o = deepcopy(s:extern_cl)
  call extern_o.parse_lines(a:firstline, a:lastline)
endfunction

