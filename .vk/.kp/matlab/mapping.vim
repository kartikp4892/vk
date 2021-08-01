
"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

function! s:get_matched(mappings)
  let mword = expression_map#map#get_map_word()

  let matched = {}
  for [key, val] in items(a:mappings)
    if (mword =~ key)
      let matched[key] = val
    endif
  endfor

  if (len(matched) == 1)
    for l:v in values(matched)
      call expression_map#map#remove_map_word()
      return l:v['map']
    endfor
  elseif (len(matched) > 1)
    let inputdict = {}
    for [key,value] in items(matched)
      let inputdict[printf('%s =~ %s', value['abbr'], key)] = value['map']
    endfor

    call inputsave()
    let matkey = tlib#input#List('s', 'Select item', keys(inputdict))
    call inputrestore()

    if (matkey == '')
      return ''
    endif

    call expression_map#map#remove_map_word()
    return inputdict[matkey]
  endif

  return ''
endfunction

function! s:get_oneof(mappings)
  let inputdict = {}
  for [key,value] in items(a:mappings)
    let inputdict[printf('%s =~ %s', value['abbr'], key)] = value['map']
  endfor

  call inputsave()
  let matkey = tlib#input#List('s', 'Select item', keys(inputdict))
  call inputrestore()

  if (matkey == '')
    return ''
  endif

  call expression_map#map#remove_map_word()
  return inputdict[matkey]
endfunction

"-------------------------------------------------------------------------------
" Exp_Map_Mj: Function
function! s:Exp_Map_Mj()
  let mappings = {}
  let mappings['\v^i%[f]$'] = {'abbr': 'if', 'map': '=matlab#matlab#if()'}
  let mappings['\v^e%[lse]%[i]f$'] = {'abbr': 'elseif', 'map': '=matlab#matlab#elseif()'}
  let mappings['\v^e%[lse]$'] = {'abbr': 'else', 'map': '=matlab#matlab#else()'}
  let mappings['\v^s%[witch]$'] = {'abbr': 'switch', 'map': '=matlab#matlab#switch()'}
  let mappings['\v^f%[or]$'] = {'abbr': 'for', 'map': '=matlab#matlab#for()'}
  let mappings['\v^w%[hile]$'] = {'abbr': 'while', 'map': '=matlab#matlab#while()'}
  let mappings['\v^t%[ry]%[catch]$'] = {'abbr': 'try-catch', 'map': '=matlab#matlab#try_catch()'}

  let mapping = s:get_matched(mappings)

  if (mapping != '')
    return mapping
  endif

  " Default
  return s:get_oneof(mappings)

endfunction
imap <M-j> =<SID>Exp_Map_Mj()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mc: Function
" Mappings: Comments
function! s:Exp_Map_Mc()
  let mappings = {}
  let mappings['\v^%[block]%[comment]$'] = {'abbr': 'block comment', 'map': '=matlab#matlab#block_comment()'}

  let mapping = s:get_matched(mappings)

  if (mapping != '')
    return mapping
  endif

  " Default
  return s:get_oneof(mappings)

endfunction
imap <M-c> =<SID>Exp_Map_Mc()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mf: Function
" Functions
function! s:Exp_Map_Mf()
  let mappings = {}
  let mappings['\v^f%[unction]$'] = {'abbr': 'function', 'map': '=matlab#matlab#function()'}
  let mappings['\v^a%[nonymous]%[function]$'] = {'abbr': 'anonymous function', 'map': '=matlab#matlab#anonymous_function()'}
  let mappings['\v^v%[ar]%[arg]%[in]$'] = {'abbr': 'varargin', 'map': 'varargin'}
  let mappings['\v^v%[ar]%[arg]%[out]$'] = {'abbr': 'varargout', 'map': 'varargout'}
  let mappings['\v^n%[arg]%[in]$'] = {'abbr': 'nargin', 'map': 'nargin'}

  let mapping = s:get_matched(mappings)

  if (mapping != '')
    return mapping
  endif

  " Default
  return s:get_oneof(mappings)

