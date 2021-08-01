
"=========================================================
" Moving through file
"=========================================================
"print the location of the file under cursor
nmap <LeftMouse> <LeftMouse> :echo  findfile(tolower(expand("<cfile>")), &path, -1)
"grep where location of entity with name under cursor
""nmap g <LeftMouse>:exe '!grep -nri "\(architecture\\|entity\)\s\+' . expand("<cword>") . '.\+is" $BASE_DIR/src/dsn/'

function! Go2file(pname)
  exe 'set pa=' . expand("%:p:h") . ',/usr/include,,,' . a:pname
  try
    if (finddir(tolower(expand("<cfile>"))) != "")
      normal gf
      E
    else
      normal gF
    endif
  catch
    if (findfile(tolower(expand("<cfile>"))) != "")
      exe "find " . findfile(tolower(expand("<cfile>")))
    else
      echo 'Error : Can''t find file "' . expand("<cfile>") . '" in path !!!'
    endif
  endtry
  exe 'set pa=.,/usr/include,,,$BASE_DIR/**'
endfunction

function! Go2entity(pname)
"  let @c = input ("1. Design\n2. Test Bench\nEnter Choice :")
let @c = 1
  if (@c == 1)
    " let s:pname = '$BASE_DIR/ddr2_sb/src/dsn/**'
    let s:pname = '$BASE_DIR'
  elseif (@c == 2)
    let s:pname = '$BASE_DIR/verify/tb/**'
  else
    let s:pname = a:pname
  endif
  normal ma
  let @l = line(".") + 1
  let @a = getline(@l)
  exe 'read !grep -nri "\(architecture\|entity\)\s\+\<' . expand("<cword>") . '\>\s\+is" `find ' . s:pname . ' -iname "*.vhd"`' 
  let @b = getline(@l)
  if (@b == @a)
    u
    normal `a
    echo 'Error : Can''t find file with entity "' . expand("<cword>") . '"'
  else
    exe @l
    while expand("<cfile>") == 'Binary'
      let @l = @l + 1
      exe @l
      let @b = getline(@l)
    endwhile
    let @+ = expand("<cfile>")
    u
    normal `a
    exe 'tabnew ' . @+
  endif
endfunction

"** imp when used for searching a file with gf or [I
set suffixesadd=.vhd,.v,.sv
nmap z<LeftMouse> <LeftMouse>:call Go2file("$BASE_DIR/src/dsn/**")
" find file with entity and open in new tab
nmap <silent>  :silent call Go2entity("./")
"=========================================================

"=================================================================================
" GO TO COMPONENT
"=================================================================================

function! Go2component(pname)
"  let @c = input ("1. Design\n2. Test Bench\nEnter Choice :")
let @c = 1
  if (@c == 1)
    let s:pname = '$BASE_DIR'
  elseif (@c == 2)
    let s:pname = '$BASE_DIR/verify/tb/**'
  else
    let s:pname = a:pname
  endif
  let @s = expand("<cword>")
  exe '!grep -nri "\(component\)\s\+' . @s . '\s\+is" `find ' . s:pname . ' -iname "*.vhd"` >~/a'
  tabnew ~/a
  $
  let @l = line(".")
  while @l != 0
      exe @l
"    if (expand("<cfile>") == 'Binary')
    if (getline(".") =~ 'Binary file')
      call setline(".", '')
      let @l = @l - 1
      "d
    else
      let @b = expand("<cfile>:.")
      normal f:l
      let @d = expand("<cword>")
      let @b = @b . " (" . @d . ")"
      call setline(".", @b)
      let @l = @l - 1
    endif
  endwhile
  g/^$/d
  w
endfunction

nmap <silent>  :silent call Go2component("./")

"=================================================================================



