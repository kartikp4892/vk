let g:VHDL_DSL_SCOPE = []

"-------------------------------------------------------------------------------
" VHDL Token
"-------------------------------------------------------------------------------
let g:Vhdl_token = {}
let g:Vhdl_token.type = 'Vhdl_token'
function! g:Vhdl_token.new(start,end,text) dict
  echo "g:Vhdl_token.new()"
  let this = copy(self)
  let this.startpos = a:start
  let this.endpos = a:end
  let this.text = a:text
  return this
endfunction

function! g:Vhdl_token.NULL() dict
  echo "g:Vhdl_token.NULL()"
  return self.new([0,0,0,0], [0,0,0,0], '')
endfunction



"-------------------------------------------------------------------------------
" VHDL TOKEN REGEX
"-------------------------------------------------------------------------------
let g:Vhdl_token_regex = {}
let g:Vhdl_token_regex.type = 'Vhdl_token_regex'
function! g:Vhdl_token_regex.new(regex) dict
  echo "g:Vhdl_token_regex.new()"
  let this = copy(self)
  let this.regex = a:regex
  return this
endfunction

function! g:Vhdl_token_regex.parse() dict
  echo "g:Vhdl_token_regex.parse()"
  let saveview = winsaveview()
  let m_token = g:Vhdl_token.NULL()
  let success = 0

  let ptrn = '\V\%(' . self.regex . '\)'
  let cptrn = '\V\%#' . ptrn
  let [start, end, kw] = Utils_search(cptrn, 'c')

  if (kw != '') 
    let success = 1
    let m_token = g:Vhdl_token.new(start, end, kw)
    return [success, m_token]
  endif

  call winrestview(saveview)

  return [success, m_token]

endfunction

function! VHDL_REGEX(regex)
  return g:Vhdl_token_regex.new(a:regex)
endfunction

"-------------------------------------------------------------------------------
" VHDL Comment
"-------------------------------------------------------------------------------
let g:Vhdl_token_comment = {}
let g:Vhdl_token_comment.type = 'Vhdl_token_comment'

function! g:Vhdl_token_comment.new() dict
  echo "g:Vhdl_token_comment.new()"
  let this = copy(self)
  let this.regex = '--'
  let this.callbacks = []
  return this
endfunction

function! g:Vhdl_token_comment.add_callback(callback) dict
  echo "g:Vhdl_token_comment.add_callback()"
  let self.callbacks += [a:callback]
  echo "Len callbacks = " . len(self.callbacks)
  return self
endfunction

function! g:Vhdl_token_comment.parse() dict
  echo "g:Vhdl_token_comment.parse()"
  echo "Length of callbacks = " . len(self.callbacks)

  let saveview = winsaveview()
  let m_token = g:Vhdl_token.NULL()
  let success = 0

  let ptrn = '\V\%(' . self.regex . '\)'
  let cptrn = '\V\%#' . ptrn
  let [start, end, kw] = Utils_search(cptrn, 'c')
  echo "inside Comment, kw=" . kw

  if (kw == '--') " Comment started. Skip to next line if possible
    let text = Utils_gettext(start)
    normal $
    let end[2] = col('.')

    for Callback in self.callbacks
      echo Callback
      call Callback(text)
    endfor

    if (start[1] < line('$'))
      exe start[1] + 1
    endif
    let success = 1
    let m_token = g:Vhdl_token.new(start, end, text)

    return [success, m_token]
  endif

  call winrestview(saveview)

  return [success, m_token]
endfunction

"-------------------------------------------------------------------------------
let g:VHDL_COMMENT = g:Vhdl_token_comment.new()
"-------------------------------------------------------------------------------


"-------------------------------------------------------------------------------
" VHDL Lexer
"-------------------------------------------------------------------------------
let g:Vhdl_identifier = '\[\[:alnum:]_.]\+'
let g:Vhdl_lexer = {}
let g:Vhdl_lexer.type = 'Vhdl_lexer'
let g:Vhdl_lexer.m_token = g:Vhdl_token.NULL()
let g:Vhdl_lexer.lut_regex = ''
let g:Vhdl_lexer.EOF = 0

