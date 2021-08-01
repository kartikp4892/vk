"===============================================================================
" Macros
"===============================================================================

"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" `uvm_component_utils_begin
"-------------------------------------------------------------------------------
fun! sv#uvm#uvm_macros#component_utils_begin()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`uvm_component_utils_begin(' . l:component . ')'
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .=   '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= '  maa'
  let l:str .= '`uvm_component_utils_end`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `uvm_component_param_utils_begin
"-------------------------------------------------------------------------------
fun! sv#uvm#uvm_macros#component_param_utils_begin()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`uvm_component_param_utils_begin(' . l:component . ')'
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .=   '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= '  maa'
  let l:str .= '`uvm_component_utils_end`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `uvm_component_utils
"-------------------------------------------------------------------------------
fun! sv#uvm#uvm_macros#component_utils()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`uvm_component_utils(' . l:component . ')'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `uvm_component_param_utils
"-------------------------------------------------------------------------------
fun! sv#uvm#uvm_macros#component_param_utils()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`uvm_component_param_utils(' . l:component . ')'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `uvm_object_utils_begin-end
"-------------------------------------------------------------------------------
fun! sv#uvm#uvm_macros#object_utils_begin()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`uvm_object_utils_begin(' . l:component . ')'
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .= '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= '  maa'
  let l:str .= '`uvm_object_utils_end`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `uvm_object_param_utils_begin-end
"-------------------------------------------------------------------------------
fun! sv#uvm#uvm_macros#object_param_utils_begin()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`uvm_object_param_utils_begin(' . l:component . ')'
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .= '  // data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= '  maa'
  let l:str .= '`uvm_object_utils_end`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `uvm_object_utils
"-------------------------------------------------------------------------------
fun! sv#uvm#uvm_macros#object_utils()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`uvm_object_utils(' . l:component . ')'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `uvm_object_param_utils
"-------------------------------------------------------------------------------
fun! sv#uvm#uvm_macros#object_utils()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let l:str = '// The utility macro to provide implementations of virtual methods such as get_type_name and create'
  let l:str .= '`uvm_object_param_utils(' . l:component . ')'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `uvm_field_utils_begin
"-------------------------------------------------------------------------------
fun! sv#uvm#uvm_macros#field_utils_begin()
  let l:str = '`uvm_field_utils_begin (mca)'
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .=   '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= '  maa'
  let l:str .= '`uvm_field_utils_end`ca'
  return l:str
endfun

