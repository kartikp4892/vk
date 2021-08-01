let s:table = {}

function! s:table.getmax() dict
  let self.maxwidth = {}
  for l:list in self.rows
    let l:idx = 0
    for l:col in l:list
      if (exists("self.maxwidth[l:idx]"))
        if (self.maxwidth[l:idx] < strlen(substitute(l:col, '.', 'x', 'g')))
          let self.maxwidth[l:idx] = strlen(substitute(l:col, '.', 'x', 'g'))
        endif
      else
        let self.maxwidth[l:idx] = strlen(substitute(l:col, '.', 'x', 'g'))
      endif
      let l:idx += 1
    endfor
  endfor
  return string(self.maxwidth)
endfunction

function! s:table.getTable(useMultibyte) dict
  " useMultibyte to include multibyte character for creating table
  "l : left, m: middle, r: right
  "u : up , m: middle, d: down
  if (a:useMultibyte == 'y')
    let l:lu = '┌'
    let l:mu = '┬'
    let l:ru = '┐'

    let l:lm = '├'
    let l:mm = '┼'
    let l:rm = '┤'

    let l:ld = '└'
    let l:md = '┴'
    let l:rd = '┘'

    let l:vsc = '│' " seperate character
    let l:hsc = '─' " horizontal seperate character
  else
    let l:lu = '+'
    let l:mu = '+'
    let l:ru = '+'

    let l:lm = '|'
    let l:mm = '+'
    let l:rm = '|'

    let l:ld = '+'
    let l:md = '+'
    let l:rd = '+'

    let l:vsc = '|' " vertical seperate character
    let l:hsc = '-' " horizontal seperate character
  endif
  let self.table = []
  for l:list in self.rows
    let l:idx = 0
    let l:str = ''
    for l:col in l:list
      let l:str .= printf(l:vsc . " %-". self.maxwidth[l:idx] . "s ", l:col) " Use multibyte char
      "let l:str .= printf("| %-". self.maxwidth[l:idx] . "s ", l:col)
      let l:idx += 1
    endfor
    let l:str .= l:vsc
    "let l:str .= '|'
    call add(self.table, l:str)

    let l:idx = 0
    let l:str = ''
      for l:col in l:list
        let l:str .= printf(l:mm . l:hsc . "%-". self.maxwidth[l:idx] . "s" . l:hsc, repeat(l:hsc,self.maxwidth[l:idx]))
        " let l:str .= printf("+-%-". self.maxwidth[l:idx] . "s-", repeat('-',self.maxwidth[l:idx]))
        let l:idx += 1
      endfor
    let l:str .= l:rm
    let l:str = substitute(l:str, '^' . l:mm, l:lm, '')
    " let l:str .= '|'
    " let l:str = substitute(l:str, '^+', '|', '')

    let l:idx = 0
    let l:start_str = ''
      for l:col in l:list
        let l:start_str .= printf(l:mu . l:hsc . "%-". self.maxwidth[l:idx] . "s" . l:hsc, repeat(l:hsc,self.maxwidth[l:idx]))
        " let l:start_str .= printf("+-%-". self.maxwidth[l:idx] . "s-", repeat('-',self.maxwidth[l:idx]))
        let l:idx += 1
      endfor
    let l:start_str .= l:ru
    let l:start_str = substitute(l:start_str, '^' . l:mu, l:lu, '')
    " let l:start_str .= '+'

    let l:idx = 0
    let l:end_str = ''
      for l:col in l:list
        let l:end_str .= printf(l:md . l:hsc . "%-". self.maxwidth[l:idx] . "s" . l:hsc, repeat(l:hsc,self.maxwidth[l:idx]))
        " let l:end_str .= printf("+-%-". self.maxwidth[l:idx] . "s-", repeat('-',self.maxwidth[l:idx]))
        let l:idx += 1
      endfor
    let l:end_str .= l:rd
    let l:end_str = substitute(l:end_str, '^' . l:md, l:ld, '')
    " let l:end_str .= '+'

    call add(self.table, l:str)
  endfor
  call remove(self.table, -1)

  call add(self.table, l:end_str)
  call insert(self.table, l:start_str)

  return self.table
endfunction

function! table#createTable#Kp_setTable(...) range
  if (a:0 == 0)
    let l:expr = input("Enter Expr: ")
  else
    let l:expr = a:1
  endif
  set cmdheight=2
  echo "Row Seperator: [y/n] "
  let l:rseperator = nr2char(getchar())

  echo "Use Multibyte Char: [y/n] "
  let l:use_multi = nr2char(getchar())
  set cmdheight=1

  let l:table = copy(s:table)
  let l:table.rows = []
  let l:line = a:firstline
  while l:line <= a:lastline
    call add(l:table.rows, map(split(getline(l:line), l:expr), 'substitute(v:val, "^\\s*\\|\\s*$", "", "g")'))
    let l:line += 1
  endwhile

  " Get data in table form
  call l:table.getmax()
  call l:table.getTable(l:use_multi)

  let l:line = a:firstline
  let l:nline = a:firstline
  let l:idx = 0
  call append(l:nline - 1, l:table.table[0])
  let l:nline += 1
  while l:line <= a:lastline
    if (getline(l:nline) =~ expr)
      call setline(l:nline, l:table.table[2 * l:idx + 1])
      if (l:rseperator == 'y' || l:rseperator == 'Y')
        call append(l:nline, l:table.table[2 * l:idx + 2])
        let l:nline += 1
      endif
    endif
    let l:line += 1
    let l:nline += 1
    let l:idx += 1
  endwhile
endfunction

"vmap  :call createTable#Kp_setTable()
