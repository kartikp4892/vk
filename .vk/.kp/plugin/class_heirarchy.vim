if (expand("%:p:t") !~ '\.sv')
  autocmd Bufread *.sv if !exists('s:sourced') | exe 'so ' . expand('<sfile>') | let s:sourced = '1' | endif
  finish
endif

if !exists('loaded_cproperty')
  command! -nargs=0 -bar KpCloseParentFolds call s:Cproperty_close_parent_folds(s:Cproperty_heap_i)
  command! -nargs=0 -bar KpOpen call s:Cproperty_Window_Open()
  command! -nargs=0 -bar KpClose call s:Cproperty_Window_Close()
  command! -nargs=+ -complete=dir KpAddFilesRecursive let s:Cproperty_all_classes_i = s:Cproperty_process_dir(<f-args>)

  " Cproperty completion for the object under cursor within the class
  imap  =<SID>Cproperty_check_for_completion()

  " Trick to get the current script ID
  map <SID>xx <SID>xx
  let s:cproperty_sid = substitute(maparg('<SID>xx'), '<SNR>\(\d\+_\)xx$',
                              \ '\1', '')
  unmap <SID>xx

  exe 'autocmd FuncUndefined *' . s:cproperty_sid . 'Cproperty_* source ' .
              \ escape(expand('<sfile>'), ' ')

  let loaded_cproperty = 'yes'
  finish
endif

unlet! s:cproperty_sid

""----------------------------------------------------------------------------
"" Script Starts from here.
""----------------------------------------------------------------------------
" To store info for balloon expression
let s:Cproperty_info = {'idx': -1, 'info': ''}

" To store the reference of file for a class property so can be jump to the reference location
" Formate: s:Cproperty_file_ref = {file_ref => {<file_name> => [<line1>, <line2>, ...]}}
let s:Cproperty_file_ref = {'file_ref': {}}

fun! s:Cproperty_file_ref.Print() dict
  let str = ''
  for [key,value] in keys(self.file_ref)
    let str .= key . ': ' . string(self[key]) . "\n"
  endfor
endfun

" Tree Node: {fold_level: no, start: ln, end: ln}
let s:Cproperty_node = {'fold_level': -1, 'start': -1, 'end': -1}

fun! s:Cproperty_node.new() dict
  return deepcopy(self)
endfun

fun! s:Cproperty_node.add(fold_level, start, end) dict
  let self.fold_level = a:fold_level
  let self.start = a:start
  let self.end = a:end
endfun

fun! s:Cproperty_node.print() dict
  let str = ''
  let str .= 'fold_level = ' . self.fold_level . "\n"
  let str .= 'start = ' . self.start . "\n"
  let str .= 'end = ' . self.end . "\n"
  return str
endfun

" Containing fold information for Cproperty Window
let s:Cproperty_heap = {'folds': [], 'cur_fold_level': -1, 'cur_line': -1}
let s:Cproperty_heap_i = {}

fun! s:Cproperty_heap.new() dict
  return deepcopy(self)
endfun

fun! s:Cproperty_heap.add_node(fold_level, start, end) dict
  let l:Cproperty_node_i = s:Cproperty_node.new()
  call l:Cproperty_node_i.add(a:fold_level, a:start, a:end)
  call add(self.folds, l:Cproperty_node_i)
endfun

fun! s:Cproperty_heap.sort_folds() dict
  call sort(self.folds, "s:Cproperty_node_compare")
endfun

fun! s:Cproperty_heap.create_class_folds(class)
  "class
  let self.cur_fold_level += 1
  let self.cur_line += 1
  let l:fold_{self.cur_fold_level}_start = self.cur_line

  " Store the file reference of lines to a variable
  if !exists('s:Cproperty_file_ref.file_ref[a:class.source_path]')
    let s:Cproperty_file_ref.file_ref[a:class.source_path] = []
  endif
  call add(s:Cproperty_file_ref.file_ref[a:class.source_path], self.cur_line)

  "Get Info for ballon evaluation
  let l:info = split(a:class.class, '##')[-1]
  let s:Cproperty_info[self.cur_line] = l:info

  let self.cur_fold_level += 1
  "parent
  if (type(a:class.parent) == type({}))
    let self.cur_line += 1
    let l:fold_{self.cur_fold_level}_start = self.cur_line

    " Recursively create folds for parent classes
    call self.create_class_folds(a:class.parent)

    let l:fold_{self.cur_fold_level}_end = self.cur_line - 1
    call self.add_node(self.cur_fold_level, l:fold_{self.cur_fold_level}_start, l:fold_{self.cur_fold_level}_end)
  else
    if (a:class.parent != '')
      let self.cur_line += 1
      let l:fold_{self.cur_fold_level}_start = self.cur_line

      let self.cur_line += 1

      " Store the file reference of lines to a variable
      call add(s:Cproperty_file_ref.file_ref[a:class.source_path], self.cur_line)

      "Get Info for ballon evaluation
      let l:info = split(a:class.class, '##')[-1]
      let s:Cproperty_info[self.cur_line] = l:info

      let l:fold_{self.cur_fold_level}_end = self.cur_line
      let self.cur_line += 1

      call self.add_node(self.cur_fold_level, l:fold_{self.cur_fold_level}_start, l:fold_{self.cur_fold_level}_end)
    endif
  endif

  "variables
  if len(a:class.vars) != 0
    let self.cur_line += 1
    let l:fold_{self.cur_fold_level}_start = self.cur_line

    for l:var in a:class.vars
      let self.cur_line += 1

      " Store the file reference of lines to a variable
      call add(s:Cproperty_file_ref.file_ref[a:class.source_path], self.cur_line)

      "Get Info for ballon evaluation
      let l:info = split(l:var, '##')[-1]
      let s:Cproperty_info[self.cur_line] = l:info
    endfor
    let l:fold_{self.cur_fold_level}_end = self.cur_line
    let self.cur_line += 1
    call self.add_node(self.cur_fold_level, l:fold_{self.cur_fold_level}_start, l:fold_{self.cur_fold_level}_end)
  endif

  "methods
  if len(a:class.methods) != 0
    let self.cur_line += 1
    let l:fold_{self.cur_fold_level}_start = self.cur_line

    for l:method in a:class.methods
      let self.cur_line += 1

      " Store the file reference of lines to a variable
      call add(s:Cproperty_file_ref.file_ref[a:class.source_path], self.cur_line)

      "Get Info for ballon evaluation
      let l:info = split(l:method, '##')[-1]
      let s:Cproperty_info[self.cur_line] = l:info
    endfor
    let l:fold_{self.cur_fold_level}_end = self.cur_line
    let self.cur_line += 1
    call self.add_node(self.cur_fold_level, l:fold_{self.cur_fold_level}_start, l:fold_{self.cur_fold_level}_end)
  endif

  let self.cur_fold_level -= 1
  let l:fold_{self.cur_fold_level}_end = self.cur_line - 1
  call self.add_node(self.cur_fold_level, l:fold_{self.cur_fold_level}_start, l:fold_{self.cur_fold_level}_end)

  let self.cur_fold_level -= 1
