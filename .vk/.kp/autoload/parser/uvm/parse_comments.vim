let parser#uvm#parse_comments#comment = {}

function! parser#uvm#parse_comments#comment.new(m_blk_cmt) dict
  call debug#debug#log(printf("parser#uvm#parse_comments#comment.new == %s", string(self.new)))

  let this = deepcopy(self)

  let this.m_blk_cmt = a:m_blk_cmt
  let this.method_ptrn = '\v^\c\s*\/\/\s*(method|function|task)(\s+name)?\s*:'
  let this.return_type_ptrn = '\v^\c\s*\/\/\s*(return)(\s+type)?\s*:'
  let this.arg_ptrn = '\v^\c\s*\/\/\s*(arguments?)\s*:'
  let this.desc_ptrn = '\v^\c\s*\/\/\s*(description)\s*:'
  let this.param_ptrn = '\v^\c\s*\/\/\s*(parameters?)\s*:'
  let this.class_ptrn = '\v^\c\s*\/\/\s*(class?)\s*:'
  let this.class_parent_ptrn = '\v^\c\s*\/\/\s*(parent?)\s*:'
  let this.var_name_ptrn = '\v^\s*\w+(\s*\[.{-}\])*(\s+\w+)?(\s*\[.{-}\])*\zs\s*(:|:-|-)'
  let this.database = {}
  
  return this
endfunction

function! parser#uvm#parse_comments#comment.parse_alpha_numero() dict
  call debug#debug#log(printf("parser#uvm#parse_comments#comment.parse_alpha_numero == %s", string(self.parse_alpha_numero)))
  
  if (len(self.m_blk_cmt.start_pos) == 0 || len(self.m_blk_cmt.end_pos) == 0)
    return 
  endif

  let comments_a = getline(self.m_blk_cmt.start_pos[0], self.m_blk_cmt.end_pos[0])

  let self.database = {}
  let cmt_in_prog = ""
  for l:cmt_str in comments_a
    if (l:cmt_str =~ '\v^\s*\/\/\s*[^0-9a-zA-Z_]+$') " //--------------------- 
      continue
    endif

    if (l:cmt_str =~? self.method_ptrn)
      let l:cmt_str = substitute(l:cmt_str, self.method_ptrn, '', 'g')
      if (l:cmt_str =~ '\v^\s*\w+\s*(:|:-|-)')
        let [method_name, description] = split(l:cmt_str, '\v^\s*\w+\zs\s*(:|:-|-)\s*')
        let method_name = substitute(method_name, '\v(^\s+|\s+$)', '', 'g')
        let description = substitute(description, '\v(^\s+|\s+$)', '', 'g')
        let self.database['method'] = {'name': method_name, 'description': description}
      endif

    elseif (l:cmt_str =~? self.class_ptrn)
      let l:cmt_str = substitute(l:cmt_str, self.class_ptrn, '', 'g')
      if (l:cmt_str =~ '\v^\s*\w+\s*(:|:-|-)')
        let [class_name, description] = split(l:cmt_str, '\v^\s*\w+\zs\s*(:|:-|-)\s*')
        let class_name = substitute(class_name, '\v(^\s+|\s+$)', '', 'g')
        let description = substitute(description, '\v(^\s+|\s+$)', '', 'g')
        let self.database['class'] = {'name': class_name, 'description': description}
      endif

    elseif (l:cmt_str =~? self.class_parent_ptrn)
      let l:cmt_str = substitute(l:cmt_str, self.class_parent_ptrn, '', 'g')
      if (l:cmt_str =~ '\v^\s*\w+\s*(:|:-|-)')
        let [parent_name, description] = split(l:cmt_str, '\v^\s*\w+\zs\s*(:|:-|-)\s*')
        let parent_name = substitute(parent_name, '\v(^\s+|\s+$)', '', 'g')
        let description = substitute(description, '\v(^\s+|\s+$)', '', 'g')
        let self.database['parent'] = {'name': parent_name, 'description': description}
      endif

    elseif (l:cmt_str =~? self.arg_ptrn)
      let cmt_in_prog = "argument"
      let l:cmt_str = substitute(l:cmt_str, self.arg_ptrn, '', 'g')

      call self.extract_var_info(l:cmt_str, 'arguments')
    elseif (l:cmt_str =~? self.param_ptrn)
      let cmt_in_prog = "parameter"
      let l:cmt_str = substitute(l:cmt_str, self.param_ptrn, '', 'g')

      call self.extract_var_info(l:cmt_str, 'parameters')
    elseif (l:cmt_str =~? self.desc_ptrn)
      let cmt_in_prog = "description"
      let l:cmt_str = substitute(l:cmt_str, self.desc_ptrn, '', 'g')
      call self.extract_desc_info(l:cmt_str)
    elseif (l:cmt_str =~? self.return_type_ptrn)
      let l:cmt_str = substitute(l:cmt_str, self.return_type_ptrn, '', 'g')
      let rt_ptrn = '\v^\s*\w+\s*(\[.{-}\])*\s*'
      if (l:cmt_str =~ rt_ptrn)
        let return_type = matchstr(l:cmt_str, rt_ptrn)
        let l:cmt_str = substitute(l:cmt_str, rt_ptrn, '', 'g')
        let return_type = substitute(return_type, '\v(^\s+|\s+$)', '', 'g')
      endif

      let des_ptrn = '\v^\s*(:|:-|-)\s*'
      if (l:cmt_str =~ des_ptrn)
        let description = substitute(l:cmt_str, des_ptrn, '', 'g')
        let description = substitute(description, '\v(^\s+|\s+$)', '', 'g')
      endif

      if (!exists('description'))
        continue
      endif
      let self.database['return_type'] = {'return_type': return_type, 'description': description}
    else
      if (cmt_in_prog == "argument")
        let l:cmt_str = substitute(l:cmt_str, '^\s*//\s*', '', 'g')
        call self.extract_var_info(l:cmt_str, 'arguments')
      elseif (cmt_in_prog == "description")
        let l:cmt_str = substitute(l:cmt_str, '^\s*//\s*', '', 'g')
        call self.extract_desc_info(l:cmt_str)
      elseif (cmt_in_prog == "parameter")
        let l:cmt_str = substitute(l:cmt_str, '^\s*//\s*', '', 'g')
        call self.extract_var_info(l:cmt_str, 'parameters')
      endif

    endif

  endfor