" must have list with priority from higher to lower
let g:VHDL_LEXER_LUT = [ 
  \  VHDL_REGEX(g:Vhdl_identifier),
  \  g:VHDL_COMMENT,
  \  ',',
  \  '--',
  \  '(', ')', 
  \  '<>', 
  \  ';',
  \  ':'
  \ ]

let g:Vhdl_lexer.lut = g:VHDL_LEXER_LUT

function! g:Vhdl_lexer.new() dict
  echo "g:Vhdl_lexer.new()"
  let this = copy(self)
  let this.lut = g:VHDL_LEXER_LUT
  return this
endfunction

function! g:Vhdl_lexer.regex() dict
  echo "g:Vhdl_lexer.regex"
  if (self.lut_regex == '')
    let token_regexs = []
    for lookup in g:Vhdl_lexer.lut
      if (type(lookup) == type(""))
        let token_regexs += [lookup]
      elseif (type(lookup) == type({}))
        if (lookup.type == g:Vhdl_token_regex.type)
          let token_regexs += [lookup.regex]
        endif
      endif
      unlet lookup
    endfor
    let ptrn = '\V\%(' . join(token_regexs, '\|') . '\)'
    let self.lut_regex = ptrn
  endif

  return self.lut_regex
endfunction

function! g:Vhdl_lexer.current_token() dict
  echo "g:Vhdl_lexer.current_token"
  let ptrn = self.regex()
  let cptrn = '\V\%#' . ptrn
  let [start, end, kw] = Utils_search(cptrn, 'c')
  let self.m_token = g:Vhdl_token.new(start, end, kw)
  return self.m_token
endfunction

function! g:Vhdl_lexer.advance() dict
  echo "g:Vhdl_lexer.advance"
  let ptrn = self.regex()
  let success = 1
  if (search(ptrn, 'W') == 0)
    let success = 0
  endif
  return success
endfunction

function! g:Vhdl_lexer.next_token() dict
  echo "g:Vhdl_lexer.next_token, EOF = " . self.EOF
  let self.m_token = g:Vhdl_token.NULL()
  let success = 0

  if (self.EOF == 1)
    return [success, self.EOF, self.m_token]
  endif

  for lookup in self.lut
    if (type(lookup) == type(""))
      let lu_regex = lookup
      let ptrn = '\V\%(' . lu_regex . '\)'
      let cptrn = '\V\%#' . ptrn
      let [start, end, kw] = Utils_search(cptrn, 'c')

      if (kw != '')
        let success = 1
        let self.m_token = g:Vhdl_token.new(start, end, kw)
        break
      endif
    elseif (type(lookup) == type({}))
      let [success, self.m_token] = lookup.parse()
      if (success)
        if (lookup.type == g:Vhdl_token_comment.type) " Skip comments
          return self.next_token()
        endif
        break
      endif
    endif
    unlet lookup
  endfor

  let self.EOF = !self.advance()

  return [success, self.EOF, self.m_token]

endfunction

"-------------------------------------------------------------------------------
let VHDL_LEXER = g:Vhdl_lexer.new()
"-------------------------------------------------------------------------------

let NULL_KEYWORD = [[0,0,0,0], [0,0,0,0], '']

function! Vhdl_current_keyword()
  let m_token = g:VHDL_LEXER.current_token()
  return [m_token.startpos, m_token.endpos, m_token.text]
endfunction

function! Vhdl_next_keyword()

  let [success, EOF, m_token] = g:VHDL_LEXER.next_token()
  echo m_token.text

  return [success, EOF, m_token.startpos, m_token.endpos, m_token.text]
endfunction

"-------------------------------------------------------------------------------
" General
"-------------------------------------------------------------------------------
function! VHDL_IDENTIFIER()
  return g:Vhdl_identifier
endfunction

function! VHDL_MATCH(exp, act)
  if (a:exp == VHDL_IDENTIFIER())
    echo a:act . ' =~ ' . a:exp
    return (a:act =~ '\V' . a:exp)
  else
    echo a:act . ' == ' . a:exp
    return (a:exp == a:act)
  endif
endfunction

function! TOKEN2STR(token)
  if (type(a:token) == type(""))
    return a:token
  elseif (type(a:token) == type({}))
    return a:token.str()
  endif

  return '<UNKNOWN>'
