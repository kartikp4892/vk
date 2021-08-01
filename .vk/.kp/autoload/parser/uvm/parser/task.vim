let parser#uvm#parser#task#task = {}

"-------------------------------------------------------------------------------
" Task : Task.new
"-------------------------------------------------------------------------------
function! parser#uvm#parser#task#task.new(lexer) dict
  call debug#debug#log(printf("parser#uvm#parser#task#task.new == %s", string(self.new)))

  let this = deepcopy(self)
  let this.type = 'task'
  let this.lexer = a:lexer
  let this.start_pos = g:parser#uvm#null#null
  let this.end_pos = g:parser#uvm#null#null
  let this.cargo = ''
  let this.extern = ''
  let this.task_type = ''
  let this.task_name = ''
  let this.return_type = ''
  let this.parent_class = ''
  let this.args = []
  
  " list of keys that should be part of comments
  let this.comments_keys = ['task_name', 'args', 'parent_class']
  let this.placeholder_comments_keys = {'task_name': 'Task', 'args': 'Arguments', 'parent_class': 'Parent Class'}
  
  return this
endfunction

"-------------------------------------------------------------------------------
" Task : Task.parse
"-------------------------------------------------------------------------------
function! parser#uvm#parser#task#task.parse() dict
  call debug#debug#log(printf("parser#uvm#parser#task#task.parse == %s", string(self.parse)))
  
  " Comment
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'
  if (self.lexer.m_current_keyword.cargo =~ '\v^(\/\/|\/\*)')
    return 0
  endif
  
  ParserReturnOnNull 'm_keyword_n1', 'self.lexer.clone_next_keyword()'
  ParserReturnOnNull 'm_keyword_n2', 'self.lexer.clone_next_keyword(2)'

  if (m_keyword.cargo == 'task' || (m_keyword.cargo =~ '\v^(extern)$' && (m_keyword_n1.cargo == 'task' || m_keyword_n2.cargo == 'task')) || (m_keyword.cargo =~ '\v^(virtual|static)$' && m_keyword_n1.cargo == 'task'))
    call self.__parse__()
    return 1
  endif

  return 0

endfunction

"-------------------------------------------------------------------------------
" Task : Task.parse_header
"-------------------------------------------------------------------------------
function! parser#uvm#parser#task#task.parse_header() dict
  call debug#debug#log(printf("parser#uvm#parser#task#task.parse_header == %s", string(self.parse_header)))
  
  " Comment
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'
  if (self.lexer.m_current_keyword.cargo =~ '\v^(\/\/|\/\*)')
    return 0
  endif
  
  ParserReturnOnNull 'm_keyword_n1', 'self.lexer.clone_next_keyword()'
  ParserReturnOnNull 'm_keyword_n2', 'self.lexer.clone_next_keyword(2)'

  if (m_keyword.cargo == 'task' || (m_keyword.cargo =~ '\v^(extern)$' && (m_keyword_n1.cargo == 'task' || m_keyword_n2.cargo == 'task')) || (m_keyword.cargo =~ '\v^(virtual|static)$' && m_keyword_n1.cargo == 'task'))
    call self.__parse_header__()
    return 1
  endif

  return 0

endfunction

"-------------------------------------------------------------------------------
" Task : Task.parse_arg
"-------------------------------------------------------------------------------
function! parser#uvm#parser#task#task.parse_arg() dict
  call debug#debug#log(printf("parser#uvm#parser#task#task.parse_arg == %s", string(self.parse_arg)))
  
  let m_arg = g:parser#uvm#parser#arg#arg.new(self.lexer)

  if (m_arg.parse() == 1)
    return m_arg 
  else
    return g:parser#uvm#null#null
  endif
endfunction

