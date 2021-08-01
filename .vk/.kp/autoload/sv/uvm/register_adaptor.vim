"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

"-------------------------------------------------------------------------------
" register_adaptor: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#register_adaptor()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let str = comments#block_comment#getComments("Class", "" . name)
  let str .= 'class ' . name . ' extends uvm_reg_adapter;' .
          \ s:_set_indent(&shiftwidth) . '`uvm_object_utils(' . name . ')' .
          \
          \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
          \ 'function new(string name = "' . name . '");' .
          \ s:_set_indent(&shiftwidth) . 'super.new(name);' .
          \ s:_set_indent(0) . 'supports_byte_enable = 0;' .
          \ s:_set_indent(0) . 'provides_responses   = 0;' .
          \ s:_set_indent(-&shiftwidth) . 'endfunction' .
          \
          \ s:_set_indent(0) . comments#block_comment#getComments("Function", "reg2bus") .
          \ 'virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);' .
          \
          \ s:_set_indent(&shiftwidth) . printf('maa%s %s;', s:GetTemplete("a", 'trans'), s:GetTemplete("a", 'm_trans')) .
          \ s:_set_indent(0) . printf('%s = %s::type_id::create("%s");', s:GetTemplete("a", 'm_trans'), s:GetTemplete("a", 'trans'), s:GetTemplete("a", 'm_trans')) .
          \
          \ s:_set_indent(0) . 'if ( rw.kind == UVM_READ ) begin' .
          \ s:_set_indent(&shiftwidth) . '' .
          \ s:_set_indent(0) . 'end ' .
          \ s:_set_indent(0) . 'else if ( rw.kind == UVM_WRITE ) begin' .
          \ s:_set_indent(&shiftwidth) . '' .
          \ s:_set_indent(0) . 'end' .
          \ s:_set_indent(0) . 'else begin ' .
          \ s:_set_indent(&shiftwidth) . '' .
          \ s:_set_indent(0) . 'end' .
          \ s:_set_indent(0) . printf('return %s;', s:GetTemplete("a", 'm_trans')) .
          \ s:_set_indent(-&shiftwidth) . 'endfunction: reg2bus' .
          \
          \ s:_set_indent(0) . comments#block_comment#getComments("Function", "bus2reg") .
          \ 'virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);' .
          \ s:_set_indent(&shiftwidth) . printf('%s %s;', s:GetTemplete("a", 'trans'), s:GetTemplete("a", 'm_trans')) .
          \ s:_set_indent(0) . printf('if (!$cast(%s, bus_item)) begin', s:GetTemplete("a", 'm_trans')) .
          \ s:_set_indent(&shiftwidth) . printf('`uvm_fatal( get_full_name(), "bus_item is not of the %s type." )', s:GetTemplete("a", 'trans')) .
          \ s:_set_indent(0) . 'return;' .
          \ s:_set_indent(-&shiftwidth) . 'end' .
          \
          \ s:_set_indent(0) . printf('rw.kind = ( %s ) ? UVM_READ : UVM_WRITE;', s:GetTemplete("b", 'condition')) .
          \ s:_set_indent(0) . printf('// rw.data = %s', s:GetTemplete("b", 'LOGIC TO ASSIGN DATA')) .
          \ s:_set_indent(0) . printf('// rw.addr = %s', s:GetTemplete("b", 'LOGIC TO ASSIGN ADDR'))  .
          \
          \ s:_set_indent(0) . 'rw.status = UVM_IS_OK;' .
          \ s:_set_indent(-&shiftwidth) . 'endfunction: bus2reg' .
          \
          \ s:_set_indent(-&shiftwidth) . 'endclass: ' . name . '`aa'

  return str
endfunction
"-------------------------------------------------------------------------------
" uvm_reg_predictor: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#uvm_reg_predictor()
 let str = printf('typedef uvm_reg_predictor#( maa%s ) %s;`aa', s:GetTemplete("a", 'trans'), s:GetTemplete("b", 'predictor_t'))
 return str
endfunction

