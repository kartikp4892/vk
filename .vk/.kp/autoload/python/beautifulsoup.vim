let s:default_soup = 'soup.'

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
" Function : update_default_name
"-------------------------------------------------------------------------------
function! s:update_default_name()
  if (search('\v\w+\.\w+\.%#', 'n') != 0)
    return
  endif

  if (search('\v\w+\.%#', 'n') != 0)
    let [ln, cn] = searchpos('\v\w+\.%#', 'n')
    let s:default_soup = strpart(getline('.'), cn - 1, col('.') - 1)
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : get_default_name
"-------------------------------------------------------------------------------
function! s:get_default_name()
  "Matches . in current position?
  if (search('\v\.%#', 'n') != 0)
    call s:update_default_name()
    return ''
  endif

  return s:default_soup
endfunction

"-------------------------------------------------------------------------------
" Function : new
"-------------------------------------------------------------------------------
function! python#beautifulsoup#new()
  let str = 'soup = BeautifulSoup(maa, "html.parser")`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : contents
"-------------------------------------------------------------------------------
function! python#beautifulsoup#contents()
  let soup = s:get_default_name()
  let str = soup . 'contents'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : children
"-------------------------------------------------------------------------------
function! python#beautifulsoup#children()
  let soup = s:get_default_name()
  let str = soup . 'children'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : descendants
"-------------------------------------------------------------------------------
function! python#beautifulsoup#descendants()
  let soup = s:get_default_name()
  let str = soup . 'descendants'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : string
"-------------------------------------------------------------------------------
function! python#beautifulsoup#string()
  let soup = s:get_default_name()
  let str = soup . 'string'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : stripped_strings
"-------------------------------------------------------------------------------
function! python#beautifulsoup#stripped_strings()
  let soup = s:get_default_name()
  let str = soup . 'stripped_strings'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : strings
"-------------------------------------------------------------------------------
function! python#beautifulsoup#strings()
  let soup = s:get_default_name()
  let str = soup . 'strings'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : string
"-------------------------------------------------------------------------------
function! python#beautifulsoup#string()
  let soup = s:get_default_name()
  let str = soup . 'string'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : string
"-------------------------------------------------------------------------------
function! python#beautifulsoup#string()
  let soup = s:get_default_name()
  let str = soup . 'string'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : string
"-------------------------------------------------------------------------------
function! python#beautifulsoup#string()
  let soup = s:get_default_name()
  let str = soup . 'string'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : parent
"-------------------------------------------------------------------------------
function! python#beautifulsoup#parent()
  let soup = s:get_default_name()
  let str = soup . 'parent'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : parents
"-------------------------------------------------------------------------------
function! python#beautifulsoup#parents()
  let soup = s:get_default_name()
  let str = soup . 'parents'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : prettify
"-------------------------------------------------------------------------------
function! python#beautifulsoup#prettify()
  let soup = s:get_default_name()
  let str = soup . 'prettify'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : next_sibling
"-------------------------------------------------------------------------------
function! python#beautifulsoup#next_sibling()
  let soup = s:get_default_name()
  let str = soup . 'next_sibling'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : previous_sibling
"-------------------------------------------------------------------------------
function! python#beautifulsoup#previous_sibling()
  let soup = s:get_default_name()
  let str = soup . 'previous_sibling'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : next_element
"-------------------------------------------------------------------------------
function! python#beautifulsoup#next_element()
  let soup = s:get_default_name()
  let str = soup . 'next_element'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : previous_element
"-------------------------------------------------------------------------------
function! python#beautifulsoup#previous_element()
  let soup = s:get_default_name()
  let str = soup . 'previous_element'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : next_elements
"-------------------------------------------------------------------------------
function! python#beautifulsoup#next_elements()
  let soup = s:get_default_name()
  let str = soup . 'next_elements'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : previous_elements
"-------------------------------------------------------------------------------
function! python#beautifulsoup#previous_elements()
  let soup = s:get_default_name()
  let str = soup . 'previous_elements'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find_all
"-------------------------------------------------------------------------------
function! python#beautifulsoup#find_all()
  let soup = s:get_default_name()
  let str = soup . 'find_all(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find
