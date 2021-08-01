if !exists('ovm_tx_class_name')
  let ovm_tx_class_name = ""
endif

"-------------------------------------------------------------------------------
" `ovm_field_int
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_int()
  let l:str = '// Implement the data operations for the packed integral property.'
  let l:str .= '`ovm_field_int(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_object
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_object()
  let l:str = '//Implements the data operations for an ovm_object-based property.'
  let l:str .= '`ovm_field_object(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_string
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_string()
  let l:str = '//Implements the data operations for a string property.'
  let l:str .= '`ovm_field_string(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_enum
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_enum()
  let l:str = '//Implements the data operations for an enumerated property.'
  let l:str .= '`ovm_field_enum(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_real
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_real()
  let l:str = '//Implements the data operations for any real property.'
  let l:str .= '`ovm_field_real(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_event
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_event()
  let l:str = '//Implements the data operations for an event property.'
  let l:str .= '`ovm_field_event(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_sarray_int
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_sarray_int()
  let l:str = '//Implements the data operations for a one-dimensional static array of integrals.'
  let l:str .= '`ovm_field_sarray_int(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_sarray_object
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_sarray_object()
  let l:str = '//Implements the data operations for a one-dimensional static array of ovm_object-based objects.'
  let l:str .= '`ovm_field_sarray_object(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_sarray_string
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_sarray_string()
  let l:str = '//Implements the data operations for a one-dimensional static array of strings.'
  let l:str .= '`ovm_field_sarray_string(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_sarray_enum
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_sarray_enum()
  let l:str = '//Implements the data operations for a one-dimensional static array of enums.'
  let l:str .= '`ovm_field_sarray_enum(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_array_int
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_array_int()
  let l:str = '//Implements the data operations for a one-dimensional dynamic array of integrals.'
  let l:str .= '`ovm_field_array_int(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_array_object
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_array_object()
  let l:str = '//Implements the data operations for a one-dimensional dynamic array of ovm_object-based objects.'
  let l:str .= '`ovm_field_array_object(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_array_string
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_array_string()
  let l:str = '//Implements the data operations for a one-dimensional dynamic array of strings.'
  let l:str .= '`ovm_field_array_string(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_array_enum
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_array_enum()
  let l:str = '//Implements the data operations for a one-dimensional dynamic array of enums.'
  let l:str .= '`ovm_field_array_enum(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_queue_int
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_queue_int()
  let l:str = '//Implements the data operations for a queue of integrals.'
  let l:str .= '`ovm_field_queue_int(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_queue_object
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_queue_object()
  let l:str = '//Implements the data operations for a queue of ovm_object-based objects.'
  let l:str .= '`ovm_field_queue_object(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_queue_string
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_queue_string()
  let l:str = '//Implements the data operations for a queue of strings.'
  let l:str .= '`ovm_field_queue_string(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_queue_enum
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_queue_enum()
  let l:str = '//Implements the data operations for a one-dimensional queue of enums.'
  let l:str .= '`ovm_field_queue_enum(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_string
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_string()
  let l:str = '//Implements the data operations for an associative array of integrals indexed by string.'
  let l:str .= '`ovm_field_aa_int_string(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_object_string
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_object_string()
  let l:str = '//Implements the data operations for an associative array of ovm_object-based objects indexed by string.'
  let l:str .= '`ovm_field_aa_object_string(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_string_string
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_string_string()
  let l:str = '//Implements the data operations for an associative array of strings indexed by string.'
  let l:str .= '`ovm_field_aa_string_string(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_object_int
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_object_int()
  let l:str = '//Implements the data operations for an associative array of ovm_object-based objects indexed by the int data type.'
  let l:str .= '`ovm_field_aa_object_int(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_int
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_int()
  let l:str = '//Implements the data operations for an associative array of integral types indexed by the int data type.'
  let l:str .= '`ovm_field_aa_int_int(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_int_unsigned
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_int_unsigned()
  let l:str = '//Implements the data operations for an associative array of integral types indexed by the int unsigned data type.'
  let l:str .= '`ovm_field_aa_int_int_unsigned(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_integer
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_integer()
  let l:str = '//Implements the data operations for an associative array of integral types indexed by the integer data type.'
  let l:str .= '`ovm_field_aa_int_integer(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_integer_unsigned
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_integer_unsigned()
  let l:str = '//Implements the data operations for an associative array of integral types indexed by the integer unsigned data type.'
  let l:str .= '`ovm_field_aa_int_integer_unsigned(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_byte
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_byte()
  let l:str = '//Implements the data operations for an associative array of integral types indexed by the byte data type.'
  let l:str .= '`ovm_field_aa_int_byte(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_byte_unsigned
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_byte_unsigned()
  let l:str = '//Implements the data operations for an associative array of integral types indexed by the byte unsigned data type.'
  let l:str .= '`ovm_field_aa_int_byte_unsigned(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_shortint
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_shortint()
  let l:str = '//Implements the data operations for an associative array of integral types indexed by the shortint data type.'
  let l:str .= '`ovm_field_aa_int_shortint(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_shortint_unsigned
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_shortint_unsigned()
  let l:str = '//Implements the data operations for an associative array of integral types indexed by the shortint unsigned data type.'
  let l:str .= '`ovm_field_aa_int_shortint_unsigned(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_longint
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_longint()
  let l:str = '//Implements the data operations for an associative array of integral types indexed by the longint data type.'
  let l:str .= '`ovm_field_aa_int_longint(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_longint_unsigned
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_longint_unsigned()
  let l:str = '//Implements the data operations for an associative array of integral types indexed by the longint unsigned data type.'
  let l:str .= '`ovm_field_aa_int_longint_unsigned(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_key
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_key()
  let l:str = '//Implements the data operations for an associative array of integral types indexed by any integral key data type.'
  let l:str .= '`ovm_field_aa_int_key(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_field_aa_int_enumkey