"-------------------------------------------------------------------------------
" uvm_reg_sequence: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#uvm_reg_sequence()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let str = printf('class %s extends uvm_reg_sequence;', name) .
          \ s:_set_indent(&shiftwidth) . printf('`uvm_object_utils( %s )', name) .
          \ s:_set_indent(0) . printf('function new( string name = "%s" );', name) .
          \ s:_set_indent(&shiftwidth) . 'super.new( name );' .
          \ s:_set_indent(-&shiftwidth) . ('endfunction: new') .
          \ s:_set_indent(0) . ('virtual task body();') .
          \ s:_set_indent(&shiftwidth) . printf('maa%s %s;', s:GetTemplete("a", 'reg_block'), s:GetTemplete("a", 'm_reg_block')) .
          \ s:_set_indent(0) . ('uvm_status_e status;') .
          \ s:_set_indent(0) . ('uvm_reg_data_t value;') .
          \ s:_set_indent(0) . printf('$cast( %s, model );', s:GetTemplete("a", 'm_reg_block')) .
          \ s:_set_indent(0) . printf('write_reg( %s.%s, status, %s);', s:GetTemplete("a", 'm_reg_block'), s:GetTemplete("a", 'm_reg'), s:GetTemplete("a", 'data')) .
          \ s:_set_indent(0) . printf('read_reg( %s.%s, status, value );', s:GetTemplete("a", 'm_reg_block'), s:GetTemplete("a", 'm_reg')) .
          \ s:_set_indent(-&shiftwidth) . ('endtask: body') .
          \ s:_set_indent(-&shiftwidth) . printf('endclass: %s`aa', name)

  return str
endfunction

"-------------------------------------------------------------------------------
" uvm_reg_sequence_write_reg: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#uvm_reg_sequence_write_reg()
  let str = printf('write_reg(.rg(maa%s),  // input  uvm_reg', s:GetTemplete("a", 'uvm_reg')) .
          \ s:_set_indent(10) . printf('.status(%s),  // output  uvm_status_e', s:GetTemplete("b", '/status')) .
          \ s:_set_indent(0) . printf('.value(%s),  // input  uvm_reg_data_t', s:GetTemplete("c", '/value')) .
          \ s:_set_indent(0) . ('.path(UVM_DEFAULT_PATH),  // input  uvm_path_e') .
          \ s:_set_indent(0) . ('.map(null),  // input  uvm_reg_map') .
          \ s:_set_indent(0) . ('.prior(-1),  // input  int  ') .
          \ s:_set_indent(0) . ('.extension(null),  // input  uvm_object  ') .
          \ s:_set_indent(0) . ('.fname(""),  // input  string  ') .
          \ s:_set_indent(0) . ('.lineno(0))  // input  int  ') .
          \ s:_set_indent(-10) . ('`aa')

  return str
endfunction

"-------------------------------------------------------------------------------
" uvm_reg_sequence_read_reg: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#uvm_reg_sequence_read_reg()
  let str = printf('read_reg(.rg(maa%s),  // input  uvm_reg', s:GetTemplete("a", 'uvm_reg')) .
          \ s:_set_indent(9) . printf('.status(%s),  // output  uvm_status_e', s:GetTemplete("b", '/status')) .
          \ s:_set_indent(0) . printf('.value(%s),  // output  uvm_reg_data_t', s:GetTemplete("c", '/value')) .
          \ s:_set_indent(0) . ('.path(UVM_DEFAULT_PATH),  // input  uvm_path_e') .
          \ s:_set_indent(0) . ('.map(null),  // input  uvm_reg_map') .
          \ s:_set_indent(0) . ('.prior(-1),  // input  int  ') .
          \ s:_set_indent(0) . ('.extension(null),  // input  uvm_object  ') .
          \ s:_set_indent(0) . ('.fname(""),  // input  string  ') .
          \ s:_set_indent(0) . ('.lineno(0))  // input  int  ') .
          \ s:_set_indent(-9) . ('`aa')

  return str
endfunction

"-------------------------------------------------------------------------------
" reg_map_set_sequencer: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#reg_map_set_sequencer()
 let str = printf('set_sequencer( .sequencer( maa%s ), .adapter( %s ) );`aa', s:GetTemplete("a", 'sequencer'), s:GetTemplete("b", 'adapter'))
 return str
