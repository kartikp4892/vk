
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
" Function : new
"-------------------------------------------------------------------------------
function! python#mechanize#new()
  let str = 'mech = mechanize.Browser()' .
          \ 
          \ s:_set_indent(0) . 'cj = cookielib.LWPCookieJar()' .
          \ s:_set_indent(0) . 'mech.set_cookiejar(cj)' .
          \ 
          \ s:_set_indent(0) . 'mech.set_handle_equiv(True)' .
          \ s:_set_indent(0) . 'mech.set_handle_gzip(False)' .
          \ s:_set_indent(0) . 'mech.set_handle_redirect(True)' .
          \ s:_set_indent(0) . 'mech.set_handle_referer(True)' .
          \ s:_set_indent(0) . 'mech.set_handle_robots(False)' .
          \ 
          \ s:_set_indent(0) . '# Follows refresh 0 but not hangs on refresh > 0' .
          \ s:_set_indent(0) . 'mech.set_handle_refresh(mechanize._http.HTTPRefreshProcessor(), max_time=1)' .
          \ 
          \ s:_set_indent(0) . '# Want debugging messages?' .
          \ s:_set_indent(0) . 'mech.set_debug_http(True)' .
          \ s:_set_indent(0) . 'mech.set_debug_redirects(True)' .
          \ s:_set_indent(0) . 'mech.set_debug_responses(True)' .
          \ 
          \ s:_set_indent(0) . "mech.addheaders = [('User-agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/3.0.1-1.fc9 Firefox/3.0.1')] "

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : browser
"-------------------------------------------------------------------------------
function! python#mechanize#browser()
  let str = 'mech = mechanize.Browser()'
endfunction

"-------------------------------------------------------------------------------
" Function : set_handle_equiv
"-------------------------------------------------------------------------------
function! python#mechanize#set_handle_equiv()
  let str = 'mech.set_handle_equiv()'
endfunction

"-------------------------------------------------------------------------------
" Function : set_handle_gzip
"-------------------------------------------------------------------------------
function! python#mechanize#set_handle_gzip()
  let str = 'mech.set_handle_gzip()'
endfunction

"-------------------------------------------------------------------------------
" Function : set_handle_redirect
"-------------------------------------------------------------------------------
function! python#mechanize#set_handle_redirect()
  let str = 'mech.set_handle_redirect()'
endfunction

"-------------------------------------------------------------------------------
" Function : set_handle_referer
"-------------------------------------------------------------------------------
function! python#mechanize#set_handle_referer()
  let str = 'mech.set_handle_referer()'
endfunction

"-------------------------------------------------------------------------------
" Function : set_handle_robots
"-------------------------------------------------------------------------------
function! python#mechanize#set_handle_robots()
  let str = 'mech.set_handle_robots()'
endfunction

"-------------------------------------------------------------------------------
" Function : set_handle_refresh
"-------------------------------------------------------------------------------
function! python#mechanize#set_handle_refresh()
  let str = 'mech.set_handle_refresh()'
endfunction

"-------------------------------------------------------------------------------
" Function : set_debug_http
"-------------------------------------------------------------------------------
function! python#mechanize#set_debug_http()
  let str = 'mech.set_debug_http()'
endfunction

"-------------------------------------------------------------------------------
" Function : set_debug_redirects
"-------------------------------------------------------------------------------
function! python#mechanize#set_debug_redirects()
  let str = 'mech.set_debug_redirects()'
endfunction

"-------------------------------------------------------------------------------
" Function : set_debug_responses
"-------------------------------------------------------------------------------
function! python#mechanize#set_debug_responses()
  let str = 'mech.set_debug_responses()'
endfunction

"-------------------------------------------------------------------------------
" Function : addheaders
"-------------------------------------------------------------------------------
function! python#mechanize#addheaders()
  let str = 'mech.addheaders = '
endfunction

"-------------------------------------------------------------------------------
" Function : read
"-------------------------------------------------------------------------------
function! python#mechanize#read()
  let str = 'mech.response().read()'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : title
"-------------------------------------------------------------------------------
function! python#mechanize#title()
  let str = 'mech.title()'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : info
"-------------------------------------------------------------------------------
function! python#mechanize#info()
  let str = 'mech.response().info()'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : forms
"-------------------------------------------------------------------------------
function! python#mechanize#forms()
  let str = 'mech.forms()'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : form
"-------------------------------------------------------------------------------
function! python#mechanize#form()
  let str = 'mech.form[maa]`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : submit
"-------------------------------------------------------------------------------
function! python#mechanize#submit()
  let str = 'mech.submit()'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : links
"-------------------------------------------------------------------------------
function! python#mechanize#links()
  let str = 'mech.links(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find_link
"-------------------------------------------------------------------------------
function! python#mechanize#find_link()
  let str = 'mech.find_link(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : geturl
"-------------------------------------------------------------------------------
function! python#mechanize#geturl()
  let str = 'mech.geturl()'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : retrieve
"-------------------------------------------------------------------------------
function! python#mechanize#retrieve()
  let str = 'mech.retrieve(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : set_proxies
"-------------------------------------------------------------------------------
function! python#mechanize#set_proxies()
  let str = 'mech.set_proxies(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : add_proxy_password
"-------------------------------------------------------------------------------
function! python#mechanize#add_proxy_password()
  let str = 'mech.add_proxy_password(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : click_link
"-------------------------------------------------------------------------------
function! python#mechanize#click_link()
  let str = 'mech.click_link(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : open
"-------------------------------------------------------------------------------
function! python#mechanize#open()
  let str = 'mech.open(maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : add_password
"-------------------------------------------------------------------------------
function! python#mechanize#add_password()
  let str = printf("mech.add_password(maa%s, %s, %s)`aa", s:GetTemplete('1', 'url'), s:GetTemplete('2', 'username'),  s:GetTemplete('3', 'password') )
  return str
endfunction


"-------------------------------------------------------------------------------
" Function : select_form
"-------------------------------------------------------------------------------
function! python#mechanize#select_form()
  let str = 'mech.select_form(nr = maa)`aa'
  return str
endfunction




