
let sv#uvm#skalaton#seq_item#db = {'prefix': '', 'file': '', 'this': '', 'm_this': '', 'path': ''}
"-------------------------------------------------------------------------------
" Function : new
" a:1 - dictionary
"       file key must be provided.
"-------------------------------------------------------------------------------
function! sv#uvm#skalaton#seq_item#db.new(...) dict
  let seqitem = deepcopy(self)
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
    let seqitem[l:key] = a:1[l:key]
  endfor

  if (has_key(a:1, 'path'))
    call intf.find()
  endif

  call seqitem.parse()

  return seqitem
endfunction

"-------------------------------------------------------------------------------
" Function : sv#uvm#skalaton#seq_item#db.parse
"-------------------------------------------------------------------------------
function! sv#uvm#skalaton#seq_item#db.parse() dict

  let self.path = fnamemodify(self.file, ':p:h')
  let self.this = fnamemodify(self.file, ':p:t:r')

  let self.m_this = 'm_seq_item'

endfunction

"-------------------------------------------------------------------------------
" Function : find
"-------------------------------------------------------------------------------
function! sv#uvm#skalaton#seq_item#db.find() dict
  let files = split(glob('`find ' . self.path . ' -name "*"`'), "\n")
  call filter(files, 'v:val =~ ''\v_%(seq%[uence]_item|trans%[action]>''')
  call map(files, 'fnamemodify(v:val, ":.")')

  let self.file = tlib#input#List('s', 'Sequence Item', files)
endfunction