endfunction

"-------------------------------------------------------------------------------
" Skip Pair
"-------------------------------------------------------------------------------
let g:Vhdl_pair = {}
let g:Vhdl_pair.type = 'Vhdl_pair'

function! g:Vhdl_pair.new(begin, end) dict
  echo "g:Vhdl_pair.new"
  let this = copy(self)
  let this.begin = a:begin
  let this.end = a:end
  return this
endfunction

function! g:Vhdl_pair.parse() dict
  echo "g:Vhdl_pair.parse()"
  let [startpos, __, kw] = Vhdl_current_keyword()
  echo "parsing Vhdl_pair: start kw " . kw
  if (kw == self.begin)
    let [SUCCESS, EOF, __, __, kw] = Vhdl_next_keyword()
    if (!SUCCESS) | return g:NULL_KEYWORD | endif

    while (kw != self.end)
      let [SUCCESS, EOF, __, endpos, kw] = Vhdl_next_keyword()
      if (!SUCCESS) | return g:NULL_KEYWORD | endif

      if (kw == self.begin)
        self.parse()
      endif
    endwhile

    let txt = Utils_gettext(startpos, endpos)
    echo [startpos, endpos, txt]
    return [startpos, endpos, txt]
  endif

  return g:NULL_KEYWORD
endfunction

function! VHDL_PAIR_SKIP(begin, end)
  return g:Vhdl_pair.new(a:begin, a:end)
endfunction

"-------------------------------------------------------------------------------
" Any Of
"-------------------------------------------------------------------------------
let g:Vhdl_any_of = {}
let g:Vhdl_any_of.type = 'Vhdl_any_of'

function! g:Vhdl_any_of.new(...) dict
  let this = copy(self)
  let this.tokens = a:000[0]
  return this
endfunction

function! g:Vhdl_any_of.str() dict
  let tokens_str = join(map(deepcopy(self.tokens), 'TOKEN2STR(v:val)'), ' ')
  return printf('ANY_OF(%0s)', tokens_str)
endfunction

function! g:Vhdl_any_of.parse() dict
  echo "g:Vhdl_any_of.parse()"
  let found = 0
  let [SUCCESS, EOF, __, __, act_token] = Vhdl_next_keyword()
  if (!SUCCESS) | return g:NULL_KEYWORD | endif

  for exp_token in self.tokens
    if(type(exp_token) == type(""))
      if (exp_token == act_token)
        let found = 1
        break
      endif
    elseif (type(exp_token) == type({}))
      let saveview = winsaveview()

      if (exp_token.parse())
        let found = 1
        break
      endif

      call winrestview(saveview)
    endif
    unlet exp_token
  endfor

  if (found == 0)
    echoerr "Expected '" . self.str() . "', Found '" . act_token . "'"
  endif

  return found

endfunction

function! VHDL_ANY(...)
  return g:Vhdl_any_of.new(a:000)
endfunction

"-------------------------------------------------------------------------------
" Zero or more
"-------------------------------------------------------------------------------
let g:Vhdl_zero_or_more = {}
let g:Vhdl_zero_or_more.type = 'Vhdl_zero_or_more'

function! g:Vhdl_zero_or_more.new(...) dict
  let this = copy(self)
  let this.tokens = a:000[0]
  let this.identifiers = []
  return this
endfunction

function! g:Vhdl_zero_or_more.str() dict
  let tokens_str = join(map(deepcopy(self.tokens), 'TOKEN2STR(v:val)'), ' ')
  return printf('ZERO_OR_MORE(%0s)', tokens_str)
endfunction

function! g:Vhdl_zero_or_more.parse() dict
  echo "g:Vhdl_zero_or_more.parse()"
  let done = 0
  let found = 0
  while done == 0
    let saveview = winsaveview()

    let identifiers = []
    for exp_token in self.tokens
      let [SUCCESS, EOF, __, __, act_token] = Vhdl_next_keyword()
      if (!SUCCESS) | return g:NULL_KEYWORD | endif

      echo act_token . ' == ' . exp_token
      if (exp_token == VHDL_IDENTIFIER())
        let identifiers += [act_token]
      endif
      if(type(exp_token) == type(""))
        if (!VHDL_MATCH(exp_token, act_token))
          let done = 1
          break
        endif
      elseif (type(exp_token) == type({}))

        if (!exp_token.parse())
          let done = 1
          break
        endif

      endif
      unlet exp_token
    endfor

    if (done == 1)
      call winrestview(saveview)
    else
      let self.identifiers += identifiers
      let found = 1
    endif
  endwhile

  return found

