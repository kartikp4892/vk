
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
" Exp_Map_M2: Function
" Pointers or vectors
function! s:Exp_Map_M2()
  let mappings = {}
  let mappings['\v^s%[tring]$'] = {'abbr': 'const char*', 'map': 'const char* '}
  let mappings['\v^v%[oid]$'] = {'abbr': 'void* ', 'map': 'void* '}
  let mappings['\v^v%[ector]$'] = {'abbr': 'vector ', 'map': '=cpp#cpp#vector()'}
  let mappings['\v^p%[ointer]$'] = {'abbr': 'pointer ', 'map': '*maa = NULL;`aa'}
  let mappings['\v^s%[ize]$'] = {'abbr': 'vector->size', 'map': 'size()'}
  let mappings['\v^m%[ax]s%[ize]$'] = {'abbr': 'vector->max_size', 'map': 'max_size()'}
  let mappings['\v^r%[e]s%[ize]$'] = {'abbr': 'vector->resize', 'map': 'resize()'}
  let mappings['\v^c%[apacity]$'] = {'abbr': 'vector->capacity', 'map': 'capacity()'}
  let mappings['\v^e%[mpty]$'] = {'abbr': 'vector->empty', 'map': 'empty()'}
  let mappings['\v^r%[everse]$'] = {'abbr': 'vector->reverse', 'map': 'reverse()'}
  let mappings['\v^s%[hrink]t%[o]f%[it]$'] = {'abbr': 'vector->shrink_to_fit', 'map': 'shrink_to_fit()'}
  let mappings['\v^o%[perator]$'] = {'abbr': 'vector->operator', 'map': 'operator()'}
  let mappings['\v^a%[t]$'] = {'abbr': 'vector->at', 'map': 'at()'}
  let mappings['\v^f%[ront]$'] = {'abbr': 'vector->front', 'map': 'front()'}
  let mappings['\v^b%[ack]$'] = {'abbr': 'vector->back', 'map': 'back()'}
  let mappings['\v^d%[ata]$'] = {'abbr': 'vector->data', 'map': 'data()'}
  let mappings['\v^a%[ssign]$'] = {'abbr': 'vector->assign', 'map': 'assign()'}
  let mappings['\v^p%[ush]b%[ack]$'] = {'abbr': 'vector->push_back', 'map': 'push_back()'}
  let mappings['\v^p%[op]b%[ack]$'] = {'abbr': 'vector->pop_back', 'map': 'pop_back()'}
  let mappings['\v^i%[nsert]$'] = {'abbr': 'vector->insert', 'map': 'insert()'}
  let mappings['\v^e%[rase]$'] = {'abbr': 'vector->erase', 'map': 'erase()'}
  let mappings['\v^s%[wap]$'] = {'abbr': 'vector->swap', 'map': 'swap()'}
  let mappings['\v^c%[lear]$'] = {'abbr': 'vector->clear', 'map': 'clear()'}
  let mappings['\v^e%[mplace]$'] = {'abbr': 'vector->emplace', 'map': 'emplace()'}
  let mappings['\v^e%[mplace]b%[ack]$'] = {'abbr': 'vector->emplace', 'map': 'emplace_back()'}
  let mappings['\v^g%[et]a%[llocator]$'] = {'abbr': 'vector->get_allocator', 'map': 'get_allocator()'}

  let mappings['\v^i%[terator]$'] = {'abbr': 'vector->iterator', 'map': 'vector<%s>::iterator it'}
  let mappings['\v^r%[everse]i%[terator]$'] = {'abbr': 'vector->reverse_iterator', 'map': 'vector<%s>::reverse_iterator it'}
  let mappings['\v^f%[or]i%[nc]$'] = {'abbr': 'for ++', 'map': '=cpp#cpp#vector_iterator_for_inc()'}
  let mappings['\v^f%[or]d%[ec]$'] = {'abbr': 'for --', 'map': '=cpp#cpp#vector_iterator_for_dec()'}

  " Initializer_list
  let mappings['\v^i%[nitializer]l%[ist]$'] = {'abbr': 'initializer_list', 'map': '=cpp#cpp#initializer_list()'}

  let mapping = s:get_matched(mappings)

  if (mapping != '')
    return mapping
  endif

  " Default
  return s:get_oneof(mappings)
endfunction
imap <M-2> =<SID>Exp_Map_M2()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_M4: Function
" Pointers
function! s:Exp_Map_M4()
  let mappings = {}
  let mappings['\v^s%[tring]$'] = {'abbr': 'string', 'map': 'string '}

  let mapping = s:get_matched(mappings)

  if (mapping != '')
    return mapping
  endif

  " Default
  return s:get_oneof(mappings)