endfunction

"-------------------------------------------------------------------------------
" reg_map_set_auto_predict: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#reg_map_set_auto_predict()
  let str = printf('set_auto_predict( .on( maa%s ) );`aa', s:GetTemplete("a", '/0'))
  return str
endfunction

"-------------------------------------------------------------------------------
" uvm_mem: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#uvm_mem()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let str = comments#block_comment#getComments("Class", "" . name)
  let str .= 'class ' . name . ' extends uvm_mem;' .
          \ s:_set_indent(&shiftwidth) . '`uvm_object_utils(' . name . ')' .
          \
          \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
          \ 'function new(string name = "' . name . '", // Name of the memory model' .
          \ s:_set_indent(13) . 'longint unsigned size, // The address range' .
          \ s:_set_indent(0) . 'int unsigned n_bits, // The width of the memory in bits' .
          \ s:_set_indent(0) . 'string access = "RW", // Access - one of "RW" or "RO"' .
          \ s:_set_indent(0) . 'int has_coverage = UVM_NO_COVERAGE); // Functional coverage' .
          \ s:_set_indent(-13 + &shiftwidth) . 'super.new(name, size, n_bits, access, has_coverage);' .
          \ s:_set_indent(-&shiftwidth) . 'endfunction' .
          \ s:_set_indent(0) . 'maa' .
          \ s:_set_indent(-&shiftwidth) . 'endclass: ' . name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" uvm_reg: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#uvm_reg()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let str = comments#block_comment#getComments("Class", "" . name)
  let str .= 'class ' . name . ' extends uvm_reg;' .
          \ s:_set_indent(&shiftwidth) . '`uvm_object_utils(' . name . ')' .
          \
          \ s:_set_indent(0) . printf('rand uvm_reg_field maa%s;', s:GetTemplete("a", "field_name")) .
          \
          \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
          \ printf('function new(string name = "%s", int unsigned n_bits = %s, int has_coverage = %s);', name, s:GetTemplete("a", '/32'), s:GetTemplete("b", "/UVM_NO_COVERAGE")) .
          \ s:_set_indent(&shiftwidth) . 'super.new(name, n_bits, has_coverage);' .
          \ s:_set_indent(-&shiftwidth) . 'endfunction' .
          \
          \ s:_set_indent(0) . comments#block_comment#getComments("Function", "build") .
          \ 'virtual function void build();' .
          \ s:_set_indent(&shiftwidth) . printf('%s = uvm_reg_field::type_id::create("%s");', s:GetTemplete("a", "field_name"), s:GetTemplete("a", "field_name")) .
          \
          \ s:_set_indent(0) . printf('%s.' . 'configure(.parent                  (this), // uvm_reg: The containing register', s:GetTemplete("a", "field_name")) .
                 \  s:_set_indent(&shiftwidth) . printf('.size                    (%s), // int unsigned: How many bits wide', s:GetTemplete("a", "size")) .
                 \  s:_set_indent(0) . printf('.lsb_pos                 (%s), // int unsigned: Bit offset within the register', s:GetTemplete("b", 'lsb_pos')) .
                 \  s:_set_indent(0) . printf('.access                  ("%s"), // string: "RW", "RO", "WO" etc', s:GetTemplete("b", '/RW')) .
                 \  s:_set_indent(0) . '.volatile                (1''b0), // bit: Volatile if bit is updated by hardware' .
                 \  s:_set_indent(0) . '.reset                   (0), // uvm_reg_data_t: The reset value' .
                 \  s:_set_indent(0) . '.has_reset               (1''b1), // bit: Whether the bit is reset' .
                 \  s:_set_indent(0) . '.is_rand                 (1''b1), // bit: Whether the bit can be randomized' .
                 \  s:_set_indent(0) . '.individually_accessible (1''b0)); // bit: i.e. Totally contained within a byte lane' .
          \ s:_set_indent(-&shiftwidth) . 'mba' .
          \ s:_set_indent(-2 * &shiftwidth) . 'endfunction: build' .
          \
          \ s:_set_indent(-&shiftwidth) . 'endclass: ' . name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" reg2bus: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#reg2bus()
  let str = comments#block_comment#getComments("Function", "reg2bus") .
          \ 'virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);' .
          \ s:_set_indent(&shiftwidth) . 'maa' .
          \ s:_set_indent(0) . 'endfunction: reg2bus`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" bus2reg: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#bus2reg()
  let str = comments#block_comment#getComments("Function", "bus2reg") .
          \ 'virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);' .
          \ s:_set_indent(&shiftwidth) . 'maa' .
          \ s:_set_indent(0) . 'endfunction: bus2reg`aa'

  return str