endfunction

function! parser#uvm#parse_comments#comment.extract_var_info(cmt_str, var_type) dict
  call debug#debug#log(printf("parser#uvm#parse_comments#comment.extract_var_info == %s", string(self.extract_var_info)))
  
  if (!exists('self.database[a:var_type]'))
    let self.database[a:var_type] = []
  endif

  if (a:cmt_str =~ self.var_name_ptrn)
    let [arg_name, description] = split(a:cmt_str,self.var_name_ptrn)
    let arg_name = substitute(arg_name, '\v\[.{-}\]', '', 'g')
    let arg_name = substitute(arg_name, '\v^\s*\w+\s+\ze\w+', '', 'g')
    let arg_name = substitute(arg_name, '\v(^\s+|\s+$)', '', 'g')
    let description = substitute(description, '\v(^\s+|\s+$)', '', 'g')
    let self.database[a:var_type] += [{'name': arg_name, 'description': description}]

    return 1
  endif

  return 0
endfunction

function! parser#uvm#parse_comments#comment.extract_desc_info(cmt_str) dict
  call debug#debug#log(printf("parser#uvm#parse_comments#comment.extract_desc_info == %s", string(self.extract_desc_info)))
  
  if (!exists('self.database["description"]'))
    let self.database['description'] = []
  endif

  let l:cmt_str = a:cmt_str
  let l:cmt_str = substitute(l:cmt_str, '\v(^\s+|\s+$)', '', 'g')
  let self.database['description'] += [l:cmt_str]
endfunction

" let m_comment = parser#uvm#parse_comments#comment.new(str)
" nmap <F6> :call m_comment.parse_alpha_numero()



