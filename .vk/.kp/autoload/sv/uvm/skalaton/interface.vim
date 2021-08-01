"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

let sv#uvm#skalaton#interface#db = {'prefix': '', 'file': '', 'this': '', 'm_this': '', 'path': ''}
"-------------------------------------------------------------------------------
" Function : new
" a:1 - dictionary
"       either file or path key must be provided. If path key provided then it will search for intf in path
"-------------------------------------------------------------------------------
function! sv#uvm#skalaton#interface#db.new(...) dict
  let intf = deepcopy(self)
  if (a:0 == 0)
    echoerr "Argument required"
    finish
  endif

  if (type(a:1) != type({}))
    echoerr "Not a dictionary"
    finish
  endif

  if (!(has_key(a:1, 'file') || has_key(a:1, 'path')))
    echoerr 'key file or path must be provided'
    finish
  endif

  for l:key in keys(a:1)
    let intf[l:key] = a:1[l:key]
  endfor

  if (has_key(a:1, 'path'))
    call intf.find()
  endif

  call intf.parse()

  return intf
endfunction

"-------------------------------------------------------------------------------
" Function : sv#uvm#skalaton#interface#db.set_prefix
" ?a:1 : Prefix
"-------------------------------------------------------------------------------
function! sv#uvm#skalaton#interface#db.set_prefix(...)
  if (a:0 == 0)
    let self.prefix = matchstr(self.this, '\v\w+\ze_i%[nter]f%[ace]>')
    if (self.prefix == '')
      let self.prefix = self.this
    endif
    return
  endif

  let self.prefix = a:1
endfunction

"-------------------------------------------------------------------------------
" Function : sv#uvm#skalaton#interface#db.parse
"-------------------------------------------------------------------------------
function! sv#uvm#skalaton#interface#db.parse() dict

  let self.path = fnamemodify(self.file, ':p:h')
  let self.this = fnamemodify(self.file, ':p:t:r')
  call self.set_prefix()

  if (self.prefix != "")
    let self.m_this = 'm_' . self.prefix . '_vif'
  endif

endfunction

"-------------------------------------------------------------------------------
" Function : find
"-------------------------------------------------------------------------------
function! sv#uvm#skalaton#interface#db.find() dict
  let files = split(glob('`find ' . self.path . ' -name "*"`'), "\n")
  call filter(files, 'v:val =~ ''\v_i%[nter]f%[ace]>''')
  call map(files, 'fnamemodify(v:val, ":.")')

  let self.file = tlib#input#List('s', 'Interface', files)
endfunction

"-------------------------------------------------------------------------------
" Function : instantiate
"-------------------------------------------------------------------------------
function! sv#uvm#skalaton#interface#db.get_declaration_str() dict
  if (self.this == "")
    return ''
  else
    return printf('virtual %s %s;', self.this, self.m_this)
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : config_db_set
" a:1 - Value prefix - example config.vif
"-------------------------------------------------------------------------------
function! sv#uvm#skalaton#interface#db.config_db_set(cntxt, inst_name, ...) dict
  if (self.this == "")
    return ""
  else
    let value = self.m_this
    if (a:0 != 0)
      let value = a:1 . "." . self.m_this
    endif
    return s:_set_indent(0) . printf('uvm_config_db#(virtual %s)::set(.cntxt(%s), .inst_name("%s"), .field_name("%s"), .value(%s));', self.this, a:cntxt, a:inst_name, self.this, value)
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : config_db_get
" a:1 - Value prefix - example config.vif
"-------------------------------------------------------------------------------
function! sv#uvm#skalaton#interface#db.config_db_get(cntxt, inst_name, ...) dict
  if (self.this == "")
    return ""
  else
    let value = self.m_this

    if (a:0 != 0)
      let value = a:1 . "." . self.m_this
    endif

    let str = s:_set_indent(0) . printf('if (!uvm_config_db#(virtual %s)::get(.cntxt(%s), .inst_name("%s"), .field_name("%s"), .value(%s))) begin', self.this, a:cntxt, a:inst_name, self.this, value) .
      \ s:_set_indent(&shiftwidth) . printf('`uvm_fatal(get_full_name(), "uvm_config_db #( virtual %s )::get cannot find resource %s!!!")', self.this, self.this) .
      \ s:_set_indent(-&shiftwidth) . 'end'

    return str
  endif
endfunction









