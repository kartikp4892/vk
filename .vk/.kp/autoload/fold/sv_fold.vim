function! fold#sv_fold#svfold(lnum)
    if getline(a:lnum) =~# '^\s*\<class\>'
	return '>1'
    elseif getline(a:lnum) =~# '^\s*\<endclass\>'
        return  '<1'
    elseif getline(a:lnum) =~# '^[[:alnum:]_ ]*\<function\>'
        return  '>2'
    elseif getline(a:lnum) =~# '^[[:alnum:]_ ]*\<endfunction\>'
        return  '<2'
    elseif getline(a:lnum) =~# '^[[:alnum:]_ ]*\<task\>'
        return  '>2'
    elseif getline(a:lnum) =~# '^[[:alnum:]_ ]*\<endtask\>'
        return  '<2'
    else
	return '='
    endif
endfunction

function! fold#sv_fold#svfoldtext()
    return substitute(v:folddashes,'-',' ','g'). matchstr(getline(v:foldstart), '^\s*\zs.*')
endfunction
