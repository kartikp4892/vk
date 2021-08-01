
"-------------------------------------------------------------------------------
" Exp_Map_Mz: Function
"-------------------------------------------------------------------------------
function! Exp_Map_Mx()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^x%[path]$')
    call expression_map#map#remove_map_word()
    if (@+ =~ '=')
      return perl#web_scraper#conv_xpath()
    else
      return perl#web_scraper#css2xpath()
    endif
  elseif (mword =~ '\v^c%[ontains]$')
    call expression_map#map#remove_map_word()
    return perl#web_scraper#xpath_contains()
  elseif (mword =~ '\v^p%[receding-]s%[ibling]$')
    call expression_map#map#remove_map_word()
    return 'preceding-sibling::'
  elseif (mword =~ '\v^f%[ollowing-]s%[ibling]$')
    call expression_map#map#remove_map_word()
    return 'following-sibling::'
  elseif (mword =~ '\v^d%[escendant]$')
    call expression_map#map#remove_map_word()
    return 'descendant::'
  elseif (mword =~ '\v^c%[hild]$')
    call expression_map#map#remove_map_word()
    return 'child::'
  elseif (mword =~ '\v^t%[ext]$')
    call expression_map#map#remove_map_word()
    return 'text()'
  elseif (mword =~ '\v^p%[osition]$')
    call expression_map#map#remove_map_word()
    return 'position()='
  elseif (mword =~ '\v^a%[nd]$')
    call expression_map#map#remove_map_word()
    return ' and '
  elseif (mword =~ '\v^l%[ast]$')
    call expression_map#map#remove_map_word()
    return 'last()'
  else " default
    return ''
  endif
endfunction
imap <M-x> =Exp_Map_Mx()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mz: Function
" attributes
"-------------------------------------------------------------------------------
function! Exp_Map_Mz()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^c%[lass]$')
    call expression_map#map#remove_map_word()
    return '\@class'
  elseif (mword =~ '\v^i%[d]$')
    call expression_map#map#remove_map_word()
    return '\@id'
  elseif (mword =~ '\v^o%[n]c%[lick]$')
    call expression_map#map#remove_map_word()
    return '\@onclick'
  elseif (mword =~ '\v^h%[ref]$')
    call expression_map#map#remove_map_word()
    return '\@href'
  else " default
    return ''
  endif
endfunction
imap <M-z> =Exp_Map_Mz()
"-------------------------------------------------------------------------------
