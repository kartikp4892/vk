let s:pfile = $HOME . '/parser.log'

function! s:init()
  let s:m_comment = {'start_pos': [], 'end_pos': [], 'cargo': ''}
  let s:m_class = g:parser#uvm#null#null
  let s:m_fun = g:parser#uvm#null#null
  let s:m_task = g:parser#uvm#null#null
  let s:m_var = g:parser#uvm#null#null

  let s:m_class_comments = [] " {'m_comment': g:Null, 'm_class': g:Null}

  let s:comment_updated = 0

  let s:within_class = 0
  let s:within_method = 0

endfunction

"-------------------------------------------------------------------------------
" Function : sv#uvm#parser#update_comment#parse_fun
"-------------------------------------------------------------------------------
function! sv#uvm#parser#update_comment#parse_fun(lexer)
  let s:m_fun = g:parser#uvm#parser#function#function.new(a:lexer)
  if (s:m_fun.parse_header())
    call debug#debug#log (s:m_fun.string(), s:pfile)

    let s:within_method = 1

    "-------------------------------------------------------------------------------
    " Old Comment parser
    let m_old_comment = g:parser#uvm#parse_comments#comment.new(s:m_comment)
    call m_old_comment.parse_alpha_numero()
    "-------------------------------------------------------------------------------

    if (s:comment_updated == 0)
      call sv#uvm#parser#update_comment#replace_comment(s:m_fun.get_comments(m_old_comment.database), s:m_fun)
      let s:comment_updated = 1
    else
      let s:comment_updated = 0
    endif

    return 1
  endif

  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : s:parse_task
"-------------------------------------------------------------------------------
function! sv#uvm#parser#update_comment#parse_task(lexer)
  let s:m_task = g:parser#uvm#parser#task#task.new(a:lexer)
  if (s:m_task.parse_header())
    call debug#debug#log (s:m_task.string(), s:pfile)

    let s:within_method = 1

    "-------------------------------------------------------------------------------
    " Old Comment parser
    let m_old_comment = g:parser#uvm#parse_comments#comment.new(s:m_comment)
    call m_old_comment.parse_alpha_numero()
    "-------------------------------------------------------------------------------

    if (s:comment_updated == 0)
      call sv#uvm#parser#update_comment#replace_comment(s:m_task.get_comments(m_old_comment.database), s:m_task)
      let s:comment_updated = 1
    else
      let s:comment_updated = 0
    endif

    return 1
  endif

  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : s:parse_variable
"-------------------------------------------------------------------------------
function! sv#uvm#parser#update_comment#parse_variable(lexer)
  let s:m_var = g:parser#uvm#parser#variable#variable.new(a:lexer)

  " Currently don't add comments for variables inside function or task
  if (s:within_method == 1)
    return 0
  endif

  if (s:m_var.parse())
    call debug#debug#log (s:m_var.string(), s:pfile)

    ParserExpectKeywordPtrn 'a:lexer.m_current_keyword', '\v^(;|,)', 0, 'laxer_driver.vim', '31'

    "-------------------------------------------------------------------------------
    " Old Comment parser
    let m_old_comment = g:parser#uvm#parse_var_comment#comment.new(s:m_comment)
    call m_old_comment.parse_alpha_numero()
    "-------------------------------------------------------------------------------

    if (s:comment_updated == 0)
      call sv#uvm#parser#update_comment#replace_comment(s:m_var.get_var_comments(m_old_comment.database), s:m_var)
      let s:comment_updated = 1
    else
      let s:comment_updated = 0
    endif

    return 1
  endif
  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : replace_comment