endfunction

function! VHDL_ZERO_OR_MORE(...)
  return g:Vhdl_zero_or_more.new(a:000)
endfunction

"-------------------------------------------------------------------------------
" Zero or more
"-------------------------------------------------------------------------------
let g:Vhdl_optional = {}
let g:Vhdl_optional.type = 'Vhdl_optional'

function! g:Vhdl_optional.new(...) dict
  let this = copy(self)
  let this.tokens = a:000[0]
  let this.identifiers = []
  return this
endfunction

function! g:Vhdl_optional.str() dict
  let tokens_str = join(map(deepcopy(self.tokens), 'TOKEN2STR(v:val)'), ' ')
  return printf('OPTIONAL(%0s)', tokens_str)
endfunction

function! g:Vhdl_optional.parse() dict
  echo "g:Vhdl_optional.parse()"
  let done = 0
  let found = 0
  let saveview = winsaveview()

  let identifiers = []
  for exp_token in self.tokens
    let [SUCCESS, EOF, __, __, act_token] = Vhdl_next_keyword()
    if (!SUCCESS) | return g:NULL_KEYWORD | endif

    echo act_token . ' == ' . exp_token
    if (exp_token == VHDL_IDENTIFIER())
      let identifiers += [act_token]
    endif
    if(type(exp_token) == type(""))
      if (!VHDL_MATCH(exp_token, act_token))
        let done = 1
        break
      endif
    elseif (type(exp_token) == type({}))

      if (!exp_token.parse())
        let done = 1
        break
      endif

    endif
    unlet exp_token
  endfor

  if (done == 1)
    call winrestview(saveview)
  else
    let self.identifiers += identifiers
    let found = 1
  endif

  return found

endfunction

function! VHDL_OPTIONAL(...)
  return g:Vhdl_optional.new(a:000)
endfunction


"-------------------------------------------------------------------------------
" Datatype
"-------------------------------------------------------------------------------
let g:Vhdl_datatype_list = [
  \  'std_logic', 
  \  'std_logic_vector', 
  \  'unsigned', 
  \  'signed', 
  \ ]

let g:Vhdl_datatype = {}
let g:Vhdl_datatype.type = 'Vhdl_datatype'

function! g:Vhdl_datatype.new() dict
  let this = copy(self)

  let this.datatype = ''
  let this.range = ''
  return this
endfunction

function! VHDL_DATATYPE()
  let m_datatype = g:Vhdl_datatype.new()
  return m_datatype
endfunction


function! g:Vhdl_datatype.regex() dict
  echo "g:Vhdl_datatype.regex()"
  let datatype_list = map(deepcopy(g:Vhdl_datatype_list), '"\\<" . v:val . "\\>"')
  echo datatype_list
  let ptrn = '\V\%(' . join(datatype_list, '\|') . '\)'
  return ptrn
endfunction

function! g:Vhdl_datatype.parse() dict
  echo "g:Vhdl_datatype.parse()"
  let [startpos, __, kw] = Vhdl_current_keyword()
  echo "Start Vhdl_datatype.parse " . kw
  if (kw =~ self.regex())
    let self.datatype = kw

    let [SUCCESS, EOF, __, endpos, kw] = Vhdl_next_keyword()
    if (!SUCCESS) | return g:NULL_KEYWORD | endif
    let m_pair = VHDL_PAIR_SKIP('(', ')')
    let kw_tuple = m_pair.parse()
    if (kw_tuple != g:NULL_KEYWORD)
      let endpos = kw_tuple[1]
      let self.range = kw_tuple[2]
    endif

    let txt = Utils_gettext(startpos, endpos)
    return [startpos, endpos, txt]
  endif

  return g:NULL_KEYWORD
endfunction