endfun

fun! s:Cproperty_heap.create_file_folds(buf_files, classes)
  let self.cur_fold_level = 1
  let self.cur_line = 1
  let l:fold_start = 1
  for l:file in a:buf_files
    for l:class in values(filter(deepcopy(a:classes.classes), 'v:val.source_path =~ l:file'))
      call self.create_class_folds(l:class)
    endfor
    let l:fold_end = self.cur_line
    call self.add_node(self.cur_fold_level, l:fold_start, l:fold_end)
    let l:fold_start = l:fold_end + 1
  endfor
endfun

fun! s:Cproperty_heap.print() dict
  let str = ''
  for l:node in self.folds
    let str .= l:node.print() . "\n"
  endfor
  return str
endfun

fun! s:Cproperty_node_compare(node1, node2)
  return (a:node1.fold_level == a:node2.fold_level) ? 0 : (a:node1.fold_level > a:node2.fold_level) ? -1 : 1
endfun

let s:Cproperty_classes = {'classes' : {}}
" s:Cproperty_classes = {classes => {class_name => class_obj, ...}}
let s:Cproperty_buf_classes_i = {}
let s:Cproperty_all_classes_i = {}

let s:Cproperty_class = {'class' : '', 'parent' : '', 'source_path' : '', 'vars' : [], 'methods' : []}
" s:Cproperty_class = {class => Name-line_no-line_info
"            parent => Parent_Class_Name/Parent_Class_Object
"            vars => [type:name-line_no-line_info, ...]
"            methods => [type:name-line_no-line_info, ...]}

let s:Cproperty_buf_files = []

" ============================================================================
"  Classes
" ============================================================================
" @param a:1 = 'List' of Buffer files to for which class should be printed
fun! s:Cproperty_classes.Print(...) dict
  let l:str = ''
  if (a:0 == 1)
    let l:buf_files = a:1
    for l:file in l:buf_files
      let l:str .= fnamemodify(l:file, ":t") . " (" . fnamemodify(l:file, ":p:h") . ")\n"
      for l:class in values(filter(deepcopy(self.classes), 'v:val.source_path =~ l:file'))
        let l:str .= l:class.Print("  ")
      endfor
    endfor
  elseif (a:0 == 0)
    for l:class in values(self.classes)
      let l:str .= l:class.Print("  ")
    endfor
  endif

  return l:str
endfun

" ----------------------------------------------------------------------------
"  Get Properties of parent class which the class extends to
" ----------------------------------------------------------------------------
" @param a:1 = Classes object contains all class reference for loop up
fun! s:Cproperty_classes.GetHasAProperty(...) dict
  if (a:0 != 0)
    let l:classes = a:1
  else
    let l:classes = self
  endif
  for l:class in values(self.classes)
    call l:class.GetHasAProperty(l:classes)
  endfor
endfun

" ============================================================================
"  Class
" ============================================================================
fun! s:Cproperty_class.new() dict
  let l:class = deepcopy(self)
  return l:class
endfun

" Get list of variables and methods from the class and parent class recursively.
fun! s:Cproperty_class.get_property_list() dict
  let l:properties = []

  if (type(self.parent) == type({}))
    call extend(l:properties, self.parent.get_property_list())
  endif

  if (len(self.vars) != 0)
    for l:var in self.vars
      let l:item = {}
      let [l:data_type, l:var_name, @_, @_] = split(l:var, '##')

      " Remove [] from arrary variable and add to array type
      let l:data_type = matchstr(l:var_name, '\(\[.\{-}]\)\+\ze\w\+') . l:data_type
      let l:data_type = l:data_type . matchstr(l:var_name, '\w\+\zs\(\[.\{-}]\)\+')
      let l:var_name = substitute(l:var_name, '\(\[.\{-}]\)\+\ze\w\+\|\w\+\zs\(\[.\{-}]\)\+', '', 'g')

      let l:item.menu = l:data_type
      let l:item.word = l:var_name
      call add(l:properties, copy(l:item))
    endfor
  endif

  if (len(self.methods) != 0)
    for l:method in self.methods
      let l:item = {}
      let [l:method_type, l:method_name, @_, @_] = split(l:method, '##')
      let l:item.menu = l:method_type
      let l:item.word = l:method_name
      call add(l:properties, copy(l:item))
    endfor
  endif

  return l:properties

endfun

