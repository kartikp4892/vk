let s:temp_count = 1
let s:temp_signals_to_review = []

function! s:get_temp_sig()
  let name = printf("_TEMP_%0s", s:temp_count)
  let s:temp_count += 1
  return name
endfunction

function! s:get_uniq_name(sig)
  let currview = winsaveview()
  let cnt = 1
  let name = a:sig
  while (search(printf('\v<%0s>', name), 'cw') != 0)
    let name = printf('%0s_%0s', a:sig, cnt)
    let cnt += 1
  endwhile

  call winrestview(currview)

  return name
endfunction

function! SpinalDeleteHeader()
  silent g/\/\/\s*Generator\s*:/d
  silent g/\/\/\s*Component\s*:/d
  silent g/\/\/\s*Git hash\s*:/d
  call cursor(1,1)

  while (getline(".") == "")
    delete
  endwhile
endfunction

function! SpinalCommonCleanup()
  " Replace {0'd0, 8'h7} with 8'h7
  " silent %s/{0'[dbh]0\s*,\s*\(\d\+'[hdb][0-9a-fA-F]\+\)}/\1/ge
  silent %s/{0'[dbh]0\s*,\s*\([^}]*\)}/\1/ge
  " Replace _zz_1 = {24'h0, _zz_2} with _zz1 = _zz_2
  silent %s/_zz\w\+\s*=\s*\zs{\d\+'[dbh]0\s*,\s*\([^}]*\)}/\1/ge
  "silent %s/{\zs0'[dbh]0\s*,\s*//ge
endfunction

function! SpinalError(msg)
  echohl Error
  echo a:msg
  echohl None
endfunction

function! s:wire_decl_pattern(sig) " wire _zz_*
  return printf('\v^\s*wire\s+(\[.{-}\]\s*)*<%0s>', a:sig)
endfunction

function! s:reg_decl_pattern(sig) " reg _zz*
  return printf('\v^\s*reg\s+(\[.{-}\]\s*)*<%0s>', a:sig)
endfunction

function! s:out_port_wire_decl_pattern(sig) " reg _zz*
  return printf('\v^\s*(output)\s+%(wire\s+)?(\[.{-}\]\s*)*<%0s>', a:sig)
endfunction

function! s:wire_driver_pattern(sig) " _zz_* on driver side (LHS)
  return printf('\v^\s*assign\s+(<%0s>)\s*\=\s*(.{-})\s*;', a:sig)
endfunction

function! s:wire_receiver_pattern(sig) " _zz_* on receiver side (RHS)
  return printf('\v^\s*assign\s+(\w+)\s*\=\s*(<%0s>%(\[.{-}\])*)\s*;', a:sig)
endfunction

function! s:reg_driver_pattern(sig) " _zz_* on driver side (LHS)
  return printf('\v^\s*<%0s>\s*\=\s*(.{-})\s*;', a:sig)
endfunction

function! s:receiver_pattern(sig) " any of wire or reg 
  return printf('\v^\s*%(assign\s+)?(\w+)\s*\=\s*(<%0s>%(\[.{-}\])*)\s*;', a:sig) " NOTE: /\%( dosn't work here, so name will be in group(2)
endfunction

function! s:simplify_expression(expr)
  let expr = substitute(a:expr, '^{{\d\+{\(\w\+\)\[\d\+\]}}, \1}$', '$signed(\1)', 'g') " signed extend -> {{30{sig[1]}}, sig}
  let expr = substitute(expr, '^{\d\+''d0, \(\w\+\)}$', '\1', 'g') " replace {32'd0, sig} with sig
  return expr
endfunction

function! s:is_delete_wire(varname)
  let currview = winsaveview()
  let retval = 1

  let mlist = matchlist(getline("."), s:wire_decl_pattern(a:varname)) " When this function is called, cursor is  at wire declaration
  let varrange = mlist[1] " first group matching (...)

  if (varrange != "")
    " Replace d[31:0] with d if it is defined as wire [31:0] d
    silent exe printf('%%s/\<%s\>\s*%0s/%0s/ge', a:varname, escape(varrange, '[]'), a:varname)
  endif

  call cursor(1,1)

  if (search(s:wire_driver_pattern(a:varname), 'cw'))
    let mlist = matchlist(getline("."), s:wire_driver_pattern(a:varname))
    let varvalue = mlist[2] " first group matching (...)

    " replace _zz[10:0] with _zz and return 1, the upstream would delete _zz
    " and replace _zz with (expr) so (expr)[10:0] is not there anymore that
    " causes compilation errors
    silent exe printf('%%s/\v<%s>\s*\[.{-}\]/%s/ge', a:varname, a:varname)
    let retval = 1

    " DONT't REPLACE zz[10:0] with (expr)[10:0] --> " Be careful with (<expr>)... `_zz_1[10:0]` will be replaced by (<expr>)[10:0]
    " DONT't REPLACE zz[10:0] with (expr)[10:0] --> " First check if _zz_1 signal have `_zz_1[10:0]` in file, if yes, then replace with _TEMP_1, DON'T DELETE _zz_1
    " DONT't REPLACE zz[10:0] with (expr)[10:0] --> " The name of the _TEMP_1 will be decided later in the script
    " DONT't REPLACE zz[10:0] with (expr)[10:0] --> if (varvalue !~ '\v^\w+((\[.{-}\])?)*$') " varvalue not matches sig[10:0], then it's verilog expression
    " DONT't REPLACE zz[10:0] with (expr)[10:0] -->   if (search(printf('\v<%s>\s*\[.{-}\]', a:varname), 'w') != 0) " if value of _zz_1 is expression then don't delete signal if _zz_1[10:0] found in the file
    " DONT't REPLACE zz[10:0] with (expr)[10:0] -->     let retval = 0
    " DONT't REPLACE zz[10:0] with (expr)[10:0] -->   endif
    " DONT't REPLACE zz[10:0] with (expr)[10:0] --> endif
  end

  call winrestview(currview)
  return retval
endfunction

function! SpinalWire2Parameter(varname)
  let paramvalue = ""
  
  let paramname = toupper(a:varname)
  silent exe printf('%%s/\v<%0s>/%0s/', a:varname, paramname)

  call cursor(1,1)
  if (search(s:wire_decl_pattern(paramname), 'cw') != 0)

    let param_decl = getline(".")
    delete
    if (search(s:wire_driver_pattern(paramname), 'cw'))
      let mlist = matchlist(getline("."), s:wire_driver_pattern(paramname))
      let varvalue = mlist[2] " first group matching (...)
      if (varvalue == "")
        call SpinalError(printf("Error: Assign value not found for %0s parameter !!!", paramname))
        return 0
      endif

      delete

      call cursor(1,1)

      let param_decl = substitute(param_decl, '\v^\s*\zswire\s+(\[.{-}\]\s*)*', 'parameter ', '')

      " Add parameter in the first line of the module
      if (search('\v^\s*(<module> \w+) \#\(')) " Already parameterized module
        let param_decl = substitute(param_decl, ';', ' = ' . varvalue . ',', 'g')
      elseif (search('\v^\s*(<module> \w+) \(')) " Not a parameterized module
        s/(/#(/g
        call append(line('.'), ') (')
        let param_decl = substitute(param_decl, ';', ' = ' . varvalue . '', 'g')
      endif

      call append(line('.'), param_decl)
      
      return 1
    else
      call SpinalError(printf("Error: Assign statement not found for %0s wire !!!", paramname))
      return 0
    endif
  endif
endfunction

function! s:get_common_name_tuple(lhs, rhs) " if lhs=abc_1_0 , rhs=abc_12_0, returns abc_x_0
  if (a:lhs !~ '\v<\w+>' || a:rhs !~ '\v<\w+>') | return "" | endif
  let done = 0
  let lidx = 0
  let ridx = 0
  let char_list = []
  let num_list = []
  "echo a:lhs . " <> " . a:rhs
  while (done == 0)
    "echo char_list
    if (a:lhs[lidx] == "" && a:rhs[ridx] == "")
      let char_list += num_list
      let num_list = []
      let done = 1
    elseif (a:lhs[lidx] =~ '\W' || a:rhs[ridx] =~ '\W')
      let char_list += num_list
      let num_list = []
      let done = 1
    elseif (a:lhs[lidx] == a:rhs[ridx] && a:lhs[lidx] !~ '\d')
      let char_list += num_list + [a:lhs[lidx]]
      let num_list = []
      let lidx += 1
      let ridx += 1
    elseif (a:lhs[lidx] == a:rhs[ridx] && a:lhs[lidx] =~ '\d')
      let num_list += [a:lhs[lidx]]
      let lidx += 1
      let ridx += 1
    else
      let num_list = []
      if (a:lhs[lidx] !~ '\d' || a:rhs[ridx] !~ '\d') " Mismatch on other that 0-9, can't find common name, return 
        return ""
      endif

      " Skip digits and replace with 'x' on mismatch digits
      let char_list += ['x']
      while (a:lhs[lidx] =~ '\d')
        let lidx += 1
      endwhile

      while (a:rhs[ridx] =~ '\d')
        let ridx += 1
      endwhile
      
      if (a:lhs[lidx] != "" && a:rhs[ridx] != "")
        if (a:lhs[lidx] != a:rhs[ridx]) " Mismatch on other that 0-9, can't find common name, return
          return ""
        endif
      else
        let done = 1
      endif
    endif
  endwhile

  "echo join(char_list, "")
  return join(char_list, "")
endfunction

function! s:get_common_name(names) " if (abc_1_0 , abc_12_0...) returns abc_x_0
  " echo a:names FIXME: If SpinalCleanup command hangs uncomment this to debug
  let common_names = {}
  let cname = ""
  for idx in range(1,len(a:names) -1)
    let cname = s:get_common_name_tuple(a:names[idx], a:names[idx-1])
    if (cname == "") " Can't find common name
      return ""
    endif

    let common_names[cname] = 1
  endfor

  if (len(common_names) == 0 || len(common_names) != 1) " Can't find common name
    return ""
  endif

  " echo cname FIXME: If SpinalCleanup command hangs uncomment this to debug
  return cname
endfunction

function! SpinalCleanupSignals(varname) " This function is called with `_zz_*` signals

  let varvalue = ""

  call cursor(1,1)
  if (search(s:reg_decl_pattern(a:varname), 'cwn') != 0)
    " assign mysig = _zz_1;
    if (search(s:wire_receiver_pattern(a:varname), 'cw'))
      let mlist = matchlist(getline("."), s:wire_receiver_pattern(a:varname))
      let named_sig = mlist[1] " first group matching (...)
      let _zz_expr = mlist[2] " first group matching (...)
      if (named_sig == "" || _zz_expr == "")
        call SpinalError(printf("Error: Wire receiver not found for %0s reg !!!", a:varname))
        return 1 " skip current _zz_* signal and continue with next _zz_* signals
      endif

      delete
      call cursor(1,1)
      if (search(s:wire_decl_pattern(named_sig), 'cw') != 0) " Delete named signal
        delete
        silent exe printf('%%s/\v<%0s>/%0s/ge', named_sig, _zz_expr)
        silent exe printf('%%s/\v<%0s>/%0s/ge', a:varname, named_sig)
      elseif (search(s:out_port_wire_decl_pattern(named_sig), 'cw') != 0) " If named signal is declared as port then delete _zz_* instead of port
        " If named port is wire, add reg since it is processing _zz_* reg
        if (match(getline('.'), '\v<wire>') == -1) " don't have wire in port decl, add reg after output
          s/\v<output>/& reg/g
        else " port has wire, replace with reg
          s/\v<wire>/reg/ge
        endif
        call search(s:reg_decl_pattern(a:varname), 'cw') " ??? TODO: Assumption: port signal width is equal to _zz* signal width, if not, need to fix this...
        delete
        " Replace named with _zz_* expr except named port
        let named_sig_ptrn = printf('\v((input|output).*)@<!%s', named_sig)
        silent exe printf('%%s/\v<%0s>/%0s/ge', named_sig_ptrn, _zz_expr)
        silent exe printf('%%s/\v<%0s>/%0s/ge', a:varname, named_sig)
      else
        call SpinalError(printf("Error: Declaration not found for '%0s' signal for '%0s' reg !!!", named_sig, a:varname))
        return 0 " Something went wrong don't process next _zz_* signals
      endif
      return 1
    elseif (search(s:reg_driver_pattern(a:varname), 'cwn'))
      let drivers = []
      call cursor(1,1)
      while (search(s:reg_driver_pattern(a:varname), 'W'))
        let mlist = matchlist(getline("."), s:reg_driver_pattern(a:varname))
        let rhs = mlist[1] " first group matching (...)
	if (rhs == "")
	  echoerr printf("Error: Unexpected driving value for %0s reg !!!", a:varname)
	  return 0
	endif
        let drivers += [rhs]
      endwhile

      if (len(drivers) == 0)
        let cname = ''
      elseif (len(drivers) == 1)
        let cname = drivers[0]
      else
        let cname = s:get_common_name(drivers)
      endif

      if (cname == "")
        return 1 " always return 1 if couldn't process _zz_* reg, need to decide later what to do with them
      else
        let cname_uniq = s:get_uniq_name(cname)
        silent exe printf('%%s/\v<%0s>/%0s/g', a:varname, cname_uniq)
      endif
    else
      return 1 " always return 1 if couldn't process _zz_* reg, need to decide later what to do with them
    endif
  elseif (search(s:wire_decl_pattern(a:varname), 'cw') != 0)
    let temp_name = "<UNKNOWN>"
    let delete_zz = s:is_delete_wire(a:varname)
    if (delete_zz)
      delete
    else
      let temp_name = s:get_temp_sig()
      let s:temp_signals_to_review += [temp_name]
      silent exe printf('s/\v<%0s>/%0s/', a:varname, temp_name)
    endif
    if (search(s:wire_driver_pattern(a:varname), 'cw'))
      let mlist = matchlist(getline("."), s:wire_driver_pattern(a:varname))
      let varvalue = mlist[2] " first group matching (...)
      if (varvalue == "")
        call SpinalError(printf("Error: Assign value not found for %0s wire !!!", a:varname))
        return 0
      endif

      let varvalue = s:simplify_expression(varvalue)
      " If verilog expression istead of signal name or $signed(sig)
      if (varvalue =~ '\v^\$signed(\w+((\[.{-}\])?)*)$' && varvalue !~ '\v^\w+((\[.{-}\])?)*$')
        " If not in paranthesis ( and )
        if (!(varvalue[0] == "(" && varvalue[strlen(varvalue) -1] == ")"))
          let varvalue = printf('(%0s)', varvalue)
        endif
      endif

      if (delete_zz)
        delete
      else
        silent exe printf('s/\v<%0s>/%0s/', a:varname, temp_name)
        let varvalue = temp_name
      endif

      call cursor(1,1)
      let varvalue_escaped = escape(varvalue, '&/') " escape & in expression
      " signal with optional "(" and ")"
      if (varvalue =~ '\v^\(?\$signed') " remove duplicate $signed in $signed($signed(x) - $signed(y))
        silent exe printf('%%s/$signed(\s*\<%0s\>\s*)/%0s/ge', a:varname, varvalue_escaped)
      endif
      silent exe printf('%%s/\<%0s\>/%0s/ge', a:varname, varvalue_escaped)
      " Convert 32'h0000abc to 'habc
      " silent %s/\v%(\d+)?('[hHdDbB])0*(\w+)/\1\2/ge
      silent %s/\v(%(\d+)?'[hHdD])0*(\w+)/\1\2/ge
      return 1
    else
      call SpinalError(printf("Error: Assign statement not found for %0s wire !!!", a:varname))
      return 0
    endif
  endif
  return 0
endfunction

function! s:remove_temp_signal(tmpname)
  if (search(s:wire_receiver_pattern(a:tmpname), 'cw') != 0)
    let mlist = matchlist(getline("."), s:wire_receiver_pattern(a:tmpname))
    let named_sig = mlist[1] " lsh of assign statement
    if (named_sig == "")
      call SpinalError(printf("Error: not found name for %0s signal !!!", a:tmpname))
      return 1 " skip current _TEMP_* signal and continue with next _TEMP_* signals
    endif
    let uniq_name = s:get_uniq_name(named_sig)
    silent exe printf('%%s/\v<%0s>/%0s/g', a:tmpname, uniq_name)
    return 1
  elseif (search(s:receiver_pattern(a:tmpname), 'cw') != 0) " If received pattern didn't find for wire search for reg
    let mlist = matchlist(getline("."), s:receiver_pattern(a:tmpname))
    let named_sig = mlist[2] " lsh of assign statement
    if (named_sig == "")
      call SpinalError(printf("Error: not found name for %0s signal !!!", a:tmpname))
      return 1 " skip current _TEMP_* signal and continue with next _TEMP_* signals
    endif
    let uniq_name = s:get_uniq_name(named_sig)
    silent exe printf('%%s/\v<%0s>/%0s/g', a:tmpname, uniq_name)
    return 1
  elseif (search(s:wire_driver_pattern(a:tmpname), 'cw') != 0) " If name not found in received pattern generate name from driver pattern
    let mlist = matchlist(getline("."), s:wire_driver_pattern(a:tmpname))
    let named_sig = matchstr(mlist[2], '\v('')@<!(<[a-zA-Z]\w+>)') " Search name in rhs of assign expression
    if (named_sig == "")
      call SpinalError(printf("Error: not found name for %0s signal !!!", a:tmpname))
      return 1 " skip current _TEMP_* signal and continue with next _TEMP_* signals
    endif
    let uniq_name = s:get_uniq_name(named_sig)
    silent exe printf('%%s/\v<%0s>/%0s/g', a:tmpname, uniq_name)
    return 1
  endif

  return 0
endfunction

function! s:matchlist(ptrn) " search ptrn in file and get all matches in list
  let temp_sigs = {}

  call cursor(1,1)
  while (search(a:ptrn, 'W') != 0)
    let temp_sigs[matchstr(getline("."), a:ptrn)] = 1
  endwhile

  return keys(temp_sigs)
endfunction

function! s:remove_temp_signals()
  " First check if temp signals can be cleaned as per SpinalCleanupSignals
  " Note: SpinalCleanupSignals will update s:temp_signals_to_review so make a copy
  let tmp_list = deepcopy(s:temp_signals_to_review) + s:get_zz_signal_list()
  for tmpname in tmp_list
    call SpinalCleanupSignals(tmpname)
  endfor

  let tmp_list = s:matchlist('\v<_TEMP_\d+') " get list of all temporary signals in file

  for tmpname in tmp_list
    call s:remove_temp_signal(tmpname)
  endfor

endfunction

function! s:get_zz_signal_list()
  let siglist = {}
  call cursor(1,1)
  while (search('\v<_zz_', 'W'))
    let sig_zz = expand('<cword>')
    let siglist[sig_zz] = 1
  endwhile

  call cursor(1,1)
  while (search('\v<when_\w+_l\d+', 'W'))
    let sig_zz = expand('<cword>')
    let siglist[sig_zz] = 1
  endwhile

  return keys(siglist)
endfunction

function! SpinalParams2IncludeFile(filename, append_params_to_file)
  let param_pattern = '\v\#\(\_s*\zs%(parameter\s+.*,?\_s*)*\ze\n\s*\)'
  if (a:filename =~ '/')
    let filename = split(a:filename, '/')[-1]
  else
    let filename = a:filename
  endif
  let filepath = expand('%:p:h') . '/' . l:filename
  let firstline = search(param_pattern, 'wn')
  let lastline = search(param_pattern, 'wne')
  if (!filereadable(filepath))
    silent exe printf('%0s,%0sw %0s', firstline, lastline, filepath)
  elseif (a:append_params_to_file)
    silent exe printf('%0s,%0sw >> %0s', firstline, lastline, filepath)
  endif

  silent exe printf('%%s/%0s/`include "%0s"/e', param_pattern, escape(a:filename, '/\'))
endfunction

function! SpinalLength2Parameters() " Convert `(* __PARAM__SIZE = 8 *) wire [7:0] ` to `wire [SIZE-1:0] `
  let pattern = '^\s*\zs(\*\s*\<__PARAM__\(\w\+\)\>\s*=\s*\(\d\+\)\s*\*)\s*'
  while (search(pattern, 'c'))
    let mlist = matchlist(getline('.'), pattern)
    let paramname = toupper(mlist[1])
    let paramvalue = mlist[2]
    silent exe printf('s/%0s//g', pattern)
    silent exe printf('s/\v<%0s>/%0s/ge', paramvalue, paramname)
    silent exe printf('s/\v<%0s>/%0s-1/ge', paramvalue-1, paramname)
  endwhile
endfunction

function! SpinalWire2Parameters(...)
  TVarArg ['include_file', ''], ['append_params_to_file', 0]
  
  " Convert wire to parameters
  " NOTE: SpinalHDL need to generate wire with __PARAM__ prefix to convert the into parameters
  while (search('\<__PARAM__', 'c'))
    let paramname = matchstr(getline('.'), '\<__PARAM__\zs\w\+')
    silent exe printf('%%s/\<__PARAM__\(%0s\)\>/%0s/g', paramname, toupper(paramname))
    call SpinalWire2Parameter(toupper(paramname))
  endwhile
  
endfunction

function! SpinalConv2Parameters(...)
  TVarArg ['include_file', ''], ['append_params_to_file', 0]
  call SpinalLength2Parameters() " Convert `(* __PARAM__SIZE = 8 *) wire [7:0] ` to `wire [SIZE-1:0] `

  call SpinalWire2Parameters(include_file, append_params_to_file) " Convert `wire __PARAM__signal` to `parameter SIGNAL`

  call SpinalParams2IncludeFile(include_file, append_params_to_file) " Convert `module rtl #(<PARAMTERS>)` to `module rtl #(`include <PARAM_FILE>)`
endfunction

function! SpinalRemoveDuplicateWires() " Remove duplicate signals which have same wire assignments on RHS
  let duplicates_h = {} " expr : [sig1, sig2...]
  call cursor(1,1)
  while (search(s:wire_driver_pattern('\w+'), 'W'))
    let mlist = matchlist(getline("."), s:wire_driver_pattern('\w+'))
    let signame = mlist[1] " first group matching (...)
    let varvalue = mlist[2] " first group matching (...)

    if (has_key(duplicates_h, varvalue))
      let duplicates_h[varvalue] += [signame]
    else
      let duplicates_h[varvalue] = [signame]
    endif
  endwhile

  call filter(duplicates_h, 'len(v:val) > 1')

  if (len(duplicates_h) == 0)
    return 0
  endif

  for [key, values] in items(duplicates_h)
    let origsig = values[0]
    let values = values[1:]
    for l:value in values
      if (search(s:wire_decl_pattern(value), 'cw') != 0)
        if (search(s:wire_driver_pattern(value), 'cw')) " delete assignment statement first before wire declaration to make sure line number are same when deleting
          delete
          if (search(s:wire_decl_pattern(value), 'cw') != 0)
            delete
          endif

          silent exe printf('%%s/\v<%0s>/%0s/ge', value, origsig)
        endif
      endif
    endfor
  endfor

  return 1

endfunction

function! SpinalRemoveDuplicateWiresAll()
  for idx in range(5) " check 5 times (random number no logic)
    if (!SpinalRemoveDuplicateWires())
      break
    endif
  endfor
endfunction

function! SpinalCleanup(...)
  " redir! > ~/SpinalCleanup.log

  TVarArg ['include_file', ''], ['append_params_to_file', 0]

  let savesearch = @/

  call SpinalDeleteHeader()
  call SpinalCommonCleanup()

  let s:temp_signals_to_review = []

  for l:varname in s:get_zz_signal_list()
    call SpinalCleanupSignals(varname) " ??? break if SpinalCleanupSignals returns 0???
  endfor

  call SpinalConv2Parameters(include_file, append_params_to_file)

  " Post cleanup
  call s:remove_temp_signals()
  call SpinalRemoveDuplicateWiresAll()
  
  let s:temp_signals_to_review = []
  let @/ = savesearch

  " redir END
endfunction

nmap <F5> :silent call SpinalCleanup("../../src/dsc_parameters.v")
nmap <F6> :call SpinalCleanupSignals("")
nmap <F7> :call <SID>remove_temp_signals()
nmap <F8> :call SpinalWire2Parameter("")
nmap <F9> :call SpinalLength2Parameters()