"===============================================================================
" Fields
"===============================================================================
"-------------------------------------------------------------------------------
" `uvm_field_int
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_int()
  let l:str = '// Implement the data operations for the packed integral property.'
  let l:str .= '`uvm_field_int (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_object
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_object()
  "let l:str = '//Implements the data operations for an uvm_object-based property.'
  let l:str = ''
  let l:str .= '`uvm_field_object (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_string
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_string()
  "let l:str = '//Implements the data operations for a string property.'
  let l:str = ''
  let l:str .= '`uvm_field_string (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_enum
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_enum()
  "let l:str = '//Implements the data operations for an enumerated property.'
  let l:str = ''
  let l:str = printf('`uvm_field_enum (maa%s, %s, UVM_ALL_ON)`aa', s:GetTemplete("a", "enum_type"), s:GetTemplete("b", "var"))
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_real
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_real()
  "let l:str = '//Implements the data operations for any real property.'
  let l:str = ''
  let l:str .= '`uvm_field_real (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_event
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_event()
  "let l:str = '//Implements the data operations for an event property.'
  let l:str = ''
  let l:str .= '`uvm_field_event (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_sarray_int
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_sarray_int()
  "let l:str = '//Implements the data operations for a one-dimensional static array of integrals.'
  let l:str = ''
  let l:str .= '`uvm_field_sarray_int (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_sarray_object
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_sarray_object()
  "let l:str = '//Implements the data operations for a one-dimensional static array of uvm_object-based objects.'
  let l:str = ''
  let l:str .= '`uvm_field_sarray_object (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_sarray_string
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_sarray_string()
  "let l:str = '//Implements the data operations for a one-dimensional static array of strings.'
  let l:str = ''
  let l:str .= '`uvm_field_sarray_string (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_sarray_enum
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_sarray_enum()
  "let l:str = '//Implements the data operations for a one-dimensional static array of enums.'
  let l:str = ''
  let l:str .= '`uvm_field_sarray_enum (maa, UVM_ALL_ON)`aa'
  let l:str = printf('`uvm_field_sarray_enum (maa%s, %s, UVM_ALL_ON)`aa', s:GetTemplete("a", "enum_type"), s:GetTemplete("b", "var"))
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_array_int
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_array_int()
  "let l:str = '//Implements the data operations for a one-dimensional dynamic array of integrals.'
  let l:str = ''
  let l:str .= '`uvm_field_array_int (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_array_object
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_array_object()
  "let l:str = '//Implements the data operations for a one-dimensional dynamic array of uvm_object-based objects.'
  let l:str = ''
  let l:str .= '`uvm_field_array_object (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_array_string
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_array_string()
  "let l:str = '//Implements the data operations for a one-dimensional dynamic array of strings.'
  let l:str = ''
  let l:str .= '`uvm_field_array_string (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_array_enum
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_array_enum()
  "let l:str = '//Implements the data operations for a one-dimensional dynamic array of enums.'
  let l:str = ''
  let l:str = printf('`uvm_field_array_enum (maa%s, %s, UVM_ALL_ON)`aa', s:GetTemplete("a", "enum_type"), s:GetTemplete("b", "var"))
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_queue_int
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_queue_int()
  "let l:str = '//Implements the data operations for a queue of integrals.'
  let l:str = ''
  let l:str .= '`uvm_field_queue_int (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_queue_object
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_queue_object()
  "let l:str = '//Implements the data operations for a queue of uvm_object-based objects.'
  let l:str = ''
  let l:str .= '`uvm_field_queue_object (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_queue_string
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_queue_string()
  "let l:str = '//Implements the data operations for a queue of strings.'
  let l:str = ''
  let l:str .= '`uvm_field_queue_string (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_queue_enum
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_queue_enum()
  "let l:str = '//Implements the data operations for a one-dimensional queue of enums.'
  let l:str = ''
  let l:str .= '`uvm_field_queue_enum (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_string
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_string()
  "let l:str = '//Implements the data operations for an associative array of integrals indexed by string.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_string (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_object_string
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_object_string()
  "let l:str = '//Implements the data operations for an associative array of uvm_object-based objects indexed by string.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_object_string (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_string_string
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_string_string()
  "let l:str = '//Implements the data operations for an associative array of strings indexed by string.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_string_string (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_object_int
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_object_int()
  "let l:str = '//Implements the data operations for an associative array of uvm_object-based objects indexed by the int data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_object_int (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_int
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_int()
  "let l:str = '//Implements the data operations for an associative array of integral types indexed by the int data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_int (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_int_unsigned
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_int_unsigned()
  "let l:str = '//Implements the data operations for an associative array of integral types indexed by the int unsigned data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_int_unsigned (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_integer
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_integer()
  "let l:str = '//Implements the data operations for an associative array of integral types indexed by the integer data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_integer (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_integer_unsigned
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_integer_unsigned()
  "let l:str = '//Implements the data operations for an associative array of integral types indexed by the integer unsigned data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_integer_unsigned (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_byte
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_byte()
  "let l:str = '//Implements the data operations for an associative array of integral types indexed by the byte data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_byte (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_byte_unsigned
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_byte_unsigned()
  "let l:str = '//Implements the data operations for an associative array of integral types indexed by the byte unsigned data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_byte_unsigned (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_shortint
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_shortint()
  "let l:str = '//Implements the data operations for an associative array of integral types indexed by the shortint data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_shortint (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_shortint_unsigned
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_shortint_unsigned()
  "let l:str = '//Implements the data operations for an associative array of integral types indexed by the shortint unsigned data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_shortint_unsigned (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_longint
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_longint()
  "let l:str = '//Implements the data operations for an associative array of integral types indexed by the longint data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_longint (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_longint_unsigned
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_longint_unsigned()
  "let l:str = '//Implements the data operations for an associative array of integral types indexed by the longint unsigned data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_longint_unsigned (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_key
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_key()
  "let l:str = '//Implements the data operations for an associative array of integral types indexed by any integral key data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_key (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_field_aa_int_enumkey
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_macros#field_aa_int_enumkey()
  "let l:str = '//Implements the data operations for an associative array of integral types indexed by any enumeration key data type.'
  let l:str = ''
  let l:str .= '`uvm_field_aa_int_enumkey (maa, UVM_ALL_ON)`aa'
  return l:str