"-------------------------------------------------------------------------------
function! sv#uvm#parser#update_comment#replace_comment(new_comment, ...)

  TVarArg ['m_parser', g:parser#uvm#null#null]
  
  let cmt = s:m_comment.cargo

  let cmt = substitute(cmt, '\W', ' ', 'g')
  let cmt = substitute(cmt, "\n", ' ', 'g')
  let words_a = split(cmt, '\v\s+')

  let del_old_cmt = 1

  " || for l:word in words_a 
  " ||   if (match(tolower(a:new_comment), tolower(l:word)) == -1)
  " ||     let del_old_cmt = 0
  " ||     break
  " ||   endif
  " || endfor

  if (del_old_cmt)
    if (s:m_comment.start_pos != [])
      exe printf('%s,%sdelete', s:m_comment.start_pos[0], s:m_comment.end_pos[0])
      let start_ln = s:m_comment.start_pos[0]
    else
      let start_ln = l:m_parser.start_pos[0]
    endif

    let indent = indent(nextnonblank(start_ln))

    let lines = map(split(a:new_comment, ''), printf('repeat(" ", %s ) . v:val', indent))

    " If previous line is not blank add a blank line
    if (getline(start_ln - 1) !~ '^\s*$')
      let lines = [''] + lines 
    endif

    call append(start_ln - 1, lines)
  else
    let new_comment = a:new_comment . '// <TODO_COMMENT>: UPDATE OLD COMMENT BELOW'

    let start_ln = s:m_comment.start_pos[0]
    let indent = indent(prevnonblank(start_ln - 1))
    let lines = map(split(l:new_comment, ''), printf('repeat(" ", %s) . v:val', indent))
    call append(start_ln - 1, lines)
  endif

  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : s:parse_class
"-------------------------------------------------------------------------------
function! sv#uvm#parser#update_comment#parse_class(lexer)
  let s:m_class = g:parser#uvm#parser#class#class.new(a:lexer)
  if (s:m_class.parse_header())
    call debug#debug#log (s:m_class.string(), s:pfile)

    let s:within_class = 1

    if (s:comment_updated == 0)
      "-------------------------------------------------------------------------------
      " Old Comment parser
      let m_old_comment = g:parser#uvm#parse_comments#comment.new(s:m_comment)
      call m_old_comment.parse_alpha_numero()
      "-------------------------------------------------------------------------------

      call sv#uvm#parser#update_comment#replace_comment(s:m_class.get_comments(m_old_comment.database), s:m_class)
      let s:comment_updated = 1
    else
      let s:comment_updated = 0
    endif

    return 1
  endif
  return 0
endfunction

function! s:skip_block(lexer, start_kw, end_kw) " ex: start_kw = { , end_kw = }
  if (a:lexer.m_current_keyword.cargo == a:start_kw)
    ParserReturnOnNull 'm_keyword', 'a:lexer.get_next_keyword()'

    while m_keyword.cargo != a:end_kw
      ParserReturnOnNull 'm_keyword', 'a:lexer.get_next_keyword()'
    endwhile

    ParserReturnOnNull 'm_keyword', 'a:lexer.get_next_keyword()'

    return 1
  endif

  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : drive
"-------------------------------------------------------------------------------
function! sv#uvm#parser#update_comment#parse_sv(firstln, lastln)

    if (a:lastln == line('$'))
      let parse_until_end = 1
    else
      let parse_until_end = 0
    endif

    call debug#debug#ftouch()
    call debug#debug#ftouch(s:pfile)

    let g:debug#debug#enable[s:pfile] = 1
    let g:debug#debug#enable[$HOME . '/debug.log'] = 1

    if (parse_until_end == 1)
      let m_lexer = g:parser#uvm#lexer#lexer.new(expand('%:p'), a:firstln)
    else
      let m_lexer = g:parser#uvm#lexer#lexer.new(expand('%:p'), a:firstln, a:lastln)
    endif

    let start_ln = 1

    ParserReturnOnNull 'm_keyword', 'm_lexer.get_next_keyword()'

    while 1

      if (sv#uvm#parser#update_comment#parse_fun(m_lexer))
        if (s:comment_updated == 1)
          if (s:m_comment.start_pos != [])
            let start_ln = s:m_comment.start_pos[0]
          else
            let start_ln = s:m_fun.start_pos[0]
          endif

          if (parse_until_end == 1)
            let m_lexer = g:parser#uvm#lexer#lexer.new(expand('%:p'), start_ln)
          else
            let m_lexer = g:parser#uvm#lexer#lexer.new(expand('%:p'), start_ln, a:lastln)
          endif
        endif

        let s:m_comment = {'start_pos': [], 'end_pos': [], 'cargo': ''}

      elseif (sv#uvm#parser#update_comment#parse_task(m_lexer))
        if (s:comment_updated == 1)
          if (s:m_comment.start_pos != [])
            let start_ln = s:m_comment.start_pos[0]
          else
            let start_ln = s:m_task.start_pos[0]
          endif

          if (parse_until_end == 1)
            let m_lexer = g:parser#uvm#lexer#lexer.new(expand('%:p'), start_ln)
          else
            let m_lexer = g:parser#uvm#lexer#lexer.new(expand('%:p'), start_ln, a:lastln)
          endif
        endif

        let s:m_comment = {'start_pos': [], 'end_pos': [], 'cargo': ''}

      elseif (sv#uvm#parser#update_comment#parse_class(m_lexer))
        if (s:comment_updated == 1)
          if (s:m_comment.start_pos != [])
            let start_ln = s:m_comment.start_pos[0]
          else
            let start_ln = s:m_class.start_pos[0]
          endif

          if (parse_until_end == 1)
            let m_lexer = g:parser#uvm#lexer#lexer.new(expand('%:p'), start_ln)
          else
            let m_lexer = g:parser#uvm#lexer#lexer.new(expand('%:p'), start_ln, a:lastln)
          endif
        endif
        let s:m_comment = {'start_pos': [], 'end_pos': [], 'cargo': ''}
        
      elseif (sv#uvm#parser#update_comment#parse_variable(m_lexer))
        if (s:comment_updated == 1)
          if (s:m_comment.start_pos != [])
            let start_ln = s:m_comment.start_pos[0]
          else
            let start_ln = s:m_var.start_pos[0]
          endif

          if (parse_until_end == 1)
            let m_lexer = g:parser#uvm#lexer#lexer.new(expand('%:p'), start_ln)
          else
            let m_lexer = g:parser#uvm#lexer#lexer.new(expand('%:p'), start_ln, a:lastln)
          endif
        endif
        let s:m_comment = {'start_pos': [], 'end_pos': [], 'cargo': ''}
        
      else
        call debug#debug#log (m_lexer.m_current_keyword.string(), s:pfile)

        let s:m_comment = {'start_pos': [], 'end_pos': [], 'cargo': ''}
        if (m_lexer.m_current_keyword == g:parser#uvm#null#null)
          ParserReturnOnNull 'm_keyword', 'm_lexer.get_next_keyword()'
          continue
        endif

        "-------------------------------------------------------------------------------
        " Skip parenthesis
        if (s:skip_block(m_lexer, '{', '}'))
          continue
        elseif (s:skip_block(m_lexer, '[', ']'))
          continue
        elseif (s:skip_block(m_lexer, '(', ')'))
          continue
        endif
        "-------------------------------------------------------------------------------

        ParserReturnOnNull 'm_keyword', 'm_lexer.m_current_keyword'

        if (m_keyword.cargo =~ '\v^(//|/\*)')
          while m_keyword.cargo =~ '\v^(//|/\*)'
            if (s:m_comment.cargo == '')
              let start_ln = m_keyword.start_pos[0]

              let s:m_comment.start_pos = m_keyword.start_pos
            endif

            let s:m_comment.cargo .= m_keyword.cargo 
            let s:m_comment.end_pos = m_keyword.end_pos

            let m_keyword = m_lexer.get_next_keyword()
            if (m_keyword == g:parser#uvm#null#null)
              return 0
            endif
            " ParserReturnOnNull 'm_keyword', 'm_lexer.get_next_keyword()'
          endwhile

          continue
        endif

        if (m_keyword.cargo == 'endclass')
          let s:within_class = 0
        elseif (m_keyword.cargo =~ '\v^end(function|task)$')
          let s:within_method = 0
        endif

        ParserReturnOnNull 'm_keyword', 'm_lexer.get_next_keyword()'

      endif
    endwhile

endfunction

"-------------------------------------------------------------------------------
" Function : sv#uvm#parser#update_comment
"-------------------------------------------------------------------------------
function! sv#uvm#parser#update_comment#update_comment() range

  call s:init()
  call sv#uvm#parser#update_comment#parse_sv(a:firstline, a:lastline)

endfunction

"-------------------------------------------------------------------------------
" Function : sv#uvm#parser#update_comment#remove_old_comment
"-------------------------------------------------------------------------------
function! sv#uvm#parser#update_comment#remove_old_comment()
  while search('<TODO_COMMENT>') != 0
    
    let m_lexer = g:parser#uvm#lexer#lexer.new(expand('%:p'), line('.'))

    ParserReturnOnNull 'm_keyword', 'm_lexer.get_next_keyword()'
    let start_ln = m_keyword.start_pos[0]

    while m_keyword.cargo =~ '\v^(//|/\*)'
      let end_ln = m_keyword.end_pos[0]

      ParserReturnOnNull 'm_keyword', 'm_lexer.get_next_keyword()'
    endwhile

    exe printf('%s,%sdelete', start_ln, end_ln)
  endwhile
endfunction

" nmap <F7> :call sv#uvm#parser#update_comment#update_comment() 
" nmap <F8> :call sv#uvm#parser#update_comment#remove_old_comment() 