"-------------------------------------------------------------------------------
" Type
"-------------------------------------------------------------------------------
let g:Vhdl_token_type = {}
let g:Vhdl_token_type.type = 'Vhdl_token_type'

function! g:Vhdl_token_type.new() dict
  let this = copy(self)
  let this.name = ''
  let this.datatype = ''
  let this.range = ''
  return this
endfunction

function! g:Vhdl_token_type.parse() dict
  echo "g:Vhdl_token_type.parse()"
  let [__, __, kw] = Vhdl_current_keyword()
  if (kw == 'type')
    call self.parse_kws('type', VHDL_IDENTIFIER(), 'is', 'array', VHDL_PAIR_SKIP('(', ')'), 'of', VHDL_DATATYPE(), ';')
    return 1
  endif
  return 0
endfunction

function! g:Vhdl_token_type.parse_kws(...) dict
  echo "g:Vhdl_token_type.parse_kws(...)"
  for exp_kw in a:000
    if(type(exp_kw) == type(""))
      let [SUCCESS, EOF, __, __, act_kw] = Vhdl_next_keyword()
      if (!SUCCESS) | return g:NULL_KEYWORD | endif
      if (exp_kw == VHDL_IDENTIFIER())
        let self.name = tolower(act_kw)
        let g:Vhdl_datatype_list += [self.name]
      else
        if (exp_kw != act_kw)
          echoerr "Expected '" . exp_kw . "', Found '" . act_kw . "'"
        endif
      endif
      unlet act_kw
    elseif (type(exp_kw) == type({}))
      if (exp_kw == VHDL_DATATYPE())
        call exp_kw.parse()
        let self.datatype = exp_kw.datatype
        let self.range = exp_kw.range
      else
        call exp_kw.parse()
      endif
    endif
    unlet exp_kw
  endfor

  echo [self.name, self.datatype, self.range]
endfunction

function! g:Vhdl_token_type.verilog() dict
  echo "g:Vhdl_token_type.verilog()"
  let str = 'typedef logic '
  if (self.range != '')
    let range = substitute(self.range, '^(', '[', '')
    let range = substitute(range, ')$', ']', '')
    let range = substitute(range, 'downto', ':', '')
    let str .= range . ' '
  endif
  let str .= self.name . ";\n"
  return str
endfunction

"-------------------------------------------------------------------------------
" Library
"-------------------------------------------------------------------------------
let g:Vhdl_token_library = {}
let g:Vhdl_token_library.type = 'Vhdl_token_library'

function! g:Vhdl_token_library.new() dict
  let this = copy(self)
  let this.names = []
  return this
endfunction

function! g:Vhdl_token_library.parse() dict
  echo "g:Vhdl_token_library.parse()"
  let [__, __, kw] = Vhdl_current_keyword()
  if (kw == 'library')
    call self.parse_kws('library', VHDL_IDENTIFIER(), VHDL_ZERO_OR_MORE(',', VHDL_IDENTIFIER()), ';')
    return 1
  endif
  return 0
endfunction

function! g:Vhdl_token_library.parse_kws(...) dict
  echo "g:Vhdl_token_library.parse_kws(...)"
  for exp_kw in a:000
    if(type(exp_kw) == type(""))
      let [SUCCESS, EOF, __, __, act_kw] = Vhdl_next_keyword()
      echo "Vhdl_token_library ===== act_kw=" . act_kw
      if (!SUCCESS) | return g:NULL_KEYWORD | endif
      if (exp_kw == VHDL_IDENTIFIER())
        let self.names += [tolower(act_kw)]
      else
        if (exp_kw != act_kw)
          echoerr "Expected '" . exp_kw . "', Found '" . act_kw . "'"
        endif
      endif
      unlet act_kw
    elseif (type(exp_kw) == type({}))
      call exp_kw.parse()
      if (exp_kw.type == g:Vhdl_zero_or_more.type)
        let self.names += exp_kw.identifiers
      endif
    endif
    unlet exp_kw
  endfor

  echo self.names
endfunction

function! g:Vhdl_token_library.verilog() dict
  echo "g:Vhdl_token_library.verilog()"
  return ''
endfunction

