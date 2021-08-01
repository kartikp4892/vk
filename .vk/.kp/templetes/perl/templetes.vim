
let $KP_TEMPLETE_HOME = $KP_VIM_HOME . 'templetes/perl/templetes/'
let $KP_PERL_LIB_HOME = $KP_VIM_HOME . 'templetes/perl/my_perl_lib/'

command! -nargs=0 -bar ScraperBasic exe '0read ' . $KP_TEMPLETE_HOME . 'scrapy.t' | g/[[:cntrl:]]/normal $a<TAB>

command! -nargs=0 -bar ScrapyTop exe '0read ' . $KP_TEMPLETE_HOME . 'scrapy_top.t' | g/[[:cntrl:]]/normal $a<TAB>
command! -nargs=0 -bar ScrapyLink exe '0read ' . $KP_TEMPLETE_HOME . 'scrapy_link.t' | g/[[:cntrl:]]/normal $a<TAB>
command! -nargs=0 -bar ScrapyData exe '0read ' . $KP_TEMPLETE_HOME . 'scrapy_data.t' | g/[[:cntrl:]]/normal $a<TAB>
command! -nargs=0 -bar ScrapyLookUp exe '0read ' . $KP_TEMPLETE_HOME . 'scrapy_lookup.t'

command! -nargs=0 -bar PerlGetOpt exe '0read ' . $KP_TEMPLETE_HOME . 'get_opt.t'

" Templete of bid
command! -nargs=0 -bar PerlElanceBid exe '0read ' . $KP_TEMPLETE_HOME . 'elance_bid.t'

" 
command! -nargs=0 -bar SvQuestaCoverage exe '0read ' . $KP_TEMPLETE_HOME . 'sv_questa_coverage.t'
command! -nargs=0 -bar SvQuestaRegression exe '0read ' . $KP_TEMPLETE_HOME . 'sv_questa_regression_run_input_xml.t'
command! -nargs=0 -bar SvQuestaExclusion exe '0read ' . $KP_TEMPLETE_HOME . 'sv_questa_generate_exclusions.t'