" @param a:1 = indent
fun! s:Cproperty_class.Print(...) dict
  let l:str = ''
  if (a:0 != 0)
    let l:indent = a:1
  else
    let l:indent = ''
  endif

  " Discard the info as the expresion is evaluated while calculating the fold
  let [l:class, l:ln, @_] = split(self.class, '##')

  let l:str .= l:indent . l:class . "  Class  <" . l:ln . ">\n"

  if (type(self.parent) == type({}))
    let l:str .= l:indent . "  Parent:\n"

    let l:str .= self.parent.Print(l:indent . "    ")

  else
    if (self.parent != '')
      let l:str .= l:indent . "  Parent:\n"
      let l:str .= l:indent . '    ' . self.parent . "\n"

      let l:str .= l:indent . "\n"
    endif
  endif


  if (len(self.vars) != 0)
    let l:str .= l:indent  . "  Variables:\n"

    for l:var in self.vars
      let [l:data_type, l:var_name, l:ln, @_] = split(l:var, '##')
      let l:txt = l:var_name . "  " . l:data_type
      let l:str .= l:indent . "    " . l:txt . "  <" . l:ln . ">\n"
    endfor
    let l:str .= l:indent . "\n"
  endif

  if (len(self.methods) != 0)
    let l:str .= l:indent  . "  Methods:\n"

    for l:method in self.methods
      let [l:method_type, l:method_name, l:ln, @_] = split(l:method, '##')
      let l:txt = l:method_name . "  " . l:method_type
      let l:str .= l:indent . "    " . l:txt . "  <" . l:ln . ">\n"
    endfor
    let l:str .= l:indent . "\n"
  endif

  return l:str
endfun

" ----------------------------------------------------------------------------
"  Get Properties of parent class which the class extends to
" ----------------------------------------------------------------------------
fun! s:Cproperty_class.GetHasAProperty(classes) dict
  if (type(self.parent) == type(""))
    if (self.parent != '')
      if (exists('a:classes.classes[self.parent]'))
        let self.parent = a:classes.classes[self.parent]
        call self.parent.GetHasAProperty(a:classes)
      else
        "For debug
        " echohl Error
        " echo self.parent . ': Class not defined'
        " echohl None
      endif
    endif
  endif
endfun


" ============================================================================
"  Functions
" ============================================================================
" @param a:1 = <line1>
" @param a:2 = <line2>
" Description: If a:1 and a:2 is given read lines from <line1> to <line2>
"              If only a:1 is given then read line from the <line1> to the <end>
fun! s:Cproperty_process_file(file, ...)
  let l:inside_class = 0
  let l:inside_fun = 0
  let l:cmt_line = 0
  let l:class_name = ''
  let l:parent_name = ''
  let l:fn_name = ''
  let l:ln_no = 0

  if (a:0 >= 2)
    if (a:1 !~ '^\d\+$' || a:2 !~ '^\d\+$')
      call s:Cproperty_Warning_Msg("Error: Invalid line numbers, reading whole file")
      let l:line_start = ''
      let l:line_end = ''
    endif
    let l:line_start = a:1 - 1
    let l:line_end = a:2 - 1

    " Set current line number
    let l:ln_no = l:line_start
  elseif (a:0 == 1)
    if (a:1 !~ '^\d\+$')
      call s:Cproperty_Warning_Msg("Error: Invalid line numbers, reading whole file")
      let l:line_start = ''
      let l:line_end = ''
    endif
    let l:line_start = a:1 - 1
    let l:line_end = ''

    " Set current line number
    let l:ln_no = l:line_start
  else
    let l:line_start = ''
    let l:line_end = ''
  endif

  if !filereadable(a:file)
    call s:Cproperty_Warning_Msg("Error: Unable to read file " . a:file)
    return
  endif

  " Add file to the Cproperty file list
  call add(s:Cproperty_buf_files, a:file)

  " Create Objects
  let l:classes = deepcopy(s:Cproperty_classes)
  let l:class = deepcopy(s:Cproperty_class)

  let l:lines = eval('readfile(a:file)[' . l:line_start . ':' . l:line_end . ']')
  for l:line in l:lines
    "Bebug
    "call s:Cproperty_Log_Msg(l:line)

    let l:ln_no += 1

    if (l:line =~ '^\s*//\|^\s*$')
      continue
    endif

    let l:line = substitute(l:line, '\/\/.*', '', 'g')
    let l:line_info = l:line

    if (l:line =~ '\V/*')
      let l:cmt_line = 1
    endif

    if (l:line =~ '\V*/')
      let l:cmt_line = 0
    endif

    " Make sure that keywords are not inside string expression.
    let l:line = substitute(l:line, '".\{-}"', '', 'g')

    " line not define data type or not a part of `definde
    if (l:line =~ '\v<typedef>|\\$')
      continue
    endif
    "class
    if (l:cmt_line == 0 && l:line =~ '\v<class>')
      if (line !~ '\v<endclass>')
        let l:inside_class = 1
      endif
      let l:class = deepcopy(s:Cproperty_class)
      let l:class_name = matchstr(l:line, 'class\s\+\zs\w\+')

      if (l:class_name == '')
        continue
      endif

      let l:class.class = l:class_name . '##' . l:ln_no . '##' . l:line_info
      let l:class.source_path = a:file

      if (l:line =~ '\v<extends>')
        let l:parent_name = matchstr(l:line, 'extends\s\+\zs\w\+')
        " The parent name will be updated to the parent class object by GetHasAProperty
        let l:class.parent = l:parent_name
      endif
      continue
    "end class
    elseif (l:cmt_line == 0 && l:line =~ '\v<endclass>')
      if (l:class_name == '')
        "For Debug
        " echohl Error
        " echo a:file . ": " . l:line
        " echohl None
        continue
      endif
      let l:classes.classes[l:class_name] = deepcopy(l:class)
      let l:inside_class = 0
      continue
    "method
    elseif (l:inside_class == 1 && l:cmt_line == 0 && l:line =~ '\v%(<function>|<task>)')
      let l:fn_name = matchstr(l:line, '\w\+\ze\s*(')
      if (l:fn_name == '')
        continue
      endif
      if (l:line =~ '\<function\>')
        let l:fn_name = 'function##' . l:fn_name . '##' . l:ln_no . '##' . l:line_info
      else
        let l:fn_name = 'task##' . l:fn_name . '##' . l:ln_no . '##' . l:line_info
      endif
      call add(l:class.methods, l:fn_name)

      if (l:line !~ '\v<extern>|<endfunction>|<endtask>|<pure virtual>')
        let l:inside_fun = 1
      endif
      continue
    "end method
    elseif (l:inside_class == 1 && l:cmt_line == 0 && l:line =~ '\v%(<endfunction>|<endtask>)')
      let l:inside_fun = 0
      continue
    endif

    " Get Variable Type & name
    if (l:inside_class == 1 && l:inside_fun == 0)

      " If generic parameters are given "#(parameter1, ...)" remove it from the property declaration
      let l:line = substitute(l:line, '#(.\{-})', '', 'g')

      " Check if class property
      if (l:line !~ '\v\(|\)|%(\=\s*)@<!\{')
        let l:str = l:line
        if (l:str !~ ';\s*$')
          continue
        endif
        let l:str = substitute(l:str, '^\s*\<rand\>\s*', '', 'g')
        let l:str = substitute(l:str, '^\s*\<static\>\s*', '', 'g')
        let l:str = substitute(l:str, '^\s*\<protected\>\s*', '', 'g')
        let l:str = substitute(l:str, '^\s*\<local\>\s*', '', 'g')

        let l:str = substitute(l:str, '^\s*\|\s*$', '', 'g')
        let l:str = substitute(l:str, '\v\{.{-}\}', '', 'g')
        let l:str = substitute(l:str, '\v\s*(\[.{-}\])\s*', '\1', 'g')
        let l:str = substitute(l:str, '\v\s*\=.{-}[,;]', '', 'g')
        let l:type = matchstr(l:str, '^\w\+')
        let l:str = substitute(l:str, '^\w\+\s*', '', 'g')
        let l:str = substitute(l:str, '\s*;.*', '', 'g')
        let l:vars = split(l:str, '\s*,\s*')
        call filter(l:vars, 'v:val !~ "\\W" || v:val =~ "\\[.\\{-}\\]"')
        for l:var in l:vars
          if (l:type == '' || l:var == '')
            continue
          endif
          call add(l:class.vars, l:type . '##' . l:var . '##' . l:ln_no . '##' . l:line_info)
        endfor
      endif
    endif
  endfor
  return l:classes