"-------------------------------------------------------------------------------
function! python#beautifulsoup#find()
  let soup = s:get_default_name()
  let str = soup . 'find(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find_parents
"-------------------------------------------------------------------------------
function! python#beautifulsoup#find_parents()
  let soup = s:get_default_name()
  let str = soup . 'find_parents(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find_parent
"-------------------------------------------------------------------------------
function! python#beautifulsoup#find_parent()
  let soup = s:get_default_name()
  let str = soup . 'find_parent(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find_next_siblings
"-------------------------------------------------------------------------------
function! python#beautifulsoup#find_next_siblings()
  let soup = s:get_default_name()
  let str = soup . 'find_next_siblings(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find_next_sibling
"-------------------------------------------------------------------------------
function! python#beautifulsoup#find_next_sibling()
  let soup = s:get_default_name()
  let str = soup . 'find_next_sibling(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find_previous_siblings
"-------------------------------------------------------------------------------
function! python#beautifulsoup#find_previous_siblings()
  let soup = s:get_default_name()
  let str = soup . 'find_previous_siblings(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find_previous_sibling
"-------------------------------------------------------------------------------
function! python#beautifulsoup#find_previous_sibling()
  let soup = s:get_default_name()
  let str = soup . 'find_previous_sibling(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find_all_next
"-------------------------------------------------------------------------------
function! python#beautifulsoup#find_all_next()
  let soup = s:get_default_name()
  let str = soup . 'find_all_next(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find_next
"-------------------------------------------------------------------------------
function! python#beautifulsoup#find_next()
  let soup = s:get_default_name()
  let str = soup . 'find_next(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find_all_previous
"-------------------------------------------------------------------------------
function! python#beautifulsoup#find_all_previous()
  let soup = s:get_default_name()
  let str = soup . 'find_all_previous(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find_previous
"-------------------------------------------------------------------------------
function! python#beautifulsoup#find_previous()
  let soup = s:get_default_name()
  let str = soup . 'find_previous(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : select
"-------------------------------------------------------------------------------
function! python#beautifulsoup#select()
  let soup = s:get_default_name()
  let str = soup . 'select(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : append
"-------------------------------------------------------------------------------
function! python#beautifulsoup#append()
  let soup = s:get_default_name()
  let str = soup . 'append(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : NavigableString
"-------------------------------------------------------------------------------
function! python#beautifulsoup#NavigableString()
  let str = 'NavigableString(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : new_tag
"-------------------------------------------------------------------------------
function! python#beautifulsoup#new_tag()
  let soup = s:get_default_name()
  let str = soup . 'new_tag(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : insert
"-------------------------------------------------------------------------------
function! python#beautifulsoup#insert()
  let soup = s:get_default_name()
  let str = soup . 'insert(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : insert_before
"-------------------------------------------------------------------------------
function! python#beautifulsoup#insert_before()
  let soup = s:get_default_name()
  let str = soup . 'insert_before(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : insert_after
"-------------------------------------------------------------------------------
function! python#beautifulsoup#insert_after()
  let soup = s:get_default_name()
  let str = soup . 'insert_after(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : clear
"-------------------------------------------------------------------------------
function! python#beautifulsoup#clear()
  let soup = s:get_default_name()
  let str = soup . 'clear()'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : extract
"-------------------------------------------------------------------------------
function! python#beautifulsoup#extract()
  let soup = s:get_default_name()
  let str = soup . 'extract()'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : decompose
"-------------------------------------------------------------------------------
function! python#beautifulsoup#decompose()
  let soup = s:get_default_name()
  let str = soup . 'decompose()'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : replace_with
"-------------------------------------------------------------------------------
function! python#beautifulsoup#replace_with()
  let soup = s:get_default_name()
  let str = soup . 'replace_with()'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : wrap
"-------------------------------------------------------------------------------
function! python#beautifulsoup#wrap()
  let soup = s:get_default_name()
  let str = soup . 'wrap()'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : get_text
"-------------------------------------------------------------------------------
function! python#beautifulsoup#get_text()
  let soup = s:get_default_name()
  let str = soup . 'get_text()'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : original_encoding
"-------------------------------------------------------------------------------
function! python#beautifulsoup#original_encoding()
  let soup = s:get_default_name()
  let str = soup . 'original_encoding'
  return str
endfunction





