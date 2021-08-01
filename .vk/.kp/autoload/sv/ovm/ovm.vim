if !exists('ovm_tx_class_name')
  let ovm_tx_class_name = ""
endif

"-------------------------------------------------------------------------------
" OVM Sequence Item
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#sequence_item(name)
  " Block Comment
  let l:sequence_item = comments#block_comment#getComments("CLASS", "" . a:name )
  let l:sequence_item .= sv#sv#sv#class(a:name,'ovm_sequence_item')
  let l:sequence_item .= '`ovm_object_utils_begin(' . a:name . ')
                          \  
                          \`ovm_object_utils_end'
  let l:sequence_item .= sv#sv#sv#function('new', '', 'string name = "' . a:name . '"', 'new: CONSTRUCTOR')
  let l:sequence_item .= 'super.new(name);`ca'
  return l:sequence_item
endfun

"-------------------------------------------------------------------------------
" OVM Sequence
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#sequence(name)
  " Block Comment
  let l:sequence = comments#block_comment#getComments("CLASS", "" . a:name )
  let l:sequence .= sv#sv#sv#class(a:name,'ovm_sequence #(' . g:ovm_tx_class_name . ')')
  let l:sequence .= '`ovm_sequence_utils(' . a:name . ', )'
  let l:sequence .= sv#sv#sv#function('new', '', 'string name = "' . a:name . '"', 'new: CONSTRUCTOR')
  let l:sequence .= 'super.new(name);`ba'

  " body: task
  let l:sequence .= sv#sv#sv#task('body', '', 'body: TASK')
  let l:sequence .= '`ba`ca'

  return l:sequence
endfun

"-------------------------------------------------------------------------------
" OVM Sequence Item
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#object(name)
  " Block Comment
  let l:object = comments#block_comment#getComments("CLASS", "" . a:name )
  let l:object .= sv#sv#sv#class(a:name,'ovm_object')
  let l:object .= '`ovm_object_utils_begin(' . a:name . ')
                          \  
                          \`ovm_object_utils_end'
  let l:object .= sv#sv#sv#function('new', '', 'string name = "' . a:name . '"', 'new: CONSTRUCTOR')
  let l:object .= 'super.new(name);`ca'
  return l:object
endfun

"-------------------------------------------------------------------------------
" OVM Driver
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#driver(name)
  " Block Comment
  let l:driver = comments#block_comment#getComments("CLASS", "" . a:name )
  let l:driver .= sv#sv#sv#class(a:name,'ovm_driver #(' . g:ovm_tx_class_name . ')')
  let l:driver .= '`ovm_component_utils_begin(' . a:name . ')
                          \  
                          \`ovm_component_utils_end'

  " new: Constructor
  let l:driver .= sv#sv#sv#function('new', '', 'string name = "' . a:name . '", ovm_component parent', 'new: CONSTRUCTOR')
  let l:driver .= 'super.new(name, parent);`ba'

  " build: function
  let l:driver .= sv#sv#sv#function('build', 'void', '', 'build: FUNCTION')
  let l:driver .= 'super.build();`ba'

  " run: task
  let l:driver .= sv#sv#sv#task('run', '', 'run: TASK')
  let l:driver .= '`ba`ca'
  return l:driver
endfun

"-------------------------------------------------------------------------------
" OVM Scoreboard
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#scoreboard(name)
  " Block Comment
  let l:scoreboard = comments#block_comment#getComments("CLASS", "" . a:name )
  let l:scoreboard .= sv#sv#sv#class(a:name,'ovm_scoreboard')
  let l:scoreboard .= 'ovm_analysis_imp #(' . g:ovm_tx_class_name . ', ' . a:name . ') item_collected_export;'
  let l:scoreboard .= '`ovm_component_utils_begin(' . a:name . ')
                          \  
                          \`ovm_component_utils_end'

  " new: Constructor
  let l:scoreboard .= sv#sv#sv#function('new', '', 'string name = "' . a:name . '", ovm_component parent', 'new: CONSTRUCTOR')
  let l:scoreboard .= 'super.new(name, parent);`ba'

  " build: function
  let l:scoreboard .= sv#sv#sv#function('build', 'void', '', 'build: FUNCTION')
  let l:scoreboard .= 'super.build();`ba'

  " report: function
  let l:scoreboard .= sv#sv#sv#function('report', 'void', '', 'report: FUNCTION', 'virtual')
  let l:scoreboard .= '`ba'

  " write: function
  let l:scoreboard .=  sv#sv#sv#function('write', 'void', g:ovm_tx_class_name . ' trans', 'write: FUNCTION', 'virtual')
  let l:scoreboard .= '`ba'

  " compare: function
  let l:scoreboard .=  sv#sv#sv#function('compare', 'void', '', 'compare: FUNCTION', 'protected')
  let l:scoreboard .= '`ba'

  return l:scoreboard
