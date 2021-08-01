
let $KP_TEMPLETE_HOME = $KP_VIM_HOME . 'templetes/shell/templetes/'

command! -nargs=0 -bar ShellGetOpt exe '0read ' . $KP_TEMPLETE_HOME . 'get_opt.t'
command! -nargs=0 -bar SvQuestaRunBasic exe '0read ' . $KP_TEMPLETE_HOME . 'questa_run_basic.t'
command! -nargs=0 -bar SvQuestaRunFull exe '0read ' . $KP_TEMPLETE_HOME . 'questa_run_full.t'
command! -nargs=0 -bar SvQuestaExclusions exe '0read ' . $KP_TEMPLETE_HOME . 'questa_exclusions.t'
command! -nargs=0 -bar SvStartfile exe '0read ' . $KP_TEMPLETE_HOME . 'questa_startfile'
command! -nargs=0 -bar Cpan exe '0read ' . $KP_TEMPLETE_HOME . 'local_cpan.t'