endfunction


"-------------------------------------------------------------------------------
" uvm_reg_field::configure: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#uvm_reg_field_configure()
  let indent = col('.') + len('configure(') - indent(prevnonblank('.')) - 1
  let str = 'configure(.parent                  (this), // uvm_reg: The containing register' .
         \  s:_set_indent(indent) . printf('.size                    (maa%s), // int unsigned: How many bits wide', s:GetTemplete("a", "size")) .
         \  s:_set_indent(0) . printf('.lsb_pos                 (%s), // int unsigned: Bit offset within the register', s:GetTemplete("b", "lsb_pos")) .
         \  s:_set_indent(0) . printf('.access                  ("%s"), // string: "RW", "RO", "WO" etc', s:GetTemplete("c", '/RW')) .
         \  s:_set_indent(0) . '.volatile                (1''b0), // bit: Volatile if bit is updated by hardware' .
         \  s:_set_indent(0) . '.reset                   (0), // uvm_reg_data_t: The reset value' .
         \  s:_set_indent(0) . '.has_reset               (1''b1), // bit: Whether the bit is reset' .
         \  s:_set_indent(0) . '.is_rand                 (1''b1), // bit: Whether the bit can be randomized' .
         \  s:_set_indent(0) . '.individually_accessible (1''b0)); // bit: i.e. Totally contained within a byte lane`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" uvm_reg::configure: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#uvm_reg_configure()
  let indent = col('.') + len('configure(') - indent(prevnonblank('.')) - 1
  let str = 'configure(.blk_parent(this), // uvm_reg_block: The containing reg block' .
         \  s:_set_indent(indent) . '.regfile_parent(null), // uvm_reg_file: Optional, not used' .
         \  s:_set_indent(0) . '.hdl_path("")); // string: Used if HW register can be specified in one hdl_path string' .
         \  s:_set_indent(-indent) 
  return str
endfunction

"-------------------------------------------------------------------------------
" uvm_reg_block: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#uvm_reg_block()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let indent = col('.') + len('create_map(') - indent(prevnonblank('.')) - 1

  call setline(".", repeat(' ', indent(".")))

  let str = comments#block_comment#getComments("Class", "" . name)
  let str .= printf('class %s extends uvm_reg_block;', name) .
          \ s:_set_indent(&shiftwidth) . printf('`uvm_object_utils(%s)', name) .
          \ s:_set_indent(0) . printf('rand maa%s %s;', s:GetTemplete("a", "uvm_reg"), s:GetTemplete('b', 'm_uvm_reg')) .
          \ s:_set_indent(0) . 'uvm_reg_map reg_map;' .
          \
          \ s:_set_indent(0) . printf('function new(string name = "%s", int has_coverage = %s);', name, s:GetTemplete('c', '/UVM_NO_COVERAGE')) .
          \ s:_set_indent(&shiftwidth) . 'super.new(.name(name), .has_coverage(UVM_NO_COVERAGE));' .
          \ s:_set_indent(-&shiftwidth) . 'endfunction: new' .
          \
          \ s:_set_indent(0) . 'virtual function void build();' .
          \ s:_set_indent(&shiftwidth) . printf('%s = %s::type_id::create( "%s" );', s:GetTemplete("b", "m_uvm_reg"), s:GetTemplete("a", "uvm_reg"), s:GetTemplete("b", "m_uvm_reg")) .
          \ s:_set_indent(0) . printf('%s.configure(.blk_parent(this));', s:GetTemplete("b", "m_uvm_reg")) .
          \ s:_set_indent(0) . printf('%s.build();', s:GetTemplete("b", "m_uvm_reg") ) .
          \ s:_set_indent(0) . printf('reg_map = create_map(.name("reg_map"), .base_addr(%s), .n_bytes(%s), .endian(%s), .byte_addressing(%s) );', s:GetTemplete("a", '/''h0'), s:GetTemplete("a", '/4'), s:GetTemplete("a", '/UVM_LITTLE_ENDIAN'), s:GetTemplete("b", '/1')) .
          \ s:_set_indent(0) . printf('reg_map.add_reg(.rg(%s), .offset(%s), .rights("%s"));', s:GetTemplete("b", "m_uvm_reg"), s:GetTemplete("b", '/''h0'), s:GetTemplete("b", "/WO")) .
          \ s:_set_indent(0) . 'lock_model(); // finalize the address mapping' .
          \ s:_set_indent(-&shiftwidth) . 'endfunction: build' .
          \
          \ s:_set_indent(-&shiftwidth) . printf('endclass: %s`aa', name)
          " \ . ':call tskeleton#GoToNextTag()'

  return str