"-------------------------------------------------------------------------------
function! sv#ovm#ovm_macro#field_aa_int_enumkey()
  let l:str = '//Implements the data operations for an associative array of integral types indexed by any enumeration key data type.'
  let l:str .= '`ovm_field_aa_int_enumkey(maa, OVM_ALL_ON)`aa'
  return l:str
endfunction

"===============================================================================
" Sequence & Action Macros
"===============================================================================
"-------------------------------------------------------------------------------
" `ovm_declare_p_sequencer
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#declare_p_sequencer()
  let l:str = ""
  let l:str .= "// set up the sequencer type with this sequence type. "
  let l:str .= "`ovm_declare_p_sequencer(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_sequence_utils_begin
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#sequence_utils_begin()
  " Get the sequence name
  let l:seq_name = matchstr(getline(search('^[[:alnum:]_ ]*\<class\>', 'nb')), '\<class\s\+\zs\w\+')

  let l:str = ""
  let l:str .= "// pre-register the sequence with a given <ovm_sequencer> type."
  let l:str .= "`ovm_sequence_utils_begin(" . l:seq_name . ", maa)"
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .=   '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= "  "
  let l:str .= '`ovm_field_utils_end`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_sequence_utils
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#sequence_utils()
  " Get the sequence name
  let l:seq_name = matchstr(getline(search('^[[:alnum:]_ ]*\<class\>', 'nb')), '\<class\s\+\zs\w\+')
  let l:str = ""
  let l:str .= "// pre-register the sequence with a given <ovm_sequencer> type."
  let l:str .= "`ovm_sequence_utils(" . l:seq_name . ", maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_update_sequence_lib
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#update_sequence_lib()
  let l:str = ""
  let l:str .= "// populate the instance-specific sequence library for a sequencer. "
  let l:str .= "`ovm_update_sequence_lib(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_update_sequence_lib_and_item
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#update_sequence_lib_and_item()
  let l:str = ""
  let l:str .= "// populate the instance specific sequence library for a sequencer, and" .
               \"// register the given USER_ITEM as an instance override for the simple sequence’s item variable."
  let l:str .= "`ovm_update_sequence_lib_and_item(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_sequencer_utils
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#sequencer_utils()
  " Get the sequence name
  let l:seq_name = matchstr(getline(search('^[[:alnum:]_ ]*\<class\>', 'nb')), '\<class\s\+\zs\w\+')
  let l:str = ""
  let l:str .= "// declare the plumbing necessary for creating the sequencer’s sequence library"
  let l:str .= "`ovm_sequencer_utils(" . l:seq_name . ")"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_sequencer_utils_begin
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#sequencer_utils_begin()
  " Get the sequence name
  let l:seq_name = matchstr(getline(search('^[[:alnum:]_ ]*\<class\>', 'nb')), '\<class\s\+\zs\w\+')
  let l:str = ""
  let l:str .= "// declare the plumbing necessary for creating the sequencer’s sequence library"
  let l:str .= "`ovm_sequencer_utils_begin(" . l:seq_name . ")"
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .=   '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= "  maa"
  let l:str .= '`ovm_field_utils_end`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_sequencer_param_utils
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#sequencer_param_utils()
  " Get the sequence name
  let l:seq_name = matchstr(getline(search('^[[:alnum:]_ ]*\<class\>', 'nb')), '\<class\s\+\zs\w\+')
  let l:str = ""
  let l:str .= "// declare the plumbing necessary for creating the sequencer’s sequence library"
  let l:str .= "`ovm_sequencer_param_utils(" . l:seq_name . ")"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_sequencer_param_utils_begin
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#sequencer_param_utils_begin()
  " Get the sequence name
  let l:seq_name = matchstr(getline(search('^[[:alnum:]_ ]*\<class\>', 'nb')), '\<class\s\+\zs\w\+')
  let l:str = ""
  let l:str .= "// declare the plumbing necessary for creating the sequencer’s sequence library"
  let l:str .= "`ovm_sequencer_param_utils_begin(" . l:seq_name . ")"
  let l:str .= '  // Field Macros Declaration to form “automatic” implementations of the core'
  let l:str .=   '// data methods: copy, compare, pack, unpack, record, print, and sprint.'
  let l:str .= "  maa"
  let l:str .= '`ovm_field_utils_end`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_create
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#create()
  let l:str = ""
  let l:str .= "// create the item or sequence using the factory. "
  let l:str .= "`ovm_create(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_do
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#do()
  let l:str = ""
  let l:str .= "// randomize ovm_sequence_item at the time the sequencer grants the do request. (late-randomization or late-generation)"
  let l:str .= "`ovm_do(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_do_pri
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#do_pri()
  let l:str = ""
  let l:str .= "//  execute sequene item or sequence with the priority specified in the argument"
  let l:str .= "`ovm_do_pri(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_do_with
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#do_with()
  let l:str = ""
  let l:str .= "// apply constraint block to the item or sequence in a randomize with statement before execution."
  let l:str .= "`ovm_do_with(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_do_pri_with
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#do_pri_with()
  let l:str = ""
  let l:str .= "// apply constraint block to the item or sequence in a randomize with statement before execution"
  let l:str .= "`ovm_do_pri_with(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_send
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#send()
  let l:str = ""
  let l:str .= "// process the item or sequence that has been created using `ovm_create."
  let l:str .= "`ovm_send(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_send_pri
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#send_pri()
  let l:str = ""
  let l:str .= "// execute sequene item or sequence with the priority specified in the argument."
  let l:str .= "`ovm_send_pri(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_rand_send
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#rand_send()
  let l:str = ""
  let l:str .= "// process the item or sequence that has been already been allocated (possibly with `ovm_create)."
  let l:str .= "`ovm_rand_send(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_rand_send_pri
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#rand_send_pri()
  let l:str = ""
  let l:str .= "// execute the sequene item or sequence with the priority specified in the argument."
  let l:str .= "`ovm_rand_send_pri(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_rand_send_with
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#rand_send_with()
  let l:str = ""
  let l:str .= "// apply given constraint block to the item or sequence in a randomize with statement before execution."
  let l:str .= "`ovm_rand_send_with(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_rand_send_pri_with
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#rand_send_pri_with()
  let l:str = ""
  let l:str .= "// apply given constraint block to the item or sequence in a randomize with statement before execution."
  let l:str .= "`ovm_rand_send_pri_with(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_create_on
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#create_on()
  let l:str = ""
  let l:str .= "// `ovm_create and set the parent sequence to this sequence and set the sequencer to the specified SEQUENCER_REF argument."
  let l:str .= "`ovm_create_on(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_do_on
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#do_on()
  let l:str = ""
  let l:str .= "// perform `ovm_do and set the parent sequence to this sequence and set the sequencer to the specified SEQUENCER_REF argument."
  let l:str .= "`ovm_do_on(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_do_on_pri
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#do_on_pri()
  let l:str = ""
  let l:str .= "// perform `ovm_do_pri and set the parent sequence to this sequence and set the sequencer to the specified SEQUENCER_REF argument."
  let l:str .= "`ovm_do_on_pri(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_do_on_with
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#do_on_with()
  let l:str = ""
  let l:str .= "// perform `ovm_do_with and set the parent sequence to this sequence and set the sequencer to the specified SEQUENCER_REF argument."
  let l:str .= "`ovm_do_on_with(maa)`aa"
  return l:str
endfunction

"-------------------------------------------------------------------------------
" `ovm_do_on_pri_with
"-------------------------------------------------------------------------------
function sv#ovm#ovm_macro#do_on_pri_with()
  let l:str = ""
  let l:str .= "// perform `ovm_do_pri_with and set the parent sequence to this sequence and set the sequencer to the specified SEQUENCER_REF argument."
  let l:str .= "`ovm_do_on_pri_with(maa)`aa"
  return l:str
endfunction