endfunction
imap <M-4> =<SID>Exp_Map_M4()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_M5: Function
" Associtive array map, pair, iterator
function! s:Exp_Map_M5()
  let mappings = {}
  let mappings['\v^m%[ap]$'] = {'abbr': 'map', 'map': '=cpp#cpp#map()'}
  let mappings['\v^f%[ind]$'] = {'abbr': 'find', 'map': printf('auto it = %s.find(maa)`aa', s:GetTemplete('a', 'name'))}
  let mappings['\v^s%[ize]$'] = {'abbr': 'size', 'map': 'size()'}
  let mappings['\v^i%[terator]$'] = {'abbr': 'iterator', 'map': printf('map<maa%s, %s>::iterator %s;`aa', s:GetTemplete('a', 'key'), s:GetTemplete('a', 'value'), s:GetTemplete('a', '/it'))}
  let mappings['\v^e%[rase]$'] = {'abbr': 'erase', 'map': 'erase(maa)`aa'}
  let mappings['\v^r%[everse]i%[terator]$'] = {'abbr': 'reverse_iterator', 'map': printf('map<maa%s, %s>::reverse_iterator %s;`aa', s:GetTemplete('a', 'key'), s:GetTemplete('a', 'value'), s:GetTemplete('a', '/it'))}
  let mappings['\v^v%[alue]t%[ype]$'] = {'abbr': 'value_type', 'map': printf('map<maa%s, %s>::value_type(%s, %s);`aa', s:GetTemplete('a', 'key'), s:GetTemplete('a', 'value'), s:GetTemplete('a', 'k'), s:GetTemplete('a', 'v'))}
  let mappings['\v^f%[irst]$'] = {'abbr': 'first', 'map': '->first'}
  let mappings['\v^s%[econd]$'] = {'abbr': 'second', 'map': '->second'}
  let mappings['\v^f%[or]i%[nc]$'] = {'abbr': 'for ++', 'map': '=cpp#cpp#map_iterator_for_inc()'}
  let mappings['\v^f%[or]d%[ec]$'] = {'abbr': 'for --', 'map': '=cpp#cpp#map_iterator_for_dec()'}

  let mappings['\v^m%[ulti]%[map]$'] = {'abbr': 'multimap', 'map': '=cpp#cpp#multimap()'}
  let mappings['\v^m%[ulti]%[map]e%[qual]r%[ange]$'] = {'abbr': 'multimap equal_range', 'map': printf('equal_range(maa%s)`aa', s:GetTemplete('a', 'key'))}
  let mappings['\v^m%[ulti]%[map]f%[or]i%[nc]$'] = {'abbr': 'multimap for ++', 'map': '=cpp#cpp#multimap_iterator_for_inc()'}
  let mappings['\v^m%[ulti]%[map]f%[or]d%[ec]$'] = {'abbr': 'multimap for --', 'map': '=cpp#cpp#multimap_iterator_for_dec()'}
  let mappings['\v^m%[ulti]%[map]f%[or]r%[ange]$'] = {'abbr': 'multimap for range', 'map': '=cpp#cpp#multimap_iterator_for_range()'}

  let mapping = s:get_matched(mappings)

  if (mapping != '')
    return mapping
  endif

  " Default
  return s:get_oneof(mappings)

  " return s:get_oneof(mappings)

endfunction

imap <M-5> =<SID>Exp_Map_M5()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mi: Function
" Iterator
function! s:Exp_Map_Mi()
  let mappings = {}
  let mappings['\v^b%[egin]$'] = {'abbr': 'begin', 'map': 'begin()'}
  let mappings['\v^e%[nd]$'] = {'abbr': 'end', 'map': 'end()'}
  let mappings['\v^rb%[egin]$'] = {'abbr': 'rbegin', 'map': 'rbegin()'}
  let mappings['\v^re%[nd]$'] = {'abbr': 'rend', 'map': 'rend()'}

  let mappings['\v^cb%[egin]$'] = {'abbr': 'begin', 'map': 'cbegin()'}
  let mappings['\v^ce%[nd]$'] = {'abbr': 'end', 'map': 'cend()'}
  let mappings['\v^crb%[egin]$'] = {'abbr': 'rbegin', 'map': 'crbegin()'}
  let mappings['\v^cre%[nd]$'] = {'abbr': 'rend', 'map': 'crend()'}

  let mapping = s:get_matched(mappings)

  if (mapping != '')
    return mapping
  endif

  " Default
  return s:get_oneof(mappings)

endfunction
imap <M-i> =<SID>Exp_Map_Mi()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Ml: Function
function! s:Exp_Map_Ml()
  let mappings = {}
  let mappings['\v^%[main]$'] = {'abbr': 'main', 'map': '=cpp#cpp#main()'}
  let mappings['\v^s%[q]%[lite3]$'] = {'abbr': '#include <sqlite3.h>', 'map': '#include <sqlite3.h>'}
  let mappings['\v^s%[td]%[lib]$'] = {'abbr': '#include <stdlib.h>', 'map': '#include <stdlib.h>'}

  let mapping = s:get_matched(mappings)

  if (mapping != '')
    return mapping
  endif

  " Default
  return s:get_oneof(mappings)