"-------------------------------------------------------------------------------
" Task : Task.__parse_header__
"-------------------------------------------------------------------------------
function! parser#uvm#parser#task#task.__parse_header__() dict
  call debug#debug#log(printf("parser#uvm#parser#task#task.__parse_header__ == %s", string(self.__parse_header__)))
  
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'

  let self.start_pos = m_keyword.start_pos

  if (m_keyword.cargo == 'extern')
    let self.extern = m_keyword.cargo 
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
  endif

  if (m_keyword.cargo != 'task')
    let self.task_type = m_keyword.cargo 
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
  endif

  ParserExpectKeyword 'self.lexer.m_current_keyword', 'task', 0, '/home/kartik/uvm_parser_vim/parser/task.vim', '113'
  ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

  let m_keyword_n1 = self.lexer.clone_next_keyword()
  while m_keyword_n1 != g:parser#uvm#null#null && m_keyword_n1.cargo !~ '\v^(\(|;|::)$'
    let self.return_type .= m_keyword.cargo
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let m_keyword_n1 = self.lexer.clone_next_keyword()
  endwhile
  
  if (m_keyword_n1.cargo == '::')
    let self.parent_class = m_keyword.cargo
    " Skip ::
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
  endif

  let self.task_name = m_keyword.cargo

  ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

  if (m_keyword.cargo == '(')

    let m_arg = self.parse_arg() 

    if (m_arg != g:parser#uvm#null#null)
      while m_arg != g:parser#uvm#null#null
        if (len(self.args) != 0)
          if (m_arg.direction == '')
            let m_arg.direction = self.args[-1].direction
          endif

          if (m_arg.type == '')
            let m_arg.type = self.args[-1].type
            let m_arg.unpacked_range = self.args[-1].unpacked_range
          endif
        endif

        let self.args += [m_arg]

        " let m_keyword = self.lexer.get_next_keyword()| if (m_keyword == g:parser#uvm#null#null)| return 0 |endif

        ParserExpectKeywordPtrn 'self.lexer.m_current_keyword', '\v^(\)|,)$', 0, '/home/kartik/uvm_parser_vim/parser/task.vim', '89'

        if (m_keyword.cargo == ')')
          break
        endif

        let m_arg = self.parse_arg() 

      endwhile
    else
      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
      ParserExpectKeyword 'm_keyword', ')', 0, '/home/kartik/uvm_parser_vim/parser/task.vim', '98'
    endif

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
  endif

  ParserExpectKeyword 'm_keyword', ';', 0, 'parser/task.vim', '112'

  let self.end_pos = m_keyword.end_pos

  ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

  " <SKIP> let self.cargo = join(getline(self.start_pos[0], self.end_pos[0]), "\n")
endfunction

"-------------------------------------------------------------------------------
" Task : Task.__parse__
"-------------------------------------------------------------------------------
function! parser#uvm#parser#task#task.__parse__() dict
  call debug#debug#log(printf("parser#uvm#parser#task#task.__parse__ == %s", string(self.__parse__)))
  
  if !self.__parse_header__()
    return 0
  endif

  if (self.extern != '')
    return 1
  endif

  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'

  while m_keyword != g:parser#uvm#null#null && m_keyword.cargo != 'endtask'
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
  endwhile

  ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
  if (m_keyword.cargo == ':')
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
  endif
  
  let self.end_pos = self.lexer.m_prev_keyword.end_pos

  " <SKIP> let self.cargo = join(getline(self.start_pos[0], self.end_pos[0]), "\n")
endfunction

"-------------------------------------------------------------------------------
" Task : Task.string
"-------------------------------------------------------------------------------
function! parser#uvm#parser#task#task.string(...) dict
  call debug#debug#log(printf("parser#uvm#parser#task#task.string == %s", string(self.string)))

  TVarArg ['indent', 0]
  
  let indent_str = repeat(' ', indent)
  let str = "<TASK START>\n"

  let str .= printf("%s<task_type> %s\n", indent_str , self.task_type)
  let str .= printf("%s<type> %s\n", indent_str , self.type) 
  let str .= printf("%s<return_type> %s\n", indent_str , self.return_type)
  let str .= printf("%s<parent_class> %s\n", indent_str , self.parent_class)
  let str .= printf("%s<task_name> %s\n", indent_str , self.task_name)
  let str .= printf("%s<start_pos> %s\n", indent_str , string(self.start_pos))
  let str .= printf("%s<end_pos> %s\n", indent_str , string(self.end_pos))
  let str .= printf("%s<cargo> \n%s\n", indent_str , self.cargo)

  for l:arg in self.args
    let str .= printf("%s<arg>\n", indent_str)
    let str .= printf("%s\n", l:arg.string(indent + 2))
  endfor
  let str .= "<TASK END>\n"

  return str
endfunction

function! parser#uvm#parser#task#task.get_default_desc_comment() dict
  call debug#debug#log(printf("parser#uvm#parser#task#task.get_default_desc_comment == %s", string(self.get_default_desc_comment)))

  if (self.task_name == 'run_phase')
    let str = 'In this phase the TB execution starts'
  elseif (self.task_name == 'body')
    let str = 'This task executes the sequence to generate transaction'
  elseif (self.task_name == 'pre_body')
    let str = 'This task is call before body task is started'
  elseif (self.task_name == 'post_body')
    let str = 'This task is call after body task is completed'
  else
    let str = ''
  endif

  return str
endfunction

"-------------------------------------------------------------------------------
" Task : Task.get_comments
"-------------------------------------------------------------------------------
function! parser#uvm#parser#task#task.get_comments(...) dict
  call debug#debug#log(printf("parser#uvm#parser#task#task.get_comments == %s", string(self.get_comments)))
  
  TVarArg ['m_old_comment_h', {}]  

  let comments = []

  for l:key in self.comments_keys
    if (l:key == 'args')
      let idx = 0
      for l:m_arg in self[l:key]
        let m_old_arg_h = filter(deepcopy(get(m_old_comment_h, 'arguments', [])), 'v:val.name == l:m_arg.variable')
        if (len(m_old_arg_h) == 0)
          let arg_desc = l:m_arg.get_default_comment()
        else
          let arg_desc = printf(' - %s', m_old_arg_h[0].description)
        endif

        if (idx == 0)
          let idx += 1
          let cmt = printf('%-15s: %s%s', self.placeholder_comments_keys[l:key], l:m_arg.get_comments(), arg_desc)
        else
          let cmt = printf('%-15s  %s%s', '', l:m_arg.get_comments(), arg_desc)
        endif
        " let cmt = l:m_arg.get_comments()
        let comments += [l:cmt]
      endfor
    else

      if (l:key == 'return_type' && (self[l:key] == 'void' || self[l:key] == ''))
        continue
      endif

      " for extern fun --> class :: fun_name
      if (l:key == 'parent_class' && self[l:key] == '')
        continue
      endif

      if (l:key == 'task_name')
        let k ='method' 
      else
        let k = l:key
      endif

      if (exists('m_old_comment_h[k]["description"]'))
        let desc = printf(' - %s', m_old_comment_h[k]["description"])
      else
        let desc = ''
      endif

      let cmt = printf('%-15s: %s%s', self.placeholder_comments_keys[l:key], self[l:key], desc)
      let comments += [l:cmt]
    endif
  endfor

  if (exists('m_old_comment_h["description"]'))
    let idx = 0
    for l:desc in m_old_comment_h["description"]
      if (idx == 0)
        let idx += 1
        let cmt = printf('%-15s: %s', 'Description', l:desc)
      else
        let cmt = printf('%-15s  %s', '', l:desc)
      endif
      let comments += [cmt]

    endfor
  else
    let cmt = printf('%-15s: %s', 'Description', self.get_default_desc_comment())
    let comments += [cmt]
  endif

  let save_cmt_en = g:comments#variables#enable_comment
  let g:comments#variables#enable_comment = 1

  let comment_header = call('comments#block_comment#getComments', ['', ''] + comments)

  let g:comments#variables#enable_comment = save_cmt_en 

  return comment_header 
endfunction