endfun

" Read all the system verilog files recursively from Base Dir.
" And create classes object containing all the classes within file
fun! s:Cproperty_process_dir(base_dir)
  let l:classes = deepcopy(s:Cproperty_classes)
  let l:base_dir = fnamemodify(a:base_dir, ':p')

  if !isdirectory(l:base_dir)
      call s:Cproperty_Warning_Msg('Error: ' . l:base_dir . ' is not a directory')
      return
  endif

  let l:env_files_str = system('find ' . a:base_dir . ' -iname "*.sv*"')
  let l:env_files = split(l:env_files_str, "\n")
  call filter(l:env_files, 'v:val =~ "\\.sv[ih]\\?$"')
  for l:env_file in l:env_files
    call extend(l:classes.classes, s:Cproperty_process_file(l:env_file).classes, "keep")
  endfor
  return l:classes
endfun

""############################################################################
"" Class Property Window Creation
""############################################################################

""----------------------------------------------------------------------------
"" TODO: Create Help lines in Cproperty window when user press <F1>
""----------------------------------------------------------------------------

""------------------------ Globel Variables ----------------------------------
let s:Cproperty_winsize_chgd = -1
let TagList_title = '__Tag_List__'
let Cproperty_Use_Horiz_Window = ''

" Open the vertically split taglist window on the left or on the right
" side.  This setting is relevant only if Cproperty_Use_Horiz_Window is set to
" zero (i.e.  only for vertically split windows)
let Cproperty_Use_Right_Window = 0

" Taglist window is maximized or not
let s:Cproperty_win_maximized = 0

" Horizontally split taglist window height setting
let Cproperty_WinHeight = 10

" Vertically split taglist window width setting
let Cproperty_WinWidth = 30

" Increase Vim window width to display vertically split taglist window.
let Cproperty_Inc_Winwidth = 1

" Automatically update the taglist window to display tags for newly
" edited files
let Cproperty_Auto_Update = 1

" Recusively show parent classes
let Cproperty_show_parent_class = 1

let s:Cproperty_debug_file = ''
let s:Cproperty_msg = ''
let s:Cproperty_debug = 1

" Automatically close the folds for the non-active files in the taglist
" window
let Cproperty_File_Fold_Auto_Close = 0
""------------------- End of Globel Variables --------------------------------

" Cproperty_Log_Msg
" Log the supplied debug message along with the time
function! s:Cproperty_Log_Msg(msg)
    if s:Cproperty_debug
        if s:Cproperty_debug_file != ''
            exe 'redir >> ' . s:Cproperty_debug_file
            silent echon strftime('%H:%M:%S') . ': ' . a:msg . "\n"
            redir END
        else
            " Log the message into a variable
            " Retain only the last 3000 characters
            let len = strlen(s:Cproperty_msg)
            if len > 3000
                let s:Cproperty_msg = strpart(s:Cproperty_msg, len - 3000)
            endif
            let s:Cproperty_msg = s:Cproperty_msg . strftime('%H:%M:%S') . ': ' . 
                        \ a:msg . "\n"
        endif
    endif
endfunction

" Cproperty_Warning_Msg()
" Display a message using WarningMsg highlight group
function! s:Cproperty_Warning_Msg(msg)
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfunction

" Cproperty_Window_Init
" Set the default options for the taglist window
function! s:Cproperty_Window_Init()

    " The 'readonly' option should not be set for the taglist buffer.
    " If Vim is started as "view/gview" or if the ":view" command is
    " used, then the 'readonly' option is set for all the buffers.
    " Unset it for the taglist buffer
    setlocal noreadonly

    " Set the taglist buffer filetype to taglist
    setlocal filetype=Cproperty

    " Define taglist window element highlighting
    syntax match TagListComment '^" .*'
    syntax match TagListFileName '^[^" ].*$'
    syntax match TagListTitle '\w*\%(\s*Class\>\)\@='
    syntax match TagListIdentifier  '\%(\S\+\s\+\)\@<=\w\+'
    syntax match TagListProperty1  '^\(    \)\+\w*:$'
    syntax match TagListProperty2  '^\(        \)\+\w*:$'
    syntax match TagListLnum  '<.\{-}>'

    " Define the highlighting only if colors are supported
    if has('gui_running') || &t_Co > 2
      " Colors to highlight various taglist window elements
      " use highlight groups.
      highlight default link TagListTagName Search
      " Colors to highlight comments and titles

      highlight default link TagListComment Comment

      highlight default link TagListTitle Title

      highlight default TagListFileName guibg=Grey ctermbg=darkgray
                  \ guifg=white ctermfg=white

      highlight default link TagListIdentifier Identifier

      highlight default link TagListProperty1 Statement
      highlight default link TagListProperty2 sysVerilogTask

      highlight default link TagListLnum Ignore
    else
      highlight default TagListTagName term=reverse cterm=reverse
    endif

    " Folding related settings
    setlocal foldenable
    setlocal foldminlines=0
    setlocal foldmethod=manual
    setlocal foldlevel=9999

    setlocal foldcolumn=3
    setlocal foldtext=v:folddashes.Cproperty_fold_text(v:foldstart)

    silent! setlocal buftype=nofile
    silent! setlocal bufhidden=delete
    silent! setlocal noswapfile
    " Due to a bug in Vim 6.0, the winbufnr() function fails for unlisted
    " buffers. So if the taglist buffer is unlisted, multiple taglist
    " windows will be opened. This bug is fixed in Vim 6.1 and above
    if v:version >= 601
        silent! setlocal nobuflisted
    endif

    silent! setlocal nowrap

    " If the 'number' option is set in the source window, it will affect the
    " Cproperty window. So forcefully disable 'number' option for the taCproperty
    " window
    silent! setlocal nonumber

    if exists('&relativenumber')
        silent! setlocal norelativenumber
    endif

    " Use fixed height when horizontally split window is used
    if g:Cproperty_Use_Horiz_Window
      if v:version >= 602
        set winfixheight
      endif
    endif

    if !g:Cproperty_Use_Horiz_Window && v:version >= 700
      set winfixwidth
    endif

    " Setup balloon evaluation to display tag prototype
    if v:version >= 700 && has('balloon_eval')
        setlocal balloonexpr=Cproperty_Ballon_Expr()
        set ballooneval
    endif

    " Setup the cpoptions properly for the maps to work
    let l:old_cpoptions = &cpoptions
    set cpoptions&vim

    " Create buffer local mappings for jumping to the tags and sorting the list
    nnoremap <buffer> <silent> x :call <SID>Cproperty_Window_Zoom()<CR>
    nnoremap <buffer> <silent> q :close<CR>
    nnoremap <buffer> <silent> + :silent! foldopen \| call <SID>Cproperty_update_fold_col()<CR>
    nnoremap <buffer> <silent> - :silent! foldclose \| call <SID>Cproperty_update_fold_col()<CR>
    nnoremap <buffer> <silent> * :silent! %foldopen \| call <SID>Cproperty_update_fold_col()<CR>
    nnoremap <buffer> <silent> = :silent! %foldclose \| call <SID>Cproperty_update_fold_col()<CR>
    nnoremap <buffer> <silent> <kPlus> :silent! foldopen \| call <SID>Cproperty_update_fold_col()<CR>
    nnoremap <buffer> <silent> <kMinus> :silent! foldclose \| call <SID>Cproperty_update_fold_col()<CR>
    nnoremap <buffer> <silent> <kMultiply> :silent! %foldopen! \| call <SID>Cproperty_update_fold_col()<CR>

    " Close all parent class folds recursive
    nnoremap <buffer> <silent> c :silent! KpCloseParentFolds<CR>

    nnoremap <buffer> <silent> <2-LeftMouse>
                \ :call <SID>Cproperty_Window_Jump_To_Property()<CR>

    " Update foldcolumn if <LeftMouse> doesn't change the cursor to another window than Tag List Window
    nnoremap <buffer> <silent> <LeftMouse> <LeftMouse>:if  (expand("%") == '__Tag_List__') \| call <SID>Cproperty_update_fold_col() \| endif<CR>
    " TODO

    " Insert Mode Mapping
    inoremap <buffer> <silent> x             <C-o>:call <SID>Cproperty_Window_Zoom()<CR>
    inoremap <buffer> <silent> q             <C-o>:close<CR>
    inoremap <buffer> <silent> +             <C-o>:silent! foldopen \| call <SID>Cproperty_update_fold_col()<CR>
    inoremap <buffer> <silent> -             <C-o>:silent! foldclose \| call <SID>Cproperty_update_fold_col()<CR>
    inoremap <buffer> <silent> *             <C-o>:silent! %foldopen \| call <SID>Cproperty_update_fold_col()<CR>
    inoremap <buffer> <silent> =             <C-o>:silent! %foldclose \| call <SID>Cproperty_update_fold_col()<CR>
    inoremap <buffer> <silent> <kPlus>       <C-o>:silent! foldopen \| call <SID>Cproperty_update_fold_col()<CR>
    inoremap <buffer> <silent> <kMinus>      <C-o>:silent! foldclose \| call <SID>Cproperty_update_fold_col()<CR>
    inoremap <buffer> <silent> <kMultiply>   <C-o>:silent! %foldopen! \| call <SID>Cproperty_update_fold_col()<CR>
    " TODO

    " Restore the previous cpoptions settings
    let &cpoptions = l:old_cpoptions
endfunction

fun! Cproperty_fold_text(ln)
  return substitute(getline(a:ln),'^   ', '', '')
endfun