endfunction
imap <M-f> =<SID>Exp_Map_Mf()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Cf: Function
" Mapping: Matlab inbuilt functions
function! s:Exp_Map_Cf()
  let mappings = {}
  let mappings['\v^f%[printf]$'] = {'abbr': 'fprintf', 'map': "fprintf ('maa\\n', );`aa"}
  let mappings['\v^d%[isp]$'] = {'abbr': 'disp', 'map': "disp (maa);`aa"}
  let mappings['\v^d%[isp]%[lay]$'] = {'abbr': 'display', 'map': "display (maa);`aa"}
  let mappings['\v^s%[l]c%[haracter]e%[ncoding]$'] = {'abbr': 'slCharacterEncoding', 'map': "slCharacterEncoding ('maa');`aa"}
  let mappings['\v^w%[arning]$'] = {'abbr': 'warning', 'map': "warning ('maa', '');`aa"}
  let mappings['\v^e%[xist]$'] = {'abbr': 'exist', 'map': "exist ('maa')`aa"}
  let mappings['\v^d%[ate]%[str]$'] = {'abbr': 'datestr', 'map': "datestr (now, 'maaYYYYmmdd.HH:MM:SS.FFF')`aa"}
  let mappings['\v^s%[tr]%[2]%[func]$'] = {'abbr': 'str2func', 'map': "str2func (maa)`aa"}
  let mappings['\v^s%[tr]%[cat]$'] = {'abbr': 'strcat', 'map': "strcat (maa)`aa"}
  let mappings['\v^l%[oad]%[system]$'] = {'abbr': 'load_system', 'map': "load_system (maa)`aa"}
  let mappings['\v^s%[et]%[param]$'] = {'abbr': 'set_param', 'map': "set_param (maa)`aa"}
  let mappings['\v^g%[et]%[param]$'] = {'abbr': 'get_param', 'map': "set_param (maa)`aa"}
  let mappings['\v^x%[ls]%[read]$'] = {'abbr': 'xlsread', 'map': "xlsread (maa)`aa"}
  let mappings['\v^s%[im]%[set]$'] = {'abbr': 'simset', 'map': "options = simset('SrcWorkspace','current');sim(testplatformname, [Tstart Tstop],options);"}

  let mapping = s:get_matched(mappings)

  if (mapping != '')
    return mapping
  endif

  " Default
  return s:get_oneof(mappings)

endfunction
imap <C-f> =<SID>Exp_Map_Cf()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Ck: Function
" Mapping: Matlab inbuilt variables
function! s:Exp_Map_Ck()
  let mappings = {}
  let mappings['\v^m%[file]%[name]$'] = {'abbr': 'mfilename', 'map': "mfilename"}

  let mapping = s:get_matched(mappings)

  if (mapping != '')
    return mapping
  endif

  " Default
  return s:get_oneof(mappings)

endfunction
imap <C-k> =<SID>Exp_Map_Ck()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mo: Function
" Functions
function! s:Exp_Map_Mo()
  let mappings = {}
  let mappings['\v^c%[lass]$'] = {'abbr': 'class', 'map': '=matlab#oops#class()'}
  let mappings['\v^f%[unction]$'] = {'abbr': 'function', 'map': '=matlab#oops#function()'}
  let mappings['\v^e%[num]c%[lass]$'] = {'abbr': 'enumeration_class', 'map': '=matlab#oops#enumeration_class()'}
  let mappings['\v^p%[roperties]$'] = {'abbr': 'properties', 'map': '=matlab#oops#properties()'}

  let mapping = s:get_matched(mappings)

  if (mapping != '')
    return mapping
  endif

  " Default
  return s:get_oneof(mappings)

endfunction
imap <M-o> =<SID>Exp_Map_Mo()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Tags
nmap <M-]> :call matlab#tags#auto_tags()
" Search where current file script/function is called in matlab environment
nmap g<M-]> :call matlab#tags#call()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Others
"-------------------------------------------------------------------------------
imap <buffer> <M-/> f"a,
imap <buffer> <M-[> []<Left>
imap <buffer> <M-{> {}<Left>
imap <buffer> <M-.> ->
imap <buffer> <M-=> <space>=<space>
imap <buffer> <C-CR> A;