endfun

"-------------------------------------------------------------------------------
" OVM Environment
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#env(name)
  " Block Comment
  let l:env = comments#block_comment#getComments("CLASS", "" . a:name )
  let l:env .= sv#sv#sv#class(a:name,'ovm_env')
  let l:env .= '`ovm_component_utils_begin(' . a:name . ')
                          \  
                          \`ovm_component_utils_end'

  " new: Constructor
  let l:env .= sv#sv#sv#function('new', '', 'string name = "' . a:name . '", ovm_component parent', 'new: CONSTRUCTOR')
  let l:env .= 'super.new(name, parent);`ba'

  " build: function
  let l:env .= sv#sv#sv#function('build', 'void', '', 'build: FUNCTION')
  let l:env .= 'super.build();`ba'

  return l:env
endfun

"-------------------------------------------------------------------------------
" OVM Agent
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#agent(name)
  " Block Comment
  let l:agent = comments#block_comment#getComments("CLASS", "" . a:name )
  let l:agent .= sv#sv#sv#class(a:name,'ovm_agent')
  let l:agent .= '`ovm_component_utils(' . a:name . ')'

  " new: Constructor
  let l:agent .= sv#sv#sv#function('new', '', 'string name = "' . a:name . '", ovm_component parent', 'new: CONSTRUCTOR')
  let l:agent .= 'super.new(name, parent);`ba'

  " build: function
  let l:agent .= sv#sv#sv#function('build', 'void', '', 'build: FUNCTION')
  let l:agent .= 'super.build();`ba'

  " run: task
  let l:agent .= sv#sv#sv#function('connect', 'void', '', 'connect: FUNCTION')
  let l:agent .= 'super.connect();`ba`ca'
  return l:agent
endfun

"-------------------------------------------------------------------------------
" OVM Component
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#component(name)
  " Block Comment
  let l:component = comments#block_comment#getComments("CLASS", "" . a:name)
  let l:component .= sv#sv#sv#class(a:name,'ovm_component')
  let l:component .= '`ovm_component_utils(' . a:name . ')'

  " new: Constructor
  let l:component .= sv#sv#sv#function('new', '', 'string name = "' . a:name . '", ovm_component parent', 'new: CONSTRUCTOR')
  let l:component .= 'super.new(name, parent);`ba'

  " build: function
  let l:component .= sv#sv#sv#function('build', 'void', '', 'build: FUNCTION')
  let l:component .= 'super.build();`ba'

  " run: task
  let l:component .= sv#sv#sv#function('connect', 'void', '', 'connect: FUNCTION')
  let l:component .= 'super.connect();`ba`ca'
  return l:component
endfun

"-------------------------------------------------------------------------------
" OVM Callback
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#callback(name)
  " Block Comment
  let l:component = comments#block_comment#getComments("CLASS", "" . a:name)
  let l:component .= sv#sv#sv#class(a:name,'ovm_callback')

  " new: Constructor
  let l:component .= sv#sv#sv#function('new', '', 'string name = "' . a:name . '"')
  let l:component .= 'super.new(name, parent);`ba'

  return l:component
endfun

