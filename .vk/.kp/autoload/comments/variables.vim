"----------------------------------------------------------------------------
" Get block comment
"----------------------------------------------------------------------------
if (@% =~ '\v(\.sv$)|(.v$)')
  let comments#variables#comment_begin = '//'
elseif (@% =~ '\.vhd')
  let comments#variables#comment_begin = '--'
elseif (@% =~ '\.vim$' || @% =~ '\.gvimrc$' || @% =~ '\.vimrc') 
  let comments#variables#comment_begin = '"'
elseif (@% =~ '\.p[lm]$')
  let comments#variables#comment_begin = '#'
elseif (@% =~ '\.py$')
  let comments#variables#comment_begin = '#'
elseif (@% =~ '\.bas$')
  let comments#variables#comment_begin = "'"
elseif (@% =~ '\.cpp$')
  let comments#variables#comment_begin = "//"
elseif (@% =~ '\v\.(c|ba)?sh$')
  let comments#variables#comment_begin = "#"
else
  let comments#variables#comment_begin = '//'
endif

let comments#variables#enable_comment = 0

" Value of user_getComments will be the name of the user defined function used for block commenting
if (!exists('comments#variables#user_getComments'))
  let comments#variables#user_getComments = ""
endif

" Value of user_emptyComment will be the name of the user defined function used for comment
if (!exists('comments#variables#user_emptyComment'))
  let comments#variables#user_emptyComment = ""
endif

" Value of user_midEnd will be the name of the user defined function used for comment
if (!exists('comments#variables#user_midEnd'))
  let comments#variables#user_midEnd = ""
endif


