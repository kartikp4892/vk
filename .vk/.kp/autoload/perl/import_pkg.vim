"-------------------------------------------------------------------------------
" read_pkg: Function
"-------------------------------------------------------------------------------
function! perl#import_pkg#read_pkg()
  let pkg_name = matchstr(getline('.'), '\vuse\s+\zs[0-9a-zA-Z_:]+\ze\s*;')
  let pkg = substitute(pkg_name, '::', '/', 'g')
  let pkg = pkg . '.pm'

  let pkg_file = $KP_PERL_LIB_HOME . pkg

  if (!filereadable(pkg_file))
    echohl Error
    echo 'package ' . pkg_file . ' not found!!!'
    echohl None
    return
  endif

  let pkg_lines = readfile(pkg_file)
  let last_line = index(pkg_lines, '1;')
  let pkg_lines = pkg_lines[0:last_line - 1]

  let pkg_lines = ['# ####################################################################',
                  \'# [START] Package ' . pkg_name] + pkg_lines

  let pkg_lines = pkg_lines + ['# [END] Package ' . pkg_name,
                              \'# ####################################################################']

  call setline('.', '')
  call append(line('.') - 1, pkg_lines)
endfunction