" Cproperty_Window_Create
" Create a new taglist window. If it is already open, jump to it
function! s:Cproperty_Window_Create()
    " If the window is open, jump to it
    let l:winnum = bufwinnr(g:TagList_title)
    if l:winnum != -1
        " Jump to the existing window
        if winnr() != l:winnum
            exe l:winnum . 'wincmd w'
        endif
        return
    endif

    " Create a new window. If user prefers a horizontal window, then open
    " a horizontally split window. Otherwise open a vertically split
    " window
    if g:Cproperty_Use_Horiz_Window
        " Open a horizontally split window
        let l:win_dir = 'botright'
        " Horizontal window height
        let l:win_size = g:Cproperty_WinHeight
    else
        if s:Cproperty_winsize_chgd == -1
            " Open a vertically split window. Increase the window size, if
            " needed, to accomodate the new window
            if g:Cproperty_Inc_Winwidth &&
                        \ &columns < (80 + g:Cproperty_WinWidth)
                " Save the original window position
                let s:Cproperty_pre_winx = getwinposx()
                let s:Cproperty_pre_winy = getwinposy()

                " one extra column is needed to include the vertical split
                let &columns= &columns + g:Cproperty_WinWidth + 1

                let s:Cproperty_winsize_chgd = 1
            else
                let s:Cproperty_winsize_chgd = 0
            endif
        endif

        if g:Cproperty_Use_Right_Window
            " Open the window at the rightmost place
            let l:win_dir = 'botright vertical'
        else
            " Open the window at the leftmost place
            let l:win_dir = 'topleft vertical'
        endif
        let l:win_size = g:Cproperty_WinWidth
    endif

    " If the tag listing temporary buffer already exists, then reuse it.
    " Otherwise create a new buffer
    let l:bufnum = bufnr(g:TagList_title)
    if l:bufnum == -1
        " Create a new buffer
        let l:wcmd = g:TagList_title
    else
        " Edit the existing buffer
        let l:wcmd = '+buffer' . l:bufnum
    endif

    " Create the taglist window
    " Preserve the alternate file
    let l:cmd_mod = (v:version >= 700) ? 'keepalt ' : ''
    exe 'silent! ' . l:cmd_mod . l:win_dir . ' ' . l:win_size . 'split ' . l:wcmd

    " Save the new window position
    let s:Cproperty_winx = getwinposx()
    let s:Cproperty_winy = getwinposy()

    " Initialize the taglist window
    call s:Cproperty_Window_Init()
endfunction

" Cproperty_Window_Zoom
" Zoom (maximize/minimize) the taglist window
function! s:Cproperty_Window_Zoom()
    if s:Cproperty_win_maximized
        " Restore the window back to the previous size
        if g:Cproperty_Use_Horiz_Window
            exe 'resize ' . g:Cproperty_WinHeight
        else
            exe 'vert resize ' . g:Cproperty_WinWidth
        endif
        let s:Cproperty_win_maximized = 0
    else
        " Set the window size to the maximum possible without closing other
        " windows
        if g:Cproperty_Use_Horiz_Window
            resize
        else
            vert resize
        endif
        let s:Cproperty_win_maximized = 1
    endif
endfunction

" Cproperty_Window_Open
" Open and refresh the taglist window
function! s:Cproperty_Window_Open()
    " If the window is open, jump to it
    let winnum = bufwinnr(g:TagList_title)
    if winnum != -1
        " Jump to the existing window
        if winnr() != winnum
            exe winnum . 'wincmd w'
        endif
        return
    endif

    " Get the filename and filetype for the specified buffer
    let curbuf_name = fnamemodify(bufname('%'), ':p')
    let cur_lnum = line('.')

    " Open the taglist window
    call s:Cproperty_Window_Create()

    call s:Cproperty_Window_Refresh(curbuf_name)

endfunction

" Cproperty_Window_Close
" Close the taglist window
function! s:Cproperty_Window_Close()
    " Make sure the taglist window exists
    let l:winnum = bufwinnr(g:TagList_title)
    if l:winnum == -1
        call s:Cproperty_Warning_Msg('Error: Taglist window is not open')
        return
    endif

    if winnr() == l:winnum
        " Already in the taglist window. Close it and return
        if winbufnr(2) != -1
            " If a window other than the taglist window is open,
            " then only close the taglist window.
            close
        endif
    else
        " Goto the taglist window, close it and then come back to the
        " original window
        let l:curbufnr = bufnr('%')
        exe l:winnum . 'wincmd w'
        close
        " Need to jump back to the original window only if we are not
        " already in that window
        let l:winnum = bufwinnr(l:curbufnr)
        if winnr() != l:winnum
            exe l:winnum . 'wincmd w'
        endif
    endif
endfunction

" Cproperty_Window_Refresh
" Display the tags for all the files in the taglist window
function! s:Cproperty_Window_Refresh(buffile)
    " Set report option to a huge value to prevent informational messages
    " while deleting the lines
    let old_report = &report
    set report=99999

    " Mark the buffer as modifiable
    setlocal modifiable

    " Delete the contents of the buffer to the black-hole register
    silent! %delete _

    " Mark the buffer as not modifiable
    setlocal nomodifiable

    " Restore the report option
    let &report = old_report

    " Kp: Refresh Cproperty list
    let s:Cproperty_buf_files = []

    let s:Cproperty_buf_classes_i = s:Cproperty_process_file(a:buffile)

    " Whether to show parent class recursively
    if (g:Cproperty_show_parent_class == 1)
      " If reference classes is available to get parent class
      if !empty(s:Cproperty_all_classes_i)
        call s:Cproperty_buf_classes_i.GetHasAProperty(s:Cproperty_all_classes_i)
      else
        call s:Cproperty_buf_classes_i.GetHasAProperty()
      endif
    endif

    call s:Cproperty_Window_Refresh_File(s:Cproperty_buf_classes_i)

    " If Cproperty_File_Fold_Auto_Close option is set, then close all the folds
    if g:Cproperty_File_Fold_Auto_Close
        " Close all the folds
        silent! %foldclose
    endif

    " Move the cursor to the top of the taglist window
    normal! gg
