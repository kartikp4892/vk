
let $KP_MAKE_TEMPLETE_HOME = $KP_VIM_HOME . 'templetes/make/'

"-------------------------------------------------------------------------------
" SV
let $KP_SV_TEMPLETE_HOME = $KP_MAKE_TEMPLETE_HOME . 'sv/templetes/'
let $KP_CPP_TEMPLETE_HOME = $KP_MAKE_TEMPLETE_HOME . 'cpp/templetes/'

" Set comments after 'end' for begin-end pair
"command! -nargs=0 -bar SVmake exe '0read ' . $KP_SV_TEMPLETE_HOME . 'make.t' | g/[[:cntrl:]]/normal $a<TAB>
command! -nargs=0 -bar MakeQuesta exe '0read ' . $KP_SV_TEMPLETE_HOME . 'questa.make'
command! -nargs=0 -bar MakeVivado exe '0read ' . $KP_SV_TEMPLETE_HOME . 'vivado.make'
command! -nargs=0 -bar MakeCPP exe '0read ' . $KP_CPP_TEMPLETE_HOME . 'make.t'

"-------------------------------------------------------------------------------

