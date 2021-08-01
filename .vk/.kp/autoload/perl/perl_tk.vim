"-------------------------------------------------------------------------------
" pack: Function
"-------------------------------------------------------------------------------
function! perl#perl_tk#pack()
  let indent = col('.') - indent('.') - 1
  let str = "-> pack (-side => 'topmaa',". repeat(" ", indent) . "
            \     -fill => 'nonemba',
              \-expand => 0mca,
              \-anchor => 'centermda',
            \\<BS>\<BS>);mea"
  return str
endfunction