endfunction

"===============================================================================
" Sequence & Action Macros
"===============================================================================
"-------------------------------------------------------------------------------
" `uvm_declare_p_sequencer
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#declare_p_sequencer()
  let l:str = ""
  let l:str .= "// set up the sequencer type with this sequence type. "
  let l:str .= "`uvm_declare_p_sequencer (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_sequence_utils_begin
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#sequence_utils_begin()
  " Get the sequence name
  let l:seq_name = matchstr(getline(search('^[[:alnum:]_ ]*\<class\>', 'nb')), '\<class\s\+\zs\w\+')

  let l:str = ""
  let l:str .= "// pre-register the sequence with a given <uvm_sequencer> type."
  let l:str .= "`uvm_sequence_utils_begin(" . l:seq_name . ", maa)"
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .=   '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= "  "
  let l:str .= '`uvm_field_utils_end`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_sequence_utils
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#sequence_utils()
  " Get the sequence name
  let l:seq_name = matchstr(getline(search('^[[:alnum:]_ ]*\<class\>', 'nb')), '\<class\s\+\zs\w\+')
  let l:str = ""
  let l:str .= "// pre-register the sequence with a given <uvm_sequencer> type."
  let l:str .= "`uvm_sequence_utils(" . l:seq_name . ", maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_update_sequence_lib
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#update_sequence_lib()
  let l:str = ""
  let l:str .= "// populate the instance-specific sequence library for a sequencer. "
  let l:str .= "`uvm_update_sequence_lib (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_update_sequence_lib_and_item
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#update_sequence_lib_and_item()
  let l:str = ""
  let l:str .= "// populate the instance specific sequence library for a sequencer, and" .
               \"// register the given USER_ITEM as an instance override for the simple sequence’s item variable."
  let l:str .= "`uvm_update_sequence_lib_and_item (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_sequencer_utils
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#sequencer_utils()
  " Get the sequence name
  let l:seq_name = matchstr(getline(search('^[[:alnum:]_ ]*\<class\>', 'nb')), '\<class\s\+\zs\w\+')
  let l:str = ""
  let l:str .= "// declare the plumbing necessary for creating the sequencer’s sequence library"
  let l:str .= "`uvm_sequencer_utils(" . l:seq_name . ")"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_sequencer_utils_begin
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#sequencer_utils_begin()
  " Get the sequence name
  let l:seq_name = matchstr(getline(search('^[[:alnum:]_ ]*\<class\>', 'nb')), '\<class\s\+\zs\w\+')
  let l:str = ""
  let l:str .= "// declare the plumbing necessary for creating the sequencer’s sequence library"
  let l:str .= "`uvm_sequencer_utils_begin(" . l:seq_name . ")"
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .=   '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= "  maa"
  let l:str .= '`uvm_field_utils_end`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_sequencer_param_utils
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#sequencer_param_utils()
  " Get the sequence name
  let l:seq_name = matchstr(getline(search('^[[:alnum:]_ ]*\<class\>', 'nb')), '\<class\s\+\zs\w\+')
  let l:str = ""
  let l:str .= "// declare the plumbing necessary for creating the sequencer’s sequence library"
  let l:str .= "`uvm_sequencer_param_utils(" . l:seq_name . ")"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_sequencer_param_utils_begin
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#sequencer_param_utils_begin()
  " Get the sequence name
  let l:seq_name = matchstr(getline(search('^[[:alnum:]_ ]*\<class\>', 'nb')), '\<class\s\+\zs\w\+')
  let l:str = ""
  let l:str .= "// declare the plumbing necessary for creating the sequencer’s sequence library"
  let l:str .= "`uvm_sequencer_param_utils_begin(" . l:seq_name . ")"
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .=   '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= "  maa"
  let l:str .= '`uvm_field_utils_end`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_create
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#create()
  let l:str = ""
  let l:str .= "// create the item or sequence using the factory. "
  let l:str .= "`uvm_create (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_do
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#do()
  let l:str = ""
  let l:str .= "// randomize uvm_sequence_item at the time the sequencer grants the do request. (late-randomization or late-generation)"
  let l:str .= "`uvm_do (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_do_pri
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#do_pri()
  let l:str = ""
  let l:str .= "//  execute sequene item or sequence with the priority specified in the argument"
  let l:str .= "`uvm_do_pri (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_do_with
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#do_with()
  let l:str = ""
  let l:str .= "// apply constraint block to the item or sequence in a randomize with statement before execution."
  let l:str .= "`uvm_do_with (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_do_pri_with
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#do_pri_with()
  let l:str = ""
  let l:str .= "// apply constraint block to the item or sequence in a randomize with statement before execution"
  let l:str .= "`uvm_do_pri_with (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_send
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#send()
  let l:str = ""
  let l:str .= "// process the item or sequence that has been created using `uvm_create."
  let l:str .= "`uvm_send (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_send_pri
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#send_pri()
  let l:str = ""
  let l:str .= "// execute sequene item or sequence with the priority specified in the argument."
  let l:str .= "`uvm_send_pri (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_rand_send
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#rand_send()
  let l:str = ""
  let l:str .= "// process the item or sequence that has been already been allocated (possibly with `uvm_create)."
  let l:str .= "`uvm_rand_send (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_rand_send_pri
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#rand_send_pri()
  let l:str = ""
  let l:str .= "// execute the sequene item or sequence with the priority specified in the argument."
  let l:str .= "`uvm_rand_send_pri (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_rand_send_with
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#rand_send_with()
  let l:str = ""
  let l:str .= "// apply given constraint block to the item or sequence in a randomize with statement before execution."
  let l:str .= "`uvm_rand_send_with (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_rand_send_pri_with
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#rand_send_pri_with()
  let l:str = ""
  let l:str .= "// apply given constraint block to the item or sequence in a randomize with statement before execution."
  let l:str .= "`uvm_rand_send_pri_with (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_create_on
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#create_on()
  let l:str = ""
  let l:str .= "// `uvm_create and set the parent sequence to this sequence and set the sequencer to the specified SEQUENCER_REF argument."
  let l:str .= "`uvm_create_on (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_do_on
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#do_on()
  let l:str = ""
  let l:str .= "// perform `uvm_do and set the parent sequence to this sequence and set the sequencer to the specified SEQUENCER_REF argument."
  let l:str .= "`uvm_do_on (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_do_on_pri
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#do_on_pri()
  let l:str = ""
  let l:str .= "// perform `uvm_do_pri and set the parent sequence to this sequence and set the sequencer to the specified SEQUENCER_REF argument."
  let l:str .= "`uvm_do_on_pri (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_do_on_with
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#do_on_with()
  let l:str = ""
  let l:str .= "// perform `uvm_do_with and set the parent sequence to this sequence and set the sequencer to the specified SEQUENCER_REF argument."
  let l:str .= "`uvm_do_on_with (maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `uvm_do_on_pri_with
"-------------------------------------------------------------------------------
function sv#uvm#uvm_macros#do_on_pri_with()
  let l:str = ""
  let l:str .= "// perform `uvm_do_pri_with and set the parent sequence to this sequence and set the sequencer to the specified SEQUENCER_REF argument."
  let l:str .= "`uvm_do_on_pri_with (maa)`aa"
  return l:str
endfunction