endfunction

"-------------------------------------------------------------------------------
" uvm_reg_block::create_map: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#uvm_reg_block_create_map()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let indent = col('.') + len('create_map(') - indent(prevnonblank('.')) - 1

  call setline(".", repeat(' ', indent(".")))

  let str = name . ' = create_map(.name("' . name . '"), // string : Name of the map handle' .
         \  s:_set_indent(indent) . printf('.base_addr(maa%s), // uvm_reg_addr_t : The maps base address', s:GetTemplete("a", "base_addr")) .
         \  s:_set_indent(0) . printf('.n_bytes(%s), // int unsigned : Map access width in bits', s:GetTemplete('b', 'n_bytes')) .
         \  s:_set_indent(0) . printf('.endian(%s), // uvm_endianness_e : The endianess of the map', s:GetTemplete('c', 'endian')) .
         \  s:_set_indent(0) . '.byte_addressing(1)); // bit: Whether byte_addressing is supported' .
         \  s:_set_indent(-indent) . '`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" uvm_reg_map_add_reg: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#uvm_reg_map_add_reg()
  let indent = col('.') + len('add_reg (') - indent(prevnonblank('.')) - 1

  let str = printf('add_reg (.rg(maa%s), // uvm_reg : Register object handle', s:GetTemplete('a', 'rg')) . 
          \  s:_set_indent(indent) . printf('.offset(%s), // uvm_reg_addr_t : Register address offset', s:GetTemplete('b', 'offset')) .
          \  s:_set_indent(0) . printf('.rights("%s"), // string : Register access policy', s:GetTemplete('b', '/RW'))  .
          \  s:_set_indent(0) . '.unmapped(0), // bit : If true, register does not appear in the address map and a frontdoor access needs to be defined' .
          \  s:_set_indent(0) . '.frontdoor(null));// uvm_reg_frontdoor : Handle to register frontdoor access object' .
          \  s:_set_indent(-indent) . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" uvm_reg_map_add_mem: Function
"-------------------------------------------------------------------------------
function! sv#uvm#register_adaptor#uvm_reg_map_add_mem()
  let indent = col('.') + len('add_mem (') - indent(prevnonblank('.')) - 1

  let str = printf('add_mem (.mem(maa%s), // uvm_mem : Register object handle', s:GetTemplete('a', 'mem')) . 
          \  s:_set_indent(indent) . printf('.offset(%s), // uvm_reg_addr_t : Register address offset', s:GetTemplete('b', 'offset')) .
          \  s:_set_indent(0) . '.rights("RW"), // string : Register access policy' .
          \  s:_set_indent(0) . '.unmapped(0), // bit : If true, register does not appear in the address map and a frontdoor access needs to be defined' .
          \  s:_set_indent(0) . '.frontdoor(null));// uvm_reg_frontdoor : Handle to register frontdoor access object' .
          \  s:_set_indent(-indent) . '`aa'

  return str
endfunction









