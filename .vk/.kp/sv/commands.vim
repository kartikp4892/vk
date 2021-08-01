function! s:all_cleanup_without_indent()
  " SVParserUpdateIfndef

  SVCodeComment all
  SVEndLabel all
endfunction

function! s:all_cleanup_with_indent()
  " SVParserUpdateIfndef
  SVIndentCleanUp

  SVCodeComment all
  SVEndLabel all
endfunction

" Set comments after 'end' for begin-end pair
command! -nargs=+ -bar SVCodeComment call sv#sv#comment_begin_end#SetBeginEndPairs(<f-args>)

" Set end label for class,function and task
command! -nargs=+ -bar SVEndLabel call sv#sv#set_end_label#SetListEnd(<f-args>)

" Set end label for class,function and task
"command! -range=% -nargs=0 SVIndentCleanUp <line1>, <line2>call sv#sv#indent_cleanup#cleanup_indent_perl()
command! -range=% -nargs=0 SVIndentCleanUp call sv#sv#indent_cleanup#cleanup_indent(<line1>, <line2>)

" Convert class function/task into extern function/task
command! -range=% -nargs=0 SVExtern <line1>,<line2>call sv#sv#extern#parse()

" Generate UVM Skalaton
command! -nargs=0 UVMAgent call sv#uvm#uvm_scalaton#agent_skalaton()
command! -nargs=0 UVMEnv call sv#uvm#uvm_scalaton#env_skalaton()

" Cleanup stuff
command! -nargs=0 SVAllCleanUpWithoutIndent silent call s:all_cleanup_without_indent()

command! -nargs=0 SVAllCleanUpWithIndent silent call s:all_cleanup_with_indent()

"-------------------------------------------------------------------------------
" Fold by expr
"-------------------------------------------------------------------------------
command! -nargs=0 SVFold setl foldenable foldmethod=expr foldexpr=fold#sv_fold#svfold(v:lnum) foldtext=fold#sv_fold#svfoldtext() foldcolumn=3
command! -nargs=* BufdoSVcleanup silent bufdo %call sv#cleanup#all()

" Parser
" || DEPRECATED || command! -nargs=* ParserReturnOnNull exec parser#uvm#utils#assign_and_return_on_null(<args>)
" || DEPRECATED || command! -nargs=* ParserBreakOnNull exec parser#uvm#utils#assign_and_break_on_null(<args>)
" || DEPRECATED || command! -nargs=* ParserExpectKeyword exec parser#uvm#utils#expect_keyword(<args>)
" || DEPRECATED || command! -nargs=* ParserExpectKeywordPtrn exec parser#uvm#utils#expect_keyword_ptrn(<args>)
" || DEPRECATED || command! -range=% -nargs=* SVParserRemoveOldComment call sv#uvm#parser#update_comment#remove_old_comment()
" || DEPRECATED || " ----------------------------------------------
" || DEPRECATED || command! -range=% -nargs=* SVParserUpdateComment <line1>,<line2>call sv#uvm#parser#update_comment#update_comment()
" || DEPRECATED || command! SVParserUpdateIfndef call sv#uvm#parser#update_ifndef#update_ifndef()
" ----------------------------------------------

" Parser python
command! -range=% -nargs=* ANcomments silent <line1>,<line2>pyfile $KP_VIM_HOME/python_lib/vim/lib/sv/alphanumero/parser/comment/cleanup.py
command! -nargs=* BufdoANcomments silent bufdo %call alphanumero#cleanup#comments()
command! -range=% -nargs=* ANUvmInfo silent <line1>,<line2>pyfile $KP_VIM_HOME/python_lib/vim/lib/sv/alphanumero/parser/uvm_info/Combinators.py
command! -nargs=* BufdoANUvmInfo silent bufdo %call alphanumero#cleanup#uvm_info()

command! -nargs=* BufdoANcleanup silent bufdo %call alphanumero#cleanup#all()

" Debug check if parser is working without shouting errors
command! -range=% -nargs=* SVCheckParser silent bufdo <line1>,<line2>pyfile $KP_VIM_HOME/python_lib/vim/lib/sv/base/parser/Combinators.py
" ----------------------------------------------




