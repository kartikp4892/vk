
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
" Function : open
"-------------------------------------------------------------------------------
function! python#csv#open()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = 'with open(maa' . var . ', "rb") as ' . s:GetTemplete('2', 'fh') . ':' .
    \ s:_set_indent(&shiftwidth) . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : reader
"-------------------------------------------------------------------------------
function! python#csv#reader()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'fh')
  endif

  let str = 'reader = csv.reader(maa' . var . ', delimiter=",", quotechar=''"'')`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : writer
"-------------------------------------------------------------------------------
function! python#csv#writer()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'fh')
  endif

  let str = 'writer = csv.writer(maa' . var . ', delimiter=",", quotechar=''"'', quoting=csv.QUOTE_MINIMAL)`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : register_dialect
"-------------------------------------------------------------------------------
function! python#csv#register_dialect()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = 'csv.register_dialect(maa' . var . ')`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : unregister_dialect
"-------------------------------------------------------------------------------
function! python#csv#unregister_dialect()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = 'csv.unregister_dialect(maa' . var . ')`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : get_dialect
"-------------------------------------------------------------------------------
function! python#csv#get_dialect()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = 'csv.get_dialect(maa' . var . ')`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : list_dialects
"-------------------------------------------------------------------------------
function! python#csv#list_dialects()
  let str = 'csv.list_dialects()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : field_size_limit
"-------------------------------------------------------------------------------
function! python#csv#field_size_limit()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'newlimit')
  endif

  let str = 'csv.field_size_limit(maa' . var . ')`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : DictReader
"-------------------------------------------------------------------------------
function! python#csv#DictReader()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'fh')
  endif

  let str = 'csv.DictReader(maa' . var . ', fieldnames=' . s:GetTemplete('2', 'fieldnames') . ', delimiter=",", quotechar=''"'')`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : DictWriter
"-------------------------------------------------------------------------------
function! python#csv#DictWriter()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'fh')
  endif

  let str = 'csv.DictWriter(maa' . var . ', fieldnames=' . s:GetTemplete('2', 'fieldnames') . ')`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : Dialect
"-------------------------------------------------------------------------------
function! python#csv#Dialect()
  let str = 'csv.Dialect()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : excel
"-------------------------------------------------------------------------------
function! python#csv#excel()
  let str = 'csv.excel()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : excel_tab
"-------------------------------------------------------------------------------
function! python#csv#excel_tab()
  let str = 'csv.excel_tab()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : Sniffer
"-------------------------------------------------------------------------------
function! python#csv#Sniffer()
  let str = 'csv.Sniffer()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : QUOTE_ALL
"-------------------------------------------------------------------------------
function! python#csv#QUOTE_ALL()
  let str = 'csv.QUOTE_ALL'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : QUOTE_MINIMAL
"-------------------------------------------------------------------------------
function! python#csv#QUOTE_MINIMAL()
  let str = 'csv.QUOTE_MINIMAL'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : QUOTE_NONNUMERIC
"-------------------------------------------------------------------------------
function! python#csv#QUOTE_NONNUMERIC()
  let str = 'csv.QUOTE_NONNUMERIC'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : QUOTE_NONE
"-------------------------------------------------------------------------------
function! python#csv#QUOTE_NONE()
  let str = 'csv.QUOTE_NONE'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : try_except
"-------------------------------------------------------------------------------
function! python#csv#try_except()
  let str = 'try:' .
            \ s:_set_indent(&shiftwidth) . 'for row in maa' . s:GetTemplete('1', 'reader') . ':' .
            \ s:_set_indent(&shiftwidth) . s:GetTemplete('2', 'mark') . '' .
            \ s:_set_indent(-&shiftwidth) . 'except csv.Error as error:' .
            \ s:_set_indent(&shiftwidth) . 'sys.exit("file %s, line %d: %s" % (filename, ' . s:GetTemplete('1', 'reader') . '.line_num, error))`aa' .

  return str
endfunction


"###############################################################################
" CSVWRITER
"###############################################################################

"-------------------------------------------------------------------------------
" Function : csvwriter_writerow
"-------------------------------------------------------------------------------
function! python#csv#csvwriter_writerow()
  let str = s:GetTemplete('1', 'csvwriter') . '.writerow(maa)`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : csvwriter_dialect
"-------------------------------------------------------------------------------
function! python#csv#csvwriter_dialect()
  let str = s:GetTemplete('1', 'csvwriter') . '.dialect(maa)`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : csvwriter_writerows
"-------------------------------------------------------------------------------
function! python#csv#csvwriter_writerows()
  let str = s:GetTemplete('1', 'csvwriter') . '.writerows(maa)`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : Dictwriter_writeheader
"-------------------------------------------------------------------------------
function! python#csv#Dictwriter_writeheader()
  let str = s:GetTemplete('1', 'csvwriter') . '.writeheader(maa)`aa'

  return str
endfunction

"###############################################################################
" CSVREADER
"###############################################################################
"-------------------------------------------------------------------------------
" Function : csvreader_next
"-------------------------------------------------------------------------------
function! python#csv#csvreader_next()
  let str = s:GetTemplete('1', 'csvreader') . '.next()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : csvreader_dialect
"-------------------------------------------------------------------------------
function! python#csv#csvreader_dialect()
  let str = s:GetTemplete('1', 'csvreader') . '.dialect()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : csvreader_line_num
"-------------------------------------------------------------------------------
function! python#csv#csvreader_line_num()
  let str = s:GetTemplete('1', 'csvreader') . '.line_num()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : csvreader_fieldnames
"-------------------------------------------------------------------------------
function! python#csv#csvreader_fieldnames()
  let str = s:GetTemplete('1', 'csvreader') . '.fieldnames()'

  return str
endfunction

"###############################################################################
" DIALECT
"###############################################################################
"-------------------------------------------------------------------------------
" Function : dialect_delimiter
"-------------------------------------------------------------------------------
function! python#csv#dialect_delimiter()
  let str = s:GetTemplete('1', 'dialect') . '.dialect_delimiter()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : dialect_doublequote
"-------------------------------------------------------------------------------
function! python#csv#dialect_doublequote()
  let str = s:GetTemplete('1', 'dialect') . '.doublequote()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : dialect_escapechar
"-------------------------------------------------------------------------------
function! python#csv#dialect_escapechar()
  let str = s:GetTemplete('1', 'dialect') . '.escapechar()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : dialect_lineterminator
"-------------------------------------------------------------------------------
function! python#csv#dialect_lineterminator()
  let str = s:GetTemplete('1', 'dialect') . '.lineterminator()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : dialect_quotechar
"-------------------------------------------------------------------------------
function! python#csv#dialect_quotechar()
  let str = s:GetTemplete('1', 'dialect') . '.quotechar()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : dialect_quoting
"-------------------------------------------------------------------------------
function! python#csv#dialect_quoting()
  let str = s:GetTemplete('1', 'dialect') . '.quoting()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : dialect_skipinitialspace
"-------------------------------------------------------------------------------
function! python#csv#dialect_skipinitialspace()
  let str = s:GetTemplete('1', 'dialect') . '.skipinitialspace()'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : dialect_strict
"-------------------------------------------------------------------------------
function! python#csv#dialect_strict()
  let str = s:GetTemplete('1', 'dialect') . '.strict()'

  return str
endfunction



