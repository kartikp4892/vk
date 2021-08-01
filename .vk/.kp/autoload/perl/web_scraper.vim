"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

"-------------------------------------------------------------------------------
" scraper: Function
"-------------------------------------------------------------------------------
function! perl#web_scraper#scraper()
  "let name = matchstr(getline("."), '^\s*\zs\w\+')
  "call setline(".", repeat(' ', indent(".")))
  let str = 'scraper {' .
           \ s:_set_indent(&shiftwidth) . 'process "maa", "mba" => mca' .
           \ s:_set_indent(-&shiftwidth) . '};`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" proper_name: Function
"-------------------------------------------------------------------------------
function! perl#web_scraper#proper_name(name)
  let name = a:name
  let name = substitute(name, '\v_+', ' ', 'g')
  let name = substitute(name, '\v<\w+>', '\u&', "g")

  return name
endfunction

"-------------------------------------------------------------------------------
" process : Function
"-------------------------------------------------------------------------------
function! perl#web_scraper#process (is_write_sub)
  let name = matchstr(getline("."), '^\s*\zs.\+')
  call setline(".", repeat(' ', indent(".")))
  if (name == "")
    let str = 'process "maa", "mba" => mc`aa'
    return str
  else
    if (name =~ '\v\W|[A-Z]')
      let name = substitute(name, '\v\s+$', '', 'g')

      let proper_name = name

      let name = substitute(name, '\v\W+$', '', 'g')
      let name = substitute(name, '\v\W+', '_', 'g')
      let name = tolower(name)
    else
      let proper_name = perl#web_scraper#proper_name(name)
    endif

    let save_cursor = getpos(".")
    call search ("my $scraper = ", 'b')

    normal Omy $p_=name = "maa";  

    if (a:is_write_sub ==  1)
      normal Amy $s_=name = sub {
              \=common#indent#imode_set_indent(&shiftwidth)
              \my $he = shift;
              \=common#indent#imode_set_indent(0)
              \mca
              \=common#indent#imode_set_indent(0)
              \};
      " Update the old cursor position
      let save_cursor[1] += 4
    endif

    " Update the old cursor position
    let save_cursor[1] += 2
    call setpos(".", save_cursor)

    let str = 'process "$p_' . name . '", "' . proper_name . '" => mba`aa'
    return str
  endif
endfunction

"-------------------------------------------------------------------------------
" default_scraper: Function
"-------------------------------------------------------------------------------
function! perl#web_scraper#default_scraper()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  if (name == "")
    let str = 'my $scraper = scraper {' .
             \ s:_set_indent(&shiftwidth) . 'process "maa", "mba" => mca' .
             \ s:_set_indent(-&shiftwidth) . '};' .
             \ s:_set_indent(0) . 'my $scrape = $scraper -> scrape (mda);`aa'
    return str
  else
    let proper_name = perl#web_scraper#proper_name(name)

    let str = 'my $p_' . name . ' = "maa";'
    let str .= s:_set_indent(0) . 'my $scraper = scraper {'
    let str .= s:_set_indent(&shiftwidth) . 'process "$p_' . name . '", "' . proper_name . '" => mba'
    let str .= s:_set_indent(-&shiftwidth) . '};'
    let str .= s:_set_indent(0) . 'my $scrape = $scraper -> scrape (mca);`aa'
    return str
  endif
endfunction

"-------------------------------------------------------------------------------
" sub: Function
"-------------------------------------------------------------------------------
function! perl#web_scraper#sub()
  "let name = matchstr(getline("."), '^\s*\zs\w\+')
  "call setline(".", repeat(' ', indent(".")))
  let str = 'sub {' . 
           \ s:_set_indent(&shiftwidth) . 'my $he = shift;' . 
           \ s:_set_indent(0) . 'maa' .
           \ s:_set_indent(-&shiftwidth) . '};`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" conv_xpath: Function
"-------------------------------------------------------------------------------
function! perl#web_scraper#conv_xpath()
  let tag = @+
  let tag = substitute(tag, '<\|>', '', 'g')
  let tag = substitute(tag, '^\(\w\+\)\(.\+\)', '\1[\2]', 'g')
  let tag = substitute(tag, '"', '''', 'g')
  let tag = substitute(tag, '\s\+\(\w\+=\)', '\\@\1', 'g')
  return tag
endfunction

"-------------------------------------------------------------------------------
" css2xpath: Function
"-------------------------------------------------------------------------------
function! perl#web_scraper#css2xpath()
  let css = @+
  let acss = split(css, '\s\+')
  let str = '//'
  for l:ac in acss
    let attrs = split(ac, '\ze[.#]')
    for l:at in attrs
      if (l:at =~ '^\.')
        let str .= '[' . substitute(l:at , '^.', '\\@class=''', 'g') . "']"
      elseif (l:at =~ '^#')
        let str .= '[' . substitute(l:at , '^.', '\\@id=''', 'g') . "']"
      else
        let str .= l:at
      endif
    endfor
    let str .= '/'
  endfor
  let str = substitute(str, '/$', '', 'g')
  return str
endfunction

"-------------------------------------------------------------------------------
" xpath_contains: Function
"-------------------------------------------------------------------------------
function! perl#web_scraper#xpath_contains()
  if (search('\v%#\\\@\w+\=''', 'n') || search('\v%#text\(\)\=''', 'n')) " \@attr='value' or  text()='value'
    let str = "lf'f'scontains()Pf=s,"
  else
    let str = "contains(maa)`aa"
  endif
  return str
endfunction