endfunction

fun! s:Cproperty_Window_Refresh_File(classes)
  " Mark the buffer as modifiable
  setlocal modifiable

  let s:Cproperty_heap_i = s:Cproperty_heap.new()
  call s:Cproperty_heap_i.create_file_folds(s:Cproperty_buf_files, a:classes)

  put! =a:classes.Print(s:Cproperty_buf_files)

  call s:Cproperty_Create_Folds_For_File(s:Cproperty_heap_i)

  " Mark the buffer as not modifiable
  setlocal nomodifiable
endfun

function! s:Cproperty_Create_Folds_For_File(folds)
  " call s:Cproperty_Log_Msg("Folds: " . a:folds.print())
  call a:folds.sort_folds()

  " max value for foldcolumn is 12
  if (a:folds.folds[0].fold_level <= 12)
    exe 'set foldcolumn=' . (a:folds.folds[0].fold_level + 1)
  else
    set foldcolumn=12
  endif

  for l:fold in a:folds.folds
    exe l:fold.start . "," . l:fold.end . "fold"
  endfor
  exe 'silent! ' . a:folds.folds[-1].start . "," . a:folds.folds[-1].end . "foldopen!"

  call s:Cproperty_close_parent_folds(a:folds)
endfunction

" Close all parent folds recursively
fun! s:Cproperty_close_parent_folds(folds)
  exe 'silent! ' . a:folds.folds[-1].start . "," . a:folds.folds[-1].end . "foldopen!"
  for l:fold in a:folds.folds
    if (l:fold.fold_level > 3 && getline(l:fold.start) =~ '\<Class\>')
      exe "silent! " . l:fold.start . "," . l:fold.end . "foldclose"
    endif
  endfor
  call s:Cproperty_update_fold_col()
endfun

" Cproperty_Ballon_Expr
" When the mouse cursor is over a tag in the taglist window, display the
" tag prototype (balloon)
function! Cproperty_Ballon_Expr()
    " Get the tag search pattern and display it
    return s:Cproperty_Get_Cproperty_Info(v:beval_lnum)
endfunction

fun! s:Cproperty_Get_Cproperty_Info(idx)
  return get(s:Cproperty_info, a:idx, '')
endfun

fun! s:Cproperty_Window_Jump_To_Property()
  let l:fname = s:Cproperty_get_fname()
  if (l:fname == '')
    return
  endif
  let l:lnum = matchstr(getline("."), '<\zs\d\+\ze>')
  let l:winnum = bufwinnr(l:fname)
  if (l:winnum == -1)

        " Open a new window
        let cmd_mod = (v:version >= 700) ? 'keepalt ' : ''
        if g:Cproperty_Use_Horiz_Window
            exe cmd_mod . 'leftabove split ' . escape(l:fname, ' ')
        else
            if winbufnr(2) == -1
                " Only the taglist window is present
                if g:Cproperty_Use_Right_Window
                    exe cmd_mod . 'leftabove vertical split ' .
                                \ escape(l:fname, ' ')
                else
                    exe cmd_mod . 'rightbelow vertical split ' .
                                \ escape(l:fname, ' ')
                endif

                " Go to the taglist window to change the window size to
                " the user configured value
                if g:Cproperty_Use_Horiz_Window
                    exe 'resize ' . g:Cproperty_WinHeight
                else
                    exe 'vertical resize ' . g:Cproperty_WinWidth
                endif
                " Go back to the file window
                call s:Cproperty_Exe_Cmd_No_Acmds('wincmd p')
            else
                " A plugin or help window is also present
                wincmd w
                exe cmd_mod . 'leftabove split ' . escape(l:fname, ' ')
            endif
        endif
  else
    if v:version >= 700
        " If the file is opened in more than one window, then check
        " whether the last accessed window has the selected file.
        " If it does, then use that window.
        let lastwin_bufnum = winbufnr(winnr('#'))
        if bufnr(l:fname) == lastwin_bufnum
            let winnum = winnr('#')
        endif
    endif
    exe winnum . 'wincmd w'
  endif

  "Go to the line containing property
  if (l:lnum != '' && l:lnum =~ '^\d\+')
    exe l:lnum
    normal z.
  else
    call s:Cproperty_Warning_Msg("Error: invalid Line num '" . l:lnum . "'")
  endif
endfun

" Get file name have the class property
fun! s:Cproperty_get_fname()
  "call s:Cproperty_Log_Msg(string(keys(filter(deepcopy(s:Cproperty_file_ref.file_ref), 'index(v:val, line(".")) != -1'))))
  let l:fnames = keys(filter(deepcopy(s:Cproperty_file_ref.file_ref), 'index(v:val, line(".")) != -1'))

  if len(l:fnames) == 0
    call s:Cproperty_Warning_Msg("File reference not found: '" . matchstr(getline("."), '^\s*\zs\w*') . "'")
    return ''
  elseif len(l:fnames) > 1
    call s:Cproperty_Warning_Msg("More than one file reference found: '" . matchstr(getline("."), '^\s*\zs\w*') . "'")
    call s:Cproperty_Log_Msg(s:Cproperty_file_ref.Print())
  endif

  " return the first file found
  return l:fnames[0]
endfun

fun! s:Cproperty_update_fold_col()
  if (!exists('s:Cproperty_heap_i.folds'))
    return
  endif
  let fold_level = s:Cproperty_heap_i.folds[0].fold_level
  while fold_level != 0
    let stop = 0
    for l:fold in filter(deepcopy(s:Cproperty_heap_i.folds), 'v:val.fold_level =~ fold_level')
      if (foldclosed(l:fold.start) == -1)
        let stop = 1
      endif
    endfor
    if (stop == 1)
      break
    endif
    let fold_level -= 1
  endwhile

  " max value of foldcolumn is 12
  if (fold_level < 12)
    exe 'set foldcolumn=' . (fold_level + 1)
  else
    set foldcolumn=12
  endif