"-------------------------------------------------------------------------------
" Library
"-------------------------------------------------------------------------------
let g:Vhdl_token_library_use = {}
let g:Vhdl_token_library_use.type = 'Vhdl_token_library_use'

function! g:Vhdl_token_library_use.new() dict
  let this = copy(self)
  let this.names = []
  return this
endfunction

function! g:Vhdl_token_library_use.parse() dict
  echo "g:Vhdl_token_library_use.parse()"
  let [__, __, kw] = Vhdl_current_keyword()
  echo "Vhdl_token_library_use kw=" . kw
  if (kw == 'use')
    call self.parse_kws('use', VHDL_IDENTIFIER(), VHDL_ZERO_OR_MORE(',', VHDL_IDENTIFIER()), ';')
    return 1
  endif
  return 0
endfunction

function! g:Vhdl_token_library_use.parse_kws(...) dict
  echo "g:Vhdl_token_library_use.parse_kws(...)"
  for exp_kw in a:000
    if(type(exp_kw) == type(""))
      let [SUCCESS, EOF, __, __, act_kw] = Vhdl_next_keyword()
      if (!SUCCESS) | return g:NULL_KEYWORD | endif
      echo "Vhdl_token_library_use kw======" . act_kw
      if (exp_kw == VHDL_IDENTIFIER())
        let self.names += [tolower(act_kw)]
      else
        if (exp_kw != act_kw)
          echoerr "Expected '" . exp_kw . "', Found '" . act_kw . "'"
        endif
      endif
      unlet act_kw
    elseif (type(exp_kw) == type({}))
      call exp_kw.parse()
      if (exp_kw.type == g:Vhdl_zero_or_more.type)
        let self.names += exp_kw.identifiers
      endif
    endif
    unlet exp_kw
  endfor

  echo self.names
endfunction

function! g:Vhdl_token_library_use.verilog() dict
  echo "g:Vhdl_token_library_use.verilog()"
  let names = filter(deepcopy(self.names), 'v:val !~ "ieee"')
  let pkg_decl = ''
  if (len(names) != 0)
    let names = map(names, 'substitute(v:val, "work\\.", "", "g")')
    let names = map(names, 'substitute(v:val, "\\.all", "::*", "g")')
    let names = map(names, 'substitute(v:val, "\\.", "::", "g")')
    let pkg_decl = join(map(names, '"import " . v:val . ";"'), "\n")
    let pkg_decl .= "\n"
  endif
  return pkg_decl
endfunction

"-------------------------------------------------------------------------------
" VHDL ENTITY
"-------------------------------------------------------------------------------
let g:Vhdl_token_entity = {}
let g:Vhdl_token_entity.type = 'Vhdl_token_entity'

function! g:Vhdl_token_entity.new() dict
  let this = copy(self)
  let this.name = ''
  return this
endfunction

function! g:Vhdl_token_entity.parse() dict
  echo "g:Vhdl_token_entity.parse()"
  let [__, __, kw] = Vhdl_current_keyword()
  if (kw == 'entity')
    call self.parse_kws('entity', VHDL_IDENTIFIER(), 'is')
    let g:VHDL_DSL_SCOPE += ['entity']
    echo "START: scope ". join(g:VHDL_DSL_SCOPE, ' ')
    return 1
  endif
  return 0
endfunction

function! g:Vhdl_token_entity.parse_kws(...) dict
  echo "g:Vhdl_token_entity.parse_kws(...)"
  for exp_kw in a:000
    if(type(exp_kw) == type(""))
      let [SUCCESS, EOF, __, __, act_kw] = Vhdl_next_keyword()
      if (!SUCCESS) | return g:NULL_KEYWORD | endif
      if (exp_kw == VHDL_IDENTIFIER())
        let self.name = tolower(act_kw)
      else
        if (exp_kw != act_kw)
          echoerr "Expected '" . exp_kw . "', Found '" . act_kw . "'"
        endif
      endif
      unlet act_kw
    elseif (type(exp_kw) == type({}))
      call exp_kw.parse()
    endif
    unlet exp_kw
  endfor

  echo self.name
endfunction

function! g:Vhdl_token_entity.verilog() dict
  echo "g:Vhdl_token_entity.verilog()"
  let txt = 'module ' . self.name
  return txt
