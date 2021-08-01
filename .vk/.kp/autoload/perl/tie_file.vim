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
" Function : tie
"-------------------------------------------------------------------------------
function! perl#tie_file#tie()
  let name = matchstr(getline("."), '\v^\s*\zs[[:graph:]]+')
  call setline(".", repeat(' ', indent(".")))

  if (name =~ '^\s*$')
    name = s:GetTemplete('a', 'filename')
  endif

  let str =  "use Fcntl 'O_RDWR', 'O_CREAT', 'O_RDONLY';" .
           \ 'tie my @maa' . s:GetTemplete('a', 'arrayname') . ", 'Tie::File', $" . name . ', mode => O_RDWR | O_CREAT | O_RDONLY or die "Error: Coundn''t open file $' . name . '. $!";`aa'

  return str
endfunction