"-------------------------------------------------------------------------------
" OVM Sequencer
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#sequencer(name)
  " Block Comment
  let l:sequence_item = comments#block_comment#getComments("CLASS", "" . a:name )
  let l:sequence_item .= sv#sv#sv#class(a:name,'ovm_sequencer #(' . g:ovm_tx_class_name . ')')
  let l:sequence_item .= '`ovm_sequencer_utils_begin(' . a:name . ')
                          \  
                          \`ovm_component_utils_end'

  " new: Constructor
  let l:sequence_item .= sv#sv#sv#function('new', '', 'string name = "' . a:name . '", ovm_component parent', 'new: CONSTRUCTOR')
  let l:sequence_item .= 'super.new(name, parent);'
  let l:sequence_item .= '`ovm_update_sequence_lib_and_item(' . g:ovm_tx_class_name . ')`ba`ca'

  return l:sequence_item
endfun

"-------------------------------------------------------------------------------
" type_id::create
"-------------------------------------------------------------------------------
function! sv#ovm#ovm#type_id_create()
  " find search start & end
  let l:s_start =  search('^\s*\w\+\%(\s*#(\_[[:alnum:]_, ]\+)\)\?\_[[:alnum:]_, ]\+\<' .
                   \         matchstr(getline("."), '^\s*\zs\w\+') .
                   \         '\>\_[[:alnum:]_, ]*;$', 'bn')

  let l:s_end   =  search('^\s*\w\+\%(\s*#(\_[[:alnum:]_, ]\+)\)\?\_[[:alnum:]_, ]\+\<' .
                   \         matchstr(getline("."), '^\s*\zs\w\+') .
                   \         '\>\_[[:alnum:]_, ]*;$', 'ben')

  let l:curr_pos = col('.') - indent(l:s_start) + indent(l:s_end) - 1

  " get the class type name
  let l:type_name = matchstr(
                   \ join (
                   \ map(
                   \ getline(
                   \  l:s_start,
                   \  l:s_end
                   \ ), 'substitute(v:val, "^\\s\\+", "", "")'
                   \ ), "\n" . repeat(' ', l:curr_pos)),
                   \ '^\s*\zs\w\+\%(\s*#(\_[[:alnum:]_, ]\+)\)\?'
                   \)
  let l:type_name = substitute(l:type_name, "\n", "\na", "g")
  let l:str = l:type_name . '::type_id::create("' . matchstr(l:type_name, '\w\+') . '", this);'
  return l:str
endfunction

"===============================================================================
" Macros
"===============================================================================

"-------------------------------------------------------------------------------
" `ovm_component_utils_begin
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#component_utils_begin()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`ovm_component_utils_begin(' . l:component . ')'
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .=   '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= '  maa'
  let l:str .= '`ovm_component_utils_end`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `ovm_component_param_utils_begin
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#component_param_utils_begin()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`ovm_component_param_utils_begin(' . l:component . ')'
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .=   '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= '  maa'
  let l:str .= '`ovm_component_utils_end`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `ovm_component_utils
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#component_utils()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`ovm_component_utils(' . l:component . ')'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `ovm_component_param_utils
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#component_param_utils()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`ovm_component_param_utils(' . l:component . ')'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `ovm_object_utils_begin-end
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#object_utils_begin()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`ovm_object_utils_begin(' . l:component . ')'
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .= '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= '  maa'
  let l:str .= '`ovm_object_utils_end`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `ovm_object_param_utils_begin-end
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#object_param_utils_begin()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`ovm_object_param_utils_begin(' . l:component . ')'
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .= '  // data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= '  maa'
  let l:str .= '`ovm_object_utils_end`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `ovm_object_utils
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#object_utils()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`ovm_object_utils(' . l:component . ')'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `ovm_object_param_utils
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#object_utils()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`ovm_object_param_utils(' . l:component . ')'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `ovm_field_utils_begin
"-------------------------------------------------------------------------------
fun! sv#ovm#ovm#field_utils_begin()
  let l:str = '`ovm_field_utils_begin(mca)'
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .=   '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= '  maa'
  let l:str .= '`ovm_field_utils_end`ca'
  return l:str
endfun

" ==============================================================================
" System function
" ==============================================================================
" TBD
