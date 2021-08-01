"-------------------------------------------------------------------------------
" new: Function
"-------------------------------------------------------------------------------
function! perl#www_selenium#new()
  let str = 'my $sel = WWW::Selenium -> new( host => "localhost",
            \                                port => 4444,
                                            \browser => "*firefox",
                                            \browser_url => "maa",
                                            \error_callback => \&sel_err_cb,
                                        \);mb`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" start_stop: Function
"-------------------------------------------------------------------------------
function! perl#www_selenium#start_stop()
  let str = '$sel -> start;
            \
            \maa
            \
            \$sel -> stop;`aa'
  return str
endfunction

