let parser#uvm#parse_var_comment#comment = {}

function! parser#uvm#parse_var_comment#comment.new(m_blk_cmt) dict
  call debug#debug#log(printf("parser#uvm#parse_var_comment.new == %s", string(self.new)))

  let this = deepcopy(self)
  let this.m_blk_cmt = a:m_blk_cmt
  let this.var_ptrn = '\v^\c\s*\/\/\s*(variable|typedef)\s*:'
  let this.description_ptrn = '\v^\c\s*\/\/\s*(description\s*:\s*)?'
  let this.database = {}

  return this
  
endfunction

function! parser#uvm#parse_var_comment#comment.parse_alpha_numero() dict
  call debug#debug#log(printf("parser#uvm#parse_var_comment#comment.parse_alpha_numero == %s", string(self.parse_alpha_numero)))
  
  if (len(self.m_blk_cmt.start_pos) == 0 || len(self.m_blk_cmt.end_pos) == 0)
    return 
  endif

  let comments_a = getline(self.m_blk_cmt.start_pos[0], self.m_blk_cmt.end_pos[0])

  let self.database = {}

  let prv_cmt_str = ''
  for l:cmt_str in comments_a
    
    if (l:cmt_str =~ '\v^\s*\/\/\s*[^0-9a-zA-Z_]+$') " //--------------------- 
      let prv_cmt_str = l:cmt_str 

      continue
    endif

    if (l:cmt_str =~? self.var_ptrn)
      continue
    endif

    if (l:prv_cmt_str =~ '\v^\s*\/\/\s*[^0-9a-zA-Z_]+$') " //--------------------- 
      let self.database['description'] = []
    endif

    if (l:cmt_str =~? self.description_ptrn)
      let l:cmt_str = substitute(l:cmt_str, self.description_ptrn, '', 'g')
    else
      let l:cmt_str = substitute(l:cmt_str, '^\s*//\s*', '', 'g')
    endif

    call self.extract_desc_info(l:cmt_str)

    let prv_cmt_str = l:cmt_str 
  endfor

endfunction

function! parser#uvm#parse_var_comment#comment.extract_desc_info(cmt_str) dict
  call debug#debug#log(printf("parser#uvm#parse_var_comment#comment.extract_desc_info == %s", string(self.extract_desc_info)))
  
  if (!exists('self.database["description"]'))
    let self.database['description'] = []
  endif

  let l:cmt_str = a:cmt_str
  let l:cmt_str = substitute(l:cmt_str, '\v(^\s+|\s+$)', '', 'g')
  let self.database['description'] += [l:cmt_str]
endfunction