endfun

" Define the taglist autocommands
augroup TagListAutoCmds
  autocmd InsertEnter *.sv call s:Cproperty_get_current_class()
  "autocmd CursorMovedI * call s:Cproperty_get_current_class()
  " FIXME
augroup end

""----------------------------------------------------------------------------
""  TODO: Cproperty completion
""----------------------------------------------------------------------------
let s:Cproperty_current_class_i = s:Cproperty_class.new()

" Get current class object i.e. class just befor the cursor line
fun! s:Cproperty_get_current_class()
  let s:Cproperty_current_class_i = s:Cproperty_class.new()
  let l:line_start = search('\v(^[[:alnum:]_[:space:]]*)<class>', 'bn')
  let l:line_end = search('^\s*\<endclass\>', 'n')
  if (l:line_start != 0 && l:line_end != 0)
    let l:classes = s:Cproperty_process_file(expand("%:p"), l:line_start, l:line_end)
    if len(values(l:classes.classes)) == 0
      return
    endif
  else
    return
  endif
  if len(values(l:classes.classes)) > 1
    call s:Cproperty_Warning_Msg("Error: More than one current class found")
  endif
  let s:Cproperty_current_class_i = values(l:classes.classes)[0]
  return s:Cproperty_current_class_i
endfun

" Completion for the current class properties
fun! s:Cproperty_get_completion()

  " Get current class
  call s:Cproperty_get_current_class()

  " Whether to show parent class recursively
  if (g:Cproperty_show_parent_class == 1)
    " If reference classes is available to get parent class
    if !empty(s:Cproperty_all_classes_i)
      call s:Cproperty_current_class_i.GetHasAProperty(s:Cproperty_all_classes_i)
    endif
  endif

  "call s:Cproperty_Log_Msg(string(s:Cproperty_current_class_i))
  let l:cproperty_list = s:Cproperty_current_class_i.get_property_list()

  call s:Cproperty_completion(l:cproperty_list)
  return ''

endfun

" Display pum for list matching current word
" FIXME: Make the function library function
fun! s:Cproperty_completion(list)
  let l:line = getline('.')
  let l:start = col('.') - 1
  let l:end = copy(l:start)
  while l:start > 0 && l:line[l:start - 1] =~ '\k'
    let l:start -= 1
  endwhile
  let l:base = strpart(l:line, l:start, (l:end - l:start))
  
  " sequence through list and get the list of matches
  let l:res = []
  for i in range(len(a:list))
    if (type(a:list[i]) == 1)
      if a:list[i] =~ '^' . l:base
        "call complete_add(a:list[i])
        call add(l:res, a:list[i])
      endif
    elseif (type(a:list[i]) == 4)
      "if (a:list[i].abbr =~ '^' . l:base || a:list[i].word =~ '^' . l:base)
      if (a:list[i].word =~ '^' . l:base)
        "call complete_add(a:list[i])
        call add(l:res, a:list[i])
      endif
    endif
    " if complete_check()
    "   break
    " endif
  endfor
  call complete(l:start + 1, l:res)
  return ''
endfun

" Get completion for the class variable objects
fun! s:Cproperty_check_for_completion()

  if !empty(s:Cproperty_all_classes_i)
    call s:Cproperty_current_class_i.GetHasAProperty(s:Cproperty_all_classes_i)
  endif

  let l:property_list = s:Cproperty_get_class_property()

  if type(l:property_list) == type("")
    return ''
  endif

  call s:Cproperty_completion(l:property_list)
  return ''
endfun

" Get the class property list from object hairarchy ex: <obj1>.<obj2>.
fun! s:Cproperty_get_class_property()
  let l:line = getline('.')
  let l:start = col('.') - 1
  let l:use_current = 0

  " Get the object name just before '.'
  while l:start > 0 && l:line[l:start] != '.'
    if (l:line[l:start - 1] !~ '[[:alnum:]_.]')
      let l:use_current = 1
      break
    endif
    let l:start -= 1
  endwhile

  if (l:use_current == 1 || l:start == 0)
    call s:Cproperty_get_completion()
    return ''
  endif

  let l:end = l:start

  while l:start > 0 && l:line[l:start - 1] =~ '[[:alnum:]_.]'
    let l:start -= 1
  endwhile

  let l:property_list = []
  let l:obj_full_name = strpart(l:line, l:start, (l:end - l:start))
  let l:obj_names = split(l:obj_full_name, '\.')


  let l:idx = 0
  for l:obj_name in l:obj_names
    if (l:idx == 0)
      let l:class_names = filter(s:Cproperty_current_class_i.get_property_list(), 'v:val.word == l:obj_name')
    else
      let l:class_names = filter(l:property_list, 'v:val.word == l:obj_name')
    endif
    " call s:Cproperty_Log_Msg(l:class_names[0].menu . " -> ")

    if len(l:class_names) >= 1
      " Get the list or properties from the class
      if !empty(s:Cproperty_all_classes_i)
        let l:classes = values(filter(deepcopy(s:Cproperty_all_classes_i.classes), 'v:key == l:class_names[0].menu'))
        if len(l:classes) == 1
          let l:property_list = l:classes[0].get_property_list()
        elseif (len(l:classes) > 1)
          echoerr "Error: More than one class found"
        else
          let l:property_list = []
        endif
      endif
    endif

    let l:idx += 1
  endfor
  return l:property_list
endfun


" nmap ± :let a = <SID>Cproperty_get_current_class()
" nmap ² :let b = <SID>Cproperty_process_dir('/opt/Project/RCI/NGAP/CVS_NGAP/RCI_NGAP/nand_controller/trunk/dv')

""----------------------------------------------------------------------------
"" TODO: Auto completion on detecting '.' character when class object is accessed hairarically
""----------------------------------------------------------------------------