endfunction

"-------------------------------------------------------------------------------
" VHDL END
"-------------------------------------------------------------------------------
let g:Vhdl_token_end = {}
let g:Vhdl_token_end.type = 'Vhdl_token_end'

function! g:Vhdl_token_end.new() dict
  let this = copy(self)
  let this.blocktype = '' " example 'while'
  let this.name = ''
  return this
endfunction

function! g:Vhdl_token_end.parse() dict
  echo "g:Vhdl_token_end.parse()"
  let [__, __, kw] = Vhdl_current_keyword()
  if (kw == 'end')
    " end while;
    " end entity name;
    call self.parse_kws('end', VHDL_IDENTIFIER(), VHDL_OPTIONAL(VHDL_IDENTIFIER()), ';')

    " Remove last element
    echo "END: scope ". join(g:VHDL_DSL_SCOPE, ' ')
    let scope = remove(g:VHDL_DSL_SCOPE, -1)
    echo "ended " . scope
    if (scope != self.blocktype)
      echoerr "unexpected end of block. Inside block " . scope . ", found end of " . self.blocktype
    endif
    return 1
  endif
  return 0
endfunction

function! g:Vhdl_token_end.parse_kws(...) dict
  echo "g:Vhdl_token_end.parse_kws(...)"
  for exp_kw in a:000
    if(type(exp_kw) == type(""))
      let [SUCCESS, EOF, __, __, act_kw] = Vhdl_next_keyword()
      if (!SUCCESS) | return g:NULL_KEYWORD | endif
      if (exp_kw == VHDL_IDENTIFIER())
        let self.blocktype = tolower(act_kw)
      else
        if (exp_kw != act_kw)
          echoerr "Expected '" . exp_kw . "', Found '" . act_kw . "'"
        endif
      endif
      unlet act_kw
    elseif (type(exp_kw) == type({}))
      call exp_kw.parse()
      if (exp_kw.type == g:Vhdl_optional.type)
        let self.name += exp_kw.identifiers[0]
      endif
    endif
    unlet exp_kw
  endfor

  echo self.name
endfunction

function! g:Vhdl_token_end.verilog() dict
  echo "g:Vhdl_token_end.verilog()"
  let txt = ''
  if (self.blocktype == 'architecture')
    let txt = "\nendmodule"
  endif
  return txt
endfunction


"-------------------------------------------------------------------------------
" VHDL ARCHITECTURE
"-------------------------------------------------------------------------------
let g:Vhdl_token_architecture = {}
let g:Vhdl_token_architecture.type = 'Vhdl_token_architecture'

function! g:Vhdl_token_architecture.new() dict
  let this = copy(self)
  let this.name = ''
  return this
endfunction

function! g:Vhdl_token_architecture.parse() dict
  echo "g:Vhdl_token_architecture.parse()"
  let [__, __, kw] = Vhdl_current_keyword()
  if (kw == 'architecture')
    call self.parse_kws('architecture', VHDL_IDENTIFIER(), 'of', VHDL_IDENTIFIER(), 'is')
    let g:VHDL_DSL_SCOPE += ['architecture']
    echo "START: scope ". join(g:VHDL_DSL_SCOPE, ' ')
    return 1
  endif
  return 0
endfunction

function! g:Vhdl_token_architecture.parse_kws(...) dict
  echo "g:Vhdl_token_architecture.parse_kws(...)"
  for exp_kw in a:000
    if(type(exp_kw) == type(""))
      let [SUCCESS, EOF, __, __, act_kw] = Vhdl_next_keyword()
      if (!SUCCESS) | return g:NULL_KEYWORD | endif
      if (exp_kw == VHDL_IDENTIFIER())
        let self.name = tolower(act_kw)
      else
        if (exp_kw != act_kw)
          echoerr "Expected '" . exp_kw . "', Found '" . act_kw . "'"
        endif
      endif
      unlet act_kw
    elseif (type(exp_kw) == type({}))
      call exp_kw.parse()
    endif
    unlet exp_kw
  endfor

  echo self.name
endfunction

function! g:Vhdl_token_architecture.verilog() dict
  echo "g:Vhdl_token_architecture.verilog()"
  return ''
endfunction