endfunction
imap <M-l> =<SID>Exp_Map_Ml()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mo: Function
" OOPS
function! s:Exp_Map_Mo()
  let mappings = {}
  let mappings['\v^c%[lass]$'] = {'abbr': 'class', 'map': '=cpp#oops#class()'}
  let mappings['\v^c%[lass]e%[xtended]$'] = {'abbr': 'extended class', 'map': '=cpp#oops#class_extended()'}
  let mappings['\v^o%[perator]o%[verloading]$'] = {'abbr': 'Operator Overloading', 'map': '=cpp#oops#operator_overloading()'}
  let mappings['\v^f%[unction]$'] = {'abbr': 'function', 'map': '=cpp#oops#function()'}
  let mappings['\v^p%[ublic]$'] = {'abbr': 'public', 'map': 'public:  '}
  let mappings['\v^p%[rivate]$'] = {'abbr': 'private', 'map': 'private:  '}
  let mappings['\v^p%[rotected]$'] = {'abbr': 'protected', 'map': 'protected:  '}

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
" Exp_Map_Mf: Function
" OOPS
function! s:Exp_Map_Mf()
  let mappings = {}
  let mappings['\v^o%[ut]%[file]o%[pen]$'] = {'abbr': 'out file open', 'map': '=cpp#fileio#ofstream_open()'}
  let mappings['\v^i%[n]%[file]o%[pen]$'] = {'abbr': 'in file open', 'map': '=cpp#fileio#ifstream_open()'}
  let mappings['\v^%[file]c%[lose]$'] = {'abbr': 'file close', 'map': 'close();'}

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
" Exp_Map_Mj: Function
function! s:Exp_Map_Mj()
  let mappings = {}
  let mappings['\v^f%[or]i%[ncr]$'] = {'abbr': 'for++', 'map': '=cpp#cpp#for_incr()'}
  let mappings['\v^f%[or]d%[ecr]$'] = {'abbr': 'for--', 'map': '=cpp#cpp#for_decr()'}
  let mappings['\v^f%[or]%[each]$'] = {'abbr': 'foreach', 'map': '=cpp#cpp#foreach()'}
  let mappings['\v^w%[hile]$'] = {'abbr': 'while', 'map': '=cpp#cpp#while()'}
  let mappings['\v^d%[o]w%[hile]$'] = {'abbr': 'do while', 'map': '=cpp#cpp#do_while()'}
  let mappings['\v^s%[truct]$'] = {'abbr': 'struct', 'map': '=cpp#cpp#struct()'}
  let mappings['\v^u%[nion]$'] = {'abbr': 'union', 'map': '=cpp#cpp#union()'}
  let mappings['\v^f%[unction]$'] = {'abbr': 'function', 'map': '=cpp#cpp#function()'}
  let mappings['\v^t%[emplate]$'] = {'abbr': 'template', 'map': '=cpp#cpp#template()'}
  let mappings['\v^n%[ame]s%[pace]$'] = {'abbr': 'namespace', 'map': 'using namespace '}
  let mappings['\v^i%[f]$'] = {'abbr': 'if', 'map': '=cpp#cpp#if()'}
  let mappings['\v^e%[lse]%[i]f$'] = {'abbr': 'elseif', 'map': '=cpp#cpp#elseif()'}
  let mappings['\v^e%[lse]$'] = {'abbr': 'else', 'map': '=cpp#cpp#else()'}
  let mappings['\v^c%[ase]$'] = {'abbr': 'case', 'map': '=cpp#cpp#case()'}

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
" Exp_Map_Me: Function
function! s:Exp_Map_Me()
  let mappings = {}
  let mappings['\v^t%[ry]c%[atch]$'] = {'abbr': 'try catch', 'map': '=cpp#exception#try_catch()'}
  let mappings['\v^c%[atch]$'] = {'abbr': 'catch', 'map': '=cpp#exception#catch()'}
  let mappings['\v^e%[xception]$'] = {'abbr': 'exception', 'map': '=cpp#exception#exception()'}

  let mapping = s:get_matched(mappings)

  if (mapping != '')
    return mapping
  endif

  " Default
  return s:get_oneof(mappings)

endfunction
imap <M-e> =<SID>Exp_Map_Me()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Others
"-------------------------------------------------------------------------------
imap <buffer> <M-/> f"a,
imap <buffer> <M-[> []<Left>
imap <buffer> <M-{> {}<Left>
imap <buffer> <M-.> ->
imap <buffer> <M-=> <space>=
imap <buffer> <C-CR> A;







